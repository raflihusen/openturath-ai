/// Decorative labels never replace scholarly titles or stable agent identifiers.
abstract final class ArabicUiLabels {
  static String forAgent(String id, String fallback) =>
      const {
        'fiqh_syafii': 'الشافعي',
        'fiqh_hanafi': 'الحنفي',
        'fiqh_maliki': 'المالكي',
        'fiqh_hanbali': 'الحنبلي',
        'fiqh_muqaran': 'الفقه المقارن',
        'hadits': 'الحديث',
        'hadith': 'الحديث',
        'tafsir': 'التفسير',
        'aqidah': 'العقيدة',
        'nahwu_sharaf': 'علوم العربية',
        'ushul_fiqh': 'أصول الفقه',
        'tarikh': 'التاريخ',
        'tasawwuf': 'التصوف',
        'musthalah_hadits': 'مصطلح الحديث',
        'syarah_hadits': 'شروح الحديث',
        'thabaqat_rijal': 'الرجال',
        'tajwid_qiraat': 'القراءات',
        'bibliografi_faharis': 'الفهارس',
      }[id] ??
      fallback;
  static String forField(String id, String fallback) =>
      const {
        'fiqh': 'الفقه',
        'hadits': 'الحديث',
        'hadith': 'الحديث',
        'tafsir': 'التفسير',
        'aqidah': 'العقيدة',
        'lughah': 'علوم العربية',
        'tarikh': 'التاريخ',
        'tasawwuf': 'التصوف',
        'bibliografi': 'الفهارس',
        'arabic': 'علوم العربية',
        'arabic_language': 'علوم العربية',
        'usul': 'أصول الفقه',
        'ushul_fiqh': 'أصول الفقه',
      }[id] ??
      fallback;
}
