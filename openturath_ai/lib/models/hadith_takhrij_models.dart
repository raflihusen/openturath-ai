/// Model data kanonikal untuk Universal Algorithmic Takhrij Engine (UATE)
/// Hasil rekonstruksi & ekspansi arsitektur Jami' Khadim al-Haramayn (Khademhrf)
/// dari 33 kitab statis menjadi ribuan kitab hadis.
library;

/// Taksonomi kitab hadis untuk menggantikan hardcode `@BookID='26'` di `TakhreegXSL.xsl`.
enum HadithBookTaxonomy {
  /// Kitab musnad asli (Bukhari, Muslim, Abu Dawud, Ahmad, dll.) -> "أخرجه [المصنف] في [الكتاب]"
  musnadPrimary,

  /// Zawa'id perawi atas kitab musnad (seperti 'Abdullah bin Ahmad, al-Qatthan, al-Firyabi)
  /// -> "أخرجه [راوي الزوائد] في زوائده على [الكتاب]"
  zawaidNarrator,

  /// Kitab kompilasi/zawa'id tanpa sanad mandiri (al-Mathalib al-'Aliyah, Majma' al-Zawa'id, Kanz al-'Ummal)
  /// -> "أورده [المصنف] في [الكتاب]"
  secondaryCompilation,

  /// Kitab Mustakhraj (Mustakhraj Abi 'Awanah, al-Isma'ili, Abi Nu'aym)
  /// -> "أخرجه [المصنف] في مستخرجه على [الكتاب]"
  mustakhraj,

  /// Muqaddimah kitab (seperti Muqaddimah Shahih Muslim)
  /// -> "أخرجه [المصنف] في مقدمة [الكتاب]"
  muqaddimah,

  /// Kitab khadami: syarah, takhrij, 'ilal, rijal, gharib (Fath al-Bari, al-Talkhish al-Habir, Tuhfat al-Asyraf)
  serviceSharhTakhrij,
}

/// Informasi perawi zawa'id pada kitab musnad (berdasarkan WorkingGroups.pdf hlm. 69).
class ZawaidNarratorInfo {
  final String narratorId;
  final String narratorArabicName;
  final String baseBookTitle;
  final int hadithCount;
  final String notes;

  const ZawaidNarratorInfo({
    required this.narratorId,
    required this.narratorArabicName,
    required this.baseBookTitle,
    required this.hadithCount,
    this.notes = '',
  });
}

/// Metadata kitab dalam korpus ribuan kitab hadis.
class HadithBookMetadata {
  final String id;
  final String titleArabic;
  final String titleLatin;
  final String authorArabic;
  final String authorLatin;
  final int deathYearHijri;
  final int centuryHijri;
  final HadithBookTaxonomy taxonomy;
  final int canonicalRank;
  final String primaryPrintEdition;
  final String? secondaryPrintEdition;
  final ZawaidNarratorInfo? zawaidInfo;
  final bool isCore33;

  const HadithBookMetadata({
    required this.id,
    required this.titleArabic,
    required this.titleLatin,
    required this.authorArabic,
    required this.authorLatin,
    required this.deathYearHijri,
    required this.centuryHijri,
    required this.taxonomy,
    required this.canonicalRank,
    required this.primaryPrintEdition,
    this.secondaryPrintEdition,
    this.zawaidInfo,
    this.isCore33 = false,
  });

