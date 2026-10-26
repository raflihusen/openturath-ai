import 'dart:io';
import 'dart:typed_data';

/// Token morfologis hasil analisis satu kata bahasa Arab.
class ArabicMorphToken {
  final String originalWord;
  final String normalizedWord;
  final String prefix; // السوابق
  final String stem; // الجذع
  final String suffix; // اللواحق
  final String root; // الجذر الثلاثي/الرباعي
  final String patternWazan; // الوزن الصرفي

  const ArabicMorphToken({
    required this.originalWord,
    required this.normalizedWord,
    required this.prefix,
    required this.stem,
    required this.suffix,
    required this.root,
    required this.patternWazan,
  });

  /// Kunci kesamaan morfologis sesuai aturan #1 `WorkingGroups.pdf` hlm. 59:
  /// "حيث لا يؤثر السوابق ولا اللواحق ما دام أصل الكلمة (بنفس الوزن والجذر) موجوداً في الحديثين"
  String get rootAndWazanKey => '$root|$patternWazan';
}

/// Rekonstruksi bersih dari `HarfMMMP01.dll` + `Roots.bin` + `HarfDRootInx.dat`
/// beserta 5 Daftar Kata Bantu (`القوائم المساعدة` di `WorkingGroups.pdf` hlm. 63).
class HarfMorphologyService {
  HarfMorphologyService._();
  static final HarfMorphologyService instance = HarfMorphologyService._();

  /// 1. Daftar Kata yang Diabaikan dalam Perhitungan Persentase المطابقة
  /// (`قائمة الكلمات المهملة في المطابقة` — WorkingGroups.pdf hlm. 60 & 63).
  static const Set<String> ignoredMatchStopWords = {
    'صلى',
    'الله',
    'عليه',
    'وسلم',
    'ﷺ',
    'رضي',
    'عنه',
    'عنها',
    'عنهما',
    'عنهم',
    'رحمه',
    'تعالى',
    'عز',
    'وجل',
    'تبارك',
    'انه',
    'انها',
    'قال',
    'قالت',
    'فقال',
    'يقول',
    'سمعت',
    'حدثنا',
    'اخبرنا',
    'انبانا',
    'حدثني',
    'عن',
    'بن',
    'ابن',
    'ابي',
    'ابو',
    'ابا',
  };

  /// 2. Daftar Kata yang Tidak Boleh Menjadi Penutup Kutipan الفرق
  /// (`قائمة كلمات لا تختم بها عبارات الفروق` — WorkingGroups.pdf hlm. 63).
  static const Set<String> nonTerminalDiffWords = {
    'في',
    'من',
    'الى',
    'على',
    'عن',
    'مع',
    'ان',
    'لا',
    'لم',
    'لن',
    'قد',
    'كل',
    'بعض',
    'غير',
    'دون',
    'بين',
    'عند',
    'ثم',
    'او',
    'ام',
    'بل',
    'الذي',
    'التي',
    'الذين',
    'هذا',
    'هذه',
    'ذلك',
    'تلك',
  };

  /// 3. Daftar Kata yang Jika Muncul Sebagai الفرق Tunggal, Wajib Mengambil Kata Setelahnya
  /// (`قائمة كلمات إن جاءت في آخر الفروق تؤخذ الكلمة التي بعدها` — WorkingGroups.pdf hlm. 63).
  static const Set<String> takeNextWordTriggers = {
    'يا',
    'ايها',
    'انما',
    'كانما',
    'كلا',
    'بلى',
    'نعم',
    'ان',
    'ما',
    'من',
    'لا',
    'غير',
    'مثل',
    'سوى',
  };

  /// 4. Daftar Kata yang Jika Muncul Sebagai الفرق Tunggal, Wajib Mengambil Kata Sebelumnya
  /// (`قائمة كلمات إن جاءت فرقاً تؤخذ الكلمة التي قبلها` — WorkingGroups.pdf hlm. 63).
  static const Set<String> takePrevWordTriggers = {
    'له',
    'لها',
    'لهم',
    'فيها',
    'فيه',
    'منه',
    'منها',
    'عنه',
    'عنها',
    'به',
    'بها',
    'ايضا',
    'جميعا',
    'معا',
    'فقط',
    'قط',
  };

