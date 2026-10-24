import 'package:flutter/material.dart';

import '../core/arabic_catalog.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/scholarly_fonts.dart';

/// Satu angka utama kitab (jilid, halaman, wafat).
class BookStat {
  const BookStat(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
}

/// Angka utama sejajar dalam satu baris kotak, dipakai kartu kitab Arab.
class BookStatStrip extends StatelessWidget {
  const BookStatStrip({super.key, required this.items});
  final List<BookStat> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    return Padding(
      padding: const EdgeInsets.only(top: OTSpacing.md),
      child: Row(children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: OTSpacing.md),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(OTSpacing.base),
              decoration: BoxDecoration(
                color: OTColors.surface(dark),
                borderRadius: OTRadius.cardBorder,
                border: Border.all(color: OTColors.borderSubtle(dark)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(items[i].icon, size: OTSpacing.lg, color: muted),
                    const SizedBox(height: OTSpacing.sm),
                    Text(items[i].value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ArabicCatalog.ui(
                            fontSize: OTFontSize.s20,
                            fontWeight: FontWeight.w700,
                            color: ink)),
                    Text(items[i].label,
                        style: ArabicCatalog.ui(
                            fontSize: OTFontSize.s12, color: muted)),
                  ]),
            ),
          ),
        ],
      ]),
    );
  }
}

/// Satu baris label dan nilai pada kartu data kitab.
class BookFact {
  const BookFact(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
}

/// Kartu berjudul berisi baris label dan nilai dengan garis pemisah tipis.
class BookFactsCard extends StatelessWidget {
  const BookFactsCard({super.key, required this.title, required this.rows});
  final String title;
  final List<BookFact> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    return Container(
      margin: const EdgeInsets.only(top: OTSpacing.md),
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.base, OTSpacing.md, OTSpacing.base, OTSpacing.xs),
      decoration: BoxDecoration(
        color: OTColors.surface(dark),
        borderRadius: OTRadius.cardBorder,
        border: Border.all(color: OTColors.borderSubtle(dark)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title,
            style: ArabicCatalog.ui(
                fontSize: OTFontSize.s14,
                fontWeight: FontWeight.w700,
                color: muted)),
        const SizedBox(height: OTSpacing.xs),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) Divider(height: 1, color: OTColors.borderSubtle(dark)),
          _Row(rows[i], ink, muted),
        ],
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.fact, this.ink, this.muted);
  final BookFact fact;
  final Color ink, muted;

  @override
  Widget build(BuildContext context) {
    final empty = fact.value == ArabicCatalog.notStatedShort;
    final label = Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(fact.icon, size: OTSpacing.base, color: muted),
      const SizedBox(width: OTSpacing.sm),
      Flexible(
        child: Text(fact.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArabicCatalog.ui(fontSize: OTFontSize.s14, color: muted)),
      ),
    ]);
    final value = Text(fact.value.trim(),
        textAlign: TextAlign.start,
        style: empty
            ? ArabicCatalog.ui(fontSize: OTFontSize.s14, color: muted)
            : ScholarlyFonts.scheherazadeNew(
                fontSize: OTFontSize.s18, height: 1.7, color: ink));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
      child: LayoutBuilder(builder: (context, box) {
        if (box.maxWidth < 560) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [label, const SizedBox(height: OTSpacing.xs), value]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(width: 144, child: label),
          const SizedBox(width: OTSpacing.lg),
          Expanded(child: value),
        ]);
      }),
    );
  }
}
