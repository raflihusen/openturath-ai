import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Browser-based Firebase Google login. Tokens arrive by POST to a short-lived
/// loopback listener, never in a redirect URL, logs or SharedPreferences.
class DesktopGoogleSignIn {
  // Match the hosted page's Firebase authDomain. Redirect fallback must not
  // depend on cross-origin auth-helper storage blocked by modern browsers.
  static final page =
      Uri.parse('https://open-turath.firebaseapp.com/desktop-auth.html');
  static Future<OAuthCredential?>? _pending;

  static Future<OAuthCredential?> signIn() =>
      _pending ??= _signIn().whenComplete(() => _pending = null);

  static bool validCallback(
          {required String? origin,
          required String state,
          required String expectedState}) =>
      // HTTPS-to-loopback form posts may carry an opaque Origin. The random
      // single-use state binds either allowed origin to this login attempt.
      (origin == page.origin || origin == 'null') &&
      state == expectedState &&
      state.length == 43;

  static Future<OAuthCredential?> _signIn() async {
    final probe = http.Client();
    try {
      final response =
          await probe.get(page).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200 ||
          !response.body.contains('openturath-desktop-auth-')) {
        throw FirebaseAuthException(
            code: 'desktop-login-unavailable',
            message:
                'Halaman masuk desktop belum tersedia. Hubungi pengelola OpenTurath.');
      }
    } finally {
      probe.close();
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final state =
        base64UrlEncode(List.generate(32, (_) => Random.secure().nextInt(256)))
            .replaceAll('=', '');
    final result = Completer<OAuthCredential?>();
    final subscription = server.listen((request) async {
      try {
        request.response.headers.set('Cache-Control', 'no-store');
        request.response.headers.set('Referrer-Policy', 'no-referrer');
        request.response.headers.set('Content-Security-Policy',
            "default-src 'none'; style-src 'unsafe-inline'");
        if (request.method != 'POST' ||
            request.uri.path != '/callback' ||
            request.headers.contentType?.mimeType !=
                'application/x-www-form-urlencoded' ||
            (request.headers.value('origin') != page.origin &&
                request.headers.value('origin') != 'null') ||
            result.isCompleted) {
          request.response.statusCode = HttpStatus.forbidden;
          await request.response.close();
          return;
        }
        final bytes = <int>[];
        await for (final chunk
            in request.timeout(const Duration(seconds: 10))) {
          bytes.addAll(chunk);
          if (bytes.length > 32768) {
            throw const FormatException('Request too large');
          }
        }
        final fields = Uri.splitQueryString(utf8.decode(bytes));
        if (!validCallback(
            origin: request.headers.value('origin'),
            state: fields['state'] ?? '',
            expectedState: state)) {
          request.response.statusCode = HttpStatus.forbidden;
          await request.response.close();
          return;
        }
        final idToken = fields['idToken'];
        if (fields['cancel'] != '1' && (idToken == null || idToken.isEmpty)) {
          throw const FormatException('Missing credential');
        }
        request.response.headers.contentType = ContentType.html;
        request.response.write(
            '<!doctype html><html lang="id"><meta charset="utf-8">'
            '<title>OpenTurath AI</title><body><h1>Kembali ke OpenTurath AI</h1>'
            '<p>Anda dapat menutup tab ini.</p></body></html>');
        await request.response.close();
        if (!result.isCompleted) {
          result.complete(fields['cancel'] == '1'
              ? null
              : GoogleAuthProvider.credential(idToken: idToken));
        }
      } catch (_) {
        try {
          request.response.statusCode = HttpStatus.badRequest;
          await request.response.close();
        } catch (_) {/* Browser disconnected or response already closed. */}
      }
    }, onError: (Object error, StackTrace stack) {
      if (!result.isCompleted) result.completeError(error, stack);
    });
    try {
      final uri = page.replace(queryParameters: {
        'callback': 'http://127.0.0.1:${server.port}/callback',
        'state': state,
      });
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw FirebaseAuthException(
            code: 'browser-unavailable',
            message:
                'Browser tidak dapat dibuka. Periksa browser bawaan perangkat.');
      }
      return await result.future.timeout(const Duration(minutes: 3),
          onTimeout: () {
        throw FirebaseAuthException(
            code: 'desktop-login-timeout',
            message: 'Waktu masuk berakhir. Silakan coba kembali.');
      });
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  }
}
