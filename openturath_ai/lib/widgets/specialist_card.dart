import '../core/localization.dart';
import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_spacing.dart';
import '../core/scholarly_fonts.dart';
import 'apple_interactive_wrapper.dart';

/// Entri Direktori Asisten Keilmuan OpenTurath.
///
/// Desain minimalis dan bersih: tanpa ikon/emoji, tanpa deskripsi panjang,
/// dan tanpa istilah Arab (kecuali jika antarmuka disetel ke Bahasa Arab).
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
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    // Tampilkan judul sesuai bahasa aktif:
    // Jika Arab, gunakan titleArabic bila ada.
    // Jika Indonesia / Inggris, gunakan nama lokal tanpa imbuhan teks Arab.
    final displayTitle = Loc.isArabic && (titleArabic?.isNotEmpty ?? false)
        ? titleArabic!
        : Loc.text(title);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppleInteractiveWrapper(
              onTap: onOpen,
              pressedScale: 0.99,
              hapticType: HapticFeedbackType.light,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ScholarlyFonts.newsreader(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (statusLabel?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 3),
                      Text(
                        statusLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ScholarlyFonts.outfit(
                          fontSize: 11.5,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (onOpenLibrary != null)
            Tooltip(
              message: Loc.tr('openLibrary'),
              child: AppleInteractiveWrapper(
                onTap: onOpenLibrary,
                pressedScale: 0.92,
                hapticType: HapticFeedbackType.selection,
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 44,
                  width: 44,
                  child: Icon(
                    Icons.menu_book_outlined,
                    size: 19,
                    color: textSecondary,
                  ),
                ),
              ),
            ),
          if (onOpen != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: textSecondary.withValues(alpha: 0.72),
              ),
            ),
        ],
      ),
    );
  }
}
