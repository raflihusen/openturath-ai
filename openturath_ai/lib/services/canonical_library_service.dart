import 'package:flutter/services.dart';
import '../core/arabic_utils.dart';
import '../models/book_model.dart';

/// Service to load, cache, and search canonical book catalogs with diacritic-tolerant Arabic search.
class CanonicalLibraryService {
  CanonicalLibraryService._();
  static final CanonicalLibraryService instance = CanonicalLibraryService._();

  CanonicalImport? _syafiiCatalog;
  List<CanonicalBookPresentation>? _syafiiPresentations;

  /// Normalizes Arabic text by stripping diacritics and unifying letter variants.
  static String normalizeArabic(String text) => ArabicUtils.normalize(text);

  /// Loads the canonical Syafi'i catalog from asset bundle.
  Future<List<CanonicalBookPresentation>> loadSyafiiCatalog() async {
    if (_syafiiPresentations != null) {
      return _syafiiPresentations!;
    }

    try {
      final jsonStr = await rootBundle.loadString('assets/data/canonical_syafii.json');
      final catalog = parseCanonicalCatalog(jsonStr);
      _syafiiCatalog = catalog;
      _syafiiPresentations = catalog.entries
          .map((e) => CanonicalBookPresentation.fromEntry(e))
          .toList();
      return _syafiiPresentations!;
    } catch (e) {
      // Re-throw so UI can display specific failure state
      rethrow;
    }
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
  }) {
    final cleanQuery = query.trim();

    return books.where((book) {
      if (eraFilter != null && eraFilter.isNotEmpty && book.reviewedEraLabel != eraFilter) {
        return false;
      }
      if (typeFilter != null && typeFilter.isNotEmpty && book.reviewedTypeLabel != typeFilter) {
        return false;
      }

      if (cleanQuery.isEmpty) return true;

      final matchTitle = ArabicUtils.matches(book.titleArabic, cleanQuery) ||
          (book.titleLatin != null && ArabicUtils.matches(book.titleLatin!, cleanQuery));
      final matchAuthor = ArabicUtils.matches(book.authorArabic, cleanQuery) ||
          (book.authorLatin != null && ArabicUtils.matches(book.authorLatin!, cleanQuery));
      final matchPublisher = book.publisher != null && ArabicUtils.matches(book.publisher!, cleanQuery);
      final matchMuhaqqiq = book.muhaqqiq != null && ArabicUtils.matches(book.muhaqqiq!, cleanQuery);

      return matchTitle || matchAuthor || matchPublisher || matchMuhaqqiq;
    }).toList();
  }
}
