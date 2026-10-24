import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import 'openturath_brand.dart';

/// Fase 0..1 untuk jendela waktu [a, b] ms pada garis waktu sekali putar.
double obPhase(double ms, double a, double b,
        [Curve curve = Curves.easeOutCubic]) =>
    curve.transform(((ms - a) / (b - a)).clamp(0.0, 1.0));

/// Garis waktu gambar pengenalan: satu putaran awal ([ms], dari 0 sampai
/// [introMs]) lalu gerak pelan berulang ([loop], 0..1). Gerak dikurangi:
/// langsung bingkai akhir tanpa pengulangan.
class OnboardingTimeline extends StatefulWidget {
  const OnboardingTimeline(
      {super.key, required this.builder, this.introMs = 5200});

  final Widget Function(BuildContext context, double ms, double loop) builder;
  final int introMs;

  @override
  State<OnboardingTimeline> createState() => _OnboardingTimelineState();
}

class _OnboardingTimelineState extends State<OnboardingTimeline>
    with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
      vsync: this, duration: Duration(milliseconds: widget.introMs));
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 14));
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

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_in, _loop]),
        builder: (c, _) =>
            widget.builder(c, _in.value * widget.introMs, _loop.value),
      );
}

/// Tanda silang atau centang yang digambar perlahan.
class _Mark extends CustomPainter {
  _Mark(this.check, this.progress, this.color);
  final bool check;
  final double progress;
  final Color color;

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final path = Path();
    if (check) {
      path
        ..moveTo(s.width * 0.2, s.height * 0.55)
        ..lineTo(s.width * 0.42, s.height * 0.76)
        ..lineTo(s.width * 0.8, s.height * 0.28);
    } else {
      path
        ..moveTo(s.width * 0.26, s.height * 0.26)
        ..lineTo(s.width * 0.74, s.height * 0.74)
        ..moveTo(s.width * 0.74, s.height * 0.26)
        ..lineTo(s.width * 0.26, s.height * 0.74);
    }
    final total = path.computeMetrics().fold<double>(0, (a, m) => a + m.length);
    var left = total * progress;
    for (final m in path.computeMetrics()) {
      if (left <= 0) break;
      final take = math.min(left, m.length);
      c.drawPath(m.extractPath(0, take), p);
      left -= take;
    }
  }

  @override
  bool shouldRepaint(covariant _Mark old) =>
      old.progress != progress || old.color != color || old.check != check;
}

Widget _mark(bool check, double progress, Color color, {double size = 24}) =>
    SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _Mark(check, progress, color)));

// ───────────────────────── Slide 1: logo, cincin, titik mengorbit

class OnboardingLogoArt extends StatelessWidget {
  const OnboardingLogoArt({super.key, required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final ink = OTColors.textPrimary(dark);
    return LayoutBuilder(builder: (context, box) {
      final side = math.min(
          box.maxWidth, box.maxHeight.isFinite ? box.maxHeight : box.maxWidth);
      return Center(
        child: SizedBox.square(
          dimension: side,
          child: OnboardingTimeline(
            builder: (c, ms, loop) {
              final logo = obPhase(ms, 900, 1900, Curves.easeOutBack);
              return Stack(alignment: Alignment.center, children: [
                RepaintBoundary(
                  child: CustomPaint(
                      size: Size.square(side),
                      painter: _LogoPainter(ms, loop, ink)),
                ),
                Opacity(
                  opacity: obPhase(ms, 900, 1500).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.7 + 0.3 * logo,
                    child: OpenTurathMark(size: side * 0.27, color: ink),
                  ),
                ),
              ]);
            },
          ),
        ),
      );
    });
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.ms, this.loop, this.ink);
  final double ms, loop;
  final Color ink;

