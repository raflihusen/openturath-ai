import 'package:flutter/material.dart';
import '../../core/models/term_model.dart';
import '../../core/i18n/translations.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_spacing.dart';
import '../theme/ot_radius.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// OpenTurath Catalog Screen — Daftar lengkap istilah scholarly minimalis
class OTCatalogScreen extends StatefulWidget {
  final List<Term> terms;
  final String langCode;
  final ValueChanged<Term> onSelectTerm;

  const OTCatalogScreen({
    super.key,
    required this.terms,
    required this.langCode,
    required this.onSelectTerm,
  });

  @override
  State<OTCatalogScreen> createState() => _OTCatalogScreenState();
}

class _OTCatalogScreenState extends State<OTCatalogScreen> {
  String _localQuery = '';

  List<Term> get _filteredTerms {
    if (_localQuery.isEmpty) return widget.terms;
    final q = _localQuery.toLowerCase();
    return widget.terms.where((t) {
      return t.arabic.contains(q) ||
          t.indonesian.toLowerCase().contains(q) ||
          t.english.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredTerms;

    return Column(
      children: [
        // ── Inline Search Bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.sm,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: OTColors.surfaceSubtle(isDark),
              borderRadius: BorderRadius.circular(OTRadius.inputField),
              border: Border.all(
                color: OTColors.border(isDark),
                width: 0.8,
              ),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _localQuery = val),
              style: OTTypography.body(color: OTColors.textPrimary(isDark)),
              decoration: InputDecoration(
                hintText: KamusTranslations.tr('searchPlaceholder', widget.langCode),
                hintStyle: OTTypography.body(color: OTColors.textTertiary(isDark)),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: OTColors.textTertiary(isDark),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.base,
                  vertical: OTSpacing.md,
                ),
              ),
            ),
          ),
        ),

        // ── Results count & section heading ──
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.lg,
            vertical: OTSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                KamusTranslations.tr('allTerms', widget.langCode),
                style: OTTypography.sectionHeading(
                  color: OTColors.textTertiary(isDark),
                ),
              ),
              Text(
                '${filtered.length}',
                style: OTTypography.caption(
                  color: OTColors.textTertiary(isDark),
                ),
              ),
            ],
          ),
        ),

        // ── Term List ──
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: OTColors.textTertiary(isDark),
                      ),
                      const SizedBox(height: OTSpacing.md),
                      Text(
                        KamusTranslations.tr('noResultsFound', widget.langCode),
                        style: OTTypography.cardTitle(
                          color: OTColors.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.xs),
                      Text(
                        KamusTranslations.tr('noResultsDesc', widget.langCode),
                        style: OTTypography.caption(
                          color: OTColors.textTertiary(isDark),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, 100,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: OTSpacing.xs),
                  itemBuilder: (context, index) {
                    final term = filtered[index];
                    return _CatalogRow(
                      term: term,
                      isDark: isDark,
                      langCode: widget.langCode,
                      onTap: () => widget.onSelectTerm(term),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Catalog single-row scholarly style
class _CatalogRow extends StatelessWidget {
  final Term term;
  final bool isDark;
  final String langCode;
  final VoidCallback onTap;

  const _CatalogRow({
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
            // Numbered index
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OTColors.surfaceSubtle(isDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${term.id}',
                style: OTTypography.caption(
                  color: OTColors.textTertiary(isDark),
                ),
              ),
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
            // Arabic label
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
  }
}
