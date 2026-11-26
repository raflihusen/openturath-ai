import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DesktopWebViewRuntime {
  static WebViewEnvironment? environment;
  static String? problem;
  static Future<void>? _preparing;
  static Future<WebViewEnvironment>? _creatingEnv;

  static Future<void> prepare() =>
      _preparing ??= _prepare().whenComplete(() => _preparing = null);

  static Future<void> _prepare() async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.windows ||
        environment != null) {
      return;
    }
    problem = null;
    try {
      final version = await WebViewEnvironment.getAvailableVersion()
          .timeout(const Duration(seconds: 10));
      if (version == null || version.isEmpty) {
        problem =
            'Pasang Microsoft Edge WebView2 Runtime untuk membuka ruang percakapan di aplikasi.';
        return;
      }
      final support = await getApplicationSupportDirectory();
      final profile = Directory(p.join(support.path, 'webview2'));
      await profile.create(recursive: true);
      // Reuse pembuatan environment yang sedang berjalan agar retry timeout tidak
      // memicu dua WebViewEnvironment bersamaan pada userDataFolder yang sama.
      final envFuture = _creatingEnv ??= WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(userDataFolder: profile.path),
      );
      try {
        environment = await envFuture.timeout(const Duration(seconds: 15));
      } catch (e) {
        // Hanya reset cache future jika create() sendiri gagal (bukan sekadar timeout).
        envFuture.then((created) {
          environment ??= created;
        }, onError: (_) {
          if (identical(_creatingEnv, envFuture)) {
            _creatingEnv = null;
          }
        });
        rethrow;
      }
    } catch (_) {
      problem =
          'Ruang web belum dapat disiapkan. Periksa WebView2 dan izin penyimpanan aplikasi.';
    }
  }

  static bool get hasWindowsEnvironment =>
      kIsWeb ||
      defaultTargetPlatform != TargetPlatform.windows ||
      environment != null;

  static CookieManager get cookies =>
      CookieManager.instance(webViewEnvironment: environment);

  static Future<void> clearSession() async {
    // One unsupported method must not prevent the remaining cleanup operations.
    if (hasWindowsEnvironment) {
      try {
        await cookies.deleteAllCookies();
      } catch (_) {}
    }
    try {
      await InAppWebViewController.clearAllCache();
    } catch (_) {}
    try {
      await WebStorageManager.instance().deleteAllData();
    } catch (_) {}
  }
}
