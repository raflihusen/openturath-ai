import 'package:flutter/material.dart';

import '../core/design/ot_motion.dart';
import '../core/design/ot_typography.dart';
import 'openturath_brand.dart';

/// Lengkung runcing logo: dua busur bertemu di puncak. Versi [open] tidak
/// menggambar garis lantai. Bentuk yang sama dipakai `motion/src/spec.ts`.
Path otArchPath(Rect rect, {bool open = false}) {
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
    ..cubicTo(rect.center.dx + rect.width * 0.2, rect.top + rect.height * 0.075,
        rect.right, rect.top + rect.height * 0.19, rect.right, shoulder)
    ..lineTo(rect.right, rect.bottom);
  if (!open) path.close();
  return path;
}

/// Bagian 0..1 dari rentang [from]..[to] milidetik, dilunakkan [curve].
double _phase(double ms, int from, int to, Curve curve) =>
    curve.transform(((ms - from) / (to - from)).clamp(0.0, 1.0));

Path _segment(Path path, double from, double to) {
  final metric = path.computeMetrics().first;
  return metric.extractPath((from * metric.length).clamp(0.0, metric.length),
      (to * metric.length).clamp(0.0, metric.length));
}

/// Pembuka aplikasi: garis lengkung ditulis, tanda logo muncul di dalamnya,
/// tiga gema merambat ke luar, lalu wordmark naik. Diputar sekali.
class OTSplashIntro extends StatefulWidget {
  const OTSplashIntro({super.key, required this.ink});

  final Color ink;

  @override
  State<OTSplashIntro> createState() => _OTSplashIntroState();
}

class _OTSplashIntroState extends State<OTSplashIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: OTMotion.splashTotal)
        ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    const total = OTMotion.splashTotalMs;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final ms = still ? total.toDouble() : _controller.value * total;
        final mark = _phase(ms, OTMotion.splashMarkStartMs,
            OTMotion.splashMarkEndMs, OTMotion.curve);
        final word = _phase(ms, OTMotion.splashWordStartMs,
            OTMotion.splashWordEndMs, OTMotion.curve);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 92,
              height: 112,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                        painter: _SplashArchPainter(ms: ms, ink: widget.ink)),
                  ),
                  Positioned(
                    left: 22,
                    top: 46,
                    child: Opacity(
                      opacity: mark,
                      child: Transform.scale(
                        scale: 0.9 + 0.1 * mark,
                        child: OpenTurathMark(size: 48, color: widget.ink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Opacity(
              opacity: word,
              child: Transform.translate(
                offset: Offset(0, (1 - word) * OTMotion.splashWordShift),
                child: Text(
                  'OpenTurath',
                  textDirection: TextDirection.ltr,
                  style: OTTypography.brandLogo(color: widget.ink)
                      .copyWith(fontSize: OTFontSize.s36, letterSpacing: -0.6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SplashArchPainter extends CustomPainter {
  _SplashArchPainter({required this.ms, required this.ink});

  final double ms;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = otArchPath(Offset.zero & size, open: true);
    final origin = Offset(size.width / 2, size.height * 0.62);

    for (var i = 0; i < OTMotion.splashEchoCount; i++) {
      final start =
          OTMotion.splashEchoStartMs + i * OTMotion.splashEchoStaggerMs;
      final t = (ms - start) / OTMotion.splashEchoDurationMs;
      if (t <= 0 || t >= 1) continue;
      final scale = 1 + (0.45 + 0.4 * i) * OTMotion.sheetCurve.transform(t);
      final peak = 0.34 - 0.08 * i;
      final alpha = t < 0.13 ? peak * t / 0.13 : peak * (1 - (t - 0.13) / 0.87);
      canvas
        ..save()
        ..translate(origin.dx, origin.dy)
        ..scale(scale)
        ..translate(-origin.dx, -origin.dy)
        ..drawPath(
          outline,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1 / scale
            ..color = ink.withValues(alpha: alpha),
        )
        ..restore();
    }

    final drawn = _phase(ms, OTMotion.splashDrawStartMs,
        OTMotion.splashDrawEndMs, OTMotion.curve);
    if (drawn > 0) {
      canvas.drawPath(
        _segment(outline, 0, drawn),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..color = ink,
      );
    }
  }

  @override
  bool shouldRepaint(_SplashArchPainter oldDelegate) =>
      oldDelegate.ms != ms || oldDelegate.ink != ink;
}

/// Tanda memuat layar penuh: logo diam, satu cahaya menyusuri garis lengkung.
/// [progress] 0..1 untuk satu putaran.
class OTArchLoader extends StatelessWidget {
  const OTArchLoader({super.key, required this.progress, required this.ink});

  final double progress;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 88,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
                painter: _LoaderArchPainter(progress: progress, ink: ink)),
          ),
          Positioned(
              left: 17, top: 36, child: OpenTurathMark(size: 38, color: ink)),
        ],
      ),
    );
  }
}

class _LoaderArchPainter extends CustomPainter {
  _LoaderArchPainter({required this.progress, required this.ink});

  final double progress;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = otArchPath(Offset.zero & size, open: true);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(outline, stroke..color = ink.withValues(alpha: 0.12));
    const sweep = OTMotion.loaderSweep;
    final head = progress * (1 + sweep);
    canvas.drawPath(_segment(outline, head - sweep, head), stroke..color = ink);
  }

  @override
  bool shouldRepaint(_LoaderArchPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.ink != ink;
}
