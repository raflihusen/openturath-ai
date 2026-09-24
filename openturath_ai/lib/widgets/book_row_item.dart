import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../core/catalog_card_content.dart';
import '../core/catalog_section_label.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
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
    Loc.watch(context);
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
      formattedVolumes = (v.contains('جزء') || v.contains('مجلد') || v.contains('jilid') || v.contains('Jilid'))
          ? v
          : Loc.tr('volumeCount', [v]);
    } else if (book.volumesCount != null && book.volumesCount! > 0) {
      formattedVolumes = Loc.tr('volumeCount', ['${book.volumesCount}']);
    }

    final facts = catalogCardFacts(
      volumes: formattedVolumes,
      publisher: book.publisher,
      printYear: book.printYear,
      muhaqqiq: book.muhaqqiq,
      editorLabel: Loc.tr('ui_ad39f1c3af'),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: OTSpacing.sm),
      child: AppleInteractiveWrapper(
        onTap: onTap,
        pressedScale: 0.985,
        hapticType: HapticFeedbackType.light,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
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
                        style: ScholarlyFonts.firaCode(
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
                          CatalogSectionLabel.of(book.sectionArabic!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ScholarlyFonts.outfit(
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
                          Loc.tr('deathYear', ['${book.verifiedDeathYearHijri}']),
                          style: ScholarlyFonts.outfit(
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
                            height: 1.85,
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
                        style: ScholarlyFonts.scheherazadeNew(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Fakta edisi: satu batas visual, tanpa panel bertumpuk. ──
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 5,
                    children: facts.map((fact) => Text(
                      fact,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ScholarlyFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

}
