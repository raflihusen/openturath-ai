import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';

/// Jenis gambar panggung pada slide: semuanya garis monokrom yang digambar
/// perlahan, lalu bergerak sangat pelan.
enum SlideArtKind { none, rings, arch, pillars, radial }

SlideArtKind slideArtOf(String? key) => switch (key) {
      'rings' => SlideArtKind.rings,
      'arch' => SlideArtKind.arch,
      'pillars' => SlideArtKind.pillars,
      'radial' => SlideArtKind.radial,
      _ => SlideArtKind.none,
    };

/// Panggung gambar di samping teks slide. `hl` menandai bagian yang menyala
/// (tiang atau cabang), `labels` menamai bagian itu, `count` jumlah simpul.
class SlideStage extends StatefulWidget {
  const SlideStage({
    super.key,
    required this.kind,
    required this.dark,
    this.hl = -1,
    this.labels = const [],
    this.count = 5,
  });

  final SlideArtKind kind;
  final bool dark;
  final int hl;
  final List<String> labels;
  final int count;

  @override
  State<SlideStage> createState() => _SlideStageState();
}

class _SlideStageState extends State<SlideStage> with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1900));
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 18));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _in.value = 1;
    } else {
      _in.forward();
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _in.dispose();
    _loop.dispose();
    super.dispose();
  }

  int get _n => widget.kind == SlideArtKind.pillars
      ? (widget.labels.isEmpty ? 4 : widget.labels.length)
      : (widget.labels.isEmpty ? widget.count : widget.labels.length);

  @override
  Widget build(BuildContext context) {
    if (widget.kind == SlideArtKind.none) return const SizedBox.shrink();
    final ink = OTColors.textPrimary(widget.dark);
    final canvas = OTColors.canvas(widget.dark);
    final muted = OTColors.textSecondary(widget.dark);
    return LayoutBuilder(builder: (context, box) {
      final side = math.min(
          box.maxWidth, box.maxHeight.isFinite ? box.maxHeight : box.maxWidth);
      final size = Size.square(side);
      final eased = CurvedAnimation(parent: _in, curve: Curves.easeInOutCubic);
      final labelFade = CurvedAnimation(
          parent: _in, curve: const Interval(0.45, 1, curve: Curves.easeOut));
      return Center(
        child: SizedBox.square(
          dimension: side,
          child: Stack(children: [
            RepaintBoundary(
              child: CustomPaint(
                size: size,
                painter: _StagePainter(
                  kind: widget.kind,
                  intro: eased,
                  loop: _loop,
                  ink: ink,
                  canvas: canvas,
                  hl: widget.hl,
                  n: _n,
                  numbered: widget.labels.isEmpty,
                ),
              ),
            ),
            ..._overlays(size, labelFade, ink, canvas, muted),
          ]),
        ),
      );
    });
  }

  List<Widget> _overlays(
      Size s, Animation<double> fade, Color ink, Color canvas, Color muted) {
    final out = <Widget>[];
    switch (widget.kind) {
      case SlideArtKind.pillars:
        final geo = _pillarGeometry(s, _n);
        for (var i = 0; i < _n; i++) {
          final label = i < widget.labels.length ? widget.labels[i] : '';
          if (label.isEmpty) continue;
          final lit = i == widget.hl;
          out.add(Positioned(
            left: geo.centers[i] - geo.width,
            width: geo.width * 2,
            top: geo.baseline + OTSpacing.sm,
            child: FadeTransition(
              opacity: fade,
              child: Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: lit
                      ? OTTypography.captionMedium(color: ink)
                      : OTTypography.caption(color: muted)),
            ),
          ));
        }
      case SlideArtKind.radial:
        final pts = _radialNodes(s, _n);
        final nr = _nodeRadius(s);
        for (var i = 0; i < _n; i++) {
          final lit = i == widget.hl;
          if (widget.labels.isEmpty) {
            out.add(Positioned(
              left: pts[i].dx - nr,
              top: pts[i].dy - nr,
              width: nr * 2,
              height: nr * 2,
              child: FadeTransition(
                opacity: fade,
                child: Center(
                  child: Text('${i + 1}',
                      style: OTTypography.cardTitle(color: lit ? canvas : ink)),
                ),
              ),
            ));
          } else {
            out.add(Positioned(
              left: pts[i].dx - nr * 2.2,
              width: nr * 4.4,
              top: pts[i].dy + nr + OTSpacing.xs,
              child: FadeTransition(
                opacity: fade,
                child: Text(widget.labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: lit
                        ? OTTypography.arabicReading(color: ink)
                        : OTTypography.arabicReading(color: muted)),
              ),
            ));
          }
        }
      case SlideArtKind.rings:
      case SlideArtKind.arch:
      case SlideArtKind.none:
        break;
    }
    return out;
  }
}