  Paint _line(double a, [double w = 1.3]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..color = ink.withValues(alpha: a);

  @override
  void paint(Canvas c, Size s) {
    final ctr = s.center(Offset.zero);
    final R = s.width / 2;

    // Gelombang awal: tiga denyut keluar dari tengah.
    for (var i = 0; i < 3; i++) {
      final t = obPhase(ms, 100 + i * 260, 1500 + i * 260, Curves.easeOutQuart);
      if (t <= 0 || t >= 1) continue;
      c.drawCircle(ctr, R * 0.95 * t, _line(0.32 * (1 - t), 1.6));
    }

    // Cincin tetap digambar berurutan.
    const radii = [0.4, 0.6, 0.8];
    for (var i = 0; i < radii.length; i++) {
      final t =
          obPhase(ms, 500 + i * 260, 1800 + i * 260, Curves.easeInOutCubic);
      c.drawArc(Rect.fromCircle(center: ctr, radius: R * radii[i]),
          -math.pi / 2, 2 * math.pi * t, false, _line(0.42 - i * 0.08));
      if (t >= 1) {
        final dir = i.isEven ? 1.0 : -1.0;
        final a =
            -math.pi / 2 + dir * loop * 2 * math.pi * (1 + i * 0.5) + i * 2.1;
        final pos = ctr + Offset(math.cos(a), math.sin(a)) * (R * radii[i]);
        c.drawCircle(pos, 3.6, Paint()..color = ink.withValues(alpha: 0.9));
        c.drawCircle(pos, 10, Paint()..color = ink.withValues(alpha: 0.07));
      }
    }

    // Garis ukur tipis di tepi, seperti pinggir naskah.
    const ticks = 72;
    final tickT = obPhase(ms, 700, 2600, Curves.easeInOut);
    for (var i = 0; i < ticks; i++) {
      if (i / ticks > tickT) break;
      final a = -math.pi / 2 + 2 * math.pi * i / ticks;
      final long = i % 6 == 0;
      final r1 = R * 0.93, r2 = R * (long ? 0.865 : 0.9);
      c.drawLine(
          ctr + Offset(math.cos(a), math.sin(a)) * r1,
          ctr + Offset(math.cos(a), math.sin(a)) * r2,
          _line(long ? 0.5 : 0.22, 1));
    }

    // Napas halus di sekeliling logo.
    final breath = 0.5 + 0.5 * math.sin(loop * 2 * math.pi * 4);
    c.drawCircle(ctr, R * (0.24 + 0.02 * breath) * obPhase(ms, 1200, 2000),
        _line(0.12 + 0.12 * breath, 1.2));
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) => true;
}

// ───────────────────────── Slide 2: AI umum lawan OpenTurath

class OnboardingVersusArt extends StatelessWidget {
  const OnboardingVersusArt({
    super.key,
    required this.dark,
    required this.left,
    required this.right,
    required this.rows,
  });
  final bool dark;
  final String left, right;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    final inv = OTColors.textPrimary(!dark);
    return Align(
      alignment: Alignment.topCenter,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 352,
          child: OnboardingTimeline(
            introMs: 600 + rows.length * 1250 + 800,
            builder: (c, ms, loop) {
              final legend = obPhase(ms, 0, 500);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Opacity(
                    opacity: legend,
                    child: Wrap(
                        spacing: OTSpacing.sm,
                        runSpacing: OTSpacing.sm,
                        children: [
                          _legend(false, left, muted,
                              OTColors.borderStrong(dark), null, 1),
                          _legend(true, right, inv, ink, ink, 1),
                        ]),
                  ),
                  const SizedBox(height: OTSpacing.lg),
                  for (var i = 0; i < rows.length; i++) ...[
                    _group(rows[i], ms, 600.0 + i * 1250, ink, muted, inv),
                    const SizedBox(height: OTSpacing.base),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _legend(bool check, String text, Color fg, Color border, Color? fill,
          double progress) =>
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.md, vertical: OTSpacing.xs),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: OTRadius.chipBorder,
          border: Border.all(color: border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _mark(check, progress, fg, size: 16),
          const SizedBox(width: OTSpacing.xs),
          Text(text, style: OTTypography.captionMedium(color: fg)),
        ]),
      );

  Widget _group((String, String) row, double ms, double s, Color ink,
      Color muted, Color inv) {
    final lIn = obPhase(ms, s, s + 320);
    final cross = obPhase(ms, s + 320, s + 700);
    final rIn = obPhase(ms, s + 760, s + 1080);
    final tick = obPhase(ms, s + 860, s + 1180);
    final jitter = math.sin(ms * 0.09) * 2.2 * (1 - cross) * lIn;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Opacity(
        opacity: lIn,
        child: Transform.translate(
          offset: Offset(jitter, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.base, vertical: OTSpacing.md),
            decoration: BoxDecoration(
              borderRadius: OTRadius.cardBorder,
              border: Border.all(
                  color: OTColors.border(dark).withValues(alpha: 0.9)),
            ),
            child: Row(children: [
              _mark(false, cross, muted, size: 20),
              const SizedBox(width: OTSpacing.md),
              Expanded(
                child: Text(row.$1,
                    style: OTTypography.body(color: muted).copyWith(
                        decoration: cross > 0.5
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: muted)),
              ),
            ]),
          ),
        ),
      ),
      const SizedBox(height: OTSpacing.sm),
      Opacity(
        opacity: rIn,
        child: Transform.translate(
          offset: Offset((1 - rIn) * 18, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.base, vertical: OTSpacing.md),
            decoration: BoxDecoration(
              color: ink,
              borderRadius: OTRadius.cardBorder,
            ),
            child: Row(children: [
              _mark(true, tick, inv, size: 20),
              const SizedBox(width: OTSpacing.md),
              Expanded(
                child: Text(row.$2, style: OTTypography.bodyMedium(color: inv)),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

// ───────────────────────── Slide 3: peta bidang ilmu

class OnboardingFieldsArt extends StatelessWidget {
  const OnboardingFieldsArt({
    super.key,
    required this.dark,
    required this.labels,
    required this.exclusiveIndex,
    required this.exclusiveText,
  });
  final bool dark;
  final List<String> labels;
  final int exclusiveIndex;
  final String exclusiveText;

  @override
  Widget build(BuildContext context) {
    final ink = OTColors.textPrimary(dark);
    final canvas = OTColors.canvas(dark);
    final muted = OTColors.textSecondary(dark);
    return LayoutBuilder(builder: (context, box) {
      final side = math.min(
          box.maxWidth, box.maxHeight.isFinite ? box.maxHeight : box.maxWidth);
      final n = labels.length;
      final ctr = Offset(side / 2, side / 2);
      final R = side * 0.34;
      final nr = side * 0.062;
      Offset pos(int i) =>
          ctr +
          Offset(math.cos(-math.pi / 2 + 2 * math.pi * i / n),
                  math.sin(-math.pi / 2 + 2 * math.pi * i / n)) *
              R;
      return Center(
        child: SizedBox.square(
          dimension: side,
          child: OnboardingTimeline(
            builder: (c, ms, loop) {
              // Sorotan berpindah tiap ±1,9 detik setelah gambar jadi.
              final cycle = (loop * 14000 / 1900).floor() % n;
              final hl = ms < 3000 ? -1 : cycle;
              return Stack(children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size.square(side),
                    painter: _FieldsPainter(
                        ms: ms,
                        loop: loop,
                        ink: ink,
                        canvas: canvas,
                        n: n,
                        hl: hl,
                        R: R,
                        nr: nr),
                  ),
                ),
                Positioned(
                  left: ctr.dx - side * 0.1,
                  top: ctr.dy - side * 0.1,
                  width: side * 0.2,
                  height: side * 0.2,
                  child: Opacity(
                    opacity: obPhase(ms, 600, 1200),
                    child: OpenTurathMark(size: side * 0.2, color: ink),
                  ),
                ),
                for (var i = 0; i < n; i++)
                  Positioned(
                    left: pos(i).dx - side * 0.17,
                    width: side * 0.34,
                    top: pos(i).dy + nr * 1.25 + OTSpacing.base,
                    child: Opacity(
                      opacity: obPhase(ms, 900 + i * 150, 1500 + i * 150),
                      child: Text(labels[i],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: i == hl
                              ? OTTypography.captionMedium(color: ink)
                              : OTTypography.caption(color: muted)),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: side * 0.015,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 280),
                    opacity: hl == exclusiveIndex ? 1 : 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: OTSpacing.base, vertical: OTSpacing.xs),
                        decoration: BoxDecoration(
                          color: ink,
                          borderRadius: OTRadius.chipBorder,
                        ),
                        child: Text(exclusiveText,
                            style: OTTypography.captionMedium(color: canvas)),
                      ),
                    ),
                  ),
                ),
              ]);
            },
          ),
        ),
      );
    });
  }
}

class _FieldsPainter extends CustomPainter {
  _FieldsPainter({
    required this.ms,
    required this.loop,
    required this.ink,
    required this.canvas,
    required this.n,
    required this.hl,
    required this.R,
    required this.nr,
  });
  final double ms, loop, R, nr;
  final Color ink, canvas;
  final int n, hl;

