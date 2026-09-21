import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/design/ot_colors.dart';
import '../core/scholarly_fonts.dart';
import 'apple_interactive_wrapper.dart';

/// Kartu Bento Keilmuan OpenTurath V6 (Scholarly Bento Card).
///
/// Mengadopsi arsitektur kartu V6:
/// - Sudut membulat 24dp dengan border presisi 1px
/// - Header: Nomor urut serial (01, 02..), status ketersediaan, dan panah navigasi
/// - Aksen Kaligrafi Arab: Font Scheherazade New (26px, line-height 1.5)
/// - Judul Utama: Font Newsreader (22-24px, weight 600)
/// - Deskripsi Akademik: Font Outfit (13px, line-height 1.6)
/// - Metrik Korpus Monumental: Angka besar jumlah kitab (56px bold), jilid, dan era naskah
/// - Varian Hierarki: Standard, Featured Inverted (#111111), dan Sovereign (bingkai ganda)
class SpecialistCard extends StatelessWidget {
  final String title;
  final String? titleArabic;
  final String? scopeLabel;
  final String? referenceLabel;
  final int? serialIndex;
  final bool isFeatured;
  final bool isSovereign;
  final int? bookCount;
  final int? volumeCount;
  final int? pageCount;
  final String? period;
  final String? statusLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onOpenLibrary;

  const SpecialistCard({
    super.key,
    required this.title,
    this.titleArabic,
    this.scopeLabel,
    this.referenceLabel,
    this.serialIndex,
    this.isFeatured = false,
    this.isSovereign = false,
    this.bookCount,
    this.volumeCount,
    this.pageCount,
    this.period,
    this.statusLabel,
    this.onOpen,
    this.onOpenLibrary,
  });

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final themeIsDark = Theme.of(context).brightness == Brightness.dark;

    // Untuk varian Featured di mode terang: kanvas gelap inverted (#111111) dengan teks putih
    final bool cardIsDark = isFeatured ? true : themeIsDark;

    final Color surface = isFeatured && !themeIsDark
        ? const Color(0xFF111111)
        : OTColors.surface(themeIsDark);

    final Color border = isFeatured && !themeIsDark
        ? const Color(0xFF38383C)
        : OTColors.border(themeIsDark);

    final Color textPrimary = isFeatured && !themeIsDark
        ? const Color(0xFFFFFFFF)
        : OTColors.textPrimary(themeIsDark);

    final Color textSecondary = isFeatured && !themeIsDark
        ? const Color(0xFFB7B7BE)
        : OTColors.textSecondary(themeIsDark);

    final Color surfaceSubtle = isFeatured && !themeIsDark
        ? const Color(0xFF1C1C1E)
        : OTColors.surfaceSubtle(themeIsDark);

    final displayTitle = Loc.isArabic && (titleArabic?.isNotEmpty ?? false)
        ? titleArabic!
        : Loc.text(title);

    final serialText = serialIndex != null
        ? serialIndex!.toString().padLeft(2, '0')
        : null;

    final isPreparing = statusLabel != null &&
        (statusLabel!.toLowerCase().contains('siap') ||
            statusLabel!.toLowerCase().contains('soon') ||
            statusLabel!.toLowerCase().contains('mempersiapkan'));

    return AppleInteractiveWrapper(
      onTap: onOpen,
      pressedScale: 0.985,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 1.0),
        ),
        child: Stack(
          children: [
            // Bingkai Ganda Eksklusif untuk Varian Sovereign (Fikih Tahawwulat)
            if (isSovereign)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: border.withValues(alpha: cardIsDark ? 0.6 : 0.8),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Konten Utama Kartu Bento
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Header: Serial, Ketersediaan, & Panah Navigasi
                  Row(
                    children: [
                      if (serialText != null) ...[
                        Text(
                          serialText,
                          style: ScholarlyFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPreparing
                              ? (cardIsDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))
                              : (cardIsDark ? const Color(0xFF1B2A1E) : const Color(0xFFEAF5ED)),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isPreparing
                                ? (cardIsDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8))
                                : (cardIsDark ? const Color(0xFF2D5A34) : const Color(0xFFC2E2CB)),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPreparing
                                    ? textSecondary
                                    : (cardIsDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              statusLabel ?? (isPreparing ? 'Mempersiapkan' : 'Tersedia'),
                              style: ScholarlyFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isPreparing
                                    ? textSecondary
                                    : (cardIsDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (onOpenLibrary != null) ...[
                        GestureDetector(
                          onTap: onOpenLibrary,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: surfaceSubtle,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: border, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.menu_book_outlined, size: 12, color: textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Pustaka',
                                  style: ScholarlyFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Icon(
                        Icons.north_east_rounded,
                        size: 18,
                        color: textSecondary.withValues(alpha: 0.8),
                      ),
                    ],
                  ),

                  // 2. Aksen Kaligrafi Arab (Scheherazade New)
                  if (titleArabic != null && titleArabic!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      titleArabic!,
                      textDirection: TextDirection.rtl,
                      style: ScholarlyFonts.arabicCardAccent(
                        fontSize: 25,
                        color: textSecondary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],

                  // 3. Judul Editorial Latin (Newsreader)
                  const SizedBox(height: 6),
                  Text(
                    displayTitle,
                    style: ScholarlyFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: textPrimary,
                      height: 1.25,
                    ),
                  ),

                  // 4. Deskripsi Akademik (Outfit)
                  if (scopeLabel != null && scopeLabel!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      scopeLabel!,
                      style: ScholarlyFonts.outfit(
                        fontSize: 13,
                        color: textSecondary,
                        height: 1.55,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // 5. Metrik Korpus Monumental (Outfit)
                  if (bookCount != null && bookCount! > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          bookCount!.toString(),
                          style: ScholarlyFonts.outfit(
                            fontSize: 46,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                            color: textPrimary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kitab',
                          style: ScholarlyFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                        if (volumeCount != null && volumeCount! > 0) ...[
                          const SizedBox(width: 14),
                          Text(
                            '·',
                            style: TextStyle(color: textSecondary, fontSize: 16),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '$volumeCount Jilid',
                            style: ScholarlyFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // 6. Era Naskh / Periode Rujukan
                  if (period != null && period!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: border, width: 0.8)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history_edu_rounded, size: 14, color: textSecondary.withValues(alpha: 0.7)),
                          const SizedBox(width: 6),
                          Text(
                            period!,
                            style: ScholarlyFonts.outfit(
                              fontSize: 11.5,
                              color: textSecondary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
