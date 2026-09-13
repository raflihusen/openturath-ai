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
  };

  static const Map<String, String> _assetMapByAgentId = {
    'fiqh_syafii': 'assets/data/01_KATALOG_FIKIH_SYAFII.json',
    'hadits': 'assets/data/02_KATALOG_HADITS_DAN_SYARAH.json',
    'ushul_fiqh': 'assets/data/03_KATALOG_USHUL_FIKIH.json',
    'nahwu_sharaf': 'assets/data/04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json',
    'tafsir': 'assets/data/05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json',
    'fiqh_tahawwulat': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
  };

  final Map<String, List<CanonicalBookPresentation>> _catalogCache = {};

  CanonicalImport? _syafiiCatalog;
  List<CanonicalBookPresentation>? _syafiiPresentations;

  /// Normalizes Arabic text by stripping diacritics and unifying letter variants.
  static String normalizeArabic(String text) => ArabicUtils.normalize(text);

  /// Loads catalog for a specific agent or discipline.
  Future<List<CanonicalBookPresentation>> loadCatalogForAgent(AgentModel agent) async {
    final assetPath = _assetMapByAgentId[agent.id] ?? _assetMapByField[agent.fieldId];
    if (assetPath == null) {
      if (agent.fieldId == 'fiqh') {
        return loadCatalogFromAsset('assets/data/01_KATALOG_FIKIH_SYAFII.json');
      }
      return [];
    }
    return loadCatalogFromAsset(assetPath);
  }

  /// Loads catalog by discipline field ID (fiqh, hadith, usul, lughah, tafsir, fiqh_tahawwulat).
  Future<List<CanonicalBookPresentation>> loadCatalogByField(String fieldId) async {
    final assetPath = _assetMapByField[fieldId];
    if (assetPath == null) return [];
    return loadCatalogFromAsset(assetPath);
  }

  /// Loads catalog from asset bundle with in-memory caching.
  Future<List<CanonicalBookPresentation>> loadCatalogFromAsset(String assetPath) async {
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
  List<CanonicalBookPresentation>? get cachedSyafiiBooks => _syafiiPresentations;

  /// Get parsed canonical import or null if not yet loaded.
  CanonicalImport? get rawSyafiiCatalog => _syafiiCatalog;

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
      if (eraFilter != null && eraFilter.isNotEmpty && book.reviewedEraLabel != eraFilter) {
        return false;
      }
      if (typeFilter != null && typeFilter.isNotEmpty && book.reviewedTypeLabel != typeFilter) {
        return false;
      }
      if (sectionFilter != null && sectionFilter.isNotEmpty && book.sectionArabic != sectionFilter) {
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
          (book.shortTitleArabic != null && ArabicUtils.matches(book.shortTitleArabic!, cleanQuery)) ||
          (book.titleLatin != null && ArabicUtils.matches(book.titleLatin!, cleanQuery));
      final matchAuthor = ArabicUtils.matches(book.authorArabic, cleanQuery) ||
          (book.authorLatin != null && ArabicUtils.matches(book.authorLatin!, cleanQuery));
      final matchPublisher = book.publisher != null && ArabicUtils.matches(book.publisher!, cleanQuery);
      final matchMuhaqqiq = book.muhaqqiq != null && ArabicUtils.matches(book.muhaqqiq!, cleanQuery);
      final matchSection = book.sectionArabic != null && ArabicUtils.matches(book.sectionArabic!, cleanQuery);

      return matchTitle || matchAuthor || matchPublisher || matchMuhaqqiq || matchSection;
    }).toList();
  }
}
