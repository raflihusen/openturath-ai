import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/membership_pass_state.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/models/open_turath_book.dart';
import 'package:openturath_ai/screens/dashboard_screen.dart';
import 'package:openturath_ai/screens/profile_screen.dart';
import 'package:openturath_ai/screens/specialist_list_screen.dart';
import 'package:openturath_ai/screens/book_detail_screen.dart';
import 'package:openturath_ai/screens/book_library_editorial_screen.dart';
import 'package:openturath_ai/services/open_turath_catalog_repository.dart';
import 'package:openturath_ai/widgets/native_theme.dart';
import 'package:openturath_ai/widgets/tahawwulat_flagship_card.dart';
import 'package:openturath_ai/core/design/native_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final pair in [
      ('NativeInter', 'assets/native_fonts/NativeInter.ttf'),
      ('NativeArabic', 'assets/native_fonts/NativeArabic.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf')
    ]) {
      await (FontLoader(pair.$1)..addFont(rootBundle.load(pair.$2))).load();
    }
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => AppConfig.localeNotifier.value = 'id');
  final repo = OpenTurathCatalogRepository.instance;

  test('all five Tahawwulat personas load their parent corpus, never Syafii',
      () async {
    final parent =
        AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    final expected =
        await repo.loadBooksForModule(parent.id, allowFallback: false);
    expect(expected, isNotEmpty);
    for (final sub in parent.subAgents!) {
      final key = repo.resolveNativeCatalogKey(sub.id);
      expect(key, parent.id);
      final books = await repo.loadBooksForModule(key!, allowFallback: false);
      expect(books.map((b) => b.title), expected.map((b) => b.title));
      final meta = await repo.getMetadataForModule(key, allowFallback: false);
      expect(meta, isNotNull);
      expect(meta!.keyName, contains('tahawwulat'));
    }
  });
  test('unknown native catalogs fail closed', () async {
    expect(repo.resolveNativeCatalogKey('unknown_corpus'), isNull);
    await expectLater(
        repo.loadBooksForModule('unknown_corpus', allowFallback: false),
        throwsStateError);
    expect(
        await repo.getMetadataForModule('unknown_corpus', allowFallback: false),
        isNull);
  });
  test('volume classification excludes missing and ambiguous data', () {
    for (final value in ['', '-', 'unknown', '1-2', '2+']) {
      expect(nativeVolumeCount(value), isNull);
    }
    expect(nativeVolumeCount('1'), 1);
    expect(nativeVolumeCount('١'), 1);
    expect(nativeVolumeCount('۲'), 2);
    expect(nativeVolumeCount('12 jilid'), 12);
  });

  final user = UserModel(
      uid: 'visual_demo',
      name: 'Pengguna Demo',
      email: 'demo@example.test',
      photoUrl: '',
      plan: 'pro',
      questionsUsed: 0,
      entitlements: {
        'all_access': ModuleEntitlement(
            plan: 'pro', status: 'active', expiry: DateTime(2027, 10, 22))
      });
  const book = OpenTurathBook(
      id: 1,
      deathYear: 676,
      section: 'الفقه وأصوله',
      shortName: '',
      title: 'مِنْهَاجُ الطَّالِبِينَ وَعُمْدَةُ الْمُفْتِينَ',
      author: 'الإمام يحيى بن شرف النووي',
      editor: 'محقق الطبعة',
      publisher: 'دار نشر الكتاب',
      edition: '1440 هـ',
      volumes: '2',
      sourceFolder: 'INTERNAL_FOLDER_NOT_FOR_UI',
      pages: '500');

  for (final locale in ['id', 'en', 'ar']) {
    testWidgets('five direct role actions preserve identity in $locale', (tester) async {
      AppConfig.localeNotifier.value = locale;
      final agent = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
      final opened = <String>[];
      await tester.pumpWidget(MaterialApp(
        locale: Locale(locale), supportedLocales: Loc.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: NativeTheme(child: Scaffold(body: SingleChildScrollView(
          child: TahawwulatFlagshipCard(agent: agent, isSubscribed: true,
            onOpenMain: () {}, onOpenSubAgent: (sub) => opened.add(sub.id)),
        ))),
      ));
      for (final sub in agent.subAgents!) {
        final button = find.widgetWithText(TextButton, sub.name);
        expect(button, findsOneWidget);
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pump();
      }
      expect(opened, agent.subAgents!.map((s) => s.id).toList());
      expect(tester.takeException(), isNull);
    });
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        for (final page in [
          'home',
          'settings',
          'assistants',
          'catalog',
          'detail',
          'canonical'
        ]) {
          testWidgets(
              '$page $locale dark=$dark text=$scale full production layout',
              (tester) async {
            tester.view.physicalSize = Size(scale == 2 ? 320 : 390, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            AppConfig.localeNotifier.value = locale;
            final controller = TextEditingController();
            final capture = GlobalKey();
            final Widget screen = switch (page) {
              'home' => NativeDashboardPage(
                  user: user,
                  agents: AgentModel.defaultAgents,
                  lastOpenedAgentId: 'fiqh_tahawwulat',
                  searchController: controller,
                  searchQuery: '',
                  onSearch: (_) {},
                  onBrowse: ({String? fieldId}) {},
                  onOpen: (_) {},
                  onRefresh: () async {}),
              'settings' => NativeProfilePage(
                  displayName: user.name,
                  email: user.email,
                  membership: resolveMembershipPass(user),
                  version: 'preview',
                  onManage: () {},
                  onViewAccess: () {},
                  onLanguage: () {},
                  onAbout: () {},
                  onLogout: () {},
                  onDelete: () {}),
              'assistants' => NativeAssistantPage(
                  filtered: AgentModel.defaultAgents,
                  user: user,
                  searchController: controller,
                  searchQuery: '',
                  corpusKind: CorpusKind.discipline,
                  onSearch: (_) {},
                  onOpen: (_) {},
                  onSubAgent: (_, __) {},
                  onKind: (_) {},
                  onField: (_) {}),
              'catalog' => const OpenTurathBookLibraryPage(
                  books: [book], collectionName: 'Fikih Syafi’i'),
              'detail' => const OpenTurathBookDetailPage(book: book),
              _ => const BookDetailScreen(
                  localizedControls: true,
                  book: CanonicalBookPresentation(
                      editionId: 'INTERNAL_EDITION_NOT_FOR_UI',
                      titleArabic: 'كتاب العلم',
                      authorArabic: 'المؤلف',
                      publisher: 'دار العلم',
                      reviewedEraLabel: 'Mutaqaddimin',
                      volumesCount: 2)),
            };
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
                  key: capture, child: NativeTheme(child: screen)),
            ));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.text('INTERNAL_FOLDER_NOT_FOR_UI'), findsNothing);
            expect(find.text('INTERNAL_EDITION_NOT_FOR_UI'), findsNothing);
            if (page == 'home' && scale == 1) {
              expect(find.text(NativeCopy.text('field_fiqh')), findsOneWidget);
              if (locale == 'ar') expect(find.text('Fikih & Fatwa'), findsNothing);
            }
            if (scale == 1 && const bool.fromEnvironment('CAPTURE_REVISION')) {
              final boundary = capture.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              await tester.runAsync(() async {
                final image = await boundary.toImage(pixelRatio: 2);
                final bytes =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                await File(
                        '/tmp/revision-$page-$locale-${dark ? "dark" : "light"}.png')
                    .writeAsBytes(bytes!.buffer.asUint8List());
                image.dispose();
              });
            }
            final scrolls = find.byType(Scrollable);
            if (scrolls.evaluate().isNotEmpty) {
              await tester.drag(scrolls.first, const Offset(0, -600));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            await tester.pumpWidget(const SizedBox.shrink());
            controller.dispose();
          });
        }
      }
    }
  }
}
