import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/screens/book_catalog_screen.dart';
import 'package:openturath_ai/screens/book_detail_screen.dart';
import 'package:openturath_ai/widgets/book_row_item.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('id')}) => MaterialApp(
  locale: locale,
  supportedLocales: const [Locale('id'), Locale('en'), Locale('ar')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: home,
);

String _withoutBidi(String value) => value.replaceAll(RegExp(r'[\u2066-\u2069]'), '');

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

    testWidgets('BookRowItem displays Arabic title in RTL and compact tags', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _localizedApp(
          Scaffold(
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
      expect(find.text('W. 204 H'), findsOneWidget);
      expect(find.text('8 jilid'), findsOneWidget);
      expect(find.text('Detail edisi'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      final titleContext = tester.element(find.text('كتاب الأم'));
      expect(Directionality.of(titleContext), TextDirection.rtl);
      final authorContext = tester.element(find.text('الإمام محمد بن إدريس الشافعي'));
      expect(Directionality.of(authorContext), TextDirection.rtl);

      // Tap the item
      await tester.tap(find.byType(BookRowItem));
      expect(tapped, isTrue);
    });

    testWidgets('BookDetailScreen separates Arabic values and truthful edition data', (tester) async {
      await tester.pumpWidget(_localizedApp(const BookDetailScreen(book: sampleBook)));
      expect(find.text('كتاب الأم'), findsOneWidget);
      expect(find.text('Pengarang'), findsOneWidget);
      expect(find.text('Data edisi'), findsOneWidget);
      expect(find.text('Klasifikasi'), findsOneWidget);
      // Bibliography values may contain invisible directional isolates.
      expect(find.byWidgetPredicate((widget) => widget is SelectableText &&
          _withoutBidi(widget.data ?? '') == '204 H'), findsOneWidget);
      expect(find.text('Asal Mazhab'), findsOneWidget);
      expect(find.text('Mutaqaddimin'), findsOneWidget);
      expect(find.text('Darul Kutub Al-Ilmiyyah'), findsOneWidget);
      expect(find.text('Belum tercatat'), findsWidgets);
      expect(find.text('معتمد في المذهب والفتوى'), findsNothing);
      expect(Directionality.of(tester.element(find.text('الإمام محمد بن إدريس الشافعي'))), TextDirection.rtl);
      expect(find.text('Simpan rujukan'), findsOneWidget);
      expect(find.text('Salin sitasi'), findsOneWidget);
    });

    testWidgets('BookCatalogScreen displays title and search input', (tester) async {
      await tester.pumpWidget(
        _localizedApp(const BookCatalogScreen()),
      );

      expect(find.text('Katalog kitab'), findsOneWidget);
      expect(find.text("Mazhab Syafi'i"), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Saring koleksi'), findsOneWidget);
      expect(find.text("87 Kitab Mazhab Syafi'i"), findsNothing);
    });

    testWidgets('Arabic edition labels inherit RTL while source numbers stay literal', (tester) async {
      await tester.pumpWidget(_localizedApp(const Scaffold(body: Column(children: [
        BibliographicField(label: 'سنة الوفاة', value: '204 هـ'),
        BibliographicField(label: 'الناشر', value: 'دار الكتب العلمية', sourceText: true),
      ])), locale: const Locale('ar')));
      final label = tester.widget<Text>(find.text('سنة الوفاة'));
      expect(label.textDirection, isNull);
      expect(Directionality.of(tester.element(find.text('سنة الوفاة'))), TextDirection.rtl);
      expect(find.text('\u2066204\u2069 هـ'), findsOneWidget);
      expect(find.text('٢٠٤ هـ'), findsNothing);
      expect(find.text('دار الكتب العلمية'), findsOneWidget);
    });

    testWidgets('AppRoutes contains bookCatalog and bookDetail', (tester) async {
      expect(AppRoutes.bookCatalog, equals('/catalog'));
      expect(AppRoutes.bookDetail, equals('/book_detail'));
    });
  });
}


