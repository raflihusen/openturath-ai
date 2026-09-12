import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/screens/book_catalog_screen.dart';
import 'package:openturath_ai/screens/book_detail_screen.dart';
import 'package:openturath_ai/widgets/book_row_item.dart';

void main() {
  group('Milestone 1 — Book Catalog & Navigation Architecture', () {
    final sampleBook = CanonicalBookPresentation(
      editionId: 'kitab_al_umm_shafii',
      titleArabic: 'كتاب الأم',
      authorArabic: 'الإمام محمد بن إدريس الشافعي',
      titleLatin: 'Kitab Al-Umm',
      authorLatin: 'Imam Muhammad bin Idris Asy-Syafi\'i',
      verifiedDeathYearHijri: 204,
      reviewedTypeLabel: 'Asal Mazhab',
      reviewedEraLabel: 'Mutaqaddimin',
      publisher: 'Darul Kutub Al-Ilmiyyah',
      muhaqqiq: 'Dr. Rifa\'at Fauzi Abdul Muthalib',
      volumesCount: 8,
    );

    testWidgets('BookRowItem displays Arabic title in RTL and compact tags', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookRowItem(
              book: sampleBook,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Verify Arabic Title and author
      expect(find.text('كتاب الأم'), findsOneWidget);
      expect(find.text('الإمام محمد بن إدريس الشافعي'), findsOneWidget);
      expect(find.text('w. 204 H'), findsOneWidget);
      expect(find.text('Asal Mazhab'), findsOneWidget);
      expect(find.text('Mutaqaddimin'), findsOneWidget);
      expect(find.text('8 Jilid'), findsOneWidget);

      // Tap the item
      await tester.tap(find.byType(BookRowItem));
      expect(tapped, isTrue);
    });

    testWidgets('BookDetailScreen renders 5 scholarly metadata sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookDetailScreen(book: sampleBook),
        ),
      );

      // Card 1: Identitas Kitab
      expect(find.text('كتاب الأم'), findsOneWidget);
      expect(find.text('kitab_al_umm_shafii'), findsOneWidget);

      // Card 2: Muallif
      expect(find.text('MUALLIF / PENGARANG'), findsOneWidget);
      expect(find.text('الإمام محمد بن إدريس الشافعي'), findsOneWidget);

      // Card 3: Klasifikasi Ilmiah
      expect(find.text('KLASIFIKASI ILMIAH'), findsOneWidget);
      expect(find.text('Asal Mazhab'), findsOneWidget);
      expect(find.text('Mutaqaddimin'), findsOneWidget);
      expect(find.text('8 Jilid'), findsOneWidget);

      // Card 4: Data Edisi & Tahqiq
      expect(find.text('DATA EDISI & TAHQIQ'), findsOneWidget);
      expect(find.text('Darul Kutub Al-Ilmiyyah'), findsOneWidget);
      expect(find.text('Dr. Rifa\'at Fauzi Abdul Muthalib'), findsOneWidget);

      // Card 5: Aksi Riset
      expect(find.text('AKSI & TELAAH RISET'), findsOneWidget);
      expect(find.text('Buka Ruang Kajian'), findsOneWidget);
      expect(find.text('Simpan ke Catatan Riset'), findsOneWidget);
    });

    testWidgets('AppRoutes contains bookCatalog and bookDetail', (tester) async {
      expect(AppRoutes.bookCatalog, equals('/catalog'));
      expect(AppRoutes.bookDetail, equals('/book_detail'));
    });
  });
}
