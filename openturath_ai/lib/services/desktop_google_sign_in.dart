import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// A synchronous claim prevents two callback handlers waiting on their request
/// bodies from both accepting the same login attempt.
class DesktopGoogleCallbackState {
  DesktopGoogleCallbackState(this.expectedState);

  final String expectedState;
  bool _consumed = false;

  bool get isConsumed => _consumed;

  bool consume({required String? origin, required String state}) {
    if (_consumed ||
        !DesktopGoogleSignIn.validCallback(
          origin: origin,
          state: state,
          expectedState: expectedState,
        )) {
      return false;
    }
    _consumed = true;
    return true;
  }
}

/// Browser-based Firebase Google login. Tokens arrive by POST to a short-lived
/// loopback listener, never in a redirect URL, logs or SharedPreferences.
class DesktopGoogleSignIn {
  // Match the hosted page's Firebase authDomain. Redirect fallback must not
  // depend on cross-origin auth-helper storage blocked by modern browsers.
  static final page = Uri.parse(
    'https://openturath.id/desktop-auth.html',
  );
  static const browserCompanionEnabled = bool.fromEnvironment(
    'OPENTURATH_BROWSER_COMPANION',
    defaultValue: false,
  );
  static Future<OAuthCredential?>? _pending;

  static Future<OAuthCredential?> signIn() =>
      _pending ??= _signIn().whenComplete(() => _pending = null);

  static bool validCallback({
    required String? origin,
    required String state,
    required String expectedState,
  }) =>
      // HTTPS-to-loopback form posts may carry an opaque Origin. The random
      // single-use state binds either allowed origin to this login attempt.
      (origin == page.origin || origin == 'null') &&
      state == expectedState &&
      state.length == 43;

  static bool validCallbackEndpoint({
    required String? host,
    required int port,
    required InternetAddress? peer,
  }) =>
      port > 0 &&
      port <= 65535 &&
      host == '127.0.0.1:$port' &&
      peer?.type == InternetAddressType.IPv4 &&
      peer?.address == InternetAddress.loopbackIPv4.address;

  static Future<bool> _launchBrowser(Uri uri) async {
    if (!browserCompanionEnabled) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    // The companion is installed in Chrome. Falling back to another browser
    // would create a second independent Google session.
    try {
      if (Platform.isMacOS) {
        final opened = await Process.run('/usr/bin/open', [
          '-a',
          'Google Chrome',
          uri.toString(),
        ]);
        return opened.exitCode == 0;
      }
      if (Platform.isWindows) {
        for (final root in [
          Platform.environment['PROGRAMFILES'],
          Platform.environment['PROGRAMFILES(X86)'],
          Platform.environment['LOCALAPPDATA'],
        ]) {
          if (root == null || root.isEmpty) continue;
          final executable = '$root\\Google\\Chrome\\Application\\chrome.exe';
          if (!await File(executable).exists()) continue;
          await Process.start(
              executable,
              [
                uri.toString(),
              ],
              mode: ProcessStartMode.detached);
          return true;
        }
        return false;
      }
      if (Platform.isLinux) {
        for (final command in ['google-chrome', 'google-chrome-stable']) {
          final located = await Process.run('/usr/bin/which', [command]);
          if (located.exitCode != 0) continue;
          final executable = (located.stdout as String).trim();
          if (executable.isEmpty ||
              executable.contains('\n') ||
              !executable.startsWith('/')) {
            continue;
          }
          await Process.start(
              executable,
              [
                uri.toString(),
              ],
              mode: ProcessStartMode.detached);
          return true;
        }
      }
    } catch (_) {
      // Launch errors may contain the login URL, so only return a safe status.
      return false;
    }
    return false;
  }

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
              'Halaman masuk desktop belum tersedia. Hubungi pengelola OpenTurath.',
        );
      }
    } finally {
      probe.close();
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final state = base64UrlEncode(
      List.generate(32, (_) => Random.secure().nextInt(256)),
    ).replaceAll('=', '');
    final callbackState = DesktopGoogleCallbackState(state);
    final result = Completer<OAuthCredential?>();
    final subscription = server.listen(
      (request) async {
        try {
          request.response.headers.set('Cache-Control', 'no-store');
          request.response.headers.set('Referrer-Policy', 'no-referrer');
          request.response.headers.set(
            'Content-Security-Policy',
            "default-src 'none'; style-src 'unsafe-inline'",
          );
          if (request.method != 'POST' ||
              request.uri.path != '/callback' ||
              !validCallbackEndpoint(
                host: request.headers.value('host'),
                port: server.port,
                peer: request.connectionInfo?.remoteAddress,
              ) ||
              request.headers.contentType?.mimeType !=
                  'application/x-www-form-urlencoded' ||
              (request.headers.value('origin') != page.origin &&
                  request.headers.value('origin') != 'null') ||
              callbackState.isConsumed ||
              result.isCompleted) {
            request.response.statusCode = HttpStatus.forbidden;
            await request.response.close();
            return;
          }
          final bytes = <int>[];
          await for (final chunk in request.timeout(
            const Duration(seconds: 10),
          )) {
            bytes.addAll(chunk);
            if (bytes.length > 32768) {
              throw const FormatException('Request too large');
            }
          }
          final fields = Uri.splitQueryString(utf8.decode(bytes));
          final idToken = fields['idToken'];
          if (fields['cancel'] != '1' && (idToken == null || idToken.isEmpty)) {
            throw const FormatException('Missing credential');
          }
          final credential = fields['cancel'] == '1'
              ? null
              : GoogleAuthProvider.credential(idToken: idToken);
          // Recheck after the body await, then claim synchronously before any
          // response await. A concurrent handler cannot replay the callback.
          if (result.isCompleted ||
              !callbackState.consume(
                origin: request.headers.value('origin'),
                state: fields['state'] ?? '',
              )) {
            request.response.statusCode = HttpStatus.forbidden;
            await request.response.close();
            return;
          }
          try {
            request.response.headers.contentType = ContentType.html;
            request.response.write(
              '<!doctype html><html lang="id"><meta charset="utf-8">'
              '<title>OpenTurath AI</title><body><h1>Kembali ke OpenTurath AI</h1>'
              '<p>Anda dapat menutup tab ini.</p></body></html>',
            );
            await request.response.close();
          } finally {
            // Once accepted, a disconnected browser cannot discard the result.
            if (!result.isCompleted) result.complete(credential);
          }
        } catch (_) {
          try {
            request.response.statusCode = HttpStatus.badRequest;
            await request.response.close();
          } catch (_) {
            /* Browser disconnected or response already closed. */
          }
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!result.isCompleted) result.completeError(error, stack);
      },
    );
    try {
      final uri = page.replace(
        queryParameters: {
          'callback': 'http://127.0.0.1:${server.port}/callback',
          'state': state,
        },
      );
      if (!await _launchBrowser(uri)) {
        throw FirebaseAuthException(
          code: 'browser-unavailable',
          message: browserCompanionEnabled
              ? 'Google Chrome tidak dapat dibuka. Pasang Google Chrome untuk menghubungkan pendamping desktop.'
              : 'Browser tidak dapat dibuka. Periksa browser bawaan perangkat.',
        );
      }
      return await result.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          throw FirebaseAuthException(
            code: 'desktop-login-timeout',
            message: 'Waktu masuk berakhir. Silakan coba kembali.',
          );
        },
      );
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  }
}
