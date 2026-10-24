import 'package:flutter/widgets.dart';
import 'app_config.dart';
import 'copy_catalog.dart';

class LocaleScope extends InheritedNotifier<ValueNotifier<String>> {
  LocaleScope({super.key, required super.child})
      : super(notifier: AppConfig.localeNotifier);
}

abstract final class Loc {
  static const supportedCodes = ['id', 'en', 'ar'];
  static const supportedLocales = [Locale('id'), Locale('en'), Locale('ar')];
  static const languageNames = {
    'id': 'Bahasa Indonesia',
    'en': 'English',
    'ar': 'العربية'
  };
  static String get language =>
      supportedCodes.contains(AppConfig.localeNotifier.value)
          ? AppConfig.localeNotifier.value
          : 'id';
  static bool get isArabic => language == 'ar';
  static void watch(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<LocaleScope>();
  }

  static final Map<String, String> _sourceKeys = {
    for (final entry in copyCatalog.entries)
      for (final value in entry.value) value: entry.key,
  };
  static const _aliases = {
    'app_name': 'appName',
    'available_now': 'readyToUse',
    'coming_soon': 'comingSoon',
    'manage_subscription': 'manageSubscription',
    'settings': 'navSettings',
    'logout': 'logoutButton',
    'welcome': 'ahlanDefault',
    'subtitle_dash': 'defaultFieldDesc',
    'active_sub': 'activeSubscription',
    'valid_until': 'validUntil',
    'full_access': 'fullAccess',
    'unlimited_research': 'academicSlogan',
    'explore_corpus': 'chooseField',
    'theme_mode': 'appearance',
    'theme_system': 'modeSystem',
    'theme_light': 'modeLight',
    'theme_dark': 'modeDark',
    'choose_plan': 'choosePlan',
  };

  /// Mengurung teks kiri-ke-kanan (angka, kode, nama merek) agar urutannya
  /// tidak teracak di tengah kalimat Arab.
  static String ltr(String value) => '\u2066$value\u2069';

  /// "4.800+" atau "4,1 juta+"; dalam bahasa Arab tanda tambah di depan.
  static String atLeast(String number, [String unit = '']) {
    final tail = unit.isEmpty ? '' : ' $unit';
    return language == 'ar' ? '${ltr('+$number')}$tail' : '$number$tail+';
  }

  static String tr(String key, [List<String>? args]) {
    final values = copyCatalog[_aliases[key] ?? key];
    assert(values != null, 'Missing translation: $key');
    var text = values?[supportedCodes.indexOf(language)] ?? key;
    if (args != null) {
      for (var i = 0; i < args.length; i++) {
        text = text.replaceAll('{$i}', args[i]);
      }
    }
    return text;
  }

  /// Seperti [tr], tetapi selalu Arab (katalog kitab selalu Arab dan RTL).
  static String trAr(String key, [List<String>? args]) {
    final values = copyCatalog[_aliases[key] ?? key];
    var text = (values != null && values.length > 2) ? values[2] : key;
    if (args != null) {
      for (var i = 0; i < args.length; i++) {
        text = text.replaceAll('{$i}', args[i]);
      }
    }
    return text;
  }

  /// Seperti [text], tetapi selalu Arab.
  static String textAr(String source) {
    final key = _sourceKeys[source];
    return key == null ? source : trAr(key);
  }

  /// Terjemahkan label katalog statis. Naskah sumber dan nama kitab dipertahankan.
  static String text(String source) {
    final key = _sourceKeys[source];
    return key == null ? source : tr(key);
  }

  static String cleanTitle(String title) => title
      .replaceFirst(RegExp(r'^(?:Super\s+)?AI\s+', caseSensitive: false), '')
      .trim();
}