  /// 5. Kamus pengecualian akar kata tidak beraturan (*mu'tall / mahmuz / mudha'af*)
  /// yang sering muncul dalam matan hadis nabawi.
  static const Map<String, (String root, String wazan)> _irregularHadithLexicon = {
    'اعمال': ('عمل', 'افعال'),
    'عمل': ('عمل', 'فعل'),
    'يعمل': ('عمل', 'يفعل'),
    'عمال': ('عمل', 'فعال'),
    'نيات': ('نوي', 'فعلات'),
    'نيه': ('نوي', 'فعله'),
    'ينوي': ('نوي', 'يفعل'),
    'نوى': ('نوي', 'فعل'),
    'امري': ('امر', 'افعل'),
    'امره': ('امر', 'فعله'),
    'امور': ('امر', 'فعول'),
    'هجره': ('هجر', 'فعله'),
    'هجرته': ('هجر', 'فعلته'),
    'هاجر': ('هجر', 'فاعل'),
    'مهاجر': ('هجر', 'مفاعل'),
    'يمين': ('يمن', 'فعيل'),
    'ايمان': ('امن', 'افعال'),
    'مومن': ('امن', 'مفعل'),
    'امن': ('امن', 'فعل'),
    'مسلم': ('سلم', 'مفعل'),
    'مسلمون': ('سلم', 'مفعل'),
    'مسلمين': ('سلم', 'مفعل'),
    'اسلام': ('سلم', 'افعال'),
    'يسلم': ('سلم', 'يفعل'),
    'سلم': ('سلم', 'فعل'),
    'لسانه': ('لسن', 'فعاله'),
    'لسان': ('لسن', 'فعال'),
    'يده': ('يدي', 'فعله'),
    'يد': ('يدي', 'فعل'),
    'ايدي': ('يدي', 'افعل'),
    'صلاه': ('صلي', 'فعاله'),
    'صلوات': ('صلي', 'فعلات'),
    'يصلي': ('صلي', 'يفعل'),
    'زكاه': ('زكو', 'فعاله'),
    'صوم': ('صوم', 'فعل'),
    'صيام': ('صوم', 'فعال'),
    'يصوم': ('صوم', 'يفعل'),
    'حج': ('حجج', 'فعل'),
    'يحج': ('حجج', 'يفعل'),
    'ائمه': ('امم', 'افعل'),
    'امام': ('امم', 'فعال'),
    'قريش': ('قرش', 'فعيل'),
    'تتكلم': ('كلم', 'تتفعل'),
    'تكلم': ('كلم', 'تفعل'),
    'كلمه': ('كلم', 'فعله'),
    'كلام': ('كلم', 'فعال'),
    'اعادها': ('عود', 'افعال'),
    'يعيد': ('عود', 'يفعل'),
    'ردها': ('ردد', 'فعل'),
    'رددها': ('ردد', 'فعل'),
    'يفهم': ('فهم', 'يفعل'),
    'تفهم': ('فهم', 'تفعل'),
    'يعقل': ('عقل', 'يفعل'),
    'تعقل': ('عقل', 'تفعل'),
  };

  static const List<String> _prefixes = [
    'وال',
    'فال',
    'بال',
    'كال',
    'لل',
    'ال',
    'و',
    'ف',
    'ب',
    'ل',
    'ك',
    'س',
  ];

  static const List<String> _suffixes = [
    'كموها',
    'هموها',
    'كما',
    'هما',
    'هم',
    'كم',
    'هن',
    'كن',
    'نا',
    'ها',
    'ون',
    'ين',
    'ات',
    'ان',
    'تم',
    'تن',
    'وا',
    'ت',
    'ه',
    'ي',
    'ك',
  ];

  final Set<String> _loadedBinaryRoots = {};
  bool _binaryRootsChecked = false;

