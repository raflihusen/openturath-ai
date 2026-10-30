import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../core/desktop_oauth_config.dart';

/// Hasil otorisasi Google OAuth dari browser desktop untuk dioper ke Firebase Auth.
class DesktopAuthResult {
  const DesktopAuthResult({
    this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
}

/// Gerbang login Google untuk desktop (Windows): OAuth 2.0 kode otorisasi + PKCE
/// dengan redirect loopback (RFC 8252). Peramban langsung membuka halaman Google;
/// tidak ada halaman perantara dan tidak memakai Firebase Web SDK.
class DesktopAuthGateway {
  static HttpServer? _activeServer;
  static Completer<DesktopAuthResult?>? _activeCompleter;

  static const _authEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const _tokenEndpoint = 'https://oauth2.googleapis.com/token';

  static String _randomUrlSafe(int bytes) {
    final random = Random.secure();
    return base64UrlEncode(List.generate(bytes, (_) => random.nextInt(256)))
        .replaceAll('=', '');
  }

  static String pkceChallenge(String verifier) =>
      base64UrlEncode(sha256.convert(ascii.encode(verifier)).bytes)
          .replaceAll('=', '');

  /// Menukar kode otorisasi dengan token di Google. Dapat diganti saat pengujian.
  static Future<Map<String, dynamic>> _exchangeCode(
      Map<String, String> form) async {
    final response = await http
        .post(Uri.parse(_tokenEndpoint), body: form)
        .timeout(const Duration(seconds: 30));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw PlatformException(
        code: 'desktop_token_exchange_failed',
        message:
            'Google menolak penukaran kode: ${body['error'] ?? response.statusCode}',
      );
    }
    return body;
  }

  static Map<String, dynamic> _idTokenClaims(String? idToken) {
    try {
      final parts = idToken!.split('.');
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return const {};
    }
  }

  /// Memulai login Google melalui peramban bawaan. Mengembalikan `null` bila dibatalkan.
  static Future<DesktopAuthResult?> signIn({
    Duration timeout = const Duration(minutes: 3),
    @visibleForTesting Future<bool> Function(Uri url)? urlLauncher,
    @visibleForTesting
    Future<Map<String, dynamic>> Function(Map<String, String> form)?
        tokenExchange,
  }) async {
    await cancel();

    final completer = Completer<DesktopAuthResult?>();
    _activeCompleter = completer;

    HttpServer server;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    } catch (e) {
      _activeCompleter = null;
      throw PlatformException(
        code: 'desktop_loopback_failed',
        message: 'Gagal menginisialisasi server loopback lokal Windows: $e',
      );
    }
    _shutdownTimer?.cancel();
    _shutdownTimer = null;
    _activeServer = server;

    final state = _randomUrlSafe(24);
    final verifier = _randomUrlSafe(48);
    final redirectUri = 'http://127.0.0.1:${server.port}/oauth2callback';

    late final StreamSubscription<HttpRequest> sub;
    sub = server.listen((request) async {
      if (request.method != 'GET' || request.uri.path != '/oauth2callback') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      final query = request.uri.queryParameters;
      Future<void> reply(bool ok, String message) async {
        request.response.headers
          ..contentType = ContentType.html
          ..add('Cache-Control', 'no-store');
        request.response.write(_resultPage(ok, message));
        await request.response.close();
      }

      if (query['state'] != state) {
        request.response.statusCode = HttpStatus.forbidden;
        await reply(false,
            'Permintaan tidak dikenali. Tutup tab ini dan coba lagi dari aplikasi.');
        return;
      }
      if (query['error'] != null) {
        await reply(false,
            'Proses masuk dibatalkan. Anda dapat menutup tab ini dan mencoba lagi di aplikasi.');
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      final code = query['code'];
      if (code == null || code.isEmpty) {
        request.response.statusCode = HttpStatus.badRequest;
        await reply(false, 'Google tidak mengirim kode otorisasi.');
        return;
      }
      try {
        final tokens = await (tokenExchange ?? _exchangeCode)({
          'code': code,
          'client_id': DesktopOAuthConfig.clientId,
          'client_secret': DesktopOAuthConfig.clientSecret,
          'code_verifier': verifier,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
        });
        final idToken = tokens['id_token'] as String?;
        final accessToken = tokens['access_token'] as String?;
        if ((idToken ?? '').isEmpty && (accessToken ?? '').isEmpty) {
          throw PlatformException(
              code: 'desktop_no_token',
              message: 'Google tidak mengembalikan token.');
        }
        final claims = _idTokenClaims(idToken);
        await reply(true,
            'Akun berhasil dihubungkan. Anda dapat menutup tab ini dan kembali ke aplikasi OpenTurath AI.');
        if (!completer.isCompleted) {
          completer.complete(DesktopAuthResult(
            idToken: idToken,
            accessToken: accessToken,
            email: claims['email'] as String?,
            displayName: claims['name'] as String?,
            photoUrl: claims['picture'] as String?,
          ));
        }
      } catch (e) {
        await reply(false,
            'Gagal menyelesaikan proses masuk. Kembali ke aplikasi dan coba lagi.');
        if (!completer.isCompleted) completer.completeError(e);
      } finally {
        _scheduleServerShutdown();
      }
    });

    final authUrl = Uri.parse(_authEndpoint).replace(queryParameters: {
      'client_id': DesktopOAuthConfig.clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'openid email profile',
      'state': state,
      'code_challenge': pkceChallenge(verifier),
      'code_challenge_method': 'S256',
      'prompt': 'select_account',
    });
    try {
      final launcher = urlLauncher ??
          (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!await launcher(authUrl)) {
        throw Exception('Gagal membuka peramban bawaan sistem.');
      }
    } catch (e) {
      await sub.cancel();
      await cancel();
      throw PlatformException(
        code: 'browser_launch_failed',
        message:
            'Tidak dapat membuka browser sistem untuk otorisasi Google: $e',
      );
    }

    return completer.future.timeout(timeout, onTimeout: () {
      cancel();
      return null;
    }).whenComplete(() {
      sub.cancel();
      _scheduleServerShutdown();
    });
  }

  /// Membatalkan sesi otorisasi aktif dan menutup server socket lokal.
  static Future<void> cancel() async {
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(null);
    }
    _activeCompleter = null;
    if (_activeServer != null) {
      try {
        await _activeServer!.close(force: true);
      } catch (_) {}
      _activeServer = null;
    }
  }

