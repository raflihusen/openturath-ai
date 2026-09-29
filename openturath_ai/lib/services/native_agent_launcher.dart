import 'dart:io';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// NativeAgentLauncher: Menangani pembukaan asisten langsung ke aplikasi resmi
/// Google Gemini Notebook (com.google.android.apps.labs.language.tailwind) secara instan (0.1 detik)
/// atau ke browser sistem dengan jaminan akun Google yang sesuai (AccountChooser + authuser).
class NativeAgentLauncher {
  static const MethodChannel _channel =
      MethodChannel('com.openturath.ai/native_launcher');
  static const String _prefNotebookEmailKey = 'notebook_google_email';

  /// Mengambil email Google yang aktif digunakan untuk membuka asisten NotebookLM.
  /// Memprioritaskan email kustom jika disetel oleh pengguna, atau akun masuk OpenTurath AI saat ini.
  static Future<String> getActiveNotebookEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = prefs.getString(_prefNotebookEmailKey)?.trim().toLowerCase();
      if (custom != null && custom.isNotEmpty) {
        return custom;
      }
    } catch (_) {}
    return AuthService().currentUser?.email?.trim().toLowerCase() ?? '';
  }

  /// Menyimpan email Google preferensi untuk peluncuran asisten
  static Future<void> setActiveNotebookEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clean = email.trim().toLowerCase();
      if (clean.isEmpty) {
        await prefs.remove(_prefNotebookEmailKey);
      } else {
        await prefs.setString(_prefNotebookEmailKey, clean);
      }
    } catch (_) {}
  }

  /// Memformat URL NotebookLM dengan integrasi Google AccountChooser dan authuser.
  /// Mencegah browser salah masuk ke akun default (/u/0/) jika user memiliki banyak akun Google.
  static String formatAccountBoundUrl(String url, {String? email}) {
    final cleanUrl = url.replaceAll('/preview', '');
    final uri = Uri.tryParse(cleanUrl);
    if (uri == null) return cleanUrl;

    final targetEmail = email?.trim().toLowerCase();
    if (targetEmail == null || targetEmail.isEmpty) {
      return cleanUrl;
    }

    final queryParams = Map<String, String>.from(uri.queryParameters);
    queryParams['authuser'] = targetEmail;
    final notebookWithAuthuser =
        uri.replace(queryParameters: queryParams).toString();

    return 'https://accounts.google.com/AccountChooser?Email=${Uri.encodeComponent(targetEmail)}&continue=${Uri.encodeComponent(notebookWithAuthuser)}';
  }

  /// Cek apakah aplikasi resmi Google Gemini Notebook terpasang di perangkat
  static Future<bool> isNotebookAppInstalled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? installed =
          await _channel.invokeMethod<bool>('isNotebookAppInstalled');
      return installed == true;
    } catch (_) {
      return false;
    }
  }

  /// Buka URL notebook dengan pengikatan akun Google yang tepat
  /// Mengembalikan `true` jika berhasil diluncurkan.
  static Future<bool> launchNotebook(String url, {String? email}) async {
    final cleanUrl = url.replaceAll('/preview', '');
    final uri = Uri.tryParse(cleanUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        !const {'notebooklm.google.com', 'notebook.google.com'}
            .contains(uri.host)) {
      return false;
    }

    final effectiveEmail = (email != null && email.isNotEmpty)
        ? email
        : await getActiveNotebookEmail();

    // 1. Prioritaskan peluncuran Intent langsung ke com.google.android.apps.labs.language.tailwind di Android
    if (Platform.isAndroid) {
      try {
        final bool? success =
            await _channel.invokeMethod<bool>('openInNotebookApp', {
          'url': cleanUrl,
        });
        if (success == true) {
          return true;
        }
      } catch (_) {}
    }

    // 2. Format URL terikat akun Google spesifik via AccountChooser
    final targetLaunchUrl =
        formatAccountBoundUrl(cleanUrl, email: effectiveEmail);
    final targetUri = Uri.tryParse(targetLaunchUrl) ?? uri;

    // 3. Peluncuran ke browser eksternal
    try {
      final bool launched = await launchUrl(
        targetUri,
        mode: Platform.isAndroid
            ? LaunchMode.externalNonBrowserApplication
            : LaunchMode.externalApplication,
      );
      if (launched) return true;
      if (Platform.isAndroid) {
        return await launchUrl(targetUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    return false;
  }

  /// Membuka Share Sheet native Android untuk membagikan modul AI
  static Future<bool> shareText(
      {required String text, String title = 'Bagikan Modul'}) async {
    if (!Platform.isAndroid) {
      try {
        await Clipboard.setData(ClipboardData(text: text));
        return true;
      } catch (_) {
        return false;
      }
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
