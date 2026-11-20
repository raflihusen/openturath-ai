import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_copy.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'package:openturath_ai/core/app_platform.dart';
import 'openturath_brand.dart';
import 'ot_arch_motion.dart';

/// Loader OpenTurath adaptif (Light & Dark Mode) dengan dukungan reduced motion.
///
/// - Mode ringkas (`isFullscreen: false`): empat lembaran folio mengorbit tenang,
///   cocok untuk tombol, dialog, dan lembar bawah.
/// - Mode layar penuh (`isFullscreen: true`): astrolab mihrab monokrom 3 babak
///   (Mulai → Proses → Selesai) dengan emblem resmi, lengkung mihrab berdenyut,
///   6 cincin titik harmonis, oktagram geometris, sapuan cahaya konik, 4 komet
///   orbit berlawanan arah, kilau kaca pada pedestal, dan teks progresif 3 tahap.
class AppLoader extends StatefulWidget {
  final double dotSize;
  final double spacing;
  final Color? color;
  final String? title;
  final String? subtitle;
  final List<String>? stages;
  final bool isComplete;
  final VoidCallback? onCancel;
  final String? cancelLabel;
  final bool isFullscreen;

  const AppLoader({
    super.key,
    this.dotSize = 9.0,
    this.spacing = 5.0,
    this.color,
    this.title,
    this.subtitle,
    this.stages,
    this.isComplete = false,
    this.onCancel,
    this.cancelLabel,
    this.isFullscreen = false,
  });

  const AppLoader.fullscreen({
    super.key,
    this.dotSize = 10.0,
    this.spacing = 5.0,
    this.color,
    this.title,
    this.subtitle,
    this.stages,
    this.isComplete = false,
    this.onCancel,
    this.cancelLabel,
  }) : isFullscreen = true;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _loopController;
  late final AnimationController _entranceController;
  late final AnimationController _completeController;
  Timer? _stageTimer;
  int _stageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(
      vsync: this,
      duration: widget.isFullscreen
          ? const Duration(milliseconds: 6400)
          : OTMotion.loaderLoop,
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _completeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    WidgetsBinding.instance.addObserver(this);
    _loopController.repeat();
    if (widget.isFullscreen) {
      _entranceController.forward();
      _startStageCycle();
    }
    if (widget.isComplete) {
      _completeController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AppLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isComplete && widget.isComplete) {
      _completeController.forward(from: 0.0);
      _stageTimer?.cancel();
      OTMotion.selection();
    } else if (oldWidget.isComplete && !widget.isComplete) {
      _completeController.reset();
      if (widget.isFullscreen) _startStageCycle();
    }
  }

  List<String> _resolveStages() {
    if (widget.stages != null && widget.stages!.isNotEmpty) {
      return widget.stages!;
    }
    final customSub = widget.subtitle?.trim();
    final isGenericRef = customSub == null ||
        customSub.isEmpty ||
        customSub == AppCopy.loadingReferences.trim();

    if (!isGenericRef) {
      return [customSub];
    }

    switch (Loc.language) {
      case 'en':
        return [
          customSub ?? 'Loading reference books…',
          'Preparing study session…',
          'Syncing AI assistant…',
        ];
      case 'ar':
        return [
          customSub ?? 'جارٍ تحميل كتب المراجع…',
          'تهيئة جلسة المطالعة…',
          'مزامنة المساعد الذكي…',
        ];
      default:
        return [
          customSub ?? AppCopy.loadingReferences,
          'Menyiapkan sesi belajar…',
          'Menyelaraskan asisten AI…',
        ];
    }
  }

