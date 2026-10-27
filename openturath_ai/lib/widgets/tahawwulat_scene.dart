import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';

/// Mesin adegan slide Mengenal Fikih Tahawwulat. Satu adegan = daftar [Op]
/// pada kanvas maya 100 x 56; tiap Op punya waktu mulai/lamanya sendiri (detik),
/// jadi adegan diputar sekali mengikuti naskah lalu diam. Sengaja hanya
/// abstraksi geometris, tanpa makhluk bernyawa.
const double kSceneW = 100, kSceneH = 56;

enum Sk {
  disc,
  ring,
  line,
  rect,
  arc,
  poly,
  text,
  glow,
  lock,
  cross,
  tick,
  eye,
  wave,
  spark,
  brace,
  gate,
  seg,
  stack,
  cal,
  sign,
  gear,
  scale,
  bars,
}

class Op {
  const Op(
    this.k,
    this.x,
    this.y, {
    this.w = 0,
    this.h = 0,
    this.r = 0,
    this.r2 = -1,
    this.x2 = 0,
    this.y2 = 0,
    this.t = 0,
    this.d = 0.4,
    this.tone = 1,
    this.fill = false,
    this.draw = false,
    this.dash = false,
    this.up = false,
    this.dx = 0,
    this.dy = 0,
    this.mx = 0,
    this.my = 0,
    this.mt = 0,
    this.md = 0.6,
    this.out = -1,
    this.od = 0.3,
    this.shake = 0,
    this.st = 0,
    this.sd = 0.6,
    this.text = '',
    this.a0 = 0,
    this.a1 = math.pi * 2,
    this.n = 5,
    this.idx = 0,
    this.sharp = false,
    this.size = 3.4,
    this.pulse = 0,
  });

  final Sk k;
  final double x, y, w, h, r, r2, x2, y2;
  final double t, d, tone;
  final bool fill, draw, dash, up, sharp;
  final double dx, dy, mx, my, mt, md, out, od, shake, st, sd;
  final String text;
  final double a0, a1;
  final int n, idx;
  final double size;

  /// Denyut sekali (ukuran naik lalu kembali) sepanjang [mt, mt+md].
  final double pulse;
}

class SceneDef {
  const SceneDef(this.dur, this.ops, {this.alt});
  final double dur;
  final List<Op> Function() ops;
  final String? alt;
}

double _ease(double t, double s, double d, [Curve c = Curves.easeOutCubic]) {
  if (d <= 0) return t >= s ? 1 : 0;
  return c.transform(((t - s) / d).clamp(0.0, 1.0));
}

final _arabic = RegExp(r'[؀-ۿ]');

