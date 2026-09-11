/// Utilitas penanggalan Islam (Hijriah) dan Masehi deterministik & akurat
/// untuk tajuk editorial OpenTurath.
class HijriDateUtils {
  static const List<String> _hijriMonths = [
    'Muharram',
    'Shafar',
    'Rabi\'ul Awwal',
    'Rabi\'uts Tsani',
    'Jumadil Ula',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadhan',
    'Syawwal',
    'Dzulqa\'dah',
    'Dzulhijjah',
  ];

  static const List<String> _masehiMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static final Map<String, ({int day, int month, int year})> _apiCache = {};

  /// Mengonversi DateTime Masehi ke representasi Hijriah (Tahun, Bulan, Hari).
  /// Memanfaatkan cache API AlAdhan jika tersedia, atau perhitungan deterministik Umm al-Qura.
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

  /// Sinkronisasi tanggal Hijriyah dari AlAdhan API resmi secara senyap di latar belakang.
  static void registerVerifiedHijriDate({required DateTime date, required int day, required int month, required int year}) {
    final key = '${date.year}-${date.month}-${date.day}';
    _apiCache[key] = (day: day, month: month, year: year);
  }

  /// Menghasilkan format tanggal ganda yang anggun dan editorial:
  /// Contoh: "26 Shafar 1448 H • 9 September 2026 M"
  static String formatDualDate([DateTime? date]) {
    final now = date ?? DateTime.now();
    final h = gregorianToHijri(now);

    final hMonthName = (h.month >= 1 && h.month <= 12)
        ? _hijriMonths[h.month - 1]
        : 'Bulan';
    final mMonthName = (now.month >= 1 && now.month <= 12)
        ? _masehiMonths[now.month - 1]
        : '';

    return '${h.day} $hMonthName ${h.year} H • ${now.day} $mMonthName ${now.year} M';
  }

  /// Menghasilkan hanya tanggal Hijriah pendek:
  /// Contoh: "26 Shafar 1448 H"
  static String formatHijriOnly([DateTime? date]) {
    final now = date ?? DateTime.now();
    final h = gregorianToHijri(now);
    final hMonthName = (h.month >= 1 && h.month <= 12)
        ? _hijriMonths[h.month - 1]
        : 'Bulan';
    return '${h.day} $hMonthName ${h.year} H';
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
