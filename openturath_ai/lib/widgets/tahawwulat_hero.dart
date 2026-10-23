import '../core/design/ot_typography.dart';
import '../core/design/ot_expressive.dart';
import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'tahawwulat_diagram.dart';
import 'tahawwulat_artwork.dart';

String reviewCopy(String id, String ar, String en) => Loc.isArabic
    ? ar
    : Loc.language == 'en'
        ? en
        : id;

class TahawwulatHero extends StatelessWidget {
  const TahawwulatHero(
      {super.key,
      required this.onOpen,
      required this.onIntroduction,
      this.facts = const [],
      this.onOpenLibrary});

  /// Saklar pengendali tombol pengenalan (default: sembunyi).
  /// Dapat diaktifkan secara real-time kapan saja (`TahawwulatHero.showIntroduction = true`).
  static bool showIntroduction = false;

  final VoidCallback onOpen;
  final VoidCallback? onOpenLibrary;
  final VoidCallback onIntroduction;
  final List<String> facts;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 720 &&
            MediaQuery.textScalerOf(context).scale(16) <= 24;
        final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: OTExpressive.whiteMuted, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        reviewCopy('Eksklusif di OpenTurath',
                            'حصري في OpenTurath', 'Exclusive to OpenTurath'),
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s14,
                            color: OTExpressive.whiteMuted,
                            fontWeight: FontWeight.w600)))
              ]),
              const SizedBox(height: 16),
              Text(
                  reviewCopy('AI Fikih Tahawwulat', 'AI فقه التحولات',
                      'AI Fiqh Tahawwulat'),
                  style: ScholarlyFonts.outfit(
                      fontSize: wide ? OTFontSize.s36 : OTFontSize.s26,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      color: OTExpressive.white)),
              const SizedBox(height: 16),
              if (facts.isNotEmpty)
                Wrap(spacing: 16, runSpacing: 8, children: [
                  for (final fact in facts)
                    Text(fact,
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s14,
                            color: OTExpressive.whiteMuted))
                ]),
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 12, children: [
                FilledButton(
                    onPressed: onOpen,
                    style: FilledButton.styleFrom(
                        backgroundColor: OTExpressive.white,
                        foregroundColor: OTExpressive.hero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16)),
                    child: Text(reviewCopy('Buka AI Fikih Tahawwulat',
                        'افتح فقه التحولات', 'Open Fiqh Tahawwulat'))),
                if (onOpenLibrary != null)
                  SizedBox.square(
                      dimension: 48,
                      child: IconButton.filledTonal(
                          tooltip: Loc.tr('viewReferences'),
                          onPressed: onOpenLibrary,
                          style: IconButton.styleFrom(
                              backgroundColor:
                                  OTExpressive.white.withValues(alpha: .12),
                              foregroundColor: OTExpressive.white),
                          icon: Icon(Icons.auto_stories_outlined,
                              semanticLabel: Loc.tr('viewReferences')))),
                if (showIntroduction)
                  TextButton(
                      onPressed: onIntroduction,
                      style: TextButton.styleFrom(
                          foregroundColor: OTExpressive.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16)),
                      child: Text(reviewCopy(
                          'Mengenal Fikih Tahawwulat',
                          'التعرّف على فقه التحولات',
                          'Getting to know Fiqh al-Tahawwulat'))),
              ]),
            ]);
        return TahawwulatHeroSurface(
            padding: EdgeInsets.all(wide ? 32 : 24),
            radius:
                wide ? OTExpressive.heroRadius : OTExpressive.compactHeroRadius,
            child: wide
                ? Row(children: [
                    Expanded(flex: 3, child: text),
                    const SizedBox(width: 24),
                    const Expanded(
                        flex: 2,
                        child: Center(
                            child: SizedBox(
                                width: 280,
                                child: TahawwulatDiagram(inverse: true))))
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        text,
                        const SizedBox(height: 16),
                        const Center(
                            child: SizedBox(
                                width: 180,
                                child: TahawwulatDiagram(inverse: true)))
                      ]));
      });
}
