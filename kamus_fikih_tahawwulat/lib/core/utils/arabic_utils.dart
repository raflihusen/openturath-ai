/// Utility Normalisasi & Pencarian Cerdas Teks Arab (Smart Arabic Search)
/// - Menghilangkan seluruh harakat (fathah, dhommah, kasrah, tanwin, sukun, tasydid, dagger alif, dll.)
/// - Menyatukan variasi huruf Alif (أ, إ, آ, ٱ -> ا)
/// - Menyatukan Ta Marbuthah & Ha (ة -> ه)
/// - Menyatukan Ya & Alif Maqshurah (ى -> ي)
/// - Menyatukan Hamzah di atas Waw & Ya (ؤ, ئ -> ء)
/// - Menghilangkan tatweel / kashida (ـ)
class ArabicUtils {
  static final RegExp _harakatRegex = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
  static final RegExp _tatweelRegex = RegExp(r'\u0640');

  /// Normalisasi string Arab untuk perbandingan pencarian fleksibel
  static String normalize(String text) {
    if (text.isEmpty) return '';

    // 1. Hapus harakat & tatweel
    var normalized = text.replaceAll(_harakatRegex, '').replaceAll(_tatweelRegex, '');

    // 2. Normalisasi variasi huruf alif
    normalized = normalized
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[ؤئ]'), 'ء');

    return normalized.toLowerCase().trim();
  }

  /// Cek apakah teks target mengandung query pencarian (baik Arab maupun Latin)
  static bool matches(String source, String query) {
    if (query.trim().isEmpty) return true;

    final normSource = normalize(source);
    final normQuery = normalize(query);

    // Cek versi normalisasi
    if (normSource.contains(normQuery)) return true;

    // Cek versi teks mentah (case-insensitive)
    if (source.toLowerCase().contains(query.toLowerCase().trim())) return true;

    return false;
  }
}
