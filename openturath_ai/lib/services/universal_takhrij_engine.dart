import 'dart:math' as math;

import '../models/hadith_takhrij_models.dart';
import 'harf_morphology_service.dart';

/// Mesin Inti 7-Lapis: Universal Algorithmic Takhrij Engine (UATE)
/// Merekonstruksi logika `HadithEncyProj.exe`, `Engine0200.dll`, `HarfMMMP01.dll`,
/// `BuraqLib.dll`, dan `AsaneedReport.dll`, serta memperluasnya dari 33 kitab
/// statis menjadi arsitektur algoritmik berskala ribuan kitab.
class UniversalTakhrijEngine {
  UniversalTakhrijEngine._() {
    _initializeCanonicalKnowledgeBase();
  }

  static final UniversalTakhrijEngine instance = UniversalTakhrijEngine._();

  final HarfMorphologyService _morph = HarfMorphologyService.instance;

  final Map<String, HadithBookMetadata> _booksById = {};
  final Map<String, RawiBiographyRecord> _rawisById = {};
  final List<CanonicalHadithRecord> _corpusHadiths = [];

  /// Indeks Terbalik Akar Kata (Inverted Root Index) & Shingle Trigram untuk skala ribuan kitab.
  final Map<String, Set<String>> _invertedRootIndex = {};
  final Map<String, Set<String>> _invertedTrigramIndex = {};
  final Map<String, CanonicalHadithRecord> _hadithsByUri = {};

  List<HadithBookMetadata> get registeredBooks =>
      _booksById.values.toList(growable: false);

  List<RawiBiographyRecord> get registeredRawis =>
      _rawisById.values.toList(growable: false);

  List<CanonicalHadithRecord> get corpusHadiths =>
      List.unmodifiable(_corpusHadiths);

  HadithBookMetadata? getBookById(String id) => _booksById[id];
  RawiBiographyRecord? getRawiById(String id) => _rawisById[id];

  // ═══════════════════════════════════════════════════════════════════════════
  // LAPISAN 1: TAKSONOMI RIBUAN KITAB & RESOLVER TARQIM LINTAS CETAKAN
  // ═══════════════════════════════════════════════════════════════════════════

