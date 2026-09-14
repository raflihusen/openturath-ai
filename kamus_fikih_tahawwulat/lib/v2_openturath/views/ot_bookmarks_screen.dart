import 'package:flutter/material.dart';
import '../../core/models/term_model.dart';
import '../../core/i18n/translations.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_spacing.dart';
import '../theme/ot_radius.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// OpenTurath Bookmarks Screen — Definisi-definisi yang di-bookmark
class OTBookmarksScreen extends StatelessWidget {
  final List<String> favoriteUids;
  final List<Term> allTerms;
  final String langCode;
  final ValueChanged<Term> onSelectTerm;

  const OTBookmarksScreen({
    super.key,
    required this.favoriteUids,
    required this.allTerms,
    required this.langCode,
    required this.onSelectTerm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve favorite UIDs to (Term, Definition) pairs
    final bookmarked = <MapEntry<Term, Definition>>[];
    for (final uid in favoriteUids) {
      for (final term in allTerms) {
        for (final def in term.definitions) {
          if (def.uid == uid) {
            bookmarked.add(MapEntry(term, def));
          }
        }
      }
    }

    if (bookmarked.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: OTColors.textTertiary(isDark),
            ),
            const SizedBox(height: OTSpacing.md),
            Text(
              KamusTranslations.tr('noFavorites', langCode),
              style: OTTypography.cardTitle(
                color: OTColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: OTSpacing.xs),
            Text(
              KamusTranslations.tr('noFavoritesDesc', langCode),
              style: OTTypography.caption(
                color: OTColors.textTertiary(isDark),
              ),
              textAlign: TextAlign.center,
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
                    ? 'المحفوظات'
                    : (langCode == 'en' ? 'BOOKMARKS' : 'PENANDA'),
                style: OTTypography.sectionHeading(
                  color: OTColors.textTertiary(isDark),
                ),
              ),
              Text(
                '${bookmarked.length}',
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
            itemCount: bookmarked.length,
            separatorBuilder: (_, __) => const SizedBox(height: OTSpacing.sm),
            itemBuilder: (context, index) {
              final entry = bookmarked[index];
              final term = entry.key;
              final def = entry.value;

              return AppleInteractiveWrapper(
                onTap: () => onSelectTerm(term),
                child: Container(
                  decoration: BoxDecoration(
                    color: OTColors.surface(isDark),
                    borderRadius: BorderRadius.circular(OTRadius.card),
                    border: Border.all(
                      color: OTColors.border(isDark),
                      width: 0.8,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left amber accent bar
                        Container(
                          width: 3,
                          decoration: BoxDecoration(
                            color: OTColors.sovereignAmber,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(OTRadius.card),
                              bottomLeft: Radius.circular(OTRadius.card),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(OTSpacing.base),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Term name
                                Row(
                                  children: [
                                    Icon(
                                      Icons.bookmark,
                                      size: 14,
                                      color: OTColors.sovereignAmber,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        term.indonesian.isNotEmpty ? term.indonesian : term.english,
                                        style: OTTypography.captionMedium(
                                          color: OTColors.textSecondary(isDark),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      term.arabic,
                                      textDirection: TextDirection.rtl,
                                      style: OTTypography.arabicQuote(
                                        color: OTColors.textTertiary(isDark),
                                      ).copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: OTSpacing.sm),

                                // Definition preview (Arabic)
                                if (def.text.ar.isNotEmpty)
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text(
                                      def.text.ar,
                                      style: OTTypography.arabicQuote(
                                        color: OTColors.textPrimary(isDark),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                // Definition preview (Indonesian)
                                if (def.text.id.isNotEmpty) ...[
                                  const SizedBox(height: OTSpacing.sm),
                                  Text(
                                    def.text.id,
                                    style: OTTypography.caption(
                                      color: OTColors.textSecondary(isDark),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],

                                // Source
                                if (def.source.isNotEmpty) ...[
                                  const SizedBox(height: OTSpacing.sm),
                                  Text(
                                    '— ${def.source.split('،').first.trim()}',
                                    style: OTTypography.microPill(
                                      color: OTColors.textTertiary(isDark),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
