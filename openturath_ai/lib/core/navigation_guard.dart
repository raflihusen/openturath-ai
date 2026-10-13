import 'dart:async';
import 'package:flutter/material.dart';

/// [NavigationGuard] mencegah masalah navigasi bertumpuk (*stacked pages*)
/// yang timbul ketika pengguna mengetuk tombol navigasi secara berulang-ulang
/// dalam jeda waktu singkat saat perangkat sedang sibuk atau mengalami lag.
///
/// Mekanisme penguncian bekerja secara *per-route in-flight window* (450ms),
/// sehingga double tap pada rute yang sama ditolak, namun navigasi anak (child routes)
/// dari dalam halaman yang sedang aktif tetap dapat dibuka secara normal.
class NavigationGuard {
  NavigationGuard._();

  static final Set<String> _inFlightRoutes = <String>{};
  static bool _isCustomNavigating = false;

  /// Mengeksekusi [Navigator.pushNamed] dengan perlindungan *Single-Flight Guard* per-route.
  ///
  /// Kunci dilepaskan otomatis setelah jendela animasi/transisi 450 milidetik selesai,
  /// sehingga rute tidak terkunci selamanya saat halaman masih terbuka di layar.
  static Future<T?> safePushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (!context.mounted) return null;

    if (!_inFlightRoutes.add(routeName)) {
      debugPrint('[NavigationGuard] Menolak push duplikat untuk "$routeName" (rute sedang in-flight)');
      return null;
    }

    // Jadwalkan pelepasan kunci rute setelah jendela debounce 450ms
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 450))
          .whenComplete(() => _inFlightRoutes.remove(routeName)),
    );

    try {
      return await Navigator.pushNamed<T>(
        context,
        routeName,
        arguments: arguments,
      );
    } catch (_) {
      _inFlightRoutes.remove(routeName);
      rethrow;
    }
  }

  /// Mengeksekusi navigasi kustom dengan pengunci *Single-Flight Guard*.
  static Future<T?> safeNavigate<T>(
    BuildContext context,
    Future<T?> Function() navigationAction,
  ) async {
    if (_isCustomNavigating) {
      debugPrint('[NavigationGuard] Menolak navigasi duplikat (operasi navigasi sedang aktif)');
      return null;
    }

    _isCustomNavigating = true;
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 450))
          .whenComplete(() => _isCustomNavigating = false),
    );

    try {
      if (!context.mounted) return null;
      return await navigationAction();
    } catch (_) {
      _isCustomNavigating = false;
      rethrow;
    }
  }

  /// Reset internal state untuk keperluan unit test.
  @visibleForTesting
  static void resetForTesting() {
    _inFlightRoutes.clear();
    _isCustomNavigating = false;
  }
}
