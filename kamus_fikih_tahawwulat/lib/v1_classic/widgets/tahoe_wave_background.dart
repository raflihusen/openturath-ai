import 'dart:math' as math;
import 'package:flutter/material.dart';

class TahoeWaveBackground extends StatefulWidget {
  final bool isDark;
  final Widget child;

  const TahoeWaveBackground({
    super.key,
    required this.isDark,
    required this.child,
  });

  @override
  State<TahoeWaveBackground> createState() => _TahoeWaveBackgroundState();
}

class _TahoeWaveBackgroundState extends State<TahoeWaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseBg = widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFEBF4FF);

    return Stack(
      children: [
        // Solid base color
        Container(color: baseBg),

        // Animated wave layers
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _TahoeWavePainter(
                  progress: _controller.value,
                  isDark: widget.isDark,
                ),
              );
            },
          ),
        ),

        // Foreground content
        widget.child,
      ],
    );
  }
}

class _TahoeWavePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _TahoeWavePainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1: Sky blue wave
    final paint1 = Paint()
      ..color = isDark
          ? const Color(0x2E38BDF8)
          : const Color(0x3360A5FA)
      ..style = PaintingStyle.fill;

    // Layer 2: Indigo violet wave
    final paint2 = Paint()
      ..color = isDark
          ? const Color(0x266366F1)
          : const Color(0x2E818CF8)
      ..style = PaintingStyle.fill;

    // Layer 3: Cyan deep wave
    final paint3 = Paint()
      ..color = isDark
          ? const Color(0x1F06B6D4)
          : const Color(0x2638BDF8)
      ..style = PaintingStyle.fill;

    _drawWave(canvas, size, paint1, 0.0, 36.0, 0.48);
    _drawWave(canvas, size, paint2, math.pi * 0.65, 48.0, 0.58);
    _drawWave(canvas, size, paint3, math.pi * 1.3, 40.0, 0.68);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double phaseOffset, double waveHeight, double yRatio) {
    final path = Path();
    final yBase = size.height * yRatio;
    path.moveTo(0, size.height);
    path.lineTo(0, yBase);

    for (double x = 0; x <= size.width; x += 10) {
      final radian = (x / size.width) * 2 * math.pi;
      final y = yBase + math.sin(radian + (progress * 2 * math.pi) + phaseOffset) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TahoeWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
