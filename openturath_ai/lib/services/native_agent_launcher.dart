import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/notebook_navigation.dart';

/// User-initiated launch of an exact trusted HTTPS notebook destination.
class NativeAgentLauncher {
  static const MethodChannel _channel = MethodChannel('com.openturath.ai/native_launcher');
  static bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<bool> isNotebookAppInstalled() async {
    if (!_isAndroid) return false;
    try { return await _channel.invokeMethod<bool>('isNotebookAppInstalled') == true; }
    catch (_) { return false; }
  }

  static Future<bool> launchNotebook(String url) async {
    final uri = Uri.tryParse(url);
    if (kIsWeb || uri == null || !NotebookNavigation.notebook(uri)) return false;
    if (_isAndroid) {
      try {
        if (await _channel.invokeMethod<bool>('openInNotebookApp', {'url': uri.toString()}) == true) return true;
      } catch (_) {}
    }
    try {
      return await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (_) { return false; }
  }

  static Future<bool> shareText({required String text, String title = 'Bagikan Modul'}) async {
    if (!_isAndroid || text.trim().isEmpty) return false;
    try {
      return await _channel.invokeMethod<bool>('shareText', {'text': text, 'title': title}) == true;
    } catch (_) { return false; }
  }
}
