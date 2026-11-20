import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/constants.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/agent_service.dart';
import 'package:openturath_ai/services/callable_gateway.dart';

class _Gateway extends CallableGateway {
  _Gateway({this.response, this.error});

  final Object? response;
  final FirebaseFunctionsException? error;
  String? calledName;
  Map<String, dynamic>? calledData;

  @override
  Future<dynamic> call(String name, [Map<String, dynamic>? data]) async {
    calledName = name;
    calledData = data;
    if (error != null) throw error!;
    return response;
  }
}

Matcher _accessError(String code) =>
    isA<AgentAccessException>().having((error) => error.code, 'code', code);

void main() {
  test(
      'server access reasons survive transport without copying private details',
      () async {
    final gateway = _Gateway(
        error: FirebaseFunctionsException(
      code: 'failed-precondition',
      message: 'Preparing access',
      details: const {
        'reason': 'access_provisioning',
        'request_id': '11111111-2222-4333-8444-555555555555',
        'email': 'private@example.invalid',
        'token': 'not-a-diagnostic-field'
      },
    ));
    await expectLater(
        AgentService(functions: gateway).getAgentUrl('fiqh_syafii'),
        throwsA(isA<AgentAccessException>()
            .having((dynamic e) => e.reason, 'reason', 'access_provisioning')
            .having((dynamic e) => e.requestId, 'requestId',
                '11111111-2222-4333-8444-555555555555')));
  });
  // Synthetic ID: this suite must never depend on a production notebook.
  const path = '/notebook/00000000-0000-4000-8000-000000000001';
  const assignedUrl = 'https://notebooklm.google.com$path';
  const canonicalUrl = 'https://notebook.google.com$path';

  test(
      'preserves server notebook assignment while bypassing legacy host redirect',
      () async {
    final gateway = _Gateway(response: {'url': assignedUrl});
    final service = AgentService(functions: gateway);

    expect(await service.getAgentUrl('fiqh_syafii'), canonicalUrl);
    expect(gateway.calledName, AppConstants.fnGetAgentUrl);
    expect(gateway.calledData, {'agentId': 'fiqh_syafii'});
  });

  test('accepts the official alternate notebook host without rewriting it',
      () async {
    const url = 'https://notebook.google.com$path/';
    final service = AgentService(functions: _Gateway(response: {'url': url}));
    expect(await service.getAgentUrl('hadits'), url);
  });

  for (final code in ['permission-denied', 'unauthenticated', 'unavailable']) {
    test('preserves server $code and does not fall back to a local URL',
        () async {
      final service = AgentService(
        functions: _Gateway(
          error:
              FirebaseFunctionsException(code: code, message: 'Server error'),
        ),
      );
      await expectLater(
          service.getAgentUrl('fiqh_syafii'), throwsA(_accessError(code)));
    });
  }

  for (final response in [
    null,
    'not a map',
    ['not a map']
  ]) {
    test('rejects malformed callable response ${response.runtimeType}',
        () async {
      final service = AgentService(functions: _Gateway(response: response));
      await expectLater(service.getAgentUrl('fiqh_syafii'),
          throwsA(_accessError('invalid-response')));
    });
  }

  for (final response in [
    {},
    {'url': null},
    {'url': ''}
  ]) {
    test('does not conceal missing server destinations: $response', () async {
      final service = AgentService(functions: _Gateway(response: response));
      await expectLater(service.getAgentUrl('fiqh_syafii'),
          throwsA(_accessError('empty-url')));
    });
  }

  final invalidUrls = <Object>[
    123,
    'http://notebooklm.google.com$path',
    'https://notebooklm.google.com.attacker.invalid$path',
    'https://attacker.invalid$path',
    'https://accounts.google.com$path',
    'https://user:password@notebooklm.google.com$path',
    'https://notebooklm.google.com:8443$path',
    'https://notebooklm.google.com/',
    'https://notebooklm.google.com/notebook/not-a-notebook',
    'https://notebooklm.google.com$path/extra',
    '$assignedUrl?redirect=https://attacker.invalid',
    '$assignedUrl#unexpected',
    ' $assignedUrl',
    '$assignedUrl ',
    'https://notebooklm.google.com/%6eotebook/00000000-0000-4000-8000-000000000001',
  ];
  for (var index = 0; index < invalidUrls.length; index++) {
    test('rejects unsafe or invalid destination case $index', () async {
      final service = AgentService(
        functions: _Gateway(response: {'url': invalidUrls[index]}),
      );
      await expectLater(service.getAgentUrl('fiqh_syafii'),
          throwsA(_accessError('invalid-url')));
    });
  }

  test('falls back to canonical master URL when server is down and user is VIP', () async {
    final gateway = _Gateway(
      error: FirebaseFunctionsException(
        code: 'resource-exhausted',
        message: 'Quota exceeded',
      ),
    );
    final service = AgentService(functions: gateway);
    final vipUser = UserModel(
      uid: 'vip-user-uid',
      name: 'VIP User',
      email: 'alkhateeb23@gmail.com',
      photoUrl: '',
      plan: 'all_access',
      questionsUsed: 0,
      isVip: true,
    );

    final url = await service.getAgentUrl('fiqh_syafii', vipUser);
    expect(url, 'https://notebooklm.google.com/notebook/565630db-d4cb-4070-af38-e8cb81d688ea');
  });

  test('auto-detects VIP from canonical email even when isVip flag is false or omitted', () async {
    final gateway = _Gateway(
      error: FirebaseFunctionsException(
        code: 'unavailable',
        message: 'Network error',
      ),
    );
    final service = AgentService(functions: gateway);
    final vipUser = UserModel(
      uid: 'vip-auto-uid',
      name: 'Syekh Mohammed Al-Ahdal',
      email: 'mohammedhalahdal@gmail.com',
      photoUrl: '',
      plan: 'free',
      questionsUsed: 0,
      isVip: false, // Disengaja false untuk membuktikan auto-detection dinamis
    );

    expect(vipUser.isVip, isTrue);
    final url = await service.getAgentUrl('hadits', vipUser);
    expect(url, 'https://notebooklm.google.com/notebook/20b333d1-43eb-4ddb-a776-90473931929b');
  });

  test('does not bypass permission-denied paywall even for provided user', () async {
    final gateway = _Gateway(
      error: FirebaseFunctionsException(
        code: 'permission-denied',
        message: 'Payment required',
        details: const {'reason': 'entitlement_required'},
      ),
    );
    final service = AgentService(functions: gateway);
    final regularUser = UserModel(
      uid: 'regular-uid',
      name: 'Regular User',
      email: 'regular@example.com',
      photoUrl: '',
      plan: 'free',
      questionsUsed: 0,
      isVip: false,
    );

    await expectLater(
      service.getAgentUrl('fiqh_syafii', regularUser),
      throwsA(_accessError('permission-denied')),
    );
  });
}
