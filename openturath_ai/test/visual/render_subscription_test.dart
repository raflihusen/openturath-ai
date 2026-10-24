// Merender layar Langganan ke PNG untuk audit visual. Hanya berjalan bila
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
import 'package:openturath_ai/core/constants.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/subscription_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';

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
  await loadAll('NativeArabicUI',
      ['$dir/Cairo-400.ttf', '$dir/Cairo-600.ttf', '$dir/Cairo-700.ttf']);
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
    String? tap,
    String? scrollTo,
    String? query}) async {
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
  if (query != null) {
    await tester.enterText(find.byType(TextField).first, query);
    await tester.pump(const Duration(milliseconds: 600));
  }
  final trigger = tap == null
      ? null
      : (find.text(tap).evaluate().isNotEmpty
          ? find.text(tap)
          : find.byTooltip(tap));
  if (trigger != null && trigger.evaluate().isEmpty) {
    fail('Render $name: required action $tap was not found');
  } else if (trigger != null) {
    await tester.ensureVisible(trigger.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(trigger.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 900));
  }
  if (scrollTo != null) {
    await tester.ensureVisible(find.text(scrollTo).first);
    await tester.pump(const Duration(milliseconds: 500));
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

  testWidgets('render langganan', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/package_info'),
            (_) async => {
                  'appName': 'OpenTurath AI',
                  'packageName': 'id.openturath',
                  'version': '1.0.70',
                  'buildNumber': '71',
                  'buildSignature': ''
                });
    await tester.runAsync(_loadFonts);
    AuthService.previewUser = UserModel(
      uid: 'Qx7Zp2LmN8vRt4Kc',
      name: 'Rafli Husen',
      email: 'contoh@openturath.id',
      photoUrl: '',
      plan: AppConstants.planTrial,
      questionsUsed: 0,
    );
    final tag = Platform.environment['OT_TAG'] ?? 'now';
    if (Platform.environment['OT_CASES'] == '1') {
      const sub = SubscriptionScreen();
      await _shot(tester, 'sub_${tag}_1bulan', sub,
          size: const Size(980, 1300), tap: '1 Bulan');
      await _shot(tester, 'sub_${tag}_scale16', sub,
          size: const Size(390, 2600), textScale: 1.6);
      await _shot(tester, 'sub_${tag}_320', sub, size: const Size(320, 2200));
      await _shot(tester, 'sub_${tag}_ar_p', sub,
          size: const Size(390, 1900), locale: 'ar');
      await _shot(tester, 'sub_${tag}_850', sub, size: const Size(850, 1400));
      return;
    }
    final sizes = {
      'u': const Size(980, 1500),
      'w': const Size(1280, 1500),
      'p': const Size(390, 1900),
    };
    for (final locale
        in (Platform.environment['OT_LOCALES'] ?? 'id').split(',')) {
      for (final e in sizes.entries) {
        for (final dark in [false, true]) {
          if (dark && e.key != 'u') continue;
          await _shot(
              tester,
              'sub_${tag}_${locale}_${e.key}${dark ? '_d' : ''}',
              const SubscriptionScreen(),
              size: e.value,
              locale: locale,
              dark: dark);
        }
      }
    }
  });
}
