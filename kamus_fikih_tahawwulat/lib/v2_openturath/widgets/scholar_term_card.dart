import 'package:flutter/material.dart';
import '../../core/models/term_model.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_radius.dart';
import '../theme/ot_spacing.dart';
import 'apple_interactive_wrapper.dart';
import 'exif_source_pill.dart';

/// Kartu istilah bergaya scholarly minimalis untuk daftar katalog
class ScholarTermCard extends StatelessWidget {
  final Term term;
  final VoidCallback onTap;

  const ScholarTermCard({
    super.key,
    required this.term,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppleInteractiveWrapper(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(OTSpacing.base),
        decoration: BoxDecoration(
          color: OTColors.surface(isDark),
          borderRadius: BorderRadius.circular(OTRadius.card),
          border: Border.all(
            color: OTColors.border(isDark),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: OTColors.surfaceSubtle(isDark),
                    borderRadius: BorderRadius.circular(OTRadius.pill),
                  ),
                  child: Text(
                    '#${term.id}',
                    style: OTTypography.caption(
                      color: OTColors.textTertiary(isDark),
                    ),
                  ),
                ),
                // Sovereign Amber badge for Tahawwulat corpus
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: OTColors.sovereignAmberBg,
                    borderRadius: BorderRadius.circular(OTRadius.pill),
                    border: Border.all(
                      color: OTColors.sovereignAmber.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'تحولات',
                    style: OTTypography.caption(
                      color: OTColors.sovereignAmber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: OTSpacing.md),

            // Arabic title (RTL)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                term.arabic,
                textDirection: TextDirection.rtl,
                style: OTTypography.arabicReading(
                  color: OTColors.textPrimary(isDark),
                ),
              ),
            ),
            const SizedBox(height: OTSpacing.sm),

            // Latin transliteration
            Text(
              term.indonesian,
              style: OTTypography.body(
                color: OTColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: OTSpacing.md),

            // EXIF micro-pill strip
            Wrap(
              spacing: OTSpacing.sm,
              runSpacing: OTSpacing.xs,
              children: [
                ExifSourcePill(
                  source: '${term.definitions.length} ibarah',
                  icon: Icons.format_quote_outlined,
                ),
                if (term.definitions.isNotEmpty)
                  ExifSourcePill(
                    source: term.definitions.first.source.split('،').first.trim(),
                    icon: Icons.menu_book_outlined,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
