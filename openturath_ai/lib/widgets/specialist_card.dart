import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';

/// Unified rounded specialist card adhering to Quiet Scholar Adaptive standards.
/// Clean, symmetrical 16dp container with scholarly typography,
/// elegant category icon, and optional integrated Pustaka action.
class SpecialistCard extends StatelessWidget {
  const SpecialistCard({
    super.key,
    required this.title,
    required this.scopeLabel,
    required this.onOpen,
    this.titleArabic,
    this.emoji,
    this.icon,
    this.statusLabel,
    this.onOpenLibrary,
  });

  final String title;
  final String scopeLabel;
  final String? titleArabic;
  final String? emoji;
  final IconData? icon;
  final String? statusLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onOpenLibrary;

  IconData _resolveIcon() {
    if (icon != null) return icon!;
    final lowerTitle = title.toLowerCase();
    final lowerScope = scopeLabel.toLowerCase();

    if (lowerTitle.contains('tahawwulat') || lowerScope.contains('tahawwulat')) {
      return Icons.history_edu_rounded;
    }
    if (lowerTitle.contains('syafi') || lowerTitle.contains('fikih')) {
      return Icons.menu_book_rounded;
    }
    if (lowerTitle.contains('hanafi') || lowerTitle.contains('maliki') || lowerTitle.contains('hanbali')) {
      return Icons.balance_rounded;
    }
    if (lowerTitle.contains('hadits') || lowerScope.contains('hadits')) {
      return Icons.auto_stories_rounded;
    }
    if (lowerTitle.contains('tafsir') || lowerScope.contains('tafsir')) {
      return Icons.import_contacts_rounded;
    }
    if (lowerTitle.contains('tasawuf') || lowerScope.contains('akhlak')) {
      return Icons.psychology_alt_outlined;
    }
    if (lowerTitle.contains('habib') || lowerTitle.contains('imam') || lowerTitle.contains('ulama')) {
      return Icons.school_outlined;
    }
    return Icons.menu_book_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final accent = OTColors.accent(isDark);

    final resolvedIcon = _resolveIcon();
    final isComingSoon = statusLabel != null && statusLabel!.isNotEmpty;

    return Material(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Scholarly Icon Box
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isComingSoon
                      ? surfaceSubtle
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isComingSoon ? border : accent.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  resolvedIcon,
                  size: 21,
                  color: isComingSoon
                      ? textSecondary.withValues(alpha: 0.7)
                      : accent,
                ),
              ),
              const SizedBox(width: 14),

              // Title, Arabic, and Scope
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: OTTypography.cardTitle(color: textPrimary).copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (titleArabic != null && titleArabic!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            titleArabic!,
                            textDirection: TextDirection.rtl,
                            style: OTTypography.arabicReading(
                              color: isDark ? const Color(0xFFD97706) : const Color(0xFFB45309),
                            ).copyWith(
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      scopeLabel,
                      style: OTTypography.caption(color: textSecondary).copyWith(
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (statusLabel != null) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: surfaceSubtle,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: border.withValues(alpha: 0.6), width: 0.6),
                        ),
                        child: Text(
                          statusLabel!,
                          style: OTTypography.caption(color: textSecondary).copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
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
                InkWell(
                  onTap: onOpenLibrary,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 13, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Pustaka',
                          style: OTTypography.button(color: textSecondary).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (onOpen != null) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: textSecondary.withValues(alpha: 0.6),
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