  /// Menghasilkan formula atribusi takhrij bahasa Arab yang presisi sesuai manhaj kitab
  /// (menggantikan logika XSLT `<TakreegMutonBook>` di `TakhreegXSL.xsl`).
  String formatAttributionPhrase({bool isFirstInChain = true, bool precedingWasSecondary = false}) {
    final prefix = isFirstInChain
        ? ''
        : '، و';
    final needVerb = isFirstInChain || precedingWasSecondary;

    switch (taxonomy) {
      case HadithBookTaxonomy.secondaryCompilation:
        return '$prefixأورده $authorArabic في "$titleArabic"';
      case HadithBookTaxonomy.zawaidNarrator:
        final verb = needVerb ? 'أخرجه ' : '';
        final narrator = zawaidInfo?.narratorArabicName ?? authorArabic;
        final baseBook = zawaidInfo?.baseBookTitle ?? titleArabic;
        return '$prefix$verb$narrator في زوائده على "$baseBook"';
      case HadithBookTaxonomy.muqaddimah:
        final verb = needVerb ? 'أخرجه ' : '';
        return '$prefix$verb$authorArabic في "مقدمة $titleArabic"';
      case HadithBookTaxonomy.mustakhraj:
        final verb = needVerb ? 'أخرجه ' : '';
        return '$prefix$verb$authorArabic في "$titleArabic"';
      case HadithBookTaxonomy.serviceSharhTakhrij:
        return '$prefixذكره $authorArabic في "$titleArabic"';
      case HadithBookTaxonomy.musnadPrimary:
        final verb = needVerb ? 'أخرجه ' : '';
        return '$prefix$verb$authorArabic في "$titleArabic"';
    }
  }
}

/// Status marfu'/mauquf/maqthu' sebuah riwayat hadis.
enum HadithElevationStatus {
  marfu('مرفوع', 'Marfu‘ (Sabda/Perbuatan Nabi ﷺ)'),
  mauquf('موقوف', 'Mauquf (Perkataan/Perbuatan Sahabat)'),
  maqthu('مقطوع', 'Maqthu‘ (Perkataan Tabi‘in)'),
  qudsi('قدسي', 'Hadis Qudsi');

  final String arabicLabel;
  final String indonesianLabel;
  const HadithElevationStatus(this.arabicLabel, this.indonesianLabel);
}

/// Satu mata rantai perawi di dalam sanad hadis.
class SanadNarratorHop {
  final String rawMention;
  final String? resolvedRawiId;
  final String resolvedArabicName;
  final String transmissionPhrase; // حدثنا، أخبرنا، عن، سمعت، قال
  final double disambiguationConfidence;
  final bool wasMuhmalOrMubham;

  const SanadNarratorHop({
    required this.rawMention,
    this.resolvedRawiId,
    required this.resolvedArabicName,
    required this.transmissionPhrase,
    this.disambiguationConfidence = 1.0,
    this.wasMuhmalOrMubham = false,
  });
}

/// Rekaman kanonikal satu hadis beserta penomoran ganda lintas cetakan.
class CanonicalHadithRecord {
  final String uri;
  final String bookId;
  final String bookTitleArabic;
  final int harfNumber;
  final String printNumber; // TarqeemMatboa1
  final int partNumber;
  final int pageNumber;
  final String sectionTitle; // كتاب
  final String chapterTitle; // باب
  final String rawSanad;
  final String rawMatn;
  final String? hiddenMatnFromIhalah; // <متن_مخفي>
  final String? hiddenSanadFromIhalah; // <سند_مخفي>
  final String rawiAlaId;
  final String rawiAlaArabicName;
  final HadithElevationStatus elevationStatus;
  final List<SanadNarratorHop> sanadChain;
  final String? historicalDateLabel; // تواريخ المتون
  final List<String> thematicTags; // شجرة الموضوعات

  const CanonicalHadithRecord({
    required this.uri,
    required this.bookId,
    required this.bookTitleArabic,
    required this.harfNumber,
    required this.printNumber,
    required this.partNumber,
    required this.pageNumber,
    required this.sectionTitle,
    required this.chapterTitle,
    required this.rawSanad,
    required this.rawMatn,
    this.hiddenMatnFromIhalah,
    this.hiddenSanadFromIhalah,
    required this.rawiAlaId,
    required this.rawiAlaArabicName,
    this.elevationStatus = HadithElevationStatus.marfu,
    required this.sanadChain,
    this.historicalDateLabel,
    this.thematicTags = const [],
  });

  /// Matan efektif yang digunakan untuk pengindeksan dan takhrij
  /// (menggabungkan matan tampak dan `<متن_مخفي>` hasil resolusi ihalah).
  String get effectiveMatnForIndexing {
    if (hiddenMatnFromIhalah != null && hiddenMatnFromIhalah!.trim().isNotEmpty) {
      return '$rawMatn ${hiddenMatnFromIhalah!}'.trim();
    }
    return rawMatn;
  }

