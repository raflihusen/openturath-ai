import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/open_turath_book.dart';
import 'package:openturath_ai/screens/book_library_editorial_screen.dart';

const _book = OpenTurathBook(
  id: 1, deathYear: 204, section: 'فقه', shortName: 'الأُمّ',
  title: 'كِتَابُ الأُمِّ', author: 'الإمام الشافعي', editor: 'المحقق',
  publisher: 'دار النشر', edition: 'الأولى', volumes: '1',
  sourceFolder: '', pages: '100',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => AppConfig.localeNotifier.value = 'id');
  tearDown(() => AppConfig.localeNotifier.value = 'id');

  Widget catalog({String language = 'id', bool dark = false, double scale = 1}) {
    AppConfig.localeNotifier.value = language;
    return MaterialApp(
      theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
      locale: Locale(language), supportedLocales: Loc.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const OpenTurathBookLibraryPage(
        books: [_book], collectionName: 'Koleksi uji',
      ),
    );
  }

  testWidgets('unvocalized Arabic search finds the vocalized title and clears',
      (tester) async {
    await tester.pumpWidget(catalog());
    await tester.enterText(find.byType(TextField), 'كتاب الام');
    await tester.pump();
    expect(find.text(_book.title), findsOneWidget);
    expect(find.byTooltip(Loc.tr('clearSearch')), findsOneWidget);
    await tester.tap(find.byTooltip(Loc.tr('clearSearch')));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
    expect(find.text(_book.title), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus, isTrue);
  });

  testWidgets('volume choices expose selection and support keyboard activation',
      (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    await tester.pumpWidget(catalog());
    final multiple = find.widgetWithText(ChoiceChip, Loc.tr('multipleVolumes'));
    expect(multiple, findsOneWidget);
    Focus.of(tester.element(find.text(Loc.tr('multipleVolumes')))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(tester.widget<ChoiceChip>(multiple).selected, isTrue);
    expect(tester.getSemantics(multiple), matchesSemantics(
      label: Loc.tr('multipleVolumes'), isSelected: true,
      hasSelectedState: true, isEnabled: true, hasEnabledState: true,
      isFocusable: true, isFocused: true, hasTapAction: true,
      isButton: true, hasFocusAction: true,
    ));
    expect(find.text(_book.title), findsNothing);
    await tester.tap(find.text(Loc.tr('allBooks')));
    await tester.pumpAndSettle();
    expect(find.text(_book.title), findsOneWidget);
  });

  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    for (final language in Loc.supportedCodes) {
      for (final dark in [false, true]) {
        testWidgets('catalog reflows at $width in $language dark=$dark with 2x text',
            (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });
          await tester.pumpWidget(catalog(language: language, dark: dark, scale: 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.enterText(find.byType(TextField), 'No result');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
