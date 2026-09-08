import 'app_config.dart';

class Loc {
  static const Map<String, Map<String, String>> _dict = {
    'id': {
      'app_name': 'OpenTurath AI',
      'available_now': 'Tersedia Sekarang',
      'coming_soon': 'Segera',
      'manage_subscription': 'Kelola Langganan',
      'settings': 'Pengaturan',
      'logout': 'Keluar',
      'welcome': 'أهلاً',
      'subtitle_dash': 'Pilih bidang ilmu yang ingin Anda teliti.',
      'active_sub': 'Langganan Aktif',
      'valid_until': 'Berlaku hingga',
      'full_access': 'Akses Penuh Seluruh Kitab',
      'unlimited_research': 'Riset Turats Tanpa Batas',
      'explore_corpus': 'Jelajahi seluruh korpus turats Islam dan ibarah asli.',
      'theme_mode': 'Tampilan Tema',
      'theme_system': 'Sistem Default',
      'theme_light': 'Terang',
      'theme_dark': 'Gelap',
      'language': 'Bahasa',
      'save': 'Simpan',
      'cancel': 'Batal',
      'choose_plan': 'Pilih Paket Ini',
    },
    'en': {
      'app_name': 'OpenTurath AI',
      'available_now': 'Available Now',
      'coming_soon': 'Coming Soon',
      'manage_subscription': 'Manage Subscription',
      'settings': 'Settings',
      'logout': 'Sign Out',
      'welcome': 'Welcome',
      'subtitle_dash': 'Select a field of study for your research.',
      'active_sub': 'Active Subscription',
      'valid_until': 'Valid until',
      'full_access': 'Full Corpus Access',
      'unlimited_research': 'Unlimited Turats Research',
      'explore_corpus': 'Explore original Islamic heritage and primary citations.',
      'theme_mode': 'Theme Mode',
      'theme_system': 'System Default',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'language': 'Language',
      'save': 'Save',
      'cancel': 'Cancel',
      'choose_plan': 'Choose This Plan',
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
