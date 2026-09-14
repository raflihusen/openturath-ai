import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/term_model.dart';
import '../../core/providers/kamus_providers.dart';
import '../../core/i18n/translations.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_spacing.dart';
import '../theme/ot_radius.dart';
import '../widgets/exif_source_pill.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// OpenTurath Detail Screen — Layar telaah istilah (Quiet Scholar reading view)
/// Garis kiri Sovereign Amber 3px per definisi, EXIF micro-pill sumber, aksi bersahaja
class OTDetailScreen extends ConsumerWidget {
  final Term term;
  final String langCode;
  final VoidCallback onBack;
  final Function(Term, Definition) onShare;
  final VoidCallback onAiSummary;

  const OTDetailScreen({
    super.key,
    required this.term,
    required this.langCode,
    required this.onBack,
    required this.onShare,
    required this.onAiSummary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoritesProvider);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    return Column(
      children: [
        // ── Sticky Header ──
        Container(
          color: OTColors.canvas(isDark),
          padding: const EdgeInsets.fromLTRB(
            OTSpacing.sm, OTSpacing.sm, OTSpacing.lg, OTSpacing.sm,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: OTColors.textPrimary(isDark),
                ),
                onPressed: onBack,
              ),
              const Spacer(),
              // AI Summary button
              if (term.definitions.length > 1)
                AppleInteractiveWrapper(
                  onTap: onAiSummary,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: OTColors.surfaceSubtle(isDark),
                      borderRadius: BorderRadius.circular(OTRadius.pill),
                      border: Border.all(
                        color: OTColors.border(isDark),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: OTColors.sovereignAmber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          KamusTranslations.tr('aiSummary', langCode),
                          style: OTTypography.microPill(
                            color: OTColors.textSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Scrollable Content ──
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── Term Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.base,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Arabic title — full RTL display
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          term.arabic,
                          textDirection: TextDirection.rtl,
                          style: OTTypography.arabicDisplay(
                            color: OTColors.textPrimary(isDark),
                          ),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.sm),

                      // Indonesian / English transliteration
                      Text(
                        term.indonesian.isNotEmpty ? term.indonesian : term.english,
                        style: OTTypography.corpusTitle(
                          color: OTColors.textSecondary(isDark),
                        ),
                      ),
                      if (term.english.isNotEmpty && term.indonesian.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          term.english,
                          style: OTTypography.caption(
                            color: OTColors.textTertiary(isDark),
                          ),
                        ),
                      ],

                      const SizedBox(height: OTSpacing.md),

                      // EXIF micro-pills row
                      Wrap(
                        spacing: OTSpacing.sm,
                        runSpacing: OTSpacing.xs,
                        children: [
                          ExifSourcePill(
                            source: '#${term.id}',
                            icon: Icons.tag,
                          ),
                          ExifSourcePill(
                            source: '${term.definitions.length} ${langCode == 'ar' ? 'عبارة' : 'ibarah'}',
                            icon: Icons.format_quote_outlined,
                          ),
                          ...term.definitions
                              .map((d) => d.source.split('،').first.trim())
                              .toSet()
                              .take(3)
                              .map((s) => ExifSourcePill(
                                    source: s,
                                    icon: Icons.menu_book_outlined,
                                  )),
                        ],
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
                    height: OTSpacing.base,
                  ),
                ),
              ),

              // ── Section Heading: Definitions ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.sm,
                  ),
                  child: Text(
                    langCode == 'ar'
                        ? 'العبارات والتعريفات'
                        : (langCode == 'en' ? 'DEFINITIONS' : 'DEFINISI & IBARAH'),
                    style: OTTypography.sectionHeading(
                      color: OTColors.textTertiary(isDark),
                    ),
                  ),
                ),
              ),

              // ── Definition Cards ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  OTSpacing.lg, 0, OTSpacing.lg, 100,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final def = term.definitions[index];
                      final isFav = favorites.contains(def.uid);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: OTSpacing.md),
                        child: _DefinitionCard(
                          definition: def,
                          index: index,
                          isDark: isDark,
                          langCode: langCode,
                          isFavorite: isFav,
                          onToggleFavorite: () {
                            favoritesNotifier.toggleFavorite(def.uid);
                            HapticFeedback.lightImpact();
                          },
                          onCopy: () {
                            final text = '${def.text.ar}\n\n${def.text.id}\n\n— ${def.source}';
                            Clipboard.setData(ClipboardData(text: text));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(KamusTranslations.tr('copy', langCode)),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onShare: () => onShare(term, def),
                        ),
                      );
                    },
                    childCount: term.definitions.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single definition card with left Sovereign Amber accent bar
class _DefinitionCard extends StatelessWidget {
  final Definition definition;
  final int index;
  final bool isDark;
  final String langCode;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _DefinitionCard({
    required this.definition,
    required this.index,
    required this.isDark,
    required this.langCode,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // Left accent bar (3px Sovereign Amber)
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: OTColors.sovereignAmber.withOpacity(0.6 + (index * 0.1).clamp(0.0, 0.4)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(OTRadius.card),
                  bottomLeft: Radius.circular(OTRadius.card),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(OTSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Definition index badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: OTColors.surfaceSubtle(isDark),
                            borderRadius: BorderRadius.circular(OTRadius.pill),
                          ),
                          child: Text(
                            '${langCode == 'ar' ? 'عبارة' : 'Ibarah'} ${index + 1}',
                            style: OTTypography.microPill(
                              color: OTColors.textTertiary(isDark),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Actions row (compact)
                        _ActionIcon(
                          icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
                          color: isFavorite ? OTColors.sovereignAmber : OTColors.textTertiary(isDark),
                          onTap: onToggleFavorite,
                        ),
                        const SizedBox(width: OTSpacing.xs),
                        _ActionIcon(
                          icon: Icons.copy_outlined,
                          color: OTColors.textTertiary(isDark),
                          onTap: onCopy,
                        ),
                        const SizedBox(width: OTSpacing.xs),
                        _ActionIcon(
                          icon: Icons.share_outlined,
                          color: OTColors.textTertiary(isDark),
                          onTap: onShare,
                        ),
                      ],
                    ),
                    const SizedBox(height: OTSpacing.md),

                    // Arabic text (RTL, tight line-height)
                    if (definition.text.ar.isNotEmpty)
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          definition.text.ar,
                          style: OTTypography.arabicReading(
                            color: OTColors.textPrimary(isDark),
                          ),
                        ),
                      ),

                    if (definition.text.ar.isNotEmpty && definition.text.id.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
                        child: Divider(
                          color: OTColors.border(isDark),
                          height: 1,
                        ),
                      ),

                    // Indonesian text
                    if (definition.text.id.isNotEmpty)
                      Text(
                        definition.text.id,
                        style: OTTypography.body(
                          color: OTColors.textSecondary(isDark),
                        ),
                      ),

                    // English text
                    if (definition.text.en.isNotEmpty) ...[
                      const SizedBox(height: OTSpacing.sm),
                      Text(
                        definition.text.en,
                        style: OTTypography.body(
                          color: OTColors.textTertiary(isDark),
                        ),
                      ),
                    ],

                    // Source micro-pill
                    if (definition.source.isNotEmpty) ...[
                      const SizedBox(height: OTSpacing.md),
                      Wrap(
                        children: [
                          ExifSourcePill(
                            source: definition.source,
                            icon: Icons.menu_book_outlined,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact action icon button
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
