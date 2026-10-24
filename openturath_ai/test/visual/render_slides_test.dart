// Merender slide Mengenal Fikih Tahawwulat ke PNG untuk ditinjau. Hanya
// berjalan bila OT_SNAPSHOT_DIR diset. OT_SLIDES: daftar indeks dipisah koma.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/widgets/tahawwulat_slides_screen.dart';

final _dir = Platform.environment['OT_SNAPSHOT_DIR'];
final _key = GlobalKey();

void main() {
  testWidgets('render slide', (tester) async {
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
    final idx = (Platform.environment['OT_SLIDES'] ?? '0')
        .split(',')
        .map(int.parse)
        .toList();
    final lang = Platform.environment['OT_LANG'] ?? 'id';
    AppConfig.localeNotifier.value = lang;
    for (final wide in [true, false]) {
      final size = wide ? const Size(1280, 800) : const Size(390, 844);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      for (final i in idx) {
        await tester.pumpWidget(RepaintBoundary(
            key: _key,
            child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                home: TahawwulatSlidesScreen(initialPage: i))));
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 400)));
        for (var k = 0; k < 40; k++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull, reason: 'slide $i');
        await tester.runAsync(() async {
          final b =
              _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await b.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('$_dir/s${i}_${lang}_${wide ? 'w' : 'p'}.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes!.buffer.asUint8List());
        });
        await tester.pumpWidget(const SizedBox());
      }
    }
    addTearDown(() {
      tester.view.reset();
      AppConfig.localeNotifier.value = 'id';
    });
  }, skip: _dir == null);
}
