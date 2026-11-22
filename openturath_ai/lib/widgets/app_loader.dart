import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_copy.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'package:openturath_ai/core/app_platform.dart';
import 'openturath_brand.dart';

/// Loader OpenTurath adaptif (Light & Dark Mode) dengan dukungan reduced motion.
///
/// - Mode ringkas (`isFullscreen: false`): empat lembaran folio mengorbit tenang
///   untuk tombol, dialog, dan lembar bawah.
/// - Mode layar penuh (`isFullscreen: true`): medan titik konsentris imersif yang
///   memenuhi seluruh layar — selaras dengan hero `openturath.id` — memancar
///   tenang dari kotak emblem OpenTurath dengan alur Mulai → Proses → Selesai.
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
  late final AnimationController _waveController;
  late final AnimationController _entranceController;
  late final AnimationController _completeController;
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);
  Timer? _stageTimer;
  int _stageIndex = 0;

  // Periode gelombang exact (2π / 1.25 ≈ 5.0265 detik) agar loop mulus 100%
  // selaras dengan `Math.sin(r * 0.021 - t * 1.25)` pada website openturath.id.
  static const _websiteWavePeriod = Duration(milliseconds: 5027);

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: widget.isFullscreen ? _websiteWavePeriod : OTMotion.loaderLoop,
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _completeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    WidgetsBinding.instance.addObserver(this);
    _waveController.repeat();
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
    // Animasi loader WAJIB terus berjalan tanpa henti agar pengguna
    // melihat proses tetap berjalan dan tidak mengira aplikasi mengalami freeze.
    final isForeground = isDesktop ||
        state == null ||
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    // ignore: deprecated_member_use
    if (reduced || !TickerMode.of(context) || !isForeground) {
      if (_waveController.isAnimating) _waveController.stop();
      if (reduced && widget.isFullscreen) {
        _entranceController.value = 1.0;
      }
    } else if (!_waveController.isAnimating) {
      _waveController.repeat();
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
    _pointer.dispose();
    _waveController.dispose();
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

    return ColoredBox(
      color: canvas,
      child: MouseRegion(
        onHover: (event) => _pointer.value = event.localPosition,
        onExit: (_) => _pointer.value = null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Lapis 1: Medan titik simetris penuh layar (identik dengan hero openturath.id)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _DotFieldPainter(
                    wave: _waveController,
                    entrance: _entranceController,
                    complete: _completeController,
                    pointer: _pointer,
                    still: still,
                    isDark: isDark,
                    ink: ink,
                    hasText: widget.title != null || widget.subtitle != null,
                  ),
                ),
              ),
            ),

            // Lapis 2: Kotak emblem OpenTurath + tipografi tenang di tengah
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: widget.title == null
                            ? Loc.tr('loadingProcess')
                            : Loc.text(widget.title!),
                        liveRegion: true,
                        child: _EmblemTile(
                          entrance: _entranceController,
                          complete: _completeController,
                          still: still,
                          isDark: isDark,
                          ink: ink,
                          surface: surface,
                          canvasColor: canvas,
                        ),
                      ),
                      if (widget.title != null) ...[
                        const SizedBox(height: 28),
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
                      if (widget.onCancel != null) ...[
                        const SizedBox(height: 28),
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
                ),
              ),
            ),
          ],
        ),
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
                  animation: _waveController,
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

/// Kotak emblem OpenTurath minimalis (selaras dengan hero-mark di openturath.id).
class _EmblemTile extends StatelessWidget {
  const _EmblemTile({
    required this.entrance,
    required this.complete,
    required this.still,
    required this.isDark,
    required this.ink,
    required this.surface,
    required this.canvasColor,
  });

  final Animation<double> entrance;
  final Animation<double> complete;
  final bool still;
  final bool isDark;
  final Color ink;
  final Color surface;
  final Color canvasColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([entrance, complete]),
      builder: (context, _) {
        final e = still
            ? 1.0
            : Curves.easeOutCubic
                .transform((entrance.value / 0.55).clamp(0.0, 1.0));
        final c = complete.value.clamp(0.0, 1.0);
        final pop = math.sin(c * math.pi) * 0.045;
        final scale = (0.86 + 0.14 * e) + pop;

        return Opacity(
          opacity: e,
          child: Transform.scale(
            scale: scale,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: OTRadius.cardBorder,
                    border: Border.all(
                      color: ink.withValues(alpha: isDark ? 0.14 : 0.08),
                      width: 1.0,
                    ),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: OTColors.shadow.withValues(alpha: 0.55),
                              blurRadius: 36,
                              offset: const Offset(0, 14),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: OTColors.shadow.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                            BoxShadow(
                              color: OTColors.shadow.withValues(alpha: 0.10),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                  ),
                  child: Center(
                    child: OpenTurathMark(size: 46, color: ink),
                  ),
                ),
                if (c > 0.08)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Transform.scale(
                      scale: Curves.easeOutBack.transform(c),
                      child: Container(
                        width: 24,
                        height: 24,
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
            ),
          ),
        );
      },
    );
  }
}

/// Medan titik konsentris penuh layar — terinspirasi langsung dari `site.js`
/// di `openturath.id`: cincin titik simetris berselang-seling yang bergelombang
/// pelan keluar dari pusat emblem, dengan alur Mulai (ekspansi keluar) dan
/// Selesai (sapuan akhir lalu tenang).
class _DotFieldPainter extends CustomPainter {
  _DotFieldPainter({
    required this.wave,
    required this.entrance,
    required this.complete,
    required this.pointer,
    required this.still,
    required this.isDark,
    required this.ink,
    required this.hasText,
  }) : super(repaint: Listenable.merge([wave, entrance, complete, pointer]));

