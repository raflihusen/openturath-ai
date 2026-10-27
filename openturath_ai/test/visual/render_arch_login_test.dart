// Tangkapan layar gema lengkung di login pada beberapa waktu.
// OT_SNAPSHOT_DIR=/tmp/shots flutter test test/visual/render_arch_login_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/arch_echo_canvas.dart';

final _dir = Platform.environment['OT_SNAPSHOT_DIR'];

void main() {
  if (_dir == null) {
    test('visual snapshots are opt-in (set OT_SNAPSHOT_DIR)', () {});
    return;
  }
  Directory(_dir!).createSync(recursive: true);

  Future<void> shot(WidgetTester tester, String name,
      {required double introMs,
      required double seconds,
      required Size size,
      bool compact = false}) async {
    final key = GlobalKey();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: ColoredBox(
          color: const Color(0xFF09090B),
          child: CustomPaint(
            size: size,
            painter: archEchoPainterAt(
                seconds: seconds, introMs: introMs, compact: compact),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  for (final (label, intro, secs) in [
    ('a_650ms', 650.0, 0.65),
    ('b_1300ms', 1300.0, 1.3),
    ('c_2000ms', 2000.0, 2.0),
    ('d_selesai', 3000.0, 9.0),
  ]) {
    testWidgets('ponsel $label', (tester) async {
      await shot(tester, 'ponsel_$label',
          introMs: intro,
          seconds: secs,
          size: const Size(360, 440),
          compact: true);
    });
  }
  testWidgets('desktop selesai', (tester) async {
    await shot(tester, 'desktop_selesai',
        introMs: 3000, seconds: 9, size: const Size(760, 760));
  });
}
