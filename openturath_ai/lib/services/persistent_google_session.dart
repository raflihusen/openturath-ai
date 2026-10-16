import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/notebook_navigation.dart';
import 'desktop_webview_runtime.dart';

/// Brankas sesi Google persisten dengan Cookie Expiration Pinning (180 hari)
/// dan kepatuhan penuh terhadap RFC 6265bis (__Host-* cookies).
class PersistentGoogleSession {
  PersistentGoogleSession._();
  static final PersistentGoogleSession instance = PersistentGoogleSession._();

  static const String _vaultKey = 'ot_persistent_google_cookies_v3';
  static const String _ownerKey = 'webview_session_owner';
  static const String _readyKey = 'google_session_ready';

  static const Set<String> _googleAuthCookies = {
    'SID',
    'HSID',
    'SSID',
    'APISID',
    'SAPISID',
    '__Secure-1PSID',
    '__Secure-3PSID',
    '__Secure-1PAPISID',
    '__Secure-3PAPISID',
    '__Secure-1PSIDTS',
    '__Secure-3PSIDTS',
    'SIDCC',
    '__Secure-1PSIDCC',
    '__Secure-3PSIDCC',
    'LSID',
    '__Host-GAPS',
    '__Host-1PLSID',
    '__Host-3PLSID',
  };

  /// Set cookie dengan mematuhi RFC 6265bis (__Host-* wajib domain: null & path: '/')
  Future<void> _setCookieSafely(
    CookieManager cookieManager, {
    required String name,
    required String value,
    required String rawDomain,
    required String rawPath,
    required int? expiresDate,
    required bool isSecure,
    required bool isHttpOnly,
  }) async {
    final isHostPrefix = name.startsWith('__Host-');
    final isSecurePrefix = name.startsWith('__Secure-') || isHostPrefix;
    final cleanHost = rawDomain.replaceFirst(RegExp(r'^\.'), '');
    final targetHost = cleanHost.isEmpty ? 'google.com' : cleanHost;

    await cookieManager.setCookie(
      url: WebUri('https://$targetHost'),
      name: name,
      value: value,
      domain: isHostPrefix
          ? null
          : (rawDomain.isEmpty ? '.google.com' : rawDomain),
      path: isHostPrefix ? '/' : (rawPath.isEmpty ? '/' : rawPath),
      expiresDate: expiresDate,
      isSecure: isSecurePrefix ? true : isSecure,
      isHttpOnly: isHttpOnly,
      sameSite: isHostPrefix ? HTTPCookieSameSitePolicy.LAX : null,
    );
  }

