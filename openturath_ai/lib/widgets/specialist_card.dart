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
  final VoidCallback? onOpen;
  final VoidCallback? onOpenLibrary;

  IconData get _disciplineIcon => icon ?? switch (fieldId) {
        'fiqh' => Icons.balance_outlined,
        'hadith' => Icons.format_quote_outlined,
        'tafsir' => Icons.auto_stories_outlined,
        'usul' => Icons.account_tree_outlined,
        'lughah' => Icons.translate_outlined,
        'aqidah' => Icons.lightbulb_outline_rounded,
        'tarikh' => Icons.history_edu_outlined,
        'tasawwuf' => Icons.spa_outlined,
        'bibliografi' => Icons.library_books_outlined,
        _ => Icons.menu_book_outlined,
      };

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = OTColors.border(isDark);
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final scope = scopeLabel?.trim();
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
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: OTColors.surfaceSubtle(isDark),
                  borderRadius: BorderRadius.circular(OTRadius.input),
                  border: Border.all(color: border),
                ),
                child: Icon(_disciplineIcon, size: 21, color: ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ScholarlyFonts.newsreader(
                        fontSize: OTFontSize.s18,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                    if (scope != null && scope.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        Loc.text(scope),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s12,
                          height: 1.35,
                          color: muted,
                        ),
                      ),
                    ],
                    if (reference != null && reference.isNotEmpty &&
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
              if (onOpenLibrary != null)
                IconButton(
                  onPressed: onOpenLibrary,
                  tooltip: Loc.tr('referenceBooks'),
                  icon: Icon(Icons.auto_stories_outlined,
                      color: muted, size: 20),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.chevron_right_rounded,
                      color: muted, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
