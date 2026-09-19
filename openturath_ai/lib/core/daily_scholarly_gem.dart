/// Reviewed seed collection: public-domain Arabic source text, original ID/EN
/// renderings of the meaning. Rotation is not a claim of 365 unique narrations.
class DailyScholarlyGem {
  const DailyScholarlyGem({required this.id, required this.excerpt,
    required this.sanad, required this.meaningKey, required this.hadithNumber});
  final String id;
  final String excerpt;
  final String sanad;
  final String meaningKey;
  final int hadithNumber;
  String get sourceUrl => 'https://sunnah.com/bukhari:$hadithNumber';
  String source(String code) => switch (code) {
    'ar' => 'صحيح البخاري، الحديث $hadithNumber',
    'en' => 'Sahih al-Bukhari, hadith $hadithNumber',
    _ => 'Shahih al-Bukhari, hadis $hadithNumber',
  };
  String copyWithSanad(String code) => '$sanad\n«$excerpt»\n\n${source(code)}\n$sourceUrl';
  static DailyScholarlyGem forDate(DateTime date) {
    // Calendar components, not local elapsed hours: stable through DST changes.
    final index = DateTime.utc(date.year, date.month, date.day)
      .difference(DateTime.utc(2026, 1, 1)).inDays;
    return collection[((index % collection.length) + collection.length) % collection.length];
  }
  static const collection = <DailyScholarlyGem>[
    DailyScholarlyGem(id: 'bukhari-1', hadithNumber: 1, meaningKey: 'gem.intention',
      excerpt: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      sanad: 'حَدَّثَنَا الْحُمَيْدِيُّ عَبْدُ اللَّهِ بْنُ الزُّبَيْرِ، قَالَ حَدَّثَنَا سُفْيَانُ، قَالَ حَدَّثَنَا يَحْيَى بْنُ سَعِيدٍ الأَنْصَارِيُّ، قَالَ أَخْبَرَنِي مُحَمَّدُ بْنُ إِبْرَاهِيمَ التَّيْمِيُّ، أَنَّهُ سَمِعَ عَلْقَمَةَ بْنَ وَقَّاصٍ اللَّيْثِيَّ، يَقُولُ سَمِعْتُ عُمَرَ بْنَ الْخَطَّابِ رَضِيَ اللَّهُ عَنْهُ عَلَى الْمِنْبَرِ قَالَ سَمِعْتُ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ يَقُولُ:'),
    DailyScholarlyGem(id: 'bukhari-71', hadithNumber: 71, meaningKey: 'gem.knowledge',
      excerpt: 'مَنْ يُرِدِ اللَّهُ بِهِ خَيْرًا يُفَقِّهْهُ فِي الدِّينِ',
      sanad: 'حَدَّثَنَا سَعِيدُ بْنُ عُفَيْرٍ، قَالَ حَدَّثَنَا ابْنُ وَهْبٍ، عَنْ يُونُسَ، عَنِ ابْنِ شِهَابٍ، قَالَ قَالَ حُمَيْدُ بْنُ عَبْدِ الرَّحْمَنِ سَمِعْتُ مُعَاوِيَةَ خَطِيبًا يَقُولُ سَمِعْتُ النَّبِيَّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ يَقُولُ:'),
  ];
}
