import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/legal_copy.dart';
import 'package:openturath_ai/widgets/legal_document_sheet.dart';

void main() {
  group('Audit Integritas Legal & Kebijakan OpenTurath', () {
    test('Semua placeholder [[...]] wajib telah diselesaikan (bebas dari kurung siku ganda)', () {
      final placeholderRegex = RegExp(r'\[\[.+?\]\]');

      // 1. Cek Identitas & Bab 1.2
      expect(placeholderRegex.hasMatch(LegalCopy.aboutAppParagraph1), isFalse);
      expect(placeholderRegex.hasMatch(LegalCopy.aboutAppParagraph2), isFalse);
      expect(placeholderRegex.hasMatch(LegalCopy.aboutAppTagline), isFalse);

      // 2. Cek Bab 2: Ketentuan Layanan
      for (final sec in LegalCopy.termsSections) {
        expect(placeholderRegex.hasMatch(sec.title), isFalse, reason: 'Placeholder ditemukan di judul: ${sec.title}');
        expect(placeholderRegex.hasMatch(sec.content), isFalse, reason: 'Placeholder ditemukan di pasal: ${sec.title}');
      }

      // 3. Cek Bab 3: Kebijakan Privasi
      for (final sec in LegalCopy.privacySections) {
        expect(placeholderRegex.hasMatch(sec.title), isFalse, reason: 'Placeholder ditemukan di judul: ${sec.title}');
        expect(placeholderRegex.hasMatch(sec.content), isFalse, reason: 'Placeholder ditemukan di pasal: ${sec.title}');
      }

      // 4. Cek Bab 4: Pembayaran & Refund
      for (final sec in LegalCopy.refundSections) {
        expect(placeholderRegex.hasMatch(sec.title), isFalse, reason: 'Placeholder ditemukan di judul: ${sec.title}');
        expect(placeholderRegex.hasMatch(sec.content), isFalse, reason: 'Placeholder ditemukan di pasal: ${sec.title}');
      }

      // 5. Cek Bab 7: Panduan AI
      for (final sec in LegalCopy.aiGuidelineSections) {
        expect(placeholderRegex.hasMatch(sec.title), isFalse, reason: 'Placeholder ditemukan di judul: ${sec.title}');
        expect(placeholderRegex.hasMatch(sec.content), isFalse, reason: 'Placeholder ditemukan di pasal: ${sec.title}');
      }

      // 6. Cek Bab 9: Bantuan & Kontak
      for (final sec in LegalCopy.contactSections) {
        expect(placeholderRegex.hasMatch(sec.title), isFalse, reason: 'Placeholder ditemukan di judul: ${sec.title}');
        expect(placeholderRegex.hasMatch(sec.content), isFalse, reason: 'Placeholder ditemukan di pasal: ${sec.title}');
      }

      // 7. Cek Teks Hapus Akun Kanonik
      expect(placeholderRegex.hasMatch(LegalCopy.deleteAccountConfirmationBody), isFalse);
    });

    test('Etika The Quiet Scholar: Bebas tanda seru (!) pada seluruh dokumen hukum dan kebijakan', () {
      // Periksa semua bagian di LegalCopy
      for (final sec in LegalCopy.termsSections) {
        expect(sec.title.contains('!'), isFalse, reason: 'Tanda seru di judul: ${sec.title}');
        expect(sec.content.contains('!'), isFalse, reason: 'Tanda seru di isi: ${sec.title}');
      }

      for (final sec in LegalCopy.privacySections) {
        expect(sec.title.contains('!'), isFalse, reason: 'Tanda seru di judul: ${sec.title}');
        expect(sec.content.contains('!'), isFalse, reason: 'Tanda seru di isi: ${sec.title}');
      }

      for (final sec in LegalCopy.refundSections) {
        expect(sec.title.contains('!'), isFalse, reason: 'Tanda seru di judul: ${sec.title}');
        expect(sec.content.contains('!'), isFalse, reason: 'Tanda seru di isi: ${sec.title}');
      }

      for (final sec in LegalCopy.aiGuidelineSections) {
        expect(sec.title.contains('!'), isFalse, reason: 'Tanda seru di judul: ${sec.title}');
        expect(sec.content.contains('!'), isFalse, reason: 'Tanda seru di isi: ${sec.title}');
      }

      for (final sec in LegalCopy.contactSections) {
        expect(sec.title.contains('!'), isFalse, reason: 'Tanda seru di judul: ${sec.title}');
        expect(sec.content.contains('!'), isFalse, reason: 'Tanda seru di isi: ${sec.title}');
      }

      expect(LegalCopy.deleteAccountConfirmationBody.contains('!'), isFalse);
    });

    test('Keutuhan struktur dan pasal-pasal kanonik', () {
      expect(LegalCopy.termsSections.length, equals(14));
      expect(LegalCopy.privacySections.length, equals(13));
      expect(LegalCopy.refundSections.length, equals(7));
      expect(LegalCopy.aiGuidelineSections.length, equals(14));
      expect(LegalCopy.contactSections.length, equals(3));

      // Verifikasi saluran email resmi openturath@gmail.com
      expect(LegalCopy.contactSupportEmail, equals('openturath@gmail.com'));
      expect(LegalCopy.contactPrivacyEmail, equals('openturath@gmail.com'));
      expect(LegalCopy.contactCopyrightEmail, equals('openturath@gmail.com'));

      // Verifikasi penegasan manual renewal tanpa auto-debit
      final manualRenewalText = LegalCopy.refundSections[2].content;
      expect(manualRenewalText, contains('manual'));
      expect(manualRenewalText.toLowerCase(), contains('tanpa'));
    });

    testWidgets('LegalDocumentSheet dapat ditampilkan tanpa crash untuk setiap dokumen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => LegalDocumentSheet.showTermsOfService(context),
                child: const Text('Buka Ketentuan'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Ketentuan'));
      await tester.pumpAndSettle();

      expect(find.text(LegalCopy.termsTitle), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);
    });
  });
}
