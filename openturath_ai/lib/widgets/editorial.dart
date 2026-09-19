import '../core/l10n/app_dictionary.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import 'apple_interactive_wrapper.dart';

bool _dark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

/// Shared page rhythm. Reading screens pass maxWidth: 720.
class EditorialPage extends StatelessWidget {
  const EditorialPage({super.key, required this.children, this.title, this.eyebrow,
    this.subtitle, this.trailing, this.showBack = false, this.maxWidth = 1100});
  final List<Widget> children;
  final String? title, eyebrow, subtitle;
  final Widget? trailing;
  final bool showBack;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
      final gutter = constraints.maxWidth >= 800 ? 40.0 : 24.0;
      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsetsDirectional.fromSTEB(gutter, 20, gutter, 40),
        child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (title != null) ...[
              EditorialHeader(title: title!, eyebrow: eyebrow, subtitle: subtitle,
                trailing: trailing, showBack: showBack),
              const SizedBox(height: 32),
            ],
            ...children,
          ]),
        )),
      );
    })),
  );
}

class EditorialHeader extends StatelessWidget {
  const EditorialHeader({super.key, required this.title, this.eyebrow,
    this.subtitle, this.trailing, this.showBack = false});
  final String title;
  final String? eyebrow, subtitle;
  final Widget? trailing;
  final bool showBack;
  @override
  Widget build(BuildContext context) {
    final dark = _dark(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (showBack) Padding(padding: const EdgeInsets.only(bottom: 12),
        child: IconButton(tooltip: MaterialLocalizations.of(context).backButtonTooltip, onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded))),
      if (eyebrow != null) ...[
        Text(eyebrow!, style: OTTypography.sectionHeading(color: OTColors.textSecondary(dark))),
        const SizedBox(height: 10),
      ],
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(child: Semantics(header: true, child: Text(title,
          style: OTTypography.displayLarge(color: OTColors.textPrimary(dark)).copyWith(fontSize: 32, height: context.languageCode == 'ar' ? 1.85 : 1.16)))),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ]),
      if (subtitle != null) ...[
        const SizedBox(height: 10),
        Text(subtitle!, style: OTTypography.body(color: OTColors.textSecondary(dark)).copyWith(height: context.languageCode == 'ar' ? 1.85 : 1.6)),
      ],
    ]);
  }
}

class EditorialSection extends StatelessWidget {
  const EditorialSection({super.key, required this.title, this.trailing, required this.child});
  final String title;
  final Widget? trailing;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [Expanded(child: Semantics(header: true, child: Text(title,
        style: OTTypography.bookTitle(color: OTColors.textPrimary(_dark(context)))))),
        if (trailing != null) trailing!]),
      const SizedBox(height: 16), child,
    ]),
  );
}

class EditorialRow extends StatelessWidget {
  const EditorialRow({super.key, required this.title, this.subtitle, this.leading,
    this.trailing, this.onTap, this.selected = false});
  final String title;
  final String? subtitle;
  final Widget? leading, trailing;
  final VoidCallback? onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final dark = _dark(context);
    return AppleInteractiveWrapper(onTap: onTap, semanticLabel: null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? OTColors.surfaceSubtle(dark) : null,
          border: Border(bottom: BorderSide(color: OTColors.border(dark), width: 0.8))),
        child: Row(children: [
          if (leading != null) ...[IconTheme(data: IconThemeData(size: 21,
            color: OTColors.textSecondary(dark)), child: leading!), const SizedBox(width: 16)],
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: OTTypography.bodyMedium(color: OTColors.textPrimary(dark)).copyWith(fontSize: 15)),
            if (subtitle != null) ...[const SizedBox(height: 5), Text(subtitle!,
              style: OTTypography.caption(color: OTColors.textSecondary(dark)).copyWith(height: context.languageCode == 'ar' ? 1.85 : 1.5))],
          ])),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!]
          else if (onTap != null) ...[const SizedBox(width: 12), Icon(Icons.chevron_right_rounded,
            size: 20, color: OTColors.textSecondary(dark))],
        ]),
      ),
    );
  }
}

