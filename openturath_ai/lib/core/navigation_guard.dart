import 'package:flutter/material.dart';

/// [NavigationGuard] mencegah masalah navigasi bertumpuk (*stacked pages*)
/// yang timbul ketika pengguna mengetuk tombol navigasi secara berulang-ulang
/// dalam jeda waktu singkat saat perangkat sedang sibuk atau mengalami lag.
class NavigationGuard {
  NavigationGuard._();

  static bool _isNavigating = false;
  static String? _activeRoute;

  /// Mengetahui apakah saat ini ada operasi navigasi yang sedang berlangsung (*in-flight*).
  static bool get isNavigating => _isNavigating;

  /// Rute yang saat ini sedang aktif dibuka.
  static String? get activeRoute => _activeRoute;

  /// Mengeksekusi [Navigator.pushNamed] dengan perlindungan *Single-Flight Guard*.
  ///
  /// Jika ada navigasi lain yang sedang berjalan atau rute yang sama sedang
  /// dalam proses dibuka, pemanggilan berikutnya akan langsung diabaikan secara aman.
  static Future<T?> safePushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (_isNavigating) {
      debugPrint('[NavigationGuard] Menolak push duplikat untuk "$routeName" (operasi navigasi sedang aktif)');
      return null;
    }

    _isNavigating = true;
    _activeRoute = routeName;

    try {
      if (!context.mounted) return null;
      return await Navigator.pushNamed<T>(
        context,
        routeName,
        arguments: arguments,
      );
    } finally {
      _isNavigating = false;
      _activeRoute = null;
    }
  }

  /// Mengeksekusi navigasi kustom dengan pengunci *Single-Flight Guard*.
  static Future<T?> safeNavigate<T>(
    BuildContext context,
    Future<T?> Function() navigationAction,
  ) async {
    if (_isNavigating) {
      debugPrint('[NavigationGuard] Menolak navigasi duplikat (operasi navigasi sedang aktif)');
      return null;
    }

    _isNavigating = true;
    try {
      if (!context.mounted) return null;
      return await navigationAction();
    } finally {
      _isNavigating = false;
      _activeRoute = null;
    }
  }

  /// Reset internal state untuk keperluan unit test.
  @visibleForTesting
  static void resetForTesting() {
    _isNavigating = false;
    _activeRoute = null;
  }
}
