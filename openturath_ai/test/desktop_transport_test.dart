import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openturath_ai/services/callable_gateway.dart';
import 'package:openturath_ai/services/desktop_google_sign_in.dart';

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
  test(
    'Loopback callback requires exact one-time state and allowed origin',
    () {
      final state = 'a' * 43;
      bool valid(String? origin, String value) =>
          DesktopGoogleSignIn.validCallback(
            origin: origin,
            state: value,
            expectedState: state,
          );
      expect(valid(DesktopGoogleSignIn.page.origin, state), isTrue);
      expect(
        valid('null', state),
        isTrue,
      ); // Opaque HTTPS-to-loopback form origin.
      expect(valid(null, state), isFalse);
      expect(valid('https://untrusted.example', state), isFalse);
      expect(valid('https://open-turath.web.app', state), isFalse);
      expect(
        valid('https://open-turath.firebaseapp.com.evil.example', state),
        isFalse,
      );
      expect(valid('https://open-turath.firebaseapp.com:444', state), isFalse);
      expect(valid(DesktopGoogleSignIn.page.origin, 'b' * 43), isFalse);
      expect(valid('null', ''), isFalse);
    },
  );
  test(
    'Loopback callback Host must match the exact listener address and port',
    () {
      bool valid(String? host) => DesktopGoogleSignIn.validCallbackEndpoint(
            host: host,
            port: 49152,
            peer: InternetAddress.loopbackIPv4,
          );
      expect(valid('127.0.0.1:49152'), isTrue);
      for (final host in [
        null,
        'localhost:49152',
        '127.0.0.1',
        '127.0.0.1:49153',
        '127.0.0.1:049152',
        '127.0.0.1.:49152',
        '127.0.0.2:49152',
        '127.0.0.1:49152.evil.example',
        'evil.example:49152',
        ' 127.0.0.1:49152',
        '127.0.0.1:49152 ',
        '127.0.0.1:49152, evil.example',
      ]) {
        expect(valid(host), isFalse, reason: 'Host $host must not be accepted');
      }
    },
  );
  test('Callback peer must be the bound IPv4 loopback address', () {
    bool valid(InternetAddress? peer, {int port = 49152}) =>
        DesktopGoogleSignIn.validCallbackEndpoint(
          host: '127.0.0.1:$port',
          port: port,
          peer: peer,
        );
    expect(valid(InternetAddress.loopbackIPv4), isTrue);
    for (final peer in [
      null,
      InternetAddress('127.0.0.2'),
      InternetAddress.loopbackIPv6,
      InternetAddress('::ffff:127.0.0.1'),
      InternetAddress('192.0.2.1'),
    ]) {
      expect(valid(peer), isFalse);
    }
    expect(valid(InternetAddress.loopbackIPv4, port: 0), isFalse);
    expect(valid(InternetAddress.loopbackIPv4, port: 65536), isFalse);
  });
  test('Invalid callbacks do not consume the one-time login state', () {
    final state = 'a' * 43;
    final gate = DesktopGoogleCallbackState(state);
    expect(
      gate.consume(origin: 'https://untrusted.example', state: state),
      isFalse,
    );
    expect(
      gate.consume(origin: DesktopGoogleSignIn.page.origin, state: 'b' * 43),
      isFalse,
    );
    expect(gate.isConsumed, isFalse);
    expect(gate.consume(origin: 'null', state: state), isTrue);
    expect(gate.isConsumed, isTrue);
    expect(
      gate.consume(origin: DesktopGoogleSignIn.page.origin, state: state),
      isFalse,
    );
  });
  test(
    'Concurrent bodies cannot replay state while the first reply is closing',
    () async {
      final state = 'a' * 43;
      final gate = DesktopGoogleCallbackState(state);
      final firstBody = Completer<String>();
      final secondBody = Completer<String>();
      final accepted = Completer<void>();
      final responseClosed = Completer<void>();
      Future<bool> callback(Future<String> body) async {
        if (gate.isConsumed) return false;
        final postedState = await body;
        if (!gate.consume(
          origin: DesktopGoogleSignIn.page.origin,
          state: postedState,
        )) {
          return false;
        }
        accepted.complete();
        await responseClosed.future;
        return true;
      }

      // Both handlers pass their initial check before either body is available.
      final first = callback(firstBody.future);
      final second = callback(secondBody.future);
      firstBody.complete(state);
      secondBody.complete(state);
      await accepted.future;
      expect(gate.isConsumed, isTrue);
      expect(await callback(Future.value(state)), isFalse);
      responseClosed.complete();
      final outcomes = await Future.wait([first, second]);
      expect(outcomes.where((accepted) => accepted).length, 1);
      expect(outcomes.where((accepted) => !accepted).length, 1);
    },
  );
}
