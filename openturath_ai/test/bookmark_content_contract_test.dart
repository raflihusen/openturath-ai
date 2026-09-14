import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/bookmark_content.dart';
import 'package:openturath_ai/models/bookmark_model.dart';

void main() {
  group('AI answer bookmark content contract', () {
    test('uses the first markdown heading as title and omits it from preview', () {
      final parsed = parseAiAnswerContent(
        '# Syarat sah salat berjamaah\n\nPenjelasan singkat tentang syarat-syaratnya.',
      );

      expect(parsed.title, 'Syarat sah salat berjamaah');
      expect(parsed.preview, 'Penjelasan singkat tentang syarat-syaratnya.');
      expect(parsed.hasFallbackTitle, isFalse);
    });

    test('falls back to the first meaningful line when no heading exists', () {
      final parsed = parseAiAnswerContent('\n\nPenjelasan tanpa heading\n\nIsi lanjutan.');

      expect(parsed.title, 'Penjelasan tanpa heading');
      expect(parsed.hasFallbackTitle, isTrue);
    });

    test('removes technical response labels from display titles', () {
      final parsed = parseAiAnswerContent('# [i] JAWABAN LANGSUNG: Hukum jual beli\n\nIsi jawaban.');

      expect(parsed.title, 'Hukum jual beli');
    });
  });

  group('Bookmark document metadata', () {
    test('old records remain readable with safe AI answer defaults', () {
      final item = BookmarkModel.fromJson({
        'id': 'legacy',
        'title': 'Catatan lama',
        'createdAt': DateTime(2026, 9, 14).toIso8601String(),
      });

      expect(item.documentKind, BookmarkDocumentKind.aiAnswer);
      expect(item.verificationStatus, BookmarkVerificationStatus.unverified);
    });

    test('manual notes retain their private-note identity after serialization', () {
      final item = BookmarkModel(
        id: 'note_1',
        title: 'Catatan saya',
        agentId: 'catatan_mandiri',
        agentTitle: 'Catatan Pribadi',
        fieldName: 'Catatan Pribadi',
        fieldId: 'general',
        arabicExcerpt: '',
        fullAnswer: 'Isi',
        bookReference: '',
        pageNumber: '',
        documentKind: BookmarkDocumentKind.personalNote,
        verificationStatus: BookmarkVerificationStatus.notApplicable,
        createdAt: DateTime(2026, 9, 14),
      );

      final restored = BookmarkModel.fromJson(item.toJson());
      expect(restored.documentKind, BookmarkDocumentKind.personalNote);
      expect(restored.verificationStatus, BookmarkVerificationStatus.notApplicable);
    });
  });
}
