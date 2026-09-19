import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TelemetryService: Sistem Pemantauan Crash & Error Senyap (Silent Telemetry)
/// ─────────────────────────────────────────────────────────────────────────────
class TelemetryService {
  TelemetryService._({FirebaseFirestore? firestore})
      : _firestore = firestore;

  static final TelemetryService instance = TelemetryService._();

  FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  /// Visible for testing to inject mock instances
  @visibleForTesting
  void setMockInstances({FirebaseFirestore? firestore, FirebaseAuth? auth}) {
    _firestore = firestore;
  }

  /// Ring buffer untuk breadcrumbs (maksimal 20 peristiwa terakhir)
  static const int maxBreadcrumbs = 20;
  final List<Map<String, dynamic>> _breadcrumbs = [];

  /// Deduplikasi error (mencegah log flooding untuk error yang berulang dalam 120 detik)
  static const Duration _dedupWindow = Duration(seconds: 120);
  final Map<String, DateTime> _reportedSignatures = {};

  bool _initialized = false;

  /// Inisialisasi global unhandled error handlers
  void init() {
    if (_initialized) return;
    _initialized = true;

    // 1. Flutter Framework Errors (Widget building, layout, etc.)
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      reportError(
        details.exception,
        details.stack,
        context: 'flutter_framework_error',
        severity: 'error',
        extra: {
          'library': details.library,
          if (kDebugMode) 'summary': details.summary.toString(),
        },
      );
      // Production handlers must not echo raw exceptions to device logs.
      if (kDebugMode) {
        if (originalOnError != null) originalOnError(details);
        else FlutterError.presentError(details);
      }
    };