class EditorialButton extends StatelessWidget {
  const EditorialButton({super.key, required this.label, this.onPressed,
    this.icon, this.secondary = false, this.busy = false, this.expanded = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary, busy, expanded;
  @override
  Widget build(BuildContext context) {
    final dark = _dark(context);
    final enabled = onPressed != null && !busy;
    final foreground = secondary ? OTColors.textPrimary(dark) : OTColors.onAccent(dark);
    return Semantics(button: true, enabled: enabled, label: busy ? '$label, ${context.tr('Sedang memuat')}' : null,
      child: AppleInteractiveWrapper(onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(opacity: enabled || busy ? 1 : .45,
          child: Container(
            width: expanded ? double.infinity : null,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(color: secondary ? Colors.transparent : OTColors.accent(dark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: secondary ? OTColors.borderStrong(dark) : OTColors.accent(dark), width: .8)),
            child: Row(mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, children: [
                if (busy) ...[SizedBox(width: 18, height: 18, child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: foreground)), const SizedBox(width: 10)]
                else if (icon != null) ...[Icon(icon, size: 18, color: foreground), const SizedBox(width: 10)],
                Flexible(child: Text(label, textAlign: TextAlign.center,
                  style: OTTypography.button(color: foreground))),
              ]),
          ),
        ),
      ),
    );
  }
}

class EditorialSearchField extends StatefulWidget {
  const EditorialSearchField({super.key, this.controller, this.onChanged, this.hintText = 'Cari...'});
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  @override
  State<EditorialSearchField> createState() => _EditorialSearchFieldState();
}
class _EditorialSearchFieldState extends State<EditorialSearchField> {
  late final TextEditingController _owned = TextEditingController();
  TextEditingController get _controller => widget.controller ?? _owned;
  @override
  void dispose() { _owned.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<TextEditingValue>(
    valueListenable: _controller,
    builder: (context, value, _) => TextField(
      controller: _controller, onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: OTTypography.body(color: OTColors.textPrimary(_dark(context))),
      decoration: InputDecoration(hintText: context.tr(widget.hintText),
        prefixIcon: const Icon(Icons.search_rounded, size: 21),
        suffixIcon: value.text.isEmpty ? null : IconButton(tooltip: context.tr('Hapus pencarian'),
          onPressed: () { _controller.clear(); widget.onChanged?.call(''); },
          icon: const Icon(Icons.close_rounded, size: 18))),
    ),
  );
}

class EditorialEmptyState extends StatelessWidget {
  const EditorialEmptyState({super.key, required this.title, this.description, this.action});
  final String title;
  final String? description;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.menu_book_outlined, size: 28, color: OTColors.textSecondary(_dark(context))),
      const SizedBox(height: 20), Text(title, textAlign: TextAlign.center,
        style: OTTypography.bookTitle(color: OTColors.textPrimary(_dark(context)))),
      if (description != null) ...[const SizedBox(height: 10), Text(description!, textAlign: TextAlign.center,
        style: OTTypography.body(color: OTColors.textSecondary(_dark(context))))],
      if (action != null) ...[const SizedBox(height: 24), action!],
    ]),
  );
}

class EditorialReveal extends StatefulWidget {
  const EditorialReveal({super.key, required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;
  @override
  State<EditorialReveal> createState() => _EditorialRevealState();
}
class _EditorialRevealState extends State<EditorialReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this,
    duration: const Duration(milliseconds: 280));
  Timer? _timer;
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _timer?.cancel(); _controller.value = 1; _started = true;
    } else if (!_started) {
      _started = true;
      _timer = Timer(widget.delay, () { if (mounted) _controller.forward(); });
    }
  }
  @override
  void dispose() { _timer?.cancel(); _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _controller,
    child: AnimatedBuilder(animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 6 * (1 - Curves.easeOutCubic.transform(_controller.value))), child: child),
      child: widget.child));
}

class EditorialArabicText extends StatelessWidget {
  const EditorialArabicText(this.text, {super.key, this.fontSize = 24,
    this.color, this.textAlign = TextAlign.start});
  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign textAlign;
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl,
    child: Text(text, textAlign: textAlign,
      style: OTTypography.arabicReading(color: color ?? OTColors.textPrimary(_dark(context)), height: 1.9)
        .copyWith(fontSize: fontSize, fontStyle: FontStyle.normal),
      textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: true)));
}

class EditorialCard extends StatelessWidget {
  const EditorialCard({super.key, required this.child,
    this.padding = const EdgeInsets.all(20), this.inverse = false});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool inverse;
  @override
  Widget build(BuildContext context) {
    final dark = _dark(context);
    return Container(padding: padding,
      decoration: BoxDecoration(color: inverse ? OTColors.inverseSurface(dark) : OTColors.surface(dark),
        borderRadius: BorderRadius.circular(12), border: Border.all(color: OTColors.border(dark), width: .8)),
      child: inverse ? DefaultTextStyle.merge(style: const TextStyle(color: OTColors.onInverseSurface),
        child: IconTheme(data: const IconThemeData(color: OTColors.onInverseSurface), child: child)) : child);
  }
}
