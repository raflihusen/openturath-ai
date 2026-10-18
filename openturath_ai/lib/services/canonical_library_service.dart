import 'package:flutter/services.dart';
import '../core/arabic_utils.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';

/// Service to load, cache, and search canonical book catalogs with diacritic-tolerant Arabic search.
class CanonicalLibraryService {
  CanonicalLibraryService._();
  static final CanonicalLibraryService instance = CanonicalLibraryService._();

  static const Map<String, String> _assetMapByField = {
    'fiqh': 'assets/data/01_KATALOG_FIKIH_SYAFII.json',
    'hadith': 'assets/data/02_KATALOG_HADITS_DAN_SYARAH.json',
    'usul': 'assets/data/03_KATALOG_USHUL_FIKIH.json',
    'lughah': 'assets/data/04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json',
    'tafsir': 'assets/data/05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json',
    'fiqh_tahawwulat': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
    'tarikh': 'assets/data/07_KATALOG_TARIKH_DAN_SIRAH_NABAWIYYAH.json',
    'tasawwuf': 'assets/data/14_KATALOG_TASAWWUF_DAN_ADZKAR.json',
    'aqidah': 'assets/data/18_KATALOG_AQIDAH_DAN_USHULUDDIN.json',
    'bibliografi': 'assets/data/26_KATALOG_BIBLIOGRAFI_DAN_FAHARIS.json',
  };

  static const Map<String, String> _assetMapByAgentId = {
    'fiqh_syafii': 'assets/data/01_KATALOG_FIKIH_SYAFII.json',
    'fiqh_syafii_muhaqqiq': 'assets/data/01_KATALOG_FIKIH_SYAFII.json',
    'hadits': 'assets/data/02_KATALOG_HADITS_DAN_SYARAH.json',
    'hadits_muhaqqiq': 'assets/data/02_KATALOG_HADITS_DAN_SYARAH.json',
    'ushul_fiqh': 'assets/data/03_KATALOG_USHUL_FIKIH.json',
    'ushul_muhaqqiq': 'assets/data/03_KATALOG_USHUL_FIKIH.json',
    'nahwu_sharaf': 'assets/data/04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json',
    'nahwu_sharaf_muerib': 'assets/data/04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json',
    'nahwu_sharaf_tashrif':
        'assets/data/04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json',
    'tafsir': 'assets/data/05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json',
    'tafsir_muhaqqiq': 'assets/data/05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json',
    'fiqh_tahawwulat': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
    'fiqh_tahawwulat_muhaqqiq': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
    'fiqh_tahawwulat_bayan': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
    'fiqh_tahawwulat_mukhtabir': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
    'fiqh_tahawwulat_habib': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
    'fiqh_tahawwulat_khatib': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
    'tarikh': 'assets/data/07_KATALOG_TARIKH_DAN_SIRAH_NABAWIYYAH.json',
    'fiqh_muqaran': 'assets/data/08_KATALOG_FIKIH_MUQARAN_DAN_UMUM.json',
    'fiqh_muqaran_muhaqqiq':
        'assets/data/08_KATALOG_FIKIH_MUQARAN_DAN_UMUM.json',
    'fatawa_masail': 'assets/data/08_KATALOG_FIKIH_MUQARAN_DAN_UMUM.json',
    'syarah_hadits': 'assets/data/10_KATALOG_SYARAH_HADITS.json',
    'fiqh_hanafi': 'assets/data/11_KATALOG_FIKIH_HANAFI.json',
    'fiqh_hanafi_muhaqqiq': 'assets/data/11_KATALOG_FIKIH_HANAFI.json',
    'fiqh_maliki': 'assets/data/12_KATALOG_FIKIH_MALIKI.json',
    'fiqh_maliki_muhaqqiq': 'assets/data/12_KATALOG_FIKIH_MALIKI.json',
    'fiqh_hanbali': 'assets/data/13_KATALOG_FIKIH_HANBALI.json',
    'fiqh_hanbali_muhaqqiq': 'assets/data/13_KATALOG_FIKIH_HANBALI.json',
    'habib_umar': 'assets/data/14_KATALOG_TASAWWUF_DAN_ADZKAR.json',
    'imam_ghazali': 'assets/data/14_KATALOG_TASAWWUF_DAN_ADZKAR.json',
    'tajwid_qiraat': 'assets/data/15_KATALOG_TAJWID_DAN_QIRAAT.json',
    'qawaid_fiqhiyyah': 'assets/data/03_KATALOG_USHUL_FIKIH.json',
    'musthalah_hadits':
        'assets/data/17_KATALOG_MUSTHALAH_DAN_ULUMUL_HADITS.json',
    'aqidah': 'assets/data/18_KATALOG_AQIDAH_DAN_USHULUDDIN.json',
    'thabaqat_rijal': 'assets/data/19_KATALOG_THABAQAT_DAN_TARAJIM.json',
    'bibliografi_faharis':
        'assets/data/26_KATALOG_BIBLIOGRAFI_DAN_FAHARIS.json',
  };

