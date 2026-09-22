import 'package:flutter/material.dart';
import '../localization.dart';
import 'native_fonts.dart';

/// Native-only design vocabulary. The AI room keeps its original tokens.
abstract final class NativeColors {
  static const canvasLight = Color(0xFFF9F9F8);
  static const canvasDark = Color(0xFF101010);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1A1A1A);
  static const surfaceSubtleLight = Color(0xFFF0F0ED);
  static const surfaceSubtleDark = Color(0xFF252523);
  static const textPrimaryLight = Color(0xFF191919);
  static const textPrimaryDark = Color(0xFFF2F2EF);
  static const textSecondaryLight = Color(0xFF60605B);
  static const textSecondaryDark = Color(0xFFB6B6AF);
  static const textTertiaryLight = Color(0xFF70706A);
  static const textTertiaryDark = Color(0xFFA0A099);
  static const borderLight = Color(0x14191919);
  static const borderDark = Color(0x1FFFFFFF);
  static const borderStrongLight = Color(0xFF787872);
  static const borderStrongDark = Color(0xFF92928B);
  static const accentLight = textPrimaryLight;
  static const accentDark = textPrimaryDark;
  static const destructiveLight = Color(0xFF8C2F2F);
  static const destructiveDark = Color(0xFFE49A93);
  static Color canvas(bool dark) => dark ? canvasDark : canvasLight;
  static Color surface(bool dark) => dark ? surfaceDark : surfaceLight;
  static Color surfaceSubtle(bool dark) => dark ? surfaceSubtleDark : surfaceSubtleLight;
  static Color textPrimary(bool dark) => dark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool dark) => dark ? textSecondaryDark : textSecondaryLight;
  static Color textTertiary(bool dark) => dark ? textTertiaryDark : textTertiaryLight;
  static Color border(bool dark) => dark ? borderDark : borderLight;
  static Color borderStrong(bool dark) => dark ? borderStrongDark : borderStrongLight;
  static Color accent(bool dark) => textPrimary(dark);
  static Color onAccent(bool dark) => canvas(dark);
  static Color inverseSurface(bool dark) => dark ? surfaceLight : textPrimaryLight;
  static Color destructive(bool dark) => dark ? destructiveDark : destructiveLight;
  static Color marja(bool dark) => dark ? const Color(0xFFA7BDA6) : const Color(0xFF405C42);
  static Color collection(bool dark) => dark ? const Color(0xFF171917) : const Color(0xFFF7F5F0);
  static Color brass(bool dark) => dark ? const Color(0xFFC7AD78) : const Color(0xFF765C2E);
}

abstract final class NativeType {
  static TextStyle title(bool dark, {double size = 28}) => NativeFonts.newsreader(
    fontSize: size, fontWeight: FontWeight.w600, letterSpacing: -.35,
    height: 1.2, color: NativeColors.textPrimary(dark));
  static TextStyle body(bool dark, {double size = 16}) => NativeFonts.outfit(
    fontSize: size, height: 1.5, color: NativeColors.textPrimary(dark));
  static TextStyle meta(bool dark) => NativeFonts.outfit(
    fontSize: 13, height: 1.45, color: NativeColors.textSecondary(dark));
  static TextStyle arabic(bool dark, {double size = 26}) => NativeFonts.scheherazadeNew(
    fontSize: size, height: 1.9, fontWeight: FontWeight.w600,
    color: NativeColors.textPrimary(dark));
}

