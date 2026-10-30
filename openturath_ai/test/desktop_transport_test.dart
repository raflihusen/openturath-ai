import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openturath_ai/services/callable_gateway.dart';

void main() {
  Matcher code(String value) =>
      isA<FirebaseFunctionsException>().having((e) => e.code, 'code', value);
  test(
    'Windows callable authenticates and preserves the server contract',
    () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://us-central1-open-turath.cloudfunctions.net/createDokuPayment',
        );
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(jsonDecode(request.body), {
          'data': {'planId': 'monthly'},
        });
        return http.Response('{"result":{"invoice":"123"}}', 200);
      });
      final transport = CallableHttpTransport(
        client: client,
        projectId: 'open-turath',
        token: () async => 'test-token',
      );
      expect(await transport.call('createDokuPayment', {'planId': 'monthly'}), {
        'invoice': '123',
      });
    },
  );
  test('Server unauthenticated rejection retries once with a fresh token',
      () async {
    final seen = <String?>[];
    final transport = CallableHttpTransport(
      client: MockClient((request) async {
        seen.add(request.headers['Authorization']);
        return seen.length == 1
            ? http.Response(
                '{"error":{"status":"UNAUTHENTICATED","message":"expired"}}',
                401)
            : http.Response('{"result":{"ok":true}}', 200);
      }),
      projectId: 'test',
      token: () async => 'old',
      refreshToken: () async => 'fresh',
    );
    expect(await transport.call('getAccessReadiness'), {'ok': true});
    expect(seen, ['Bearer old', 'Bearer fresh']);
  });
  test('Unauthenticated retry happens only once', () async {
    var requests = 0;
    final transport = CallableHttpTransport(
      client: MockClient((_) async {
        requests++;
        return http.Response(
            '{"error":{"status":"UNAUTHENTICATED","message":"no"}}', 401);
      }),
      projectId: 'test',
      token: () async => 'old',
      refreshToken: () async => 'fresh',
    );
    await expectLater(
        transport.call('redeemCode'), throwsA(code('unauthenticated')));
    expect(requests, 2);
  });
  test('Missing login cannot dispatch a paid operation', () async {
    var requests = 0;
    final transport = CallableHttpTransport(
      client: MockClient((_) async {
        requests++;
        return http.Response('{}', 200);
      }),
      projectId: 'test',
      token: () async => null,
    );
    await expectLater(
      transport.call('redeemCode'),
      throwsA(code('unauthenticated')),
    );
    expect(requests, 0);
  });
  test('Callable error details reach the existing entitlement UI', () async {
    final transport = CallableHttpTransport(
      client: MockClient(
        (_) async => http.Response(
          '{"error":{"status":"RESOURCE_EXHAUSTED","message":"Quota exhausted","details":{"limit":3}}}',
          429,
        ),
      ),
      projectId: 'test',
      token: () async => 'token',
    );
    await expectLater(
      transport.call('getNotebookUrl'),
      throwsA(code('resource-exhausted')),
    );
  });
  for (final body in ['<html>upstream error</html>', '[]', '{}']) {
    test('Rejects malformed envelope $body', () async {
      final transport = CallableHttpTransport(
        client: MockClient((_) async => http.Response(body, 200)),
        projectId: 'test',
        token: () async => 'token',
      );
      await expectLater(
        transport.call('getNotebookUrl'),
        throwsA(code('internal')),
      );
    });
  }
  test(
    'Payment timeout never retries a possibly completed transaction',
    () async {
      var requests = 0;
      final transport = CallableHttpTransport(
        client: MockClient((_) async {
          requests++;
          throw TimeoutException('timeout');
        }),
        projectId: 'test',
        token: () async => 'token',
      );
      await expectLater(
        transport.call('createDokuPayment'),
        throwsA(code('deadline-exceeded')),
      );
      expect(requests, 1);
    },
  );
}
