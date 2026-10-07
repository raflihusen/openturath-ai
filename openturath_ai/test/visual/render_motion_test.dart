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
  final brand = FontLoader('NativeNewsreader')
    ..addFont(rootBundle.load('assets/native_fonts/NativeNewsreader.ttf'));
  await brand.load();
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
      for (final at in [370, 670, 1400]) {
        await tester.pump(Duration(milliseconds: at - elapsed));
        elapsed = at;
        await _save(tester, 'splash_${tag}_$at');
      }
      await tester.pumpWidget(frame(const AppLoader.fullscreen()));
      await tester.pump(const Duration(milliseconds: 500));
      await _save(tester, 'loader_$tag');
      for (var frame = 0; frame < 12; frame++) {
        if (frame > 0) await tester.pump(const Duration(milliseconds: 150));
        await _save(
            tester, 'loader_${tag}_frame_${frame.toString().padLeft(2, '0')}');
      }
    }
  }, skip: _dir == null);
}
