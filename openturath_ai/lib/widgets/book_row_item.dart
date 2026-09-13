import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../models/book_model.dart';
import 'apple_interactive_wrapper.dart';

/// Item baris naskah kanonikal dengan desain minimalis terinspirasi dari lembar informasi Google Camera (Pixel EXIF card).
/// Monokrom murni, tanpa aksen biru, dengan tipografi Arab proporsional dan strip metadata horizontal rapi.
class BookRowItem extends StatelessWidget {
  const BookRowItem({
    super.key,
    required this.book,
    required this.onTap,
    this.searchQuery,
  });

  final CanonicalBookPresentation book;
  final VoidCallback onTap;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    // Format jilid bersih tanpa duplikasi kata
    String? formattedVolumes;
    if (book.volumesDescription != null && book.volumesDescription!.isNotEmpty) {
      final v = book.volumesDescription!;
      formattedVolumes = (v.contains('جزء') || v.contains('مجلد') || v.contains('Jilid'))
          ? v
          : '$v Jilid';
    } else if (book.volumesCount != null && book.volumesCount! > 0) {
      formattedVolumes = '${book.volumesCount} Jilid';
    }

    final hasPages = book.pagesDescription != null &&
        book.pagesDescription!.isNotEmpty &&
        book.pagesDescription != '-';
    final hasTahqiq = book.muhaqqiq != null &&
        book.muhaqqiq!.isNotEmpty &&
        book.muhaqqiq != '-';
    final hasPublisher = book.publisher != null &&
        book.publisher!.isNotEmpty &&
        book.publisher != '-';
    final hasYear = book.printYear != null &&
        book.printYear!.isNotEmpty &&
        book.printYear != '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: OTSpacing.sm),
      child: AppleInteractiveWrapper(
        onTap: onTap,
        pressedScale: 0.985,
        hapticType: HapticFeedbackType.light,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Row Atas: Nomor Urut (#id), Kategori (القسم), & Tahun Wafat ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: border.withValues(alpha: 0.8), width: 0.6),
                      ),
                      child: Text(
                        '#${book.editionId}',
                        style: GoogleFonts.firaCode(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    if (book.sectionArabic != null && book.sectionArabic!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          book.sectionArabic!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    if (book.verifiedDeathYearHijri != null && book.verifiedDeathYearHijri! > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: border.withValues(alpha: 0.7), width: 0.5),
                        ),
                        child: Text(
                          'w. ${book.verifiedDeathYearHijri} H',
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // ── Judul Kitab Bahasa Arab (RTL) ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          book.titleArabic,
                          textAlign: TextAlign.right,
                          style: OTTypography.arabicReading(
                            color: textPrimary,
                          ).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: textSecondary.withValues(alpha: 0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ── Nama Pengarang (Al-Mu'allif) ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 13,
                      color: textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        book.authorArabic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Metadata Strip Bergaya Informasi Google Camera (EXIF Micro-Pills) ──
                if (formattedVolumes != null ||
                    hasPages ||
                    hasTahqiq ||
                    hasPublisher ||
                    hasYear ||
                    book.reviewedTypeLabel != null ||
                    book.reviewedEraLabel != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: border.withValues(alpha: 0.5), width: 0.6),
                    ),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (formattedVolumes != null)
                          _buildExifPill(
                            icon: Icons.layers_outlined,
                            text: formattedVolumes,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            border: border,
                          ),
                        if (book.reviewedTypeLabel != null && book.reviewedTypeLabel!.isNotEmpty)
                          _buildExifPill(
                            icon: Icons.menu_book_outlined,
                            text: book.reviewedTypeLabel!,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            border: border,
                          ),
                        if (book.reviewedEraLabel != null && book.reviewedEraLabel!.isNotEmpty)
                          _buildExifPill(
                            icon: Icons.history_edu_rounded,
                            text: book.reviewedEraLabel!,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            border: border,
                          ),
                        if (hasPages)
                          _buildExifPill(
                            icon: Icons.article_outlined,
                            text: '${book.pagesDescription} Hlm',
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            border: border,
                          ),
                        if (hasTahqiq)
                          _buildExifPill(
                            icon: Icons.edit_note_rounded,
                            text: book.muhaqqiq!,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            border: border,
                            maxWidth: 160,
                          ),
                        if (hasPublisher)
                          _buildExifPill(
                            icon: Icons.apartment_rounded,
                            text: book.publisher!,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            border: border,
                            maxWidth: 150,
                          ),
                        if (hasYear)
                          _buildExifPill(
                            icon: Icons.calendar_today_outlined,
                            text: book.printYear!,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            border: border,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExifPill({
    required IconData icon,
    required String text,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    double? maxWidth,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textSecondary),
          const SizedBox(width: 4),
          if (maxWidth != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            )
          else
            Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
