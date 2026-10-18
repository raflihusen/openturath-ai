import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/book_model.dart';

void main() {
  group('Canonical Syafi\'i Catalog Parser Tests', () {
    test('parses canonical_syafii.json correctly with 87 entries', () {
      final file = File('assets/data/canonical_syafii.json');
      expect(file.existsSync(), isTrue,
          reason: 'assets/data/canonical_syafii.json must exist');

      final content = file.readAsStringSync();
      final result = parseCanonicalCatalog(content);

      expect(result.entries.isNotEmpty, isTrue);
      expect(result.entries.length, equals(87),
          reason: 'Expected 87 canonical books');
      expect(result.issues.isEmpty, isTrue,
          reason: 'Expected 0 format issues in catalog: ${result.issues}');

      // Verify sample entry: Al-Umm
      final alUmm =
          result.entries.firstWhere((e) => e.shortTitleArabic == 'الأم');
      expect(alUmm.titleArabic, equals('الأم'));
      expect(alUmm.authorArabic, equals('الإمام الشافعي'));
      expect(alUmm.recordedDeathYearHijri, equals(204));
      expect(alUmm.recordedVolumes, equals(8));
      expect(alUmm.publisher, isNotNull);

      // Verify Presentation conversion does not leak raw authority badges prematurely
      final presentation = CanonicalBookPresentation.fromEntry(alUmm);
      expect(presentation.reviewedAuthorityLabel, isNull);
      expect(presentation.canShowAuthority, isFalse);
      expect(presentation.reviewedTypeLabel, equals('Asal Mazhab'));
      expect(presentation.reviewedEraLabel, equals('Mutaqaddimin'));
      expect(presentation.compactLabels, contains('Asal Mazhab'));
      expect(presentation.compactLabels, contains('8 Jilid'));
    });
  });
}
