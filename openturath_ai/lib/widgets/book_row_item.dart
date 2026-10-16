import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../models/book_model.dart';
import 'book_identity_card.dart';
import '../core/arabic_catalog.dart';

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
    // Katalog selalu berbahasa Arab (keputusan pemilik 2026-10-16).
    String? volumes;
    final vd = book.volumesDescription?.trim() ?? '';
    if (vd.isNotEmpty && vd != '-') {
      volumes = RegExp(r'^[0-9٠-٩]+$').hasMatch(vd)
          ? ArabicCatalog.volumes(vd)
          : ArabicCatalog.digits(vd);
    } else if (book.volumesCount != null && book.volumesCount! > 0) {
      volumes = ArabicCatalog.volumes('${book.volumesCount}');
    }
    final pages = book.pagesDescription?.trim() ?? '';
    final pageLabel = pages.isEmpty || pages == '-'
        ? null
        : RegExp(r'^[0-9٠-٩.,،\s]+$').hasMatch(pages)
            ? ArabicCatalog.pages(pages.replaceAll(RegExp(r'[.,،\s]'), ''))
            : ArabicCatalog.digits(pages);
    final facts = [
      if (volumes != null) volumes,
      if (pageLabel != null) pageLabel
    ];

    return BookIdentityCard(
      title: book.titleArabic,
      author: ArabicCatalog.authorName(book.authorArabic),
      facts: facts.take(2).toList(),
      deathLabel: ArabicCatalog.death(book.verifiedDeathYearHijri),
      onTap: onTap,
    );
  }
}
