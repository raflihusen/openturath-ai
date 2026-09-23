import 'dart:io';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// NativeAgentLauncher: Menangani pembukaan asisten langsung ke aplikasi resmi
/// Google Gemini Notebook (com.google.android.apps.labs.language.tailwind) secara instan (0.1 detik)
/// tanpa overhead browser atau webview jika aplikasi terinstal.
class NativeAgentLauncher {
  static const MethodChannel _channel = MethodChannel('com.openturath.ai/native_launcher');

  /// Cek apakah aplikasi resmi Google Gemini Notebook terpasang di perangkat
  static Future<bool> isNotebookAppInstalled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? installed = await _channel.invokeMethod<bool>('isNotebookAppInstalled');
      return installed == true;
    } catch (_) {
      return false;
    }
  }

  /// Buka URL notebook langsung di aplikasi resmi native Gemini Notebook
  /// Mengembalikan `true` jika berhasil diluncurkan langsung ke aplikasi native.
  static Future<bool> launchNotebook(String url) async {
    final cleanUrl = url.replaceAll('/preview', '');
    final uri = Uri.tryParse(cleanUrl);
    if (uri == null || uri.scheme != 'https' || uri.userInfo.isNotEmpty ||
        !const {'notebooklm.google.com', 'notebook.google.com'}.contains(uri.host)) {
      return false;
    }

    // 1. Prioritaskan peluncuran Intent langsung ke com.google.android.apps.labs.language.tailwind
    if (Platform.isAndroid) {
      try {
        final bool? success = await _channel.invokeMethod<bool>('openInNotebookApp', {
          'url': cleanUrl,
        });
        if (success == true) {
          return true;
        }
      } catch (_) {}
    }

    // 2. Coba peluncuran non-browser via url_launcher
    try {
      final bool launched = await launchUrl(
        uri,
        mode: Platform.isAndroid ? LaunchMode.externalNonBrowserApplication
            : LaunchMode.externalApplication,
      );
      if (launched) return true;
      if (Platform.isAndroid) return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}

    return false;
  }

  /// Membuka Share Sheet native Android untuk membagikan modul AI
  static Future<bool> shareText({required String text, String title = 'Bagikan Modul'}) async {
    if (!Platform.isAndroid) {
      try {
        await Clipboard.setData(ClipboardData(text: text));
        return true;
      } catch (_) { return false; }
    }
    try {
      final bool? success = await _channel.invokeMethod<bool>('shareText', {
        'text': text,
        'title': title,
      });
      return success == true;
    } catch (_) {
      return false;
    }
  }
}
