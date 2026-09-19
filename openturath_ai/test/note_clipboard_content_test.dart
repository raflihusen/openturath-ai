import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/note_clipboard_content.dart';
import 'package:openturath_ai/models/bookmark_model.dart';

void main() {
  clipboardRegressionTests();
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



// Regression coverage: old bookmarks sometimes only contain arabicExcerpt.
void clipboardRegressionTests() {
  BookmarkModel note({String answer = '', String excerpt = '',
    String reference = '', String page = '', String? author,
    BookmarkVerificationStatus status = BookmarkVerificationStatus.unverified}) =>
      BookmarkModel(id: 'test', title: 'Catatan', agentId: '', agentTitle: '',
        fieldName: '', fieldId: '', arabicExcerpt: excerpt, fullAnswer: answer,
        bookReference: reference, pageNumber: page, author: author,
        createdAt: DateTime(2026), verificationStatus: status);

  test('copies legacy excerpt-only notes without dropping Arabic', () {
    expect(noteClipboardText(note(excerpt: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ')),
        '# Catatan\n\nإِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ');
  });
  test('prefers stored complete answer over excerpt', () {
    expect(noteClipboardText(note(answer: 'Complete', excerpt: 'Excerpt')),
        '# Catatan\n\nComplete');
  });
  test('does not promote unverified metadata into an exported citation', () {
    expect(noteClipboardText(note(answer: 'Body', reference: 'Unverified source',
        page: '123')), '# Catatan\n\nBody');
  });
  test('includes only supplied verified citation fields', () {
    expect(noteClipboardText(note(answer: 'Body', reference: 'الكتاب',
        author: 'المؤلف', page: '12', status: BookmarkVerificationStatus.verified)),
        '# Catatan\n\nBody\n\nRujukan: الكتاب · المؤلف · hlm. 12');
  });
  test('does not invent a reference from page number alone', () {
    expect(noteClipboardText(note(answer: 'Body', page: '12',
        status: BookmarkVerificationStatus.verified)), '# Catatan\n\nBody');
  });
}
