import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import 'apple_interactive_wrapper.dart';

/// V6 bento entry for a field of study.
///
/// Each card exposes the same information hierarchy as the public website:
/// index, availability, Arabic accent, editorial title, scope, and corpus scale.
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
    this.serial,
    this.metricLabel,
    this.featured,
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
  final String? serial;
  final String? metricLabel;
  final bool? featured;

  static const Map<String, _SpecialistEditorialData> _editorialData = {
    'fikih syafi\'i':
        _SpecialistEditorialData('01', 'الفقه', '1.240 Kitab · 210 Jt Kata'),
    'hadis & syarah':
        _SpecialistEditorialData('02', 'الحديث', '780 Kitab · 126 Jt Kata'),
    'hadis':
        _SpecialistEditorialData('02', 'الحديث', '780 Kitab · 126 Jt Kata'),
    'tafsir al-qur\'an':
        _SpecialistEditorialData('03', 'التفسير', '640 Kitab · 98 Jt Kata'),
    'tafsir':
        _SpecialistEditorialData('03', 'التفسير', '640 Kitab · 98 Jt Kata'),
    'akidah':
        _SpecialistEditorialData('04', 'العقيدة', '510 Kitab · 74 Jt Kata'),
    'ushul fikih':
        _SpecialistEditorialData('05', 'الأصول', '420 Kitab · 61 Jt Kata'),
    'bahasa arab':
        _SpecialistEditorialData('06', 'العربية', '360 Kitab · 48 Jt Kata'),
    'sirah': _SpecialistEditorialData('07', 'السيرة', '310 Kitab · 43 Jt Kata'),
    'tasawuf':
        _SpecialistEditorialData('08', 'التصوف', '290 Kitab · 39 Jt Kata'),
  };

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final editorial = _editorialData[title.toLowerCase()];
    final isFeatured = featured ?? title.toLowerCase().contains('hadis');
    final isUnavailable = statusLabel?.isNotEmpty ?? false;

    final standardSurface = OTColors.surface(isDark);
    final standardInk = OTColors.textPrimary(isDark);
    final standardMuted = OTColors.textSecondary(isDark);
    final standardHairline = OTColors.border(isDark);
    final invertedSurface =
        isDark ? OTColors.textPrimaryDark : OTColors.textPrimaryLight;
    final invertedInk =
        isDark ? OTColors.textPrimaryLight : OTColors.textPrimaryDark;
    final invertedMuted =
        isDark ? OTColors.textSecondaryLight : OTColors.textSecondaryDark;

    final surface = isFeatured ? invertedSurface : standardSurface;
    final ink = isFeatured ? invertedInk : standardInk;
    final muted = isFeatured ? invertedMuted : standardMuted;
    final hairline =
        isFeatured ? muted.withValues(alpha: 0.32) : standardHairline;
    final arabic = (titleArabic?.isNotEmpty ?? false)
        ? titleArabic!
        : editorial?.arabic ?? '';
    final displayTitle =
        Loc.isArabic && arabic.isNotEmpty ? arabic : Loc.text(title);
    final corpusMetric = metricLabel ?? editorial?.metric ?? 'Koleksi rujukan';

    return Semantics(
      button: onOpen != null,
      label: '$displayTitle, $corpusMetric',
      child: AppleInteractiveWrapper(
        onTap: onOpen,
        borderRadius: OTRadius.cardBorder,
        child: Container(
          height: 216,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: OTRadius.cardBorder,
            border: Border.all(color: hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (arabic.isNotEmpty)
                Positioned(
                  right: 18,
                  top: 44,
                  child: IgnorePointer(
                    child: Text(
                      arabic,
                      textDirection: TextDirection.rtl,
                      style: OTTypography.arabicDisplay(
                        color: ink.withValues(alpha: 0.10),
                        height: 1.9,
                      ).copyWith(fontSize: 44),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          serial ?? editorial?.serial ?? '—',
                          style:
                              OTTypography.metadataTag(color: muted).copyWith(
                            fontFamily: 'monospace',
                            fontFamilyFallback: const ['Scheherazade New'],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: ink.withValues(alpha: 0.07),
                            borderRadius: OTRadius.chipBorder,
                            border: Border.all(color: hairline),
                          ),
                          child: Text(
                            isUnavailable
                                ? statusLabel!.toUpperCase()
                                : 'TERSEDIA',
                            style:
                                OTTypography.metadataTag(color: muted).copyWith(
                              fontSize: 9,
                              letterSpacing: 1.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.bookTitle(color: ink).copyWith(
                        fontSize: 24,
                        height: 1.08,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scopeLabel?.isNotEmpty == true
                          ? scopeLabel!
                          : 'Rujukan turats terpilih',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.body(color: muted)
                          .copyWith(fontSize: 12.5),
                    ),
                    const SizedBox(height: 18),
                    Container(height: 1, color: hairline),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            corpusMetric,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OTTypography.captionMedium(color: ink),
                          ),
                        ),
                        if (onOpenLibrary != null)
                          AppleInteractiveWrapper(
                            onTap: onOpenLibrary,
                            enableHaptic: true,
                            semanticLabel: 'Buka pustaka $displayTitle',
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(Icons.menu_book_outlined,
                                  size: 18, color: muted),
                            ),
                          ),
                        const SizedBox(width: 4),
                        Icon(Icons.north_east_rounded, size: 18, color: muted),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialistEditorialData {
  const _SpecialistEditorialData(this.serial, this.arabic, this.metric);

  final String serial;
  final String arabic;
  final String metric;
}
