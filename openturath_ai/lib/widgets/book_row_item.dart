import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_spacing.dart';
import '../core/catalog_card_content.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/book_model.dart';
import 'apple_interactive_wrapper.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';
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

    final hasDeathYear = book.verifiedDeathYearHijri != null &&
        book.verifiedDeathYearHijri! > 0;

    // Susunan yang sama dengan kartu di daftar kitab per koleksi: judul,
    // pengarang, lalu satu baris fakta edisi.
    return Padding(
      padding: const EdgeInsets.only(bottom: OTSpacing.sm),
      child: AppleInteractiveWrapper(
        onTap: onTap,
        pressedScale: 0.985,
        hapticType: HapticFeedbackType.light,
        borderRadius: BorderRadius.circular(OTRadius.card),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(OTRadius.card),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                book.titleArabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ScholarlyFonts.scheherazadeNew(
                  color: textPrimary,
                  fontSize: OTFontSize.s22,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                book.authorArabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ScholarlyFonts.scheherazadeNew(
                  color: textSecondary,
                  fontSize: OTFontSize.s16,
                  height: 1.5,
                ),
              ),
              if (facts.isNotEmpty || hasDeathYear) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        facts.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s12, color: textSecondary),
                      ),
                    ),
                    if (hasDeathYear) ...[
                      const SizedBox(width: 12),
                      Text(
                        Loc.tr('deathYear', ['${book.verifiedDeathYearHijri}']),
                        maxLines: 1,
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s12, color: textSecondary),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
