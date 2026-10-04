import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/open_turath_book.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/screens/book_detail_screen.dart';
import 'package:openturath_ai/screens/book_library_editorial_screen.dart';
import 'package:openturath_ai/screens/library_metadata_overview_screen.dart';
import 'package:openturath_ai/services/open_turath_catalog_repository.dart';
import 'package:openturath_ai/widgets/specialist_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget localized(String language, Widget page) {
    AppConfig.localeNotifier.value = language;
    return MaterialApp(
      locale: Locale(language),
      supportedLocales: Loc.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: page,
    );
  }

  setUp(() => AppConfig.localeNotifier.value = 'id');
  tearDown(() => AppConfig.localeNotifier.value = 'id');

  testWidgets('assistant card shows its remit and source instead of generic library rows',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(localized(
      'id',
      Scaffold(
        body: SpecialistCard(
          title: 'Fikih Syafi’i',
          fieldId: 'fiqh',
          scopeLabel: 'Matan · Syarah · Hasyiyah',
          referenceLabel: 'الأم · المجموع',
          onOpen: () {},
          onOpenLibrary: () {},
        ),
      ),
    ));

    expect(find.text('Fikih Syafi’i'), findsOneWidget);
    expect(find.text('Matan · Syarah · Hasyiyah'), findsOneWidget);
    expect(find.text('الأم · المجموع'), findsOneWidget);
    expect(find.text('Pustaka'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  const metadata = AiLibraryMetadata(
    keyName: 'hadits',
    idModul: '02_HADITS',
    kategori: 'Hadits Nabawi',
    nama: 'AI Kutubus Sunnah & Matan Hadits',
    namaArab: 'الحديث الشريف',
    totalKitab: 1173,
    totalJilid: '1.500+ Jilid',
    totalHalaman: 532640,
    totalKata: 105700587,
    rentangMasa: 'Abad 2 H - Abad 10 H',
    headlineAplikasi: 'Dilatih dengan 1.141 kitab',
  );

  testWidgets('Arabic reference overview omits conflicting legacy count and fits phone',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(localized(
      'ar',
      const AiLibraryOverviewPage(metadata: metadata, onSearch: null),
    ));

    expect(find.text('الحديث الشريف'), findsOneWidget);
    expect(find.text(Loc.tr('librarySummary')), findsOneWidget);
    expect(find.textContaining('1.141'), findsNothing);
    expect(Directionality.of(tester.element(find.text('الحديث الشريف'))),
        TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });

  const book = OpenTurathBook(
    id: 1,
    deathYear: 110,
    section: 'كتب السنة',
    shortName: 'فضائل مكة',
    title: 'فضائل مكة والسكن فيها',
    author: 'الحسن بن يسار البصري',
    editor: 'سامي مكي العاني',
    publisher: 'مكتبة الفلاح',
    edition: 'طبعة معتمدة',
    volumes: '1',
    sourceFolder: '-',
    pages: '40',
  );

  const canonicalBook = CanonicalBookPresentation(
    editionId: 'kitab_al_umm_shafii',
    titleArabic: 'كتاب الأم',
    authorArabic: 'الإمام محمد بن إدريس الشافعي',
    verifiedDeathYearHijri: 204,
    reviewedTypeLabel: 'Asal Mazhab',
    reviewedEraLabel: 'Mutaqaddimin',
    publisher: 'دار الكتب العلمية',
    muhaqqiq: 'رفعت فوزي عبد المطلب',
    volumesCount: 8,
  );

  testWidgets('English edition record keeps Arabic source and hides empty folder',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(localized(
      'en',
      const OpenTurathBookDetailPage(book: book),
    ));

    expect(find.text('Book reference'), findsOneWidget);
    expect(find.text('فضائل مكة والسكن فيها'), findsOneWidget);
    expect(find.text('Publisher'), findsOneWidget);
    expect(find.text('Source collection'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final language in Loc.supportedCodes) {
    testWidgets('book list and edition fit 320 px in $language', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(localized(
        language,
        const OpenTurathBookLibraryPage(
          books: [book],
          collectionName: 'الحديث الشريف',
        ),
      ));
      // Judul halaman adalah nama koleksi.
      expect(find.text('الحديث الشريف'), findsOneWidget);
      expect(find.text(book.title), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(localized(
        language,
        const OpenTurathBookDetailPage(book: book),
      ));
      expect(find.text(Loc.tr('bookReferenceLabel')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('canonical dossier fits 320 px in $language', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(localized(
        language,
        const BookDetailScreen(book: canonicalBook),
      ));
      expect(find.text(Loc.tr('bookDetails')), findsOneWidget);
      expect(find.text(canonicalBook.titleArabic), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
