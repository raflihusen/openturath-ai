import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import 'apple_interactive_wrapper.dart';

/// Satu entri direktori kajian.
///
/// Sengaja tidak memakai bentuk kartu. Halaman Asisten adalah daftar untuk
/// ditelusuri, sehingga judul, status, dan aksi pustaka harus terbaca dalam
/// satu baris yang ringan—bukan berkompetisi dengan halaman sebagai "kartu".
class SpecialistCard extends StatelessWidget {
  const SpecialistCard({
    super.key,
    required this.title,
    this.scopeLabel,
    required this.onOpen,
    this.titleArabic,
    this.emoji,
    this.icon,
    this.statusLabel,
    this.onOpenLibrary,
  });

  final String title;
  final String? scopeLabel;
  final String? titleArabic;
  final String? emoji;
  final IconData? icon;
  final String? statusLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.bookTitle(color: textPrimary)
                          .copyWith(fontSize: 18),
                    ),
                    if ((scopeLabel?.isNotEmpty ?? false) ||
                        (statusLabel?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 3),
                      Text(
                        statusLabel?.isNotEmpty == true
                            ? statusLabel!
                            : scopeLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OTTypography.caption(color: textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (onOpenLibrary != null)
            Tooltip(
              message: 'Buka pustaka',
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