  void _startStageCycle() {
    _stageTimer?.cancel();
    final stages = _resolveStages();
    if (stages.length <= 1 || widget.isComplete) return;
    _stageTimer = Timer.periodic(const Duration(milliseconds: 2400), (_) {
      if (!mounted || widget.isComplete) return;
      final list = _resolveStages();
      if (_stageIndex < list.length - 1) {
        setState(() => _stageIndex++);
      } else {
        _stageTimer?.cancel();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void _syncMotion() {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final isDesktop = AppPlatform.isDesktop;
    final state = WidgetsBinding.instance.lifecycleState;
    // Di desktop (macOS/Windows/Linux), saat cursor fokus ke aplikasi lain (inactive),
    // jendela aplikasi tetap terbuka dan terlihat oleh pengguna di layar.
    // Animasi loader WAJIB terus berputar tanpa henti agar pengguna
    // melihat proses tetap berjalan dan tidak mengira aplikasi mengalami freeze.
    final isForeground = isDesktop ||
        state == null ||
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    // ignore: deprecated_member_use
    if (reduced || !TickerMode.of(context) || !isForeground) {
      if (_loopController.isAnimating) _loopController.stop();
      if (reduced && widget.isFullscreen) {
        _entranceController.value = 1.0;
      }
    } else if (!_loopController.isAnimating) {
      _loopController.repeat();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) _syncMotion();
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _loopController.dispose();
    _entranceController.dispose();
    _completeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = widget.color ?? OTColors.accent(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final still = MediaQuery.disableAnimationsOf(context);

    if (!widget.isFullscreen) {
      return _buildCompact(
        ink: ink,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        still: still,
      );
    }

    final stages = _resolveStages();
    final activeSubtitle = widget.isComplete
        ? (Loc.language == 'en'
            ? 'Session ready'
            : Loc.language == 'ar'
                ? 'الجلسة جاهزة'
                : 'Sesi siap digunakan')
        : stages[_stageIndex.clamp(0, stages.length - 1)];

    final titleStyle = Loc.isArabic
        ? OTTypography.arabicReading(color: textPrimary).copyWith(
            fontSize: OTFontSize.s22,
            fontWeight: FontWeight.w600,
          )
        : ScholarlyFonts.newsreader(
            fontSize: OTFontSize.s22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.35,
            color: textPrimary,
          );

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: widget.title == null
                ? Loc.tr('loadingProcess')
                : Loc.text(widget.title!),
            liveRegion: true,
            child: RepaintBoundary(
              child: _AstrolabeEmblemLoader(
                loop: _loopController,
                entrance: _entranceController,
                complete: _completeController,
                still: still,
                isDark: isDark,
                ink: ink,
                surface: surface,
                canvasColor: canvas,
              ),
            ),
          ),
          if (widget.title != null) ...[
            const SizedBox(height: 24),
            Text(
              Loc.text(widget.title!),
              textAlign: TextAlign.center,
              style: titleStyle,
            ),
          ],
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.22),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              );
            },
            child: Text(
              activeSubtitle,
              key: ValueKey(activeSubtitle),
              textAlign: TextAlign.center,
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.05,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _QuietProgressTrack(
            loop: _loopController,
            complete: _completeController,
            still: still,
            ink: ink,
            trackColor: border.withValues(alpha: isDark ? 0.45 : 0.65),
          ),
          if (widget.onCancel != null) ...[
            const SizedBox(height: 26),
            TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(
                minimumSize: const Size(88, 44),
              ),
              child: Text(
                widget.cancelLabel ?? Loc.tr('cancel'),
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: canvas,
      child: SafeArea(
        child: Center(child: content),
      ),
    );
  }

  Widget _buildCompact({
    required Color ink,
    required Color textPrimary,
    required Color textSecondary,
    required bool still,
  }) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          label: widget.title == null
              ? Loc.tr('loadingProcess')
              : Loc.text(widget.title!),
          liveRegion: true,
          child: RepaintBoundary(
            child: SizedBox.square(
              dimension: widget.title == null ? 24.0 : 48.0,
              child: CustomPaint(
                painter: _OrbitPainter(
                  animation: _loopController,
                  still: still,
                  color: ink,
                ),
              ),
            ),
          ),
        ),
        if (widget.title != null) ...[
          const SizedBox(height: 20),
          Text(
            Loc.text(widget.title!),
            textAlign: TextAlign.center,
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s14,
              color: textSecondary,
            ),
          ),
        ],
        if (widget.onCancel != null) ...[
          const SizedBox(height: 24),
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              minimumSize: const Size(80, 44),
            ),
            child: Text(
              widget.cancelLabel ?? Loc.tr('cancel'),
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s14,
                fontWeight: FontWeight.w400,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ],
    );