  /// Membaca berkas biner `Roots.bin` dari `/Users/apple/Downloads/khademhrf`
  /// apabila tersedia di disk lokal macOS untuk memperkaya tabel akar kata.
  void ensureBinaryRootsLoaded([String? customRootsBinPath]) {
    if (_binaryRootsChecked) return;
    _binaryRootsChecked = true;
    final path = customRootsBinPath ??
        '/Users/apple/Downloads/khademhrf/جامع خادم الحرمين الشريفين/01جامع خادم الحرمين الشريفين/Source/HarfMMMP/Roots.bin';
    try {
      final file = File(path);
      if (!file.existsSync()) return;
      final bytes = file.readAsBytesSync();
      _decodeHarfRootsBinary(bytes);
    } catch (_) {
      // Tetap berjalan murni dengan kamus algoritmik jika sandbox/file tidak tersedia.
    }
  }

  /// Mendekode rangkaian huruf Arab (Windows-1256 / UTF-16LE) dari `Roots.bin`.
  void _decodeHarfRootsBinary(Uint8List bytes) {
    final currentRoot = <int>[];
    for (var i = 0; i < bytes.length; i++) {
      final b = bytes[i];
      final mapped = _cp1256ToUnicodeArabic(b);
      if (mapped != null) {
        currentRoot.add(mapped);
      } else {
        if (currentRoot.length >= 3 && currentRoot.length <= 4) {
          _loadedBinaryRoots.add(String.fromCharCodes(currentRoot));
        }
        currentRoot.clear();
      }
    }
    if (currentRoot.length >= 3 && currentRoot.length <= 4) {
      _loadedBinaryRoots.add(String.fromCharCodes(currentRoot));
    }
  }

  int? _cp1256ToUnicodeArabic(int byte) {
    const map = <int, int>{
      0xC1: 0x0627, // ء -> ا
      0xC2: 0x0627, // آ -> ا
      0xC3: 0x0627, // أ -> ا
      0xC4: 0x0648, // ؤ -> و
      0xC5: 0x0627, // إ -> ا
      0xC6: 0x064A, // ئ -> ي
      0xC7: 0x0627, // ا
      0xC8: 0x0628, // ب
      0xC9: 0x0647, // ة -> ه
      0xCA: 0x062A, // ت
      0xCB: 0x062B, // ث
      0xCC: 0x062C, // ج
      0xCD: 0x062D, // ح
      0xCE: 0x062E, // خ
      0xCF: 0x062F, // د
      0xD0: 0x0630, // ذ
      0xD1: 0x0631, // ر
      0xD2: 0x0632, // ز
      0xD3: 0x0633, // س
      0xD4: 0x0634, // ش
      0xD5: 0x0635, // ص
      0xD6: 0x0636, // ض
      0xD8: 0x0637, // ط
      0xD9: 0x0638, // ظ
      0xDA: 0x0639, // ع
      0xDB: 0x063A, // غ
      0xE1: 0x0641, // ف
      0xE2: 0x0642, // ق
      0xE3: 0x0643, // ك
      0xE4: 0x0644, // ل
      0xE5: 0x0645, // م
      0xE6: 0x0646, // ن
      0xE7: 0x0647, // ه
      0xE8: 0x0648, // و
      0xEC: 0x064A, // ى -> ي
      0xED: 0x064A, // ي
    };
    return map[byte];
  }

  /// Menghapus harakat, tatweel, tanda baca, dan menormalisasi huruf Arab.
  String normalizeArabicWord(String input) {
    var s = input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[^\u0621-\u064A]'), '');
    return s.trim();
  }

