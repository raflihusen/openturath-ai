import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/exclusive_activation_dialog.dart';

void main() {
  testWidgets('ExclusiveActivationDialog renders premium celebration card and benefits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ExclusiveActivationDialog.show(
                  context,
                  serviceTitle: "Kajian Fikih Syafi'i: Al-Muhaqqiq",
                  durationDays: 7,
                  expiryDate: DateTime(2026, 10, 6),
                  agentId: 'fiqh_syafii',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Verifikasi chip eksklusif & judul
    expect(find.text('AKSES PERDANA TERVERIFIKASI'), findsOneWidget);
    expect(find.text('Akses Eksklusif Terbuka'), findsOneWidget);
    expect(find.text("Kajian Fikih Syafi'i: Al-Muhaqqiq"), findsOneWidget);
    expect(find.text('Aktif • 7 Hari'), findsOneWidget);

    // Verifikasi poin-poin hak istimewa
    expect(find.text('Tanya-Jawab Ilmiah Tanpa Batas'), findsOneWidget);
    expect(find.text('Ibarah & Rujukan Kitab Asli'), findsOneWidget);
    expect(find.text('Simpan Catatan & Faedah'), findsOneWidget);

    // Verifikasi tombol aksi
    expect(find.text('Mulai Telaah Sekarang'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);

    // Klik tombol tutup
    await tester.ensureVisible(find.text('Tutup'));
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    expect(find.text('AKSES PERDANA TERVERIFIKASI'), findsNothing);
  });
}