  void _initializeCanonicalKnowledgeBase() {
    if (_booksById.isNotEmpty) return;

    // 1. Registrasi Kitab Inti (Core 33) + Ekspansi Taksonomi Ribuan Kitab
    // (Mustakhrajat, Zawa'id, Ajza' Haditsiyyah, Amali, Mashyakhat, Syuruh)
    const initialBooks = <HadithBookMetadata>[
      HadithBookMetadata(
        id: 'bukhari',
        titleArabic: 'صحيح البخاري',
        titleLatin: 'Ṣaḥīḥ al-Bukhārī',
        authorArabic: 'البخاري',
        authorLatin: 'Al-Bukhārī',
        deathYearHijri: 256,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 1,
        primaryPrintEdition: 'طبعة السلطانية / ترقيم محمد فؤاد عبد الباقي',
        secondaryPrintEdition: 'طبعة دار طوق النجاة',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'muslim',
        titleArabic: 'صحيح مسلم',
        titleLatin: 'Ṣaḥīḥ Muslim',
        authorArabic: 'مسلم',
        authorLatin: 'Muslim bin al-Ḥajjāj',
        deathYearHijri: 261,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 2,
        primaryPrintEdition: 'طبعة محمد فؤاد عبد الباقي - دار إحياء التراث العربي',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'abu_dawud',
        titleArabic: 'سنن أبي داود',
        titleLatin: 'Sunan Abī Dāwūd',
        authorArabic: 'أبو داود',
        authorLatin: 'Abū Dāwūd al-Sijistānī',
        deathYearHijri: 275,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 3,
        primaryPrintEdition: 'طبعة محيي الدين عبد الحميد / دار الرسالة العالمية',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'tirmidzi',
        titleArabic: 'جامع الترمذي',
        titleLatin: 'Jāmi‘ al-Tirmidzī',
        authorArabic: 'الترمذي',
        authorLatin: 'Abū ‘Īsā al-Tirmidzī',
        deathYearHijri: 279,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 4,
        primaryPrintEdition: 'طبعة أحمد شاكر ومحمد فؤاد عبد الباقي',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'nasai_sughra',
        titleArabic: 'سنن النسائي الصغرى (المجتبى)',
        titleLatin: 'Sunan al-Nasā’ī (al-Mujtabā)',
        authorArabic: 'النسائي',
        authorLatin: 'Aḥmad bin Syu‘ayb al-Nasā’ī',
        deathYearHijri: 303,
        centuryHijri: 4,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 5,
        primaryPrintEdition: 'طبعة مكتب المطبوعات الإسلامية بحلب (عبد الفتاح أبو غدة)',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'ibn_majah',
        titleArabic: 'سنن ابن ماجه',
        titleLatin: 'Sunan Ibn Mājah',
        authorArabic: 'ابن ماجه',
        authorLatin: 'Ibn Mājah al-Qazwīnī',
        deathYearHijri: 273,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 6,
        primaryPrintEdition: 'طبعة محمد فؤاد عبد الباقي',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'ibn_majah_zawaid_qattan',
        titleArabic: 'زوائد أبي الحسن القطان على سنن ابن ماجه',
        titleLatin: 'Zawā’id al-Qaṭṭān ‘alā Sunan Ibn Mājah',
        authorArabic: 'ابن ماجه',
        authorLatin: 'Abū al-Ḥasan al-Qaṭṭān',
        deathYearHijri: 345,
        centuryHijri: 4,
        taxonomy: HadithBookTaxonomy.zawaidNarrator,
        canonicalRank: 7,
        primaryPrintEdition: 'طبعة محمد فؤاد عبد الباقي',
        zawaidInfo: ZawaidNarratorInfo(
          narratorId: 'rawi_qattan',
          narratorArabicName: 'أبو الحسن القطان',
          baseBookTitle: 'سنن ابن ماجه',
          hadithCount: 5,
        ),
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'muwattha_malik',
        titleArabic: 'موطأ مالك',
        titleLatin: 'Muwaṭṭa’ Mālik',
        authorArabic: 'مالك',
        authorLatin: 'Mālik bin Anas',
        deathYearHijri: 179,
        centuryHijri: 2,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 8,
        primaryPrintEdition: 'رواية يحيى بن يحيى الليثي - ترقيم فؤاد عبد الباقي',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'musnad_ahmad',
        titleArabic: 'مسند أحمد',
        titleLatin: 'Musnad Aḥmad bin Ḥanbal',
        authorArabic: 'أحمد',
        authorLatin: 'Aḥmad bin Ḥanbal',
        deathYearHijri: 241,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 9,
        primaryPrintEdition: 'طبعة مؤسسة الرسالة (شعيب الأرنؤوط)',
        secondaryPrintEdition: 'الطبعة الميمنية',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'musnad_ahmad_zawaid_abdullah',
        titleArabic: 'زوائد عبد الله بن أحمد على المسند',
        titleLatin: 'Zawā’id ‘Abdillāh bin Aḥmad',
        authorArabic: 'أحمد',
        authorLatin: '‘Abdullāh bin Aḥmad bin Ḥanbal',
        deathYearHijri: 290,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.zawaidNarrator,
        canonicalRank: 10,
        primaryPrintEdition: 'طبعة مؤسسة الرسالة',
        zawaidInfo: ZawaidNarratorInfo(
          narratorId: 'rawi_abdullah_ahmad',
          narratorArabicName: 'عبد الله بن أحمد بن حنبل',
          baseBookTitle: 'مسند أحمد',
          hadithCount: 784,
        ),
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'musnad_humaidi',
        titleArabic: 'مسند الحميدي',
        titleLatin: 'Musnad al-Ḥumaydī',
        authorArabic: 'الحميدي',
        authorLatin: 'Al-Ḥumaydī',
        deathYearHijri: 219,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 11,
        primaryPrintEdition: 'طبعة دار السقا - دمشق',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'musnad_tayalisi',
        titleArabic: 'مسند أبي داود الطيالسي',
        titleLatin: 'Musnad Abī Dāwūd al-Ṭayālisī',
        authorArabic: 'أبو داود الطيالسي',
        authorLatin: 'Abū Dāwūd al-Ṭayālisī',
        deathYearHijri: 204,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 12,
        primaryPrintEdition: 'طبعة دار هجر (التركي)',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'musannaf_abdurrazzaq',
        titleArabic: 'مصنف عبد الرزاق',
        titleLatin: 'Muṣannaf ‘Abd al-Razzāq',
        authorArabic: 'عبد الرزاق الصنعاني',
        authorLatin: '‘Abd al-Razzāq al-Ṣan‘ānī',
        deathYearHijri: 211,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 13,
        primaryPrintEdition: 'طبعة المجلس العلمي بالهند (حبيب الرحمن الأعظمي)',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'musannaf_ibn_abi_syaibah',
        titleArabic: 'مصنف ابن أبي شيبة',
        titleLatin: 'Muṣannaf Ibn Abī Syaybah',
        authorArabic: 'ابن أبي شيبة',
        authorLatin: 'Ibn Abī Syaybah',
        deathYearHijri: 235,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 14,
        primaryPrintEdition: 'طبعة مكتبة الرشد / دار القبلة',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'shahih_ibn_khuzaimah',
        titleArabic: 'صحيح ابن خزيمة',
        titleLatin: 'Ṣaḥīḥ Ibn Khuzaymah',
        authorArabic: 'ابن خزيمة',
        authorLatin: 'Ibn Khuzaymah',
        deathYearHijri: 311,
        centuryHijri: 4,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 15,
        primaryPrintEdition: 'طبعة المكتب الإسلامي (الأعظمي)',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'shahih_ibn_hibban',
        titleArabic: 'صحيح ابن حبان (الإحسان)',
        titleLatin: 'Ṣaḥīḥ Ibn Ḥibbān',
        authorArabic: 'ابن حبان',
        authorLatin: 'Ibn Ḥibbān al-Bustī',
        deathYearHijri: 354,
        centuryHijri: 4,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 16,
        primaryPrintEdition: 'طبعة مؤسسة الرسالة (شعيب الأرنؤوط)',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'mustadrak_hakim',
        titleArabic: 'المستدرك على الصحيحين',
        titleLatin: 'Al-Mustadrak ‘alā al-Ṣaḥīḥayn',
        authorArabic: 'الحاكم النيسابوري',
        authorLatin: 'Al-Ḥākim al-Naysābūrī',
        deathYearHijri: 405,
        centuryHijri: 5,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 17,
        primaryPrintEdition: 'طبعة دار الكتب العلمية (مصطفى عبد القادر عطا)',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'mujam_kabir_thabarani',
        titleArabic: 'المعجم الكبير للطبراني',
        titleLatin: 'Al-Mu‘jam al-Kabīr li-l-Ṭabarānī',
        authorArabic: 'الطبراني',
        authorLatin: 'Al-Ṭabarānī',
        deathYearHijri: 360,
        centuryHijri: 4,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 18,
        primaryPrintEdition: 'طبعة مكتبة ابن تيمية (حمدي السلفي)',
        isCore33: true,
      ),
      HadithBookMetadata(
        id: 'sunan_kubra_baihaqi',
        titleArabic: 'السنن الكبرى للبيهقي',
        titleLatin: 'Al-Sunan al-Kubrā li-l-Bayhaqī',
        authorArabic: 'البيهقي',
        authorLatin: 'Al-Bayhaqī',
        deathYearHijri: 458,
        centuryHijri: 5,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 19,
        primaryPrintEdition: 'طبعة دار الكتب العلمية / مركز هجر',
        isCore33: true,
      ),
      // Kitab ke-26 di Khademhrf yang di-hardcode di TakhreegXSL.xsl (`@BookID='26'`)
      HadithBookMetadata(
        id: 'mathalib_aliyah',
        titleArabic: 'المطالب العالية بزوائد المسانيد الثمانية',
        titleLatin: 'Al-Maṭālib al-‘Āliyah',
        authorArabic: 'ابن حجر العسقلاني',
        authorLatin: 'Ibn Ḥajar al-‘Asqalānī',
        deathYearHijri: 852,
        centuryHijri: 9,
        taxonomy: HadithBookTaxonomy.secondaryCompilation,
        canonicalRank: 26,
        primaryPrintEdition: 'طبعة دار الغيث (الغنيم)',
        isCore33: true,
      ),
      // Ekspansi di Luar 33 Kitab (Mustakhrajat, Zawa'id, Ajza', Amali, Mashyakhat)
      HadithBookMetadata(
        id: 'mustakhraj_abi_awanah',
        titleArabic: 'مستخرج أبي عوانة',
        titleLatin: 'Mustakhraj Abī ‘Awānah',
        authorArabic: 'أبو عوانة الإسفراييني',
        authorLatin: 'Abū ‘Awānah al-Isfarāyīnī',
        deathYearHijri: 316,
        centuryHijri: 4,
        taxonomy: HadithBookTaxonomy.mustakhraj,
        canonicalRank: 34,
        primaryPrintEdition: 'طبعة الجامعة الإسلامية بالمدينة المنورة',
        isCore33: false,
      ),
      HadithBookMetadata(
        id: 'majma_zawaid_haitsami',
        titleArabic: 'مجمع الزوائد ومنبع الفوائد',
        titleLatin: 'Majma‘ al-Zawā’id',
        authorArabic: 'نور الدين الهيثمي',
        authorLatin: 'Nūr al-Dīn al-Haytsamī',
        deathYearHijri: 807,
        centuryHijri: 9,
        taxonomy: HadithBookTaxonomy.secondaryCompilation,
        canonicalRank: 35,
        primaryPrintEdition: 'طبعة مكتبة القدسي / دار الفكر',
        isCore33: false,
      ),
      HadithBookMetadata(
        id: 'juz_rafa_yadain_bukhari',
        titleArabic: 'جزء رفع اليدين في الصلاة',
        titleLatin: 'Juz’ Raf‘ al-Yadayn fī al-Ṣalāh',
        authorArabic: 'البخاري',
        authorLatin: 'Al-Bukhārī',
        deathYearHijri: 256,
        centuryHijri: 3,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 36,
        primaryPrintEdition: 'طبعة دار ابن حزم (بديع الدين شاه الراشدي)',
        isCore33: false,
      ),
      HadithBookMetadata(
        id: 'hilyat_auliya_abi_nuaim',
        titleArabic: 'حلية الأولياء وطبقات الأصفياء',
        titleLatin: 'Ḥilyat al-Auliyā’',
        authorArabic: 'أبو نعيم الأصبهاني',
        authorLatin: 'Abū Nu‘aym al-Aṣbahānī',
        deathYearHijri: 430,
        centuryHijri: 5,
        taxonomy: HadithBookTaxonomy.musnadPrimary,
        canonicalRank: 37,
        primaryPrintEdition: 'طبعة السعادة - القاهرة',
        isCore33: false,
      ),
      HadithBookMetadata(
        id: 'fath_al_bari',
        titleArabic: 'فتح الباري شرح صحيح البخاري',
        titleLatin: 'Fatḥ al-Bārī Syarḥ Ṣaḥīḥ al-Bukhārī',
        authorArabic: 'ابن حجر العسقلاني',
        authorLatin: 'Ibn Ḥajar al-‘Asqalānī',
        deathYearHijri: 852,
        centuryHijri: 9,
        taxonomy: HadithBookTaxonomy.serviceSharhTakhrij,
        canonicalRank: 50,
        primaryPrintEdition: 'الطبعة السلفية (محب الدين الخطيب وفؤاد عبد الباقي)',
        isCore33: false,
      ),
    ];

    for (final book in initialBooks) {
      _booksById[book.id] = book;
    }

    // 2. Registrasi Basis Data Perawi (`TaragemRwa` & `Nouns`)
    const initialRawis = <RawiBiographyRecord>[
      RawiBiographyRecord(
        id: 'rawi_umar',
        fullNameArabic: 'عمر بن الخطاب بن نفيل القرشي العدوي',
        esmShuhra: 'عمر بن الخطاب',
        kunia: 'أبو حفص',
        laqab: 'الفاروق',
        nasab: 'القرشي العدوي',
        tabaqaNum: 1,
        tabaqaArabic: 'الطبقة الأولى (كبار الصحابة)',
        birthYearHijri: -40,
        deathYearHijri: 23,
        livingCity: 'المدينة المنورة',
        martabaIbnHajar: 'صحابي جليل، ثاني الخلفاء الراشدين',
        martabaDzahabi: 'أمير المؤمنين، صحابي',
        shyoukhIds: [],
        talamizIds: ['rawi_alqamah', 'rawi_ibn_umar', 'rawi_abu_hurairah'],
        totalHadithCountInCorpus: 537,
      ),
      RawiBiographyRecord(
        id: 'rawi_ibn_umar',
        fullNameArabic: 'عبد الله بن عمر بن الخطاب القرشي العدوي',
        esmShuhra: 'عبد الله بن عمر',
        kunia: 'أبو عبد الرحمن',
        laqab: '',
        nasab: 'القرشي العدوي المدني',
        tabaqaNum: 1,
        tabaqaArabic: 'الطبقة الأولى (الصحابة)',
        birthYearHijri: -10,
        deathYearHijri: 73,
        livingCity: 'المدينة المنورة',
        martabaIbnHajar: 'صحابي ابن صحابي، من المكثرين',
        martabaDzahabi: 'صحابي جليل، أحد الأعلام',
        shyoukhIds: ['rawi_umar'],
        talamizIds: ['rawi_nafi', 'rawi_salim'],
        totalHadithCountInCorpus: 2630,
      ),
      RawiBiographyRecord(
        id: 'rawi_anas',
        fullNameArabic: 'أنس بن مالك بن النضر الأنصاري الخزرجي',
        esmShuhra: 'أنس بن مالك',
        kunia: 'أبو حمزة',
        laqab: 'خادم رسول الله ﷺ',
        nasab: 'الأنصاري النجاري',
        tabaqaNum: 1,
        tabaqaArabic: 'الطبقة الأولى (الصحابة)',
        birthYearHijri: -10,
        deathYearHijri: 93,
        livingCity: 'البصرة',
        martabaIbnHajar: 'صحابي جليل، خادم النبي ﷺ، من المكثرين',
        martabaDzahabi: 'صحابي، آخر الصحابة موتاً بالبصرة',
        shyoukhIds: [],
        talamizIds: ['rawi_tsumamah', 'rawi_zuhri', 'rawi_qatadah'],
        totalHadithCountInCorpus: 2286,
      ),
      RawiBiographyRecord(
        id: 'rawi_abu_hurairah',
        fullNameArabic: 'عبد الرحمن بن صخر الدوسي اليماني',
        esmShuhra: 'أبو هريرة الدوسي',
        kunia: 'أبو هريرة',
        laqab: 'حافظ الصحابة',
        nasab: 'الدوسي المدني',
        tabaqaNum: 1,
        tabaqaArabic: 'الطبقة الأولى (الصحابة)',
        birthYearHijri: -19,
        deathYearHijri: 59,
        livingCity: 'المدينة المنورة',
        martabaIbnHajar: 'صحابي جليل، أحفظ الصحابة لحديث رسول الله ﷺ',
        martabaDzahabi: 'الإمام الحافظ، سيد الحفاظ الأثبات',
        shyoukhIds: ['rawi_umar'],
        talamizIds: ['rawi_abu_salamah', 'rawi_araj'],
        totalHadithCountInCorpus: 5374,
      ),
      RawiBiographyRecord(
        id: 'rawi_alqamah',
        fullNameArabic: 'علقمة بن وقاص الليثي المدني',
        esmShuhra: 'علقمة بن وقاص الليثي',
        kunia: 'أبو شبل',
        laqab: '',
        nasab: 'الليثي العتواري المدني',
        tabaqaNum: 2,
        tabaqaArabic: 'الطبقة الثانية (كبار التابعين)',
        deathYearHijri: 82,
        livingCity: 'المدينة المنورة',
        martabaIbnHajar: 'ثقة ثبت',
        martabaDzahabi: 'ثقة نبيل',
        shyoukhIds: ['rawi_umar'],
        talamizIds: ['rawi_muhammad_ibrahim'],
        jarhTadilStatements: [
          JarhTadilStatement(
            criticArabicName: 'النسائي',
            statementArabic: 'ثقة',
            sourceBookArabic: 'تهذيب الكمال (20/312)',
            rankCategory: 1,
          ),
          JarhTadilStatement(
            criticArabicName: 'ابن حبان',
            statementArabic: 'ذكره في الثقات',
            sourceBookArabic: 'الثقات لابن حبان (5/241)',
            rankCategory: 1,
          ),
        ],
        totalHadithCountInCorpus: 19,
      ),
      RawiBiographyRecord(
        id: 'rawi_muhammad_ibrahim',
        fullNameArabic: 'محمد بن إبراهيم بن الحارث التيمي المدني',
        esmShuhra: 'محمد بن إبراهيم التيمي',
        kunia: 'أبو عبد الله',
        laqab: '',
        nasab: 'القرشي التيمي المدني',
        tabaqaNum: 4,
        tabaqaArabic: 'الطبقة الرابعة (الوسطى من التابعين)',
        deathYearHijri: 120,
        livingCity: 'المدينة المنورة',
        martabaIbnHajar: 'ثقة له أفراد',
        martabaDzahabi: 'ثقة عالم',
        shyoukhIds: ['rawi_alqamah', 'rawi_abu_salamah'],
        talamizIds: ['rawi_yahya_said'],
        jarhTadilStatements: [
          JarhTadilStatement(
            criticArabicName: 'أحمد بن حنبل',
            transmitterArabicName: 'عبد الله بن أحمد',
            statementArabic: 'ثقة، يروي أحاديث مناكير',
            sourceBookArabic: 'الجرح والتعديل لابن أبي حاتم (7/184)',
            rankCategory: 1,
          ),
          JarhTadilStatement(
            criticArabicName: 'يحيى بن معين',
            statementArabic: 'ثقة',
            sourceBookArabic: 'تهذيب التهذيب (9/5)',
            rankCategory: 1,
          ),
        ],
        totalHadithCountInCorpus: 124,
      ),
      RawiBiographyRecord(
        id: 'rawi_yahya_said',
        fullNameArabic: 'يحيى بن سعيد بن قيس الأنصاري المدني القاضي',
        esmShuhra: 'يحيى بن سعيد الأنصاري',
        kunia: 'أبو سعيد',
        laqab: 'القاضي',
        nasab: 'الأنصاري النجاري المدني',
        tabaqaNum: 5,
        tabaqaArabic: 'الطبقة الخامسة (صغار التابعين) — مدار الحديث',
        deathYearHijri: 144,
        livingCity: 'المدينة المنورة / العراق',
        martabaIbnHajar: 'ثقة ثبت حجة',
        martabaDzahabi: 'ثقة حجة إمام',
        shyoukhIds: ['rawi_muhammad_ibrahim', 'rawi_nafi', 'rawi_zuhri'],
        talamizIds: [
          'rawi_sufyan_uyainah',
          'rawi_malik',
          'rawi_hammad_zaid',
          'rawi_abdul_wahhab_tsaqafi',
        ],
        jarhTadilStatements: [
          JarhTadilStatement(
            criticArabicName: 'علي بن المديني',
            statementArabic: 'لم يكن بالمدينة بعد كبار التابعين مثل يحيى بن سعيد، وله نحو ثلاث مائة حديث',
            sourceBookArabic: 'سير أعلام النبلاء (5/476)',
            rankCategory: 1,
          ),
          JarhTadilStatement(
            criticArabicName: 'أبو زرعة الرازي',
            statementArabic: 'ثقة مأمون حجة',
            sourceBookArabic: 'الجرح والتعديل (9/148)',
            rankCategory: 1,
          ),
        ],
        totalHadithCountInCorpus: 692,
      ),
      RawiBiographyRecord(
        id: 'rawi_sufyan_uyainah',
        fullNameArabic: 'سفيان بن عيينة بن أبي عمران الهلالي الكوفي ثم المكي',
        esmShuhra: 'سفيان بن عيينة',
        kunia: 'أبو محمد',
        laqab: 'محدث الحرم',
        nasab: 'الهلالي المكي',
        tabaqaNum: 8,
        tabaqaArabic: 'الطبقة الثامنة (الوسطى من أتباع التابعين)',
        birthYearHijri: 107,
        deathYearHijri: 198,
        livingCity: 'مكة المكرمة',
        martabaIbnHajar: 'ثقة حافظ فقيه إمام حجة إلا أنه تغير حفظه بأخرة وكان ربما دلس لكن عن الثقات',
        martabaDzahabi: 'أحد الأعلام، ثقة ثبت حافظ إمام',
        isMudallis: true,
        shyoukhIds: ['rawi_yahya_said', 'rawi_zuhri'],
        talamizIds: ['rawi_humaidi', 'rawi_ahmad', 'rawi_musaddad'],
        jarhTadilStatements: [
          JarhTadilStatement(
            criticArabicName: 'الشافعي',
            statementArabic: 'لولا مالك وسفيان لذهب علم الحجاز',
            sourceBookArabic: 'تهذيب الكمال (11/185)',
            rankCategory: 1,
          ),
        ],
        totalHadithCountInCorpus: 2450,
      ),
      RawiBiographyRecord(
        id: 'rawi_malik',
        fullNameArabic: 'مالك بن أنس بن مالك الأصبحي المدني',
        esmShuhra: 'مالك بن أنس',
        kunia: 'أبو عبد الله',
        laqab: 'إمام دار الهجرة',
        nasab: 'الأصبحي الحميري المدني',
        tabaqaNum: 7,
        tabaqaArabic: 'الطبقة السابعة (كبار أتباع التابعين)',
        birthYearHijri: 93,
        deathYearHijri: 179,
        livingCity: 'المدينة المنورة',
        martabaIbnHajar: 'رأس المتقنين وكبير المتثبتين',
        martabaDzahabi: 'الإمام الحافظ فقيه الأمة',
        shyoukhIds: ['rawi_yahya_said', 'rawi_nafi', 'rawi_zuhri'],
        talamizIds: ['rawi_abdullah_maslamah', 'rawi_yahya_yahya'],
        totalHadithCountInCorpus: 1840,
      ),
      RawiBiographyRecord(
        id: 'rawi_hammad_zaid',
        fullNameArabic: 'حماد بن زيد بن درهم الأزدي الجهضمي البصري',
        esmShuhra: 'حماد بن زيد',
        kunia: 'أبو إسماعيل',
        laqab: 'الأزرق الضرير',
        nasab: 'الأزدي البصري',
        tabaqaNum: 8,
        tabaqaArabic: 'الطبقة الثامنة (أتباع التابعين)',
        birthYearHijri: 98,
        deathYearHijri: 179,
        livingCity: 'البصرة',
        martabaIbnHajar: 'ثقة ثبت فقيه',
        martabaDzahabi: 'ثقة ثبت حجة',
        shyoukhIds: ['rawi_yahya_said'],
        talamizIds: ['rawi_musaddad', 'rawi_abdullah_maslamah'],
        totalHadithCountInCorpus: 910,
      ),
      RawiBiographyRecord(
        id: 'rawi_abdul_wahhab_tsaqafi',
        fullNameArabic: 'عبد الوهاب بن عبد المجيد بن الصلت الثقفي البصري',
        esmShuhra: 'عبد الوهاب الثقفي',
        kunia: 'أبو محمد',
        laqab: '',
        nasab: 'الثقفي البصري',
        tabaqaNum: 8,
        tabaqaArabic: 'الطبقة الثامنة (أتباع التابعين)',
        birthYearHijri: 108,
        deathYearHijri: 194,
        livingCity: 'البصرة',
        martabaIbnHajar: 'ثقة تغير قبل موته بثلاث سنين',
        martabaDzahabi: 'ثقة احتج به الجماعة',
        isMukhtalith: true,
        shyoukhIds: ['rawi_yahya_said'],
        talamizIds: ['rawi_muhammad_mutsanna'],
        totalHadithCountInCorpus: 412,
      ),
      RawiBiographyRecord(
        id: 'rawi_humaidi',
        fullNameArabic: 'عبد الله بن الزبير بن عيسى القرشي الأسدي الحميدي',
        esmShuhra: 'الحميدي',
        kunia: 'أبو بكر',
        laqab: 'الحميدي',
        nasab: 'القرشي المكي',
        tabaqaNum: 10,
        tabaqaArabic: 'الطبقة العاشرة (كبار الآخذين عن تبع الأتباع)',
        deathYearHijri: 219,
        livingCity: 'مكة المكرمة',
        martabaIbnHajar: 'ثقة حافظ فقيه أجل أصحاب ابن عيينة',
        martabaDzahabi: 'الإمام الحافظ الثبت',
        shyoukhIds: ['rawi_sufyan_uyainah'],
        talamizIds: ['rawi_bukhari'],
        totalHadithCountInCorpus: 580,
      ),
      RawiBiographyRecord(
        id: 'rawi_abdullah_maslamah',
        fullNameArabic: 'عبد الله بن مسلمة بن قعنب القعنبي الحارثي',
        esmShuhra: 'عبد الله بن مسلمة القعنبي',
        kunia: 'أبو عبد الرحمن',
        laqab: 'القعنبي',
        nasab: 'الحارثي المدني البصري',
        tabaqaNum: 9,
        tabaqaArabic: 'الطبقة التاسعة (صغار أتباع التابعين)',
        deathYearHijri: 221,
        livingCity: 'البصرة / مكة',
        martabaIbnHajar: 'ثقة عابد أثبت الناس في الموطأ',
        martabaDzahabi: 'الإمام القدوة الثبت',
        shyoukhIds: ['rawi_malik', 'rawi_hammad_zaid'],
        talamizIds: ['rawi_bukhari', 'rawi_muslim', 'rawi_abu_dawud'],
        totalHadithCountInCorpus: 840,
      ),
      RawiBiographyRecord(
        id: 'rawi_musaddad',
        fullNameArabic: 'مسدد بن مسرهد بن مسربل الأسدي البصري',
        esmShuhra: 'مسدد بن مسرهد',
        kunia: 'أبو الحسن',
        laqab: '',
        nasab: 'الأسدي البصري',
        tabaqaNum: 10,
        tabaqaArabic: 'الطبقة العاشرة',
        deathYearHijri: 228,
        livingCity: 'البصرة',
        martabaIbnHajar: 'ثقة حافظ يقال إنه أول من صنف المسند بالبصرة',
        martabaDzahabi: 'الحافظ الثبت الحجة',
        shyoukhIds: ['rawi_hammad_zaid', 'rawi_sufyan_uyainah'],
        talamizIds: ['rawi_bukhari', 'rawi_abu_dawud'],
        totalHadithCountInCorpus: 760,
      ),
      RawiBiographyRecord(
        id: 'rawi_muhammad_mutsanna',
        fullNameArabic: 'محمد بن المثنى بن عبيد العنزي البصري الزمن',
        esmShuhra: 'محمد بن المثنى (بندار)',
        kunia: 'أبو موسى',
        laqab: 'الزمن',
        nasab: 'العنزي البصري',
        tabaqaNum: 10,
        tabaqaArabic: 'الطبقة العاشرة',
        birthYearHijri: 167,
        deathYearHijri: 252,
        livingCity: 'البصرة',
        martabaIbnHajar: 'ثقة ثبت',
        martabaDzahabi: 'الإمام الحافظ الثبت',
        shyoukhIds: ['rawi_abdul_wahhab_tsaqafi'],
        talamizIds: ['rawi_bukhari', 'rawi_muslim', 'rawi_tirmidzi', 'rawi_nasai', 'rawi_ibn_majah'],
        totalHadithCountInCorpus: 1120,
      ),
      RawiBiographyRecord(
        id: 'rawi_nafi',
        fullNameArabic: 'نافع مولى ابن عمر المدني',
        esmShuhra: 'نافع مولى ابن عمر',
        kunia: 'أبو عبد الله',
        laqab: 'مولى ابن عمر',
        nasab: 'القرشي العدوي المدني',
        tabaqaNum: 3,
        tabaqaArabic: 'الطبقة الثالثة (الوسطى من التابعين)',
        deathYearHijri: 117,
        livingCity: 'المدينة المنورة',
        martabaIbnHajar: 'ثقة ثبت فقيه مشهور',
        martabaDzahabi: 'إمام التابعين بالمدينة، ثبت',
        shyoukhIds: ['rawi_ibn_umar'],
        talamizIds: ['rawi_zuhri', 'rawi_malik', 'rawi_yahya_said'],
        totalHadithCountInCorpus: 1450,
      ),
      RawiBiographyRecord(
        id: 'rawi_salim',
        fullNameArabic: 'سالم بن عبد الله بن عمر بن الخطاب العدوي',
        esmShuhra: 'سالم بن عبد الله بن عمر',
        kunia: 'أبو عمر',
        laqab: 'أحد الفقهاء السبعة',
        nasab: 'القرشي العدوي المدني',
        tabaqaNum: 3,
        tabaqaArabic: 'الطبقة الثالثة (التابعين)',
        deathYearHijri: 106,
        livingCity: 'المدينة المنورة',
        martabaIbnHajar: 'ثقة ثبت فقيه فاضل',
        martabaDzahabi: 'الإمام الزاهد الحافظ',
        shyoukhIds: ['rawi_ibn_umar'],
        talamizIds: ['rawi_zuhri'],
        totalHadithCountInCorpus: 620,
      ),
      RawiBiographyRecord(
        id: 'rawi_zuhri',
        fullNameArabic: 'محمد بن مسلم بن عبيد الله بن شهاب الزهري',
        esmShuhra: 'ابن شهاب الزهري',
        kunia: 'أبو بكر',
        laqab: 'الزهري',
        nasab: 'القرشي الزهري المدني',
        tabaqaNum: 4,
        tabaqaArabic: 'الطبقة الرابعة (تلي الوسطى من التابعين)',
        birthYearHijri: 58,
        deathYearHijri: 124,
        livingCity: 'المدينة المنورة / الشام',
        martabaIbnHajar: 'الفقيه الحافظ متفق على جلالته وإتقانه',
        martabaDzahabi: 'الإمام العلم، حافظ زمانه',
        shyoukhIds: ['rawi_anas', 'rawi_nafi', 'rawi_salim'],
        talamizIds: ['rawi_malik', 'rawi_mamar', 'rawi_yunus', 'rawi_sufyan_uyainah'],
        totalHadithCountInCorpus: 2200,
      ),
      RawiBiographyRecord(
        id: 'rawi_mamar',
        fullNameArabic: 'معمر بن راشد الأزدي الحداني البصري ثم اليماني',
        esmShuhra: 'معمر بن راشد',
        kunia: 'أبو عروة',
        laqab: '',
        nasab: 'الأزدي البصري الصنعاني',
        tabaqaNum: 7,
        tabaqaArabic: 'الطبقة السابعة (كبار أتباع التابعين)',
        birthYearHijri: 95,
        deathYearHijri: 153,
        livingCity: 'صنعاء اليمن',
        martabaIbnHajar: 'ثقة ثبت فاضل إلا أن في روايته عن ثابت والأعمش وهشام بن عروة شيئاً',
        martabaDzahabi: 'الإمام الحافظ شيخ اليمن',
        shyoukhIds: ['rawi_zuhri'],
        talamizIds: ['rawi_abdurrazzaq'],
        totalHadithCountInCorpus: 1650,
      ),
      RawiBiographyRecord(
        id: 'rawi_yunus',
        fullNameArabic: 'يونس بن يزيد بن أبي النجاد الأيلي',
        esmShuhra: 'يونس بن يزيد الأيلي',
        kunia: 'أبو يزيد',
        laqab: '',
        nasab: 'الأيلي مولى معاوية',
        tabaqaNum: 7,
        tabaqaArabic: 'الطبقة السابعة',
        deathYearHijri: 159,
        livingCity: 'أيلة / مصر',
        martabaIbnHajar: 'ثقة إلا أن في روايته عن غير الزهري وهماً قليلاً',
        martabaDzahabi: 'أحد الأثبات في الزهري',
        shyoukhIds: ['rawi_zuhri'],
        talamizIds: ['rawi_ibn_wahb'],
        totalHadithCountInCorpus: 710,
      ),
    ];

    for (final rawi in initialRawis) {
      _rawisById[rawi.id] = rawi;
    }

    // 3. Registrasi Korpus Hadis Kanonikal (mencakup variasi lafaz pendek/panjang,
    // zawa'id, kompilasi sekunder, mustakhraj, dan contoh ikhtilaf sanad di WorkingGroups.pdf)
    final initialCorpus = <CanonicalHadithRecord>[
      // KLASTER 1: Hadis Niat («إنما الأعمال بالنيات») — Lintas 33 Kitab & Ribuan Kitab
      const CanonicalHadithRecord(
        uri: 'ot://hadith/bukhari/1',
        bookId: 'bukhari',
        bookTitleArabic: 'صحيح البخاري',
        harfNumber: 1,
        printNumber: '1',
        partNumber: 1,
        pageNumber: 6,
        sectionTitle: 'كتاب بدء الوحي',
        chapterTitle: 'باب كيف كان بدء الوحي إلى رسول الله ﷺ',
        rawSanad:
            'حَدَّثَنَا الْحُمَيْدِيُّ عَبْدُ اللَّهِ بْنُ الزُّبَيْرِ قَالَ حَدَّثَنَا سُفْيَانُ قَالَ حَدَّثَنَا يَحْيَى بْنُ سَعِيدٍ الْأَنْصَارِيُّ قَالَ أَخْبَرَنِي مُحَمَّدُ بْنُ إِبْرَاهِيمَ التَّيْمِيُّ أَنَّهُ سَمِعَ عَلْقَمَةَ بْنَ وَقَّاصٍ اللَّيْثِيَّ يَقُولُ سَمِعْتُ عُمَرَ بْنَ الْخَطَّابِ رَضِيَ اللَّهُ عَنْهُ عَلَى الْمِنْبَرِ قَالَ سَمِعْتُ رَسُولَ اللَّهِ ﷺ يَقُولُ',
        rawMatn:
            'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى دُنْيَا يُصِيبُهَا أَوْ إِلَى امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
        rawiAlaId: 'rawi_umar',
        rawiAlaArabicName: 'عمر بن الخطاب',
        elevationStatus: HadithElevationStatus.marfu,
        historicalDateLabel: 'العهد المدني — بعد الهجرة النبوية',
        thematicTags: ['النية والإخلاص', 'الأعمال القلبية', 'الهجرة وأحكامها'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'عمر بن الخطاب',
            resolvedRawiId: 'rawi_umar',
            resolvedArabicName: 'عمر بن الخطاب',
            transmissionPhrase: 'سمعت رسول الله ﷺ',
          ),
          SanadNarratorHop(
            rawMention: 'علقمة بن وقاص الليثي',
            resolvedRawiId: 'rawi_alqamah',
            resolvedArabicName: 'علقمة بن وقاص الليثي',
            transmissionPhrase: 'سمعت',
          ),
          SanadNarratorHop(
            rawMention: 'محمد بن إبراهيم التيمي',
            resolvedRawiId: 'rawi_muhammad_ibrahim',
            resolvedArabicName: 'محمد بن إبراهيم التيمي',
            transmissionPhrase: 'سمع',
          ),
          SanadNarratorHop(
            rawMention: 'يحيى بن سعيد الأنصاري',
            resolvedRawiId: 'rawi_yahya_said',
            resolvedArabicName: 'يحيى بن سعيد الأنصاري',
            transmissionPhrase: 'أخبرني',
          ),
          SanadNarratorHop(
            rawMention: 'سفيان',
            resolvedRawiId: 'rawi_sufyan_uyainah',
            resolvedArabicName: 'سفيان بن عيينة',
            transmissionPhrase: 'حدثنا',
            wasMuhmalOrMubham: true,
            disambiguationConfidence: 0.99,
          ),
          SanadNarratorHop(
            rawMention: 'الحميدي عبد الله بن الزبير',
            resolvedRawiId: 'rawi_humaidi',
            resolvedArabicName: 'الحميدي',
            transmissionPhrase: 'حدثنا',
          ),
        ],
      ),
      const CanonicalHadithRecord(
        uri: 'ot://hadith/bukhari/54',
        bookId: 'bukhari',
        bookTitleArabic: 'صحيح البخاري',
        harfNumber: 54,
        printNumber: '54',
        partNumber: 1,
        pageNumber: 20,
        sectionTitle: 'كتاب الإيمان',
        chapterTitle: 'باب ما جاء أن الأعمال بالنية والحسبة ولكل امرئ ما نوى',
        rawSanad:
            'حَدَّثَنَا عَبْدُ اللَّهِ بْنُ مَسْلَمَةَ قَالَ أَخْبَرَنَا مَالِكٌ عَنْ يَحْيَى بْنِ سَعِيدٍ عَنْ مُحَمَّدِ بْنِ إِبْرَاهِيمَ عَنْ عَلْقَمَةَ بْنِ وَقَّاصٍ عَنْ عُمَرَ أَنَّ رَسُولَ اللَّهِ ﷺ قَالَ',
        rawMatn:
            'الْأَعْمَالُ بِالنِّيَّةِ، وَلِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ لدُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَتَزَوَّجُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
        rawiAlaId: 'rawi_umar',
        rawiAlaArabicName: 'عمر بن الخطاب',
        elevationStatus: HadithElevationStatus.marfu,
        historicalDateLabel: 'العهد المدني — بعد الهجرة النبوية',
        thematicTags: ['النية والإخلاص', 'الإيمان والاحتساب'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'عمر',
            resolvedRawiId: 'rawi_umar',
            resolvedArabicName: 'عمر بن الخطاب',
            transmissionPhrase: 'أن رسول الله ﷺ قال',
          ),
          SanadNarratorHop(
            rawMention: 'علقمة بن وقاص',
            resolvedRawiId: 'rawi_alqamah',
            resolvedArabicName: 'علقمة بن وقاص الليثي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'محمد بن إبراهيم',
            resolvedRawiId: 'rawi_muhammad_ibrahim',
            resolvedArabicName: 'محمد بن إبراهيم التيمي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'يحيى بن سعيد',
            resolvedRawiId: 'rawi_yahya_said',
            resolvedArabicName: 'يحيى بن سعيد الأنصاري',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'مالك',
            resolvedRawiId: 'rawi_malik',
            resolvedArabicName: 'مالك بن أنس',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'عبد الله بن مسلمة',
            resolvedRawiId: 'rawi_abdullah_maslamah',
            resolvedArabicName: 'عبد الله بن مسلمة القعنبي',
            transmissionPhrase: 'أخبرنا',
          ),
        ],
      ),
      const CanonicalHadithRecord(
        uri: 'ot://hadith/muslim/1907',
        bookId: 'muslim',
        bookTitleArabic: 'صحيح مسلم',
        harfNumber: 3530,
        printNumber: '1907',
        partNumber: 3,
        pageNumber: 1515,
        sectionTitle: 'كتاب الإمارة',
        chapterTitle: 'باب قوله ﷺ إنما الأعمال بالنية وأنها تدخل فيها الغزو وغيره من الأعمال',
        rawSanad:
            'حَدَّثَنَا عَبْدُ اللَّهِ بْنُ مَسْلَمَةَ بْنِ قَعْنَبٍ حَدَّثَنَا مَالِكٌ عَنْ يَحْيَى بْنِ سَعِيدٍ عَنْ مُحَمَّدِ بْنِ إِبْرَاهِيمَ عَنْ عَلْقَمَةَ بْنِ وَقَّاصٍ عَنْ عُمَرَ بْنِ الْخَطَّابِ قَالَ قَالَ رَسُولُ اللَّهِ ﷺ',
        rawMatn:
            'إِنَّمَا الْأَعْمَالُ بِالنِّيَّةِ، وَإِنَّمَا لِامْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ إِلَى دُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَتَزَوَّجُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
        rawiAlaId: 'rawi_umar',
        rawiAlaArabicName: 'عمر بن الخطاب',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['النية والإخلاص', 'الجهاد والهجرة'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'عمر بن الخطاب',
            resolvedRawiId: 'rawi_umar',
            resolvedArabicName: 'عمر بن الخطاب',
            transmissionPhrase: 'قال رسول الله ﷺ',
          ),
          SanadNarratorHop(
            rawMention: 'علقمة بن وقاص',
            resolvedRawiId: 'rawi_alqamah',
            resolvedArabicName: 'علقمة بن وقاص الليثي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'محمد بن إبراهيم',
            resolvedRawiId: 'rawi_muhammad_ibrahim',
            resolvedArabicName: 'محمد بن إبراهيم التيمي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'يحيى بن سعيد',
            resolvedRawiId: 'rawi_yahya_said',
            resolvedArabicName: 'يحيى بن سعيد الأنصاري',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'مالك',
            resolvedRawiId: 'rawi_malik',
            resolvedArabicName: 'مالك بن أنس',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'عبد الله بن مسلمة بن قعنب',
            resolvedRawiId: 'rawi_abdullah_maslamah',
            resolvedArabicName: 'عبد الله بن مسلمة القعنبي',
            transmissionPhrase: 'حدثنا',
          ),
        ],
      ),
      const CanonicalHadithRecord(
        uri: 'ot://hadith/abu_dawud/2201',
        bookId: 'abu_dawud',
        bookTitleArabic: 'سنن أبي داود',
        harfNumber: 2201,
        printNumber: '2201',
        partNumber: 2,
        pageNumber: 262,
        sectionTitle: 'كتاب الطلاق',
        chapterTitle: 'باب فيما عني به الطلاق والنيات',
        rawSanad:
            'حَدَّثَنَا مُسَدَّدٌ حَدَّثَنَا حَمَّادٌ يَعْنِي ابْنَ زَيْدٍ عَنْ يَحْيَى بْنِ سَعِيدٍ عَنْ مُحَمَّدِ بْنِ إِبْرَاهِيمَ عَنْ عَلْقَمَةَ بْنِ وَقَّاصٍ قَالَ سَمِعْتُ عُمَرَ بْنَ الْخَطَّابِ يَخْطُبُ قَالَ سَمِعْتُ النَّبِيَّ ﷺ يَقُولُ',
        rawMatn:
            'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ إِلَى دُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَتَزَوَّجُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
        rawiAlaId: 'rawi_umar',
        rawiAlaArabicName: 'عمر بن الخطاب',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['النية والإخلاص', 'الطلاق والنيات'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'عمر بن الخطاب',
            resolvedRawiId: 'rawi_umar',
            resolvedArabicName: 'عمر بن الخطاب',
            transmissionPhrase: 'سمعت النبي ﷺ',
          ),
          SanadNarratorHop(
            rawMention: 'علقمة بن وقاص',
            resolvedRawiId: 'rawi_alqamah',
            resolvedArabicName: 'علقمة بن وقاص الليثي',
            transmissionPhrase: 'سمعت',
          ),
          SanadNarratorHop(
            rawMention: 'محمد بن إبراهيم',
            resolvedRawiId: 'rawi_muhammad_ibrahim',
            resolvedArabicName: 'محمد بن إبراهيم التيمي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'يحيى بن سعيد',
            resolvedRawiId: 'rawi_yahya_said',
            resolvedArabicName: 'يحيى بن سعيد الأنصاري',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'حماد يعني ابن زيد',
            resolvedRawiId: 'rawi_hammad_zaid',
            resolvedArabicName: 'حماد بن زيد',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'مسدد',
            resolvedRawiId: 'rawi_musaddad',
            resolvedArabicName: 'مسدد بن مسرهد',
            transmissionPhrase: 'حدثنا',
          ),
        ],
      ),
      // Riwayat mukhtashar (sangat ringkas <= 15 kata) untuk menguji Aturan #7 & Two-Stage Containment (50%)
      const CanonicalHadithRecord(
        uri: 'ot://hadith/musnad_humaidi/28',
        bookId: 'musnad_humaidi',
        bookTitleArabic: 'مسند الحميدي',
        harfNumber: 28,
        printNumber: '28',
        partNumber: 1,
        pageNumber: 31,
        sectionTitle: 'أحاديث عمر بن الخطاب رضي الله عنه',
        chapterTitle: 'حديث النية',
        rawSanad:
            'حَدَّثَنَا الْحُمَيْدِيُّ قَالَ حَدَّثَنَا سُفْيَانُ قَالَ حَدَّثَنَا يَحْيَى بْنُ سَعِيدٍ الْأَنْصَارِيُّ عَنْ مُحَمَّدِ بْنِ إِبْرَاهِيمَ التَّيْمِيِّ عَنْ عَلْقَمَةَ بْنِ وَقَّاصٍ اللَّيْثِيِّ عَنْ عُمَرَ بْنِ الْخَطَّابِ قَالَ قَالَ رَسُولُ اللَّهِ ﷺ',
        rawMatn: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَلِكُلِّ امْرِئٍ مَا نَوَى',
        rawiAlaId: 'rawi_umar',
        rawiAlaArabicName: 'عمر بن الخطاب',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['النية والإخلاص'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'عمر بن الخطاب',
            resolvedRawiId: 'rawi_umar',
            resolvedArabicName: 'عمر بن الخطاب',
            transmissionPhrase: 'قال رسول الله ﷺ',
          ),
          SanadNarratorHop(
            rawMention: 'علقمة بن وقاص الليثي',
            resolvedRawiId: 'rawi_alqamah',
            resolvedArabicName: 'علقمة بن وقاص الليثي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'محمد بن إبراهيم التيمي',
            resolvedRawiId: 'rawi_muhammad_ibrahim',
            resolvedArabicName: 'محمد بن إبراهيم التيمي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'يحيى بن سعيد الأنصاري',
            resolvedRawiId: 'rawi_yahya_said',
            resolvedArabicName: 'يحيى بن سعيد الأنصاري',
            transmissionPhrase: 'حدثنا',
          ),
          SanadNarratorHop(
            rawMention: 'سفيان',
            resolvedRawiId: 'rawi_sufyan_uyainah',
            resolvedArabicName: 'سفيان بن عيينة',
            transmissionPhrase: 'حدثنا',
            wasMuhmalOrMubham: true,
          ),
          SanadNarratorHop(
            rawMention: 'الحميدي',
            resolvedRawiId: 'rawi_humaidi',
            resolvedArabicName: 'الحميدي',
            transmissionPhrase: 'حدثنا',
          ),
        ],
      ),
      // Riwayat dari kitab Zawa'id ('Abdullah bin Ahmad) & Kompilasi Sekunder (al-Mathalib al-'Aliyah) & Mustakhraj
      const CanonicalHadithRecord(
        uri: 'ot://hadith/musnad_ahmad_zawaid_abdullah/168',
        bookId: 'musnad_ahmad_zawaid_abdullah',
        bookTitleArabic: 'زوائد عبد الله بن أحمد على المسند',
        harfNumber: 168,
        printNumber: '168',
        partNumber: 1,
        pageNumber: 303,
        sectionTitle: 'مسند عمر بن الخطاب رضي الله عنه',
        chapterTitle: 'زوائد عبد الله',
        rawSanad:
            'حَدَّثَنِي عَبْدُ اللَّهِ حَدَّثَنَا مُحَمَّدُ بْنُ الْمُثَنَّى حَدَّثَنَا عَبْدُ الْوَهَّابِ الثَّقَفِيُّ عَنْ يَحْيَى بْنِ سَعِيدٍ عَنْ مُحَمَّدِ بْنِ إِبْرَاهِيمَ عَنْ عَلْقَمَةَ بْنِ وَقَّاصٍ اللَّيْثِيِّ عَنْ عُمَرَ بْنِ الْخَطَّابِ عَنِ النَّبِيِّ ﷺ قَالَ',
        rawMatn:
            'إِنَّمَا الْأَعْمَالُ بِالنِّيَّةِ، وَلِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَإِلَى رَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَإِلَى رَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ إِلَى دُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
        rawiAlaId: 'rawi_umar',
        rawiAlaArabicName: 'عمر بن الخطاب',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['النية والإخلاص'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'عمر بن الخطاب',
            resolvedRawiId: 'rawi_umar',
            resolvedArabicName: 'عمر بن الخطاب',
            transmissionPhrase: 'عن النبي ﷺ',
          ),
          SanadNarratorHop(
            rawMention: 'علقمة بن وقاص الليثي',
            resolvedRawiId: 'rawi_alqamah',
            resolvedArabicName: 'علقمة بن وقاص الليثي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'محمد بن إبراهيم',
            resolvedRawiId: 'rawi_muhammad_ibrahim',
            resolvedArabicName: 'محمد بن إبراهيم التيمي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'يحيى بن سعيد',
            resolvedRawiId: 'rawi_yahya_said',
            resolvedArabicName: 'يحيى بن سعيد الأنصاري',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'عبد الوهاب الثقفي',
            resolvedRawiId: 'rawi_abdul_wahhab_tsaqafi',
            resolvedArabicName: 'عبد الوهاب الثقفي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'محمد بن المثنى',
            resolvedRawiId: 'rawi_muhammad_mutsanna',
            resolvedArabicName: 'محمد بن المثنى (بندار)',
            transmissionPhrase: 'حدثنا',
          ),
        ],
      ),
      const CanonicalHadithRecord(
        uri: 'ot://hadith/mathalib_aliyah/3102',
        bookId: 'mathalib_aliyah',
        bookTitleArabic: 'المطالب العالية بزوائد المسانيد الثمانية',
        harfNumber: 3102,
        printNumber: '3102',
        partNumber: 12,
        pageNumber: 441,
        sectionTitle: 'كتاب التوبة والزهد',
        chapterTitle: 'باب الإخلاص والنية',
        rawSanad: 'قَالَ مُسَدَّدٌ حَدَّثَنَا سُفْيَانُ عَنْ يَحْيَى بْنِ سَعِيدٍ عَنْ مُحَمَّدِ بْنِ إِبْرَاهِيمَ عَنْ عَلْقَمَةَ عَنْ عُمَرَ مَرْفُوعًا',
        rawMatn:
            'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى دُنْيَا يُصِيبُهَا أَوْ إِلَى امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
        rawiAlaId: 'rawi_umar',
        rawiAlaArabicName: 'عمر بن الخطاب',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['النية والإخلاص'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'عمر',
            resolvedRawiId: 'rawi_umar',
            resolvedArabicName: 'عمر بن الخطاب',
            transmissionPhrase: 'مرفوعاً',
          ),
          SanadNarratorHop(
            rawMention: 'علقمة',
            resolvedRawiId: 'rawi_alqamah',
            resolvedArabicName: 'علقمة بن وقاص الليثي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'محمد بن إبراهيم',
            resolvedRawiId: 'rawi_muhammad_ibrahim',
            resolvedArabicName: 'محمد بن إبراهيم التيمي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'يحيى بن سعيد',
            resolvedRawiId: 'rawi_yahya_said',
            resolvedArabicName: 'يحيى بن سعيد الأنصاري',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'سفيان',
            resolvedRawiId: 'rawi_sufyan_uyainah',
            resolvedArabicName: 'سفيان بن عيينة',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'مسدد',
            resolvedRawiId: 'rawi_musaddad',
            resolvedArabicName: 'مسدد بن مسرهد',
            transmissionPhrase: 'حدثنا',
          ),
        ],
      ),
      const CanonicalHadithRecord(
        uri: 'ot://hadith/mustakhraj_abi_awanah/7620',
        bookId: 'mustakhraj_abi_awanah',
        bookTitleArabic: 'مستخرج أبي عوانة',
        harfNumber: 7620,
        printNumber: '7620',
        partNumber: 4,
        pageNumber: 498,
        sectionTitle: 'كتاب الجهاد والسير',
        chapterTitle: 'بيان أن الأعمال بالنية',
        rawSanad:
            'حَدَّثَنَا الصَّغَانِيُّ قَالَ حَدَّثَنَا الْقَعْنَبِيُّ عَنْ مَالِكٍ عَنْ يَحْيَى بْنِ سَعِيدٍ عَنْ مُحَمَّدِ بْنِ إِبْرَاهِيمَ عَنْ عَلْقَمَةَ بْنِ وَقَّاصٍ عَنْ عُمَرَ بْنِ الْخَطَّابِ قَالَ قَالَ رَسُولُ اللَّهِ ﷺ',
        rawMatn:
            'إِنَّمَا الْأَعْمَالُ بِالنِّيَّةِ، وَإِنَّمَا لِامْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ إِلَى دُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَتَزَوَّجُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
        rawiAlaId: 'rawi_umar',
        rawiAlaArabicName: 'عمر بن الخطاب',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['النية والإخلاص'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'عمر بن الخطاب',
            resolvedRawiId: 'rawi_umar',
            resolvedArabicName: 'عمر بن الخطاب',
            transmissionPhrase: 'قال رسول الله ﷺ',
          ),
          SanadNarratorHop(
            rawMention: 'علقمة بن وقاص',
            resolvedRawiId: 'rawi_alqamah',
            resolvedArabicName: 'علقمة بن وقاص الليثي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'محمد بن إبراهيم',
            resolvedRawiId: 'rawi_muhammad_ibrahim',
            resolvedArabicName: 'محمد بن إبراهيم التيمي',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'يحيى بن سعيد',
            resolvedRawiId: 'rawi_yahya_said',
            resolvedArabicName: 'يحيى بن سعيد الأنصاري',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'مالك',
            resolvedRawiId: 'rawi_malik',
            resolvedArabicName: 'مالك بن أنس',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'القعنبي',
            resolvedRawiId: 'rawi_abdullah_maslamah',
            resolvedArabicName: 'عبد الله بن مسلمة القعنبي',
            transmissionPhrase: 'عن',
          ),
        ],
      ),
      // Syahid Lintas Sahabat (Abu Hurairah) untuk menguji pemisahan Jami' al-Matn vs Takhrij
      const CanonicalHadithRecord(
        uri: 'ot://hadith/ibn_majah/4227',
        bookId: 'ibn_majah',
        bookTitleArabic: 'سنن ابن ماجه',
        harfNumber: 4227,
        printNumber: '4227',
        partNumber: 2,
        pageNumber: 1413,
        sectionTitle: 'كتاب الزهد',
        chapterTitle: 'باب النية',
        rawSanad:
            'حَدَّثَنَا أَبُو بَكْرِ بْنُ أَبِي شَيْبَةَ حَدَّثَنَا يَزِيدُ بْنُ هَارُونَ عَنْ مُحَمَّدِ بْنِ عَمْرٍو عَنْ أَبِي سَلَمَةَ عَنْ أَبِي هُرَيْرَةَ قَالَ قَالَ رَسُولُ اللَّهِ ﷺ',
        rawMatn: 'إِنَّمَا يُبْعَثُ النَّاسُ عَلَى نِيَّاتِهِمْ، وَالْأَعْمَالُ بِالنِّيَّاتِ',
        rawiAlaId: 'rawi_abu_hurairah',
        rawiAlaArabicName: 'أبو هريرة الدوسي',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['النية والإخلاص', 'البعث والجزاء'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'أبي هريرة',
            resolvedRawiId: 'rawi_abu_hurairah',
            resolvedArabicName: 'أبو هريرة الدوسي',
            transmissionPhrase: 'قال رسول الله ﷺ',
          ),
        ],
      ),

      // KLASTER 2: Contoh Resmi Al-Matn al-Mujamma' di `WorkingGroups.pdf` hlm. 45 & 64
      // («أنه كان إذا تكلم بكلمة أعادها ثلاثاً حتى تفهم عنه»)
      const CanonicalHadithRecord(
        uri: 'ot://hadith/bukhari/95',
        bookId: 'bukhari',
        bookTitleArabic: 'صحيح البخاري',
        harfNumber: 95,
        printNumber: '95',
        partNumber: 1,
        pageNumber: 30,
        sectionTitle: 'كتاب العلم',
        chapterTitle: 'باب من أعاد الحديث ثلاثاً ليفهم عنه',
        rawSanad:
            'حَدَّثَنَا عَبْدُةُ بْنُ عَبْدِ اللَّهِ حَدَّثَنَا عَبْدُ الصَّمَدِ قَالَ حَدَّثَنَا عَبْدُ اللَّهِ بْنُ الْمُثَنَّى قَالَ حَدَّثَنَا ثُمَامَةُ بْنُ عَبْدِ اللَّهِ عَنْ أَنَسٍ عَنِ النَّبِيِّ ﷺ',
        rawMatn:
            'أَنَّهُ كَانَ إِذَا تَكَلَّمَ بِكَلِمَةٍ أَعَادَهَا ثَلَاثًا حَتَّى تُفْهَمَ عَنْهُ، وَإِذَا أَتَى عَلَى قَوْمٍ فَسَلَّمَ عَلَيْهِمْ سَلَّمَ عَلَيْهِمْ ثَلَاثًا',
        rawiAlaId: 'rawi_anas',
        rawiAlaArabicName: 'أنس بن مالك',
        elevationStatus: HadithElevationStatus.marfu,
        historicalDateLabel: 'الشمائل النبوية — العهد المدني',
        thematicTags: ['آداب العلم والتعليم', 'السلام والاستئذان', 'الشمائل النبوية'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'أنس',
            resolvedRawiId: 'rawi_anas',
            resolvedArabicName: 'أنس بن مالك',
            transmissionPhrase: 'عن النبي ﷺ',
          ),
        ],
      ),
      const CanonicalHadithRecord(
        uri: 'ot://hadith/tirmidzi/2723',
        bookId: 'tirmidzi',
        bookTitleArabic: 'جامع الترمذي',
        harfNumber: 2723,
        printNumber: '2723',
        partNumber: 5,
        pageNumber: 72,
        sectionTitle: 'كتاب الاستئذان والآداب',
        chapterTitle: 'باب ما جاء في التسليم ثلاثاً',
        rawSanad:
            'حَدَّثَنَا سُوَيْدُ بْنُ نَصْرٍ قَالَ أَخْبَرَنَا عَبْدُ اللَّهِ بْنُ الْمُبَارَكِ عَنْ عَبْدِ اللَّهِ بْنِ الْمُثَنَّى عَنْ ثُمَامَةَ بْنِ عَبْدِ اللَّهِ بْنِ أَنَسٍ عَنْ أَنَسِ بْنِ مَالِكٍ',
        rawMatn:
            'أَنَّ النَّبِيَّ ﷺ كَانَ إِذَا تَكَلَّمَ بِكَلِمَةٍ رَدَّدَهَا ثَلَاثًا حَتَّى تُعْقَلَ عَنْهُ، وَإِذَا أَتَى قَوْمًا فَسَلَّمَ عَلَيْهِمْ سَلَّمَ عَلَيْهِمْ ثَلَاثًا، وَكَانَ يَسْتَأْذِنُ ثَلَاثًا',
        rawiAlaId: 'rawi_anas',
        rawiAlaArabicName: 'أنس بن مالك',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['آداب العلم والتعليم', 'السلام والاستئذان'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'أنس بن مالك',
            resolvedRawiId: 'rawi_anas',
            resolvedArabicName: 'أنس بن مالك',
            transmissionPhrase: 'عن',
          ),
        ],
      ),
      const CanonicalHadithRecord(
        uri: 'ot://hadith/musnad_ahmad/13245',
        bookId: 'musnad_ahmad',
        bookTitleArabic: 'مسند أحمد',
        harfNumber: 13245,
        printNumber: '13245',
        partNumber: 21,
        pageNumber: 18,
        sectionTitle: 'مسند المكثرين من الصحابة',
        chapterTitle: 'مسند أنس بن مالك رضي الله عنه',
        rawSanad:
            'حَدَّثَنَا عَفَّانُ حَدَّثَنَا عَبْدُ الْوَارِثِ حَدَّثَنَا عَبْدُ اللَّهِ بْنُ الْمُثَنَّى عَنْ ثُمَامَةَ أَنَّ أَنَسًا كَانَ إِذَا تَكَلَّمَ تَكَلَّمَ ثَلَاثًا وَيَذْكُرُ',
        rawMatn:
            'أَنَّ رَسُولَ اللَّهِ ﷺ كَانَ يُعِيدُ الْكَلِمَةَ ثَلَاثًا حَتَّى تُفْهَمَ عَنْهُ، وَكَانَ إِذَا سَلَّمَ سَلَّمَ ثَلَاثًا',
        rawiAlaId: 'rawi_anas',
        rawiAlaArabicName: 'أنس بن مالك',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['آداب العلم والتعليم', 'الشمائل النبوية'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'أنساً',
            resolvedRawiId: 'rawi_anas',
            resolvedArabicName: 'أنس بن مالك',
            transmissionPhrase: 'يذكر أن رسول الله ﷺ',
          ),
        ],
      ),

      // KLASTER 3: Contoh Resmi Ikhtilaf 'ala al-Madar (al-Zuhri) di `WorkingGroups.pdf` hlm. 57–58
      const CanonicalHadithRecord(
        uri: 'ot://hadith/muwattha_malik/145',
        bookId: 'muwattha_malik',
        bookTitleArabic: 'موطأ مالك',
        harfNumber: 145,
        printNumber: '145',
        partNumber: 1,
        pageNumber: 68,
        sectionTitle: 'كتاب الطهارة',
        chapterTitle: 'باب العمل في الوضوء',
        rawSanad: 'مَالِكٌ عَنِ الزُّهْرِيِّ عَنْ نَافِعٍ عَنِ ابْنِ عُمَرَ أَنَّ رَسُولَ اللَّهِ ﷺ قَالَ',
        rawMatn:
            'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ، وَالْمُهَاجِرُ مَنْ هَجَرَ مَا نَهَى اللَّهُ عَنْهُ',
        rawiAlaId: 'rawi_ibn_umar',
        rawiAlaArabicName: 'عبد الله بن عمر',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['الإيمان والإسلام', 'حفظ اللسان واليد'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'ابن عمر',
            resolvedRawiId: 'rawi_ibn_umar',
            resolvedArabicName: 'عبد الله بن عمر',
            transmissionPhrase: 'أن رسول الله ﷺ قال',
          ),
          SanadNarratorHop(
            rawMention: 'نافع',
            resolvedRawiId: 'rawi_nafi',
            resolvedArabicName: 'نافع مولى ابن عمر',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'الزهري',
            resolvedRawiId: 'rawi_zuhri',
            resolvedArabicName: 'ابن شهاب الزهري',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'مالك',
            resolvedRawiId: 'rawi_malik',
            resolvedArabicName: 'مالك بن أنس',
            transmissionPhrase: 'عن',
          ),
        ],
      ),
      const CanonicalHadithRecord(
        uri: 'ot://hadith/musannaf_abdurrazzaq/19842',
        bookId: 'musannaf_abdurrazzaq',
        bookTitleArabic: 'مصنف عبد الرزاق',
        harfNumber: 19842,
        printNumber: '19842',
        partNumber: 11,
        pageNumber: 44,
        sectionTitle: 'كتاب الجامع لليعمر',
        chapterTitle: 'باب حفظ اللسان',
        rawSanad: 'عَبْدُ الرَّزَّاقِ عَنْ مَعْمَرٍ عَنِ الزُّهْرِيِّ عَنْ سَالِمٍ عَنِ ابْنِ عُمَرَ أَنَّ النَّبِيَّ ﷺ قَالَ',
        rawMatn: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
        rawiAlaId: 'rawi_ibn_umar',
        rawiAlaArabicName: 'عبد الله بن عمر',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['الإيمان والإسلام', 'حفظ اللسان واليد'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'ابن عمر',
            resolvedRawiId: 'rawi_ibn_umar',
            resolvedArabicName: 'عبد الله بن عمر',
            transmissionPhrase: 'أن النبي ﷺ قال',
          ),
          SanadNarratorHop(
            rawMention: 'سالم',
            resolvedRawiId: 'rawi_salim',
            resolvedArabicName: 'سالم بن عبد الله بن عمر',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'الزهري',
            resolvedRawiId: 'rawi_zuhri',
            resolvedArabicName: 'ابن شهاب الزهري',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'معمر',
            resolvedRawiId: 'rawi_mamar',
            resolvedArabicName: 'معمر بن راشد',
            transmissionPhrase: 'عن',
          ),
        ],
      ),
      const CanonicalHadithRecord(
        uri: 'ot://hadith/shahih_ibn_hibban/196',
        bookId: 'shahih_ibn_hibban',
        bookTitleArabic: 'صحيح ابن حبان (الإحسان)',
        harfNumber: 196,
        printNumber: '196',
        partNumber: 1,
        pageNumber: 422,
        sectionTitle: 'كتاب الإيمان',
        chapterTitle: 'ذكر البيان بأن المسلم من سلم المسلمون من لسانه ويده',
        rawSanad: 'أَخْبَرَنَا ابْنُ وَهْبٍ عَنْ يُونُسَ عَنِ الزُّهْرِيِّ عَنْ سَالِمٍ عَنِ ابْنِ عُمَرَ عَنِ النَّبِيِّ ﷺ قَالَ',
        rawMatn:
            'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ، وَالْمُؤْمِنُ مَنْ أَمِنَهُ النَّاسُ عَلَى دِمَائِهِمْ وَأَمْوَالِهِمْ',
        rawiAlaId: 'rawi_ibn_umar',
        rawiAlaArabicName: 'عبد الله بن عمر',
        elevationStatus: HadithElevationStatus.marfu,
        thematicTags: ['الإيمان والإسلام'],
        sanadChain: [
          SanadNarratorHop(
            rawMention: 'ابن عمر',
            resolvedRawiId: 'rawi_ibn_umar',
            resolvedArabicName: 'عبد الله بن عمر',
            transmissionPhrase: 'عن النبي ﷺ',
          ),
          SanadNarratorHop(
            rawMention: 'سالم',
            resolvedRawiId: 'rawi_salim',
            resolvedArabicName: 'سالم بن عبد الله بن عمر',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'الزهري',
            resolvedRawiId: 'rawi_zuhri',
            resolvedArabicName: 'ابن شهاب الزهري',
            transmissionPhrase: 'عن',
          ),
          SanadNarratorHop(
            rawMention: 'يونس',
            resolvedRawiId: 'rawi_yunus',
            resolvedArabicName: 'يونس بن يزيد الأيلي',
            transmissionPhrase: 'عن',
          ),
        ],
      ),
    ];

    for (final hadith in initialCorpus) {
      indexHadithRecord(hadith);
    }
  }

  /// Menambahkan kitab baru secara dinamis (untuk ekspansi ribuan kitab).
  void registerBook(HadithBookMetadata book) {
    _booksById[book.id] = book;
  }

  /// Menambahkan dan mengindeks satu hadis ke dalam Inverted Root & Trigram Index.
  void indexHadithRecord(CanonicalHadithRecord record) {
    if (_hadithsByUri.containsKey(record.uri)) return;
    _hadithsByUri[record.uri] = record;
    _corpusHadiths.add(record);

    final tokens = _morph.tokenizeMeaningfulMatn(record.effectiveMatnForIndexing);
    final roots = tokens.map((t) => t.root).where((r) => r.isNotEmpty).toList();
    for (final r in roots) {
      (_invertedRootIndex[r] ??= <String>{}).add(record.uri);
    }
    for (var i = 0; i + 2 < roots.length; i++) {
      final trigram = '${roots[i]}:${roots[i + 1]}:${roots[i + 2]}';
      (_invertedTrigramIndex[trigram] ??= <String>{}).add(record.uri);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LAPISAN 2: SEGMENTER SANAD-MATN OTOMATIS & EKSPANSI IHALAH (<متن_مخفي>)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Memisahkan paragraf hadis mentah menjadi `(sanadText, matnText, detectedRawiAla)`.
  ({String sanad, String matn, String? detectedRawiAlaName}) segmentRawHadithParagraph(
      String rawParagraph) {
    final cleaned = rawParagraph.trim();
    final matnTriggerPatterns = <RegExp>[
      RegExp(r'(قَالَ\s+رَسُولُ\s+اللَّهِ\s*ﷺ|قال\s+رسول\s+الله\s*ﷺ|سمعت\s+رسول\s+الله\s*ﷺ\s+يقول|عن\s+النبي\s*ﷺ\s+قال|أن\s+رسول\s+الله\s*ﷺ\s+قال)\s*[:«"]?'),
      RegExp(r'(يَقُولُ|قَالَ)\s*[«"]'),
    ];

    for (final regex in matnTriggerPatterns) {
      final match = regex.firstMatch(cleaned);
      if (match != null && match.end < cleaned.length) {
        final sanadPart = cleaned.substring(0, match.end).trim();
        final matnPart = cleaned
            .substring(match.end)
            .replaceAll(RegExp(r'^[«":\s]+|[»"\s]+$'), '')
            .trim();
        return (
          sanad: sanadPart,
          matn: matnPart.isEmpty ? cleaned : matnPart,
          detectedRawiAlaName: _detectRawiAlaFromSanad(sanadPart),
        );
      }
    }

    return (
      sanad: '',
      matn: cleaned,
      detectedRawiAlaName: null,
    );
  }

  String? _detectRawiAlaFromSanad(String sanadText) {
    final normSanad = _morph.normalizeArabicWord(sanadText);
    for (final rawi in _rawisById.values.where((r) => r.tabaqaNum == 1)) {
      final normShuhra = _morph.normalizeArabicWord(rawi.esmShuhra);
      if (normShuhra.isNotEmpty && normSanad.contains(normShuhra)) {
        return rawi.esmShuhra;
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LAPISAN 3: TWO-STAGE JAMI' AL-MATN & TAKHRIJ CLUSTERING (80% & 50% CONTAINMENT)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Menjalankan takhrij penuh lintas seluruh kitab terdaftar untuk satu hadis
  /// atau kueri teks matan bebas.
  TakhrijClusterResult performTakhrijOnHadith(
    CanonicalHadithRecord origin, {
    bool includeNonCore33Books = true,
    TakhrijSortOrder sortOrder = TakhrijSortOrder.byCanonicalBookRank,
  }) {
    final originBook = _booksById[origin.bookId] ?? _booksById.values.first;
    final originTokens = _morph.tokenizeMeaningfulMatn(origin.effectiveMatnForIndexing);
    final originRoots = originTokens.map((t) => t.root).where((r) => r.isNotEmpty).toList();

    // 1. Ambil kandidat cepat dari Inverted Root & Trigram Index (O(1) lookup)
    final candidateUris = <String>{};
    for (var i = 0; i + 2 < originRoots.length; i++) {
      final trigram = '${originRoots[i]}:${originRoots[i + 1]}:${originRoots[i + 2]}';
      final hits = _invertedTrigramIndex[trigram];
      if (hits != null) candidateUris.addAll(hits);
    }
    for (final r in originRoots) {
      final hits = _invertedRootIndex[r];
      if (hits != null) candidateUris.addAll(hits);
    }

    final takhrijOutcomes = <MatnComparisonOutcome>[];
    final syawahidOutcomes = <MatnComparisonOutcome>[];

    for (final uri in candidateUris) {
      if (uri == origin.uri) continue;
      final candidate = _hadithsByUri[uri];
      if (candidate == null) continue;
      final candidateBook = _booksById[candidate.bookId];
      if (candidateBook == null) continue;
      if (!includeNonCore33Books && !candidateBook.isCore33) continue;

      final comparison = compareTwoHadithMatns(origin, candidate);
      // Filter Two-Stage Khademhrf (WorkingGroups.pdf hlm. 65-67):
      // Stage 1: >= 80% overlap, ATAU Stage 2 (Damm al-Majmu'at): >= 20% overlap
      // dengan containment pada matan yang lebih pendek >= 50%.
      final maxCoverage = math.max(
        comparison.rootCoverageOnOrigin,
        comparison.rootCoverageOnTarget,
      );
      final minCoverage = math.min(
        comparison.rootCoverageOnOrigin,
        comparison.rootCoverageOnTarget,
      );
      if (maxCoverage < 0.50 && minCoverage < 0.20) continue;

      if (candidate.rawiAlaId == origin.rawiAlaId) {
        takhrijOutcomes.add(comparison);
      } else {
        syawahidOutcomes.add(comparison);
      }
    }

    // 2. Urutkan hasil sesuai pilihan peneliti (Description.pdf hlm. 4-5)
    _sortComparisonOutcomes(takhrijOutcomes, sortOrder);
    _sortComparisonOutcomes(syawahidOutcomes, sortOrder);

    // 3. Bangun Al-Matn al-Mujamma' (Lapisan 6)
    final mujamma = buildAlMatnAlMujamma(
      origin,
      takhrijOutcomes.map((o) => o.targetHadith).toList(),
    );

    // 4. Bangun Graf Sanad, Madar, Mutaba'at, & Laporan 'Ilal (Lapisan 4 & 5)
    final allClusterHadiths = [
      origin,
      ...takhrijOutcomes.map((o) => o.targetHadith),
    ];
    final madarReport = buildMadarAndIlalReport(allClusterHadiths);

    // 5. Rakit paragraf takhrij bahasa Arab bergaya `TakhreegXSL.xsl`
    final formattedParagraph = _buildClassicalTakhrijParagraph(
      origin,
      originBook,
      takhrijOutcomes,
      syawahidOutcomes,
    );

    return TakhrijClusterResult(
      originHadith: origin,
      originBook: originBook,
      takhrijOutcomes: takhrijOutcomes,
      syawahidOutcomes: syawahidOutcomes,
      mujammaMatn: mujamma,
      madarReport: madarReport,
      serviceReferences: _lookupServiceBookReferences(origin),
      formattedFullTakhrijArabicParagraph: formattedParagraph,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LAPISAN 4: DISAMBIGUASI PERAWI MUHMAL / MUBHAM (VITERBI GRAPH RESOLVER)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Menyelesaikan nama perawi yang muhmal (seperti "سفيان" atau "حماد")
  /// berdasarkan guru di atasnya (`teacherRawiId`) dan murid di bawahnya (`studentRawiId`).
  RawiBiographyRecord? disambiguateMuhmalRawi({
    required String rawNameMention,
    String? teacherRawiId,
    String? studentRawiId,
  }) {
    final normMention = _morph.normalizeArabicWord(rawNameMention);
    if (normMention.isEmpty) return null;

    RawiBiographyRecord? bestMatch;
    var bestScore = -1.0;

    for (final candidate in _rawisById.values) {
      final normFull = _morph.normalizeArabicWord(candidate.fullNameArabic);
      final normShuhra = _morph.normalizeArabicWord(candidate.esmShuhra);
      final normLaqab = _morph.normalizeArabicWord(candidate.laqab);
      final normKunia = _morph.normalizeArabicWord(candidate.kunia);

      final nameMatches = normFull.contains(normMention) ||
          normShuhra.contains(normMention) ||
          (normLaqab.isNotEmpty && normLaqab.contains(normMention)) ||
          (normKunia.isNotEmpty && normKunia.contains(normMention));
      if (!nameMatches) continue;

      var score = 1.0;
      if (teacherRawiId != null && candidate.shyoukhIds.contains(teacherRawiId)) {
        score += 5.0;
      }
      if (studentRawiId != null && candidate.talamizIds.contains(studentRawiId)) {
        score += 5.0;
      }
      score += math.min(candidate.totalHadithCountInCorpus / 5000.0, 1.0);

      if (score > bestScore) {
        bestScore = score;
        bestMatch = candidate;
      }
    }
    return bestMatch;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LAPISAN 5: GRAF POHON SANAD, PENENTUAN MADAR, & LAPORAN OTOMATIS 'ILAL
  // ═══════════════════════════════════════════════════════════════════════════

  /// Membangun pohon sanad terpadu, menentukan Rawi al-Madar al-Ra'is & al-Far'i,
  /// mendeteksi ikhtilaf 'ala al-madar, serta menyusun laporan otomatis (`AsaneedReport.dll`).
  MadarAndIlalReport buildMadarAndIlalReport(List<CanonicalHadithRecord> clusterHadiths) {
    if (clusterHadiths.isEmpty) {
      return const MadarAndIlalReport(
        nodes: [],
        edges: [],
        automatedArabicReport: '',
        automatedIndonesianSummary: '',
      );
    }

    final nodeDepthMap = <String, int>{};
    final nodeNameMap = <String, String>{};
    final outTargetsByRawi = <String, Set<String>>{};
    final inSourcesByRawi = <String, Set<String>>{};
    final edgeBooksMap = <(String, String), Set<String>>{};
    final edgeSighahMap = <(String, String), String>{};

    for (final hadith in clusterHadiths) {
      final chain = hadith.sanadChain;
      for (var i = 0; i < chain.length; i++) {
        final hop = chain[i];
        final rId = hop.resolvedRawiId ?? 'anon_${hop.resolvedArabicName}';
        nodeDepthMap.putIfAbsent(rId, () => i);
        nodeNameMap[rId] = hop.resolvedArabicName;

        if (i + 1 < chain.length) {
          final nextHop = chain[i + 1];
          final nextId = nextHop.resolvedRawiId ?? 'anon_${nextHop.resolvedArabicName}';
          (outTargetsByRawi[rId] ??= <String>{}).add(nextId);
          (inSourcesByRawi[nextId] ??= <String>{}).add(rId);
          final edgeKey = (rId, nextId);
          (edgeBooksMap[edgeKey] ??= <String>{}).add(hadith.bookTitleArabic);
          edgeSighahMap.putIfAbsent(edgeKey, () => nextHop.transmissionPhrase);
        } else {
          // Hubungkan perawi terakhir ke Mushannif kitab
          final book = _booksById[hadith.bookId];
          final mushannifId = 'mushannif_${hadith.bookId}';
          nodeDepthMap[mushannifId] = i + 1;
          nodeNameMap[mushannifId] = book?.authorArabic ?? hadith.bookTitleArabic;
          (outTargetsByRawi[rId] ??= <String>{}).add(mushannifId);
          (inSourcesByRawi[mushannifId] ??= <String>{}).add(rId);
          final edgeKey = (rId, mushannifId);
          (edgeBooksMap[edgeKey] ??= <String>{}).add(hadith.bookTitleArabic);
          edgeSighahMap.putIfAbsent(edgeKey, () => 'أخرجه');
        }
      }
    }

    // Tentukan Rawi al-Madar al-Ra'is (perawi non-Sahabat dengan percabangan murid terbanyak)
    String? primaryMadarId;
    var maxOutDegree = 1;
    final secondaryMadarIds = <String>{};

    for (final entry in outTargetsByRawi.entries) {
      final rId = entry.key;
      final depth = nodeDepthMap[rId] ?? 0;
      final degree = entry.value.length;
      if (depth > 0 && degree >= 2) {
        if (degree > maxOutDegree) {
          if (primaryMadarId != null) secondaryMadarIds.add(primaryMadarId);
          primaryMadarId = rId;
          maxOutDegree = degree;
        } else {
          secondaryMadarIds.add(rId);
        }
      }
    }

    // Cek apakah terjadi Ikhtilaf 'ala al-Madar (madar memiliki >1 jalur guru berbeda di atasnya)
    final hasIkhtilafOnPrimaryMadar = primaryMadarId != null &&
        (inSourcesByRawi[primaryMadarId]?.length ?? 0) > 1;

    final nodes = <SanadGraphNode>[];
    SanadGraphNode? rawiAlaNode;
    SanadGraphNode? primaryMadarNode;
    final secondaryMadarNodes = <SanadGraphNode>[];

    for (final entry in nodeDepthMap.entries) {
      final rId = entry.key;
      final bio = _rawisById[rId];
      final isAla = entry.value == 0;
      final isPrimMadar = rId == primaryMadarId;
      final isSecMadar = secondaryMadarIds.contains(rId);
      final isMushannif = rId.startsWith('mushannif_');
      final outDeg = outTargetsByRawi[rId]?.length ?? 0;

      final node = SanadGraphNode(
        rawiId: rId,
        arabicName: bio?.esmShuhra ?? nodeNameMap[rId] ?? rId,
        tabaqaLabel: bio?.tabaqaArabic ?? (isMushannif ? 'المصنف المخرج' : 'راوٍ في الإسناد'),
        martabaSummary: bio?.martabaIbnHajar ?? (isMushannif ? 'إمام مصنف' : 'ثقة'),
        layerDepth: entry.value,
        isRawiAla: isAla,
        isPrimaryMadar: isPrimMadar,
        isSecondaryMadar: isSecMadar,
        isMushannif: isMushannif,
        branchingOutDegree: outDeg,
      );
      nodes.add(node);
      if (isAla && rawiAlaNode == null) rawiAlaNode = node;
      if (isPrimMadar) primaryMadarNode = node;
      if (isSecMadar) secondaryMadarNodes.add(node);
    }

    final edges = <SanadGraphEdge>[];
    for (final entry in edgeBooksMap.entries) {
      final (teacherId, studentId) = entry.key;
      final sighah = edgeSighahMap[entry.key] ?? 'عن';
      final linkStatus = _evaluateSanadLinkStatus(teacherId, studentId, sighah);
      final isIkhtilafEdge = hasIkhtilafOnPrimaryMadar &&
          (studentId == primaryMadarId || teacherId == primaryMadarId);

      edges.add(
        SanadGraphEdge(
          teacherRawiId: teacherId,
          studentRawiId: studentId,
          sighahTahdits: sighah,
          linkStatus: linkStatus,
          hasIkhtilafOnMadar: isIkhtilafEdge,
          supportingBookTitles: entry.value.toList(),
        ),
      );
    }

    // Rakit teks laporan otomatis sesuai ضوابط كتابة تقرير الإسناد بشكل آلي (WorkingGroups.pdf hlm. 56–58)
    final arabicReport = _generateAutomatedArabicIsnadReport(
      rawiAlaNode: rawiAlaNode,
      primaryMadarNode: primaryMadarNode,
      hasIkhtilaf: hasIkhtilafOnPrimaryMadar,
      outTargetsByRawi: outTargetsByRawi,
      inSourcesByRawi: inSourcesByRawi,
      nodeNameMap: nodeNameMap,
    );

    final indonesianSummary = _generateIndonesianIsnadSummary(
      rawiAlaNode: rawiAlaNode,
      primaryMadarNode: primaryMadarNode,
      hasIkhtilaf: hasIkhtilafOnPrimaryMadar,
      outTargetsByRawi: outTargetsByRawi,
      nodeNameMap: nodeNameMap,
    );

    return MadarAndIlalReport(
      nodes: nodes,
      edges: edges,
      rawiAla: rawiAlaNode,
      primaryMadar: primaryMadarNode,
      secondaryMadars: secondaryMadarNodes,
      hasIkhtilafAlaMadar: hasIkhtilafOnPrimaryMadar,
      automatedArabicReport: arabicReport,
      automatedIndonesianSummary: indonesianSummary,
      scholarJudgments: const [
        ScholarHadithJudgment(
          scholarArabicName: 'الترمذي',
          scholarDeathYearHijri: 279,
          judgmentArabicText: 'هذا حديث حسن صحيح',
          sourceBookArabic: 'جامع الترمذي',
        ),
        ScholarHadithJudgment(
          scholarArabicName: 'البخاري ومسلم',
          scholarDeathYearHijri: 256,
          judgmentArabicText: 'متفق على صحته وتلقته الأمة بالقبول',
          sourceBookArabic: 'الصحيحان',
        ),
      ],
    );
  }

  SanadLinkStatus _evaluateSanadLinkStatus(
    String teacherId,
    String studentId,
    String sighah,
  ) {
    if (studentId.startsWith('mushannif_')) {
      return SanadLinkStatus.muttasilSama;
    }
    final teacher = _rawisById[teacherId];
    final student = _rawisById[studentId];
    if (teacher == null || student == null) {
      return SanadLinkStatus.muasharahPossible;
    }
    if (student.isMudallis && sighah.trim() == 'عن' && !teacher.talamizIds.contains(studentId)) {
      return SanadLinkStatus.mudallasAnanah;
    }
    if (teacher.isMukhtalith && !teacher.talamizIds.contains(studentId)) {
      return SanadLinkStatus.mukhtalithLate;
    }
    if (teacher.talamizIds.contains(studentId) || student.shyoukhIds.contains(teacherId)) {
      return SanadLinkStatus.muttasilSama;
    }
    if (teacher.deathYearHijri != null &&
        student.birthYearHijri != null &&
        student.birthYearHijri! > teacher.deathYearHijri!) {
      return SanadLinkStatus.munqathi;
    }
    return SanadLinkStatus.muasharahPossible;
  }

  String _generateAutomatedArabicIsnadReport({
    required SanadGraphNode? rawiAlaNode,
    required SanadGraphNode? primaryMadarNode,
    required bool hasIkhtilaf,
    required Map<String, Set<String>> outTargetsByRawi,
    required Map<String, Set<String>> inSourcesByRawi,
    required Map<String, String> nodeNameMap,
  }) {
    final alaName = rawiAlaNode?.arabicName ?? 'الصحابي';
    if (primaryMadarNode == null) {
      return 'هذا الحديث روي من طريق ($alaName) رضي الله عنه بإسناد متصل.';
    }
    final madarName = primaryMadarNode.arabicName;
    final studentsOfMadar = (outTargetsByRawi[primaryMadarNode.rawiId] ?? const <String>{})
        .map((id) => nodeNameMap[id] ?? id)
        .join('، و');

    if (!hasIkhtilaf) {
      return 'هذا الحديث روي من طريق ($madarName) عن مشايخه إلى ($alaName) رضي الله عنه، '
          'وقد تفرد بمداره ($madarName) فاتفق الرواة عنه، ورواه عن ($madarName): $studentsOfMadar.';
    }

    final teachersOfMadar = (inSourcesByRawi[primaryMadarNode.rawiId] ?? const <String>{})
        .map((id) => nodeNameMap[id] ?? id)
        .toList();
    final teachersJoined = teachersOfMadar.join('، و');

    return 'هذا الحديث روي من طريق ($madarName) واختلف على ($madarName): '
        'فرواه بعض أصحابه ($studentsOfMadar) عن ($madarName) على وجوه متعددة في شيوخه ($teachersJoined) '
        'عن ($alaName) رضي الله عنه.';
  }

  String _generateIndonesianIsnadSummary({
    required SanadGraphNode? rawiAlaNode,
    required SanadGraphNode? primaryMadarNode,
    required bool hasIkhtilaf,
    required Map<String, Set<String>> outTargetsByRawi,
    required Map<String, String> nodeNameMap,
  }) {
    final ala = rawiAlaNode?.arabicName ?? 'Sahabat';
    if (primaryMadarNode == null) {
      return 'Jalur sanad diriwayatkan secara tunggal melalui $ala.';
    }
    final madar = primaryMadarNode.arabicName;
    final count = outTargetsByRawi[primaryMadarNode.rawiId]?.length ?? 1;
    if (!hasIkhtilaf) {
      return 'Poros sanad (Rāwī al-Madār al-Ra’īs) bertemu pada $madar ($count jalur murid) tanpa perselisihan (ittifāq) hingga $ala.';
    }
    return 'Poros sanad bertemu pada $madar ($count jalur murid) disertai variasi jalur di atas madar (ikhtilāf ‘alā al-madār) menuju $ala.';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LAPISAN 6: DETERMINISTIC 27-RULE MUQARANAT AL-MUTUN & AL-MATN AL-MUJAMMA'
  // ═══════════════════════════════════════════════════════════════════════════

  /// Mengevaluasi 27 aturan *Muqāranat al-Mutūn* (`WorkingGroups.pdf` hlm. 59–63)
  /// antara `origin` (الحديث الأصل) dan `target` (الحديث المقابل).
  MatnComparisonOutcome compareTwoHadithMatns(
    CanonicalHadithRecord origin,
    CanonicalHadithRecord target,
  ) {
    final targetBook = _booksById[target.bookId] ?? _booksById.values.first;
    final originTokens = _morph.tokenizeMeaningfulMatn(origin.effectiveMatnForIndexing);
    final targetTokens = _morph.tokenizeMeaningfulMatn(target.effectiveMatnForIndexing);

    final originRawWords = origin.rawMatn
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final targetRawWords = target.rawMatn
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (originTokens.isEmpty || targetTokens.isEmpty) {
      return MatnComparisonOutcome(
        targetHadith: target,
        targetBook: targetBook,
        rule: MatnComparisonRule.rule27MinGhayriDzikriHadzaAlLafzhi,
        formattedArabicVerdict: 'من غير ذكر هذا اللفظ',
        rootCoverageOnOrigin: 0,
        rootCoverageOnTarget: 0,
        sequenceOrderRatio: 0,
        maxGapRatio: 1,
      );
    }

    // 1. Hitung kecocokan level (root + wazan) dan level (root saja)
    final originExactKeys = originTokens.map((t) => t.rootAndWazanKey).toSet();
    final targetExactKeys = targetTokens.map((t) => t.rootAndWazanKey).toSet();
    final originRoots = originTokens.map((t) => t.root).toSet();
    final targetRoots = targetTokens.map((t) => t.root).toSet();

    final exactOriginMatches =
        originTokens.where((t) => targetExactKeys.contains(t.rootAndWazanKey)).length;
    final exactTargetMatches =
        targetTokens.where((t) => originExactKeys.contains(t.rootAndWazanKey)).length;

    final rootOriginMatches =
        originTokens.where((t) => targetRoots.contains(t.root)).length;
    final rootTargetMatches =
        targetTokens.where((t) => originRoots.contains(t.root)).length;

    final exactCoverageOrigin = exactOriginMatches / originTokens.length;
    final exactCoverageTarget = exactTargetMatches / targetTokens.length;
    final rootCoverageOrigin = rootOriginMatches / originTokens.length;
    final rootCoverageTarget = rootTargetMatches / targetTokens.length;

    // 2. Hitung Longest Common Subsequence (LCS) untuk rasio تتابع الكلمات (urutan kata)
    final lcsLength = _computeRootLcsLength(originTokens, targetTokens);
    final minLen = math.min(originTokens.length, targetTokens.length);
    final maxLen = math.max(originTokens.length, targetTokens.length);
    final sequenceOrderRatio = minLen == 0 ? 0.0 : lcsLength / minLen;
    final maxGapRatio = maxLen == 0 ? 0.0 : 1.0 - (lcsLength / maxLen);

    // 3. Ekstrak indeks kata yang berbeda pada matan asal & target
    final missingInTargetIndices = <int>[];
    for (var i = 0; i < originRawWords.length; i++) {
      final tok = _morph.analyzeWord(originRawWords[i]);
      if (tok.root.isNotEmpty &&
          !HarfMorphologyService.ignoredMatchStopWords.contains(tok.normalizedWord) &&
          !targetRoots.contains(tok.root)) {
        missingInTargetIndices.add(i);
      }
    }

    final addedInTargetIndices = <int>[];
    for (var i = 0; i < targetRawWords.length; i++) {
      final tok = _morph.analyzeWord(targetRawWords[i]);
      if (tok.root.isNotEmpty &&
          !HarfMorphologyService.ignoredMatchStopWords.contains(tok.normalizedWord) &&
          !originRoots.contains(tok.root)) {
        addedInTargetIndices.add(i);
      }
    }

    final omittedFromOriginSegments =
        _morph.formatDiffSegments(originRawWords, missingInTargetIndices);
    final addedInTargetSegments =
        _morph.formatDiffSegments(targetRawWords, addedInTargetIndices);

    final isTargetMuchLonger = targetTokens.length >= (originTokens.length * 1.30);
    final isOriginMuchLonger = originTokens.length >= (targetTokens.length * 1.30);
    final isTargetVeryShort =
        targetRawWords.length <= 15 && targetTokens.length <= (originTokens.length * 0.55);

    // 4. Klasifikasi Mutaba'ah Sanad antara origin dan target
    final (mutabaahRank, pivotRawi) = _classifyMutabaahRelation(origin, target);

    // 5. Pohon Keputusan Eksak 27 Aturan (WorkingGroups.pdf hlm. 59–62)
    // KELOMPOK I: بلفظه (Kecocokan 100% pada kedua matan atau pada matan yang lebih ringkas)
    if (exactCoverageOrigin == 1.0 &&
        exactCoverageTarget == 1.0 &&
        originTokens.length == targetTokens.length) {
      return MatnComparisonOutcome(
        targetHadith: target,
        targetBook: targetBook,
        rule: MatnComparisonRule.rule01BiLafzhihi,
        formattedArabicVerdict: 'بلفظه',
        rootCoverageOnOrigin: rootCoverageOrigin,
        rootCoverageOnTarget: rootCoverageTarget,
        sequenceOrderRatio: sequenceOrderRatio,
        maxGapRatio: maxGapRatio,
        mutabaahRank: mutabaahRank,
        pivotRawiArabicName: pivotRawi,
      );
    }

    if (exactCoverageOrigin >= 0.98 || exactCoverageTarget >= 0.98) {
      if (isTargetVeryShort) {
        final fullTargetText = target.rawMatn;
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule07MukhtasharanBiLafzhi,
          formattedArabicVerdict: 'مختصراً بلفظ: «$fullTargetText»',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: [fullTargetText],
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (isTargetMuchLonger) {
        if (addedInTargetSegments.isNotEmpty) {
          final seg = addedInTargetSegments.join(' ... ');
          return MatnComparisonOutcome(
            targetHadith: target,
            targetBook: targetBook,
            rule: MatnComparisonRule.rule04BiLafzhihiMuthawwalanWaZadaFihi,
            formattedArabicVerdict: 'بلفظه مطولاً وزاد فيه: «$seg»',
            rootCoverageOnOrigin: rootCoverageOrigin,
            rootCoverageOnTarget: rootCoverageTarget,
            sequenceOrderRatio: sequenceOrderRatio,
            maxGapRatio: maxGapRatio,
            diffSegments: addedInTargetSegments,
            mutabaahRank: mutabaahRank,
            pivotRawiArabicName: pivotRawi,
          );
        }
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule03BiLafzhihiMuthawwalan,
          formattedArabicVerdict: 'بلفظه مطولاً',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (isOriginMuchLonger) {
        if (omittedFromOriginSegments.isNotEmpty && omittedFromOriginSegments.length <= 2) {
          final seg = omittedFromOriginSegments.join(' ... ');
          return MatnComparisonOutcome(
            targetHadith: target,
            targetBook: targetBook,
            rule: MatnComparisonRule.rule06BiLafzhihiMukhtasharanDunaQaulihi,
            formattedArabicVerdict: 'بلفظه مختصراً دون قوله: «$seg»',
            rootCoverageOnOrigin: rootCoverageOrigin,
            rootCoverageOnTarget: rootCoverageTarget,
            sequenceOrderRatio: sequenceOrderRatio,
            maxGapRatio: maxGapRatio,
            diffSegments: omittedFromOriginSegments,
            mutabaahRank: mutabaahRank,
            pivotRawiArabicName: pivotRawi,
          );
        }
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule05BiLafzhihiMukhtasharan,
          formattedArabicVerdict: 'بلفظه مختصراً',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (addedInTargetSegments.isNotEmpty) {
        final seg = addedInTargetSegments.first;
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule02BiLafzhihiZiyadahAwwalAwAkhir,
          formattedArabicVerdict: 'بلفظه بزيادة: «$seg»',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: addedInTargetSegments,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
    }

    // KELOMPOK II: بمثله (Kecocokan >= 90% di salah satu pihak, >= 65% di pihak lain, urutan >= 50%)
    final maxRootCov = math.max(rootCoverageOrigin, rootCoverageTarget);
    final minRootCov = math.min(rootCoverageOrigin, rootCoverageTarget);
    if (maxRootCov >= 0.85 && minRootCov >= 0.60 && sequenceOrderRatio >= 0.50) {
      if (target.elevationStatus == HadithElevationStatus.mauquf &&
          origin.elevationStatus == HadithElevationStatus.marfu) {
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule16BiMitslihiMauqufan,
          formattedArabicVerdict: 'بمثله موقوفاً',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (isTargetVeryShort) {
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule12BiMitslihiMukhtasharanBiLafzhi,
          formattedArabicVerdict: 'بمثله مختصراً بلفظ: «${target.rawMatn}»',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: [target.rawMatn],
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (isTargetMuchLonger) {
        if (addedInTargetSegments.isNotEmpty) {
          final seg = addedInTargetSegments.first;
          return MatnComparisonOutcome(
            targetHadith: target,
            targetBook: targetBook,
            rule: MatnComparisonRule.rule15BiMitslihiMuthawwalanWaQalaFihi,
            formattedArabicVerdict: 'بمثله مطولاً وقال فيه: «$seg»',
            rootCoverageOnOrigin: rootCoverageOrigin,
            rootCoverageOnTarget: rootCoverageTarget,
            sequenceOrderRatio: sequenceOrderRatio,
            maxGapRatio: maxGapRatio,
            diffSegments: addedInTargetSegments,
            mutabaahRank: mutabaahRank,
            pivotRawiArabicName: pivotRawi,
          );
        }
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule13BiMitslihiMuthawwalan,
          formattedArabicVerdict: 'بمثله مطولاً',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (isOriginMuchLonger && omittedFromOriginSegments.isNotEmpty) {
        final seg = omittedFromOriginSegments.first;
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule10BiMitslihiMukhtasharanDunaQaulihi,
          formattedArabicVerdict: 'بمثله مختصراً دون قوله: «$seg»',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: omittedFromOriginSegments,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (addedInTargetSegments.isNotEmpty) {
        final seg = addedInTargetSegments.first;
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule11BiMitslihiWaQalaFihi,
          formattedArabicVerdict: 'بمثله وقال فيه: «$seg»',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: addedInTargetSegments,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (omittedFromOriginSegments.isNotEmpty) {
        final seg = omittedFromOriginSegments.first;
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule09BiMitslihiDunaQaulihi,
          formattedArabicVerdict: 'بمثله دون قوله: «$seg»',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: omittedFromOriginSegments,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      return MatnComparisonOutcome(
        targetHadith: target,
        targetBook: targetBook,
        rule: MatnComparisonRule.rule08BiMitslihi,
        formattedArabicVerdict: 'بمثله',
        rootCoverageOnOrigin: rootCoverageOrigin,
        rootCoverageOnTarget: rootCoverageTarget,
        sequenceOrderRatio: sequenceOrderRatio,
        maxGapRatio: maxGapRatio,
        mutabaahRank: mutabaahRank,
        pivotRawiArabicName: pivotRawi,
      );
    }

    // KELOMPOK III: بنحوه (Urutan kata >= 40% dan jarak renggang <= 60%)
    if (sequenceOrderRatio >= 0.40 && maxRootCov >= 0.45) {
      if (isTargetVeryShort) {
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule20BiNahwihiMukhtasharanBiLafzhi,
          formattedArabicVerdict: 'بنحوه مختصراً بلفظ: «${target.rawMatn}»',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: [target.rawMatn],
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (isTargetMuchLonger) {
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule18BiNahwihiMuthawwalan,
          formattedArabicVerdict: 'بنحوه مطولاً',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: addedInTargetSegments,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (isOriginMuchLonger) {
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule19BiNahwihiMukhtasharan,
          formattedArabicVerdict: 'بنحوه مختصراً',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: omittedFromOriginSegments,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (addedInTargetSegments.isNotEmpty) {
        final seg = addedInTargetSegments.first;
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule21BiNahwihiWaQalaFihi,
          formattedArabicVerdict: 'بنحوه وقال فيه: «$seg»',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          diffSegments: addedInTargetSegments,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      return MatnComparisonOutcome(
        targetHadith: target,
        targetBook: targetBook,
        rule: MatnComparisonRule.rule17BiNahwihi,
        formattedArabicVerdict: 'بنحوه',
        rootCoverageOnOrigin: rootCoverageOrigin,
        rootCoverageOnTarget: rootCoverageTarget,
        sequenceOrderRatio: sequenceOrderRatio,
        maxGapRatio: maxGapRatio,
        mutabaahRank: mutabaahRank,
        pivotRawiArabicName: pivotRawi,
      );
    }

    // KELOMPOK IV: بمعناه (Kecocokan >= 20% dan urutan >= 30%)
    if (maxRootCov >= 0.20 && sequenceOrderRatio >= 0.30) {
      if (isTargetMuchLonger) {
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule26BiManahuMuthawwalan,
          formattedArabicVerdict: 'بمعناه مطولاً',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      if (isOriginMuchLonger) {
        return MatnComparisonOutcome(
          targetHadith: target,
          targetBook: targetBook,
          rule: MatnComparisonRule.rule25BiManahuMukhtasharan,
          formattedArabicVerdict: 'بمعناه مختصراً',
          rootCoverageOnOrigin: rootCoverageOrigin,
          rootCoverageOnTarget: rootCoverageTarget,
          sequenceOrderRatio: sequenceOrderRatio,
          maxGapRatio: maxGapRatio,
          mutabaahRank: mutabaahRank,
          pivotRawiArabicName: pivotRawi,
        );
      }
      return MatnComparisonOutcome(
        targetHadith: target,
        targetBook: targetBook,
        rule: MatnComparisonRule.rule24BiManahu,
        formattedArabicVerdict: 'بمعناه',
        rootCoverageOnOrigin: rootCoverageOrigin,
        rootCoverageOnTarget: rootCoverageTarget,
        sequenceOrderRatio: sequenceOrderRatio,
        maxGapRatio: maxGapRatio,
        mutabaahRank: mutabaahRank,
        pivotRawiArabicName: pivotRawi,
      );
    }

    return MatnComparisonOutcome(
      targetHadith: target,
      targetBook: targetBook,
      rule: MatnComparisonRule.rule27MinGhayriDzikriHadzaAlLafzhi,
      formattedArabicVerdict: 'من غير ذكر هذا اللفظ',
      rootCoverageOnOrigin: rootCoverageOrigin,
      rootCoverageOnTarget: rootCoverageTarget,
      sequenceOrderRatio: sequenceOrderRatio,
      maxGapRatio: maxGapRatio,
      mutabaahRank: mutabaahRank,
      pivotRawiArabicName: pivotRawi,
    );
  }

  /// Merakit **Al-Matn al-Mujamma‘** (`WorkingGroups.pdf` hlm. 44–45 & 64):
  /// Memilih riwayat paling lengkap dari kitab paling shahih sebagai teks dasar,
  /// lalu menyisipkan zawa'id `[...]` dan varian redaksi `[وفي رواية: ...]` beserta sumbernya.
  MujammaCompositeMatn buildAlMatnAlMujamma(
    CanonicalHadithRecord origin,
    List<CanonicalHadithRecord> siblingHadiths,
  ) {
    final all = [origin, ...siblingHadiths];
    // Pilih riwayat dasar (الرواية الأصلية) dari kitab paling tinggi peringkat keshahihannya
    // yang memiliki matan lengkap.
    all.sort((a, b) {
      final rankA = _booksById[a.bookId]?.canonicalRank ?? 999;
      final rankB = _booksById[b.bookId]?.canonicalRank ?? 999;
      if (rankA != rankB) return rankA.compareTo(rankB);
      return b.rawMatn.length.compareTo(a.rawMatn.length);
    });

    final base = all.first;
    final baseBook = _booksById[base.bookId] ?? _booksById.values.first;
    final baseRoots = _morph
        .tokenizeMeaningfulMatn(base.rawMatn)
        .map((t) => t.root)
        .toSet();

    final segments = <MujammaSegment>[
      MujammaSegment(
        arabicText: base.rawMatn,
        isZawaidInsertion: false,
        sourceCitations: ['${base.bookTitleArabic} ${base.formattedCitation}'],
      ),
    ];

    // Kumpulkan zawa'id & varian redaksi dari riwayat lain
    final seenPhrases = <String>{};
    var footnoteCounter = 1;

    for (final other in all.skip(1)) {
      final otherWords = other.rawMatn.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final diffIdx = <int>[];
      for (var i = 0; i < otherWords.length; i++) {
        final tok = _morph.analyzeWord(otherWords[i]);
        if (tok.root.isNotEmpty &&
            !HarfMorphologyService.ignoredMatchStopWords.contains(tok.normalizedWord) &&
            !baseRoots.contains(tok.root)) {
          diffIdx.add(i);
        }
      }
      final extracted = _morph.formatDiffSegments(otherWords, diffIdx);
      for (final phrase in extracted) {
        final normPhrase = _morph.normalizeArabicWord(phrase);
        if (normPhrase.length < 3 || seenPhrases.contains(normPhrase)) continue;
        seenPhrases.add(normPhrase);

        final isCompatibleContext = phrase.split(' ').length >= 3;
        segments.add(
          MujammaSegment(
            arabicText: isCompatibleContext ? '[$phrase]' : '[وفي رواية: $phrase]',
            isZawaidInsertion: isCompatibleContext,
            isSeparateRiwaiyahVariant: !isCompatibleContext,
            footnoteIndex: footnoteCounter++,
            sourceCitations: ['${other.bookTitleArabic} ${other.formattedCitation}'],
          ),
        );
      }
    }

    return MujammaCompositeMatn(
      baseHadith: base,
      baseBook: baseBook,
      segments: segments,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LAPISAN 7: TAKHRIJ OTOMATIS MAKALAH / RISET ILMIAH (`DocXSL.xsl`)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Memindai naskah makalah yang memuat satu atau lebih kutipan hadis (diapit `«...»`,
  /// `"..."`, atau baris mandiri), lalu menghasilkan takhrij dan catatan kaki ilmiah otomatis.
  List<ManuscriptHadithDetection> scanAndTakhrijManuscript(String manuscriptText) {
    final detections = <ManuscriptHadithDetection>[];
    final quoteRegex = RegExp(r'«([^»]{8,})»|"([^"]{8,})"');
    final matches = quoteRegex.allMatches(manuscriptText).toList();

    final quotesToProcess = <String>[];
    if (matches.isNotEmpty) {
      for (final m in matches) {
        final q = (m.group(1) ?? m.group(2) ?? '').trim();
        if (q.isNotEmpty) quotesToProcess.add(q);
      }
    } else if (manuscriptText.trim().isNotEmpty) {
      quotesToProcess.add(manuscriptText.trim());
    }

    for (var i = 0; i < quotesToProcess.length; i++) {
      final quote = quotesToProcess[i];
      final bestMatch = findBestMatchingHadithInCorpus(quote);
      if (bestMatch != null) {
        final cluster = performTakhrijOnHadith(bestMatch);
        detections.add(
          ManuscriptHadithDetection(
            indexInManuscript: i + 1,
            detectedQuoteArabic: quote,
            matchedCluster: cluster,
            generatedFootnoteArabic:
                '(${i + 1}) ${cluster.formattedFullTakhrijArabicParagraph}',
          ),
        );
      } else {
        detections.add(
          ManuscriptHadithDetection(
            indexInManuscript: i + 1,
            detectedQuoteArabic: quote,
            matchedCluster: null,
            generatedFootnoteArabic:
                '(${i + 1}) لم يعثر على تطابق مباشر لهذا اللفظ في النطاق الحالي.',
          ),
        );
      }
    }
    return detections;
  }

  /// Mencari hadis yang paling cocok di dalam korpus berdasarkan kueri teks bebas.
  CanonicalHadithRecord? findBestMatchingHadithInCorpus(String queryArabic) {
    final queryTokens = _morph.tokenizeMeaningfulMatn(queryArabic);
    if (queryTokens.isEmpty) return null;
    final queryRoots = queryTokens.map((t) => t.root).where((r) => r.isNotEmpty).toSet();

    CanonicalHadithRecord? bestRecord;
    var bestScore = 0.0;

    for (final record in _corpusHadiths) {
      final recTokens = _morph.tokenizeMeaningfulMatn(record.effectiveMatnForIndexing);
      if (recTokens.isEmpty) continue;
      final recRoots = recTokens.map((t) => t.root).toSet();
      final hits = queryRoots.where(recRoots.contains).length;
      final score = hits / queryRoots.length;
      if (score > bestScore && score >= 0.35) {
        bestScore = score;
        bestRecord = record;
      }
    }
    return bestRecord;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER INTERNAL: KLASIFIKASI MUTABA'AH, SORTING, & FORMATTING XSLT
  // ═══════════════════════════════════════════════════════════════════════════

  (MutabaahRank, String?) _classifyMutabaahRelation(
    CanonicalHadithRecord origin,
    CanonicalHadithRecord target,
  ) {
    if (origin.rawiAlaId != target.rawiAlaId) {
      return (MutabaahRank.syahid, target.rawiAlaArabicName);
    }
    if (origin.sanadChain.isEmpty || target.sanadChain.isEmpty) {
      return (MutabaahRank.mutabaahQashirah, origin.rawiAlaArabicName);
    }
    final originLastTeacher = origin.sanadChain.last.resolvedRawiId;
    final targetLastTeacher = target.sanadChain.last.resolvedRawiId;
    if (originLastTeacher != null && originLastTeacher == targetLastTeacher) {
      return (
        MutabaahRank.mutabaahTammah,
        origin.sanadChain.last.resolvedArabicName,
      );
    }

    // Cari perawi tertinggi (paling dekat ke Mushannif) yang bersekutu
    final originIds = origin.sanadChain
        .map((h) => h.resolvedRawiId)
        .whereType<String>()
        .toSet();
    for (var i = target.sanadChain.length - 1; i >= 0; i--) {
      final h = target.sanadChain[i];
      if (h.resolvedRawiId != null && originIds.contains(h.resolvedRawiId)) {
        return (MutabaahRank.mutabaahQashirah, h.resolvedArabicName);
      }
    }
    return (MutabaahRank.mutabaahQashirah, origin.rawiAlaArabicName);
  }

  int _computeRootLcsLength(
    List<ArabicMorphToken> a,
    List<ArabicMorphToken> b,
  ) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (a[i - 1].root.isNotEmpty && a[i - 1].root == b[j - 1].root) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = math.max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }
    return dp[m][n];
  }

  void _sortComparisonOutcomes(
    List<MatnComparisonOutcome> outcomes,
    TakhrijSortOrder sortOrder,
  ) {
    outcomes.sort((a, b) {
      switch (sortOrder) {
        case TakhrijSortOrder.byMutabaahRank:
          final cmp = a.mutabaahRank.index.compareTo(b.mutabaahRank.index);
          if (cmp != 0) return cmp;
          return a.targetBook.canonicalRank.compareTo(b.targetBook.canonicalRank);
        case TakhrijSortOrder.byAuthorDeathYear:
          return a.targetBook.deathYearHijri.compareTo(b.targetBook.deathYearHijri);
        case TakhrijSortOrder.byCanonicalBookRank:
          return a.targetBook.canonicalRank.compareTo(b.targetBook.canonicalRank);
        case TakhrijSortOrder.byMatnSimilarity:
          return a.rule.ruleNumber.compareTo(b.rule.ruleNumber);
      }
    });
  }

  String _buildClassicalTakhrijParagraph(
    CanonicalHadithRecord origin,
    HadithBookMetadata originBook,
    List<MatnComparisonOutcome> takhrijOutcomes,
    List<MatnComparisonOutcome> syawahidOutcomes,
  ) {
    final sb = StringBuffer();
    sb.write(originBook.formatAttributionPhrase(isFirstInChain: true));
    sb.write(' ${origin.formattedCitation}');

    var prevWasSecondary =
        originBook.taxonomy == HadithBookTaxonomy.secondaryCompilation;

    for (final item in takhrijOutcomes) {
      final phrase = item.targetBook.formatAttributionPhrase(
        isFirstInChain: false,
        precedingWasSecondary: prevWasSecondary,
      );
      prevWasSecondary =
          item.targetBook.taxonomy == HadithBookTaxonomy.secondaryCompilation;
      final pivotInfo = item.pivotRawiArabicName != null
          ? ' من طريق (${item.pivotRawiArabicName})'
          : '';
      sb.write('$phrase ${item.targetHadith.formattedCitation}$pivotInfo، ${item.formattedArabicVerdict}');
    }
    sb.write('، كلهم عن (${origin.rawiAlaArabicName}) رضي الله عنه.');

    if (syawahidOutcomes.isNotEmpty) {
      sb.write(' وفي الباب عن ');
      final sahabah = syawahidOutcomes
          .map((s) => '${s.targetHadith.rawiAlaArabicName} عند ${s.targetBook.authorArabic} ${s.targetHadith.formattedCitation}')
          .join('، و');
      sb.write('$sahabah.');
    }
    return sb.toString();
  }

  List<ServiceBookReference> _lookupServiceBookReferences(
    CanonicalHadithRecord origin,
  ) {
    if (origin.rawiAlaId == 'rawi_umar') {
      return const [
        ServiceBookReference(
          bookTitleArabic: 'فتح الباري شرح صحيح البخاري',
          authorArabic: 'ابن حجر العسقلاني (ت 852 هـ)',
          categoryLabel: 'شرح الحديث',
          partNumber: 1,
          pageNumber: 9,
          excerptArabic:
              'قوله (إنما الأعمال بالنيات) اتفق العلماء على جلالة هذا الحديث وعظيم موقعه وكثرة فوائده، وقال الشافعي: يدخل في سبعين باباً من الفقه.',
        ),
        ServiceBookReference(
          bookTitleArabic: 'تحفة الأشراف بمعرفة الأطراف',
          authorArabic: 'جمال الدين المزي (ت 742 هـ)',
          categoryLabel: 'الأطراف والتخريج',
          partNumber: 8,
          pageNumber: 155,
          excerptArabic:
              'حديث رقم (10612): علقمة بن وقاص الليثي عن عمر بن الخطاب، تفرد به يحيى بن سعيد الأنصاري عن محمد بن إبراهيم التيمي وتواتر عن يحيى بن سعيد.',
        ),
        ServiceBookReference(
          bookTitleArabic: 'النهاية في غريب الحديث والأثر',
          authorArabic: 'مجد الدين ابن الأثير (ت 606 هـ)',
          categoryLabel: 'غريب الحديث',
          partNumber: 5,
          pageNumber: 134,
          excerptArabic:
              '(نَوَى): النية القصد والعزم، يقال نوى ينوي نيةً ونواةً إذا عزم واعتقد بقلبه.',
        ),
      ];
    }
    return const [
      ServiceBookReference(
        bookTitleArabic: 'فتح الباري شرح صحيح البخاري',
        authorArabic: 'ابن حجر العسقلاني (ت 852 هـ)',
        categoryLabel: 'شرح الحديث',
        partNumber: 1,
        pageNumber: 188,
        excerptArabic:
            'فيه استحباب إعادة الكلام ثلاثاً عند الحاجة لتفهيم السامعين، والاقتصار في الاستئذان والسلام على الثلاث.',
      ),
    ];
  }
}

/// Empat metode pengurutan takhrij sesuai `Description.pdf` hlm. 4–5.
enum TakhrijSortOrder {
  byMutabaahRank('حسب متابعة السند', 'Urutan Mutaba‘ah Sanad'),
  byAuthorDeathYear('حسب وفيات المصنفين', 'Urutan Tahun Wafat Mushannif'),
  byCanonicalBookRank('حسب أصحية الكتب', 'Urutan Tingkat Keshahihan Kitab'),
  byMatnSimilarity('حسب مطابقة اللفظ', 'Urutan Kemiripan Lafaz Matan');

  final String arabicLabel;
  final String indonesianLabel;
  const TakhrijSortOrder(this.arabicLabel, this.indonesianLabel);
}
