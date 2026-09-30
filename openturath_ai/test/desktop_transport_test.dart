import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openturath_ai/services/callable_gateway.dart';
import 'package:openturath_ai/services/desktop_google_sign_in.dart';

void main() {
  Matcher code(String value) =>
      isA<FirebaseFunctionsException>().having((e) => e.code, 'code', value);
  test('Windows callable authenticates and preserves the server contract',
      () async {
    final client = MockClient((request) async {
      expect(request.url.toString(),
          'https://us-central1-open-turath.cloudfunctions.net/createDokuPayment');
      expect(request.headers['Authorization'], 'Bearer test-token');
      expect(jsonDecode(request.body), {
        'data': {'planId': 'monthly'}
      });
      return http.Response('{"result":{"invoice":"123"}}', 200);
    });
    final transport = CallableHttpTransport(
        client: client,
        projectId: 'open-turath',
        token: () async => 'test-token');
    expect(await transport.call('createDokuPayment', {'planId': 'monthly'}),
        {'invoice': '123'});
  });
  test('Missing login cannot dispatch a paid operation', () async {
    var requests = 0;
    final transport = CallableHttpTransport(
        client: MockClient((_) async {
          requests++;
          return http.Response('{}', 200);
        }),
        projectId: 'test',
        token: () async => null);
    await expectLater(
        transport.call('redeemCode'), throwsA(code('unauthenticated')));
    expect(requests, 0);
  });
  test('Callable error details reach the existing entitlement UI', () async {
    final transport = CallableHttpTransport(
        client: MockClient((_) async => http.Response(
            '{"error":{"status":"RESOURCE_EXHAUSTED","message":"Quota exhausted","details":{"limit":3}}}',
            429)),
        projectId: 'test',
        token: () async => 'token');
    await expectLater(
        transport.call('getNotebookUrl'), throwsA(code('resource-exhausted')));
  });
  for (final body in ['<html>upstream error</html>', '[]', '{}']) {
    test('Rejects malformed envelope $body', () async {
      final transport = CallableHttpTransport(
          client: MockClient((_) async => http.Response(body, 200)),
          projectId: 'test',
          token: () async => 'token');
      await expectLater(
          transport.call('getNotebookUrl'), throwsA(code('internal')));
    });
  }
  test('Payment timeout never retries a possibly completed transaction',
      () async {
    var requests = 0;
    final transport = CallableHttpTransport(
        client: MockClient((_) async {
          requests++;
          throw TimeoutException('timeout');
        }),
        projectId: 'test',
        token: () async => 'token');
    await expectLater(transport.call('createDokuPayment'),
        throwsA(code('deadline-exceeded')));
    expect(requests, 1);
  });
  test('Loopback callback requires exact one-time state and allowed origin',
      () {
    final state = 'a' * 43;
    bool valid(String? origin, String value) =>
        DesktopGoogleSignIn.validCallback(
            origin: origin, state: value, expectedState: state);
    expect(valid(DesktopGoogleSignIn.page.origin, state), isTrue);
    expect(
        valid('null', state), isTrue); // Opaque HTTPS-to-loopback form origin.
    expect(valid(null, state), isFalse);
    expect(valid('https://untrusted.example', state), isFalse);
    expect(valid('https://open-turath.web.app', state), isFalse);
    expect(valid('https://open-turath.firebaseapp.com.evil.example', state),
        isFalse);
    expect(valid('https://open-turath.firebaseapp.com:444', state), isFalse);
    expect(valid(DesktopGoogleSignIn.page.origin, 'b' * 43), isFalse);
    expect(valid('null', ''), isFalse);
  });
}
