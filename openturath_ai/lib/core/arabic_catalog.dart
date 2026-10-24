import 'package:flutter/material.dart';

/// Teks katalog kitab yang SELALU berbahasa Arab dan RTL, apa pun bahasa
/// aplikasi (keputusan pemilik 2026-10-16): katalog adalah bagian turath,
/// jadi judul, label, angka, dan keterangan edisi ditulis dalam bahasa Arab.
abstract final class ArabicCatalog {
  /// Gaya teks antarmuka Arab (Cairo) untuk katalog, terlepas dari bahasa aplikasi.
  static TextStyle ui(
          {double? fontSize,
          FontWeight? fontWeight,
          Color? color,
          double? height}) =>
      TextStyle(
          fontFamily: 'NativeArabicUI',
          fontFamilyFallback: const ['NativeInter'],
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height ?? 1.5);

  /// Tema katalog: seluruh komponen bawaan (chip, menu, tombol) memakai huruf Arab.
  static ThemeData theme(ThemeData t) => t.copyWith(
      textTheme: t.textTheme.apply(fontFamily: 'NativeArabicUI'),
      primaryTextTheme: t.primaryTextTheme.apply(fontFamily: 'NativeArabicUI'));

  static const _hindi = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  /// Ubah angka Latin menjadi angka Arab-Timur.
  static String digits(String s) =>
      s.replaceAllMapped(RegExp(r'[0-9]'), (m) => _hindi[int.parse(m[0]!)]);

  /// 5775 -> ٥٬٧٧٥
  static String number(String s) {
    final latin =
        s.replaceAllMapped(RegExp(r'[٠-٩]'), (m) => '${_hindi.indexOf(m[0]!)}');
    final n = int.tryParse(latin.trim());
    if (n == null) return digits(s);
    final grouped = n
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return digits(grouped).replaceAll(',', '٬');
  }

  static bool _ada(String v) {
    final t = v.trim();
    return t.isNotEmpty && t != '-' && t != notStated;
  }

  static const notStated = 'غير متوفر في المصدر';
  static const notStatedShort = 'غير مذكور في المصدر';

  static String? volumes(String v) => _ada(v) ? 'المجلدات: ${number(v)}' : null;

  static String? pages(String v) => _ada(v) ? 'الصفحات: ${number(v)}' : null;

  /// «ت ٧١٠ هـ» dari angka; teks seperti «معاصر» dipakai apa adanya.
  static String? death(int? year, [String text = '']) {
    final t = text.trim();
    if (t.isNotEmpty &&
        t != notStated &&
        !RegExp(r'^[0-9٠-٩]+\s*هـ$').hasMatch(t)) {
      return digits(t);
    }
    if (year == null || year <= 0) return null;
    return 'ت ${digits('$year')} هـ';
  }

  /// Nama pengarang tanpa keterangan wafat dalam kurung (wafat ditampilkan terpisah).
  static String authorName(String author) => author
      .replaceAll(RegExp(r'\s*\((?:ال)?متو[فـ]ى[^)]*\)'), '')
      .replaceAll(RegExp(r'\s*\(ت\s*[0-9٠-٩]+\s*هـ?\)'), '')
      .trim();

  // Label antarmuka katalog.
  static const catalogTitle = 'فهرس الكتب';
  static const bookCard = 'بطاقة الكتاب';
  static const searchHint = 'ابحث بعنوان الكتاب أو المؤلف أو المحقق أو الناشر';
  static const clearSearch = 'مسح البحث';
  static const allBooks = 'جميع الكتب';
  static const singleVolume = 'مجلد واحد';
  static const multiVolume = 'عدة مجلدات';
  static const sortTitle = 'العنوان';
  static const sortAuthor = 'المؤلف';
  static const sortVolumes = 'عدد المجلدات';
  static const cardView = 'عرض البطاقات';
  static const listView = 'قائمة مختصرة';
  static const noBooks = 'لم نعثر على كتب مطابقة.';
  static const tryAnother = 'جرّب عنوانًا أو اسم مؤلف آخر.';
  static const aiInfo = 'عن هذا المساعد';
  static const back = 'رجوع';
  static String bookCount(int n) => 'عدد الكتب: ${number('$n')}';
  static String shown(int n, int total) =>
      'الكتب المعروضة: ${number('$n')} من ${number('$total')}';

  static const edition = 'بيانات الطبعة';
  static const copyCitation = 'نسخ الإحالة';
  static const saveNote = 'حفظ في الملاحظات';
  static const removeNote = 'إزالة من الملاحظات';
  static const copied = 'تم نسخ الإحالة';
  static const saved = 'تم الحفظ في الملاحظات';
  static const lTitle = 'الكتاب';
  static const lAuthor = 'المؤلف';
  static const lDeath = 'الوفاة';
  static const lScience = 'العلم';
  static const lVolumes = 'المجلدات';
  static const lPages = 'الصفحات';
  static const lEdition = 'الطبعة';
  static const lEditor = 'المحقق';
  static const lSupervisor = 'الإشراف';
  static const lPublisher = 'الناشر';
  static const lType = 'نوع الكتاب';
  static const lWarning = 'تنبيه';
  static const notice =
      'بيانات الطبعة منقولة من بطاقة الكتاب في مصدره الرقمي، وما لم يُذكر فيها تُرك فارغًا ولم يُخمَّن. وذِكرُ اسم المحقق لا يعني أن OpenTurath راجع النص.';
  static const reviewNotice =
      'في بيانات هذه الطبعة ما يحتاج إلى مراجعة؛ فتحقق منها في المصدر.';
}
