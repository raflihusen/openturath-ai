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

/// Loader OpenTurath adaptif (Light & Dark Mode) dengan dukungan reduced motion.
///
/// - Mode ringkas (`isFullscreen: false`): empat lembaran folio mengorbit tenang,
///   cocok untuk tombol, dialog, dan lembar bawah.
/// - Mode layar penuh (`isFullscreen: true`): astrolab monokrom OpenTurath 3 babak
///   (Mulai → Proses → Selesai) dengan emblem resmi, cincin titik konsentris,
///   oktagram geometris, komet orbit, dan status teks bergilir yang tenang.
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
          ? const Duration(milliseconds: 6000)
          : OTMotion.loaderLoop,
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _completeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
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
                borderColor: border,
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
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.18),
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

/// Centerpiece astrolab monokrom OpenTurath untuk mode layar penuh (Light & Dark Mode).
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
    required this.borderColor,
  });

  final Animation<double> loop;
  final Animation<double> entrance;
  final Animation<double> complete;
  final bool still;
  final bool isDark;
  final Color ink;
  final Color surface;
  final Color canvasColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final merged = Listenable.merge([loop, entrance, complete]);
    return SizedBox.square(
      dimension: 224,
      child: AnimatedBuilder(
        animation: merged,
        builder: (context, child) {
          final e = still ? 1.0 : Curves.easeOutBack.transform(entrance.value.clamp(0.0, 1.0));
          final c = complete.value.clamp(0.0, 1.0);
          final u = still ? 0.25 : loop.value;
          final breath = still ? 0.0 : (1.0 - c) * 0.022 * math.sin(u * math.pi * 4);
          final donePop = math.sin(c * math.pi) * 0.06;
          final tileScale = (0.76 + 0.24 * e) + breath + donePop;

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
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: isDark ? surface : surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? ink.withValues(alpha: 0.20 + 0.16 * c)
                          : ink.withValues(alpha: 0.10 + 0.22 * c),
                      width: 1.2 + 0.5 * c,
                    ),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: ink.withValues(alpha: 0.10 + 0.06 * c),
                              blurRadius: 28,
                              spreadRadius: 1,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: OTColors.shadow.withValues(alpha: 0.11),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: OTColors.shadow.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: OpenTurathMark(size: 40, color: ink),
                  ),
                ),
              ),
              if (c > 0.05)
                Positioned(
                  right: 68,
                  top: 68,
                  child: Transform.scale(
                    scale: Curves.easeOutBack.transform(c),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: ink,
                        shape: BoxShape.circle,
                        border: Border.all(color: canvasColor, width: 2.2),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: OTColors.onAccent(isDark),
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

  static const _ringR = [54.0, 66.0, 78.0, 91.0, 104.0];
  static const _ringCount = [24, 32, 40, 48, 56];
  static const _ringDot = [1.55, 1.4, 1.25, 1.1, 0.95];

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

    // 1. Subtle radial ambient halo behind emblem (mode-aware)
    if (isDark) {
      final haloPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            ink.withValues(alpha: 0.14 * e),
            ink.withValues(alpha: 0.04 * e),
            ink.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: 108));
      canvas.drawCircle(center, 108, haloPaint);
    }

    // 2. Act 1 Ignition Shockwave Ring
    if (!still && entrance.value > 0.08 && entrance.value < 0.96) {
      final wp = ((entrance.value - 0.08) / 0.88).clamp(0.0, 1.0);
      final wr = 26.0 + Curves.easeOutExpo.transform(wp) * 86.0;
      final wa = (1.0 - wp) * (isDark ? 0.22 : 0.18);
      canvas.drawCircle(
        center,
        wr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 * (1.0 - wp) + 0.4
          ..color = ink.withValues(alpha: wa),
      );
    }

    // 3. Dual counter-rotating Islamic geometric octagram hairlines
    final octAlpha = (isDark ? 0.11 : 0.085) * e * (1.0 - 0.45 * settle);
    if (octAlpha > 0.002) {
      _drawOctagram(canvas, center, 86.0 * (0.88 + 0.12 * e), u * tau * 0.25, octAlpha);
      _drawOctagram(canvas, center, 66.0 * (0.88 + 0.12 * e), -u * tau * 0.25, octAlpha * 0.85);
    }

    // 4. Outer astrolabe track + 48 precision compass ticks
    final dialAlpha = (isDark ? 0.13 : 0.11) * e;
    canvas.drawCircle(
      center,
      106.0,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = ink.withValues(alpha: dialAlpha),
    );
    for (var i = 0; i < 48; i++) {
      final ang = (i / 48) * tau - math.pi / 2;
      final isCard = i % 12 == 0;
      final isMid = i % 4 == 0;
      final rIn = isCard ? 101.0 : (isMid ? 103.5 : 105.0);
      final rOut = isCard ? 111.0 : (isMid ? 108.5 : 107.2);
      final a = (isCard ? 0.38 : (isMid ? 0.20 : 0.10)) * e * (isCard ? 1.0 : (1.0 - 0.5 * settle));
      canvas.drawLine(
        Offset(cx + math.cos(ang) * rIn, cy + math.sin(ang) * rIn),
        Offset(cx + math.cos(ang) * rOut, cy + math.sin(ang) * rOut),
        Paint()
          ..strokeWidth = isCard ? 1.2 : 0.8
          ..strokeCap = StrokeCap.round
          ..color = ink.withValues(alpha: a),
      );
    }

    // 5. 5 Concentric OpenTurath Dot-Rings with harmonic thinking wave
    for (var ri = 0; ri < _ringR.length; ri++) {
      final rDelay = ri * 0.11;
      final rIn = still ? 1.0 : Curves.easeOutExpo.transform(((entrance.value - rDelay) / (1.0 - rDelay)).clamp(0.0, 1.0));
      if (rIn <= 0.005) continue;

      final wavePhase = ((u * 2.0 - ri * 0.12) % 1.0 + 1.0) % 1.0;
      final pulse = math.exp(-math.pow((wavePhase - 0.22) * 5.6, 2.0)) * activeAmp;
      final dir = ri.isEven ? 1.0 : -1.0;
      final rot = dir * (tau / _ringCount[ri]) * (ri.isEven ? 2.0 : 1.0) * u;
      final curR = _ringR[ri] * (0.84 + 0.16 * rIn) + pulse * 2.4 + settle * (ri * 0.8);
      final baseA = ((isDark ? 0.52 : 0.44) - ri * 0.065) * rIn;
      final dotA = ((baseA + pulse * 0.36) * (1.0 - 0.58 * settle)).clamp(0.0, 1.0);
      final dotR = _ringDot[ri] * (1.0 + 0.42 * pulse) * (1.0 - 0.2 * settle);

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

    // 6. Counter-orbiting luminous/ink comet arcs (fade out cleanly on completion)
    final cometVis = e * (1.0 - settle);
    if (cometVis > 0.01) {
      _drawComet(canvas, center, 106.0, -math.pi * 0.5 + tau * u, 1.15, 1.0, 0.88 * cometVis, 2.1);
      _drawComet(canvas, center, 106.0,  math.pi * 0.5 + tau * u, 0.85, 1.0, 0.56 * cometVis, 1.7);
      _drawComet(canvas, center,  78.0, -math.pi * 0.2 - tau * u, 0.90, -1.0, 0.62 * cometVis, 1.6);
    }

    // 7. Act 3 Completion Lock Ring & Resolution Shockwave
    if (c > 0.005) {
      canvas.drawCircle(
        center,
        106.0,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = ink.withValues(alpha: 0.72 * (1.0 - 0.45 * settle)),
      );
      if (c < 0.98) {
        final wr = 46.0 + Curves.easeOutExpo.transform(c) * 68.0;
        final wa = math.pow(1.0 - c, 1.5) * 0.36;
        canvas.drawCircle(
          center,
          wr,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2 * (1.0 - c) + 0.5
            ..color = ink.withValues(alpha: wa),
        );
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

  void _drawComet(Canvas canvas, Offset center, double radius, double headAngle,
      double arcLen, double dir, double maxAlpha, double strokeW) {
    const segs = 24;
    for (var i = 0; i < segs; i++) {
      final f0 = i / segs;
      final f1 = (i + 1) / segs;
      final a0 = headAngle - dir * f0 * arcLen;
      final a1 = headAngle - dir * f1 * arcLen;
      final a = maxAlpha * math.pow(1.0 - f0, 2.0);
      if (a < 0.01) continue;
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
    canvas.drawCircle(Offset(hx, hy), strokeW * 1.35, Paint()..color = ink.withValues(alpha: maxAlpha));
    canvas.drawCircle(Offset(hx, hy), strokeW * 0.45, Paint()..color = canvasColor.withValues(alpha: maxAlpha));
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
      width: 132,
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
