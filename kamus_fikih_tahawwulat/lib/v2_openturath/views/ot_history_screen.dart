import 'package:flutter/material.dart';
import '../../core/models/term_model.dart';
import '../../core/i18n/translations.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_spacing.dart';
import '../theme/ot_radius.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// OpenTurath History Screen — Riwayat telaah istilah (Quiet Scholar style)
class OTHistoryScreen extends StatelessWidget {
  final List<int> historyIds;
  final List<Term> allTerms;
  final String langCode;
  final ValueChanged<Term> onSelectTerm;

  const OTHistoryScreen({
    super.key,
    required this.historyIds,
    required this.allTerms,
    required this.langCode,
    required this.onSelectTerm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve history IDs to Term objects
    final historyTerms = <Term>[];
    for (final id in historyIds) {
      final match = allTerms.where((t) => t.id == id);
      if (match.isNotEmpty) historyTerms.add(match.first);
    }

    if (historyTerms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 48,
              color: OTColors.textTertiary(isDark),
            ),
            const SizedBox(height: OTSpacing.md),
            Text(
              KamusTranslations.tr('noHistory', langCode),
              style: OTTypography.cardTitle(
                color: OTColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: OTSpacing.xs),
            Text(
              KamusTranslations.tr('noHistoryDesc', langCode),
              style: OTTypography.caption(
                color: OTColors.textTertiary(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                langCode == 'ar'
                    ? 'السجل'
                    : (langCode == 'en' ? 'RECENTLY VIEWED' : 'TERAKHIR DILIHAT'),
                style: OTTypography.sectionHeading(
                  color: OTColors.textTertiary(isDark),
                ),
              ),
              Text(
                '${historyTerms.length}',
                style: OTTypography.caption(
                  color: OTColors.textTertiary(isDark),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, 100,
            ),
            itemCount: historyTerms.length,
            separatorBuilder: (_, __) => const SizedBox(height: OTSpacing.xs),
            itemBuilder: (context, index) {
              final term = historyTerms[index];
              return AppleInteractiveWrapper(
                onTap: () => onSelectTerm(term),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OTSpacing.base,
                    vertical: OTSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: OTColors.surface(isDark),
                    borderRadius: BorderRadius.circular(OTRadius.card),
                    border: Border.all(
                      color: OTColors.border(isDark),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Clock icon
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: OTColors.textTertiary(isDark),
                      ),
                      const SizedBox(width: OTSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              term.indonesian.isNotEmpty ? term.indonesian : term.english,
                              style: OTTypography.bodyMedium(
                                color: OTColors.textPrimary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${term.definitions.length} ${langCode == 'ar' ? 'عبارة' : 'ibarah'}',
                              style: OTTypography.caption(
                                color: OTColors.textTertiary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        term.arabic,
                        textDirection: TextDirection.rtl,
                        style: OTTypography.arabicQuote(
                          color: OTColors.textSecondary(isDark),
                        ).copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: OTSpacing.xs),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: OTColors.textTertiary(isDark),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
