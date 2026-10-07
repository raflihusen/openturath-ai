// Merender layar ke PNG untuk tinjauan visual. Hanya berjalan bila
// OT_SNAPSHOT_DIR diset:  OT_SNAPSHOT_DIR=/tmp/shots flutter test test/visual
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
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
import 'package:openturath_ai/models/turath_chat_message.dart';
import 'package:openturath_ai/widgets/native_turath_chat_view.dart';
import 'package:openturath_ai/screens/dashboard_screen.dart';
import 'package:openturath_ai/screens/main_shell_screen.dart';
import 'package:openturath_ai/screens/bookmark_screen.dart';
import 'package:openturath_ai/screens/login_screen.dart';
import 'package:openturath_ai/widgets/app_error_state.dart';
import 'package:openturath_ai/screens/library_metadata_overview_screen.dart';
import 'package:openturath_ai/screens/book_library_editorial_screen.dart';
import 'package:openturath_ai/screens/book_catalog_screen.dart';
import 'package:openturath_ai/widgets/app_loader.dart';
import 'package:openturath_ai/screens/profile_screen.dart';
import 'package:openturath_ai/screens/subscription_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/services/open_turath_catalog_repository.dart';
import 'package:openturath_ai/widgets/assistant_grid_card.dart';
import 'package:openturath_ai/widgets/exclusive_activation_dialog.dart';
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

  Future<void> loadAll(String family, List<String> assets) async {
    final loader = FontLoader(family);
    for (final asset in assets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }

  const dir = 'assets/native_fonts';
  await loadAll('NativeOutfit', [
    '$dir/NativeOutfit.ttf',
    '$dir/NativeOutfit-600.ttf',
    '$dir/NativeOutfit-700.ttf',
  ]);
  await load('NativeInter', '$dir/NativeInter.ttf');
  await loadAll('NativeNewsreader',
      ['$dir/NativeNewsreader-400.ttf', '$dir/NativeNewsreader.ttf']);
  await loadAll(
      'NativeArabic', ['$dir/NativeArabic.ttf', '$dir/NativeArabic-700.ttf']);
  await load('NativeArabicUI', '$dir/NativeArabicUI.ttf');
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
    bool dark = false,
    double textScale = 1,
    String? tap}) async {
  // Jendela lebar dirender sebagai macOS, jendela sempit sebagai Android,
  // supaya lembar dan dialog adaptif tampil seperti di perangkat aslinya.
  debugDefaultTargetPlatformOverride =
      size.width >= 700 ? TargetPlatform.macOS : TargetPlatform.android;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  AppConfig.localeNotifier.value = locale;
  await tester.pumpWidget(RepaintBoundary(
    key: _key,
    child: MaterialApp(
      // Kunci per tangkapan: navigator dan dialog tidak terbawa dari sebelumnya.
      key: ValueKey(name),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(locale),
      supportedLocales: Loc.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: LocaleScope(child: c!)),
      home: child,
    ),
  ));
  await tester
      .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pump(const Duration(milliseconds: 900));
  if (tap != null && find.text(tap).evaluate().isEmpty) {
    fail('Render $name: required action $tap was not found');
  } else if (tap != null) {
    // Buka dialog atau lembar dengan mengetuk teks pemicunya.
    await tester.ensureVisible(find.text(tap).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(tap).first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 900));
  }
  final boundary =
      _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_dir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
  debugDefaultTargetPlatformOverride = null;
  final error = tester.takeException();
  expect(error, isNull,
      reason: 'Render $name must have no framework exception');
}

