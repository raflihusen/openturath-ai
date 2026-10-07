import 'package:flutter/material.dart';
import '../core/design/ot_expressive.dart';
import '../core/design/ot_radius.dart';
import '../core/scholarly_fonts.dart';
import '../core/design/ot_typography.dart';

/// A quiet Arabic watermark remains decorative; actions retain their own focus.
class OTInkCard extends StatelessWidget {
  const OTInkCard({super.key, required this.child, this.watermark = '', this.onTap, this.semanticLabel, this.padding = const EdgeInsets.all(24)});
  final Widget child;
  final String watermark;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: Material(color: OTExpressive.hero, borderRadius: OTRadius.cardBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Stack(children: [
        if (watermark.isNotEmpty) Positioned.fill(child: IgnorePointer(child: ExcludeSemantics(
          child: Align(alignment: Alignment.bottomRight, child: Padding(
            padding: const EdgeInsets.only(right: 16), child: Text(watermark,
            textDirection: TextDirection.rtl, maxLines: 1,
            style: ScholarlyFonts.scheherazadeNew(fontSize: OTFontSize.s64,
              height: 1.1, color: OTExpressive.white.withValues(alpha: .10)))))))),
        Padding(padding: padding, child: child),
      ])),
    ),
  );
}
