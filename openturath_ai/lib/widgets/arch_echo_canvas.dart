import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:openturath_ai/core/app_platform.dart';
import 'package:openturath_ai/core/design/ot_motion.dart';
import 'ot_arch_motion.dart';

/// "Gema lengkung": lengkung runcing logo diulang sebagai lapisan bersarang,
/// seperti pintu yang makin dalam. Saat dibuka, tiap lengkung digambar dari
/// lantai ke puncak mulai dari yang terdalam, lalu menggema ke luar dengan
/// denyut cahaya di puncak. Setelahnya: cahaya bernapas pelan, bintik cahaya
/// merambat menyusuri lengkung, dan debu halus naik di dalam pintu.
/// Tanpa teks, tanpa ikon, hanya tinta putih.
class ArchEchoCanvas extends StatefulWidget {
  const ArchEchoCanvas({super.key, this.compact = false});

  /// Kanvas pendek (ponsel): lengkung dipotong oleh tepi bawah kanvas.
  final bool compact;

  @override
  State<ArchEchoCanvas> createState() => _ArchEchoCanvasState();
}

class _ArchEchoCanvasState extends State<ArchEchoCanvas>
    with TickerProviderStateMixin {
  // Urutan masuk: lapisan terbangun dari yang terdalam, lalu cahaya naik.
  late final AnimationController _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _ArchEchoPainter.introTotalMs));
  late final AnimationController _clock =
      AnimationController(vsync: this, duration: const Duration(hours: 1));
  late final AppLifecycleListener _lifecycle;
  bool _still = false;

  bool get _underTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onStateChange: (_) => _sync());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context) || _underTest;
    if (_still) {
      _intro.value = 1;
    } else if (_intro.status == AnimationStatus.dismissed) {
      _intro.forward();
    }
    _sync();
  }

  /// Berjalan hanya saat jendela aktif dan gerak tidak dikurangi.
  void _sync() {
    final state = WidgetsBinding.instance.lifecycleState;
    final isDesktop = AppPlatform.isDesktop;
    final active = isDesktop ||
        state == null ||
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    if (_still || !active) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _intro.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_clock, _intro]),
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ArchEchoPainter(
            // Saat diam, pakai satu bingkai yang representatif.
            seconds: _still ? 2.6 : _clock.value * 3600,
            introMs: _intro.value * _ArchEchoPainter.introTotalMs,
            compact: widget.compact,
          ),
        ),
      ),
    );
  }
}

class _ArchEchoPainter extends CustomPainter {
  _ArchEchoPainter(
      {required this.seconds, required this.introMs, required this.compact});

  final double seconds;
  final double introMs;
  final bool compact;

  static const int introTotalMs = 3000;
  static const _layers = 6;
  static const _breath = 13.0; // detik per napas cahaya
  static const _drawMs = 900.0; // lama satu lengkung digambar
  static const _staggerMs = 170.0; // jeda antarlapisan, dari dalam ke luar

  /// Gelombang halus 0..1 dengan puncak yang lebih lama daripada sinus.
  static double _wave(double phase) {
    final s = 0.5 + 0.5 * math.sin(phase * 2 * math.pi);
    return s * s * (3 - 2 * s);
  }

  static double _ease(double v) => OTMotion.curve.transform(v.clamp(0.0, 1.0));

  static Color _white(double alpha) =>
      Color.fromRGBO(255, 255, 255, alpha.clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final top = size.height * (compact ? 0.11 : 0.10);
    final base = size.height * (compact ? 0.93 : 0.88);
    final h0 = base - top;
    final w0 = math.min(size.width * (compact ? 0.64 : 0.70), h0 * 0.74);
    final t = seconds / _breath;
    final breathe = _wave(t);
    final settled = introMs >= introTotalMs - 1;

    // ── Cahaya pintu, di belakang semua lapisan ──
    final glowIn = _ease((introMs - 900) / 1400);
    final glowCenter = Offset(cx, base - h0 * 0.30);
    final glowRadius = w0 * 0.62;
    canvas.drawCircle(
      glowCenter,
      glowRadius,
      Paint()
        ..shader = ui.Gradient.radial(
          glowCenter,
          glowRadius,
          [_white((0.07 + 0.07 * breathe) * glowIn), _white(0)],
        ),
    );

    // ── Lantai: garis tipis dan pendar elips tempat lengkung berdiri ──
    final floorIn = _ease((introMs - 500) / 900);
    final floorRect = Rect.fromCenter(
        center: Offset(cx, base), width: w0 * 1.5, height: h0 * 0.09);
    canvas.save();
    canvas
        .clipRect(Rect.fromLTRB(0, base - h0 * 0.045, size.width, size.height));
    canvas.drawOval(
      floorRect,
      Paint()
        ..shader = ui.Gradient.radial(
          floorRect.center,
          floorRect.width / 2,
          [_white((0.14 + 0.06 * breathe) * floorIn), _white(0)],
          const [0.0, 1.0],
          TileMode.clamp,
          Matrix4.diagonal3Values(1, floorRect.height / floorRect.width, 1)
              .storage,
          floorRect.center,
        ),
    );
    canvas.restore();
    canvas.drawLine(
      Offset(cx - w0 * 0.78, base),
      Offset(cx + w0 * 0.78, base),
      Paint()
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          Offset(cx - w0 * 0.78, base),
          Offset(cx + w0 * 0.78, base),
          [_white(0), _white(0.30 * floorIn), _white(0)],
          const [0.0, 0.5, 1.0],
        ),
    );

