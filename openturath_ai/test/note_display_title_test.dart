import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/note_display_title.dart';
import 'package:openturath_ai/models/bookmark_model.dart';

void main() {
  BookmarkModel note({String title = '', String body = '',
    BookmarkDocumentKind kind = BookmarkDocumentKind.personalNote}) => BookmarkModel(
      id: 'note', title: title, agentId: '', agentTitle: '', fieldName: '', fieldId: '',
      arabicExcerpt: '', fullAnswer: body, bookReference: '', pageNumber: '',
      documentKind: kind, createdAt: DateTime(2026));
  String render(BookmarkModel value, String fallback) => noteDisplayTitle(value,
      untitled: fallback, translateLabel: (label) => label);

  test('empty titles follow the current language without a stored translation', () {
    final value = note(body: 'User content');
    expect(render(value, 'Untitled note'), 'Untitled note');
    expect(render(value, 'ملاحظة بلا عنوان'), 'ملاحظة بلا عنوان');
    expect(value.title, isEmpty);
  });
  test('AI parser-generated fallbacks follow the current language', () {
    final value = note(kind: BookmarkDocumentKind.aiAnswer);
    expect(render(value, 'Untitled note'), 'Untitled note');
  });
  test('actual source and user titles that resemble defaults remain verbatim', () {
    expect(render(note(title: 'Catatan tanpa judul'), 'Untitled note'),
      'Catatan tanpa judul');
    expect(render(note(body: '# Kajian tanpa judul',
      kind: BookmarkDocumentKind.aiAnswer), 'Untitled note'), 'Kajian tanpa judul');
    expect(render(note(title: 'العِلْمُ'), 'Untitled note'), 'العِلْمُ');
  });
}
