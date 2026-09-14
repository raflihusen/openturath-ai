import 'package:flutter/material.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_radius.dart';
import '../theme/ot_spacing.dart';

/// Google Camera EXIF Micro-Pill — Deretan pil mikro monokrom 11px
class ExifSourcePill extends StatelessWidget {
  final String source;
  final IconData? icon;

  const ExifSourcePill({
    super.key,
    required this.source,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OTSpacing.sm,
        vertical: OTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: OTColors.surfaceSubtle(isDark),
        borderRadius: BorderRadius.circular(OTRadius.pill),
        border: Border.all(
          color: OTColors.border(isDark),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: OTColors.textTertiary(isDark),
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              source,
              style: OTTypography.microPill(
                color: OTColors.textSecondary(isDark),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