  static const Map<String, String> _assetMapByCatalogId = {
    'canonical_syafii': 'assets/data/01_KATALOG_FIKIH_SYAFII.json',
    'canonical_hadits': 'assets/data/02_KATALOG_HADITS_DAN_SYARAH.json',
    'canonical_ushul_fikih': 'assets/data/03_KATALOG_USHUL_FIKIH.json',
    'canonical_bahasa_arab':
        'assets/data/04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json',
    'canonical_tafsir': 'assets/data/05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json',
    'canonical_tahawwulat': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
    'canonical_tarikh':
        'assets/data/07_KATALOG_TARIKH_DAN_SIRAH_NABAWIYYAH.json',
    'canonical_fiqh_muqaran':
        'assets/data/08_KATALOG_FIKIH_MUQARAN_DAN_UMUM.json',
    'canonical_fatawa_masail':
        'assets/data/08_KATALOG_FIKIH_MUQARAN_DAN_UMUM.json',
    'canonical_syarah_hadits': 'assets/data/10_KATALOG_SYARAH_HADITS.json',
    'canonical_hanafi': 'assets/data/11_KATALOG_FIKIH_HANAFI.json',
    'canonical_maliki': 'assets/data/12_KATALOG_FIKIH_MALIKI.json',
    'canonical_hanbali': 'assets/data/13_KATALOG_FIKIH_HANBALI.json',
    'canonical_tasawuf': 'assets/data/14_KATALOG_TASAWWUF_DAN_ADZKAR.json',
    'canonical_ulumul_quran': 'assets/data/15_KATALOG_TAJWID_DAN_QIRAAT.json',
    'canonical_qawaid_fiqhiyyah': 'assets/data/03_KATALOG_USHUL_FIKIH.json',
    'canonical_musthalah_hadits':
        'assets/data/17_KATALOG_MUSTHALAH_DAN_ULUMUL_HADITS.json',
    'canonical_akidah': 'assets/data/18_KATALOG_AQIDAH_DAN_USHULUDDIN.json',
    'canonical_thabaqat_tarajim':
        'assets/data/19_KATALOG_THABAQAT_DAN_TARAJIM.json',
    'canonical_bibliografi':
        'assets/data/26_KATALOG_BIBLIOGRAFI_DAN_FAHARIS.json',
  };

  final Map<String, List<CanonicalBookPresentation>> _catalogCache = {};

  List<CanonicalBookPresentation>? _syafiiPresentations;

  /// Loads catalog for a specific agent or discipline.
  Future<List<CanonicalBookPresentation>> loadCatalogForAgent(
      AgentModel agent) async {
    final assetPath = (agent.catalogId != null
            ? _assetMapByCatalogId[agent.catalogId!]
            : null) ??
        _assetMapByAgentId[agent.id] ??
        _assetMapByField[agent.fieldId];
    if (assetPath == null) {
      if (agent.fieldId == 'fiqh') {
        return loadCatalogFromAsset('assets/data/01_KATALOG_FIKIH_SYAFII.json');
      }
      return [];
    }
    return loadCatalogFromAsset(assetPath);
  }

