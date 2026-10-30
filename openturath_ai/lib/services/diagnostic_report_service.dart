import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_failure_reporter.dart';
import 'telemetry_service.dart';

/// Laporan diagnostik rinci yang dikirim pengguna lewat tombol "Kirim laporan".
///
/// Tidak ada teks bebas dan tidak ada nilai cookie: hanya tahap, kode galat,
/// alamat halaman tanpa query, penanda ada/tidaknya sesi, dan jejak langkah
/// aplikasi yang sudah disamarkan. Server menyaring sekali lagi.
class DiagnosticReportService {
  static const endpoint =
      'https://us-central1-open-turath.cloudfunctions.net/submitDiagnosticReport';

  /// Alamat tanpa query dan fragmen (token OAuth sering ada di sana).
  static String safePage(String? url) {
    final uri = Uri.tryParse(url ?? '');
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return 'unknown';
    return '${uri.scheme}://${uri.host}${uri.path}';
  }

  static Map<String, dynamic> payload({
    required String stage,
    required String code,
    String category = 'webview',
    String? page,
    Map<String, bool> flags = const {},
    List<Map<String, dynamic>>? breadcrumbs,
  }) {
    final base = AuthFailureReporter.payload(
        stage: stage, code: code, category: category);
    final crumbs = (breadcrumbs ?? TelemetryService.instance.recentBreadcrumbs)
        .map((c) => {
              'message': TelemetryService.instance
                  .sanitizeData('${c['message'] ?? ''}'),
              'category': AuthFailureReporter.sanitize('${c['category'] ?? ''}'),
            })
        .toList();
    return {
      ...base,
      'page': safePage(page),
      'flags': flags,
      'breadcrumbs': crumbs,
    };
  }

  /// Mengembalikan kode rujukan (mis. OT-1A2B3C) atau null bila gagal terkirim.
  static Future<String?> send({
    required String stage,
    required String code,
    String category = 'webview',
    String? page,
    Map<String, bool> flags = const {},
    Future<http.Response> Function(Uri, String)? sender,
  }) async {
    try {
      final body = jsonEncode(payload(
          stage: stage, code: code, category: category, page: page, flags: flags));
      final post = sender ??
          (uri, b) =>
              http.post(uri, headers: {'Content-Type': 'application/json'}, body: b);
      final res =
          await post(Uri.parse(endpoint), body).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final ref = (jsonDecode(res.body) as Map)['ref'];
      return ref is String && RegExp(r'^OT-[0-9A-F]{6}$').hasMatch(ref)
          ? ref
          : null;
    } catch (_) {
      return null;
    }
  }
}
