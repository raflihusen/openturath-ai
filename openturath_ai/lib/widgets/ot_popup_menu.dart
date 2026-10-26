import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';

/// Item menu popup gaya OpenTurath. Sorotan saat kursor di atasnya berbentuk
/// kapsul inset (bukan persegi penuh yang menabrak sudut menu), berwarna
/// monokrom, dan mengikuti terang/gelap.
///
/// Dipakai menggantikan [PopupMenuItem] di semua menu titik tiga.
class OTPopupMenuItem<T> extends PopupMenuEntry<T> {
  const OTPopupMenuItem({
    super.key,
    required this.value,
    required this.child,
    this.enabled = true,
    this.height = kMinInteractiveDimension,
  });

  final T value;
  final Widget child;
  final bool enabled;

  @override
  final double height;

  @override
  bool represents(T? value) => value == this.value;

  @override
  State<OTPopupMenuItem<T>> createState() => _OTPopupMenuItemState<T>();
}

class _OTPopupMenuItemState<T> extends State<OTPopupMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    return Semantics(
      button: true,
      enabled: widget.enabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.sm, vertical: OTSpacing.xxs),
        child: InkWell(
          onTap: widget.enabled
              ? () => Navigator.pop<T>(context, widget.value)
              : null,
          canRequestFocus: widget.enabled,
          borderRadius: BorderRadius.circular(OTRadius.chip),
          hoverColor: ink.withValues(alpha: dark ? 0.08 : 0.05),
          focusColor: ink.withValues(alpha: dark ? 0.10 : 0.07),
          highlightColor: ink.withValues(alpha: dark ? 0.12 : 0.08),
          splashColor: ink.withValues(alpha: dark ? 0.10 : 0.06),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: widget.height - OTSpacing.xxs * 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: OTSpacing.base),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 1,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