  /// Loads catalog from asset bundle with in-memory caching.
  Future<List<CanonicalBookPresentation>> loadCatalogFromAsset(
      String assetPath) async {
    if (_catalogCache.containsKey(assetPath)) {
      return _catalogCache[assetPath]!;
    }

    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final books = parseSyamilahCatalog(jsonStr);
      _catalogCache[assetPath] = books;
      if (assetPath.contains('01_KATALOG_FIKIH_SYAFII')) {
        _syafiiPresentations = books;
      }
      return books;
    } catch (e) {
      rethrow;
    }
  }

  /// Loads the canonical Syafi'i catalog from asset bundle (backwards compatible).
  Future<List<CanonicalBookPresentation>> loadSyafiiCatalog() async {
    if (_syafiiPresentations != null) {
      return _syafiiPresentations!;
    }
    return loadCatalogFromAsset('assets/data/01_KATALOG_FIKIH_SYAFII.json');
  }

  /// Get cached presentations or null if not yet loaded.
  List<CanonicalBookPresentation>? get cachedSyafiiBooks =>
      _syafiiPresentations;

  /// Filter books by query string with diacritic-tolerant Arabic & Latin normalization.
  List<CanonicalBookPresentation> filterBooks(
    List<CanonicalBookPresentation> books,
    String query, {
    String? eraFilter,
    String? typeFilter,
    String? sectionFilter,
    String? centuryFilter,
  }) {
    final cleanQuery = query.trim();

    return books.where((book) {
      if (eraFilter != null &&
          eraFilter.isNotEmpty &&
          book.reviewedEraLabel != eraFilter) {
        return false;
      }
      if (typeFilter != null &&
          typeFilter.isNotEmpty &&
          book.reviewedTypeLabel != typeFilter) {
        return false;
      }
      if (sectionFilter != null &&
          sectionFilter.isNotEmpty &&
          book.sectionArabic != sectionFilter) {
        return false;
      }
      if (centuryFilter != null && centuryFilter.isNotEmpty) {
        final year = book.verifiedDeathYearHijri;
        if (centuryFilter == 'Salaf (≤ 300 H)') {
          if (year == null || year > 300) return false;
        } else if (centuryFilter == 'Mutaqaddimin (301-600 H)') {
          if (year == null || year <= 300 || year > 600) return false;
        } else if (centuryFilter == 'Muta\'akhkhirin (601-1100 H)') {
          if (year == null || year <= 600 || year > 1100) return false;
        } else if (centuryFilter == 'Mu\'ashir (> 1100 H)') {
          if (year != null && year <= 1100) return false;
        }
      }

      if (cleanQuery.isEmpty) return true;

      final matchTitle = ArabicUtils.matches(book.titleArabic, cleanQuery) ||
          (book.shortTitleArabic != null &&
              ArabicUtils.matches(book.shortTitleArabic!, cleanQuery)) ||
          (book.titleLatin != null &&
              ArabicUtils.matches(book.titleLatin!, cleanQuery));
      final matchAuthor = ArabicUtils.matches(book.authorArabic, cleanQuery) ||
          (book.authorLatin != null &&
              ArabicUtils.matches(book.authorLatin!, cleanQuery));
      final matchPublisher = book.publisher != null &&
          ArabicUtils.matches(book.publisher!, cleanQuery);
      final matchMuhaqqiq = book.muhaqqiq != null &&
          ArabicUtils.matches(book.muhaqqiq!, cleanQuery);
      final matchSection = book.sectionArabic != null &&
          ArabicUtils.matches(book.sectionArabic!, cleanQuery);

      return matchTitle ||
          matchAuthor ||
          matchPublisher ||
          matchMuhaqqiq ||
          matchSection;
    }).toList();
  }
}