  Paint _line(double a, [double w = 1.3]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..color = ink.withValues(alpha: a);

  @override
  void paint(Canvas c, Size s) {
    final ctr = s.center(Offset.zero);
    final pts = [
      for (var i = 0; i < n; i++)
        ctr +
            Offset(math.cos(-math.pi / 2 + 2 * math.pi * i / n),
                    math.sin(-math.pi / 2 + 2 * math.pi * i / n)) *
                R
    ];
    // Cincin orbit tipis.
    c.drawArc(
        Rect.fromCircle(center: ctr, radius: R),
        -math.pi / 2,
        2 * math.pi * obPhase(ms, 100, 1400, Curves.easeInOutCubic),
        false,
        _line(0.16));
    for (var i = 0; i < n; i++) {
      final t = obPhase(ms, 300 + i * 120, 1000 + i * 120);
      final end = ctr + (pts[i] - ctr) * t;
      c.drawLine(ctr, end, _line(i == hl ? 0.7 : 0.2));
      // Denyut cahaya menyusuri garis cabang yang menyala.
      if (i == hl) {
        final k = (loop * 14000 % 1900) / 1900;
        final p = ctr + (pts[i] - ctr) * Curves.easeInOut.transform(k);
        c.drawCircle(p, 4, Paint()..color = ink);
        c.drawCircle(p, 11, Paint()..color = ink.withValues(alpha: 0.08));
      }
    }
    for (var i = 0; i < n; i++) {
      final t = Curves.easeOutBack
          .transform(obPhase(ms, 600 + i * 120, 1200 + i * 120));
      final lit = i == hl;
      final r = nr * (lit ? 1.25 : 1) * t;
      if (lit) {
        final pulse = 0.5 + 0.5 * math.sin(loop * 2 * math.pi * 7);
        c.drawCircle(pts[i], r + 8 + 7 * pulse,
            Paint()..color = ink.withValues(alpha: 0.05 + 0.05 * pulse));
        c.drawCircle(pts[i], r, Paint()..color = ink);
      } else {
        c.drawCircle(pts[i], r, Paint()..color = canvas);
        c.drawCircle(pts[i], r, _line(0.5));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FieldsPainter old) => true;
}

// ───────────────────────── Slide 4: bertanya, lalu memeriksa sumber

class OnboardingAskArt extends StatelessWidget {
  const OnboardingAskArt({
    super.key,
    required this.dark,
    required this.question,
    required this.explain,
    required this.passage,
    required this.reference,
  });
  final bool dark;
  final String question, explain, passage, reference;

  @override
  Widget build(BuildContext context) {
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    final inv = OTColors.textPrimary(!dark);
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 340,
          child: OnboardingTimeline(
            introMs: 6200,
            builder: (c, ms, loop) {
              final qIn = obPhase(ms, 200, 600);
              final typed = obPhase(ms, 500, 1700, Curves.linear);
              final chars = (question.characters.length * typed).round();
              final shown = question.characters.take(chars).toString();
              final cursor = typed < 1 && (ms ~/ 330).isEven;
              final dots =
                  obPhase(ms, 1800, 2000) * (1 - obPhase(ms, 2900, 3100));
              final card = obPhase(ms, 2900, 3500);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Opacity(
                      opacity: qIn,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: OTSpacing.base, vertical: OTSpacing.md),
                        decoration: BoxDecoration(
                          color: ink,
                          borderRadius: OTRadius.cardBorder,
                        ),
                        child: Text('$shown${cursor ? '▍' : ''}',
                            style: OTTypography.bodyMedium(color: inv)),
                      ),
                    ),
                  ),
                  const SizedBox(height: OTSpacing.base),
                  SizedBox(
                    height: OTSpacing.xl,
                    child: Opacity(
                      opacity: dots,
                      child: Row(children: [
                        for (var i = 0; i < 3; i++)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                                end: OTSpacing.xs),
                            child: Transform.translate(
                              offset: Offset(
                                  0,
                                  -4 *
                                      math.max(
                                          0, math.sin(ms * 0.012 - i * 0.9))),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: muted),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                  Opacity(
                    opacity: card,
                    child: Transform.translate(
                      offset: Offset(0, (1 - card) * 18),
                      child: _answer(ms, ink, muted, inv),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _answer(double ms, Color ink, Color muted, Color inv) {
    Widget bar(double w, double start, {Alignment a = Alignment.centerLeft}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: OTSpacing.sm),
          child: Align(
            alignment: a,
            child: FractionallySizedBox(
              widthFactor: w * obPhase(ms, start, start + 520),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: muted.withValues(alpha: 0.28),
                  borderRadius: OTRadius.chipBorder,
                ),
              ),
            ),
          ),
        );
    final chip = obPhase(ms, 4700, 5100);
    final tick = obPhase(ms, 5000, 5500);
    return Container(
      padding: const EdgeInsets.all(OTSpacing.base),
      decoration: BoxDecoration(
        color: OTColors.surface(dark),
        borderRadius: OTRadius.cardBorder,
        border: Border.all(color: OTColors.border(dark)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          OpenTurathMark(size: 20, color: ink),
          const SizedBox(width: OTSpacing.sm),
          Text('OpenTurath', style: OTTypography.captionMedium(color: ink)),
        ]),
        const SizedBox(height: OTSpacing.base),
        Text(explain.toUpperCase(),
            style: OTTypography.metadataTag(color: muted)),
        const SizedBox(height: OTSpacing.sm),
        bar(1, 3300),
        bar(0.9, 3500),
        bar(0.62, 3700),
        const SizedBox(height: OTSpacing.sm),
        Text(passage.toUpperCase(),
            style: OTTypography.metadataTag(color: muted)),
        const SizedBox(height: OTSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(OTSpacing.md),
          decoration: BoxDecoration(
            color: OTColors.surfaceSubtle(dark),
            borderRadius: OTRadius.xsBorder,
            border: BorderDirectional(end: BorderSide(color: ink, width: 2)),
          ),
          child: Column(children: [
            bar(1, 3900, a: Alignment.centerRight),
            bar(0.74, 4150, a: Alignment.centerRight),
          ]),
        ),
        const SizedBox(height: OTSpacing.md),
        Opacity(
          opacity: chip,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.md, vertical: OTSpacing.xs),
            decoration: BoxDecoration(
              borderRadius: OTRadius.chipBorder,
              border: Border.all(color: OTColors.borderStrong(dark)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.menu_book_outlined, size: 16, color: ink),
              const SizedBox(width: OTSpacing.sm),
              Flexible(
                child: Text(reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OTTypography.captionMedium(color: ink)),
              ),
              const SizedBox(width: OTSpacing.sm),
              _mark(true, tick, ink, size: 16),
            ]),
          ),
        ),
      ]),
    );
  }
}