    return Center(child: content);
  }
}

/// Centerpiece astrolab mihrab OpenTurath 6-lapis untuk mode layar penuh (Light & Dark Mode).
class _AstrolabeEmblemLoader extends StatelessWidget {
  const _AstrolabeEmblemLoader({
    required this.loop,
    required this.entrance,
    required this.complete,
    required this.still,
    required this.isDark,
    required this.ink,
    required this.surface,
    required this.canvasColor,
  });

  final Animation<double> loop;
  final Animation<double> entrance;
  final Animation<double> complete;
  final bool still;
  final bool isDark;
  final Color ink;
  final Color surface;
  final Color canvasColor;

  @override
  Widget build(BuildContext context) {
    final merged = Listenable.merge([loop, entrance, complete]);
    return SizedBox.square(
      dimension: 248,
      child: AnimatedBuilder(
        animation: merged,
        builder: (context, _) {
          final e = still
              ? 1.0
              : Curves.easeOutBack.transform(entrance.value.clamp(0.0, 1.0));
          final c = complete.value.clamp(0.0, 1.0);
          final u = still ? 0.25 : loop.value;
          final breath =
              still ? 0.0 : (1.0 - c) * 0.024 * math.sin(u * math.pi * 4);
          final donePop = math.sin(c * math.pi) * 0.065;
          final tileScale = (0.72 + 0.28 * e) + breath + donePop;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AstrolabePainter(
                    loop: loop,
                    entrance: entrance,
                    complete: complete,
                    still: still,
                    isDark: isDark,
                    ink: ink,
                    canvasColor: canvasColor,
                  ),
                ),
              ),
              Transform.scale(
                scale: tileScale,
                child: SizedBox.square(
                  dimension: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pedestal tile dengan bayangan berlapis OpenTurath
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                    color: ink.withValues(alpha: 0.13 + 0.07 * c),
                                    blurRadius: 34,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: OTColors.shadow.withValues(alpha: 0.55),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: OTColors.shadow.withValues(alpha: 0.12),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: OTColors.shadow.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                      ),
                      // Kilau kaca diagonal & rim-light konik berputar di atas pedestal
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: CustomPaint(
                          size: const Size.square(80),
                          painter: _PedestalSheenPainter(
                            phase: u,
                            complete: c,
                            still: still,
                            isDark: isDark,
                            ink: ink,
                          ),
                          child: Center(
                            child: OpenTurathMark(size: 44, color: ink),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Lencana centang monokrom animasi garis saat babak Selesai (isComplete)
              if (c > 0.05)
                Positioned(
                  right: 76,
                  top: 76,
                  child: Transform.scale(
                    scale: Curves.easeOutBack.transform(c),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: ink,
                        shape: BoxShape.circle,
                        border: Border.all(color: canvasColor, width: 2.4),
                      ),
                      child: CustomPaint(
                        painter: _CheckStrokePainter(
                          progress: ((c - 0.18) / 0.55).clamp(0.0, 1.0),
                          color: OTColors.onAccent(isDark),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Kilau kaca diagonal dan garis tepi konik berputar pada pedestal emblem.
class _PedestalSheenPainter extends CustomPainter {
  _PedestalSheenPainter({
    required this.phase,
    required this.complete,
    required this.still,
    required this.isDark,
    required this.ink,
  });

  final double phase;
  final double complete;
  final bool still;
  final bool isDark;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(0.75), const Radius.circular(21.5));

    // 1. Diagonal glass specular sheen (twice per loop cycle)
    if (!still) {
      final sweepU = (phase * 2.0) % 1.0;
      if (sweepU > 0.12 && sweepU < 0.62) {
        final sp = (sweepU - 0.12) / 0.50;
        final se = -(math.cos(math.pi * sp) - 1.0) * 0.5;
        final dx = (se * 2.3 - 0.65) * size.width;
        canvas.save();
        canvas.translate(dx, 0);
        canvas.rotate(-0.42);
        final sheenRect = Rect.fromLTWH(-18, -28, 36, size.height + 56);
        final sheenAlpha = isDark ? 0.14 : 0.075;
        canvas.drawRect(
          sheenRect,
          Paint()
            ..shader = LinearGradient(
              colors: [
                ink.withValues(alpha: 0.0),
                ink.withValues(alpha: sheenAlpha),
                ink.withValues(alpha: 0.0),
              ],
            ).createShader(sheenRect),
        );
        canvas.restore();
      }
    }

    // 2. Base hairline border
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1 + 0.5 * complete
        ..color = ink.withValues(
            alpha: isDark ? (0.18 + 0.18 * complete) : (0.11 + 0.24 * complete)),
    );

    // 3. Rotating metallic conic rim-light highlight along border
    if (!still && complete < 0.95) {
      final rimAngle = phase * math.pi * 2.0;
      final rimPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          transform: GradientRotation(rimAngle),
          colors: [
            ink.withValues(alpha: 0.0),
            ink.withValues(alpha: (isDark ? 0.55 : 0.36) * (1.0 - complete)),
            ink.withValues(alpha: 0.0),
            ink.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.16, 0.34, 1.0],
        ).createShader(rect);
      canvas.drawRRect(rrect, rimPaint);
    }
  }

  @override
  bool shouldRepaint(_PedestalSheenPainter old) =>
      old.phase != phase ||
      old.complete != complete ||
      old.still != still ||
      old.isDark != isDark ||
      old.ink != ink;
}

/// Animasi goresan centang monokrom saat babak Selesai.
class _CheckStrokePainter extends CustomPainter {
  _CheckStrokePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;
    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.52)
      ..lineTo(size.width * 0.43, size.height * 0.70)
      ..lineTo(size.width * 0.76, size.height * 0.32);
    final metric = path.computeMetrics().first;
    final sub = metric.extractPath(0, metric.length * Curves.easeOutCubic.transform(progress));
    canvas.drawPath(
      sub,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_CheckStrokePainter old) =>
      old.progress != progress || old.color != color;
}

class _AstrolabePainter extends CustomPainter {
  _AstrolabePainter({
    required this.loop,
    required this.entrance,
    required this.complete,
    required this.still,
    required this.isDark,
    required this.ink,
    required this.canvasColor,
  }) : super(repaint: Listenable.merge([loop, entrance, complete]));

  final Animation<double> loop;
  final Animation<double> entrance;
  final Animation<double> complete;
  final bool still;
  final bool isDark;
  final Color ink;
  final Color canvasColor;

  static const _ringR = [56.0, 67.5, 79.0, 91.0, 103.5, 116.0];
  static const _ringCount = [24, 32, 40, 48, 56, 64];
  static const _ringDot = [1.55, 1.42, 1.28, 1.15, 1.02, 0.90];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    const tau = math.pi * 2;

    final u = still ? 0.25 : loop.value;
    final e = still ? 1.0 : Curves.easeOutCubic.transform(entrance.value);
    final c = complete.value.clamp(0.0, 1.0);
    final settle = Curves.easeOutCubic.transform(c);
    final activeAmp = 1.0 - settle;
    final radarAngle = -math.pi * 0.5 + tau * u;

    // 1. Ambient radial halo & silky conic radar illumination sweep
    if (isDark) {
      final haloPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            ink.withValues(alpha: 0.16 * e),
            ink.withValues(alpha: 0.045 * e),
            ink.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: 122));
      canvas.drawCircle(center, 122, haloPaint);
    }

    if (!still && activeAmp > 0.02) {
      final sweepRect = Rect.fromCircle(center: center, radius: 118);
      final sweepAlpha = (isDark ? 0.095 : 0.055) * e * activeAmp;
      canvas.drawCircle(
        center,
        118,
        Paint()
          ..shader = SweepGradient(
            startAngle: 0,
            endAngle: tau,
            transform: GradientRotation(radarAngle - 0.95),
            colors: [
              ink.withValues(alpha: 0.0),
              ink.withValues(alpha: sweepAlpha),
              ink.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.14, 0.16],
          ).createShader(sweepRect),
      );
    }

    // 2. Pulsing Nested Sacred Mihrab Arches radiating softly from behind emblem
    if (!still && activeAmp > 0.02) {
      for (var k = 0; k < 2; k++) {
        final ap = (u * 2.0 + k * 0.5) % 1.0;
        final archW = 74.0 + Curves.easeOutCubic.transform(ap) * 92.0;
        final archH = archW * 1.14;
        final archAlpha = math.sin(ap * math.pi) * (isDark ? 0.14 : 0.10) * e * activeAmp;
        if (archAlpha > 0.003) {
          final rect = Rect.fromCenter(center: center, width: archW, height: archH);
          canvas.drawPath(
            otArchPath(rect, open: true),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0
              ..strokeCap = StrokeCap.round
              ..color = ink.withValues(alpha: archAlpha),
          );
        }
      }
    }

    // 3. Act 1 Ignition Shockwave Ring
    if (!still && entrance.value > 0.06 && entrance.value < 0.96) {
      final wp = ((entrance.value - 0.06) / 0.90).clamp(0.0, 1.0);
      final wr = 28.0 + Curves.easeOutExpo.transform(wp) * 96.0;
      final wa = (1.0 - wp) * (isDark ? 0.24 : 0.20);
      canvas.drawCircle(
        center,
        wr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * (1.0 - wp) + 0.4
          ..color = ink.withValues(alpha: wa),
      );
    }

    // 4. Dual Counter-Rotating Islamic Geometric Octagrams (Rub el Hizb)
    final octAlpha = (isDark ? 0.115 : 0.088) * e * (1.0 - 0.48 * settle);
    if (octAlpha > 0.002) {
      _drawOctagram(canvas, center, 92.0 * (0.88 + 0.12 * e), u * tau * 0.25, octAlpha);
      _drawOctagram(canvas, center, 71.0 * (0.88 + 0.12 * e), -u * tau * 0.25, octAlpha * 0.82);
    }

    // 5. Precision 60-Tick Swiss Chronometer / Astrolabe Dial
    final dialAlpha = (isDark ? 0.13 : 0.105) * e;
    canvas.drawCircle(
      center,
      116.0,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85
        ..color = ink.withValues(alpha: dialAlpha),
    );
    for (var i = 0; i < 60; i++) {
      final ang = (i / 60) * tau - math.pi / 2;
      final isCard = i % 15 == 0;
      final isMid = i % 5 == 0;
      // Subtle illumination wave synced to radar angle
      final diff = ((ang - radarAngle) % tau + tau) % tau;
      final radarBoost = (!still && activeAmp > 0.02 && diff > tau - 0.9)
          ? ((diff - (tau - 0.9)) / 0.9) * 0.38 * activeAmp
          : 0.0;
      final rIn = isCard ? 111.0 : (isMid ? 113.5 : 114.8);
      final rOut = isCard ? 122.0 : (isMid ? 118.5 : 117.2);
      final baseA = (isCard ? 0.38 : (isMid ? 0.20 : 0.095)) * (isCard ? 1.0 : (1.0 - 0.5 * settle));
      final a = ((baseA + radarBoost) * e).clamp(0.0, 0.9);
      canvas.drawLine(
        Offset(cx + math.cos(ang) * rIn, cy + math.sin(ang) * rIn),
        Offset(cx + math.cos(ang) * rOut, cy + math.sin(ang) * rOut),
        Paint()
          ..strokeWidth = isCard ? 1.3 : 0.8
          ..strokeCap = StrokeCap.round
          ..color = ink.withValues(alpha: a),
      );
    }

    // 6. 6 Concentric OpenTurath Dot-Rings with Harmonic Wave + Radar Illumination
    for (var ri = 0; ri < _ringR.length; ri++) {
      final rDelay = ri * 0.095;
      final rIn = still
          ? 1.0
          : Curves.easeOutExpo
              .transform(((entrance.value - rDelay) / (1.0 - rDelay)).clamp(0.0, 1.0));
      if (rIn <= 0.005) continue;

      final wavePhase = ((u * 2.0 - ri * 0.11) % 1.0 + 1.0) % 1.0;
      final pulse = math.exp(-math.pow((wavePhase - 0.22) * 5.6, 2.0)) * activeAmp;
      final dir = ri.isEven ? 1.0 : -1.0;
      final rot = dir * (tau / _ringCount[ri]) * (ri.isEven ? 2.0 : 1.0) * u;
      final curR = _ringR[ri] * (0.84 + 0.16 * rIn) + pulse * 2.6 + settle * (ri * 0.8);
      final baseA = ((isDark ? 0.50 : 0.42) - ri * 0.055) * rIn;
      final dotA = ((baseA + pulse * 0.38) * (1.0 - 0.58 * settle)).clamp(0.0, 1.0);
      final dotR = _ringDot[ri] * (1.0 + 0.45 * pulse) * (1.0 - 0.2 * settle);

      final dotPaint = Paint()..color = ink.withValues(alpha: dotA);
      final count = _ringCount[ri];
      for (var i = 0; i < count; i++) {
        final ang = (i / count) * tau + rot;
        canvas.drawCircle(
          Offset(cx + math.cos(ang) * curR, cy + math.sin(ang) * curR),
          dotR,
          dotPaint,
        );
      }
    }

    // 7. 4 Counter-Orbiting Comets + Orbiting Diamond Satellites
    final cometVis = e * (1.0 - settle);
    if (cometVis > 0.01) {
      _drawComet(canvas, center, 116.0, -math.pi * 0.5 + tau * u, 1.18, 1.0, 0.90 * cometVis, 2.2);
      _drawComet(canvas, center, 116.0,  math.pi * 0.5 + tau * u, 0.88, 1.0, 0.56 * cometVis, 1.7);
      _drawComet(canvas, center,  91.0, -math.pi * 0.2 - tau * u, 0.95, -1.0, 0.66 * cometVis, 1.7);
      _drawComet(canvas, center,  67.5,  math.pi * 0.8 + tau * u * 2.0, 0.72, 1.0, 0.48 * cometVis, 1.3);

      // Two precision geometric diamond satellites orbiting softly
      _drawDiamondSatellite(canvas, center, 103.5, math.pi * 0.15 - tau * u, 3.6, 0.78 * cometVis);
      _drawDiamondSatellite(canvas, center, 103.5, math.pi * 1.15 - tau * u, 3.0, 0.55 * cometVis);
    }

    // 8. Act 3 Completion Lock Ring & Double Resolution Shockwave
    if (c > 0.005) {
      canvas.drawCircle(
        center,
        116.0,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = ink.withValues(alpha: 0.74 * (1.0 - 0.45 * settle)),
      );
      if (c < 0.98) {
        final wr1 = 48.0 + Curves.easeOutExpo.transform(c) * 76.0;
        final wa1 = math.pow(1.0 - c, 1.5) * 0.38;
        canvas.drawCircle(
          center,
          wr1,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2 * (1.0 - c) + 0.5
            ..color = ink.withValues(alpha: wa1),
        );
        if (c > 0.16) {
          final c2 = ((c - 0.16) / 0.84).clamp(0.0, 1.0);
          final wr2 = 48.0 + Curves.easeOutExpo.transform(c2) * 68.0;
          final wa2 = math.pow(1.0 - c2, 1.7) * 0.22;
          canvas.drawCircle(
            center,
            wr2,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = ink.withValues(alpha: wa2),
          );
        }
      }
    }
  }

  void _drawOctagram(Canvas canvas, Offset center, double radius, double rot, double alpha) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rot);
    final side = radius * math.sqrt2;
    final rect = Rect.fromCenter(center: Offset.zero, width: side, height: side);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..color = ink.withValues(alpha: alpha);
    canvas.drawRect(rect, p);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(rect, p);
    canvas.restore();
  }

  void _drawDiamondSatellite(
      Canvas canvas, Offset center, double radius, double ang, double r, double alpha) {
    final pos = Offset(center.dx + math.cos(ang) * radius, center.dy + math.sin(ang) * radius);
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2),
      Paint()..color = canvasColor,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = ink.withValues(alpha: alpha),
    );
    canvas.restore();
  }

  void _drawComet(Canvas canvas, Offset center, double radius, double headAngle,
      double arcLen, double dir, double maxAlpha, double strokeW) {
    const segs = 26;
    for (var i = 0; i < segs; i++) {
      final f0 = i / segs;
      final f1 = (i + 1) / segs;
      final a0 = headAngle - dir * f0 * arcLen;
      final a1 = headAngle - dir * f1 * arcLen;
      final a = maxAlpha * math.pow(1.0 - f0, 2.0);
      if (a < 0.01) continue;
      if (isDark) {
        canvas.drawLine(
          Offset(center.dx + math.cos(a0) * radius, center.dy + math.sin(a0) * radius),
          Offset(center.dx + math.cos(a1) * radius, center.dy + math.sin(a1) * radius),
          Paint()
            ..strokeWidth = strokeW * 3.0
            ..strokeCap = StrokeCap.round
            ..color = ink.withValues(alpha: a * 0.16),
        );
      }
      canvas.drawLine(
        Offset(center.dx + math.cos(a0) * radius, center.dy + math.sin(a0) * radius),
        Offset(center.dx + math.cos(a1) * radius, center.dy + math.sin(a1) * radius),
        Paint()
          ..strokeWidth = strokeW * (0.35 + 0.65 * (1.0 - f0))
          ..strokeCap = StrokeCap.round
          ..color = ink.withValues(alpha: a),
      );
    }
    final hx = center.dx + math.cos(headAngle) * radius;
    final hy = center.dy + math.sin(headAngle) * radius;
    canvas.drawCircle(Offset(hx, hy), strokeW * 1.45, Paint()..color = ink.withValues(alpha: maxAlpha));
    canvas.drawCircle(Offset(hx, hy), strokeW * 0.5, Paint()..color = canvasColor.withValues(alpha: maxAlpha));
  }

  @override
  bool shouldRepaint(_AstrolabePainter old) =>
      old.loop != loop ||
      old.entrance != entrance ||
      old.complete != complete ||
      old.still != still ||
      old.isDark != isDark ||
      old.ink != ink ||
      old.canvasColor != canvasColor;
}

