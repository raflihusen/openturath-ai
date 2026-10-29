import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';

/// Penanda "bahasa sudah dipilih sadar oleh pengguna". Pilihan bahasa tampil
/// sekali di pemasangan baru, sebelum pengenalan dan sebelum masuk akun.
class LanguageGate {
  const LanguageGate._();

  static const _key = 'language_chosen_v1';
  static const _localeKey = 'app_locale';

  /// Sudah dipilih bila penandanya ada, atau bila pengguna lama sudah pernah
  /// menyimpan bahasa lewat pengalih bahasa (mereka tidak ditanya lagi).
  static Future<bool> chosen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getBool(_key) ?? false) || prefs.containsKey(_localeKey);
    } catch (_) {
      // Bila penyimpanan gagal dibaca, jangan menahan pengguna di pilihan bahasa.
      return true;
    }
  }

  static Future<void> markChosen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {}
  }

  /// Usulan awal dari bahasa perangkat: Arab, Indonesia, selain itu Inggris.
  static String suggest([ui.Locale? device]) {
    final code = (device ?? ui.PlatformDispatcher.instance.locale).languageCode;
    return switch (code) {
      'ar' => 'ar',
      'id' || 'in' => 'id',
      _ => 'en',
    };
  }
}
