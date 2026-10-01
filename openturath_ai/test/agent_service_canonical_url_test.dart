import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/constants.dart';
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

Matcher _accessError(String code) => isA<AgentAccessException>()
    .having((error) => error.code, 'code', code);

void main() {
  // Synthetic ID: this suite must never depend on a production notebook.
  const path = '/notebook/00000000-0000-4000-8000-000000000001';
  const assignedUrl = 'https://notebooklm.google.com$path';

  test('uses the server destination even for an agent with a former override',
      () async {
    final gateway = _Gateway(response: {'url': assignedUrl});
    final service = AgentService(functions: gateway);

    expect(await service.getAgentUrl('fiqh_syafii'), assignedUrl);
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
    test('preserves server $code and does not fall back to a local URL', () async {
      final service = AgentService(
        functions: _Gateway(
          error: FirebaseFunctionsException(code: code, message: 'Server error'),
        ),
      );
      await expectLater(service.getAgentUrl('fiqh_syafii'),
          throwsA(_accessError(code)));
    });
  }

  for (final response in [null, 'not a map', ['not a map']]) {
    test('rejects malformed callable response ${response.runtimeType}', () async {
      final service = AgentService(functions: _Gateway(response: response));
      await expectLater(service.getAgentUrl('fiqh_syafii'),
          throwsA(_accessError('invalid-response')));
    });
  }

  for (final response in [{}, {'url': null}, {'url': ''}]) {
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
}
