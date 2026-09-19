import 'l10n/language_notifier.dart';

/// Tabular civil Hijri estimate, not an Umm al-Qura or local moon-sighting decree.
/// A supplied authoritative date may override the arithmetic for that day.
class HijriDateUtils {
  static const _months = <String, List<String>>{
    'id': ['Muharram', 'Safar', 'Rabiulawal', 'Rabiulakhir', 'Jumadilawal', 'Jumadilakhir', 'Rajab', 'Syakban', 'Ramadan', 'Syawal', 'Zulkaidah', 'Zulhijah'],
    'en': ['Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Ula', 'Jumada al-Akhirah', 'Rajab', "Sha'ban", 'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'],
    'ar': ['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'],
  };
  static const _solarMonths = <String, List<String>>{
    'id': ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'],
    'en': ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    'ar': ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'],
  };
  static final Map<String, ({int day, int month, int year})> _apiCache = {};

  /// Mengonversi DateTime Masehi ke representasi Hijriah (Tahun, Bulan, Hari).
  /// Uses supplied date overrides, otherwise a tabular civil calculation.
  static ({int day, int month, int year}) gregorianToHijri(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    if (_apiCache.containsKey(key)) {
      return _apiCache[key]!;
    }

    int day = date.day;
    int month = date.month;
    int year = date.year;

    int m = month;
    int y = year;
    if (m < 3) {
      y -= 1;
      m += 12;
    }

    int a = y ~/ 100;
    int b = 2 - a + (a ~/ 4);
    int jd = (365.25 * (y + 4716)).toInt() + (30.6001 * (m + 1)).toInt() + day + b - 1524;

    // Menghitung hari Hijriah dari Julian Day (Epoch 1 Muharram 1 H = JD 1948440)
    int l = jd - 1948440 + 10632;
    int n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    int j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) + (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    int hMonth = (24 * l) ~/ 709;
    int hDay = l - (709 * hMonth) ~/ 24;
    int hYear = 30 * n + j - 30;

    return (day: hDay.clamp(1, 30), month: hMonth.clamp(1, 12), year: hYear);
  }

  /// Registers a date supplied by an external verified source; performs no API call.
  static void registerVerifiedHijriDate({required DateTime date, required int day, required int month, required int year}) {
    if (day < 1 || day > 30 || month < 1 || month > 12 || year < 1) {
      throw ArgumentError('Invalid Hijri date');
    }
    final key = '${date.year}-${date.month}-${date.day}';
    _apiCache[key] = (day: day, month: month, year: year);
  }

  static String formatHijri({required int day, required int month, required int year,
    String? languageCode, bool? easternArabicDigits}) {
    if (day < 1 || day > 30 || month < 1 || month > 12 || year < 1) {
      throw ArgumentError('Invalid Hijri date');
    }
    final code = languageCode ?? LocaleService.instance.current.languageCode;
    final months = _months[code] ?? _months['id']!;
    final suffix = switch (code) { 'ar' => 'هـ', 'en' => 'AH', _ => 'H' };
    final dayLabel = code == 'en' ? '$day${_ordinal(day)}' : '$day';
    return formatUiNumber('$dayLabel ${months[month - 1]} $year $suffix',
      languageCode: code, easternArabicDigits: easternArabicDigits);
  }
  static String _ordinal(int value) {
    if (value % 100 >= 11 && value % 100 <= 13) return 'th';
    return switch (value % 10) { 1 => 'st', 2 => 'nd', 3 => 'rd', _ => 'th' };
  }
  static String formatDualDate([DateTime? date]) =>
    '${formatHijriOnly(date)} • ${formatMasehiOnly(date)}';
  static String formatHijriOnly([DateTime? date]) {
    final h = gregorianToHijri(date ?? DateTime.now());
    return formatHijri(day: h.day, month: h.month, year: h.year);
  }
  static String formatMasehiOnly([DateTime? date]) {
    final now = date ?? DateTime.now();
    final code = LocaleService.instance.current.languageCode;
    final months = _solarMonths[code] ?? _solarMonths['id']!;
    final suffix = switch (code) { 'ar' => 'م', 'en' => 'CE', _ => 'M' };
    return formatUiNumber('${now.day} ${months[now.month - 1]} ${now.year} $suffix');
  }

  /// Menambahkan durasi bulan kalender dengan month-end clamping deterministik.
  /// Contoh: 31 Januari + 1 bulan = 28 Februari (atau 29 pada kabisat).
  /// 31 Maret + 1 bulan = 30 April.
  static DateTime addCalendarMonthsClamped(DateTime baseDate, int months) {
    var newYear = baseDate.year;
    var newMonth = baseDate.month + months;
    while (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    while (newMonth < 1) {
      newYear--;
      newMonth += 12;
    }
    final daysInTargetMonth = DateTime(newYear, newMonth + 1, 0).day;
    final clampedDay = baseDate.day > daysInTargetMonth ? daysInTargetMonth : baseDate.day;
    return DateTime(
      newYear,
      newMonth,
      clampedDay,
      baseDate.hour,
      baseDate.minute,
      baseDate.second,
      baseDate.millisecond,
      baseDate.microsecond,
    );
  }
}