class ScenePainter extends CustomPainter {
  ScenePainter(this.ops, this.time, this.fg, this.bg, this.latin, this.arabic)
      : super();
  final List<Op> ops;
  final double time;
  final Color fg, bg;
  final TextStyle latin, arabic;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / kSceneW, size.height / kSceneH);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(
        (size.width - kSceneW * s) / 2, (size.height - kSceneH * s) / 2);
    canvas.scale(s);
    final unit = math.max(0.38, 1.3 / s);
    for (final o in ops) {
      _op(canvas, o, unit, s);
    }
    canvas.restore();
  }

  void _op(Canvas c, Op o, double unit, double s) {
    final ap = _ease(time, o.t, o.d);
    if (ap <= 0) return;
    final mp = _ease(time, o.mt, o.md, Curves.easeInOutCubic);
    final fo = o.out >= 0 ? _ease(time, o.out, o.od) : 0.0;
    final alpha = (ap * (1 - fo) * o.tone).clamp(0.0, 1.0);
    if (alpha <= 0.003) return;

    var px = o.x + o.dx * (1 - ap) + o.mx * mp;
    var py = o.y + o.dy * (1 - ap) + o.my * mp;
    if (o.shake > 0) {
      final e = ((time - o.st) / o.sd).clamp(0.0, 1.0);
      final env = math.sin(math.pi * e);
      px += math.sin(time * 47 + o.idx * 1.7) * o.shake * env;
      py += math.cos(time * 53 + o.idx * 2.3) * o.shake * env;
    }
    var r = o.r2 >= 0 ? o.r + (o.r2 - o.r) * mp : o.r;
    if (o.pulse > 0) {
      final e = ((time - o.mt) / o.md).clamp(0.0, 1.0);
      r *= 1 + o.pulse * math.sin(math.pi * e);
    }
    final col = fg.withValues(alpha: alpha);
    final stroke = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * 1.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillP = Paint()..color = col;
    final grow = 0.92 + 0.08 * ap;

    void strokePath(Path p) {
      var path = p;
      if (o.dash) path = _dashed(path, unit * 2.2, unit * 1.8);
      if (o.draw && ap < 1) path = _partial(path, ap);
      c.drawPath(path, stroke);
    }

    switch (o.k) {
      case Sk.disc:
        c.drawCircle(Offset(px, py), r * grow, fillP);
      case Sk.ring:
        final p = Path()
          ..addOval(Rect.fromCircle(center: Offset(px, py), radius: r));
        if (o.fill) {
          c.drawCircle(Offset(px, py), r,
              fillP..color = col.withValues(alpha: alpha * 0.18));
        }
        strokePath(p);
      case Sk.line:
        final p = Path()
          ..moveTo(px, py)
          ..lineTo(o.x2 + o.dx * (1 - ap) + o.mx * mp,
              o.y2 + o.dy * (1 - ap) + o.my * mp);
        strokePath(p);
      case Sk.rect:
        var w = o.w, h = o.h;
        var cy = py;
        if (o.up) {
          final hh = h * ap;
          cy = py + (h - hh) / 2;
          h = hh;
        }
        final rr = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(px, cy), width: w, height: h),
            Radius.circular(math.min(o.r, math.min(w, h) / 2)));
        if (o.fill) {
          c.drawRRect(rr, fillP);
        } else {
          strokePath(Path()..addRRect(rr));
        }
      case Sk.arc:
        final p = Path()
          ..addArc(Rect.fromCircle(center: Offset(px, py), radius: r), o.a0,
              o.a1 - o.a0);
        strokePath(p);
      case Sk.poly:
        final p = _poly(Offset(px, py), r, o.n, o.a0);
        if (o.fill) {
          c.drawPath(p, fillP);
        } else {
          strokePath(p);
        }
      case Sk.text:
        _text(c, o.text, Offset(px, py), o.size, col, unit * 0 + s);
      case Sk.glow:
        final rr = r * (0.7 + 0.3 * ap);
        final sh = RadialGradient(colors: [
          fg.withValues(alpha: alpha * 0.34),
          fg.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: Offset(px, py), radius: rr));
        c.drawCircle(Offset(px, py), rr, Paint()..shader = sh);
      case Sk.lock:
        final lift = o.up ? (1 - mp) * o.h * 0.42 : 0.0;
        final body = RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(px, py + o.h * 0.16),
                width: o.w,
                height: o.h * 0.62),
            Radius.circular(o.w * 0.12));
        c.drawRRect(body, fillP);
        final sw = o.w * 0.66;
        final top = py + o.h * 0.16 - o.h * 0.31;
        final sp = Path()
          ..moveTo(px - sw / 2, top - lift * 0.0)
          ..lineTo(px - sw / 2, top - o.h * 0.12 - lift)
          ..arcToPoint(Offset(px + sw / 2, top - o.h * 0.12 - lift),
              radius: Radius.circular(sw / 2), clockwise: true)
          ..lineTo(px + sw / 2, top - (o.up ? lift : 0));
        c.drawPath(sp, stroke..strokeWidth = unit * 1.9);
        c.drawCircle(Offset(px, py + o.h * 0.16), o.w * 0.07,
            Paint()..color = bg.withValues(alpha: alpha));
      case Sk.cross:
        final a = r;
        final p = Path()
          ..moveTo(px - a, py - a)
          ..lineTo(px + a, py + a)
          ..moveTo(px + a, py - a)
          ..lineTo(px - a, py + a);
        strokePath(p);
      case Sk.tick:
        final p = Path()
          ..moveTo(px - r, py + r * 0.1)
          ..lineTo(px - r * 0.3, py + r * 0.75)
          ..lineTo(px + r, py - r * 0.7);
        strokePath(p);
      case Sk.eye:
        final hw = o.w / 2;
        final p = Path()
          ..moveTo(px - hw, py)
          ..quadraticBezierTo(px, py - o.h, px + hw, py)
          ..quadraticBezierTo(px, py + o.h, px - hw, py);
        strokePath(p);
        if (ap > 0.5) {
          c.drawCircle(Offset(px, py), r, fillP);
        }
      case Sk.wave:
        final p = Path();
        const steps = 80;
        for (var i = 0; i <= steps; i++) {
          final u = i / steps;
          final xx = o.x + (o.x2 - o.x) * u + o.mx * mp * 0;
          final ph = u * o.n * 2 * math.pi;
          final v =
              o.sharp ? (2 / math.pi) * math.asin(math.sin(ph)) : math.sin(ph);
          final yy = py + v * o.h;
          i == 0 ? p.moveTo(xx, yy) : p.lineTo(xx, yy);
        }
        strokePath(p);
      case Sk.spark:
        final p = Path();
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4 - math.pi / 2;
          final rr = i.isEven ? r : r * 0.28;
          final pt = Offset(px + math.cos(a) * rr, py + math.sin(a) * rr);
          i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
        }
        p.close();
        c.drawPath(p, fillP);
      case Sk.brace:
        final hh = o.h / 2, dpt = o.w;
        c.save();
        c.translate(px, py);
        c.rotate(o.a0);
        c.translate(-px, -py);
        final p = Path()
          ..moveTo(px, py - hh)
          ..quadraticBezierTo(
              px + dpt * 0.1, py - hh, px + dpt * 0.1, py - hh * 0.8)
          ..lineTo(px + dpt * 0.1, py - hh * 0.12)
          ..quadraticBezierTo(px + dpt * 0.1, py, px + dpt, py)
          ..quadraticBezierTo(
              px + dpt * 0.1, py, px + dpt * 0.1, py + hh * 0.12)
          ..lineTo(px + dpt * 0.1, py + hh * 0.8)
          ..quadraticBezierTo(px + dpt * 0.1, py + hh, px, py + hh);
        strokePath(p);
        c.restore();
      case Sk.gate:
        final w = o.w, h = o.h;
        final frame = Path()
          ..moveTo(px - w / 2, py + h / 2)
          ..lineTo(px - w / 2, py - h / 2 + w / 2)
          ..arcTo(Rect.fromLTWH(px - w / 2, py - h / 2, w, w), math.pi, math.pi,
              false)
          ..lineTo(px + w / 2, py + h / 2);
        strokePath(frame);
        final gap = (w / 2) * mp;
        if (mp < 1) {
          final lw = w / 2 - gap;
          for (final side in [-1, 1]) {
            final cx = px + side * (w / 4 + gap / 2 + (w / 4 - lw / 2) * 0);
            final rr = Rect.fromCenter(
                center: Offset(px + side * (w / 2 - lw / 2), py + w / 4),
                width: lw,
                height: h - w / 2);
            if (lw > 0.2) {
              c.drawRect(rr, fillP..color = col.withValues(alpha: alpha * 0.5));
            }
            // ignore: unused_local_variable
            final _ = cx;
          }
        }
      case Sk.seg:
        const gap = 0.05;
        final a0 = math.pi + o.idx * math.pi / 4 + gap;
        const sweep = math.pi / 4 - gap * 2;
        final ro = r, ri = r - o.w;
        final p = Path()
          ..arcTo(Rect.fromCircle(center: Offset(px, py), radius: ro), a0,
              sweep, true)
          ..arcTo(Rect.fromCircle(center: Offset(px, py), radius: ri),
              a0 + sweep, -sweep, false)
          ..close();
        if (o.fill) {
          c.drawPath(p, fillP);
        } else {
          strokePath(p);
        }
      case Sk.stack:
        for (var i = 0; i < 3; i++) {
          final rr = RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(px + (i == 1 ? o.w * 0.06 : 0),
                      py + (i - 1) * o.h * 1.15),
                  width: o.w * (i == 1 ? 0.9 : 1),
                  height: o.h),
              Radius.circular(o.h * 0.3));
          if (o.fill) {
            c.drawRRect(rr, fillP);
          } else {
            c.drawRRect(rr, stroke);
          }
        }
      case Sk.cal:
        final rr = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(px, py), width: o.w, height: o.h),
            Radius.circular(o.w * 0.1));
        c.drawRRect(rr, stroke);
        c.drawLine(Offset(px - o.w / 2, py - o.h * 0.22),
            Offset(px + o.w / 2, py - o.h * 0.22), stroke);
        for (var i = 0; i < 3; i++) {
          for (var j = 0; j < 2; j++) {
            c.drawCircle(
                Offset(px + (i - 1) * o.w * 0.26, py + o.h * (0.02 + j * 0.24)),
                unit * 0.7,
                fillP);
          }
        }
      case Sk.sign:
        c.drawLine(Offset(px, py + o.h / 2), Offset(px, py - o.h / 2), stroke);
        final dir = o.up ? -1.0 : 1.0;
        final p = Path()
          ..moveTo(px, py - o.h / 2)
          ..lineTo(px + dir * o.w * 0.78, py - o.h / 2)
          ..lineTo(px + dir * o.w, py - o.h / 2 + o.h * 0.18)
          ..lineTo(px + dir * o.w * 0.78, py - o.h / 2 + o.h * 0.36)
          ..lineTo(px, py - o.h / 2 + o.h * 0.36)
          ..close();
        if (o.fill) {
          c.drawPath(p, fillP);
        } else {
          c.drawPath(p, stroke);
        }
      case Sk.gear:
        final p = Path();
        final teeth = o.n;
        for (var i = 0; i < teeth * 2; i++) {
          final a = i * math.pi / teeth + mp * 1.2;
          final rr = i.isEven ? r : r * 0.78;
          final pt = Offset(px + math.cos(a) * rr, py + math.sin(a) * rr);
          i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
        }
        p.close();
        c.drawPath(p, stroke);
        c.drawCircle(Offset(px, py), r * 0.28, stroke);
      case Sk.scale:
        // Neraca: tiang, balok yang miring, dua piringan.
        final tilt = o.a0 + (o.a1 - o.a0) * mp;
        final half = o.w / 2;
        final lx = px - math.cos(tilt) * half, ly = py - math.sin(tilt) * half;
        final rx = px + math.cos(tilt) * half, ry = py + math.sin(tilt) * half;
        c.drawLine(Offset(px, py + o.h * 0.5), Offset(px, py), stroke);
        c.drawLine(Offset(px - o.w * 0.16, py + o.h * 0.5),
            Offset(px + o.w * 0.16, py + o.h * 0.5), stroke);
        c.drawLine(Offset(lx, ly), Offset(rx, ry), stroke);
        for (final e in [Offset(lx, ly), Offset(rx, ry)]) {
          final bot = e + Offset(0, o.h * 0.32);
          c.drawLine(e, bot - Offset(o.w * 0.14, 0), stroke);
          c.drawLine(e, bot + Offset(o.w * 0.14, 0), stroke);
          c.drawLine(bot - Offset(o.w * 0.17, 0), bot + Offset(o.w * 0.17, 0),
              stroke..strokeWidth = unit * 1.8);
          stroke.strokeWidth = unit * 1.15;
        }
      case Sk.bars:
        // Deretan batang audio/tinggi: o.n batang di lebar o.w.
        final gapW = o.w / o.n;
        for (var i = 0; i < o.n; i++) {
          final v = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(i * 1.9 + 0.6));
          final pulse = 1 + 0.3 * math.sin(math.pi * mp) * (i.isEven ? 1 : -1);
          final hh = o.h * v * pulse * ap;
          final rr = RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(px - o.w / 2 + gapW * (i + 0.5), py),
                  width: gapW * 0.5,
                  height: hh),
              Radius.circular(gapW * 0.25));
          c.drawRRect(rr, fillP);
        }
    }
  }

  void _text(
      Canvas c, String s, Offset p, double size, Color col, double scale) {
    final ar = _arabic.hasMatch(s);
    final base = ar ? arabic : latin;
    final px = math.max(size, 11 / scale);
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: base.copyWith(
              color: col,
              fontSize: px,
              height: 1.15,
              fontWeight: FontWeight.w600)),
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(c, p - Offset(tp.width / 2, tp.height / 2));
  }

  static Path _poly(Offset c, double r, int n, double rot) {
    final p = Path();
    for (var i = 0; i < n; i++) {
      final a = rot - math.pi / 2 + i * 2 * math.pi / n;
      final pt = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  static Path _partial(Path p, double f) {
    final out = Path();
    final ms = p.computeMetrics().toList();
    final total = ms.fold<double>(0, (a, m) => a + m.length);
    var left = total * f;
    for (final m in ms) {
      if (left <= 0) break;
      out.addPath(m.extractPath(0, math.min(left, m.length)), Offset.zero);
      left -= m.length;
    }
    return out;
  }

  static Path _dashed(Path p, double on, double off) {
    final out = Path();
    for (final m in p.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        out.addPath(m.extractPath(d, math.min(d + on, m.length)), Offset.zero);
        d += on + off;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(ScenePainter old) =>
      old.time != time || old.fg != fg || old.ops != ops;
}

/// Memutar [def] sekali ketika [active], lalu diam. Ketuk untuk memutar ulang.
class SceneView extends StatefulWidget {
  const SceneView(
      {super.key, required this.def, required this.active, required this.dark});
  final SceneDef def;
  final bool active;
  final bool dark;

  @override
  State<SceneView> createState() => _SceneViewState();
}

class _SceneViewState extends State<SceneView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.def.dur * 1000).round()));
  List<Op>? _ops;
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.of(context).disableAnimations;
    _ops = widget.def.ops();
    if (widget.active) _play();
  }

  @override
  void didUpdateWidget(SceneView old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _play();
    if (old.def != widget.def) _ops = widget.def.ops();
  }

  void _play() {
    if (_reduce) {
      _c.value = 1;
    } else {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = OTColors.textPrimary(widget.dark);
    final bg = OTColors.canvas(widget.dark);
    final latin = OTTypography.body(color: fg);
    final ar = OTTypography.arabicDisplay(color: fg);
    return Semantics(
      label: widget.def.alt,
      image: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _play,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(
            painter: ScenePainter(
                _ops ?? const [], _c.value * widget.def.dur, fg, bg, latin, ar),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
