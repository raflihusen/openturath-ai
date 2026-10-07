import 'package:flutter/material.dart';
import '../core/design/ot_expressive.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';

import '../core/design/ot_typography.dart';

/// A quiet Arabic watermark remains decorative; actions retain their own focus.
class OTInkCard extends StatelessWidget {
  const OTInkCard(
      {super.key,
      required this.child,
      this.watermark = '',
      this.onTap,
      this.semanticLabel,
      this.padding = const EdgeInsets.all(24)});
  final Widget child;
  final String watermark;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticLabel,
        child: Material(
          color: Theme.of(context).brightness == Brightness.dark
              ? OTColors.surface(true)
              : OTExpressive.hero,
          borderRadius: OTRadius.cardBorder,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
              onTap: onTap,
              child: Stack(children: [
                if (watermark.isNotEmpty)
                  Positioned.fill(
                    child: IgnorePointer(child: ExcludeSemantics(child: LayoutBuilder(builder: (context, box) => Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(width: box.maxWidth * .85, height: box.maxHeight * .65,
                        child: FittedBox(fit: BoxFit.contain, child: Text(watermark,
                          textDirection: TextDirection.rtl, maxLines: 1,
                          style: const TextStyle(fontFamily: 'NativeArabicUI', fontSize: OTFontSize.s36,
                            fontWeight: FontWeight.w700, height: 1.5).copyWith(color: OTExpressive.white.withValues(alpha: .08))))),
                    )))),
                  ),
                Padding(padding: padding, child: child),
              ])),
        ),
      );
}
