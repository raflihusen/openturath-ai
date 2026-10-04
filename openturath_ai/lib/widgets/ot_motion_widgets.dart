import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import 'apple_interactive_wrapper.dart';

import 'package:openturath_ai/core/design/ot_radius.dart';
/// Animasi masuk yang tenang: memudar sambil naik beberapa piksel.
/// [index] memberi jeda berurutan antar-ubin. Tanpa timer, jadi aman di tes,
/// dan otomatis nonaktif bila pengguna meminta gerak dikurangi.
class OTReveal extends StatefulWidget {
  const OTReveal({super.key, this.index = 0, required this.child});

  final int index;
  final Widget child;

  @override
  State<OTReveal> createState() => _OTRevealState();
}

class _OTRevealState extends State<OTReveal>
    with SingleTickerProviderStateMixin {
  static const _base = 360;
  static const _stagger = 45;

  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final delay = widget.index.clamp(0, 8) * _stagger;
    final total = _base + delay;
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: total));
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay / total, 1, curve: OTMotion.curve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _progress.value) * 10),
          child: child,
        ),
      ),
    );
  }
}

/// Memudarkan konten setiap kali [active] berubah menjadi true.
/// Dipakai untuk pergantian tab agar halaman tidak meluncur melewati tab lain.
class OTActiveFade extends StatefulWidget {
  const OTActiveFade({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<OTActiveFade> createState() => _OTActiveFadeState();
}

class _OTActiveFadeState extends State<OTActiveFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: OTMotion.normal, value: 1);
  late final Animation<double> _progress =
      CurvedAnimation(parent: _controller, curve: OTMotion.curve);

  @override
  void didUpdateWidget(OTActiveFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _progress.value) * 6),
          child: child,
        ),
      ),
    );
  }
}

/// Ubin bento: sudut 16, garis tipis, tanpa bayangan. Garis menegas saat
/// kursor di atasnya. [inverse] dipakai untuk satu ubin fokus per layar.
class OTBentoTile extends StatefulWidget {
  const OTBentoTile({
    super.key,
    required this.child,
    this.onTap,
    this.inverse = false,
    this.padding = const EdgeInsets.all(OTSpacing.base),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool inverse;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  static const double radius = 16;

  @override
  State<OTBentoTile> createState() => _OTBentoTileState();
}

class _OTBentoTileState extends State<OTBentoTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final interactive = widget.onTap != null;
    final background = widget.inverse
        ? OTColors.inverseSurface(isDark)
        : OTColors.surface(isDark);
    final border = widget.inverse
        ? (isDark ? OTColors.border(isDark) : background)
        : (_hovered && interactive
            ? OTColors.borderStrong(isDark)
            : OTColors.border(isDark));

    final tile = AnimatedContainer(
      duration: OTMotion.fast,
      curve: OTMotion.curve,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(OTBentoTile.radius),
        border: Border.all(color: border),
      ),
      child: widget.child,
    );
    if (!interactive) return tile;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AppleInteractiveWrapper(
        onTap: widget.onTap,
        pressedScale: 0.985,
        borderRadius: BorderRadius.circular(OTBentoTile.radius),
        semanticLabel: widget.semanticLabel,
        child: tile,
      ),
    );
  }
}

/// Kerangka statis saat data dimuat: menjaga tata letak tanpa indikator berputar.
class OTSkeletonList extends StatelessWidget {
  const OTSkeletonList({super.key, this.count = 4, this.tileHeight = 96});

  final int count;
  final double tileHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final block = OTColors.surfaceSubtle(isDark);
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: block, borderRadius: BorderRadius.circular(OTRadius.xs)),
        );
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(OTSpacing.lg),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: OTSpacing.md),
        itemBuilder: (context, index) => OTReveal(
          index: index,
          child: Container(
            height: tileHeight,
            padding: const EdgeInsets.all(OTSpacing.base),
            decoration: BoxDecoration(
              color: OTColors.surface(isDark),
              borderRadius: BorderRadius.circular(OTBentoTile.radius),
              border: Border.all(color: OTColors.border(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [bar(180, 16), bar(260, 10), bar(120, 10)],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu dua sisi yang berbalik saat diketuk. Tanpa animasi bila gerak dikurangi.
class OTFlipCard extends StatefulWidget {
  const OTFlipCard({
    super.key,
    required this.front,
    required this.back,
    this.semanticLabel,
  });

  final Widget front;
  final Widget back;
  final String? semanticLabel;

  @override
  State<OTFlipCard> createState() => _OTFlipCardState();
}

class _OTFlipCardState extends State<OTFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _turn =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

  void _toggle() {
    OTMotion.selection();
    final showBack = _controller.value < 0.5;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = showBack ? 1 : 0;
    } else if (showBack) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  /// Posisi kursor di atas kartu, -1..1 pada tiap sumbu; nol saat di luar.
  Offset _lean = Offset.zero;
  static const _maxLean = 0.07; // sekitar 4 derajat

  void _follow(PointerEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(event.position);
    setState(() => _lean = Offset(
          (local.dx / box.size.width * 2 - 1).clamp(-1.0, 1.0),
          (local.dy / box.size.height * 2 - 1).clamp(-1.0, 1.0),
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: still ? null : _follow,
        onExit: (_) => setState(() => _lean = Offset.zero),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(end: _lean),
            duration: OTMotion.fast,
            curve: OTMotion.curve,
            builder: (context, lean, _) => AnimatedBuilder(
              animation: _turn,
              builder: (context, _) {
                final angle = _turn.value * 3.141592653589793;
                final showBack = _turn.value >= 0.5;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    // Kartu miring mengikuti kursor, lalu berbalik saat diketuk.
                    ..rotateX(-lean.dy * _maxLean)
                    ..rotateY(lean.dx * _maxLean + angle),
                  child: showBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(3.141592653589793),
                          child: widget.back,
                        )
                      : widget.front,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Chevron "buka" yang mengikuti arah baca: › di LTR, ‹ di RTL.
IconData otChevronIcon(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
        ? Icons.chevron_left_rounded
        : Icons.chevron_right_rounded;

/// Jarak judul [AppBar]: rapat ke tombol kembali; tanpa tombol kembali,
/// judul sejajar dengan tepi isi halaman.
double otTitleSpacing(BuildContext context) =>
    (ModalRoute.of(context)?.canPop ?? false) ? 0 : 20;
