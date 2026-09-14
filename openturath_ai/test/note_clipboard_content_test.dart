import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/note_clipboard_content.dart';
import 'package:openturath_ai/models/bookmark_model.dart';

void main() {
  test('formats a note for copying without losing its title or body', () {
    final item = BookmarkModel(
      id: 'note_1',
      title: 'Hukum berjamaah',
      agentId: 'fiqh',
      agentTitle: 'Fikih',
      fieldName: 'Fikih',
      fieldId: 'fiqh',
      arabicExcerpt: '',
      fullAnswer: 'Isi kajian yang tersimpan.',
      bookReference: '',
      pageNumber: '',
      createdAt: DateTime(2026, 9, 14),
    );

    expect(
      noteClipboardText(item),
      '# Hukum berjamaah\n\nIsi kajian yang tersimpan.',
    );
  });
}
