import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../models/book_model.dart';
import 'apple_interactive_wrapper.dart';

/// Item baris naskah kanonikal dengan tinggi adaptif, tipografi Amiri berharakat,
/// isolasi arah baca RTL, dan target sentuh ramah Apple HIG (>= 48px).
class BookRowItem extends StatelessWidget {
  const BookRowItem({
    super.key,
    required this.book,
    required this.onTap,
    this.searchQuery,
  });

  final CanonicalBookPresentation book;
  final VoidCallback onTap;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final primaryAccent = OTColors.accent(isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: OTSpacing.sm),
      child: AppleInteractiveWrapper(
        onTap: onTap,
        pressedScale: 0.98,
        hapticType: HapticFeedbackType.light,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.md,
            vertical: OTSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading Icon / Book Badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryAccent.withValues(alpha: isDark ? 0.3 : 0.2),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 20,
                  color: primaryAccent,
                ),
              ),
              const SizedBox(width: OTSpacing.md),

              // Title and Meta Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Arabic Title with RTL Isolation
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        book.titleArabic,
                        textAlign: TextAlign.right,
                        style: OTTypography.arabicReading(
                          color: textPrimary,
                        ).copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Author & Death Year
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.authorArabic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OTTypography.caption(color: textSecondary).copyWith(
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        if (book.verifiedDeathYearHijri != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'w. ${book.verifiedDeathYearHijri} H',
                              style: OTTypography.caption(color: textSecondary).copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Tags & Labels (Type, Era, Volumes)
                    if (book.compactLabels.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: book.compactLabels.map((lbl) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: isDark ? 0.12 : 0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lbl,
                              style: OTTypography.caption(color: primaryAccent).copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
