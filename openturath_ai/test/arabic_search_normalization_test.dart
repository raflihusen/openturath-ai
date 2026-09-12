import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/arabic_utils.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/services/canonical_library_service.dart';

void main() {
  group('Milestone 2 — Arabic Search Normalization & Scholarly Citations', () {
    test('ArabicUtils strips all diacritics and tatweel', () {
      const withTashkil = 'كِتَابُ الأُمِّ لِلإِمَامِ الشَّافِعِيِّ';
      final normalized = ArabicUtils.normalize(withTashkil);

      // Harakat removed and alif variants normalized to 'ا'
      expect(normalized, isNot(contains('\u064E'))); // Fathah
      expect(normalized, isNot(contains('\u0650'))); // Kasrah
      expect(normalized, isNot(contains('\u064F'))); // Dammah
      expect(normalized, isNot(contains('\u0651'))); // Shaddah
      expect(normalized, equals('كتاب الام للامام الشافعي'));
    });

    test('ArabicUtils unifies alif variants (أ, إ, آ, ٱ -> ا)', () {
      expect(ArabicUtils.normalize('أحمد'), equals('احمد'));
      expect(ArabicUtils.normalize('إبراهيم'), equals('ابراهيم'));
      expect(ArabicUtils.normalize('آدم'), equals('ادم'));
      expect(ArabicUtils.normalize('ٱبن'), equals('ابن'));
    });

    test('ArabicUtils unifies Ta Marbuthah and Ya Makhfufah', () {
      expect(ArabicUtils.normalize('رسالة'), equals('رساله'));
      expect(ArabicUtils.normalize('موسى'), equals('موسي'));
      expect(ArabicUtils.normalize('فتوى'), equals('فتوي'));
    });

    test('ArabicUtils.matches matches text with and without harakat', () {
      const source = 'الإِمَامُ أَبُو حَامِدٍ الغَزَالِيُّ';
      expect(ArabicUtils.matches(source, 'الغزالي'), isTrue);
      expect(ArabicUtils.matches(source, 'أبو حامد'), isTrue);
      expect(ArabicUtils.matches(source, 'ابو حامد'), isTrue); // Bare alif matches
      expect(ArabicUtils.matches(source, 'الامام'), isTrue); // Bare alif matches
    });

    test('CanonicalLibraryService.filterBooks finds books with diacritic variations', () {
      final books = [
        const CanonicalBookPresentation(
          editionId: 'umm',
          titleArabic: 'كِتَابُ الأُمِّ',
          authorArabic: 'الإِمَامُ مُحَمَّدُ بْنُ إِدْرِيسَ الشَّافِعِيُّ',
          titleLatin: 'Kitab Al-Umm',
          authorLatin: 'Imam Asy-Syafi\'i',
          reviewedEraLabel: 'Mutaqaddimin',
          reviewedTypeLabel: 'Asal Mazhab',
          publisher: 'Darul Kutub Al-Ilmiyyah',
          muhaqqiq: 'Dr. Rifa\'at',
        ),
        const CanonicalBookPresentation(
          editionId: 'tanbih',
          titleArabic: 'التَّنْبِيهُ فِي الفِقْهِ الشَّافِعِيِّ',
          authorArabic: 'أَبُو إِسْحَاقَ الشِّيرَازِيُّ',
          titleLatin: 'At-Tanbih',
          reviewedEraLabel: 'Mutaqaddimin',
          reviewedTypeLabel: 'Matan',
        ),
      ];

      final service = CanonicalLibraryService.instance;

      // Search with bare alif 'الام'
      final res1 = service.filterBooks(books, 'الام');
      expect(res1.length, equals(1));
      expect(res1.first.editionId, equals('umm'));

      // Search with unvowelled 'الشافعي'
      final res2 = service.filterBooks(books, 'الشافعي');
      expect(res2.length, equals(2)); // Both mention Syafi'i (author / title)

      // Search with unvowelled 'الشيرازي'
      final res3 = service.filterBooks(books, 'الشيرازي');
      expect(res3.length, equals(1));
      expect(res3.first.editionId, equals('tanbih'));

      // Search by publisher
      final res4 = service.filterBooks(books, 'Ilmiyyah');
      expect(res4.length, equals(1));
      expect(res4.first.editionId, equals('umm'));

      // Search by muhaqqiq
      final res5 = service.filterBooks(books, 'Rifa\'at');
      expect(res5.length, equals(1));
      expect(res5.first.editionId, equals('umm'));
    });
  });
}