void main() {
  if (_dir == null) {
    test('visual snapshots are opt-in (set OT_SNAPSHOT_DIR)', () {});
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/package_info'),
            (_) async => {
                  'appName': 'OpenTurath AI',
                  'packageName': 'id.openturath',
                  'version': '1.0.63',
                  'buildNumber': '64',
                  'buildSignature': ''
                });
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
    await _shot(tester, 'tahawwulat_long',
        const TahawwulatIntroductionSheet(asPage: true),
        size: const Size(1280, 3600));
    await _shot(tester, 'tahawwulat_window',
        const TahawwulatIntroductionSheet(asPage: true),
        size: const Size(850, 860));
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
    Widget mixedChat() => Scaffold(
        appBar: AppBar(title: const Text('Fikih Tahawwulat: Al-Muhaqqiq')),
        body: NativeTurathChatView(
            agent: flagship,
            isGenerating: false,
            onSend: (_) {},
            messages: [
              TurathChatMessage(
                  id: 'question',
                  isUser: true,
                  timestamp: DateTime(2026),
                  text:
                      'Bagaimana memahami makna kebahagiaan dalam Fikih Tahawwulat?'),
              TurathChatMessage(
                  id: 'answer',
                  isUser: false,
                  timestamp: DateTime(2026),
                  text:
                      '## Memahami kebahagiaan\n\nIni contoh tampilan bilingual. Istilah **السَّعَادَة** berada dalam paragraf Indonesia tanpa mengubah arah baca. Rujukan perlu diperiksa pada edisi kitab yang digunakan.\n\n> السعادة في الدارين\n\n### Langkah telaah\n\n1. Baca kutipan sumber.\n2. Periksa konteks dan halaman.\n3. Pisahkan kutipan dari penjelasan AI.',
                  citations: const [
                    'Contoh tampilan · bukan kutipan terverifikasi'
                  ])
            ]));
    await _shot(tester, 'chat_mixed', mixedChat(), size: const Size(1280, 900));
    await _shot(tester, 'chat_mixed_dark', mixedChat(), dark: true);
    await _shot(tester, 'chat_mixed_phone', mixedChat(),
        size: const Size(390, 844));
    await _shot(tester, 'subscription_phone', const SubscriptionScreen(),
        size: const Size(390, 844));
    await _shot(tester, 'profile_phone', const ProfileScreen(),
        size: const Size(390, 844));
    await _shot(tester, 'shell_desktop', const MainShellScreen(),
        size: const Size(1280, 900));
    await _shot(tester, 'shell_phone', const MainShellScreen(),
        size: const Size(390, 844));
    await _shot(tester, 'profile_large_text', const ProfileScreen(),
        size: const Size(390, 1000), textScale: 2);
    await _shot(tester, 'subscription_ar_phone', const SubscriptionScreen(),
        size: const Size(390, 844), locale: 'ar');
    await _shot(tester, 'dashboard_dark', const DashboardScreen(), dark: true);
    await _shot(tester, 'dashboard_phone', const DashboardScreen(),
        size: const Size(390, 844));
    // Ukuran jendela yang dipakai pengguna (sekitar 850 x 860) dan jendela lebar.
    await _shot(tester, 'subscription_window', const SubscriptionScreen(),
        size: const Size(850, 1500));
    await _shot(tester, 'subscription_wide', const SubscriptionScreen(),
        size: const Size(1280, 900));
    await _shot(tester, 'subscription_dark', const SubscriptionScreen(),
        size: const Size(1280, 900), dark: true);
    await _shot(tester, 'profile_window', const ProfileScreen(),
        size: const Size(850, 860));
    for (final state in <(String, AppErrorState)>[
      (
        'auth',
        AppErrorState(
          icon: Icons.link_off_rounded,
          title: Loc.tr('roomAuthTitle'),
          message: Loc.tr('roomAuthBody'),
          retryLabel: Loc.tr('roomOpenInBrowser'),
          retryIcon: Icons.open_in_new_rounded,
          onRetry: () {},
          onBack: () {},
          backLabel: Loc.tr('back'),
        )
      ),
      (
        'loadfail',
        AppErrorState(
          icon: Icons.wifi_off_rounded,
          title: Loc.tr('roomLoadFailTitle'),
          message: Loc.tr('roomLoadFailBody'),
          retryLabel: Loc.tr('tryAgain'),
          onRetry: () {},
          onBack: () {},
          backLabel: Loc.tr('back'),
        )
      ),
    ]) {
      await _shot(tester, 'room_${state.$1}', Scaffold(body: state.$2),
          size: const Size(850, 700));
    }
    const win = Size(850, 860);
    await _shot(tester, 'dlg_field', const SubscriptionScreen(),
        size: win, tap: 'Pilih bidang');
    for (final dark in [false, true]) {
      await _shot(
          tester,
          'dlg_activation${dark ? '_dark' : ''}',
          const Scaffold(
              body: ExclusiveActivationDialog(
                  serviceTitle: "Fikih Syafi'i", durationDays: 30)),
          size: win,
          dark: dark);
    }
    await _shot(tester, 'dlg_redeem', const SubscriptionScreen(),
        size: const Size(850, 1500), tap: 'Gunakan voucher');
    await _shot(tester, 'dlg_language', const ProfileScreen(),
        size: win, tap: 'Bahasa');
    await _shot(tester, 'dlg_about', const ProfileScreen(),
        size: win, tap: 'Tentang OpenTurath');
    await _shot(tester, 'dlg_delete', const ProfileScreen(),
        size: win, tap: 'Hapus akun');
    AuthService.previewUser = UserModel(
      uid: 'Qx7Zp2LmN8vRt4Kc',
      name: 'Rafli Husen',
      email: 'contoh@openturath.id',
      photoUrl: '',
      plan: AppConstants.planTholib1m,
      questionsUsed: 0,
      subscriptionExpiry: DateTime(2027, 1, 1),
      entitlements: const {
        'all_access': ModuleEntitlement(plan: 'permanent', status: 'active'),
      },
    );
    await _shot(tester, 'dlg_access', const ProfileScreen(),
        size: win, tap: 'Daftar asisten aktif');
    await _shot(tester, 'dlg_access_dark', const ProfileScreen(),
        size: win, tap: 'Daftar asisten aktif', dark: true);
    // Layar pustaka: ringkasan koleksi, daftar kitab, dan rincian kitab.
    final catalog = OpenTurathCatalogRepository.instance;
    final libraryMeta = await tester.runAsync(() => catalog.loadAllMetadata());
    final libraryBooks =
        await tester.runAsync(() => catalog.loadBooksForModule('fiqh_syafii'));
    if (libraryMeta != null && libraryMeta.isNotEmpty) {
      final syafii = libraryMeta['fiqh_syafii'] ?? libraryMeta.values.first;
      await _shot(tester, 'library_overview',
          AiLibraryOverviewPage(metadata: syafii, onSearch: () {}),
          size: win);
      await _shot(tester, 'library_overview_wide',
          AiLibraryOverviewPage(metadata: syafii, onSearch: () {}),
          size: const Size(1280, 860));
    }
    if (libraryBooks != null && libraryBooks.isNotEmpty) {
      await _shot(
          tester,
          'library_books',
          OpenTurathBookLibraryPage(
              books: libraryBooks, collectionName: "Fikih Syafi'i"),
          size: win);
      await _shot(tester, 'library_book_detail',
          OpenTurathBookDetailPage(book: libraryBooks.first),
          size: win);
      await _shot(tester, 'library_book_detail_wide',
          OpenTurathBookDetailPage(book: libraryBooks.first),
          size: const Size(1280, 860));
      await _shot(tester, 'library_detail_phone',
          OpenTurathBookDetailPage(book: libraryBooks.first),
          size: const Size(390, 844));
      await _shot(
          tester,
          'library_ar_phone',
          OpenTurathBookLibraryPage(
              books: libraryBooks, collectionName: "Fikih Syafi'i"),
          size: const Size(390, 844),
          locale: 'ar');
    }
    await _shot(tester, 'catalog_id', const BookCatalogScreen(), size: win);
    await _shot(tester, 'profile_dark', const ProfileScreen(),
        size: win, dark: true);
    await _shot(tester, 'subscription_ar_new', const SubscriptionScreen(),
        size: const Size(1280, 900), locale: 'ar');
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
