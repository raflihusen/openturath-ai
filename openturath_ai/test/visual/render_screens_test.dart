// Merender layar ke PNG untuk tinjauan visual. Hanya berjalan bila
// OT_SNAPSHOT_DIR diset:  OT_SNAPSHOT_DIR=/tmp/shots flutter test test/visual
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/core/constants.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/dashboard_screen.dart';
import 'package:openturath_ai/screens/bookmark_screen.dart';
import 'package:openturath_ai/screens/login_screen.dart';
import 'package:openturath_ai/widgets/app_loader.dart';
import 'package:openturath_ai/screens/profile_screen.dart';
import 'package:openturath_ai/screens/subscription_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/services/open_turath_catalog_repository.dart';
import 'package:openturath_ai/widgets/assistant_grid_card.dart';
import 'package:openturath_ai/widgets/legal_document_sheet.dart';
import 'package:openturath_ai/widgets/tahawwulat_flagship_card.dart';
import 'package:openturath_ai/widgets/tahawwulat_introduction_sheet.dart';

final _dir = Platform.environment['OT_SNAPSHOT_DIR'];
final _key = GlobalKey();

Future<void> _loadFonts() async {
  Future<void> load(String family, String asset) async {
    final loader = FontLoader(family)..addFont(rootBundle.load(asset));
    await loader.load();
  }

  await load('NativeOutfit', 'assets/native_fonts/NativeOutfit.ttf');
  await load('NativeInter', 'assets/native_fonts/NativeInter.ttf');
  await load('NativeNewsreader', 'assets/native_fonts/NativeNewsreader.ttf');
  await load('NativeArabic', 'assets/native_fonts/NativeArabic.ttf');
  await load('NativeArabicUI', 'assets/native_fonts/NativeArabicUI.ttf');
  final icons = File(
      '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

Future<void> _shot(WidgetTester tester, String name, Widget child,
    {Size size = const Size(950, 900),
    String locale = 'id',
    bool dark = false}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  AppConfig.localeNotifier.value = locale;
  await tester.pumpWidget(RepaintBoundary(
    key: _key,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(locale),
      supportedLocales: Loc.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, c) => LocaleScope(child: c!),
      home: child,
    ),
  ));
  await tester
      .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pump(const Duration(milliseconds: 900));
  final boundary =
      _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_dir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
  final error = tester.takeException();
  if (error != null) {
    // ignore: avoid_print
    print(
        'RENDER ERROR in $name: ${error.toString().split('\n').take(6).join(' | ')}');
  }
}

void main() {
  if (_dir == null) {
    test('visual snapshots are opt-in (set OT_SNAPSHOT_DIR)', () {});
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render', (tester) async {
    await tester.runAsync(_loadFonts);
    final meta = await tester.runAsync(
            () => OpenTurathCatalogRepository.instance.loadAllMetadata()) ??
        const <String, AiLibraryMetadata>{};
    final agents = AgentModel.defaultAgents
        .where((a) => a.kind == CorpusKind.discipline)
        .toList();
    final flagship = agents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    final others = agents.where((a) => a.id != flagship.id).take(6).toList();

    Widget assistants() => Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              TahawwulatFlagshipCard(
                agent: flagship,
                metadata: meta['fiqh_tahawwulat'],
                isSubscribed: true,
                onOpenMain: () {},
                onOpenSubAgent: (_) {},
                onOpenLibrary: () {},
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < others.length; i += 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var c = i;
                            c < i + 3 && c < others.length;
                            c++) ...[
                          if (c > i) const SizedBox(width: 12),
                          Expanded(
                            child: AssistantGridCard(
                              agent: others[c],
                              metadata:
                                  OpenTurathCatalogRepository.exactMetadata(
                                      meta, others[c].id),
                              onOpen: () {},
                              onOpenLibrary: () {},
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ]),
          ),
        );

    for (final locale in ['id', 'ar']) {
      await _shot(tester, 'login_$locale', const LoginScreen(), locale: locale);
      await _shot(tester, 'assistants_$locale', assistants(),
          size: const Size(1000, 1100), locale: locale);
      await _shot(tester, 'tahawwulat_$locale',
          const TahawwulatIntroductionSheet(asPage: true),
          size: const Size(1280, 1500), locale: locale);
    }
    for (final section in [2, 3, 4, 5, 6]) {
      await _shot(
          tester,
          'tahawwulat_s$section',
          TahawwulatIntroductionSheet(
              key: ValueKey(section), asPage: true, initialSection: section),
          size: const Size(1280, 1700));
    }
    await _shot(tester, 'tahawwulat_phone',
        const Scaffold(body: TahawwulatIntroductionSheet()),
        size: const Size(390, 844));
    await _shot(tester, 'login_dark', const LoginScreen(), dark: true);
    SharedPreferences.setMockInitialValues({});
    AuthService.previewUser = UserModel(
      uid: 'Qx7Zp2LmN8vRt4Kc',
      name: 'Rafli Husen',
      email: 'contoh@openturath.id',
      photoUrl: '',
      plan: AppConstants.planTrial,
      questionsUsed: 0,
    );
    for (final locale in ['id', 'ar']) {
      await _shot(tester, 'dashboard_$locale', const DashboardScreen(),
          locale: locale);
      await _shot(tester, 'profile_$locale', const ProfileScreen(),
          locale: locale);
      await _shot(tester, 'subscription_$locale', const SubscriptionScreen(),
          size: const Size(950, 1500), locale: locale);
    }
    await _shot(tester, 'dashboard_dark', const DashboardScreen(), dark: true);
    await _shot(tester, 'dashboard_phone', const DashboardScreen(),
        size: const Size(390, 844));
    await _shot(tester, 'notes_id', const BookmarkScreen());
    await _shot(
        tester,
        'loader_id',
        Scaffold(
            body: AppLoader.fullscreen(
                title: 'Fikih Syafi\'i',
                subtitle: 'Menyiapkan ruang telaah…',
                onCancel: () {})),
        size: const Size(950, 600));
    AuthService.previewUser = null;
    await _shot(tester, 'login_phone', const LoginScreen(),
        size: const Size(390, 844));
    await _shot(
        tester,
        'guideline_id',
        Builder(
            builder: (context) => Scaffold(
                body: Center(
                    child: FilledButton(
                        onPressed: () =>
                            LegalDocumentSheet.showAiGuideline(context),
                        child: const Text('open'))))),
        size: const Size(950, 900));
  });
}