  /// Format sitasi standar (`(الجزء/الصفحة) برقم: (رقم الحديث)`).
  String get formattedCitation => '($partNumber/$pageNumber) برقم: ($printNumber)';
}

/// Kategori utama perbandingan lafaz matan.
enum MatnComparisonCategory {
  biLafzhihi('بلفظه', 'Lafaz Identik (100% Akar & Wazan)'),
  biMitslihi('بمثله', 'Lafaz Semisal (≥ 90% Kecocokan)'),
  biNahwihi('بنحوه', 'Lafaz Senada (≥ 40% Sekuens)'),
  biManahu('بمعناه', 'Makna Сеrupa (≥ 20% Kecocokan)'),
  withoutPhrase('من غير ذكر هذا اللفظ', 'Tanpa Penyebutan Lafaz Ini');

  final String arabicTitle;
  final String indonesianTitle;
  const MatnComparisonCategory(this.arabicTitle, this.indonesianTitle);
}

/// Ke-27 aturan deterministik Muqaranat al-Mutun (WorkingGroups.pdf hlm. 59–63).
enum MatnComparisonRule {
  rule01BiLafzhihi(1, 'بلفظه', MatnComparisonCategory.biLafzhihi),
  rule02BiLafzhihiZiyadahAwwalAwAkhir(2, 'بلفظه بزيادة في أوله أو آخره', MatnComparisonCategory.biLafzhihi),
  rule03BiLafzhihiMuthawwalan(3, 'بلفظه مطولاً', MatnComparisonCategory.biLafzhihi),
  rule04BiLafzhihiMuthawwalanWaZadaFihi(4, 'بلفظه مطولاً وزاد فيه', MatnComparisonCategory.biLafzhihi),
  rule05BiLafzhihiMukhtasharan(5, 'بلفظه مختصراً', MatnComparisonCategory.biLafzhihi),
  rule06BiLafzhihiMukhtasharanDunaQaulihi(6, 'بلفظه مختصراً دون قوله', MatnComparisonCategory.biLafzhihi),
  rule07MukhtasharanBiLafzhi(7, 'مختصراً بلفظ', MatnComparisonCategory.biLafzhihi),

  rule08BiMitslihi(8, 'بمثله', MatnComparisonCategory.biMitslihi),
  rule09BiMitslihiDunaQaulihi(9, 'بمثله دون قوله', MatnComparisonCategory.biMitslihi),
  rule10BiMitslihiMukhtasharanDunaQaulihi(10, 'بمثله مختصراً دون قوله', MatnComparisonCategory.biMitslihi),
  rule11BiMitslihiWaQalaFihi(11, 'بمثله وقال فيه', MatnComparisonCategory.biMitslihi),
  rule12BiMitslihiMukhtasharanBiLafzhi(12, 'بمثله مختصراً بلفظ', MatnComparisonCategory.biMitslihi),
  rule13BiMitslihiMuthawwalan(13, 'بمثله مطولاً', MatnComparisonCategory.biMitslihi),
  rule14BiMitslihiMuthawwalanWaQalaAwwalAwAkhir(14, 'بمثله مطولاً وقال في أوله أو آخره', MatnComparisonCategory.biMitslihi),
  rule15BiMitslihiMuthawwalanWaQalaFihi(15, 'بمثله مطولاً وقال فيه', MatnComparisonCategory.biMitslihi),
  rule16BiMitslihiMauqufan(16, 'بمثله موقوفاً', MatnComparisonCategory.biMitslihi),