  final Animation<double> wave;
  final Animation<double> entrance;
  final Animation<double> complete;
  final ValueNotifier<Offset?> pointer;
  final bool still;
  final bool isDark;
  final Color ink;
  final bool hasText;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    const tau = math.pi * 2.0;
    final isCompact = w < 760;
    final gap = isCompact ? 26.0 : 32.0;
    final cx = w * 0.5;
    // Pusatkan titik tepat di kotak emblem (sedikit di atas tengah bila ada teks)
    final cy = hasText ? h * 0.5 - 52.0 : h * 0.5;
    final rMax = math.sqrt(
          math.pow(math.max(cx, w - cx), 2) + math.pow(math.max(cy, h - cy), 2),
        ) +
        gap;

    // Fase gelombang sin(r * 0.021 - phase) — persis rumus website openturath.id
    final phase = still ? 0.0 : wave.value * tau;
    final mv = still ? 0.0 : 1.0;

    // Babak 1 (Mulai): jangkauan ekspansi cincin dari pusat hingga sudut layar
    final e = still ? 1.0 : Curves.easeOutCubic.transform(entrance.value);
    final reach = still ? rMax : (rMax * (0.08 + 0.92 * e));

    // Babak 3 (Selesai): sapuan gelombang penutup halus lalu mereda tenang
    final c = complete.value.clamp(0.0, 1.0);
    final settle = Curves.easeOutCubic.transform(c);
    final finishRing = c > 0.005 ? (60.0 + Curves.easeOutExpo.transform(c) * rMax) : -1.0;

    // Sorot kursor & paralaks kedalaman lembut (hanya saat ada pointer di desktop)
    final ptr = pointer.value;
    final hasPtr = ptr != null && !still;
    final offX = hasPtr ? ((ptr.dx - w * 0.5) / w) * -18.0 : 0.0;
    final offY = hasPtr ? ((ptr.dy - h * 0.5) / h) * -18.0 : 0.0;
    final spotR = isCompact ? 150.0 : 220.0;
    final spotR2 = spotR * spotR;

    // Zona pelindung keterbacaan di sekitar teks judul & subjudul
    final textZone = hasText
        ? Rect.fromCenter(
            center: Offset(cx, cy + 104.0),
            width: math.min(w - 48.0, 340.0),
            height: 118.0,
          )
        : null;

    final paint = Paint()..isAntiAlias = true;
    final halfDiag = math.sqrt(w * w + h * h) * 0.5;
    final baseDim = isDark ? 0.88 : 1.0;

    for (var k = 3; k * gap < rMax; k++) {
      final rr = k * gap;
      if (rr > reach) break;

      final n = math.max(12, ((tau * rr / gap) / 2.0).round() * 2);
      final stagger = k.isOdd ? (math.pi / n) : 0.0;

      // Gelombang tenang mengalir keluar dari emblem
      final waveVal = math.sin(rr * 0.021 - phase);
      final amp = (1.0 - 0.75 * settle) * mv;
      final rad = rr + waveVal * 3.2 * amp;
      final depth = 0.35 + rr / halfDiag;

      final fadeInCenter = (rr / 135.0).clamp(0.0, 1.0);
      final edgeSoft = ((reach - rr) / 90.0).clamp(0.0, 1.0);
      final baseSize = (0.9 + rr / 900.0 + (waveVal + 1.0) * 0.45) *
          (isCompact ? 0.85 : 1.0);

      // Peningkatan kilau halus ketika gelombang "Selesai" melintas cincin ini
      double finishBoost = 0.0;
      if (finishRing > 0) {
        final dist = (rr - finishRing).abs();
        if (dist < 120.0) {
          finishBoost = math.exp(-(dist * dist) / (58.0 * 58.0)) * (1.0 - c) * 0.45;
        }
      }

      for (var i = 0; i < n; i++) {
        final ang = (i / n) * tau + stagger;
        final x = cx + math.cos(ang) * rad + offX * depth;
        final y = cy + math.sin(ang) * rad + offY * depth;
        if (x < -6 || x > w + 6 || y < -6 || y > h + 6) continue;

        double g = 0.0;
        if (hasPtr) {
          final dx = x - ptr.dx;
          final dy = y - ptr.dy;
          final d2 = dx * dx + dy * dy;
          if (d2 < spotR2 * 3.0) {
            g = math.exp(-d2 / spotR2);
          }
        }

        // Redupkan titik tepat di belakang teks agar selalu terbaca bersih
        double shade = 1.0;
        if (textZone != null && textZone.contains(Offset(x, y))) {
          shade = 0.14;
        }

        final sz = baseSize * (1.0 + g * 0.75 + finishBoost * 0.6);
        final rawAlpha = (0.18 + (waveVal + 1.0) * 0.24 + g * 0.46 + finishBoost) *
            fadeInCenter *
            edgeSoft *
            shade *
            baseDim *
            (1.0 - 0.35 * settle);
        final alpha = rawAlpha.clamp(0.0, 0.92);
        if (alpha <= 0.008) continue;

        paint.color = ink.withValues(alpha: alpha);
        canvas.drawCircle(Offset(x, y), sz, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotFieldPainter old) =>
      old.wave != wave ||
      old.entrance != entrance ||
      old.complete != complete ||
      old.pointer != pointer ||
      old.still != still ||
      old.isDark != isDark ||
      old.ink != ink ||
      old.hasText != hasText;
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
