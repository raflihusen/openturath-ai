import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

import 'mark_data.dart';
import 'tokens.dart';

/// Geometri tanda OpenTurath: empat kontur, dinormalkan ke kotak 0..1 pada
/// tinggi. Kontur pertama adalah bingkai arch luar.
class MarkGeometry {
  MarkGeometry._() {
    for (final d in kMarkPaths) {
      final p = parseSvgPathData(d).shift(const Offset(kMarkDx, kMarkDy));
      parts.add(p);
    }
  }
  static final MarkGeometry instance = MarkGeometry._();
  final List<Path> parts = [];

  Path get all {
    final p = Path();
    for (final part in parts) {
      p.addPath(part, Offset.zero);
    }
    return p;
  }

  /// Bingkai arch luar, dipakai untuk gema latar.
  Path get frame => parts.first;
  static const Size size = Size(kMarkWidth, kMarkHeight);
}

/// Tanda yang bisa digambar tiga cara, dan dipadukan:
/// [trace] menelusuri garis tepi, [fill] mengisi penuh dengan opasitas,
/// [level] mengisi dari bawah ke atas (kemajuan pemasangan).
class MarkPainter extends CustomPainter {
  MarkPainter({
    this.trace = 0,
    this.fill = 0,
    this.level = 0,
    this.base = true,
  });
  final double trace, fill, level;
  final bool base;

  @override
  void paint(Canvas canvas, Size size) {
    final g = MarkGeometry.instance;
    final k = math.min(size.width / kMarkWidth, size.height / kMarkHeight);
    final w = kMarkWidth * k, h = kMarkHeight * k;
    canvas.save();
    canvas.translate((size.width - w) / 2, (size.height - h) / 2);
    canvas.scale(k);
    final path = g.all;

    if (base) {
      canvas.drawPath(path, Paint()..color = OT.line);
    }
    if (level > 0) {
      final y = kMarkHeight * (1 - level.clamp(0, 1));
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, y, kMarkWidth, kMarkHeight - y));
      canvas.drawPath(path, Paint()..color = OT.ink);
      canvas.restore();
      if (level < 1) {
        // Tepi isian: garis tipis bercahaya.
        final glow = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0x00FAFAFA), Color(0x88FAFAFA), Color(0x00FAFAFA)],
          ).createShader(Rect.fromLTWH(0, y - 2, kMarkWidth, 4));
        canvas.save();
        canvas.clipPath(path);
        canvas.drawRect(Rect.fromLTWH(0, y - 6, kMarkWidth, 12), glow);
        canvas.restore();
      }
    }
    if (fill > 0) {
      canvas.drawPath(
        path,
        Paint()..color = OT.ink.withValues(alpha: fill.clamp(0, 1)),
      );
    }
    if (trace > 0 && trace < 1) {
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 / k * 0.9
        ..strokeCap = StrokeCap.round
        ..color = OT.ink;
      for (final part in g.parts) {
        for (final m in part.computeMetrics()) {
          canvas.drawPath(m.extractPath(0, m.length * trace), stroke);
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MarkPainter o) =>
      o.trace != trace || o.fill != fill || o.level != level;
}

/// Gema latar: bingkai arch berulang yang memuai pelan dan memudar, seperti
/// riak dari tanda di tengah. [intensity] 0..1 menaikkan kecerahan.
class EchoPainter extends CustomPainter {
  EchoPainter({required this.phase, required this.intensity, this.center});
  final double phase, intensity;
  final Offset? center;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = MarkGeometry.instance.frame;
    final c = center ?? size.center(Offset.zero);
    const rings = 5;
    final baseK = 170 / kMarkHeight; // sama dengan tanda di tengah
    for (var i = 0; i < rings; i++) {
      final t = (phase + i / rings) % 1.0;
      final scale = baseK * (1 + t * 3.4);
      final a = math.pow(1 - t, 2) * (0.05 + 0.16 * intensity);
      if (a < 0.004) continue;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(scale);
      canvas.translate(-kMarkWidth / 2, -kMarkHeight / 2);
      canvas.drawPath(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 / scale
          ..color = OT.ink.withValues(alpha: a.toDouble()),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(EchoPainter o) =>
      o.phase != phase || o.intensity != intensity || o.center != center;
}
