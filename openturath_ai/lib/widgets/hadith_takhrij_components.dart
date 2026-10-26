import 'package:flutter/material.dart';

import '../core/design/ot_buttons.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../models/hadith_takhrij_models.dart';
import 'ot_motion_widgets.dart';

/// Kartu Tampilan **Al-Matn al-Mujamma‘** (Matan Komposit Lintas Riwayat)
/// Menggantikan warna biru `<MMHit>` di `HadithXSLN.xsl` dengan sorotan tonal
/// monokromatis OpenTurath (`OTColors.surfaceSubtle`) dan tautan nomor catatan kaki.
class MujammaMatnCard extends StatefulWidget {
  const MujammaMatnCard({
    super.key,
    required this.compositeMatn,
    this.onSaveToMejaTelaah,
  });

  final MujammaCompositeMatn compositeMatn;
  final VoidCallback? onSaveToMejaTelaah;

  @override
  State<MujammaMatnCard> createState() => _MujammaMatnCardState();
}

class _MujammaMatnCardState extends State<MujammaMatnCard> {
  int? _selectedFootnoteIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final borderStrong = OTColors.borderStrong(isDark);

    final zawaidSegments = widget.compositeMatn.segments
        .where((s) => s.footnoteIndex != null)
        .toList();

    return OTBentoTile(
      padding: const EdgeInsets.all(OTSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المتن المجمع والزوائد',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.bookTitle(color: textPrimary),
                  ),
                  OTSpacing.gapXs,
                  Text(
                    'الرواية الأصلية: ${widget.compositeMatn.baseHadith.bookTitleArabic} ${widget.compositeMatn.baseHadith.formattedCitation}',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.caption(color: textSecondary),
                  ),
                ],
              ),
              if (widget.onSaveToMejaTelaah != null)
                OutlinedButton(
                  style: OTButtons.compactOutlined(isDark),
                  onPressed: widget.onSaveToMejaTelaah,
                  child: const Text('＋ Kumpulkan ke Meja Telaah'),
                ),
            ],
          ),
          OTSpacing.gapLg,

          // ── Teks Komposit Al-Matn al-Mujamma' ──
          Container(
            padding: const EdgeInsets.all(OTSpacing.lg),
            decoration: BoxDecoration(
              color: surfaceSubtle,
              borderRadius: OTRadius.cardBorder,
              border: Border.all(color: border),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                spacing: OTSpacing.sm,
                runSpacing: OTSpacing.sm,
                children: [
                  for (final seg in widget.compositeMatn.segments)
                    if (seg.footnoteIndex == null)
                      Text(
                        seg.arabicText,
                        textDirection: TextDirection.rtl,
                        style: OTTypography.arabicIbarah(color: textPrimary),
                      )
                    else
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedFootnoteIndex =
                              _selectedFootnoteIndex == seg.footnoteIndex
                                  ? null
                                  : seg.footnoteIndex;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OTSpacing.sm,
                            vertical: OTSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedFootnoteIndex == seg.footnoteIndex
                                ? OTColors.inverseSurface(isDark)
                                : OTColors.surface(isDark),
                            borderRadius: OTRadius.xsBorder,
                            border: Border.all(color: borderStrong),
                          ),
                          child: Text(
                            '${seg.arabicText} (${seg.footnoteIndex})',
                            textDirection: TextDirection.rtl,
                            style: OTTypography.arabicReading(
                              color: _selectedFootnoteIndex == seg.footnoteIndex
                                  ? OTColors.onInverseSurface
                                  : textPrimary,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          if (zawaidSegments.isNotEmpty) ...[
            OTSpacing.gapLg,
            Text(
              'مصادر الزوائد والفروق في المتن المجمع',
              textDirection: TextDirection.rtl,
              style: OTTypography.cardTitle(color: textPrimary),
            ),
            OTSpacing.gapSm,
            for (final z in zawaidSegments)
              Padding(
                padding: const EdgeInsets.only(bottom: OTSpacing.xs),
                child: Container(
                  padding: const EdgeInsets.all(OTSpacing.md),
                  decoration: BoxDecoration(
                    color: _selectedFootnoteIndex == z.footnoteIndex
                        ? surfaceSubtle
                        : OTColors.surface(isDark),
                    borderRadius: OTRadius.xsBorder,
                    border: Border.all(
                      color: _selectedFootnoteIndex == z.footnoteIndex
                          ? borderStrong
                          : border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OTSpacing.sm,
                          vertical: OTSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: OTColors.inverseSurface(isDark),
                          borderRadius: OTRadius.chipBorder,
                        ),
                        child: Text(
                          '(${z.footnoteIndex})',
                          style: OTTypography.captionMedium(
                            color: OTColors.onInverseSurface,
                          ),
                        ),
                      ),
                      OTSpacing.gapMd,
                      Expanded(
                        child: Text(
                          '${z.arabicText} — أخرجه: ${z.sourceCitations.join('، ')}',
                          textDirection: TextDirection.rtl,
                          style: OTTypography.arabicReading(color: textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Kartu Matriks **27-Aturan Muqāranat al-Mutūn**
class MatnComparisonOutcomeCard extends StatelessWidget {
  const MatnComparisonOutcomeCard({
    super.key,
    required this.outcome,
    this.onTapBook,
  });

  final MatnComparisonOutcome outcome;
  final VoidCallback? onTapBook;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

    final taxonomyBadge = switch (outcome.targetBook.taxonomy) {
      HadithBookTaxonomy.musnadPrimary => 'كتاب مسند أصلي (أخرجه)',
      HadithBookTaxonomy.zawaidNarrator => 'زوائد الرواة (في زوائده)',
      HadithBookTaxonomy.secondaryCompilation => 'مصنف جامع / زوائد (أورده)',
      HadithBookTaxonomy.mustakhraj => 'مستخرج على الصحيحين',
      HadithBookTaxonomy.muqaddimah => 'مقدمة الكتاب',
      HadithBookTaxonomy.serviceSharhTakhrij => 'كتاب شرح وتخريج',
    };

    final originPercent = (outcome.rootCoverageOnOrigin * 100).round();
    final seqPercent = (outcome.sequenceOrderRatio * 100).round();

    return OTBentoTile(
      onTap: onTapBook,
      padding: const EdgeInsets.all(OTSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: OTSpacing.sm,
            runSpacing: OTSpacing.xs,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OTSpacing.sm,
                      vertical: OTSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: OTColors.inverseSurface(isDark),
                      borderRadius: OTRadius.chipBorder,
                    ),
                    child: Text(
                      'القاعدة #${outcome.rule.ruleNumber}: ${outcome.rule.category.arabicTitle}',
                      textDirection: TextDirection.rtl,
                      style: OTTypography.captionMedium(
                        color: OTColors.onInverseSurface,
                      ),
                    ),
                  ),
                  OTSpacing.gapSm,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OTSpacing.sm,
                      vertical: OTSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: OTRadius.chipBorder,
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      taxonomyBadge,
                      textDirection: TextDirection.rtl,
                      style: OTTypography.caption(color: textSecondary),
                    ),
                  ),
                ],
              ),
              Text(
                'تطابق الجذور: $originPercent% · تتابع: $seqPercent%',
                textDirection: TextDirection.rtl,
                style: OTTypography.captionMedium(color: textSecondary),
              ),
            ],
          ),
          OTSpacing.gapMd,
          Text(
            '${outcome.targetBook.formatAttributionPhrase(isFirstInChain: true)} ${outcome.targetHadith.formattedCitation}',
            textDirection: TextDirection.rtl,
            style: OTTypography.arabicReading(color: textPrimary),
          ),
          OTSpacing.gapXs,
          Text(
            'حكم المقارنة اللفظية: ${outcome.formattedArabicVerdict} · (${outcome.mutabaahRank.arabicLabel})',
            textDirection: TextDirection.rtl,
            style: OTTypography.bodyMedium(color: textSecondary),
          ),
          OTSpacing.gapSm,
          Container(
            padding: const EdgeInsets.all(OTSpacing.md),
            decoration: BoxDecoration(
              color: surfaceSubtle,
              borderRadius: OTRadius.xsBorder,
              border: Border.all(color: border),
            ),
            child: Text(
              '«${outcome.targetHadith.rawMatn}»',
              textDirection: TextDirection.rtl,
              style: OTTypography.arabicReading(color: textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel Inspector Biografi Perawi (*Tarjamat al-Rāwī & Aqwāl al-Jarḥ wa al-Ta‘dīl*)
class RawiBiographyInspectorCard extends StatelessWidget {
  const RawiBiographyInspectorCard({
    super.key,
    required this.rawi,
    this.onClose,
  });

  final RawiBiographyRecord rawi;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

    return OTBentoTile(
      padding: const EdgeInsets.all(OTSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بطاقة ترجمة الراوي والجرح والتعديل',
                      textDirection: TextDirection.rtl,
                      style: OTTypography.sectionHeading(color: textSecondary),
                    ),
                    OTSpacing.gapXs,
                    Text(
                      rawi.fullNameArabic,
                      textDirection: TextDirection.rtl,
                      style: OTTypography.arabicDisplay(color: textPrimary),
                    ),
                  ],
                ),
              ),
              if (onClose != null)
                OutlinedButton(
                  style: OTButtons.compactOutlined(isDark),
                  onPressed: onClose,
                  child: const Text('Tutup'),
                ),
            ],
          ),
          OTSpacing.gapMd,
          Wrap(
            spacing: OTSpacing.sm,
            runSpacing: OTSpacing.xs,
            children: [
              _MetaChip(label: 'الشهرة: ${rawi.esmShuhra}', isDark: isDark),
              if (rawi.kunia.isNotEmpty)
                _MetaChip(label: 'الكنية: ${rawi.kunia}', isDark: isDark),
              _MetaChip(label: rawi.tabaqaArabic, isDark: isDark),
              if (rawi.deathYearHijri != null && rawi.deathYearHijri! > 0)
                _MetaChip(label: 'الوفاة: ${rawi.deathYearHijri} هـ', isDark: isDark),
              _MetaChip(label: 'الإقامة: ${rawi.livingCity}', isDark: isDark),
              _MetaChip(
                label: 'مروياته في المدونة: ${rawi.totalHadithCountInCorpus}',
                isDark: isDark,
              ),
            ],
          ),
          OTSpacing.gapMd,
          Container(
            padding: const EdgeInsets.all(OTSpacing.md),
            decoration: BoxDecoration(
              color: surfaceSubtle,
              borderRadius: OTRadius.xsBorder,
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'رتبة الحافظ ابن حجر (تقريب التهذيب): ${rawi.martabaIbnHajar}',
                  textDirection: TextDirection.rtl,
                  style: OTTypography.arabicReading(color: textPrimary),
                ),
                OTSpacing.gapXs,
                Text(
                  'رتبة الحافظ الذهبي (الكاشف): ${rawi.martabaDzahabi}',
                  textDirection: TextDirection.rtl,
                  style: OTTypography.arabicReading(color: textSecondary),
                ),
              ],
            ),
          ),
          if (rawi.jarhTadilStatements.isNotEmpty) ...[
            OTSpacing.gapMd,
            Text(
              'أقوال أئمة الجرح والتعديل المصنفة',
              textDirection: TextDirection.rtl,
              style: OTTypography.cardTitle(color: textPrimary),
            ),
            OTSpacing.gapSm,
            for (final st in rawi.jarhTadilStatements)
              Padding(
                padding: const EdgeInsets.only(bottom: OTSpacing.xs),
                child: Text(
                  '• قال ${st.criticArabicName}: «${st.statementArabic}» [${st.sourceBookArabic}]',
                  textDirection: TextDirection.rtl,
                  style: OTTypography.arabicReading(color: textPrimary),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OTSpacing.md,
        vertical: OTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: OTColors.surfaceSubtle(isDark),
        borderRadius: OTRadius.chipBorder,
        border: Border.all(color: OTColors.border(isDark)),
      ),
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: OTTypography.captionMedium(color: OTColors.textPrimary(isDark)),
      ),
    );
  }
}
