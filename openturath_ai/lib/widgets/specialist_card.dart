import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import 'apple_interactive_wrapper.dart';
import 'ot_mobile_primitives.dart';

/// Compact mobile directory entry for an assistant.
///
/// It deliberately avoids website metrics, decorative serial numbers, and
/// oversized marketing copy. The row exposes only information needed to choose
/// and open an assistant.
class SpecialistCard extends StatelessWidget {
  const SpecialistCard({
    super.key,
    required this.title,
    this.scopeLabel,
    this.referenceLabel,
    required this.onOpen,
    this.titleArabic,
    this.emoji,
    this.icon,
    this.statusLabel,
    this.onOpenLibrary,
    this.serial,
    this.metricLabel,
    this.featured,
  });

  final String title;
  final String? scopeLabel;
  final String? referenceLabel;
  final String? titleArabic;
  final String? emoji;
  final IconData? icon;
  final String? statusLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onOpenLibrary;
  final String? serial;
  final String? metricLabel;
  final bool? featured;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final unavailable = statusLabel?.isNotEmpty ?? false;
    final arabic = titleArabic?.trim() ?? '';
    final displayTitle =
        Loc.isArabic && arabic.isNotEmpty ? arabic : Loc.text(title);
    final description = scopeLabel?.trim().isNotEmpty == true
        ? scopeLabel!.trim()
        : 'Buka asisten untuk memulai kajian.';

    return Semantics(
      button: onOpen != null,
      label: '$displayTitle. $description',
      child: AppleInteractiveWrapper(
        onTap: onOpen,
        borderRadius: OTRadius.cardBorder,
        child: Container(
          constraints: const BoxConstraints(minHeight: 116),
          padding: const EdgeInsets.all(OTSpacing.base),
          decoration: BoxDecoration(
            color: OTColors.surface(dark),
            borderRadius: OTRadius.cardBorder,
            border: Border.all(color: OTColors.border(dark)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OTColors.surfaceSubtle(dark),
                  borderRadius: OTRadius.rowBorder,
                ),
                child: arabic.isNotEmpty
                    ? Text(
                        arabic,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        textDirection: TextDirection.rtl,
                        style: OTTypography.arabicReading(
                          color: OTColors.textPrimary(dark),
                        ).copyWith(fontSize: 15),
                      )
                    : Icon(icon ?? Icons.auto_awesome_outlined,
                        size: 21, color: OTColors.textSecondary(dark)),
              ),
              const SizedBox(width: OTSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OTTypography.bookTitle(
                                color: OTColors.textPrimary(dark)),
                          ),
                        ),
                        if (unavailable)
                          OTStatusPill(label: statusLabel ?? 'Segera'),
                      ],
                    ),
                    const SizedBox(height: OTSpacing.xs),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.caption(
                          color: OTColors.textSecondary(dark)),
                    ),
                    if (referenceLabel?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: OTSpacing.sm),
                      Text(
                        referenceLabel!.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: OTTypography.arabicQuote(
                          color: OTColors.textTertiary(dark),
                        ).copyWith(fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: OTSpacing.sm),
              if (onOpenLibrary != null)
                IconButton(
                  tooltip: 'Buka pustaka $displayTitle',
                  onPressed: onOpenLibrary,
                  icon: const Icon(Icons.menu_book_outlined, size: 20),
                  color: OTColors.textSecondary(dark),
                ),
              Icon(Icons.chevron_right_rounded,
                  size: 21, color: OTColors.textTertiary(dark)),
            ],
          ),
        ),
      ),
    );
  }
}