class _PillarGeometry {
  const _PillarGeometry(this.centers, this.width, this.baseline, this.heights);
  final List<double> centers;
  final double width, baseline;
  final List<double> heights;
}

_PillarGeometry _pillarGeometry(Size s, int n) {
  final width = s.width * (n <= 4 ? 0.1 : 0.08);
  final span = s.width * 0.8;
  final step = n == 1 ? 0.0 : span / (n - 1);
  final start = s.width * 0.1;
  return _PillarGeometry(
    [for (var i = 0; i < n; i++) start + step * i],
    width,
    s.height * 0.8,
    [for (var i = 0; i < n; i++) s.height * (0.3 + 0.1 * i)],
  );
}

double _nodeRadius(Size s) => s.width * 0.075;

List<Offset> _radialNodes(Size s, int n) {
  final c = s.center(Offset.zero);
  final r = s.width * 0.34;
  return [
    for (var i = 0; i < n; i++)
      c +
          Offset(math.cos(-math.pi / 2 + 2 * math.pi * i / n) * r,
              math.sin(-math.pi / 2 + 2 * math.pi * i / n) * r)
  ];
}

class _StagePainter extends CustomPainter {
  _StagePainter({
    required this.kind,
    required this.intro,
    required this.loop,
    required this.ink,
    required this.canvas,
    required this.hl,
    required this.n,
    required this.numbered,
  }) : super(repaint: Listenable.merge([intro, loop]));

  final SlideArtKind kind;
  final Animation<double> intro, loop;
  final Color ink, canvas;
  final int hl, n;
  final bool numbered;

  double _p(double a, double b) =>
      ((intro.value - a) / (b - a)).clamp(0.0, 1.0);

  Paint _line(double alpha, [double w = 1.4]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..color = ink.withValues(alpha: alpha);

  Paint _fill(double alpha) => Paint()
    ..style = PaintingStyle.fill
    ..color = ink.withValues(alpha: alpha);

  void _drawPartial(Canvas c, Path path, double t, Paint paint) {
    if (t <= 0) return;
    for (final PathMetric m in path.computeMetrics()) {
      c.drawPath(m.extractPath(0, m.length * t), paint);
    }
  }

  @override
  void paint(Canvas c, Size s) {
    switch (kind) {
      case SlideArtKind.rings:
        _rings(c, s);
      case SlideArtKind.arch:
        _arch(c, s);
      case SlideArtKind.pillars:
        _pillars(c, s);
      case SlideArtKind.radial:
        _radial(c, s);
      case SlideArtKind.none:
        break;
    }
  }

  void _rings(Canvas c, Size s) {
    final ctr = s.center(Offset.zero);
    final maxR = s.width / 2 * 0.92;
    for (var i = 0; i < 4; i++) {
      final r = maxR * (0.3 + 0.23 * i);
      final t = _p(i * 0.12, 0.6 + i * 0.12);
      c.drawArc(Rect.fromCircle(center: ctr, radius: r), -math.pi / 2,
          2 * math.pi * t, false, _line(0.5 - i * 0.07));
      if (t < 1) continue;
      final dir = i.isEven ? 1.0 : -1.0;
      final a = -math.pi / 2 +
          dir * loop.value * 2 * math.pi * (1 - i * 0.18) +
          i * 1.3;
      final pos = ctr + Offset(math.cos(a) * r, math.sin(a) * r);
      c.drawCircle(pos, 3.5, _fill(0.85));
      c.drawCircle(pos, 9, _fill(0.08));
    }
    final pulse = 1 + 0.12 * math.sin(loop.value * 2 * math.pi * 3);
    c.drawCircle(ctr, maxR * 0.07 * pulse * _p(0.5, 1), _fill(0.95));
    c.drawCircle(ctr, maxR * 0.14 * pulse * _p(0.5, 1), _line(0.35));
  }

  Path _archPath(
      Offset bottomCenter, double halfW, double springH, double apexH) {
    final p = Path()
      ..moveTo(bottomCenter.dx - halfW, bottomCenter.dy)
      ..lineTo(bottomCenter.dx - halfW, bottomCenter.dy - springH)
      ..cubicTo(
          bottomCenter.dx - halfW,
          bottomCenter.dy - springH - apexH * 0.55,
          bottomCenter.dx - halfW * 0.35,
          bottomCenter.dy - springH - apexH * 0.86,
          bottomCenter.dx,
          bottomCenter.dy - springH - apexH)
      ..cubicTo(
          bottomCenter.dx + halfW * 0.35,
          bottomCenter.dy - springH - apexH * 0.86,
          bottomCenter.dx + halfW,
          bottomCenter.dy - springH - apexH * 0.55,
          bottomCenter.dx + halfW,
          bottomCenter.dy - springH)
      ..lineTo(bottomCenter.dx + halfW, bottomCenter.dy);
    return p;
  }

  void _arch(Canvas c, Size s) {
    final base = Offset(s.width / 2, s.height * 0.86);
    final baseT = _p(0, 0.3);
    c.drawLine(Offset(s.width * 0.1, base.dy),
        Offset(s.width * 0.1 + s.width * 0.8 * baseT, base.dy), _line(0.4));
    for (var i = 3; i >= 0; i--) {
      final level = 3 - i;
      final t = _p(0.1 + level * 0.14, 0.7 + level * 0.1);
      final halfW = s.width * (0.1 + 0.085 * i);
      final spring = s.height * (0.18 + 0.05 * i);
      final apex = s.height * (0.2 + 0.075 * i);
      _drawPartial(c, _archPath(base, halfW, spring, apex), t,
          _line(0.85 - i * 0.17, i == 0 ? 2 : 1.4));
    }
    final glow = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 2);
    final apexY = base.dy - s.height * (0.18 + 0.2);
    final dotT = _p(0.7, 1);
    c.drawCircle(
        Offset(base.dx, apexY - s.height * 0.045), 4 * dotT, _fill(0.95));
    c.drawCircle(Offset(base.dx, apexY - s.height * 0.045),
        (10 + 8 * glow) * dotT, _fill(0.07 + 0.05 * glow));
  }

