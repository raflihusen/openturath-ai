// Merender bingkai kunci gerak pembuka dan loader ke PNG, untuk dicocokkan
// dengan rancangan Remotion di `motion/`. Hanya berjalan bila
// OT_SNAPSHOT_DIR diset.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/design/ot_colors.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/widgets/app_loader.dart';
import 'package:openturath_ai/widgets/ot_arch_motion.dart';

final _dir = Platform.environment['OT_SNAPSHOT_DIR'];
final _key = GlobalKey();

Future<void> _fonts() async {
  for (final f in {
    'NativeNewsreader': 'NativeNewsreader.ttf',
    'Newsreader': 'NativeNewsreader.ttf',
    'Outfit': 'NativeOutfit.ttf',
    'NativeOutfit': 'NativeOutfit.ttf',
    'NativeArabicUI': 'NativeArabic.ttf',
  }.entries) {
    final loader = FontLoader(f.key)
      ..addFont(rootBundle.load('assets/native_fonts/${f.value}'));
    await loader.load();
  }
}

Future<void> _save(WidgetTester tester, String name) async {
  expect(tester.takeException(), isNull,
      reason: 'Motion $name must render without errors');
  await tester.runAsync(() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_dir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render motion', (tester) async {
    await tester.runAsync(_fonts);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    final only = Platform.environment['OT_SPLASH_SIZES'];
    if (only != null) {
      for (final spec in only.split(',')) {
        final wh = spec.split('x').map(double.parse).toList();
        tester.view.physicalSize = Size(wh[0], wh[1]);
        for (final dark in [false, true]) {
          final tag = dark ? 'dark' : 'light';
          await tester.pumpWidget(RepaintBoundary(
            key: _key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: Scaffold(
                backgroundColor: OTColors.canvas(dark),
                body: Center(
                    child: OTSplashIntro(
                        key: ValueKey('$spec$tag'),
                        ink: OTColors.textPrimary(dark))),
              ),
            ),
          ));
          var elapsed = 0;
          for (final at in [300, 700, 1000, 1300, 1700, 2700]) {
            await tester.pump(Duration(milliseconds: at - elapsed));
            elapsed = at;
            await _save(tester, 'sp_${spec}_${tag}_$at');
          }
        }
      }
      return;
    }
    for (final dark in [false, true]) {
      final tag = dark ? 'dark' : 'light';
      Widget frame(Widget child) => RepaintBoundary(
            key: _key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: Scaffold(
                backgroundColor: OTColors.canvas(dark),
                body: Center(child: child),
              ),
            ),
          );
      await tester.pumpWidget(frame(
          OTSplashIntro(key: ValueKey(tag), ink: OTColors.textPrimary(dark))));
      var elapsed = 0;
      for (final at in [300, 700, 1000, 1300, 1600, 2300]) {
        await tester.pump(Duration(milliseconds: at - elapsed));
        elapsed = at;
        await _save(tester, 'splash_${tag}_$at');
      }
      await tester.pumpWidget(frame(const AppLoader.fullscreen()));
      await tester.pump(const Duration(milliseconds: 500));
      await _save(tester, 'loader_$tag');
      for (var frame = 0; frame < 60; frame++) {
        if (frame > 0) await tester.pump(const Duration(milliseconds: 30));
        await _save(
            tester, 'loader_${tag}_frame_${frame.toString().padLeft(2, '0')}');
      }
    }
  }, skip: _dir == null);
}
