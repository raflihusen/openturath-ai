import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/scholarly_citation.dart';
import 'package:openturath_ai/core/note_clipboard_content.dart';
import 'package:openturath_ai/models/bookmark_model.dart';

void main() {
  test('supplied and verified references stay distinct in every language', () {
    const supplied = ScholarlyCitation(book: 'الكتاب', author: 'المؤلف',
      volume: '2', page: '37');
    expect(supplied.format(languageCode: 'en'),
      'Supplied reference; not verified: الكتاب · المؤلف · vol. 2 · p. 37');
    expect(supplied.format(languageCode: 'ar'), contains('لم يُتحقق منه'));
    expect(supplied.format(), contains('belum diverifikasi'));
    expect(const ScholarlyCitation(book: 'الكتاب', verified: true)
      .format(languageCode: 'en'), 'Verified reference: الكتاب');
  });
  test('missing edition data and links are never invented', () {
    expect(const ScholarlyCitation(book: 'الكتاب').format(languageCode: 'en'),
      'Supplied reference; not verified: الكتاب');
    expect(const ScholarlyCitation(book: '').format(), isEmpty);
    expect(const ScholarlyCitation(book: 'Book', appUrl: 'javascript:alert(1)')
      .format(), isNot(contains('javascript')));
    expect(const ScholarlyCitation(book: 'Book', appUrl: 'https://example.org/book/7')
      .format(), endsWith('https://example.org/book/7'));
  });
  test('letter counter excludes Arabic harakat, tatweel, digits and punctuation', () {
    expect(countScholarlyLetters('بِسْمِ اللَّهِ'), 7);
    expect(countScholarlyLetters('العِلْمُ ١٢٣ 456، . ـ 😀'), 5);
    expect(countScholarlyLetters('Café e\u0301 A'), 6);
    expect(countScholarlyLetters('پژوهش'), 5);
    expect(countScholarlyLetters(' \n\t\u064e\u0651\u06d6 ١٢3 !'), 0);
  });
  test('explicit export preserves legacy Arabic and marks supplied metadata', () {
    final note = BookmarkModel(id: 'legacy', title: '', agentId: '', agentTitle: '',
      fieldName: '', fieldId: '', arabicExcerpt: 'نصٌ محفوظٌ', fullAnswer: '',
      bookReference: 'الكتاب', pageNumber: '19', volume: '3',
      createdAt: DateTime(2026));
    expect(noteClipboardText(note, includeSource: false), 'نصٌ محفوظٌ');
    final exported = noteClipboardText(note, includeSource: true, languageCode: 'en');
    expect(exported, startsWith('نصٌ محفوظٌ\n\nSupplied reference; not verified:'));
    expect(exported, contains('vol. 3 · p. 19'));
    final restored = BookmarkModel.fromJson(note.toJson());
    expect(restored.volume, '3');
    expect(restored.appUrl, isNull);
  });
}
