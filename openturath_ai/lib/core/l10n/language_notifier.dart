import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { id, en, ar }

@immutable
class AppLocale {
  const AppLocale({this.language = AppLanguage.id, this.easternArabicDigits = false});
  final AppLanguage language;
  final bool easternArabicDigits;
  String get languageCode => language.name;
  bool get isArabic => language == AppLanguage.ar;
  AppLocale copyWith({AppLanguage? language, bool? easternArabicDigits}) => AppLocale(
    language: language ?? this.language,
    easternArabicDigits: easternArabicDigits ?? this.easternArabicDigits);
}

/// Sole owner of locale preference. Riverpod and legacy readers observe it.
/// Writes are serialized; a delayed startup read cannot undo a user choice.
class LocaleService {
  LocaleService._();
  @visibleForTesting
  LocaleService.forTesting();
  static final instance = LocaleService._();
  static const languageKey = 'ot_preferred_language';
  static const digitsKey = 'ot_eastern_arabic_digits';
  final _state = ValueNotifier(const AppLocale());
  final _legacyCode = ValueNotifier('id');
  ValueListenable<AppLocale> get listenable => _state;
  ValueListenable<String> get languageCodeListenable => _legacyCode;
  AppLocale get current => _state.value;
  Future<void>? _initialization;
  Future<void> _writes = Future.value();
  int _revision = 0;

  Future<void> initialize() {
    if (_initialization != null) return _initialization!;
    return _initialization = _load().catchError((Object error, StackTrace stack) {
      _initialization = null; // allow a genuine storage failure to be retried
      Error.throwWithStackTrace(error, stack);
    });
  }
  Future<void> _load() async {
    final revision = _revision;
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(languageKey) ?? prefs.getString('app_locale');
    final language = AppLanguage.values.where((v) => v.name == code).firstOrNull ?? AppLanguage.id;
    if (revision == _revision) _publish(AppLocale(language: language,
      easternArabicDigits: prefs.getBool(digitsKey) ?? false));
  }
  void _publish(AppLocale value) {
    _legacyCode.value = value.languageCode;
    _state.value = value;
  }
  Future<bool> update({AppLanguage? language, bool? easternArabicDigits}) {
    ++_revision;
    final next = current.copyWith(language: language, easternArabicDigits: easternArabicDigits);
    _publish(next); // hot switch before disk I/O
    final write = _writes.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final languageSaved = await prefs.setString(languageKey, next.languageCode);
      final digitsSaved = await prefs.setBool(digitsKey, next.easternArabicDigits);
      return languageSaved && digitsSaved;
    }).catchError((Object _) => false);
    _writes = write.then<void>((_) {});
    return write;
  }
}

class LanguageNotifier extends StateNotifier<AppLocale> {
  LanguageNotifier(this.service) : super(service.current) {
    service.listenable.addListener(_changed);
  }
  final LocaleService service;
  void _changed() => state = service.current;
  Future<bool> setLanguage(AppLanguage value) => service.update(language: value);
  Future<bool> setEasternArabicDigits(bool value) => service.update(easternArabicDigits: value);
  @override
  void dispose() { service.listenable.removeListener(_changed); super.dispose(); }
}
final languageProvider = StateNotifierProvider<LanguageNotifier, AppLocale>((ref) =>
  LanguageNotifier(LocaleService.instance));

String formatUiNumber(Object number, {String? languageCode, bool? easternArabicDigits}) {
  final locale = LocaleService.instance.current;
  final useEastern = (languageCode ?? locale.languageCode) == 'ar' &&
    (easternArabicDigits ?? locale.easternArabicDigits);
  if (!useEastern) return number.toString();
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return number.toString().replaceAllMapped(RegExp('[0-9]'), (m) => digits[int.parse(m[0]!)]);
}

/// Propagates numeral changes as well as locale changes to const subtrees and
/// already-open routes without resetting the Navigator or reading position.
class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({super.key, required this.locale, required super.child});
  final AppLocale locale;
  static AppLocale? maybeOf(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<AppLocaleScope>()?.locale;
  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) =>
    locale.language != oldWidget.locale.language ||
    locale.easternArabicDigits != oldWidget.locale.easternArabicDigits;
}
