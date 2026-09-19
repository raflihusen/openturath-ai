import '../core/l10n/app_dictionary.dart';
import '../core/l10n/library_dictionary.dart';
import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../models/book_model.dart';
import 'apple_interactive_wrapper.dart';
import 'editorial.dart';

/// A compact, script-aware bibliographic card. Full metadata lives in the dossier.
class BookRowItem extends StatelessWidget {
  const BookRowItem({super.key, required this.book, required this.onTap, this.searchQuery});
  final CanonicalBookPresentation book;
  final VoidCallback onTap;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = OTColors.textSecondary(dark);
    return AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: .985,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.circular(12),
      child: EditorialCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          EditorialArabicText(librarySourceLabel(book.titleArabic, context.languageCode), fontSize: 24),
          const SizedBox(height: 4),
          EditorialArabicText(librarySourceLabel(book.authorArabic, context.languageCode), fontSize: 20, color: secondary),
          if (book.titleLatin?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(book.titleLatin!, textDirection: TextDirection.ltr, style: OTTypography.body(color: secondary)),
          ],
          const SizedBox(height: 16),
          Wrap(spacing: 20, runSpacing: 8, children: [
            if (book.verifiedDeathYearHijri != null)
              Text(context.tr('library.died', args: {'year': libraryBidi('${book.verifiedDeathYearHijri}', context.languageCode)}),
                style: OTTypography.caption(color: secondary)),
            if (book.volumesCount != null)
              Text(context.tr('library.volumes_count', args: {'count': libraryBidi('${book.volumesCount}', context.languageCode)}),
                style: OTTypography.caption(color: secondary)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(context.tr('library.edition_details'), style: OTTypography.caption(color: secondary)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward, size: 16, color: secondary),
            ]),
          ]),
        ]),
      ),
    );
  }
}

/// Keep labels and values on separate lines so Arabic and Latin never compete.
class BibliographicField extends StatelessWidget {
  const BibliographicField({super.key, required this.label, this.value, this.sourceText = false});
  final String label;
  final String? value;
  final bool sourceText;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final clean = value?.trim();
    final text = clean == null || clean.isEmpty || clean == '-' ? context.tr('library.unknown') : sourceText
        ? libraryBidi(librarySourceLabel(clean, context.languageCode), context.languageCode)
        : libraryDataLabel(clean, context.languageCode);
    final arabic = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(label,
          style: OTTypography.caption(color: OTColors.textSecondary(dark))),
        const SizedBox(height: 6),
        if (arabic) EditorialArabicText(text, fontSize: 22)
        else SelectableText(text, textDirection: TextDirection.ltr,
          style: OTTypography.body(color: OTColors.textPrimary(dark))),
      ]),
    );
  }
}