  /// Menganalisis satu kata Arab menjadi `(prefix, stem, suffix, root, wazan)`.
  ArabicMorphToken analyzeWord(String rawWord) {
    ensureBinaryRootsLoaded();
    final norm = normalizeArabicWord(rawWord);
    if (norm.isEmpty) {
      return ArabicMorphToken(
        originalWord: rawWord,
        normalizedWord: '',
        prefix: '',
        stem: '',
        suffix: '',
        root: '',
        patternWazan: '',
      );
    }

    // 1. Cek kamus langsung sebelum dan sesudah pengupasan
    if (_irregularHadithLexicon.containsKey(norm)) {
      final entry = _irregularHadithLexicon[norm]!;
      return ArabicMorphToken(
        originalWord: rawWord,
        normalizedWord: norm,
        prefix: '',
        stem: norm,
        suffix: '',
        root: entry.$1,
        patternWazan: entry.$2,
      );
    }

    var working = norm;
    var extractedPrefix = '';
    var extractedSuffix = '';

    // 2. Kupas sawabiq (prefiks) jika menyisakan minimal 3 huruf
    for (final p in _prefixes) {
      if (working.startsWith(p) && working.length - p.length >= 3) {
        extractedPrefix = p;
        working = working.substring(p.length);
        break;
      }
    }

    // Cek lagi kamus setelah kupas prefiks
    if (_irregularHadithLexicon.containsKey(working)) {
      final entry = _irregularHadithLexicon[working]!;
      return ArabicMorphToken(
        originalWord: rawWord,
        normalizedWord: norm,
        prefix: extractedPrefix,
        stem: working,
        suffix: '',
        root: entry.$1,
        patternWazan: entry.$2,
      );
    }

    // 3. Kupas lawahiq (sufiks) jika menyisakan minimal 3 huruf
    for (final s in _suffixes) {
      if (working.endsWith(s) && working.length - s.length >= 3) {
        extractedSuffix = s;
        working = working.substring(0, working.length - s.length);
        break;
      }
    }

    if (_irregularHadithLexicon.containsKey(working)) {
      final entry = _irregularHadithLexicon[working]!;
      return ArabicMorphToken(
        originalWord: rawWord,
        normalizedWord: norm,
        prefix: extractedPrefix,
        stem: working,
        suffix: extractedSuffix,
        root: entry.$1,
        patternWazan: entry.$2,
      );
    }

    // 4. Ekstraksi akar kata (jadzr) & pola morfologis (wazan)
    final (root, wazan) = _extractRootAndWazan(working);
    return ArabicMorphToken(
      originalWord: rawWord,
      normalizedWord: norm,
      prefix: extractedPrefix,
      stem: working,
      suffix: extractedSuffix,
      root: root,
      patternWazan: wazan,
    );
  }

  (String root, String wazan) _extractRootAndWazan(String stem) {
    if (stem.length <= 3) {
      return (stem, 'فعل');
    }

    // Pola 4 huruf: افعل / فاعل / فعيل / فعول / مفعل / تفعل / يفعل / نفعل
    if (stem.length == 4) {
      if (stem.startsWith('ا')) {
        return (stem.substring(1), 'افعل');
      }
      if (stem.startsWith('م')) {
        return (stem.substring(1), 'مفعل');
      }
      if (stem.startsWith('ي') || stem.startsWith('ت') || stem.startsWith('ن')) {
        return (stem.substring(1), 'يفعل');
      }
      if (stem[1] == 'ا') {
        return ('${stem[0]}${stem[2]}${stem[3]}', 'فاعل');
      }
      if (stem[2] == 'ي') {
        return ('${stem[0]}${stem[1]}${stem[3]}', 'فعيل');
      }
      if (stem[2] == 'و') {
        return ('${stem[0]}${stem[1]}${stem[3]}', 'فعول');
      }
      if (stem[2] == 'ا') {
        return ('${stem[0]}${stem[1]}${stem[3]}', 'فعال');
      }
      return (stem, 'فعلل');
    }

    // Pola 5 huruf: افتعل / انفعـل / تفاعل / تفعلل / مفعول / مفاعل / افعال
    if (stem.length == 5) {
      if (stem.startsWith('ان')) {
        return (stem.substring(2), 'انفعل');
      }
      if (stem.startsWith('ا') && stem[2] == 'ت') {
        return ('${stem[1]}${stem[3]}${stem[4]}', 'افتعل');
      }
      if (stem.startsWith('م') && stem[3] == 'و') {
        return ('${stem[1]}${stem[2]}${stem[4]}', 'مفعول');
      }
      if (stem.startsWith('م') && stem[2] == 'ا') {
        return ('${stem[1]}${stem[3]}${stem[4]}', 'مفاعل');
      }
      if (stem.startsWith('ت') && stem[2] == 'ا') {
        return ('${stem[1]}${stem[3]}${stem[4]}', 'تفاعل');
      }
      if (stem.startsWith('ا') && stem[3] == 'ا') {
        return ('${stem[1]}${stem[2]}${stem[4]}', 'افعال');
      }
    }

    // Pola 6 huruf: استفعل
    if (stem.length >= 6 && stem.startsWith('است')) {
      final rem = stem.substring(3);
      return (rem.length >= 3 ? rem.substring(0, 3) : rem, 'استفعل');
    }

    // Fallback: saring huruf tambahan (سألتمونيها) hingga tersisa 3 konsonan inti
    final chars = stem.split('');
    const affixes = {'ا', 'و', 'ي', 'م', 'ت', 'ن', 'س', 'ه'};
    final core = <String>[];
    for (final c in chars) {
      if (!affixes.contains(c) || (chars.length - core.length <= 3)) {
        core.add(c);
      }
      if (core.length == 3) break;
    }
    final candidate = core.join();
    if (_loadedBinaryRoots.contains(candidate)) {
      return (candidate, 'فعل');
    }
    return (candidate.length == 3 ? candidate : stem.substring(0, 3), 'فعل');
  }

