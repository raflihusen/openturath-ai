import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room_failure.dart';
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
  static final Map<String, String> _sentReferences = {};

  /// Alamat tanpa query dan fragmen (token OAuth sering ada di sana).
  static String safePage(String? url) {
    final uri = Uri.tryParse(url ?? '');
    if (uri == null ||
        !const {'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty) return 'unknown';
    final segments = uri.pathSegments.map((part) =>
        part.contains('@') ||
                RegExp(r'(token|password|secret|SID)[=:]', caseSensitive: false)
                    .hasMatch(part)
            ? 'REDACTED' : Uri.encodeComponent(part));
    final path = '${uri.path.startsWith('/') ? '/' : ''}${segments.join('/')}';
    final host = uri.host.contains(':') ? '[${uri.host}]' : uri.host;
    return '${uri.scheme}://$host${uri.hasPort ? ':${uri.port}' : ''}$path';
  }

  static Map<String, dynamic> payload({
    required String stage,
    required String code,
    String category = 'webview',
    String? page,
    Map<String, bool> flags = const {},
    List<Map<String, dynamic>>? breadcrumbs,
    RoomFailure? failure,
  }) {
    final base = AuthFailureReporter.payload(
        stage: failure?.stage ?? stage,
        code: failure?.code ?? code, category: category);
    final crumbs = (breadcrumbs ?? TelemetryService.instance.recentBreadcrumbs)
        .map((c) => {
              'message': TelemetryService.instance
                  .sanitizeData('${c['message'] ?? ''}'),
              'category': AuthFailureReporter.sanitize('${c['category'] ?? ''}'),
            })
        .toList();
    return {
      ...base,
      'schema_version': 2,
      if (failure != null) ...failure.metadata,
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
    RoomFailure? failure,
    http.Client? client,
    Future<String?> Function()? authToken,
  }) async {
    final eventId = failure?.eventId;
    if (eventId != null && _sentReferences.containsKey(eventId)) {
      return _sentReferences[eventId];
    }
    try {
      final body = jsonEncode(payload(
          stage: stage, code: code, category: category, page: page, flags: flags,
          failure: failure));
      String? token;
      if (sender == null) {
        try {
          token = await (authToken ?? _currentToken)()
              .timeout(const Duration(seconds: 2));
        } catch (_) {}
      }
      final headers = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final post = sender ??
          (uri, b) => client != null
              ? client.post(uri, headers: headers, body: b)
              : http.post(uri, headers: headers, body: b);
      final res =
          await post(Uri.parse(endpoint), body).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final ref = (jsonDecode(res.body) as Map)['ref'];
      if (ref is! String || !RegExp(r'^OT-[0-9A-F]{6}$').hasMatch(ref)) return null;
      if (eventId != null) {
        if (_sentReferences.length >= 100) _sentReferences.remove(_sentReferences.keys.first);
        _sentReferences[eventId] = ref;
      }
      return ref;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _currentToken() async {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance.currentUser?.getIdToken();
  }
}
