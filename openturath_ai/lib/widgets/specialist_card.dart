import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/ot_colors.dart';
import 'apple_interactive_wrapper.dart';

/// Minimalist Purism Specialist Card
/// Clean, typographic, rounded corners (16), no icons, no Arabic clutter, no subtitle lines.
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

    return AppleInteractiveWrapper(
      onTap: onOpen,
      pressedScale: 0.98,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pure Title & Optional Minimal Status Badge
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.newsreader(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (statusLabel != null && statusLabel!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isDark ? border : const Color(0xFFE4E4E7),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          statusLabel!,
                          style: GoogleFonts.outfit(
                            color: textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons: Optional Pustaka + Chevron
              if (onOpenLibrary != null) ...[
                const SizedBox(width: 8),
                AppleInteractiveWrapper(
                  onTap: onOpenLibrary,
                  pressedScale: 0.94,
                  hapticType: HapticFeedbackType.selection,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 13, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Pustaka',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (onOpen != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: textSecondary.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
