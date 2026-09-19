import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/language_notifier.dart';

class AppConfig {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
  static ValueListenable<String> get localeNotifier => LocaleService.instance.languageCodeListenable;

  static const String _themeKey = 'app_theme_mode';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme (Default: ThemeMode.system)
    final themeStr = prefs.getString(_themeKey);
    if (themeStr == 'light') {
      themeNotifier.value = ThemeMode.light;
    } else if (themeStr == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.system;
    }

    await LocaleService.instance.initialize();
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
    final language = AppLanguage.values.where((v) => v.name == langCode).firstOrNull;
    if (language != null) await LocaleService.instance.update(language: language);
  }
}
