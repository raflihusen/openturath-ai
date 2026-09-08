import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
  static final ValueNotifier<String> localeNotifier = ValueNotifier('id'); // 'id', 'en', 'ar'

  static const String _themeKey = 'app_theme_mode';
  static const String _localeKey = 'app_locale';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme (Default: Dark Mode sesuai desain master Figma)
    final themeStr = prefs.getString(_themeKey);
    if (themeStr == 'light') {
      themeNotifier.value = ThemeMode.light;
    } else if (themeStr == 'system') {
      themeNotifier.value = ThemeMode.system;
    } else {
      themeNotifier.value = ThemeMode.dark;
    }

    // Load Locale
    final localeStr = prefs.getString(_localeKey);
    if (localeStr != null) {
      localeNotifier.value = localeStr;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_themeKey, 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(_themeKey, 'dark');
    } else {
      await prefs.setString(_themeKey, 'system');
    }
  }

  static Future<void> setLocale(String langCode) async {
    localeNotifier.value = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, langCode);
  }
}
