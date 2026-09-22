import 'package:flutter/material.dart';

import '../core/catalog_card_content.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../models/book_model.dart';
import 'apple_interactive_wrapper.dart';

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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final volume = book.volumesDescription?.trim().isNotEmpty == true
        ? book.volumesDescription
        : book.volumesCount == null
            ? null
            : '${book.volumesCount} jilid';
    final facts = catalogCardFacts(
      volumes: volume,
      publisher: book.publisher,
      printYear: book.printYear,
      muhaqqiq: book.muhaqqiq,
    );

    return AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: 0.99,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: OTColors.border(dark)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: OTSpacing.base),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.sectionArabic ?? 'Kitab rujukan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OTTypography.metadataTag(
                              color: OTColors.textSecondary(dark),
                            ),
                          ),
                        ),
                        if (book.verifiedDeathYearHijri != null)
                          Text(
                            'w. ${book.verifiedDeathYearHijri} H',
                            style: OTTypography.caption(
                              color: OTColors.textSecondary(dark),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: OTSpacing.sm),
                    Text(
                      book.titleArabic,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: OTTypography.arabicReading(
                        color: OTColors.textPrimary(dark),
                      ).copyWith(fontSize: 21, height: 1.55),
                    ),
                    const SizedBox(height: OTSpacing.xs),
                    Text(
                      book.authorArabic,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.captionMedium(
                        color: OTColors.textPrimary(dark),
                      ),
                    ),
                    if (facts.isNotEmpty) ...[
                      const SizedBox(height: OTSpacing.xs),
                      Text(
                        facts.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OTTypography.caption(
                          color: OTColors.textSecondary(dark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: OTSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 34),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: OTColors.textTertiary(dark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