/// Bilah kemajuan monokrom tipis dan tenang di bawah status teks.
class _QuietProgressTrack extends StatelessWidget {
  const _QuietProgressTrack({
    required this.loop,
    required this.complete,
    required this.still,
    required this.ink,
    required this.trackColor,
  });

  final Animation<double> loop;
  final Animation<double> complete;
  final bool still;
  final Color ink;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      height: 3,
      child: AnimatedBuilder(
        animation: Listenable.merge([loop, complete]),
        builder: (context, _) {
          final c = complete.value.clamp(0.0, 1.0);
          final u = still ? 0.35 : (loop.value * 2.0) % 1.0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: CustomPaint(
              painter: _TrackPainter(
                phase: u,
                complete: c,
                ink: ink,
                trackColor: trackColor,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.phase,
    required this.complete,
    required this.ink,
    required this.trackColor,
  });

  final double phase;
  final double complete;
  final Color ink;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = trackColor);
    if (complete > 0.01) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * Curves.easeOutCubic.transform(complete), size.height),
        Paint()..color = ink,
      );
      return;
    }
    final barW = size.width * 0.34;
    final x = -barW + (size.width + barW) * Curves.easeInOutSine.transform(phase);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, barW, size.height), const Radius.circular(999)),
      Paint()..color = ink.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.phase != phase ||
      old.complete != complete ||
      old.ink != ink ||
      old.trackColor != trackColor;
}

/// Loader folio OpenTurath (varian ringkas): empat lembaran kitab berputar tenang.
class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required this.animation,
    required this.still,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final bool still;
  double get progress => still ? 0.25 : animation.value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = progress * 2 * math.pi;
    final turn = phase;
    final breath = 0.5 - 0.5 * math.cos(phase);
    final w = size.shortestSide;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(turn);

    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 2);
      final radius = w * (0.16 + 0.07 * breath);
      final rect = Rect.fromCenter(
        center: Offset(radius, -radius),
        width: w * (0.30 - 0.05 * breath),
        height: w * (0.30 + 0.04 * breath),
      );
      final paint = Paint()
        ..isAntiAlias = true
        ..color = color.withValues(alpha: (1.0 - i * 0.16).clamp(0.2, 1.0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(w * 0.105)),
        paint,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.animation != animation || old.still != still || old.color != color;
}
