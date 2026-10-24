import 'package:flutter/material.dart';
import '../core/answer_direction.dart';
import '../core/arabic_catalog.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/scholarly_fonts.dart';

/// Satu identitas bibliografis, dipakai katalog koleksi dan katalog kanonikal.
/// Kartu rata: judul paling banyak dua baris, pengarang satu baris, lalu satu
/// baris keterangan kecil di dasar kartu (wafat, jilid, halaman) tanpa pil.
class BookIdentityCard extends StatefulWidget {
  const BookIdentityCard(
      {super.key,
      required this.title,
      required this.author,
      required this.facts,
      required this.onTap,
      this.deathLabel,
      this.index});
  final String title, author;
  final List<String> facts;
  final String? deathLabel;
  final int? index;
  final VoidCallback onTap;

  bool get hasAuthorDate => RegExp(r'[0-9٠-٩]').hasMatch(author);

  @override
  State<BookIdentityCard> createState() => _BookIdentityCardState();
}

class _BookIdentityCardState extends State<BookIdentityCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    final titleRtl = answerDirection(widget.title) == TextDirection.rtl;
    final authorRtl = answerDirection(widget.author) == TextDirection.rtl;
    final meta = <_Fact>[
      if (widget.deathLabel != null && !widget.hasAuthorDate)
        _Fact(null, widget.deathLabel!),
      for (final f in widget.facts)
        _Fact(
            f.startsWith('الصفحات')
                ? Icons.description_outlined
                : Icons.layers_outlined,
            f),
    ];
    return Semantics(
      button: true,
      label: '${widget.title}, ${widget.author}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: OTMotion.fast,
          curve: OTMotion.curve,
          decoration: BoxDecoration(
            color: OTColors.surface(dark),
            borderRadius: OTRadius.cardBorder,
            border: Border.all(
                color: _hover
                    ? OTColors.borderStrong(dark)
                    : OTColors.borderSubtle(dark)),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: OTRadius.cardBorder,
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    OTSpacing.lg, OTSpacing.lg, OTSpacing.lg, OTSpacing.base),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.index != null)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    end: OTSpacing.md, top: OTSpacing.sm),
                                child: Text(
                                    ArabicCatalog.digits(widget.index
                                        .toString()
                                        .padLeft(2, '0')),
                                    style: ArabicCatalog.ui(
                                        fontSize: OTFontSize.s12,
                                        fontWeight: FontWeight.w600,
                                        color: OTColors.textTertiary(dark))),
                              ),
                            Expanded(
                              child: Text(widget.title,
                                  textDirection: answerDirection(widget.title),
                                  textAlign: titleRtl
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: titleRtl
                                      ? ScholarlyFonts.scheherazadeNew(
                                          fontSize: OTFontSize.s22,
                                          height: 1.55,
                                          fontWeight: FontWeight.w400,
                                          color: ink)
                                      : OTTypography.cardTitle(color: ink)),
                            ),
                          ],
                        ),
                        const SizedBox(height: OTSpacing.xs),
                        Text(widget.author,
                            textDirection: answerDirection(widget.author),
                            textAlign:
                                authorRtl ? TextAlign.right : TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: authorRtl
                                ? ScholarlyFonts.scheherazadeNew(
                                    fontSize: OTFontSize.s16,
                                    height: 1.5,
                                    color: muted)
                                : OTTypography.caption(color: muted)),
                      ],
                    ),
                    const SizedBox(height: OTSpacing.md),
                    Row(children: [
                      Expanded(
                        child: Wrap(
                          spacing: OTSpacing.base,
                          runSpacing: OTSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [for (final m in meta) _FactView(m, muted)],
                        ),
                      ),
                      Icon(Icons.chevron_left_rounded,
                          size: OTSpacing.xl,
                          color: _hover ? ink : OTColors.textTertiary(dark)),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Fact {
  const _Fact(this.icon, this.text);
  final IconData? icon;
  final String text;
}

class _FactView extends StatelessWidget {
  const _FactView(this.fact, this.color);
  final _Fact fact;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        if (fact.icon != null) ...[
          Icon(fact.icon, size: OTSpacing.base, color: color),
          const SizedBox(width: OTSpacing.xs),
        ],
        Flexible(
          child: Text(fact.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection: answerDirection(fact.text),
              style: answerDirection(fact.text) == TextDirection.rtl
                  ? ArabicCatalog.ui(fontSize: OTFontSize.s12, color: color)
                  : OTTypography.caption(color: color)),
        ),
      ]);
}
