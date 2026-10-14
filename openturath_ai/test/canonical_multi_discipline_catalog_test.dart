import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/services/canonical_library_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Canonical Multi-Discipline Catalog Integration (V9.2, 5.383 Kitab)', () {
    test('All 18 V9.2 catalog asset files exist and parse exactly 5,383 books', () {
      const baseDir = 'assets/data';
      final files = {
        '01_KATALOG_FIKIH_SYAFII.json': 104,
        '02_KATALOG_HADITS_DAN_SYARAH.json': 1138,
        '03_KATALOG_USHUL_FIKIH.json': 180,
        '04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json': 847,
        '05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json': 274,
        '06_KATALOG_FIKIH_TAHAWWULAT.json': 58,
        '07_KATALOG_TARIKH_DAN_SIRAH_NABAWIYYAH.json': 378,
        '08_KATALOG_FIKIH_MUQARAN_DAN_UMUM.json': 210,
        '10_KATALOG_SYARAH_HADITS.json': 133,
        '11_KATALOG_FIKIH_HANAFI.json': 82,
        '12_KATALOG_FIKIH_MALIKI.json': 77,
        '13_KATALOG_FIKIH_HANBALI.json': 68,
        '14_KATALOG_TASAWWUF_DAN_ADZKAR.json': 747,
        '15_KATALOG_TAJWID_DAN_QIRAAT.json': 38,
        '17_KATALOG_MUSTHALAH_DAN_ULUMUL_HADITS.json': 226,
        '18_KATALOG_AQIDAH_DAN_USHULUDDIN.json': 410,
        '19_KATALOG_THABAQAT_DAN_TARAJIM.json': 381,
        '26_KATALOG_BIBLIOGRAFI_DAN_FAHARIS.json': 32,
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

      expect(totalCount, equals(5383));
      for (final gone in const [
        '09_KATALOG_FATAWA_DAN_MASAIL_FIQHIYYAH.json',
        '16_KATALOG_QAWAID_FIQHIYYAH.json',
        '21_KATALOG_ADAB_DAN_BALAGHAH.json',
      ]) {
        expect(File('$baseDir/$gone').existsSync(), isFalse, reason: '$gone sudah dilebur');
      }
    });

    test('All 6 active specialist agents have catalogId set for Pustaka button', () {
      final activeAgents = AgentModel.defaultAgents.where((a) => a.isActive).toList();
      expect(activeAgents.length, greaterThanOrEqualTo(6));
      for (final agent in activeAgents) {
        expect(agent.catalogId, isNotNull, reason: 'Agent ${agent.id} must have catalogId');
        expect(agent.catalogId, startsWith('canonical_'));
      }
    });

    test('CanonicalBookPresentation parses Syamilah attributes and pagesDescription accurately', () {
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
          "عدد_الصفحات": "3882",
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
      expect(b.pagesDescription, equals('3882'));
      expect(b.compactLabels, contains('3882 Hlm'));
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
        const CanonicalBookPresentation(
          editionId: '1',
          titleArabic: 'صَحِيحُ البُخَارِيِّ',
          shortTitleArabic: 'صحيح البخاري',
          authorArabic: 'الإمام البخاري',
          verifiedDeathYearHijri: 256,
          sectionArabic: 'كتب السنة',
          muhaqqiq: 'زهير الناصر',
        ),
        const CanonicalBookPresentation(
          editionId: '2',
          titleArabic: 'فَتْحُ البَارِي شَرْحُ صَحِيحِ البُخَارِي',
          shortTitleArabic: 'فتح الباري',
          authorArabic: 'ابن حجر العسقلاني',
          verifiedDeathYearHijri: 852,
          sectionArabic: 'كتب السنة',
          muhaqqiq: 'محب الدين الخطيب',
        ),
        const CanonicalBookPresentation(
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
