// Merender video pengumuman teks 9:16 (1080x1920) ke urutan PNG. Hanya berjalan
// bila OT_TEASER_DIR diset. OT_TEASER_FRAMES="a-b" merender sebagian bingkai
// (untuk tinjauan); OT_TEASER_FPS mengatur kecepatan (bawaan 30).
//   OT_TEASER_DIR=/tmp/teaser flutter test test/visual/render_teaser_test.dart
//   ffmpeg -framerate 30 -i /tmp/teaser/f_%04d.png -c:v libx264 -pix_fmt yuv420p out.mp4
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/widgets/ot_arch_motion.dart';

final _dir = Platform.environment['OT_TEASER_DIR'];
final _key = GlobalKey();

const _bg = Color(0xFF09090B);
const _ink = Color(0xFFFAFAFA);
const _serif = 'NativeNewsreader';
const _sans = 'NativeOutfit';

double _clamp(double v) => v.clamp(0.0, 1.0);
double _out(double v) => Curves.easeOutExpo.transform(_clamp(v));
double _inOut(double v) => Curves.easeInOutCubic.transform(_clamp(v));

class _Line {
  const _Line(this.text,
      {this.size = 112, this.bold = false, this.dim = false});
  final String text;
  final double size;
  final bool bold, dim;
}

/// Satu adegan = beberapa baris yang masuk dari bawah dengan kabur yang
/// menajam, lalu keluar ke atas dengan kabur yang menebal. Adegan berikutnya
/// mulai masuk saat adegan ini baru keluar, jadi tidak ada layar kosong.
class _Scene {
  const _Scene(this.start, this.exit, this.lines);
  final double start, exit;
  final List<_Line> lines;
}

const _scenes = [
  _Scene(0.3, 2.45, [
    _Line('Turath tidak', size: 150),
    _Line('pernah sulit.', size: 150, bold: true),
  ]),
  _Scene(2.95, 5.0, [
    _Line('Mencarinya', size: 150),
    _Line('yang sulit.', size: 150, bold: true),
  ]),
  _Scene(5.5, 8.4, [
    _Line('Itu berakhir', size: 130),
    _Line('26 Oktober.', size: 170, bold: true),
    _Line('Tanya. Temukan ibarahnya. Periksa kitabnya.', size: 56, dim: true),
  ]),
];

const _logoStart = 8.9; // animasi pembuka aplikasi, 2,7 dtk
const _dateStart = 11.3;
const _total = 15.2;

class _Teaser extends StatelessWidget {
  const _Teaser({required this.t});
  final double t;

  Widget _blur(double sigma, Widget child) => sigma < 0.3
      ? child
      : ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
              sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal),
          child: child);

  Widget _line(String text, _Line l, double enterAt, double exitAt) {
    final words = text.split(' ');
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < words.length; i++) ...[
            if (i > 0) SizedBox(width: l.size * 0.26),
            Builder(builder: (_) {
              final a = _out((t - enterAt - i * 0.09) / 1.0);
              final x = _inOut((t - exitAt - i * 0.04) / 0.55);
              final alpha = a * (1 - x) * (l.dim ? 0.55 : 1);
              final dy = (1 - a) * 46 - x * 38;
              final sigma = (1 - a) * 16 + x * 14;
              return Opacity(
                opacity: alpha,
                child: Transform.translate(
                  offset: Offset(0, dy),
                  child: _blur(
                    sigma,
                    Text(words[i],
                        style: TextStyle(
                            fontFamily: _serif,
                            fontSize: l.size,
                            height: 1.16,
                            letterSpacing: -l.size * 0.012,
                            fontWeight:
                                l.bold ? FontWeight.w700 : FontWeight.w400,
                            color: _ink)),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _sceneWidget(_Scene s) {
    if (t < s.start || t > s.exit + 0.9) return const SizedBox.shrink();
    var delay = s.start;
    final children = <Widget>[];
    for (final l in s.lines) {
      children.add(_line(l.text, l, delay, s.exit));
      delay += 0.42;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 90),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drift = t / _total;
    // Kamera mendorong pelan sepanjang video; cahaya bergeser mengikuti.
    final push = 1 + 0.05 * Curves.easeInOut.transform(drift);
    // Logo dan tanggal menjadi satu kunci: logo naik sedikit saat tanggal tiba.
    final dateA = _out((t - _dateStart) / 1.1);
    final lift = _inOut((t - _dateStart) / 1.1) * 360;
    final logoOn = t >= _logoStart;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: _bg,
        child: Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1.15 - drift * 0.7, -1.0 + drift * 0.5),
                  radius: 1.3,
                  colors: [
                    _ink.withValues(alpha: 0.13 + 0.05 * math.sin(t * 0.6)),
                    _ink.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Transform.scale(
              scale: push,
              child: Stack(children: [
                for (final s in _scenes) _sceneWidget(s),
                if (logoOn)
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(0, -lift),
                      child: Center(
                        child: Transform.scale(
                          scale: 1.7,
                          child: const OTSplashIntro(ink: _ink),
                        ),
                      ),
                    ),
                  ),
                if (t >= _dateStart)
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0, 0.62),
                      child: Opacity(
                        opacity: dateA,
                        child: Transform.translate(
                          offset: Offset(0, (1 - dateA) * 30),
                          child: _blur(
                            (1 - dateA) * 10,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 46, vertical: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: _ink.withValues(alpha: 0.55),
                                    width: 2),
                                color: _ink.withValues(alpha: 0.06),
                              ),
                              child: const Text('26.10.2026',
                                  style: TextStyle(
                                      fontFamily: _sans,
                                      fontSize: 70,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 8,
                                      color: _ink)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

void main() {
  testWidgets('render teaser', (tester) async {
    await tester.runAsync(() async {
      for (final f in {
        'NativeNewsreader': 'NativeNewsreader.ttf',
        'Newsreader': 'NativeNewsreader.ttf',
        'NativeOutfit': 'NativeOutfit.ttf',
        'Outfit': 'NativeOutfit.ttf',
        'NativeArabicUI': 'NativeArabic.ttf',
      }.entries) {
        final l = FontLoader(f.key)
          ..addFont(rootBundle.load('assets/native_fonts/${f.value}'));
        await l.load();
      }
    });
    AppConfig.localeNotifier.value = 'id';
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    final fps = int.parse(Platform.environment['OT_TEASER_FPS'] ?? '30');
    final all = (_total * fps).round();
    var from = 0, to = all;
    final sel = Platform.environment['OT_TEASER_FRAMES'];
    if (sel != null) {
      final p = sel.split('-').map(int.parse).toList();
      from = p[0];
      to = p[1];
    }
    final step = Duration(microseconds: (1e6 / fps).round());
    for (var f = 0; f < to; f++) {
      final t = f / fps;
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(size: Size(1080, 1920)),
          child: RepaintBoundary(key: _key, child: _Teaser(t: t))));
      await tester.pump(step);
      if (f < from) continue;
      await tester.runAsync(() async {
        final b =
            _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await b.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_dir/f_${f.toString().padLeft(4, '0')}.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }
    expect(tester.takeException(), isNull);
    addTearDown(() => tester.view.reset());
  }, skip: _dir == null, timeout: const Timeout(Duration(minutes: 30)));
}
