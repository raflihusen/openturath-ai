import 'package:flutter/material.dart';
import 'package:openturath_ai/core/arabic_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/screens/book_catalog_screen.dart';
import 'package:openturath_ai/screens/book_detail_screen.dart';
import 'package:openturath_ai/widgets/book_row_item.dart';

void main() {
  group('Milestone 1 — Book Catalog & Navigation Architecture', () {
    const sampleBook = CanonicalBookPresentation(
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

    testWidgets('BookRowItem displays Arabic title in RTL and compact tags',
        (tester) async {
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
      expect(find.text('ت ٢٠٤ هـ'), findsOneWidget);
      // Daftar editorial menyimpan fakta inti; penerbit tetap pada detail.
      expect(find.textContaining('المجلدات: ٨'), findsOneWidget);
      expect(find.textContaining('Darul Kutub Al-Ilmiyyah'), findsNothing);

      // Tap the item
      await tester.tap(find.byType(BookRowItem));
      expect(tapped, isTrue);
    });

    testWidgets(
        'BookDetailScreen follows Arabic locale and keeps source text RTL',
        (tester) async {
      AppConfig.localeNotifier.value = 'ar';
      addTearDown(() => AppConfig.localeNotifier.value = 'id');
      await tester.pumpWidget(
        const MaterialApp(
          home: BookDetailScreen(book: sampleBook),
        ),
      );

      // Judul, pengarang, angka Arab-Indic, dan tabel edisi.
      expect(find.text('كتاب الأم'), findsOneWidget);
      expect(find.text('الإمام محمد بن إدريس الشافعي'), findsOneWidget);
      expect(find.text(ArabicCatalog.digits('8')), findsWidgets);
      expect(find.text(ArabicCatalog.edition), findsOneWidget);
      expect(find.text('Darul Kutub Al-Ilmiyyah'), findsOneWidget);
      expect(find.text('Dr. Rifa\'at Fauzi Abdul Muthalib'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('كتاب الأم'))),
          TextDirection.rtl);
    });

    testWidgets('BookCatalogScreen displays title and search input',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BookCatalogScreen(),
        ),
      );

      // Katalog selalu Arab dan RTL, apa pun bahasa aplikasi.
      // Judul dan subjudul pra-muat sama-sama menampilkan "فهرس الكتب".
      expect(find.text(ArabicCatalog.catalogTitle), findsNWidgets(2));
      expect(find.text(Loc.trAr('allBooks')), findsOneWidget);
    });

    testWidgets('book details are fully Arabic and RTL in any app language',
        (tester) async {
      AppConfig.localeNotifier.value = 'en';
      addTearDown(() => AppConfig.localeNotifier.value = 'id');
      await tester.pumpWidget(
        const MaterialApp(home: BookDetailScreen(book: sampleBook)),
      );

      expect(find.text(ArabicCatalog.bookCard), findsOneWidget);
      expect(find.text('Book Record'), findsNothing);
      expect(find.text('كتاب الأم'), findsOneWidget);
      expect(find.text(ArabicCatalog.digits('8')), findsWidgets);
      expect(Directionality.of(tester.element(find.text('كتاب الأم'))),
          TextDirection.rtl);
    });

    testWidgets('AppRoutes contains bookCatalog and bookDetail',
        (tester) async {
      expect(AppRoutes.bookCatalog, equals('/catalog'));
      expect(AppRoutes.bookDetail, equals('/book_detail'));
    });
  });
}
