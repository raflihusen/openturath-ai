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
  TelemetryService._({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore,
        _auth = auth;

  static final TelemetryService instance = TelemetryService._();

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  /// Visible for testing to inject mock instances
  @visibleForTesting
  void setMockInstances({FirebaseFirestore? firestore, FirebaseAuth? auth}) {
    _firestore = firestore;
    _auth = auth;
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
          'summary': details.summary.toString(),
        },
      );
      if (originalOnError != null) {
        originalOnError(details);
      } else {
        FlutterError.presentError(details);
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
      return false; // biarkan default handling berjalan
    };

    leaveBreadcrumb('Aplikasi dimulai (Telemetry aktif)', category: 'lifecycle');
  }

  /// Rekam jejak interaksi pengguna / sistem ke in-memory ring buffer
  void leaveBreadcrumb(String message, {String category = 'action'}) {
    try {
      final sanitized = sanitizeData(message);
      _breadcrumbs.add({
        'message': sanitized,
        'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      });
      if (_breadcrumbs.length > maxBreadcrumbs) {
        _breadcrumbs.removeAt(0);
      }
    } catch (_) {}
  }

  /// Masking data sensitif (password, authorization token, voucher, email)
  String sanitizeData(String input) {
    if (input.isEmpty) return input;
    var sanitized = input;

    // 1. Mask Bearer / Token
    sanitized = sanitized.replaceAll(
      RegExp(r'bearer\s+[a-zA-Z0-9_\-\.]+', caseSensitive: false),
      'Bearer [REDACTED_TOKEN]',
    );

    // 2. Mask password / apikey / secret / auth
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'''(password|secret|apiKey|api_key|token|access_token|refreshToken)["':\s=]+[^,\s\n}]+''', caseSensitive: false),
      (match) => '${match.group(1)}: "[REDACTED]"',
    );

    // 3. Mask Google SID/HSID/SSID cookies
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(SID|HSID|SSID|APISID|SAPISID)=[^;\s]+', caseSensitive: false),
      (match) => '${match.group(1)}=[REDACTED_COOKIE]',
    );

    // 4. Mask voucher codes bila ada
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'''(voucher|code)["':\s=]+[a-zA-Z0-9\-_]{5,20}''', caseSensitive: false),
      (match) => '${match.group(1)}: "[REDACTED_CODE]"',
    );

    sanitized = sanitized.replaceAll(
      RegExp(r'[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'),
      '[REDACTED_EMAIL]',
    );
    return sanitized;
  }

  /// Mask email pengguna untuk kepatuhan privasi (cth: a***@domain.com)
  String maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return '';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) {
      return '*@$domain';
    }
    return '${name[0]}***${name[name.length - 1]}@$domain';
  }

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
      final errorStr = sanitizeData(error?.toString() ?? 'Unknown Error');
      final stackStr = sanitizeData(stackTrace?.toString() ?? '');

      // Cek deduplikasi
      final signature = _computeErrorSignature(errorStr, context, stackStr);
      final now = DateTime.now();
      final lastReported = _reportedSignatures[signature];
      if (lastReported != null && now.difference(lastReported) < _dedupWindow) {
        return; // Lewati karena baru saja dilaporkan dalam kurun dedupWindow
      }
      _reportedSignatures[signature] = now;

      // Bersihkan signature lama yang sudah lewat window
      _reportedSignatures.removeWhere((_, time) => now.difference(time) > _dedupWindow);

      final user = _firebaseAuth.currentUser;
      // Remote reporting requires an authenticated owner; pre-login errors stay local.
      if (user == null) return;
      final maskedUserEmail = user?.email != null ? maskEmail(user!.email!) : '';

      final sanitizedExtra = <String, dynamic>{};
      if (extra != null) {
        for (final entry in extra.entries) {
          sanitizedExtra[entry.key] = sanitizeData(entry.value?.toString() ?? '');
        }
      }

      final payload = {
        'error': errorStr.length > 2000 ? errorStr.substring(0, 2000) : errorStr,
        'context': sanitizeData(context ?? 'general').substring(0,
            sanitizeData(context ?? 'general').length.clamp(0, 300)),
        'severity': severity,
        'stackTrace': stackStr.length > 5000 ? stackStr.substring(0, 5000) : stackStr,
        'breadcrumbs': List<Map<String, dynamic>>.from(_breadcrumbs),
        'extra': sanitizedExtra,
        'userId': user?.uid ?? 'unauthenticated',
        'userEmail': maskedUserEmail,
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
