import 'app_config.dart';

class Loc {
  static const Map<String, Map<String, String>> _dict = {
    'id': {
      'app_name': 'OpenTurath AI',
      'available_now': 'Tersedia',
      'coming_soon': 'Belum tersedia',
      'manage_subscription': 'Langganan',
      'settings': 'Profil',
      'logout': 'Keluar',
      'welcome': 'أهلاً',
      'subtitle_dash': 'Pilih ruang riset.',
      'active_sub': 'Akses aktif',
      'valid_until': 'Aktif hingga',
      'full_access': 'Akses semua ruang riset yang tersedia',
      'unlimited_research': 'Riset kitab turats',
      'explore_corpus': 'Pilih ruang riset.',
      'theme_mode': 'Tampilan Tema',
      'theme_system': 'Sistem Default',
      'theme_light': 'Terang',
      'theme_dark': 'Gelap',
      'language': 'Bahasa',
      'save': 'Simpan',
      'cancel': 'Batal',
      'choose_plan': 'Pilih paket',
    },
    'en': {
      'app_name': 'OpenTurath AI',
      'available_now': 'Available',
      'coming_soon': 'Unavailable',
      'manage_subscription': 'Subscription',
      'settings': 'Profile',
      'logout': 'Sign Out',
      'welcome': 'Welcome',
      'subtitle_dash': 'Select a research space.',
      'active_sub': 'Active Access',
      'valid_until': 'Active until',
      'full_access': 'Access to all available research spaces',
      'unlimited_research': 'Turats manuscript research',
      'explore_corpus': 'Select a research space.',
      'theme_mode': 'Theme Mode',
      'theme_system': 'System Default',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'language': 'Language',
      'save': 'Save',
      'cancel': 'Cancel',
      'choose_plan': 'Choose Plan',
    },
    'ar': {
      'app_name': 'أوبن تراث الذكاء الاصطناعي',
      'available_now': 'متاح الآن',
      'coming_soon': 'قريباً',
      'manage_subscription': 'إدارة الاشتراك',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'welcome': 'أهلاً',
      'subtitle_dash': 'اختر مجال العلم الذي ترغب في البحث فيه.',
      'active_sub': 'الاشتراك نشط',
      'valid_until': 'صالح حتى',
      'full_access': 'وصول كامل للمصادر',
      'unlimited_research': 'بحث غير محدود في التراث',
      'explore_corpus': 'استكشف كتب التراث الإسلامي مع العبارات الأصلية.',
      'theme_mode': 'مظهر التطبيق',
      'theme_system': 'تلقائي',
      'theme_light': 'فاتح',
      'theme_dark': 'داكن',
      'language': 'اللغة',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'choose_plan': 'اختر هذه الباقة',
    }
  };

  static String tr(String key, [List<String>? args]) {
    final lang = AppConfig.localeNotifier.value;
    String text = _dict[lang]?[key] ?? _dict['en']?[key] ?? key;
    
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        text = text.replaceAll('{$i}', args[i]);
      }
    }
    return text;
  }
}
