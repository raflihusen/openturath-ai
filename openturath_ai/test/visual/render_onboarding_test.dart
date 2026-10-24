// Merender pengenalan aplikasi ke PNG. Hanya berjalan bila OT_SNAPSHOT_DIR diset.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/onboarding_copy.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/screens/onboarding_screen.dart';

final _dir = Platform.environment['OT_SNAPSHOT_DIR'];
final _key = GlobalKey();

void main() {
  testWidgets('render pengenalan', (tester) async {
    await tester.runAsync(() async {
      for (final f in {
        'NativeArabic': 'NativeArabic.ttf',
        'NativeArabicUI': 'NativeArabic.ttf',
        'NativeNewsreader': 'NativeNewsreader.ttf',
        'NativeOutfit': 'NativeOutfit.ttf',
        'NativeInter': 'NativeInter.ttf',
      }.entries) {
        final l = FontLoader(f.key)
          ..addFont(rootBundle.load('assets/native_fonts/${f.value}'));
        await l.load();
      }
    });
    final lang = Platform.environment['OT_LANG'] ?? 'id';
    final dark = Platform.environment['OT_DARK'] == '1';
    AppConfig.localeNotifier.value = lang;
    for (final wide in [false, true]) {
      tester.view.physicalSize =
          wide ? const Size(1280, 800) : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(RepaintBoundary(
          key: _key,
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: const OnboardingScreen(replay: true))));
      for (var page = 0; page < 4; page++) {
        for (var k = 0; k < 65; k++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.runAsync(() async {
          final b =
              _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await b.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
              '$_dir/ob${page + 1}_${lang}_${dark ? 'd' : 'l'}_${wide ? 'w' : 'p'}.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes!.buffer.asUint8List());
        });
        expect(tester.takeException(), isNull);
        if (page < 3) {
          await tester.tap(find.text(OnboardingCopy.next));
          await tester.pump(const Duration(milliseconds: 700));
        }
      }
      await tester.pumpWidget(const SizedBox());
    }
    addTearDown(() {
      tester.view.reset();
      AppConfig.localeNotifier.value = 'id';
    });
  }, skip: _dir == null);
}
