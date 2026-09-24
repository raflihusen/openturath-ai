import 'localization.dart';

/// Presentation labels for catalog taxonomy. Source metadata remains untouched.
abstract final class CatalogSectionLabel {
  static const _sections = <String, List<String>>{
    'كتب السنة': ['Kitab Hadis', 'Hadith collections', 'كتب السنة'],
    'الأدب والنثر': [
      'Sastra dan prosa',
      'Literature and prose',
      'الأدب والنثر'
    ],
    'التصوف': ['Tasawuf dan adab', 'Spirituality and ethics', 'التصوف والآداب'],
    'أصول الفقه': ['Usul Fikih', 'Legal theory', 'أصول الفقه'],
    'علوم اللغة العربية': [
      'Bahasa Arab',
      'Arabic language',
      'علوم اللغة العربية'
    ],
    'مسائل الفقهية': ['Masalah fikih', 'Legal questions', 'المسائل الفقهية'],
    'التاريخ': ['Sejarah Islam', 'Islamic history', 'التاريخ الإسلامي'],
    'العقيدة': ['Akidah', 'Theology', 'العقيدة'],
    'السيرة النبوية': [
      'Sirah Nabawiyah',
      'Prophetic biography',
      'السيرة النبوية'
    ],
    'التجويد': [
      'Tajwid dan qiraat',
      'Recitation and readings',
      'التجويد والقراءات'
    ],
    'التخريج': ['Takhrij Hadis', 'Hadith sourcing', 'تخريج الحديث'],
    'الفقه الحنب': ['Fikih Hanbali', 'Hanbali jurisprudence', 'الفقه الحنبلي'],
    'الفقه الشافعي': [
      "Fikih Syafi'i",
      "Shafi'i jurisprudence",
      'الفقه الشافعي'
    ],
    'الفقه الحنفي': ['Fikih Hanafi', 'Hanafi jurisprudence', 'الفقه الحنفي'],
    'الفقه المالكي': ['Fikih Maliki', 'Maliki jurisprudence', 'الفقه المالكي'],
    'فهارس الكتب': ['Bibliografi', 'Bibliography', 'فهارس الكتب'],
    'العلل والسؤالات': ['Ilal Hadis', 'Hadith criticism', 'العلل والسؤالات'],
    'الفقه العام': ['Fikih Umum', 'General jurisprudence', 'الفقه العام'],
    'فقه التحولات': ['Fikih Tahawwulat', 'Fiqh al-Tahawwulat', 'فقه التحولات'],
    'علوم البلاغة': ['Balaghah', 'Rhetoric', 'علوم البلاغة'],
    'القواعد الفقهية': ['Kaidah Fikih', 'Legal maxims', 'القواعد الفقهية'],
    'التفسير وعلوم القرآن': [
      'Tafsir dan Ulumul Quran',
      'Qur’anic exegesis',
      'التفسير وعلوم القرآن'
    ],
    'الفتاوى': ['Fatwa', 'Legal opinions', 'الفتاوى'],
    'دواوين الشعر': ['Diwan Syair', 'Poetry collections', 'دواوين الشعر'],
    'علم العروض': ['Ilmu Arud', 'Prosody', 'علم العروض'],
    'الحديث والفتاوى': [
      'Hadis dan fatwa',
      'Hadith and legal opinions',
      'الحديث والفتاوى'
    ],
  };

  static String of(String source) {
    final normalized = source.trim();
    if (normalized.isEmpty || normalized == '-')
      return Loc.tr('unknownMetadata');
    final index = Loc.supportedCodes.indexOf(Loc.language);
    for (final entry in _sections.entries) {
      if (normalized.startsWith(entry.key)) return entry.value[index];
    }
    // Proper names and unclassified source terms stay intact for scholarly review.
    return normalized;
  }
}