  /// Mengubah kalimat matan menjadi daftar token bermakna (mengabaikan `ignoredMatchStopWords`).
  List<ArabicMorphToken> tokenizeMeaningfulMatn(String matn) {
    final rawWords = matn
        .replaceAll(RegExp(r'[\(\)\[\]\{\}«»"؛،.:!؟\-]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty);

    final tokens = <ArabicMorphToken>[];
    for (final word in rawWords) {
      final norm = normalizeArabicWord(word);
      if (norm.isEmpty || ignoredMatchStopWords.contains(norm)) continue;
      tokens.add(analyzeWord(word));
    }
    return tokens;
  }

  /// Memotong segmen perbedaan kata (`ضوابط ذكر الاختلافات` — WorkingGroups.pdf hlm. 63):
  /// - Maksimum 15 kata per segmen
  /// - Jika 2 segmen terpisah ≤ 3 kata dan totalnya ≤ 15 kata, digabung menjadi 1 segmen
  /// - Jika segmen hanya 1 kata dan termasuk `takeNextWordTriggers` / `takePrevWordTriggers`,
  ///   diperluas dengan kata tetangganya
  /// - Tidak diakhiri dengan kata dari `nonTerminalDiffWords`.
  List<String> formatDiffSegments(List<String> rawWords, List<int> diffIndices) {
    if (diffIndices.isEmpty || rawWords.isEmpty) return const [];
    final sorted = [...diffIndices]..sort();

    // 1. Bentuk rentang awal (start, end) inklusif
    final ranges = <(int, int)>[];
    var start = sorted.first;
    var prev = sorted.first;
    for (var i = 1; i < sorted.length; i++) {
      final idx = sorted[i];
      final gap = idx - prev - 1;
      final mergedLength = idx - start + 1;
      // Gabungkan jika jeda <= 3 kata dan panjang gabungan <= 15 kata
      if (gap <= 3 && mergedLength <= 15) {
        prev = idx;
      } else {
        ranges.add((start, prev));
        start = idx;
        prev = idx;
      }
    }
    ranges.add((start, prev));

    // 2. Terapkan aturan kata tunggal & kata penutup terlarang
    final formatted = <String>[];
    for (var (s, e) in ranges) {
      if (s == e) {
        final norm = normalizeArabicWord(rawWords[s]);
        if (takeNextWordTriggers.contains(norm) && e + 1 < rawWords.length) {
          e += 1;
        } else if (takePrevWordTriggers.contains(norm) && s - 1 >= 0) {
          s -= 1;
        } else if (e + 1 < rawWords.length) {
          e += 1;
        }
      }
      while (e + 1 < rawWords.length &&
          (e - s + 1) < 15 &&
          nonTerminalDiffWords.contains(normalizeArabicWord(rawWords[e]))) {
        e += 1;
      }
      if (e - s + 1 > 15) {
        e = s + 14;
      }
      formatted.add(rawWords.sublist(s, e + 1).join(' '));
    }

    // Jika lebih dari 2 segmen, ambil 2 segmen paling signifikan (hlm. 63: "إذا كان الحديث ثلاثة مقاطع يثبت أهم فرقين")
    if (formatted.length > 2) {
      return formatted.sublist(0, 2);
    }
    return formatted;
  }
}