    // 2. Platform Dispatcher Errors (Async errors, isolates, microtasks)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      reportError(
        error,
        stack,
        context: 'unhandled_async_error',
        severity: 'critical',
      );
      return !kDebugMode; // Suppress raw platform error logging in production.
    };

    leaveBreadcrumb('Aplikasi dimulai (Telemetry aktif)', category: 'lifecycle');
  }

  /// Rekam jejak interaksi pengguna / sistem ke in-memory ring buffer
  void leaveBreadcrumb(String message, {String category = 'action'}) {
    try {
      final sanitized = sanitizeData(message);
      _breadcrumbs.add({
        'message': sanitized,
        'category': sanitizeData(category),
        'timestamp': DateTime.now().toIso8601String(),
      });
      if (_breadcrumbs.length > maxBreadcrumbs) {
        _breadcrumbs.removeAt(0);
      }
    } catch (_) {}
  }

  /// Free-text fallback. Structured values must use sanitizeValue so a key
  /// such as accessToken redacts its entire value, including nested objects.
  String sanitizeData(String input) {
    if (input.isEmpty) return input;
    var text = input.replaceAllMapped(
      RegExp(r"""(?:https?|wss?)://[^\s<>"']+""", caseSensitive: false),
      (match) {
        final uri = Uri.tryParse(match.group(0)!);
        return uri != null && uri.host.isNotEmpty
          ? '${uri.scheme}://${uri.host}/[REDACTED_URL]' : '[REDACTED_URL]';
      },
    );
    text = text.replaceAll(RegExp(r'[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}', caseSensitive: false), '[REDACTED_EMAIL]');
    text = text.replaceAll(RegExp(r'bearer\s+[^\s,;]+', caseSensitive: false), 'Bearer [REDACTED_TOKEN]');
    text = text.replaceAllMapped(
      RegExp(r"""(password|passwd|secret|api[_-]?key|access[_-]?token|refresh[_-]?token|id[_-]?token|token|authorization|cookie|session|voucher|code)["']?\s*[:=]\s*(?:"[^"]*"|'[^']*'|[^,\s\n}]+)""", caseSensitive: false),
      (match) => '${match.group(1)}: [REDACTED]',
    );
    text = text.replaceAllMapped(
      RegExp(r'(SID|HSID|SSID|APISID|SAPISID)=[^;\s]+', caseSensitive: false),
      (match) => '${match.group(1)}=[REDACTED_COOKIE]',
    );
    text = text.replaceAll(RegExp(r'[^\s<>]+\?[^\s<>]+'), '[REDACTED_URL]');
    return text.length > 2000 ? '${text.substring(0, 2000)}…' : text;
  }

  bool _sensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return RegExp(r'password|passwd|secret|apikey|token|authorization|cookie|session|voucher|redeem|email|phone|credential|privatekey|prompt|question|answer|excerpt|clipboard|note|body|content|html|error|exception|stacktrace|summary').hasMatch(normalized) ||
      normalized == 'auth' || normalized == 'code' || normalized == 'query' || normalized == 'uid' || normalized == 'userid';
  }

  dynamic sanitizeValue(dynamic value, {String? key, int depth = 0}) {
    if (key != null && _sensitiveKey(key)) return '[REDACTED]';
    if (depth >= 8) return '[TRUNCATED]';
    if (value == null || value is bool || value is num) return value;
    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries.take(100))
          sanitizeData(entry.key.toString()): sanitizeValue(entry.value, key: entry.key.toString(), depth: depth + 1),
      };
    }
    if (value is Iterable) return value.take(100).map((item) => sanitizeValue(item, depth: depth + 1)).toList();
    if (value is String) return sanitizeData(value);
    return '[${value.runtimeType}]';
  }

  /// Preserve the public helper without retaining the address or its domain.
  String maskEmail(String email) => email.contains('@') ? '[REDACTED_EMAIL]' : '';

  /// Buat signature unik untuk deduplikasi error
  String _computeErrorSignature(String errorStr, String? context, String? stackTraceStr) {
    final firstThreeLines = (stackTraceStr ?? '')
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .take(3)
        .join('|');
    final raw = '${errorStr.trim()}::$context::$firstThreeLines';
    return md5.convert(utf8.encode(raw)).toString();
  }

  /// Kirim error ke Firestore secara senyap (unawaited)
  Future<void> reportError(
    dynamic error,
    dynamic stackTrace, {
    String? context,
    String severity = 'error',
    Map<String, dynamic>? extra,
  }) async {
    try {
      final errorStr = kDebugMode ? sanitizeData(error?.toString() ?? 'Unknown Error')
        : (error == null ? 'UnknownError' : error.runtimeType.toString());
      final stackStr = kDebugMode ? sanitizeData(stackTrace?.toString() ?? '') : '';
      final safeContext = sanitizeData(context ?? 'general');

      // Cek deduplikasi
      final signature = _computeErrorSignature(errorStr, safeContext, stackStr);
      final now = DateTime.now();
      final lastReported = _reportedSignatures[signature];
      if (lastReported != null && now.difference(lastReported) < _dedupWindow) {
        return; // Lewati karena baru saja dilaporkan dalam kurun dedupWindow
      }
      _reportedSignatures[signature] = now;

      // Bersihkan signature lama yang sudah lewat window
      _reportedSignatures.removeWhere((_, time) => now.difference(time) > _dedupWindow);

      final sanitizedExtra = sanitizeValue(extra ?? const <String, dynamic>{});

      final payload = {
        'error': errorStr.length > 2000 ? errorStr.substring(0, 2000) : errorStr,
        'context': safeContext,
        'severity': sanitizeData(severity),
        'stackTrace': stackStr.length > 5000 ? stackStr.substring(0, 5000) : stackStr,
        'breadcrumbs': List<Map<String, dynamic>>.from(_breadcrumbs),
        'extra': sanitizedExtra,
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        'deviceTimestamp': now.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Tulis secara senyap ke Firestore koleksi client_error_logs
      unawaited(
        _db.collection('client_error_logs').add(payload).catchError((_) {
          return null as dynamic;
        }),
      );
    } catch (_) {
      // Menjamin TelemetryService tidak pernah melempar exception ke aplikasi
    }
  }
}


