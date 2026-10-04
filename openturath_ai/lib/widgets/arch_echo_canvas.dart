import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:openturath_ai/core/design/ot_colors.dart';
/// "Gema lengkung": lengkung runcing logo diulang sebagai lapisan bersarang,
/// seperti pintu yang makin dalam. Cahaya di dasar bernapas pelan dan
/// merambat dari lapisan terdalam ke luar. Tanpa teks, tanpa ikon.
class ArchEchoCanvas extends StatefulWidget {
  const ArchEchoCanvas({super.key, this.compact = false});

  /// Kanvas pendek (ponsel): lengkung dipotong oleh tepi bawah kanvas.
  final bool compact;

  @override
  State<ArchEchoCanvas> createState() => _ArchEchoCanvasState();
}

class _ArchEchoCanvasState extends State<ArchEchoCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
      vsync: this, duration: const Duration(hours: 1));
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
    _sync();
  }

  /// Berjalan hanya saat jendela aktif dan gerak tidak dikurangi.
  void _sync() {
    final state = WidgetsBinding.instance.lifecycleState;
    final active = state == null || state == AppLifecycleState.resumed;
    if (_still || !active) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ArchEchoPainter(
            // Saat diam, pakai satu bingkai yang representatif.
            seconds: _still ? 2.6 : _clock.value * 3600,
            compact: widget.compact,
          ),
        ),
      ),
    );
  }
}

class _ArchEchoPainter extends CustomPainter {
  _ArchEchoPainter({required this.seconds, required this.compact});

  final double seconds;
  final bool compact;

  static const _layers = 7;
  static const _breath = 13.0; // detik per napas cahaya
  static const _lag = 0.085; // jeda rambat antarlapisan (bagian satu napas)

  /// Lengkung runcing seperti logo: dua busur bertemu di puncak. Garis
  /// lantai tidak ikut digambar pada versi [open].
  static Path _arch(Rect rect, {bool open = false}) {
    final shoulder = rect.top + rect.height * 0.40;
    final path = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, shoulder)
      ..cubicTo(
          rect.left,
          rect.top + rect.height * 0.19,
          rect.center.dx - rect.width * 0.2,
          rect.top + rect.height * 0.075,
          rect.center.dx,
          rect.top)
      ..cubicTo(
          rect.center.dx + rect.width * 0.2,
          rect.top + rect.height * 0.075,
          rect.right,
          rect.top + rect.height * 0.19,
          rect.right,
          shoulder)
      ..lineTo(rect.right, rect.bottom);
    if (!open) path.close();
    return path;
  }

  /// Gelombang halus 0..1 dengan puncak yang lebih lama daripada sinus.
  static double _wave(double phase) {
    final s = 0.5 + 0.5 * math.sin(phase * 2 * math.pi);
    return s * s * (3 - 2 * s);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final top = size.height * (compact ? 0.12 : 0.085);
    final bottom = size.height * (compact ? 1.25 : 0.84);
    // Titik hilang: lapisan mengecil ke arah sini, seperti lorong.
    final vanish = size.height * (compact ? 0.62 : 0.40);
    final width =
        math.min(size.width * (compact ? 0.56 : 0.78), (bottom - top) * 0.74);
    final centerX = size.width / 2;
    final t = seconds / _breath;

    // Cahaya di ujung lorong, di belakang semua lapisan.
    final glow = _wave(t);
    final glowCenter = Offset(centerX, vanish + (bottom - vanish) * 0.10);
    final glowRadius = width * 0.46;
    canvas.drawCircle(
      glowCenter,
      glowRadius,
      Paint()
        ..shader = ui.Gradient.radial(
          glowCenter,
          glowRadius,
          [
            Color.fromRGBO(255, 255, 255, 0.06 + 0.06 * glow),
            OTColors.surfaceLight.withValues(alpha: 0.00),
          ],
        ),
    );

    // Dari luar ke dalam; lapisan terdalam menyala lebih dulu.
    for (var i = 0; i < _layers; i++) {
      final depth = i / (_layers - 1); // 0 luar .. 1 dalam
      final pulse = _wave(t - (_layers - 1 - i) * _lag);
      final scale = (1 - depth * 0.74) * (1 + 0.012 * (pulse - 0.5));
      final w = width * scale;
      final rect = Rect.fromLTRB(
        centerX - w / 2,
        vanish - (vanish - top) * scale,
        centerX + w / 2,
        vanish + (bottom - vanish) * scale,
      );

      // Tiap lapisan memudar ke bawah agar tidak ada garis lantai.
      Shader fade(double alpha) => ui.Gradient.linear(
            rect.topCenter,
            rect.bottomCenter,
            [
              Color.fromRGBO(255, 255, 255, alpha),
              Color.fromRGBO(255, 255, 255, alpha),
              OTColors.surfaceLight.withValues(alpha: 0.00),
            ],
            const [0.0, 0.5, 1.0],
          );

      canvas.drawPath(
        _arch(rect),
        Paint()
          ..style = PaintingStyle.fill
          ..shader = fade(0.018 + 0.016 * pulse),
      );
      canvas.drawPath(
        _arch(rect, open: true),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..shader = fade(0.07 + 0.03 * depth + 0.09 * pulse),
      );
    }
  }

  @override
  bool shouldRepaint(_ArchEchoPainter oldDelegate) =>
      oldDelegate.seconds != seconds || oldDelegate.compact != compact;
}
