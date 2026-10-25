// Merender adegan Mengenal Fikih Tahawwulat pada beberapa waktu (25/50/75/100%)
// untuk ditinjau. Hanya berjalan bila OT_SNAPSHOT_DIR diset. OT_SCENES: id
// dipisah koma (mis. s1,s2); OT_DARK=1 untuk tema gelap; OT_LANG untuk bahasa.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/design/ot_colors.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/widgets/tahawwulat_scene.dart';
import 'package:openturath_ai/widgets/tahawwulat_scenes.dart';

final _dir = Platform.environment['OT_SNAPSHOT_DIR'];
final _key = GlobalKey();

void main() {
  testWidgets('render adegan', (tester) async {
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
    final dark = Platform.environment['OT_DARK'] == '1';
    final lang = Platform.environment['OT_LANG'] ?? 'id';
    AppConfig.localeNotifier.value = lang;
    final ids = (Platform.environment['OT_SCENES'] ?? 's1').split(',');
    tester.view.physicalSize = const Size(1600, 480);
    tester.view.devicePixelRatio = 1;
    for (final id in ids) {
      final def = sceneFor(id);
      if (def == null) continue;
      final ops = def.ops();
      final fg = OTColors.textPrimary(dark), bg = OTColors.canvas(dark);
      await tester.pumpWidget(RepaintBoundary(
          key: _key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: Scaffold(
              backgroundColor: bg,
              body: Row(children: [
                for (final f in [0.25, 0.5, 0.75, 1.0])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CustomPaint(
                        painter: ScenePainter(
                            ops,
                            def.dur * f,
                            fg,
                            bg,
                            OTTypography.body(color: fg),
                            OTTypography.arabicDisplay(color: fg)),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
              ]),
            ),
          )));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: id);
      await tester.runAsync(() async {
        final b =
            _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await b.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_dir/$id.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }
    addTearDown(() {
      tester.view.reset();
      AppConfig.localeNotifier.value = 'id';
    });
  }, skip: _dir == null);
}