    // ── Lapisan lengkung: dari luar ke dalam, yang terdalam menyala lebih dulu ──
    final apexes = <Offset>[];
    final paths = <Path>[];
    for (var i = 0; i < _layers; i++) {
      final depth = i / (_layers - 1); // 0 luar .. 1 dalam
      final pulse = _wave(t - (_layers - 1 - i) * 0.085);
      final startMs = (_layers - 1 - i) * _staggerMs;
      final p = _ease((introMs - startMs) / _drawMs);
      if (p == 0) continue;

      final scale = (1 - depth * 0.72) * (1 + 0.010 * (pulse - 0.5));
      final h = h0 * scale;
      final w = w0 * scale;
      final bottom = base - h0 * 0.10 * depth;
      final rect = Rect.fromLTRB(cx - w / 2, bottom - h, cx + w / 2, bottom);
      final outline = otArchPath(rect, open: true);
      final metric = outline.computeMetrics().first;
      final len = metric.length;

      // Isi: terang di dasar, hilang di puncak; menyusul setelah garisnya jadi.
      final fillIn = _ease((p - 0.55) / 0.45);
      if (fillIn > 0) {
        canvas.drawPath(
          otArchPath(rect),
          Paint()
            ..style = PaintingStyle.fill
            ..shader = ui.Gradient.linear(
              rect.topCenter,
              rect.bottomCenter,
              [_white(0), _white((0.020 + 0.022 * pulse) * fillIn)],
            ),
        );
      }

      // Garis: tumbuh dari lantai ke puncak di kedua sisi, bertemu di mahkota.
      final reach = p * 0.5;
      final strokeAlpha = 0.22 + 0.10 * depth + 0.16 * pulse;
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 0 ? 1.4 : 1.1
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          [_white(strokeAlpha + 0.12), _white(strokeAlpha * 0.55)],
        );
      canvas.drawPath(metric.extractPath(0, len * reach), linePaint);
      canvas.drawPath(metric.extractPath(len * (1 - reach), len), linePaint);

      // Percik di ujung garis yang sedang naik.
      if (p < 1) {
        final spark = _white(0.85 * (1 - p * 0.5));
        for (final off in [len * reach, len * (1 - reach)]) {
          final tan = metric.getTangentForOffset(off);
          if (tan != null) {
            canvas.drawCircle(tan.position, 2.1, Paint()..color = spark);
            canvas.drawCircle(
              tan.position,
              7,
              Paint()
                ..shader = ui.Gradient.radial(
                  tan.position,
                  7,
                  [_white(0.35 * (1 - p)), _white(0)],
                ),
            );
          }
        }
      }

      // Denyut di mahkota saat dua sisi bertemu.
      final ringT = ((introMs - startMs - _drawMs) / 650).clamp(0.0, 1.0);
      if (ringT > 0 && ringT < 1) {
        final apex = Offset(rect.center.dx, rect.top);
        canvas.drawCircle(
          apex,
          3 + 18 * _ease(ringT),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = _white(0.55 * (1 - ringT)),
        );
      }
      apexes.add(Offset(rect.center.dx, rect.top));
      paths.add(outline);
    }

    // ── Setelah dibuka: bintik cahaya menyusuri lengkung, debu naik di dalam ──
    if (settled) {
      for (var i = 0; i < paths.length; i += 2) {
        final metric = paths[i].computeMetrics().first;
        final period = 7.0 + i * 1.3;
        final pos = ((seconds / period) + i * 0.31) % 1.0;
        final fade = math.sin(pos * math.pi);
        const tail = 0.12;
        for (var k = 0; k < 4; k++) {
          final from = (pos - tail * (k + 1) / 4).clamp(0.0, 1.0);
          final to = (pos - tail * k / 4).clamp(0.0, 1.0);
          if (to <= from) continue;
          canvas.drawPath(
            metric.extractPath(metric.length * from, metric.length * to),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6
              ..strokeCap = StrokeCap.round
              ..color = _white(0.50 * fade * (1 - k / 4)),
          );
        }
        final head = metric.getTangentForOffset(metric.length * pos);
        if (head != null) {
          canvas.drawCircle(
              head.position, 2.2, Paint()..color = _white(0.80 * fade));
        }
      }
    }

    final moteIn = _ease((introMs - 1500) / 1200);
    if (moteIn > 0) {
      for (var i = 0; i < 22; i++) {
        final r1 = _hash(i * 3 + 1),
            r2 = _hash(i * 3 + 2),
            r3 = _hash(i * 3 + 3);
        final rise = (r2 + seconds * (0.012 + 0.02 * r3)) % 1.0;
        final y = base - rise * h0 * 0.86;
        final narrow = 1 - rise * 0.55;
        final x = cx +
            (r1 - 0.5) * w0 * 0.84 * narrow +
            math.sin(seconds * 0.6 + i) * 5;
        final twinkle = 0.5 + 0.5 * math.sin(seconds * (0.8 + r3) + i * 2.1);
        final alpha =
            (0.10 + 0.34 * twinkle) * math.sin(rise * math.pi) * moteIn;
        canvas.drawCircle(
            Offset(x, y), 0.8 + 0.9 * r3, Paint()..color = _white(alpha));
      }
    }
  }

  /// Acak deterministik 0..1, agar debu sama di setiap bingkai.
  static double _hash(int n) {
    final v = math.sin(n * 12.9898) * 43758.5453;
    return v - v.floorToDouble();
  }

  @override
  bool shouldRepaint(_ArchEchoPainter oldDelegate) =>
      oldDelegate.seconds != seconds ||
      oldDelegate.introMs != introMs ||
      oldDelegate.compact != compact;
}

/// Pelukis lepas untuk tangkapan layar uji visual pada waktu tertentu.
@visibleForTesting
CustomPainter archEchoPainterAt(
        {required double seconds,
        required double introMs,
        bool compact = false}) =>
    _ArchEchoPainter(seconds: seconds, introMs: introMs, compact: compact);
