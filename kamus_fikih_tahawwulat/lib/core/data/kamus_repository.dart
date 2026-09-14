import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/term_model.dart';
import '../utils/arabic_utils.dart';

class KamusRepository {
  List<Term> _terms = [];
  bool _isLoaded = false;

  List<Term> get terms => _terms;
  bool get isLoaded => _isLoaded;

  /// Loads dictionary from assets/data/kamus.json
  Future<List<Term>> loadTerms() async {
    if (_isLoaded && _terms.isNotEmpty) return _terms;

    final jsonString = await rootBundle.loadString('assets/data/kamus.json');
    final List<dynamic> rawList = json.decode(jsonString) as List<dynamic>;

    _terms = rawList
        .whereType<Map<String, dynamic>>()
        .map((m) => Term.fromJson(m))
        .toList();

    _isLoaded = true;
    return _terms;
  }

  /// Search across Arabic, English, and Indonesian fields
  List<Term> search(String query) {
    if (query.trim().isEmpty) return [];

    final cleanQuery = query.trim();
    return _terms.where((term) {
      // 1. Arabic match (normalized without harakat/alif variants)
      if (ArabicUtils.matches(term.arabic, cleanQuery)) return true;

      // 2. Indonesian match
      if (term.indonesian.toLowerCase().contains(cleanQuery.toLowerCase())) return true;

      // 3. English match
      if (term.english.toLowerCase().contains(cleanQuery.toLowerCase())) return true;

      // 4. Definition texts match
      for (final def in term.definitions) {
        if (ArabicUtils.matches(def.text.ar, cleanQuery)) return true;
        if (def.text.id.toLowerCase().contains(cleanQuery.toLowerCase())) return true;
        if (def.text.en.toLowerCase().contains(cleanQuery.toLowerCase())) return true;
        if (ArabicUtils.matches(def.source, cleanQuery)) return true;
      }

      return false;
    }).toList();
  }

  /// Get random term (used in Classic Version)
  Term? getRandomTerm() {
    if (_terms.isEmpty) return null;
    return (_terms..shuffle()).first;
  }

  /// Get daily term (deterministik berdasarkan hari/tanggal, used in OpenTurath Version)
  Term? getDailyTerm() {
    if (_terms.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % _terms.length;
    return _terms[index];
  }

  /// Find term by ID
  Term? findById(int id) {
    try {
      return _terms.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get unique book sources (*masadir*)
  List<String> getUniqueSources() {
    final sources = <String>{};
    for (final term in _terms) {
      for (final def in term.definitions) {
        final src = def.source.split('،').first.trim();
        if (src.isNotEmpty) {
          sources.add(src);
        }
      }
    }
    final sorted = sources.toList()..sort();
    return sorted;
  }
}
