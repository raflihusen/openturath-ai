import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppEngineVariant {
  classic,    // Versi 1: 100% Fidelity Liquid Glass / Tahoe UI
  openTurath, // Versi 2: 100% OpenTurath Quiet Scholar Edition
}

class AppPreferencesState {
  final AppEngineVariant engineVariant;
  final String languageCode; // 'id', 'ar', 'en'
  final ThemeMode themeMode; // system, light, dark

  const AppPreferencesState({
    required this.engineVariant,
    required this.languageCode,
    required this.themeMode,
  });

  AppPreferencesState copyWith({
    AppEngineVariant? engineVariant,
    String? languageCode,
    ThemeMode? themeMode,
  }) {
    return AppPreferencesState(
      engineVariant: engineVariant ?? this.engineVariant,
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

const String defaultEngineEnv = String.fromEnvironment('DEFAULT_ENGINE', defaultValue: 'openturath');

class AppPreferencesNotifier extends StateNotifier<AppPreferencesState> {
  static const _kEngineKey = 'app_engine_variant';
  static const _kLangKey = 'app_language_code';
  static const _kThemeKey = 'app_theme_mode';

  AppPreferencesNotifier()
      : super(AppPreferencesState(
          engineVariant: defaultEngineEnv == 'classic'
              ? AppEngineVariant.classic
              : AppEngineVariant.openTurath,
          languageCode: 'id',
          themeMode: ThemeMode.system,
        )) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final engineStr = prefs.getString(_kEngineKey);
    final langStr = prefs.getString(_kLangKey);
    final themeStr = prefs.getString(_kThemeKey);

    var engine = defaultEngineEnv == 'classic'
        ? AppEngineVariant.classic
        : AppEngineVariant.openTurath;
    if (engineStr == 'classic') engine = AppEngineVariant.classic;
    if (engineStr == 'openturath') engine = AppEngineVariant.openTurath;

    var lang = langStr ?? 'id';
    var theme = ThemeMode.system;
    if (themeStr == 'light') theme = ThemeMode.light;
    if (themeStr == 'dark') theme = ThemeMode.dark;

    state = AppPreferencesState(
      engineVariant: engine,
      languageCode: lang,
      themeMode: theme,
    );
  }

  Future<void> setEngineVariant(AppEngineVariant variant) async {
    state = state.copyWith(engineVariant: variant);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEngineKey, variant == AppEngineVariant.classic ? 'classic' : 'openturath');
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    await prefs.setString(_kThemeKey, modeStr);
  }

  Future<void> toggleEngine() async {
    final next = state.engineVariant == AppEngineVariant.classic
        ? AppEngineVariant.openTurath
        : AppEngineVariant.classic;
    await setEngineVariant(next);
  }
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferencesState>((ref) {
  return AppPreferencesNotifier();
});
