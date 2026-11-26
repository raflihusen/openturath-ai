import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Pembaca dokumen publik Firestore melalui HTTPS REST API v1.
///
/// Dipakai khusus di Windows untuk dokumen konfigurasi baca-publik
/// (`app_config/version`, `app_config/features`, `app_config/pricing`,
/// `app_config/agents`) agar layar Beranda tidak menyentuh C++ Firestore SDK
/// maupun cache disk LevelDB (`%LOCALAPPDATA%\firestore`) saat aplikasi baru
/// dibuka.
class FirestorePublicDoc {
  FirestorePublicDoc._();

  static const String _projectId = 'open-turath';

  /// Benar bila platform aktif adalah desktop Windows non-web.
  static bool get preferRestOnCurrentPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static Uri documentUri(String collection, String docId) => Uri.https(
        'firestore.googleapis.com',
        '/v1/projects/$_projectId/databases/(default)/documents/$collection/$docId',
      );

  /// Mengambil dokumen publik Firestore sebagai `Map<String, dynamic>` yang
  /// kompatibel dengan `DocumentSnapshot.data()`. Mengembalikan `null` bila
  /// dokumen tidak ada atau jaringan gagal.
  static Future<Map<String, dynamic>?> fetch(
    String collection,
    String docId, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.get(
        documentUri(collection, docId),
        headers: const {
          'Accept': 'application/json',
          'User-Agent': 'OpenTurathApp/2.0',
        },
      ).timeout(timeout);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return decodeDocument(decoded);
    } catch (_) {
      return null;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Mendekode payload JSON REST Firestore v1 (`{"fields": {...}}`) menjadi
  /// peta Dart biasa (`String`, `int`, `double`, `bool`, `List`, `Map`, `null`).
  static Map<String, dynamic>? decodeDocument(Map<String, dynamic> raw) {
    final fields = raw['fields'];
    if (fields == null && raw['name'] is String) {
      return <String, dynamic>{};
    }
    if (fields is! Map) return null;
    final out = <String, dynamic>{};
    fields.forEach((key, value) {
      if (key is String && value is Map) {
        out[key] = _decodeValue(value);
      }
    });
    return out;
  }

  static dynamic _decodeValue(Map<dynamic, dynamic> value) {
    if (value.containsKey('nullValue')) return null;
    if (value.containsKey('booleanValue')) {
      return value['booleanValue'] == true;
    }
    if (value.containsKey('stringValue')) {
      return value['stringValue']?.toString() ?? '';
    }
    if (value.containsKey('integerValue')) {
      final raw = value['integerValue'];
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '') ?? 0;
    }
    if (value.containsKey('doubleValue')) {
      final raw = value['doubleValue'];
      if (raw is num) return raw.toDouble();
      return double.tryParse(raw?.toString() ?? '') ?? 0.0;
    }
    if (value.containsKey('timestampValue')) {
      return value['timestampValue']?.toString();
    }
    if (value.containsKey('arrayValue')) {
      final arrayObj = value['arrayValue'];
      if (arrayObj is Map && arrayObj['values'] is List) {
        return <dynamic>[
          for (final item in arrayObj['values'] as List)
            if (item is Map) _decodeValue(item),
        ];
      }
      return <dynamic>[];
    }
    if (value.containsKey('mapValue')) {
      final mapObj = value['mapValue'];
      final out = <String, dynamic>{};
      if (mapObj is Map && mapObj['fields'] is Map) {
        (mapObj['fields'] as Map).forEach((k, v) {
          if (k is String && v is Map) {
            out[k] = _decodeValue(v);
          }
        });
      }
      return out;
    }
    return null;
  }
}
