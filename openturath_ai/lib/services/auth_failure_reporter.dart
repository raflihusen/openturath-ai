import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Melaporkan kegagalan login ke server TANPA data pribadi: hanya platform, tahap,
/// kode galat, dan kategori tetap. Endpoint menolak nilai di luar pola
/// `[a-zA-Z0-9_.:-]{1,80}`, jadi token atau email tidak pernah terkirim.
/// Login yang gagal belum punya akun terautentikasi, sehingga jalur
/// `client_error_logs` (wajib login) tidak pernah bisa merekamnya.
class AuthFailureReporter {
  static const endpoint =
      'https://us-central1-open-turath.cloudfunctions.net/reportAuthFailure';
  static String appVersion = 'unknown';
  static final _safe = RegExp(r'^[a-zA-Z0-9_.:-]{1,80}$');

  /// Dibaca dari paket terpasang agar laporan selalu menyebut versi yang benar.
  static Future<void> loadAppVersion() async {
    try {
      appVersion = sanitize((await PackageInfo.fromPlatform()).version);
    } catch (_) {}
  }

  static String sanitize(String value) =>
      _safe.hasMatch(value) ? value : 'unknown';

  static Map<String, String> payload({
    required String stage,
    required String code,
    required String category,
    String? platform,
  }) =>
      {
        'platform': sanitize(platform ?? defaultTargetPlatform.name),
        'stage': sanitize(stage),
        'code': sanitize(code),
        'category': sanitize(category),
        'appVersion': appVersion,
      };

  static final Set<String> _sentThisRun = <String>{};

  /// Seperti [report], tetapi hanya sekali per jalannya aplikasi untuk
  /// kombinasi tahap+kode yang sama, supaya satu halaman yang gagal berulang
  /// tidak menghabiskan batas laju server (20 laporan per jam per IP).
  static void reportOnce({
    required String stage,
    required String code,
    String category = 'webview',
    Future<http.Response> Function(Uri, Map<String, String>)? sender,
  }) {
    if (!_sentThisRun.add('${sanitize(stage)}|${sanitize(code)}')) return;
    report(stage: stage, code: code, category: category, sender: sender);
  }

  @visibleForTesting
  static void resetOnceForTest() => _sentThisRun.clear();

  /// Fire-and-forget: galat jaringan atau server tidak boleh mengganggu login.
  static void report({
    required String stage,
    required String code,
    required String category,
    Future<http.Response> Function(Uri, Map<String, String>)? sender,
  }) {
    final body = payload(stage: stage, code: code, category: category);
    final send = sender ?? (uri, b) => http.post(uri, body: b);
    send(Uri.parse(endpoint), body)
        .timeout(const Duration(seconds: 5))
        .then((_) {}, onError: (_) {});
  }
}
