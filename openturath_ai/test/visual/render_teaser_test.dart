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
double _ease(double v) => Curves.easeOutCubic.transform(_clamp(v));

class _Line {
  const _Line(this.text,
      {this.size = 112, this.bold = false, this.dim = false});
  final String text;
  final double size;
  final bool bold, dim;
}

class _Scene {
  const _Scene(this.start, this.end, this.lines);
  final double start, end;
  final List<_Line> lines;
}

const _scenes = [
  _Scene(0.4, 3.6,
      [_Line('Turath itu'), _Line('samudra.', size: 190, bold: true)]),
  _Scene(3.8, 8.0, [
    _Line('Satu ibarah'),
    _Line('tersembunyi di antara', dim: true),
    _Line('ribuan halaman.', bold: true),
  ]),
  _Scene(8.2, 11.6, [
    _Line('Berjam-jam'),
    _Line('membuka kitab'),
    _Line('satu per satu.', dim: true),
  ]),
  _Scene(11.8, 14.6, [
    _Line('Sebentar lagi,'),
    _Line('ada yang berbeda.', size: 130, bold: true),
  ]),
  _Scene(14.8, 19.0, [
    _Line('Cara kita'),
    _Line('mengkaji turath', bold: true),
    _Line('dan menemukan ibarah', dim: true),
    _Line('tidak akan sama lagi.'),
  ]),
  _Scene(19.2, 22.4, [
    _Line('Berpijak pada kitab.'),
    _Line('Dengan teks aslinya.', bold: true),
  ]),
];

const _splashStart = 22.6, _splashEnd = 27.0;
const _finalStart = 27.2, _dateStart = 29.4, _total = 33.0;

class _Teaser extends StatelessWidget {
  const _Teaser({required this.t});
  final double t;

  Widget _words(String text, double t0, _Line l, double sceneAlpha) {
    final words = text.split(' ');
    // Satu baris utuh yang menyusut bila terlalu lebar, supaya tidak pecah baris.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < words.length; i++) ...[
            if (i > 0) SizedBox(width: l.size * 0.26),
            Builder(builder: (_) {
              final a = _ease((t - t0 - i * 0.14) / 0.7);
              return Opacity(
                opacity: a * sceneAlpha * (l.dim ? 0.55 : 1),
                child: Transform.translate(
                  offset: Offset(0, (1 - a) * 34),
                  child: Text(words[i],
                      style: TextStyle(
                          fontFamily: _serif,
                          fontSize: l.size,
                          height: 1.16,
                          letterSpacing: -l.size * 0.012,
                          fontWeight:
                              l.bold ? FontWeight.w700 : FontWeight.w400,
                          color: _ink)),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _sceneWidget(_Scene s) {
    final fadeOut = 1 - _ease((t - (s.end - 0.55)) / 0.55);
    if (t < s.start || t > s.end) return const SizedBox.shrink();
    var delay = s.start;
    final children = <Widget>[];
    for (final l in s.lines) {
      children.add(_words(l.text, delay, l, fadeOut));
      delay += 0.5;
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
    // Cahaya lembut dari kanan atas, bergeser pelan sepanjang video.
    final drift = t / _total;
    final splashFade = 1 - _ease((t - (_splashEnd - 0.5)) / 0.5);
    final dateA = _ease((t - _dateStart) / 0.9);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: _bg,
        child: Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1.1 - drift * 0.5, -0.95 + drift * 0.3),
                  radius: 1.25,
                  colors: [
                    _ink.withValues(alpha: 0.12 + 0.05 * math.sin(t * 0.7)),
                    _ink.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          for (final s in _scenes) _sceneWidget(s),
          if (t >= _splashStart && t < _splashEnd)
            Positioned.fill(
              child: Opacity(
                opacity: splashFade,
                child: Center(
                  child: Transform.scale(
                    scale: 1.55,
                    child: const OTSplashIntro(ink: _ink),
                  ),
                ),
              ),
            ),
          if (t >= _finalStart) ...[
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 5),
                    _words('Sesuatu yang lebih besar', _finalStart,
                        const _Line('', size: 96), 1),
                    const SizedBox(height: 8),
                    _words('akan hadir.', _finalStart + 0.6,
                        const _Line('', size: 130, bold: true), 1),
                    const Spacer(flex: 3),
                    Opacity(
                      opacity: dateA,
                      child: Column(children: [
                        Container(
                            width: 180 * dateA,
                            height: 2,
                            color: _ink.withValues(alpha: 0.5)),
                        const SizedBox(height: 40),
                        const Text('26.10.2026',
                            style: TextStyle(
                                fontFamily: _sans,
                                fontSize: 120,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 16,
                                color: _ink)),
                        const SizedBox(height: 40),
                        Container(
                            width: 180 * dateA,
                            height: 2,
                            color: _ink.withValues(alpha: 0.5)),
                      ]),
                    ),
                    const Spacer(flex: 4),
                  ],
                ),
              ),
            ),
          ],
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
