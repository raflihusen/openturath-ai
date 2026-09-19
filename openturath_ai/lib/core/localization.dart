import 'app_config.dart';
import 'l10n/app_dictionary.dart';

/// Legacy adapter. New widgets subscribe through context.tr / Localizations.
abstract final class Loc {
  static const _aliases = <String, String>{
    'app_name': 'OpenTurath', 'available_now': 'Tersedia',
    'coming_soon': 'Belum tersedia', 'manage_subscription': 'Kelola akses',
    'settings': 'shell.settings', 'logout': 'Keluar', 'welcome': 'shell.welcome',
    'subtitle_dash': 'Pilih bidang', 'active_sub': 'Akses aktif',
    'valid_until': 'Aktif hingga', 'full_access': 'Akses semua bidang yang tersedia',
    'unlimited_research': 'Telusuri ibarah dari kitab rujukan',
    'explore_corpus': 'Pilih bidang', 'theme_mode': 'Tampilan',
    'theme_system': 'Ikuti sistem', 'theme_light': 'Terang', 'theme_dark': 'Gelap',
    'language': 'locale.title', 'save': 'Simpan', 'cancel': 'shell.cancel',
    'choose_plan': 'Pilih akses',
  };
  static String tr(String key, [List<String>? args]) => AppDictionary.translate(
    _aliases[key] ?? key, AppConfig.localeNotifier.value,
    args: {for (var i = 0; i < (args?.length ?? 0); i++) '$i': args![i]});
}