  rule17BiNahwihi(17, 'بنحوه', MatnComparisonCategory.biNahwihi),
  rule18BiNahwihiMuthawwalan(18, 'بنحوه مطولاً', MatnComparisonCategory.biNahwihi),
  rule19BiNahwihiMukhtasharan(19, 'بنحوه مختصراً', MatnComparisonCategory.biNahwihi),
  rule20BiNahwihiMukhtasharanBiLafzhi(20, 'بنحوه مختصراً بلفظ', MatnComparisonCategory.biNahwihi),
  rule21BiNahwihiWaQalaFihi(21, 'بنحوه وقال فيه', MatnComparisonCategory.biNahwihi),
  rule22BiNahwihiWaQalaFiAwwalihi(22, 'بنحوه وقال في أوله', MatnComparisonCategory.biNahwihi),
  rule23BiNahwihiWaQalaFiAkhirihi(23, 'بنحوه وقال في آخره', MatnComparisonCategory.biNahwihi),

  rule24BiManahu(24, 'بمعناه', MatnComparisonCategory.biManahu),
  rule25BiManahuMukhtasharan(25, 'بمعناه مختصراً', MatnComparisonCategory.biManahu),
  rule26BiManahuMuthawwalan(26, 'بمعناه مطولاً', MatnComparisonCategory.biManahu),
  rule27MinGhayriDzikriHadzaAlLafzhi(27, 'من غير ذكر هذا اللفظ', MatnComparisonCategory.withoutPhrase);

  final int ruleNumber;
  final String baseArabicPhrase;
  final MatnComparisonCategory category;

  const MatnComparisonRule(this.ruleNumber, this.baseArabicPhrase, this.category);
}

/// Hasil evaluasi Muqaranat al-Mutun antara matan asal dan satu matan pembanding.
class MatnComparisonOutcome {
  final CanonicalHadithRecord targetHadith;
  final HadithBookMetadata targetBook;
  final MatnComparisonRule rule;
  final String formattedArabicVerdict;
  final double rootCoverageOnOrigin;
  final double rootCoverageOnTarget;
  final double sequenceOrderRatio;
  final double maxGapRatio;
  final List<String> diffSegments;
  final MutabaahRank mutabaahRank;
  final String? pivotRawiArabicName;

  const MatnComparisonOutcome({
    required this.targetHadith,
    required this.targetBook,
    required this.rule,
    required this.formattedArabicVerdict,
    required this.rootCoverageOnOrigin,
    required this.rootCoverageOnTarget,
    required this.sequenceOrderRatio,
    required this.maxGapRatio,
    this.diffSegments = const [],
    this.mutabaahRank = MutabaahRank.mutabaahQashirah,
    this.pivotRawiArabicName,
  });
}

/// Tingkatan mutaba'ah dalam takhrij sanad.
enum MutabaahRank {
  ashl('الرواية الأصلية', 'Riwayat Asal'),
  mutabaahTammah('متابعة تامة (عن شيخ المصنف)', 'Mutaba‘ah Tammah (Bertemu di Guru Mushannif)'),
  mutabaahQashirah('متابعة قاصرة (من طريق المدار)', 'Mutaba‘ah Qashirah (Bertemu di Atas Guru Mushannif)'),
  syahid('شاهد (من صحابي آخر)', 'Syahid (Lintas Sahabat)');

  final String arabicLabel;
  final String indonesianLabel;
  const MutabaahRank(this.arabicLabel, this.indonesianLabel);
}

/// Status ketersambungan antar-dua perawi dalam graf sanad (`AsaneedReport.dll`).
enum SanadLinkStatus {
  muttasilSama('ثبت لقاؤهما وسماعه منه', 'Bersambung (Terbukti Bertemu & Sama‘)', true),
  muasharahPossible('أمكن لقاؤهما وسماعه منه', 'Sezaman (Memungkinkan Sama‘)', true),
  mudallasAnanah('عنعنة مدلس لم يصرح بالسماع', '‘An‘anah Perawi Mudallis', false),
  mukhtalithLate('روى عنه بعد الاختلاط', 'Diriwayatkan Setelah Ikhtilath', false),
  munqathi('انقطاع لعدم ثبوت اللقاء أو المعاصرة', 'Terputus (Inqitha‘ / Irsal)', false);

  final String arabicDescription;
  final String indonesianDescription;
  final bool isConnected;
  const SanadLinkStatus(this.arabicDescription, this.indonesianDescription, this.isConnected);
}