/// Separate keys and defaults: changing native copy must not change AI chrome.
abstract final class NativeCopy {
  static const values = <String, List<String>>{
    'collection': ['Koleksi istimewa', 'Special collection', 'مجموعة خاصة'],
    'exclusive': ['Koleksi istimewa', 'Special collection', 'مجموعة خاصة'],
    'fivePaths': ['Lima pintu telaah', 'Five paths of study', 'خمسة مسارات للدراسة'],
    'chooseRole': ['Pilih asisten sesuai kebutuhan kajian Anda.', 'Choose an assistant for your study needs.', 'اختر المساعد المناسب لاحتياجات دراستك.'],
    'open': ['Buka asisten', 'Open assistant', 'فتح المساعد'],
    'explore': ['Jelajahi koleksi', 'Explore collection', 'استكشاف المجموعة'],
    'sources': ['Kitab rujukan', 'Reference works', 'الكتب المرجعية'],
    'aboutCollection': ['Tentang koleksi', 'About this collection', 'عن المجموعة'],
    'intro': ['Mengenal Fikih Tahawwulat', 'Introducing Fiqh al-Tahawwulat', 'التعريف بفقه التحولات'],
    'lineage': ['Karya Al-Habib Abu Bakar Al-Adni Al-Masyhur', 'Works of al-Habib Abu Bakr al-Adni al-Mashhur', 'مؤلفات الحبيب أبي بكر العدني المشهور'],
    'collectionBody': ['Telaah naskah, pahami konsep, dan telusuri khazanah Fikih Tahawwulat bersama lima asisten khusus.', 'Study texts, explore concepts, and discover the heritage of Fiqh al-Tahawwulat with five dedicated assistants.', 'طالع النصوص وافهم المفاهيم واستكشف تراث فقه التحولات مع خمسة مساعدين متخصصين.'],
    'muhaqqiq': ['Telaah matan, ibarah, dan rujukannya.', 'Study source texts, passages, and references.', 'مطالعة المتون والعبارات ومراجعها.'],
    'bayan': ['Pahami konsep dan istilah secara bertahap.', 'Explore concepts and terms step by step.', 'فهم المفاهيم والمصطلحات خطوة بخطوة.'],
    'mukhtabir': ['Uji pemahaman melalui tanya jawab.', 'Test your understanding through questions and answers.', 'اختبار الفهم من خلال الأسئلة والأجوبة.'],
    'habib': ['Telusuri materi muhadharah Habib Abu Bakar.', 'Explore Habib Abu Bakr’s lecture materials.', 'استكشاف مواد محاضرات الحبيب أبي بكر.'],
    'khatib': ['Susun bahan dakwah dan khutbah.', 'Prepare materials for talks and sermons.', 'إعداد مواد للدعوة والخطب.'],
    'active': ['Akses aktif', 'Access active', 'الوصول مفعّل'],
    'access': ['Lihat pilihan akses', 'View access options', 'عرض خيارات الوصول'],
    'loading': ['Memuat…', 'Loading…', 'جارٍ التحميل…'],
    'loadingBooks': ['Memuat kitab rujukan…', 'Loading reference works…', 'جارٍ تحميل الكتب المرجعية…'],
    'slow': ['Masih memuat. Anda dapat kembali dan mencoba lagi.', 'Still loading. You can go back and try again.', 'لا يزال التحميل جاريًا. يمكنك الرجوع والمحاولة مجددًا.'],
    'error': ['Belum dapat memuat data.', 'Couldn’t load the data.', 'تعذّر تحميل البيانات.'],
    'retry': ['Coba lagi', 'Try again', 'إعادة المحاولة'],
    'back': ['Kembali', 'Back', 'رجوع'],
    'cancel': ['Batal', 'Cancel', 'إلغاء'],
    'recentNotes': ['Catatan terakhir', 'Recent notes', 'الملاحظات الأخيرة'],
    'notesEmpty': ['Belum ada catatan', 'No notes yet', 'لا توجد ملاحظات بعد'],
    'notesHint': ['Simpan rujukan atau tulis catatan pertama Anda.', 'Save a reference or write your first note.', 'احفظ مرجعًا أو اكتب ملاحظتك الأولى.'],
    'write': ['Tulis catatan', 'Write a note', 'كتابة ملاحظة'],
    'searchAssistants': ['Cari asisten atau bidang ilmu', 'Search assistants or disciplines', 'البحث عن مساعد أو مجال علمي'],
    'searchBooks': ['Cari kitab, pengarang, atau muhaqqiq', 'Search works, authors, or editors', 'البحث عن كتاب أو مؤلف أو محقق'],
    'catalog': ['Katalog kitab', 'Book catalog', 'فهرس الكتب'],
    'allBooks': ['Semua kitab', 'All works', 'جميع الكتب'],
    'singleVolume': ['Satu jilid', 'One volume', 'مجلد واحد'],
    'multiVolume': ['Beberapa jilid', 'Multiple volumes', 'عدة مجلدات'],
    'noBooks': ['Tidak ada kitab yang cocok.', 'No matching works.', 'لم نعثر على كتب مطابقة.'],
    'searchHint': ['Coba judul atau nama pengarang lain.', 'Try another title or author.', 'جرّب عنوانًا أو اسم مؤلف آخر.'],
    'results': ['{0} dari {1} kitab', '{0} of {1} works', '{0} من {1} كتابًا'],
    'disciplines': ['Bidang ilmu', 'Disciplines', 'المجالات العلمية'],
    'scholars': ['Khazanah ulama', 'Scholarly collections', 'تراث العلماء'],
    'yourStudy': ['Ruang belajar Anda', 'Your study space', 'مساحة دراستك'],
    'readAgain': ['Buka kembali hasil telaah Anda.', 'Return to your study notes.', 'عُد إلى ملاحظات دراستك.'],
    'edition': ['Identitas edisi', 'Edition details', 'بيانات الطبعة'],
    'author': ['Pengarang', 'Author', 'المؤلف'],
    'editor': ['Tahqiq', 'Editor', 'المحقق'],
    'publisher': ['Penerbit', 'Publisher', 'الناشر'],
    'year': ['Tahun terbit', 'Publication year', 'سنة النشر'],
    'volumes': ['Jilid', 'Volumes', 'المجلدات'],
    'saveReference': ['Simpan rujukan', 'Save reference', 'حفظ المرجع'],
    'copyReference': ['Salin rujukan', 'Copy reference', 'نسخ المرجع'],
    'saved': ['Rujukan tersimpan', 'Reference saved', 'تم حفظ المرجع'],
    'copied': ['Rujukan disalin', 'Reference copied', 'تم نسخ المرجع'],
    'saveFailed': ['Belum dapat menyimpan. Coba lagi.', 'Couldn’t save. Try again.', 'تعذّر الحفظ. حاول مجددًا.'],
    'selectedAccess': ['Pilihan akses Anda', 'Your access selection', 'اختيار الوصول'],
    'otherAccess': ['Pilihan lainnya', 'Other options', 'خيارات أخرى'],
    'allFive': ['Termasuk kelima asisten khusus.', 'Includes all five dedicated assistants.', 'يشمل المساعدين المتخصصين الخمسة.'],
    'studyReminder': ['Periksa hasil telaah pada sumbernya dan diskusikan bersama guru.', 'Check your findings against the sources and discuss them with a teacher.', 'راجع نتائج دراستك في مصادرها وناقشها مع معلمك.'],
  };
  static String text(String key, [List<String> args = const []]) {
    final translations = values[key];
    if (translations == null) throw ArgumentError.value(key, 'key');
    var result = translations[Loc.supportedCodes.indexOf(Loc.language)];
    for (var i = 0; i < args.length; i++) {
      result = result.replaceAll('{$i}', args[i]);
    }
    return result;
  }
  static String role(String id) => text(id.split('_').last);
}
