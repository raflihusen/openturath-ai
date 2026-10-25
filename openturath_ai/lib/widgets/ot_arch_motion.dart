import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/localization.dart';
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

/// Pembuka aplikasi: lengkung logo digambar, terisi, kubah naik, dua halaman terbuka, lalu wordmark
/// ditulis huruf demi huruf dan semboyan menyusul. Diputar sekali; ketuk atau
/// [skip] melompat ke bingkai akhir. Gerak dikurangi: langsung bingkai akhir.
class OTSplashIntro extends StatefulWidget {
  const OTSplashIntro({super.key, required this.ink, this.skip});

  final Color ink;
  final ValueListenable<bool>? skip;

  @override
  State<OTSplashIntro> createState() => _OTSplashIntroState();
}

class _OTSplashIntroState extends State<OTSplashIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: OTMotion.splashTotal)
        ..forward();

  void _onSkip() {
    if (widget.skip?.value == true) _controller.value = 1;
  }

  bool _feltFill = false, _feltEnd = false;

  /// Dua sentuhan halus: saat logo selesai terbentuk dan saat semboyan tuntas.
  void _haptics() {
    final ms = _controller.value * OTMotion.splashTotalMs;
    if (!_feltFill && ms >= OTMotion.splashPagesEndMs) {
      _feltFill = true;
      OTMotion.light();
    }
    if (!_feltEnd && _controller.isCompleted && widget.skip?.value != true) {
      _feltEnd = true;
      OTMotion.selection();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.skip?.addListener(_onSkip);
    if (!WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _controller.addListener(_haptics);
    }
  }

  @override
  void dispose() {
    widget.skip?.removeListener(_onSkip);
    _controller.dispose();
    super.dispose();
  }

  static const _markH = 128.0;
  static const _vbW = 616.0,
      _vbH = 674.0,
      _box = 1024.0,
      _x0 = 204.0,
      _y0 = 175.0;

  Widget _part(String name, Color ink, double s) =>
      Stack(clipBehavior: Clip.none, children: [
        Positioned(
          left: -_x0 * s,
          top: -_y0 * s,
          width: _box * s,
          height: _box * s,
          child: SvgPicture.asset('assets/images/logo_part_$name.svg',
              fit: BoxFit.fill,
              excludeFromSemantics: true,
              colorFilter: ColorFilter.mode(ink, BlendMode.srcIn)),
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final still = MediaQuery.disableAnimationsOf(context);
    final ink = widget.ink;
    const total = OTMotion.splashTotalMs;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final ms = still ? total.toDouble() : _controller.value * total;
        const s = _markH / _vbH;
        const markW = _vbW * s;
        final fill = _phase(ms, OTMotion.splashFillStartMs,
            OTMotion.splashFillEndMs, Curves.easeInOutCubic);
        final dome = _phase(ms, OTMotion.splashDomeStartMs,
            OTMotion.splashDomeEndMs, OTMotion.curve);
        final pages = _phase(ms, OTMotion.splashPagesStartMs,
            OTMotion.splashPagesEndMs, OTMotion.curve);
        final tag = _phase(ms, OTMotion.splashTagStartMs,
            OTMotion.splashTagEndMs, OTMotion.curve);
        const word = 'OpenTurath';
        final tagStyle = Loc.isArabic
            ? OTTypography.arabicReading(color: ink.withValues(alpha: 0.72))
                .copyWith(fontSize: OTFontSize.s16, fontWeight: FontWeight.w400)
            : OTTypography.caption(color: ink.withValues(alpha: 0.72))
                .copyWith(letterSpacing: 0.6);
        const outlineH = (833 - _y0) * s;
        const canvasW = markW * 2.9, canvasH = _markH;
        // Kunci berukuran tetap, diperbesar mengikuti sisi terpendek layar
        // (ponsel kecil tetap 1×, tablet dan desktop sampai 2×).
        final shortest = MediaQuery.sizeOf(context).shortestSide;
        final scale = (shortest / 390).clamp(1.0, 2.0);
        return Semantics(
            label: '${Loc.tr('appName')}. ${Loc.tr('splashTagline')}',
            container: true,
            child: Transform.scale(
                scale: scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: canvasW,
                      height: canvasH,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                                painter: _SplashArchPainter(
                                    ms: ms,
                                    ink: ink,
                                    markRect: Rect.fromCenter(
                                        center: const Offset(
                                            canvasW / 2, outlineH / 2),
                                        width: markW,
                                        height: outlineH))),
                          ),
                          Positioned(
                            left: (canvasW - markW) / 2,
                            top: 0,
                            width: markW,
                            height: _markH,
                            child: Stack(clipBehavior: Clip.none, children: [
                              Opacity(
                                  opacity: fill, child: _part('arch', ink, s)),
                              Opacity(
                                opacity: dome,
                                child: Transform.translate(
                                    offset: Offset(0, (1 - dome) * 22 * s),
                                    child: _part('dome', ink, s)),
                              ),
                              Opacity(
                                opacity: pages,
                                child: Transform.translate(
                                    offset:
                                        Offset(-(1 - pages) * 38 * s * -1, 0),
                                    child: _part('left', ink, s)),
                              ),
                              Opacity(
                                opacity: pages,
                                child: Transform.translate(
                                    offset: Offset(-(1 - pages) * 38 * s, 0),
                                    child: _part('right', ink, s)),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: OTSpacing.base),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        for (var i = 0; i < word.length; i++)
                          _letter(word[i], i, ms, ink),
                      ]),
                    ),
                    const SizedBox(height: OTSpacing.lg),
                    Opacity(
                      opacity: tag,
                      child: Transform.translate(
                        offset: Offset(0, (1 - tag) * 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: canvasW),
                          child: Text(
                            Loc.tr('splashTagline'),
                            textAlign: TextAlign.center,
                            style: tagStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                )));
      },
    );
  }

  Widget _letter(String ch, int i, double ms, Color ink) {
    final start = OTMotion.splashWordStartMs + i * OTMotion.splashWordStaggerMs;
    final t =
        _phase(ms, start, start + OTMotion.splashWordLetterMs, OTMotion.curve);
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 8),
        child: Text(ch,
            style: OTTypography.brandLogo(color: ink)
                .copyWith(fontSize: OTFontSize.s36, letterSpacing: -0.6)),
      ),
    );
  }
}

