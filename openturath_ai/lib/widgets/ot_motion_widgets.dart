import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import 'apple_interactive_wrapper.dart';

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
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: OTMotion.normal, value: 1);
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
