import 'localization.dart';

/// Jenis naskah harus berasal dari metadata, bukan dugaan dari nama kitab.
enum BookStudyLevel {
  all,
  matan,
  sharh,
  hashiyah,
  unclassified;

  String get label => Loc.tr(switch (this) {
        all => 'allBooks',
        matan => 'matan',
        sharh => 'sharh',
        hashiyah => 'hashiyah',
        unclassified => 'unclassified',
      });
  static BookStudyLevel fromMetadata(String value) {
    final normalized = value.toLowerCase().trim();
    if (const ['matan', 'matn', 'متن', 'المتون', 'matan dasar']
        .contains(normalized)) {
      return matan;
    }
    if (const ['syarah', 'sharh', 'شرح', 'الشروح', "syarah mu'tamad"]
        .contains(normalized)) {
      return sharh;
    }
    if (const ['hasyiyah', 'hashiyah', 'حاشية', 'الحواشي', 'hasyiyah ilmiah']
        .contains(normalized)) {
      return hashiyah;
    }
    return unclassified;
  }
}
