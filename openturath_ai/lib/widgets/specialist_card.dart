import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'apple_interactive_wrapper.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';

/// Each entry describes the assistant's scholarly remit and source material.
class SpecialistCard extends StatelessWidget {
  const SpecialistCard({
    super.key,
    required this.title,
    this.scopeLabel,
    this.referenceLabel,
    this.fieldId,
    required this.onOpen,
    this.titleArabic,
    this.emoji,
    this.icon,
    this.statusLabel,
    this.isLocked = false,
    this.onOpenLibrary,
  });

  final String title;
  final String? scopeLabel;
  final String? referenceLabel;
  final String? fieldId;
  final String? titleArabic;
  final String? emoji;
  final IconData? icon;
  final String? statusLabel;
  final bool isLocked;
  final VoidCallback? onOpen;
  final VoidCallback? onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = OTColors.border(isDark);
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final reference = referenceLabel?.trim();
    final displayTitle = Loc.isArabic && (titleArabic?.isNotEmpty ?? false)
        ? titleArabic!
        : Loc.text(title);

    return AppleInteractiveWrapper(
      onTap: onOpen,
      pressedScale: 0.99,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.circular(OTRadius.card),
      child: Material(
        color: OTColors.surface(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OTRadius.card),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s18,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                    if (!isLocked &&
                        reference != null &&
                        reference.isNotEmpty &&
                        onOpenLibrary != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s11,
                          color: muted,
                        ),
                      ),
                    ],
                    if (statusLabel?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 5),
                      Text(statusLabel!,
                          style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s11, color: muted)),
                    ],
                  ],
                ),
              ),
              if (isLocked || (statusLabel?.isNotEmpty ?? false)) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: muted.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
