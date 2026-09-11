import 'package:flutter/services.dart';
import '../models/book_model.dart';

/// Service to load, cache, and search canonical book catalogs.
class CanonicalLibraryService {
  CanonicalLibraryService._();
  static final CanonicalLibraryService instance = CanonicalLibraryService._();

  CanonicalImport? _syafiiCatalog;
  List<CanonicalBookPresentation>? _syafiiPresentations;

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

  /// Filter books by query string (Arabic or Latin transliteration/field match).
  List<CanonicalBookPresentation> filterBooks(
    List<CanonicalBookPresentation> books,
    String query, {
    String? eraFilter,
    String? typeFilter,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    return books.where((book) {
      if (eraFilter != null && eraFilter.isNotEmpty && book.reviewedEraLabel != eraFilter) {
        return false;
      }
      if (typeFilter != null && typeFilter.isNotEmpty && book.reviewedTypeLabel != typeFilter) {
        return false;
      }

      if (cleanQuery.isEmpty) return true;

      final matchTitle = book.titleArabic.toLowerCase().contains(cleanQuery) ||
          (book.titleLatin?.toLowerCase().contains(cleanQuery) ?? false);
      final matchAuthor = book.authorArabic.toLowerCase().contains(cleanQuery) ||
          (book.authorLatin?.toLowerCase().contains(cleanQuery) ?? false);
      final matchPublisher = book.publisher?.toLowerCase().contains(cleanQuery) ?? false;
      final matchMuhaqqiq = book.muhaqqiq?.toLowerCase().contains(cleanQuery) ?? false;

      return matchTitle || matchAuthor || matchPublisher || matchMuhaqqiq;
    }).toList();
  }
}