  /// Kunci seluruh cookie Google dari WebView dan simpan salinannya ke brankas lokal.
  /// Menghindari pemalsuan expiresDate pada token rotasi (DBSC Anti-Tamper).
  Future<bool> lockAndPersistCookies(
    InAppWebViewController? controller,
    String email,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final cookieManager = DesktopWebViewRuntime.cookies;
      final urls = [
        WebUri('https://google.com'),
        WebUri('https://www.google.com'),
        WebUri('https://accounts.google.com'),
        WebUri(NotebookNavigation.canonicalOrigin),
      ];

      final pinnedExpiry =
          DateTime.now().add(const Duration(days: 180)).millisecondsSinceEpoch;
      final Map<String, Map<String, dynamic>> vaultMap = {};

      for (final url in urls) {
        final cookies = await cookieManager.getCookies(
          url: url,
          webViewController: controller,
        );
        for (final c in cookies) {
          final value = c.value?.toString() ?? '';
          if (value.isEmpty) continue;
          if (_googleAuthCookies.contains(c.name) ||
              c.name.startsWith('__Secure-') ||
              c.name.startsWith('__Host-')) {
            final rawDomain = c.domain ?? url.host;
            final rawPath = c.path ?? '/';

            // Kepatuhan Aturan Sakral #8 AGENTS.md (Google DBSC Anti-Tamper):
            // DILARANG memalsukan expiresDate pada token rotasi dan timestamp
            // (__Secure-1PSIDTS, __Secure-3PSIDTS, SIDCC) karena memicu Google Frontend mencabut sesi.
            final isRotationOrSession = c.name.endsWith('TS') ||
                c.name.endsWith('CC') ||
                c.expiresDate == null;
            final effectiveExpiry = isRotationOrSession
                ? c.expiresDate
                : (c.expiresDate != null && c.expiresDate! > pinnedExpiry
                    ? c.expiresDate
                    : pinnedExpiry);

            vaultMap['$rawDomain|$rawPath|${c.name}'] = {
              'name': c.name,
              'value': value,
              'domain': rawDomain,
              'path': rawPath,
              'expiresDate': effectiveExpiry,
              'isSecure': c.isSecure ?? true,
              'isHttpOnly': c.isHttpOnly ?? true,
            };
          }
        }
      }

      if (vaultMap.isEmpty) return false;

      final prefs = await SharedPreferences.getInstance();
      if (cleanEmail.isNotEmpty) {
        await prefs.setString(_ownerKey, cleanEmail);
        await prefs.setString('google_session_email', cleanEmail);
        await prefs.setString('notebook_google_email', cleanEmail);
      }
      await prefs.setBool(_readyKey, true);

      // Obfuscated Base64 envelope untuk mencegah pembacaan plaintext langsung di SharedPreferences
      final payloadJson = jsonEncode({
        'owner': cleanEmail,
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'cookies': vaultMap.values.toList(),
      });
      final encodedVault = base64Encode(utf8.encode(payloadJson));
      await prefs.setString(_vaultKey, encodedVault);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Periksa sesi aktif di WKHTTPCookieStore terlebih dahulu; jika kosong,
  /// pulihkan dari brankas lokal tanpa menimpa atribut token sensitif.
  Future<bool> restoreSessionIfAvailable(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedOwner =
          (prefs.getString(_ownerKey) ?? '').trim().toLowerCase();

      if (savedOwner.isEmpty || savedOwner != cleanEmail) {
        return false;
      }

      final cookieManager = DesktopWebViewRuntime.cookies;

      // Jika cookie aktif Google sudah hidup di WebKit, pertahankan secara organik
      // dan jangan sentuh atau timpa token hidup tersebut.
      final liveCookies = await cookieManager.getCookies(
        url: WebUri(NotebookNavigation.canonicalOrigin),
      );
      final hasLive = liveCookies.any(
        (c) =>
            (c.name == 'SID' || c.name == '__Secure-1PSID') &&
            (c.value?.toString().isNotEmpty ?? false),
      );
      if (hasLive) {
        await prefs.setBool(_readyKey, true);
        return true;
      }

      final raw = prefs.getString(_vaultKey);
      if (raw == null || raw.isEmpty) return false;

      // Mendukung format Base64 baru dan fallback plaintext lama secara mulus
      String jsonStr;
      try {
        jsonStr = utf8.decode(base64Decode(raw));
      } catch (_) {
        jsonStr = raw;
      }

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final vaultOwner = (decoded['owner'] as String? ?? '').toLowerCase();
      if (vaultOwner != cleanEmail) {
        return false;
      }

      final List<dynamic> list =
          decoded['cookies'] as List<dynamic>? ?? const [];
      if (list.isEmpty) return false;

      for (final item in list.whereType<Map<String, dynamic>>()) {
        final int? expiry = item['expiresDate'] as int?;
        await _setCookieSafely(
          cookieManager,
          name: item['name'] as String,
          value: item['value'] as String,
          rawDomain: (item['domain'] as String?) ?? '.google.com',
          rawPath: (item['path'] as String?) ?? '/',
          expiresDate: expiry,
          isSecure: item['isSecure'] as bool? ?? true,
          isHttpOnly: item['isHttpOnly'] as bool? ?? true,
        );
      }

      await prefs.setBool(_readyKey, true);
      if (cleanEmail.isNotEmpty) {
        await prefs.setString(_ownerKey, cleanEmail);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Hapus brankas HANYA ketika pengguna menekan Log Out, hapus akun, atau ganti email.
  Future<void> clearOnSignOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vaultKey);
      await prefs.remove(_ownerKey);
      await prefs.remove(_readyKey);
      await DesktopWebViewRuntime.clearSession();
    } catch (_) {}
  }
}
