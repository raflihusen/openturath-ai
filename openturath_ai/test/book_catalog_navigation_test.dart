import 'package:flutter/material.dart';
import 'package:openturath_ai/core/arabic_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_copy.dart';
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

      // Card 1: Identitas Kitab
      expect(find.text('كتاب الأم'), findsOneWidget);
      expect(find.text('kitab_al_umm_shafii'), findsOneWidget);

      // Card 2: Pengarang (المؤلف والوفاة)
      expect(find.text('المؤلف والوفاة'), findsOneWidget);
      expect(find.text('الإمام محمد بن إدريس الشافعي'), findsOneWidget);
      expect(find.text('ت. 204 هـ'), findsOneWidget);

      // Card 3: Klasifikasi & Kandungan (التصنيف والمصنف)
      expect(find.text('تصنيف النص'), findsOneWidget);
      expect(find.text(Loc.text('Asal Mazhab')), findsOneWidget);
      expect(find.text('المتقدمون'), findsOneWidget);
      expect(find.text('عدد الأجزاء: 8'), findsOneWidget);

      // Card 4: Penerbitan & Tahkik (بيانات الطبع والتحقيق)
      expect(find.text('بيانات الطبعة'), findsOneWidget);
      expect(find.text('Darul Kutub Al-Ilmiyyah'), findsOneWidget);
      expect(find.text('Dr. Rifa\'at Fauzi Abdul Muthalib'), findsOneWidget);

      // Aksi Riset telah dihapus sesuai prinsip The Quiet Scholar
      expect(find.text('AKSI & TELAAH RISET'), findsNothing);
      expect(find.text('Buka Ruang Kajian'), findsNothing);
      expect(find.text('Simpan ke Catatan Riset'), findsNothing);
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

    testWidgets(
        'English book details localize chrome while preserving Arabic title',
        (tester) async {
      AppConfig.localeNotifier.value = 'en';
      addTearDown(() => AppConfig.localeNotifier.value = 'id');
      await tester.pumpWidget(
        const MaterialApp(home: BookDetailScreen(book: sampleBook)),
      );

      expect(find.text('Book Record'), findsOneWidget);
      expect(find.text('Author and death year'), findsOneWidget);
      expect(find.text('كتاب الأم'), findsOneWidget);
      expect(find.text('d. 204 AH'), findsOneWidget);
      expect(find.text('8 volumes'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('Book Record'))),
          TextDirection.ltr);
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