  void _pillars(Canvas c, Size s) {
    final g = _pillarGeometry(s, n);
    c.drawLine(
        Offset(s.width * 0.05, g.baseline),
        Offset(s.width * 0.05 + s.width * 0.9 * _p(0, 0.3), g.baseline),
        _line(0.4));
    for (var i = 0; i < n; i++) {
      final t =
          Curves.easeOutCubic.transform(_p(0.1 + i * 0.1, 0.65 + i * 0.1));
      final h = g.heights[i] * t;
      final rect =
          Rect.fromLTWH(g.centers[i] - g.width / 2, g.baseline - h, g.width, h);
      final rr = RRect.fromRectAndCorners(rect,
          topLeft: const Radius.circular(OTRadius.xs),
          topRight: const Radius.circular(OTRadius.xs));
      final lit = i == hl;
      if (lit) {
        final pulse = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 2);
        c.drawRRect(rr.inflate(6 + 6 * pulse), _fill(0.05 + 0.05 * pulse));
        c.drawRRect(rr, _fill(0.92));
      } else {
        c.drawRRect(rr, _fill(0.05));
        c.drawRRect(rr, _line(0.4));
      }
    }
  }

  void _radial(Canvas c, Size s) {
    final ctr = s.center(Offset.zero);
    final pts = _radialNodes(s, n);
    final nr = _nodeRadius(s);
    final poly = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i < n; i++) {
      poly.lineTo(pts[i].dx, pts[i].dy);
    }
    poly.close();
    _drawPartial(c, poly, _p(0.15, 0.8), _line(0.28));
    for (var i = 0; i < n; i++) {
      final t = _p(0.05 + i * 0.07, 0.55 + i * 0.07);
      final dir = pts[i] - ctr;
      c.drawLine(ctr, ctr + dir * t, _line(i == hl ? 0.7 : 0.25));
    }
    final ringT = _p(0.2, 0.8);
    c.drawCircle(ctr, s.width * 0.07 * ringT, _line(0.55));
    c.drawCircle(ctr, s.width * 0.028 * ringT, _fill(hl < 0 ? 0.95 : 0.6));
    if (hl < 0) {
      final pulse = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 2);
      c.drawCircle(ctr, s.width * (0.1 + 0.03 * pulse) * ringT,
          _line(0.18 + 0.12 * pulse));
    }
    for (var i = 0; i < n; i++) {
      final t = Curves.easeOutBack.transform(_p(0.35 + i * 0.07, 0.85));
      final lit = i == hl;
      final r = nr * (lit ? 1.18 : 1) * t;
      if (lit) {
        final pulse = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 2);
        c.drawCircle(pts[i], r + 8 + 8 * pulse, _fill(0.05 + 0.05 * pulse));
        c.drawCircle(pts[i], r, _fill(0.95));
      } else {
        c.drawCircle(pts[i], r, Paint()..color = canvas);
        c.drawCircle(pts[i], r, _line(0.5));
      }
    }
    // Satu titik kecil mengitari cabang keempat: Imam Mahdi dan Dajjal
    // hanyalah sebagian kecil dari satu cabang.
    if (numbered && n == 5 && hl == 3) {
      final a = loop.value * 2 * math.pi * 3;
      final d = nr * 1.9;
      c.drawCircle(
          pts[3] + Offset(math.cos(a) * d, math.sin(a) * d), 3, _fill(0.85));
    }
  }

  @override
  bool shouldRepaint(covariant _StagePainter old) =>
      old.kind != kind ||
      old.ink != ink ||
      old.hl != hl ||
      old.n != n ||
      old.numbered != numbered;
}
