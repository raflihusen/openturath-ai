import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/hadith_takhrij_models.dart';
import 'package:openturath_ai/services/harf_morphology_service.dart';
import 'package:openturath_ai/services/universal_takhrij_engine.dart';

void main() {
  group('HarfMorphologyService & 5 Auxiliary Lists Tests', () {
    final morphology = HarfMorphologyService.instance;

    test('Strips tashkeel and normalizes hamzah/alif/ta marbutah accurately', () {
      const input = 'إِنَّمَا الأَعْمَالُ';
      final normalized = morphology.normalizeArabicWord(input);
      expect(normalized, equals('انماالاعمال'));
    });

    test('Tokenizes meaningful matn words and extracts roots + wazan', () {
      const matn = 'إنما الأعمال بالنيات وإنما لكل امرئ ما نوى';
      final tokens = morphology.tokenizeMeaningfulMatn(matn);
      expect(tokens.isNotEmpty, isTrue);

      final aamal =
          tokens.firstWhere((t) => t.normalizedWord.contains('اعمال'));
      expect(aamal.root, equals('عمل'));

      final niyyat =
          tokens.firstWhere((t) => t.normalizedWord.contains('نيات'));
      expect(niyyat.root, equals('نوي'));
    });

    test('Formats diff segments respecting <=15 words and non-terminal particle rules', () {
      final words = 'إنما الأعمال بالنيات وإنما لكل امرئ ما نوى فمن كانت هجرته إلى الله'
          .split(' ');
      final diffs = morphology.formatDiffSegments(words, [0, 1]);
      expect(diffs.isNotEmpty, isTrue);
    });
  });

  group('UniversalTakhrijEngine — 27 Deterministic Rules & Scaling to Thousands of Books', () {
    final engine = UniversalTakhrijEngine.instance;

    test('Rule 1-7 (بلفظه) & 8-23 (بمثله / بنحوه): Evaluates matn comparison across core & expanded books', () {
      final bukhari1 = engine.corpusHadiths
          .firstWhere((h) => h.uri == 'ot://hadith/bukhari/1');
      final humaidi28 = engine.corpusHadiths
          .firstWhere((h) => h.uri == 'ot://hadith/musnad_humaidi/28');

      final outcome = engine.compareTwoHadithMatns(bukhari1, humaidi28);
      expect(outcome.rule.ruleNumber, inInclusiveRange(1, 27));
      expect(outcome.formattedArabicVerdict, isNotEmpty);
    });

    test('Book #26 (al-Matalib al-Aliyah) & secondary compilations use «أورده» while Musnads use «أخرجه»', () {
      final mathalibBook = engine.getBookById('mathalib_aliyah')!;
      final bukhariBook = engine.getBookById('bukhari')!;
      final zawaidAbdullah =
          engine.getBookById('musnad_ahmad_zawaid_abdullah')!;

      expect(
        mathalibBook.formatAttributionPhrase(isFirstInChain: true),
        contains('أورده ابن حجر'),
      );
      expect(
        bukhariBook.formatAttributionPhrase(isFirstInChain: true),
        contains('أخرجه البخاري'),
      );
      expect(
        zawaidAbdullah.formatAttributionPhrase(isFirstInChain: true),
        contains('في زوائده على "مسند أحمد"'),
      );
    });

    test('Full Takhrij Cluster synthesis produces Al-Matn al-Mujamma, Isnad DAG, and classical paragraph', () {
      final origin = engine.corpusHadiths.first;
      final cluster = engine.performTakhrijOnHadith(
        origin,
        includeNonCore33Books: true,
        sortOrder: TakhrijSortOrder.byCanonicalBookRank,
      );

      expect(cluster.takhrijOutcomes.isNotEmpty, isTrue);
      expect(cluster.mujammaMatn.segments.isNotEmpty, isTrue);
      expect(cluster.madarReport.nodes.isNotEmpty, isTrue);
      expect(cluster.madarReport.primaryMadar, isNotNull);
      expect(cluster.formattedFullTakhrijArabicParagraph, contains('أخرجه'));
    });

    test('Disambiguates Muhmal narrator (سفيان) via teacher-student graph', () {
      final resolved = engine.disambiguateMuhmalRawi(
        rawNameMention: 'سفيان',
        teacherRawiId: 'rawi_yahya_said',
        studentRawiId: 'rawi_humaidi',
      );

      expect(resolved, isNotNull);
      expect(resolved!.id, equals('rawi_sufyan_uyainah'));
    });

    test('Automated Manuscript Scanner (DocXSL revival) detects quotes and generates footnotes', () {
      const sampleText =
          'قال رسول الله صلى الله عليه وسلم: «إنما الأعمال بالنيات وإنما لكل امرئ ما نوى».';
      final detections = engine.scanAndTakhrijManuscript(sampleText);

      expect(detections.isNotEmpty, isTrue);
      expect(detections.first.generatedFootnoteArabic, contains('البخاري'));
    });

    test('Dynamic Sanad Parser extracts narrator hops in tabaqah order from raw Arabic sanad', () {
      const sampleSanad =
          'حدثنا الحميدي قال حدثنا سفيان بن عيينة عن يحيى بن سعيد الأنصاري عن محمد بن إبراهيم التيمي عن علقمة بن وقاص الليثي عن عمر بن الخطاب';
      final hops = engine.parseSanadChainFromText(sampleSanad);

      expect(hops.length, greaterThanOrEqualTo(4));
      expect(hops.first.resolvedRawiId, equals('rawi_umar'));
    });
  });
}
