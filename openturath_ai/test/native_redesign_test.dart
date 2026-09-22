import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:openturath_ai/models/open_turath_book.dart';
import 'package:openturath_ai/screens/book_library_editorial_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/design/native_design.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/widgets/native_components.dart';
import 'package:openturath_ai/widgets/native_theme.dart';
import 'package:openturath_ai/widgets/tahawwulat_flagship_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    for (final pair in [
      ('NativeArabic', 'NativeArabic'),
      ('NativeNewsreader', 'NativeNewsreader'),
      ('NativeOutfit', 'NativeOutfit')
    ]) {
      await (FontLoader(pair.$1)
            ..addFont(rootBundle.load('assets/native_fonts/${pair.$2}.ttf')))
          .load();
    }
  });
  tearDown(() => AppConfig.localeNotifier.value = 'id');

  test('native copy covers three languages with matching placeholders', () {
    final pattern = RegExp(r'\{\d+\}');
    for (final entry in NativeCopy.values.entries) {
      expect(entry.value.length, 3, reason: entry.key);
      final expected =
          pattern.allMatches(entry.value.first).map((m) => m[0]).toSet();
      for (final value in entry.value) {
        expect(value.trim(), isNotEmpty, reason: entry.key);
        expect(pattern.allMatches(value).map((m) => m[0]).toSet(), expected,
            reason: entry.key);
      }
    }
  });

  for (final locale in ['id', 'en', 'ar']) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('five native study paths $locale dark=$dark scale=$scale',
            (tester) async {
          tester.view.physicalSize = Size(scale == 2 ? 320 : 390, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          AppConfig.localeNotifier.value = locale;
          final agent = AgentModel.defaultAgents
              .firstWhere((a) => a.id == 'fiqh_tahawwulat');
          String? selected;
          final capture = GlobalKey();
          await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            supportedLocales: Loc.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            builder: (context, child) => LocaleScope(
                child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(scale),
                        disableAnimations: true),
                    child: child!)),
            home: RepaintBoundary(
                key: capture,
                child: NativeTheme(
                    child: TahawwulatCollectionPage(
                  agent: agent,
                  isSubscribed: true,
                  onOpenMain: () {},
                  onOpenSubAgent: (sub) => selected = sub.id,
                ))),
          ));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
              Directionality.of(
                  tester.element(find.byType(TahawwulatCollectionPage))),
              locale == 'ar' ? TextDirection.rtl : TextDirection.ltr);
          if (scale == 1 && const bool.fromEnvironment('CAPTURE_NATIVE')) {
            final boundary = capture.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final image = await boundary.toImage(pixelRatio: 2);
              final bytes =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              await File(
                      '/tmp/openturath-$locale-${dark ? "dark" : "light"}.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          for (final sub in agent.subAgents!) {
            final label = find.text(sub.name);
            await tester.scrollUntilVisible(label, 240, maxScrolls: 60);
            await tester.pumpAndSettle();
            await tester.tap(label);
            expect(selected, sub.id);
            expect(tester.takeException(), isNull);
          }
        });
      }
    }
  }

  const book = OpenTurathBook(
      id: 7,
      deathYear: 676,
      section: 'الفقه',
      shortName: 'المنهاج',
      title: 'مِنْهَاجُ الطَّالِبِينَ',
      author: 'النووي',
      editor: '',
      publisher: 'دار العلم',
      edition: '1440',
      volumes: '2',
      sourceFolder: 'fiqh',
      pages: '500');

  test('reference identity is locale-independent and citation follows locale',
      () {
    final ids = <String>{};
    for (final locale in ['id', 'en', 'ar']) {
      AppConfig.localeNotifier.value = locale;
      ids.add(nativeBookReferenceId(book));
      expect(nativeBookCitation(book),
          contains('${NativeCopy.text('author')}: النووي'));
      expect(nativeBookCitation(book), isNot(contains('Tahqiq/Editor')));
    }
    expect(ids.length, 1);
  });

  for (final locale in ['id', 'en', 'ar']) {
    testWidgets(
        'catalog Arabic normalization and empty state $locale at 200 percent',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      AppConfig.localeNotifier.value = locale;
      await tester.pumpWidget(MaterialApp(
        locale: Locale(locale),
        supportedLocales: Loc.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => LocaleScope(
            child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(2)),
                child: child!)),
        home: const NativeTheme(
            child: OpenTurathBookLibraryPage(
                books: [book], collectionName: 'الفقه')),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), 'منهاج');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text(book.title), 240,
          scrollable: find.byType(Scrollable).first);
      expect(find.text(book.title), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.byType(TextField), -240,
          scrollable: find.byType(Scrollable).first);
      await tester.enterText(find.byType(TextField), 'nomatch');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
          find.text(NativeCopy.text('noBooks')), 240,
          scrollable: find.byType(Scrollable).first);
      expect(find.text(NativeCopy.text('noBooks')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('native loading honors reduced motion and releases slow timer',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: NativeLoading()))));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.hourglass_empty_rounded), findsOneWidget);
    await tester.pump(const Duration(seconds: 8));
    expect(find.text(NativeCopy.text('slow')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
