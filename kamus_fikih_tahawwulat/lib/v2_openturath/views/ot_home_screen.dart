import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/term_model.dart';
import '../../core/i18n/translations.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_spacing.dart';
import '../theme/ot_radius.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// OpenTurath Home Screen — The Quiet Scholar Beranda
/// Menampilkan header editorial, statistik ringkas, dan istilah terbaru
class OTHomeScreen extends ConsumerWidget {
  final List<Term> terms;
  final String langCode;
  final ValueChanged<Term> onSelectTerm;

  const OTHomeScreen({
    super.key,
    required this.terms,
    required this.langCode,
    required this.onSelectTerm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Recent terms (take first 5 as featured)
    final featured = terms.take(5).toList();
    // Total stats
    final totalTerms = terms.length;
    final totalDefs = terms.fold<int>(0, (sum, t) => sum + t.definitions.length);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // ── Editorial Hero Section ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              OTSpacing.lg, OTSpacing.xl, OTSpacing.lg, OTSpacing.base,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sovereign Amber corpus badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: OTColors.sovereignAmberBg,
                    borderRadius: BorderRadius.circular(OTRadius.pill),
                    border: Border.all(
                      color: OTColors.sovereignAmber.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'فقه التحولات',
                    style: OTTypography.microPill(
                      color: OTColors.sovereignAmber,
                    ),
                  ),
                ),
                const SizedBox(height: OTSpacing.md),

                // Editorial hero title
                Text(
                  KamusTranslations.tr('appTagline', langCode),
                  style: OTTypography.editorialHero(
                    color: OTColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: OTSpacing.sm),

                // Subtitle
                Text(
                  KamusTranslations.tr('creator', langCode),
                  style: OTTypography.caption(
                    color: OTColors.textTertiary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Stats Row (Monokrom Micro-badges) ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: OTSpacing.lg,
              vertical: OTSpacing.sm,
            ),
            child: Row(
              children: [
                _StatBadge(
                  value: totalTerms.toString(),
                  label: langCode == 'ar' ? 'مصطلح' : 'Istilah',
                  isDark: isDark,
                ),
                const SizedBox(width: OTSpacing.sm),
                _StatBadge(
                  value: totalDefs.toString(),
                  label: langCode == 'ar' ? 'تعريف' : 'Definisi',
                  isDark: isDark,
                ),
                const SizedBox(width: OTSpacing.sm),
                _StatBadge(
                  value: terms.isNotEmpty
                      ? terms.map((t) => t.definitions.map((d) => d.source.split('،').first.trim())).expand((s) => s).toSet().length.toString()
                      : '0',
                  label: langCode == 'ar' ? 'مصدر' : 'Sumber',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),

        // ── Divider ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
            child: Divider(
              color: OTColors.border(isDark),
              height: OTSpacing.xl,
            ),
          ),
        ),

        // ── Section Heading: Featured Terms ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
            child: Text(
              langCode == 'ar'
                  ? 'أبرز المصطلحات'
                  : (langCode == 'en' ? 'FEATURED TERMS' : 'ISTILAH UNGGULAN'),
              style: OTTypography.sectionHeading(
                color: OTColors.textTertiary(isDark),
              ),
            ),
          ),
        ),

        // ── Featured Term Cards ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.lg,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final term = featured[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < featured.length - 1 ? OTSpacing.sm : 0,
                  ),
                  child: _FeaturedTermRow(
                    term: term,
                    isDark: isDark,
                    langCode: langCode,
                    onTap: () => onSelectTerm(term),
                  ),
                );
              },
              childCount: featured.length,
            ),
          ),
        ),

        // ── Section Heading: Latest Added ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
            child: Text(
              langCode == 'ar'
                  ? 'أحدث الإضافات'
                  : (langCode == 'en' ? 'RECENTLY ADDED' : 'TERBARU DITAMBAHKAN'),
              style: OTTypography.sectionHeading(
                color: OTColors.textTertiary(isDark),
              ),
            ),
          ),
        ),

        // ── Latest Terms (reverse order) ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            OTSpacing.lg, OTSpacing.md, OTSpacing.lg, 100,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final term = terms[terms.length - 1 - index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: OTSpacing.sm),
                  child: _FeaturedTermRow(
                    term: term,
                    isDark: isDark,
                    langCode: langCode,
                    onTap: () => onSelectTerm(term),
                  ),
                );
              },
              childCount: terms.length > 10 ? 10 : terms.length,
            ),
          ),
        ),
      ],
    );
  }
}

/// Stat micro-badge (monokrom, scholarly)
class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _StatBadge({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: OTSpacing.sm,
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
        child: Column(
          children: [
            Text(
              value,
              style: OTTypography.screenTitle(
                color: OTColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: OTTypography.caption(
                color: OTColors.textTertiary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single term row — minimalist scholarly list item
class _FeaturedTermRow extends StatelessWidget {
  final Term term;
  final bool isDark;
  final String langCode;
  final VoidCallback onTap;

  const _FeaturedTermRow({
    required this.term,
    required this.isDark,
    required this.langCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppleInteractiveWrapper(
      onTap: onTap,
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
            // Number badge
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OTColors.surfaceSubtle(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${term.id}',
                style: OTTypography.captionMedium(
                  color: OTColors.textTertiary(isDark),
                ),
              ),
            ),
            const SizedBox(width: OTSpacing.md),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term.indonesian.isNotEmpty ? term.indonesian : term.english,
                    style: OTTypography.cardTitle(
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

            // Arabic title on the right
            Flexible(
              child: Text(
                term.arabic,
                textDirection: TextDirection.rtl,
                style: OTTypography.arabicReading(
                  color: OTColors.textSecondary(isDark),
                ).copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: OTSpacing.sm),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: OTColors.textTertiary(isDark),
            ),
          ],
        ),
      ),
    );
  }
}
