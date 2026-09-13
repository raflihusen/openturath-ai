import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../models/book_model.dart';
import 'apple_interactive_wrapper.dart';

/// Item baris naskah kanonikal dengan desain unik minimalis bergaya lembaran turath (folio strip),
/// tipografi Arab proporsional, dan penataan informasi Maktabah Syamilah yang sangat rapi.
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
    final primaryAccent = OTColors.accent(isDark);

    final volText = (book.volumesDescription != null && book.volumesDescription!.isNotEmpty)
        ? book.volumesDescription!
        : (book.volumesCount != null ? '${book.volumesCount} Jilid' : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: OTSpacing.sm),
      child: AppleInteractiveWrapper(
        onTap: onTap,
        pressedScale: 0.985,
        hapticType: HapticFeedbackType.light,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 0.8),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Folio Strip Accent (Aksen Lembaran Kitab Unik) ──
                Container(
                  width: 3.5,
                  color: primaryAccent.withValues(alpha: isDark ? 0.65 : 0.45),
                ),

                // ── Content ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row Atas: Nomor Urut & Tahun Wafat
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: surfaceSubtle,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: border.withValues(alpha: 0.6), width: 0.6),
                              ),
                              child: Text(
                                '#${book.editionId}',
                                style: GoogleFonts.firaCode(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                            if (book.sectionArabic != null && book.sectionArabic!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Flexible(
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
                            ],
                            const Spacer(),
                            if (book.verifiedDeathYearHijri != null && book.verifiedDeathYearHijri! > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: border.withValues(alpha: 0.5), width: 0.5),
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
                        ),
                        const SizedBox(height: 8),

                        // Judul Kitab Bahasa Arab (RTL)
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            book.titleArabic,
                            textAlign: TextAlign.right,
                            style: OTTypography.arabicReading(
                              color: textPrimary,
                            ).copyWith(
                              fontSize: 17.5,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Nama Pengarang (Al-Mu'allif)
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

                        // Chip Tambahan: Jilid, Muhaqqiq, Tipe, Era
                        if (volText != null ||
                            book.muhaqqiq != null ||
                            book.reviewedTypeLabel != null ||
                            book.reviewedEraLabel != null) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (volText != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryAccent.withValues(alpha: isDark ? 0.12 : 0.06),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.layers_outlined, size: 11, color: primaryAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        volText,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: primaryAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (book.reviewedTypeLabel != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: surfaceSubtle,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: border.withValues(alpha: 0.5), width: 0.5),
                                  ),
                                  child: Text(
                                    book.reviewedTypeLabel!,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              if (book.reviewedEraLabel != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: surfaceSubtle,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: border.withValues(alpha: 0.5), width: 0.5),
                                  ),
                                  child: Text(
                                    book.reviewedEraLabel!,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              if (book.muhaqqiq != null && book.muhaqqiq!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: surfaceSubtle,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: border.withValues(alpha: 0.5), width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit_note_rounded, size: 12, color: textSecondary),
                                      const SizedBox(width: 4),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 160),
                                        child: Text(
                                          book.muhaqqiq!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Chevron icon
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