/// Pernyataan ulama Jarh wa Ta'dil terhadap seorang perawi.
class JarhTadilStatement {
  final String criticArabicName; // الناقد
  final String? transmitterArabicName; // الحاكي
  final String statementArabic; // القول
  final String sourceBookArabic;
  final int rankCategory; // 1 = توثيق, 2 = توسط, 3 = تضعيف

  const JarhTadilStatement({
    required this.criticArabicName,
    this.transmitterArabicName,
    required this.statementArabic,
    required this.sourceBookArabic,
    required this.rankCategory,
  });
}

/// Data lengkap biografi perawi (rekonstruksi tabel `TaragemRwa` & `Nouns`).
class RawiBiographyRecord {
  final String id;
  final String fullNameArabic;
  final String esmShuhra;
  final String kunia;
  final String laqab;
  final String nasab;
  final int tabaqaNum;
  final String tabaqaArabic;
  final int? birthYearHijri;
  final int? deathYearHijri;
  final String livingCity;
  final String martabaIbnHajar; // تقريب التهذيب
  final String martabaDzahabi; // الكاشف
  final bool isMudallis;
  final bool isMukhtalith;
  final List<String> shyoukhIds;
  final List<String> talamizIds;
  final List<JarhTadilStatement> jarhTadilStatements;
  final int totalHadithCountInCorpus;

  const RawiBiographyRecord({
    required this.id,
    required this.fullNameArabic,
    required this.esmShuhra,
    required this.kunia,
    required this.laqab,
    required this.nasab,
    required this.tabaqaNum,
    required this.tabaqaArabic,
    this.birthYearHijri,
    this.deathYearHijri,
    required this.livingCity,
    required this.martabaIbnHajar,
    required this.martabaDzahabi,
    this.isMudallis = false,
    this.isMukhtalith = false,
    this.shyoukhIds = const [],
    this.talamizIds = const [],
    this.jarhTadilStatements = const [],
    this.totalHadithCountInCorpus = 0,
  });
}

/// Simpul (node) pada pohon sanad terpadu (*Tasyjīr al-Asānīd*).
class SanadGraphNode {
  final String rawiId;
  final String arabicName;
  final String tabaqaLabel;
  final String martabaSummary;
  final int layerDepth; // 0 = Rawi A'la (Sahabat), meningkat ke bawah hingga Mushannif
  final bool isRawiAla;
  final bool isPrimaryMadar;
  final bool isSecondaryMadar;
  final bool isMushannif;
  final int branchingOutDegree;

  const SanadGraphNode({
    required this.rawiId,
    required this.arabicName,
    required this.tabaqaLabel,
    required this.martabaSummary,
    required this.layerDepth,
    this.isRawiAla = false,
    this.isPrimaryMadar = false,
    this.isSecondaryMadar = false,
    this.isMushannif = false,
    this.branchingOutDegree = 1,
  });
}

/// Tepi (edge) transmisi antara guru dan murid dalam pohon sanad.
class SanadGraphEdge {
  final String teacherRawiId;
  final String studentRawiId;
  final String sighahTahdits;
  final SanadLinkStatus linkStatus;
  final bool hasIkhtilafOnMadar;
  final List<String> supportingBookTitles;

  const SanadGraphEdge({
    required this.teacherRawiId,
    required this.studentRawiId,
    required this.sighahTahdits,
    required this.linkStatus,
    this.hasIkhtilafOnMadar = false,
    this.supportingBookTitles = const [],
  });
}

/// Hukum ulama atas hadis (`HadithScientestsJudge` / `AutoDegreeSays`).
class ScholarHadithJudgment {
  final String scholarArabicName;
  final int scholarDeathYearHijri;
  final String judgmentArabicText;
  final String sourceBookArabic;
  final bool appliesToSpecificChainOnly;

  const ScholarHadithJudgment({
    required this.scholarArabicName,
    required this.scholarDeathYearHijri,
    required this.judgmentArabicText,
    required this.sourceBookArabic,
    this.appliesToSpecificChainOnly = false,
  });
}

