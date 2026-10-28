import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:openturath_ai/services/desktop_auth_gateway.dart';

String _jwt(Map<String, dynamic> claims) {
  String enc(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${enc({'alg': 'none'})}.${enc(claims)}.sig';
}

void main() {
  group('DesktopAuthGateway OAuth loopback + PKCE', () {
    tearDown(() async {
      await DesktopAuthGateway.cancel();
    });

    Future<(Future<DesktopAuthResult?>, Uri)> start({
      Future<Map<String, dynamic>> Function(Map<String, String>)? exchange,
    }) async {
      final opened = Completer<Uri>();
      final future = DesktopAuthGateway.signIn(
        timeout: const Duration(seconds: 5),
        urlLauncher: (uri) async {
          opened.complete(uri);
          return true;
        },
        tokenExchange: exchange,
      );
      return (future, await opened.future);
    }

    test('membuka halaman Google langsung dengan PKCE S256 dan state',
        () async {
      final (future, url) = await start();
      expect(url.host, 'accounts.google.com');
      expect(url.queryParameters['response_type'], 'code');
      expect(url.queryParameters['code_challenge_method'], 'S256');
      expect(url.queryParameters['code_challenge'], isNotEmpty);
      expect(url.queryParameters['scope'], 'openid email profile');
      expect(url.queryParameters['state'], isNotEmpty);
      final redirect = Uri.parse(url.queryParameters['redirect_uri']!);
      expect(redirect.host, '127.0.0.1');
      expect(redirect.path, '/oauth2callback');
      await DesktopAuthGateway.cancel();
      await future;
    });

    test('kode otorisasi ditukar dengan verifier yang cocok dengan challenge',
        () async {
      Map<String, String>? sent;
      final (future, url) = await start(exchange: (form) async {
        sent = form;
        return {
          'id_token': _jwt({
            'email': 'scholar@openturath.ai',
            'name': 'Islamic Scholar',
            'picture': 'https://x/y.png'
          }),
          'access_token': 'at-123',
        };
      });
      final redirect = Uri.parse(url.queryParameters['redirect_uri']!);
      final res = await http.get(redirect.replace(queryParameters: {
        'code': 'abc',
        'state': url.queryParameters['state']!,
      }));
      expect(res.statusCode, 200);
      expect(res.body, contains('Berhasil'));

      final result = await future;
      expect(result!.accessToken, 'at-123');
      expect(result.email, 'scholar@openturath.ai');
      expect(result.displayName, 'Islamic Scholar');
      expect(sent!['code'], 'abc');
      expect(sent!['redirect_uri'], redirect.toString());
      expect(sent!['grant_type'], 'authorization_code');
      expect(DesktopAuthGateway.pkceChallenge(sent!['code_verifier']!),
          url.queryParameters['code_challenge']);
    });

    test('state palsu ditolak dan tidak menyelesaikan login', () async {
      var exchanged = false;
      final (future, url) = await start(exchange: (_) async {
        exchanged = true;
        return {'access_token': 'x'};
      });
      final redirect = Uri.parse(url.queryParameters['redirect_uri']!);
      final res = await http.get(
          redirect.replace(queryParameters: {'code': 'abc', 'state': 'palsu'}));
      expect(res.statusCode, 403);
      expect(exchanged, isFalse);
      await DesktopAuthGateway.cancel();
      expect(await future, isNull);
    });

    test('pengguna menolak di Google: hasil null', () async {
      final (future, url) = await start();
      final redirect = Uri.parse(url.queryParameters['redirect_uri']!);
      await http.get(redirect.replace(queryParameters: {
        'error': 'access_denied',
        'state': url.queryParameters['state']!,
      }));
      expect(await future, isNull);
    });

    test('penukaran kode gagal diteruskan sebagai galat', () async {
      final (future, url) = await start(exchange: (_) async {
        throw Exception('invalid_grant');
      });
      final failure = expectLater(future, throwsException);
      final redirect = Uri.parse(url.queryParameters['redirect_uri']!);
      final res = await http.get(redirect.replace(queryParameters: {
        'code': 'abc',
        'state': url.queryParameters['state']!,
      }));
      expect(res.body, contains('Gagal'));
      await failure;
    });

    test('peramban gagal dibuka: galat dan server ditutup', () async {
      await expectLater(
        DesktopAuthGateway.signIn(urlLauncher: (_) async => false),
        throwsA(isA<Exception>()),
      );
    });
  });
}
