import '../core/design/ot_typography.dart';
import '../core/design/ot_expressive.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'tahawwulat_diagram.dart';
import 'tahawwulat_artwork.dart';
import '../services/feature_flags.dart';

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

  /// Apakah slide "Mengenal Fikih Tahawwulat" sudah boleh dibuka. Mengikuti
  /// saklar jarak jauh `app_config/features.introduction_enabled` (lihat
  /// `FeatureFlags`), sehingga bisa dinyalakan tanpa merilis aplikasi. Selama
  /// belum siap, tombolnya TETAP tampil dengan penanda "Segera hadir".
  /// Penimpaan manual `introductionReadyOverride` diutamakan (dipakai tes).
  static bool? introductionReadyOverride;

  static bool get introductionReady =>
      introductionReadyOverride ??
      FeatureFlagsService.current.introductionEnabled;

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
                TextButton(
                    onPressed: onIntroduction,
                    style: TextButton.styleFrom(
                        foregroundColor: OTExpressive.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16)),
                    // Wrap: penanda turun ke baris berikutnya bila tidak muat
                    // (layar sempit atau teks besar), alih-alih meluap.
                    child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: OTSpacing.sm,
                        runSpacing: OTSpacing.xs,
                        children: [
                          Opacity(
                              opacity: introductionReady ? 1 : 0.7,
                              child: Text(reviewCopy(
                                  'Mengenal Fikih Tahawwulat',
                                  'التعرّف على فقه التحولات',
                                  'Getting to know Fiqh al-Tahawwulat'))),
                          if (!introductionReady)
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: OTSpacing.md,
                                    vertical: OTSpacing.xs),
                                decoration: BoxDecoration(
                                    borderRadius: OTRadius.chipBorder,
                                    border: Border.all(
                                        color: OTExpressive.whiteMuted)),
                                child: Text(
                                    reviewCopy('Segera hadir', 'قريبًا',
                                        'Coming soon'),
                                    style: ScholarlyFonts.outfit(
                                        fontSize: OTFontSize.s11,
                                        color: OTExpressive.whiteMuted))),
                        ])),
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
