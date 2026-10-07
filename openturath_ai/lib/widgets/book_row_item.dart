import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../models/book_model.dart';
import 'book_identity_card.dart';

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
    // Format jilid bersih tanpa duplikasi kata
    String? formattedVolumes;
    if (book.volumesDescription != null &&
        book.volumesDescription!.isNotEmpty) {
      final v = book.volumesDescription!;
      formattedVolumes = (v.contains('جزء') ||
              v.contains('مجلد') ||
              v.contains('jilid') ||
              v.contains('Jilid'))
          ? v
          : Loc.tr('volumeCount', [v]);
    } else if (book.volumesCount != null && book.volumesCount! > 0) {
      formattedVolumes = Loc.tr('volumeCount', ['${book.volumesCount}']);
    }

    final facts = [
      if (formattedVolumes != null) formattedVolumes,
      if (book.pagesDescription?.isNotEmpty == true) book.pagesDescription!
    ];

    final hasDeathYear =
        book.verifiedDeathYearHijri != null && book.verifiedDeathYearHijri! > 0;

    return BookIdentityCard(
      title: book.titleArabic,
      author: book.authorArabic,
      facts: facts.take(2).toList(),
      deathLabel: hasDeathYear
          ? Loc.tr('deathYear', ['${book.verifiedDeathYearHijri}'])
          : null,
      onTap: onTap,
    );
  }
}
