import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import 'apple_interactive_wrapper.dart';

/// Standard card for an assistant or field of study.
///
/// Every field uses the same neutral anatomy. Availability is communicated by
/// copy and hierarchy instead of a special colour treatment.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final subtle = OTColors.surfaceSubtle(isDark);
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);
    final arabic = titleArabic?.trim() ?? '';
    final displayTitle =
        Loc.isArabic && arabic.isNotEmpty ? arabic : Loc.text(title);
    final unavailable = statusLabel?.isNotEmpty ?? false;

    return Semantics(
      button: onOpen != null,
      label: '$displayTitle${unavailable ? ', $statusLabel' : ''}',
      child: AppleInteractiveWrapper(
        onTap: onOpen,
        borderRadius: OTRadius.cardBorder,
        child: Container(
          constraints: const BoxConstraints(minHeight: 148),
          padding: OTSpacing.card,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: OTRadius.cardBorder,
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    serial ?? '—',
                    style: OTTypography.metadataTag(color: muted),
                  ),
                  OTSpacing.gapSm,
                  if (arabic.isNotEmpty)
                    Expanded(
                      child: Text(
                        arabic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        textDirection: TextDirection.rtl,
                        style: OTTypography.arabicQuote(color: muted),
                      ),
                    )
                  else
                    const Spacer(),
                  if (unavailable)
                    Container(
                      margin:
                          const EdgeInsetsDirectional.only(start: OTSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.sm,
                        vertical: OTSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: subtle,
                        borderRadius: OTRadius.smallBorder,
                      ),
                      child: Text(
                        statusLabel!,
                        style: OTTypography.captionMedium(color: muted),
                      ),
                    ),
                ],
              ),
              OTSpacing.gapLg,
              Text(
                displayTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: OTTypography.bookTitle(color: ink),
              ),
              OTSpacing.gapSm,
              Text(
                scopeLabel?.isNotEmpty == true
                    ? scopeLabel!
                    : 'Baca rujukan dan ajukan pertanyaan',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: OTTypography.caption(color: muted),
              ),
              OTSpacing.gapMd,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      metricLabel?.isNotEmpty == true
                          ? metricLabel!
                          : 'Lihat asisten',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.captionMedium(color: ink),
                    ),
                  ),
                  if (onOpenLibrary != null) ...[
                    IconButton(
                      onPressed: onOpenLibrary,
                      tooltip: 'Buka pustaka $displayTitle',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.menu_book_outlined,
                          size: 19, color: muted),
                    ),
                  ],
                  Icon(Icons.chevron_right_rounded, size: 20, color: muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
