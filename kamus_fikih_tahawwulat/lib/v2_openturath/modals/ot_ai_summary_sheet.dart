import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/term_model.dart';
import '../../core/providers/kamus_providers.dart';
import '../../core/i18n/translations.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_spacing.dart';
import '../theme/ot_radius.dart';
import '../theme/ot_motion.dart';
import '../widgets/ot_app_loader.dart';

/// OpenTurath AI Summary Sheet — Ringkasan definisi otomatis (scholarly style)
class OTAiSummarySheet extends ConsumerStatefulWidget {
  final Term term;
  final String langCode;
  final VoidCallback onClose;

  const OTAiSummarySheet({
    super.key,
    required this.term,
    required this.langCode,
    required this.onClose,
  });

  @override
  ConsumerState<OTAiSummarySheet> createState() => _OTAiSummarySheetState();
}

class _OTAiSummarySheetState extends ConsumerState<OTAiSummarySheet> {
  @override
  void initState() {
    super.initState();
    // Trigger AI generation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiSummaryProvider.notifier).generateSummary(
            term: widget.term,
            languageCode: widget.langCode,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aiState = ref.watch(aiSummaryProvider);

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: OTMotion.sheet,
              curve: OTMotion.defaultCurve,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              decoration: BoxDecoration(
                color: OTColors.canvas(isDark),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(OTRadius.sheet),
                ),
                border: Border(
                  top: BorderSide(
                    color: OTColors.border(isDark),
                    width: 0.8,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: OTColors.textTertiary(isDark).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.lg),

                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 20,
                            color: OTColors.sovereignAmber,
                          ),
                          const SizedBox(width: OTSpacing.sm),
                          Text(
                            KamusTranslations.tr('aiSummary', widget.langCode),
                            style: OTTypography.screenTitle(
                              color: OTColors.textPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OTSpacing.sm),

                      // Term reference
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OTSpacing.md,
                          vertical: OTSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: OTColors.surfaceSubtle(isDark),
                          borderRadius: BorderRadius.circular(OTRadius.inputField),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.term.indonesian.isNotEmpty
                                    ? widget.term.indonesian
                                    : widget.term.english,
                                style: OTTypography.captionMedium(
                                  color: OTColors.textSecondary(isDark),
                                ),
                              ),
                            ),
                            Text(
                              widget.term.arabic,
                              textDirection: TextDirection.rtl,
                              style: OTTypography.arabicQuote(
                                color: OTColors.textTertiary(isDark),
                              ).copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: OTSpacing.lg),

                      // Content
                      if (aiState.isLoading) ...[
                        const SizedBox(height: OTSpacing.xl),
                        const Center(child: OTAppLoader()),
                        const SizedBox(height: OTSpacing.md),
                        Center(
                          child: Text(
                            widget.langCode == 'ar'
                                ? 'جارٍ التلخيص...'
                                : 'Menyusun ringkasan...',
                            style: OTTypography.caption(
                              color: OTColors.textTertiary(isDark),
                            ),
                          ),
                        ),
                      ] else if (aiState.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(OTSpacing.base),
                          decoration: BoxDecoration(
                            color: OTColors.destructive.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(OTRadius.card),
                          ),
                          child: Text(
                            aiState.error!,
                            style: OTTypography.body(
                              color: OTColors.destructive,
                            ),
                          ),
                        ),
                      ] else if (aiState.summary != null) ...[
                        // Summary text with left accent bar
                        Container(
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
                                    child: SelectableText(
                                      aiState.summary!,
                                      style: OTTypography.body(
                                        color: OTColors.textPrimary(isDark),
                                      ).copyWith(height: 1.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