/// Laporan otomatis analisis pohon sanad, madar, dan 'ilal (`AsaneedReport.dll`).
class MadarAndIlalReport {
  final List<SanadGraphNode> nodes;
  final List<SanadGraphEdge> edges;
  final SanadGraphNode? rawiAla;
  final SanadGraphNode? primaryMadar;
  final List<SanadGraphNode> secondaryMadars;
  final bool hasIkhtilafAlaMadar;
  final String automatedArabicReport;
  final String automatedIndonesianSummary;
  final List<ScholarHadithJudgment> scholarJudgments;

  const MadarAndIlalReport({
    required this.nodes,
    required this.edges,
    this.rawiAla,
    this.primaryMadar,
    this.secondaryMadars = const [],
    this.hasIkhtilafAlaMadar = false,
    required this.automatedArabicReport,
    required this.automatedIndonesianSummary,
    this.scholarJudgments = const [],
  });
}

/// Segmen kata dalam Al-Matn al-Mujamma' (`<MMMainHadith>` & `<MMHit>`).
class MujammaSegment {
  final String arabicText;
  final bool isZawaidInsertion;
  final bool isSeparateRiwaiyahVariant; // [وفي رواية: ...]
  final int? footnoteIndex;
  final List<String> sourceCitations;

  const MujammaSegment({
    required this.arabicText,
    this.isZawaidInsertion = false,
    this.isSeparateRiwaiyahVariant = false,
    this.footnoteIndex,
    this.sourceCitations = const [],
  });
}

/// Representasi utuh Al-Matn al-Mujamma' (Matan Komposit).
class MujammaCompositeMatn {
  final CanonicalHadithRecord baseHadith;
  final HadithBookMetadata baseBook;
  final List<MujammaSegment> segments;

  const MujammaCompositeMatn({
    required this.baseHadith,
    required this.baseBook,
    required this.segments,
  });
}

/// Rujukan kitab khadami (syarah, gharib, takhrij, musykil, nasikh-mansukh).
class ServiceBookReference {
  final String bookTitleArabic;
  final String authorArabic;
  final String categoryLabel; // شرح الحديث / غريب الحديث / تخريج وعلل / مختلف الحديث
  final int partNumber;
  final int pageNumber;
  final String excerptArabic;

  const ServiceBookReference({
    required this.bookTitleArabic,
    required this.authorArabic,
    required this.categoryLabel,
    required this.partNumber,
    required this.pageNumber,
    required this.excerptArabic,
  });
}

/// Hasil lengkap satu sesi takhrij lintas ribuan kitab.
class TakhrijClusterResult {
  final CanonicalHadithRecord originHadith;
  final HadithBookMetadata originBook;
  final List<MatnComparisonOutcome> takhrijOutcomes; // Ittihad al-Rawi al-A'la
  final List<MatnComparisonOutcome> syawahidOutcomes; // Lintas Sahabat (Jami' al-Matn)
  final MujammaCompositeMatn mujammaMatn;
  final MadarAndIlalReport madarReport;
  final List<ServiceBookReference> serviceReferences;
  final String formattedFullTakhrijArabicParagraph;

  const TakhrijClusterResult({
    required this.originHadith,
    required this.originBook,
    required this.takhrijOutcomes,
    required this.syawahidOutcomes,
    required this.mujammaMatn,
    required this.madarReport,
    required this.serviceReferences,
    required this.formattedFullTakhrijArabicParagraph,
  });
}

/// Hasil pemindaian satu kutipan hadis pada fitur Takhrij Otomatis Makalah (`DocXSL.xsl`).
class ManuscriptHadithDetection {
  final int indexInManuscript;
  final String detectedQuoteArabic;
  final TakhrijClusterResult? matchedCluster;
  final String generatedFootnoteArabic;

  const ManuscriptHadithDetection({
    required this.indexInManuscript,
    required this.detectedQuoteArabic,
    this.matchedCluster,
    required this.generatedFootnoteArabic,
  });
}