class _SplashArchPainter extends CustomPainter {
  _SplashArchPainter(
      {required this.ms, required this.ink, required this.markRect});

  final double ms;
  final Color ink;
  final Rect markRect;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = otArchPath(markRect, open: true);

    // Rak kitab di dalam lengkung: naik satu per satu, lalu melebur menjadi
    // logo saat lengkung terisi ("bersumber dari kitab").
    final melt = 1 -
        _phase(ms, OTMotion.splashFillStartMs - 100,
            OTMotion.splashFillEndMs - 150, Curves.easeIn);
    if (melt > 0) {
      const heights = [0.5, 0.72, 0.6, 0.84, 0.64, 0.76, 0.54];
      final n = heights.length;
      final shelfW = markRect.width * 0.62;
      final left = markRect.center.dx - shelfW / 2;
      final gap = shelfW * 0.035;
      final w = (shelfW - gap * (n - 1)) / n;
      final base = markRect.bottom;
      for (var i = 0; i < n; i++) {
        final t = _phase(
            ms,
            i * OTMotion.splashShelfStaggerMs,
            i * OTMotion.splashShelfStaggerMs + OTMotion.splashShelfRiseMs,
            OTMotion.curve);
        if (t <= 0) continue;
        final h = markRect.height * 0.62 * heights[i] * t;
        final x = left + i * (w + gap);
        final r = RRect.fromRectAndCorners(Rect.fromLTWH(x, base - h, w, h),
            topLeft: const Radius.circular(OTRadius.xs / 4),
            topRight: const Radius.circular(OTRadius.xs / 4));
        canvas.drawRRect(
            r,
            Paint()
              ..color = ink.withValues(alpha: (0.14 + 0.06 * (i % 3)) * melt));
        canvas.drawRRect(
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.1
              ..color = ink.withValues(alpha: 0.6 * melt));
      }
    }

    // Garis lengkung logo: digambar, lalu melebur ke bentuk terisi.
    final drawn = _phase(ms, OTMotion.splashDrawStartMs,
        OTMotion.splashDrawEndMs, OTMotion.curve);
    final fade = 1 -
        _phase(ms, OTMotion.splashFillStartMs, OTMotion.splashFillEndMs,
            Curves.easeIn);
    if (drawn > 0 && fade > 0) {
      canvas.drawPath(
        _segment(outline, 0, drawn),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..color = ink.withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_SplashArchPainter oldDelegate) =>
      oldDelegate.ms != ms ||
      oldDelegate.ink != ink ||
      oldDelegate.markRect != markRect;
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
