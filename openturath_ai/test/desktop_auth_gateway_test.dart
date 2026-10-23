import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:openturath_ai/services/desktop_auth_gateway.dart';

void main() {
  group('DesktopAuthGateway RFC 8252 Loopback Server', () {
    tearDown(() async {
      await DesktopAuthGateway.cancel();
    });

    test('Serves standalone auth HTML on GET / with state parameter', () async {
      final uriCompleter = Completer<Uri>();
      final future = DesktopAuthGateway.signIn(
        timeout: const Duration(seconds: 5),
        urlLauncher: (uri) async {
          uriCompleter.complete(uri);
          return true;
        },
      );

      final openedUri = await uriCompleter.future;
      final port = openedUri.port;
      final state = openedUri.queryParameters['state'];
      expect(state, isNotNull);
      expect(state!.length, 32);

      // Verifikasi request GET / mengembalikan HTML bertema OpenTurath
      final response = await http.get(Uri.parse('http://localhost:$port/'));
      expect(response.statusCode, 200);
      expect(response.headers['content-type'], contains('text/html'));
      expect(response.body, contains('Masuk ke OpenTurath'));
      expect(response.body, contains('open-turath.firebaseapp.com'));
      expect(response.body, contains(state));

      await DesktopAuthGateway.cancel();
      await future;
    });

    test(
        'POST /auth-callback completes with DesktopAuthResult when state matches',
        () async {
      final uriCompleter = Completer<Uri>();
      final future = DesktopAuthGateway.signIn(
        timeout: const Duration(seconds: 5),
        urlLauncher: (uri) async {
          uriCompleter.complete(uri);
          return true;
        },
      );

      final openedUri = await uriCompleter.future;
      final port = openedUri.port;
      final state = openedUri.queryParameters['state'];

      // Kirim callback token valid
      final response = await http.post(
        Uri.parse('http://localhost:$port/auth-callback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'state': state,
          'idToken': 'mock-id-token-12345',
          'accessToken': 'mock-access-token-67890',
          'email': 'scholar@openturath.ai',
          'displayName': 'Islamic Scholar',
        }),
      );

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['ok'], isTrue);

      final result = await future;
      expect(result, isNotNull);
      expect(result!.idToken, 'mock-id-token-12345');
      expect(result.accessToken, 'mock-access-token-67890');
      expect(result.email, 'scholar@openturath.ai');
      expect(result.displayName, 'Islamic Scholar');
    });

    test(
        'POST /auth-callback rejects request with mismatched state (CSRF attack)',
        () async {
      final uriCompleter = Completer<Uri>();
      final future = DesktopAuthGateway.signIn(
        timeout: const Duration(seconds: 5),
        urlLauncher: (uri) async {
          uriCompleter.complete(uri);
          return true;
        },
      );

      final openedUri = await uriCompleter.future;
      final port = openedUri.port;

      // Kirim callback dengan state palsu
      final response = await http.post(
        Uri.parse('http://localhost:$port/auth-callback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'state': 'attacker-fake-state',
          'idToken': 'stolen-token',
        }),
      );

      expect(response.statusCode, 403);
      expect(response.body, contains('State mismatch'));

      await DesktopAuthGateway.cancel();
      await future;
    });

    test('GET /cancel completes with null when user cancels flow', () async {
      final uriCompleter = Completer<Uri>();
      final future = DesktopAuthGateway.signIn(
        timeout: const Duration(seconds: 5),
        urlLauncher: (uri) async {
          uriCompleter.complete(uri);
          return true;
        },
      );

      final openedUri = await uriCompleter.future;
      final port = openedUri.port;
      final state = openedUri.queryParameters['state'];

      final response = await http
          .get(Uri.parse('http://localhost:$port/cancel?state=$state'));
      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['canceled'], isTrue);

      final result = await future;
      expect(result, isNull);
    });
  });
}
