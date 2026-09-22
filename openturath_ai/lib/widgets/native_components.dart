import 'dart:async';
import 'package:flutter/material.dart';
import '../core/design/native_design.dart';
import '../core/localization.dart';

/// Opt-in controls for native pages; never used by the AI room.
class NativePress extends StatefulWidget {
  const NativePress({super.key, required this.child, this.onTap, this.label});
  final Widget child;
  final VoidCallback? onTap;
  final String? label;
  @override
  State<NativePress> createState() => _NativePressState();
}

class _NativePressState extends State<NativePress> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: widget.label,
      button: widget.onTap != null,
      child: AnimatedScale(
        scale: _pressed && !reduce ? .985 : 1,
        duration: reduce ? Duration.zero : const Duration(milliseconds: 140),
        curve: const Cubic(.16, 1, .3, 1),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: BorderRadius.circular(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class NativeSection extends StatelessWidget {
  const NativeSection(
      {super.key,
      required this.child,
      this.collection = false,
      this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final bool collection;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: collection
            ? NativeColors.collection(dark)
            : NativeColors.surface(dark),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(collection ? 40 : 28),
          side: BorderSide(
              color: collection
                  ? NativeColors.brass(dark).withValues(alpha: .35)
                  : NativeColors.border(dark),
              width: .8),
        ),
      ),
      child: child,
    );
  }
}

class NativeSearch extends StatelessWidget {
  const NativeSearch(
      {super.key,
      required this.controller,
      required this.hint,
      required this.onChanged});
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: NativeType.body(dark),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: NativeType.meta(dark),
        filled: true,
        fillColor: NativeColors.surface(dark),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip:
                      MaterialLocalizations.of(context).deleteButtonTooltip,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: NativeColors.border(dark))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide:
                BorderSide(color: NativeColors.textPrimary(dark), width: 1.5)),
      ),
    );
  }
}

class NativeLoading extends StatefulWidget {
  const NativeLoading({super.key, this.label});
  final String? label;
  @override
  State<NativeLoading> createState() => _NativeLoadingState();
}

class _NativeLoadingState extends State<NativeLoading> {
  Timer? _timer;
  bool _slow = false;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (MediaQuery.disableAnimationsOf(context))
            Icon(Icons.hourglass_empty_rounded,
                color: NativeColors.textSecondary(dark))
          else
            SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: NativeColors.textSecondary(dark))),
          const SizedBox(height: 16),
          Text(widget.label ?? NativeCopy.text('loading'),
              style: NativeType.meta(dark), textAlign: TextAlign.center),
          if (_slow) ...[
            const SizedBox(height: 8),
            Text(NativeCopy.text('slow'),
                style: NativeType.meta(dark), textAlign: TextAlign.center)
          ],
        ]),
      ),
    );
  }
}

class NativeEmpty extends StatelessWidget {
  const NativeEmpty(
      {super.key,
      required this.title,
      this.detail,
      this.onAction,
      this.action,
      this.icon = Icons.menu_book_outlined});
  final String title;
  final String? detail;
  final VoidCallback? onAction;
  final String? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 32, color: NativeColors.textSecondary(dark)),
          const SizedBox(height: 16),
          Text(title,
              style: NativeType.title(dark, size: 22),
              textAlign: TextAlign.center),
          if (detail != null) ...[
            const SizedBox(height: 8),
            Text(detail!,
                style: NativeType.meta(dark), textAlign: TextAlign.center)
          ],
          if (onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton(
                onPressed: onAction,
                child: Text(action ?? NativeCopy.text('retry')))
          ],
        ]));
  }
}

class NativeEntrance extends StatelessWidget {
  const NativeEntrance({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: const Cubic(.16, 1, .3, 1),
      builder: (_, value, child) => Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
              offset: Offset(0, 8 * (1 - value)), child: child)),
      child: child,
    );
  }
}
