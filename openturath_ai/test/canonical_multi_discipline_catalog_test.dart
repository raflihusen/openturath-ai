import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/services/canonical_library_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Canonical Multi-Discipline Catalog Integration (2,226 Kitab)', () {
    test('All 6 JSON catalog asset files exist and parse exactly 2,226 books', () {
      final baseDir = 'assets/data';
      final files = {
        '01_KATALOG_FIKIH_SYAFII.json': 87,
        '02_KATALOG_HADITS_DAN_SYARAH.json': 1173,
        '03_KATALOG_USHUL_FIKIH.json': 241,
        '04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json': 449,
        '05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json': 218,
        '06_KATALOG_FIKIH_TAHAWWULAT.json': 58,
      };

      int totalCount = 0;
      for (final entry in files.entries) {
        final file = File('$baseDir/${entry.key}');
        expect(file.existsSync(), isTrue, reason: '${entry.key} must exist');
        final content = file.readAsStringSync();
        final books = parseSyamilahCatalog(content);
        expect(books.length, equals(entry.value), reason: '${entry.key} count mismatch');
        totalCount += books.length;
      }

      expect(totalCount, equals(2226));
    });

    test('CanonicalBookPresentation parses Syamilah attributes accurately', () {
      const sampleHadithJson = '''
      [
        {
          "tahun_wafat": 256,
          "القسم": "كتب السنة",
          "الاسم_المختصر": "صحيح البخاري",
          "الكتاب": "الجامع المسند الصحيح المختصر من أمور رسول الله صلى الله عليه وسلم وسننه وأيامه",
          "المؤلف": "محمد بن إسماعيل أبو عبدالله البخاري الجعفي",
          "المحقق_أو_المعتني": "محمد زهير بن ناصر الناصر",
          "الناشر": "دار طوق النجاة",
          "سنة_الطبع": "1422هـ",
          "عدد_الأجزاء": "9",
          "id": 101
        }
      ]
      ''';

      final books = parseSyamilahCatalog(sampleHadithJson);
      expect(books.length, equals(1));
      final b = books.first;
      expect(b.editionId, equals('101'));
      expect(b.verifiedDeathYearHijri, equals(256));
      expect(b.sectionArabic, equals('كتب السنة'));
      expect(b.shortTitleArabic, equals('صحيح البخاري'));
      expect(b.titleArabic, contains('الجامع المسند'));
      expect(b.authorArabic, contains('البخاري'));
      expect(b.muhaqqiq, contains('محمد زهير'));
      expect(b.publisher, equals('دار طوق النجاة'));
      expect(b.printYear, equals('1422هـ'));
      expect(b.volumesDescription, equals('9'));
      expect(b.volumesCount, equals(9));
    });

    test('CanonicalLibraryService filterBooks filters by century, section, and query with harakat', () {
      final books = [
        CanonicalBookPresentation(
          editionId: '1',
          titleArabic: 'صَحِيحُ البُخَارِيِّ',
          shortTitleArabic: 'صحيح البخاري',
          authorArabic: 'الإمام البخاري',
          verifiedDeathYearHijri: 256,
          sectionArabic: 'كتب السنة',
          muhaqqiq: 'زهير الناصر',
        ),
        CanonicalBookPresentation(
          editionId: '2',
          titleArabic: 'فَتْحُ البَارِي شَرْحُ صَحِيحِ البُخَارِي',
          shortTitleArabic: 'فتح الباري',
          authorArabic: 'ابن حجر العسقلاني',
          verifiedDeathYearHijri: 852,
          sectionArabic: 'كتب السنة',
          muhaqqiq: 'محب الدين الخطيب',
        ),
        CanonicalBookPresentation(
          editionId: '3',
          titleArabic: 'الكشاف عن حقائق غوامض التنزيل',
          shortTitleArabic: 'تفسير الزمخشري',
          authorArabic: 'الزمخشري',
          verifiedDeathYearHijri: 538,
          sectionArabic: 'التفسير وعلوم القرآن (Balaghah)',
        ),
      ];

      final service = CanonicalLibraryService.instance;

      // 1. Search without diacritics finding diacritic title
      final r1 = service.filterBooks(books, 'صحيح البخاري');
      expect(r1.length, equals(2));

      // 2. Search by author with diacritic variation
      final r2 = service.filterBooks(books, 'البخاري');
      expect(r2.length, equals(2));

      // 3. Century Filter: Salaf (<= 300 H)
      final r3 = service.filterBooks(books, '', centuryFilter: 'Salaf (≤ 300 H)');
      expect(r3.length, equals(1));
      expect(r3.first.editionId, equals('1'));

      // 4. Century Filter: Muta'akhkhirin (601-1100 H)
      final r4 = service.filterBooks(books, '', centuryFilter: 'Muta\'akhkhirin (601-1100 H)');
      expect(r4.length, equals(1));
      expect(r4.first.editionId, equals('2'));

      // 5. Section filter
      final r5 = service.filterBooks(books, '', sectionFilter: 'التفسير وعلوم القرآن (Balaghah)');
      expect(r5.length, equals(1));
      expect(r5.first.editionId, equals('3'));
    });
  });
}
