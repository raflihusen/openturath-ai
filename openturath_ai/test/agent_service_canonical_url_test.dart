import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openturath_ai/core/constants.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/agent_service.dart';
import 'package:openturath_ai/services/callable_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    expect(url, 'https://notebook.google.com/notebook/565630db-d4cb-4070-af38-e8cb81d688ea');
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
    expect(url, 'https://notebook.google.com/notebook/20b333d1-43eb-4ddb-a776-90473931929b');
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

  group('VPS Clone Rollover, Sticky Routing & Auto-Failover', () {
    const clone1Url =
        'https://notebook.google.com/notebook/11111111-1111-4111-8111-111111111111';
    const clone2Url =
        'https://notebook.google.com/notebook/22222222-2222-4222-8222-222222222222';

    UserModel paidRegularUser() => UserModel(
          uid: 'clone-user-2001',
          name: 'Santri Clone 2001',
          email: 'santri2001@example.com',
          photoUrl: '',
          plan: 'tholib_1m',
          questionsUsed: 0,
          entitlements: {
            'fiqh_syafii': ModuleEntitlement(
              plan: 'tholib_1m',
              status: 'active',
              expiry: DateTime.now().add(const Duration(days: 30)),
              paymentStatus: 'paid',
            ),
          },
        );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AgentService.clearAssignedUrlCache();
    });

    test(
        'non-VIP clone user on cold cache NEVER falls back to Master on VPS 403 unauthenticated or 500',
        () async {
      final unauthClient = MockClient((_) async => http.Response(
            jsonEncode({
              'detail': {
                'error': {
                  'status': 'PERMISSION_DENIED',
                  'code': 'unauthenticated',
                  'message': 'Bearer token required',
                }
              }
            }),
            403,
          ));
      final serviceUnauth = AgentService(
        httpClient: unauthClient,
        tokenProvider: (_) async => null,
      );
      await expectLater(
        serviceUnauth.getAgentUrl('fiqh_syafii', paidRegularUser()),
        throwsA(_accessError('unauthenticated')),
      );

      final serverDownClient =
          MockClient((_) async => http.Response('Internal Server Error', 500));
      final serviceDown = AgentService(
        httpClient: serverDownClient,
        tokenProvider: (_) async => 'valid-token',
      );
      await expectLater(
        serviceDown.getAgentUrl('fiqh_syafii', paidRegularUser()),
        throwsA(_accessError('unavailable')),
      );
    });

    test(
        'expired Firebase token retries once with forceRefresh=true and receives assigned Clone URL',
        () async {
      var tokenCalls = 0;
      final client = MockClient((req) async {
        final auth = req.headers['Authorization'];
        if (auth == 'Bearer stale-token') {
          return http.Response(
            jsonEncode({
              'detail': {
                'error': {'code': 'unauthenticated', 'message': 'Expired token'}
              }
            }),
            403,
          );
        }
        expect(auth, 'Bearer fresh-token');
        return http.Response(
          jsonEncode({'result': {'status': 'ready', 'url': clone1Url}}),
          200,
        );
      });

      final service = AgentService(
        httpClient: client,
        tokenProvider: (force) async {
          tokenCalls++;
          return force ? 'fresh-token' : 'stale-token';
        },
      );

      final url = await service.getAgentUrl('fiqh_syafii', paidRegularUser());
      expect(url, clone1Url);
      expect(tokenCalls, 2);
    });

    test(
        'sticky cache unifies aliases, triggers SWR background relocation, and invalidates on 202 provisioning',
        () async {
      var mode = 'clone1';
      final client = MockClient((_) async {
        if (mode == 'clone1') {
          return http.Response(
            jsonEncode({'result': {'status': 'ready', 'url': clone1Url}}),
            200,
          );
        }
        if (mode == 'clone2') {
          return http.Response(
            jsonEncode({'result': {'status': 'ready', 'url': clone2Url}}),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'result': {'status': 'provisioning', 'reason': 'access_provisioning'}
          }),
          202,
        );
      });

      final service = AgentService(
        httpClient: client,
        tokenProvider: (_) async => 'tok',
      );
      final user = paidRegularUser();

      // 1. Cold fetch assigns Clone 1
      expect(await service.getAgentUrl('fiqh_syafii', user), clone1Url);

      // 2. Alias fiqh_syafii_muhaqqiq hits the SAME sticky cache instantly while
      //    background refresh relocates to Clone 2
      mode = 'clone2';
      String? relocatedUrl;
      final stickyHit = await service.getAgentUrl(
        'fiqh_syafii_muhaqqiq',
        user,
        false,
        (fresh) => relocatedUrl = fresh,
      );
      expect(stickyHit, clone1Url);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(relocatedUrl, clone2Url);

      // 3. Force refresh returning 202 provisioning throws access_provisioning & clears sticky cache
      mode = 'provisioning';
      await expectLater(
        service.getAgentUrl('fiqh_syafii', user, true),
        throwsA(isA<AgentAccessException>()
            .having((e) => e.reason, 'reason', 'access_provisioning')),
      );
    });

    test('VIP user falls back to canonical Master URL when VPS returns 500',
        () async {
      final serverDownClient =
          MockClient((_) async => http.Response('Service Unavailable', 503));
      final service = AgentService(
        httpClient: serverDownClient,
        tokenProvider: (_) async => 'tok',
      );
      final vipUser = UserModel(
        uid: 'vip-uid',
        name: 'VIP User',
        email: 'alkhateeb23@gmail.com',
        photoUrl: '',
        plan: 'vip',
        questionsUsed: 0,
        isVip: true,
      );

      final url = await service.getAgentUrl('fiqh_syafii', vipUser);
      expect(
        url,
        'https://notebook.google.com/notebook/565630db-d4cb-4070-af38-e8cb81d688ea',
      );
    });
  });
}
