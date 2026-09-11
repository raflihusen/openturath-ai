import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';

/// Unified rounded specialist card adhering to Audit Specification 6.5.
/// Replaces unboxed row designs with structured 16dp radius containers,
/// removes noisy marketing descriptions, and provides optional native Pustaka action.
class SpecialistCard extends StatelessWidget {
  const SpecialistCard({
    super.key,
    required this.title,
    required this.scopeLabel,
    required this.onOpen,
    this.titleArabic,
    this.emoji,
    this.statusLabel,
    this.onOpenLibrary,
  });

  final String title;
  final String scopeLabel;
  final String? titleArabic;
  final String? emoji;
  final String? statusLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

    return Material(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onOpen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 88),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (emoji != null) ...[
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: surfaceSubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border.withValues(alpha: 0.6), width: 0.8),
                        ),
                        child: Text(
                          emoji!,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: OTTypography.cardTitle(color: textPrimary).copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (titleArabic != null && titleArabic!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  titleArabic!,
                                  textDirection: TextDirection.rtl,
                                  style: OTTypography.arabicReading(color: textSecondary).copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scopeLabel,
                            style: OTTypography.caption(color: textSecondary).copyWith(
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (statusLabel != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: surfaceSubtle,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusLabel!,
                                style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onOpen != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: textSecondary,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (onOpenLibrary != null) ...[
            Divider(height: 1, color: border.withValues(alpha: 0.8)),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onOpenLibrary,
                icon: Icon(Icons.menu_book_outlined, size: 16, color: textSecondary),
                label: Text(
                  'Pustaka',
                  style: OTTypography.button(color: textSecondary).copyWith(fontSize: 12.5),
                ),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