  static Timer? _shutdownTimer;

  /// Menutup server sesi yang sedang berjalan saat ini saja. Timer lama
  /// dibatalkan dan terikat pada instance asalnya, sehingga sesi baru yang
  /// dimulai dalam 500 ms tidak ikut tertutup.
  static void _scheduleServerShutdown() {
    final server = _activeServer;
    _shutdownTimer?.cancel();
    _shutdownTimer = Timer(const Duration(milliseconds: 500), () {
      if (server == null) return;
      try {
        server.close(force: true);
      } catch (_) {}
      if (identical(_activeServer, server)) _activeServer = null;
    });
  }

  static String _resultPage(bool ok, String message) {
    final title = ok ? 'Berhasil' : 'Tidak dapat melanjutkan';
    final mark = ok ? '✓' : '!';
    return '''<!DOCTYPE html>
<html lang="id"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>OpenTurath AI</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:#09090B;color:#FAFAFA;font-family:"Segoe UI",system-ui,sans-serif;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:24px}
.card{background:#18181B;border:1px solid #27272A;border-radius:12px;max-width:420px;width:100%;padding:36px 32px;text-align:center}
.mark{width:48px;height:48px;border-radius:50%;border:1px solid #27272A;background:rgba(255,255,255,.08);display:flex;align-items:center;justify-content:center;margin:0 auto 18px;font-size:22px}
h1{font-size:21px;font-weight:600;margin-bottom:10px}
p{font-size:14px;color:#A1A1AA;line-height:1.55}
</style></head><body><div class="card"><div class="mark">$mark</div><h1>$title</h1><p>$message</p></div></body></html>''';
  }
}
