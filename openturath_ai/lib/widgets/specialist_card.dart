import '../core/localization.dart';
import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/scholarly_fonts.dart';
import 'apple_interactive_wrapper.dart';

/// Kartu Keilmuan Khadim Turats (Specialist Scholarly Card)
/// Didesain berwibawa dengan elevasi tenang, kurvatur 16px, kaligrafi Arab,
/// lencana cakupan disiplin, serta cuplikan marja' mu'tamad.
class SpecialistCard extends StatelessWidget {
  const SpecialistCard({
    super.key,
    required this.title,
    this.scopeLabel,
    this.referenceLabel,
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
  final String? titleArabic;
  final String? emoji;
  final IconData? icon;
  final String? statusLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final canvas = OTColors.canvas(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.0),
      ),
      child: AppleInteractiveWrapper(
        onTap: onOpen,
        pressedScale: 0.98,
        hapticType: HapticFeedbackType.light,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Disiplin Tag / Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (emoji != null && emoji!.isNotEmpty)
                    Text(emoji!, style: const TextStyle(fontSize: 16))
                  else if (icon != null)
                    Icon(icon, size: 18, color: textSecondary)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: border.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        Loc.tr('navStudies'),
                        style: ScholarlyFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (statusLabel != null && statusLabel!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: border.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel!,
                        style: ScholarlyFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Title Row: Latin & Arabic
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      Loc.text(title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ScholarlyFonts.newsreader(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ),
                  if (titleArabic != null && titleArabic!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      titleArabic!,
                      textDirection: TextDirection.rtl,
                      style: ScholarlyFonts.scheherazadeNew(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.85,
                      ),
                    ),
                  ],
                ],
              ),

              // Scope label
              if (scopeLabel != null && scopeLabel!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  Loc.text(scopeLabel!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ScholarlyFonts.outfit(
                    color: textSecondary,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],

              // Reference Books Ribbon
              if (referenceLabel != null && referenceLabel!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: canvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border.withValues(alpha: 0.7), width: 0.6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_outlined, size: 14, color: textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          referenceLabel!,
                          textDirection: TextDirection.rtl,
                          style: ScholarlyFonts.scheherazadeNew(
                            color: textSecondary,
                            fontSize: 12.5,
                            height: 1.85,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Actions Footer: Ruang Telaah & Pustaka Marja'
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Loc.tr('startStudy'),
                        style: ScholarlyFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: textPrimary,
                      ),
                    ],
                  ),
                  if (onOpenLibrary != null)
                    Tooltip(
                      message: Loc.tr('referenceBooks'),
                      child: AppleInteractiveWrapper(
                        onTap: onOpenLibrary,
                        pressedScale: 0.94,
                        hapticType: HapticFeedbackType.selection,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_library_outlined,
                                size: 13,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                Loc.tr('referenceBooks'),
                                style: ScholarlyFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
