import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_snackbar.dart';
import '../core/design/ot_buttons.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../models/hadith_takhrij_models.dart';
import 'ot_components.dart';
import 'ot_motion_widgets.dart';

/// Kartu Tampilan **Al-Matn al-Mujamma‘** (Matan Komposit Lintas Riwayat)
/// Mengadopsi estetika OpenTurath V7 (`study-spread` & `kurasi-list`):
/// - Menggantikan warna biru `<MMHit>` di `HadithXSLN.xsl` dengan sorotan monokromatis
///   editorial (`OTColors.inverseSurface` saat dipilih) dan nomor seri catatan kaki `(1)`, `(2)`.
/// - Semua tombol (`Salin Matan Komposit`, `Simpan ke Tersimpan`, `Reset Pilihan`) berfungsi penuh.
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

  void _copyCompositeText() {
    OTMotion.light();
    final fullText = widget.compositeMatn.segments
        .map(
          (s) => s.footnoteIndex != null
              ? '${s.arabicText} (${s.footnoteIndex})'
              : s.arabicText,
        )
        .join(' ');
    final footnotes = widget.compositeMatn.segments
        .where((s) => s.footnoteIndex != null)
        .map(
          (s) =>
              '(${s.footnoteIndex}) ${s.arabicText} — أخرجه: ${s.sourceCitations.join('، ')}',
        )
        .join('\n');
    final combined = footnotes.isEmpty ? fullText : '$fullText\n\n$footnotes';
    Clipboard.setData(ClipboardData(text: combined));
    AppSnackBar.success(
      context,
      'Matan komposit (Al-Matn al-Mujamma‘) beserta catatan kaki berhasil disalin.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final borderSubtle = OTColors.borderSubtle(isDark);
    final borderStrong = OTColors.borderStrong(isDark);

    final zawaidSegments = widget.compositeMatn.segments
        .where((s) => s.footnoteIndex != null)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: OTRadius.cardBorder,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header Bergaya Website V7 (`study-spread` top bar) ──
          Padding(
            padding: const EdgeInsets.all(OTSpacing.lg),
            child: Wrap(
              spacing: OTSpacing.base,
              runSpacing: OTSpacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AL-MATN AL-MUJAMMA‘ · SINTESIS LINTAS RIWAYAT',
                      style: OTTypography.sectionHeading(color: textSecondary),
                    ),
                    OTSpacing.gapXs,
                    Text(
                      'المتن المجمع والزوائد الحديثية',
                      textDirection: TextDirection.rtl,
                      style: OTTypography.bookTitle(color: textPrimary),
                    ),
                    OTSpacing.gapXs,
                    Text(
                      'الأصل المعتمد: ${widget.compositeMatn.baseHadith.bookTitleArabic} ${widget.compositeMatn.baseHadith.formattedCitation}',
                      textDirection: TextDirection.rtl,
                      style: OTTypography.caption(color: textSecondary),
                    ),
                  ],
                ),
                Wrap(
                  spacing: OTSpacing.sm,
                  runSpacing: OTSpacing.xs,
                  children: [
                    if (_selectedFootnoteIndex != null)
                      OutlinedButton(
                        style: OTButtons.compactOutlined(isDark),
                        onPressed: () {
                          OTMotion.selection();
                          setState(() => _selectedFootnoteIndex = null);
                        },
                        child: const Text('Tampilkan Semua'),
                      ),
                    OutlinedButton(
                      style: OTButtons.compactOutlined(isDark),
                      onPressed: _copyCompositeText,
                      child: const Text('Salin Matan Komposit'),
                    ),
                    if (widget.onSaveToMejaTelaah != null)
                      FilledButton(
                        style: OTButtons.compactTonal(isDark),
                        onPressed: widget.onSaveToMejaTelaah,
                        child: const Text('＋ Simpan ke Tersimpan'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: borderSubtle),

          // ── Blok Matan Komposit Interaktif ──
          Padding(
            padding: const EdgeInsets.all(OTSpacing.xl),
            child: Container(
              padding: const EdgeInsets.all(OTSpacing.lg),
              decoration: BoxDecoration(
                color: surfaceSubtle,
                borderRadius: OTRadius.xsBorder,
                border: Border.all(color: border),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Wrap(
                  spacing: OTSpacing.sm,
                  runSpacing: OTSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                          onTap: () {
                            OTMotion.selection();
                            setState(() {
                              _selectedFootnoteIndex =
                                  _selectedFootnoteIndex == seg.footnoteIndex
                                      ? null
                                      : seg.footnoteIndex;
                            });
                          },
                          child: AnimatedContainer(
                            duration: OTMotion.fast,
                            curve: OTMotion.curve,
                            padding: const EdgeInsets.symmetric(
                              horizontal: OTSpacing.md,
                              vertical: OTSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedFootnoteIndex == seg.footnoteIndex
                                  ? OTColors.inverseSurface(isDark)
                                  : surface,
                              borderRadius: OTRadius.xsBorder,
                              border: Border.all(
                                color:
                                    _selectedFootnoteIndex == seg.footnoteIndex
                                        ? OTColors.accent(isDark)
                                        : borderStrong,
                              ),
                            ),
                            child: Text(
                              '${seg.arabicText} (${seg.footnoteIndex})',
                              textDirection: TextDirection.rtl,
                              style: OTTypography.arabicReading(
                                color:
                                    _selectedFootnoteIndex == seg.footnoteIndex
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
          ),

          // ── Daftar Catatan Kaki Zawa'id Bergaya V7 (`kurasi-list`) ──
          if (zawaidSegments.isNotEmpty) ...[
            Container(height: 1, color: borderSubtle),
            Padding(
              padding: const EdgeInsets.all(OTSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'مصادر الزوائد والفروق اللفظية في المتن المجمع (${zawaidSegments.length})',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.cardTitle(color: textPrimary),
                  ),
                  OTSpacing.gapMd,
                  for (final z in zawaidSegments)
                    if (_selectedFootnoteIndex == null ||
                        _selectedFootnoteIndex == z.footnoteIndex)
                      Padding(
                        padding: const EdgeInsets.only(bottom: OTSpacing.sm),
                        child: OTBentoTile(
                          inverse: _selectedFootnoteIndex == z.footnoteIndex,
                          padding: const EdgeInsets.all(OTSpacing.md),
                          onTap: () {
                            setState(() {
                              _selectedFootnoteIndex =
                                  _selectedFootnoteIndex == z.footnoteIndex
                                      ? null
                                      : z.footnoteIndex;
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: OTSpacing.sm,
                                  vertical: OTSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedFootnoteIndex == z.footnoteIndex
                                          ? OTColors.surface(isDark)
                                          : OTColors.inverseSurface(isDark),
                                  borderRadius: OTRadius.chipBorder,
                                ),
                                child: Text(
                                  '0${z.footnoteIndex}',
                                  style: OTTypography.captionMedium(
                                    color: _selectedFootnoteIndex ==
                                            z.footnoteIndex
                                        ? textPrimary
                                        : OTColors.onInverseSurface,
                                  ),
                                ),
                              ),
                              OTSpacing.gapMd,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      z.arabicText,
                                      textDirection: TextDirection.rtl,
                                      style: OTTypography.arabicReading(
                                        color: _selectedFootnoteIndex ==
                                                z.footnoteIndex
                                            ? OTColors.onInverseSurface
                                            : textPrimary,
                                      ),
                                    ),
                                    OTSpacing.gapXs,
                                    Text(
                                      'المصادر المخرجة لهذه الزيادة: ${z.sourceCitations.join(' · ')}',
                                      textDirection: TextDirection.rtl,
                                      style: OTTypography.caption(
                                        color: _selectedFootnoteIndex ==
                                                z.footnoteIndex
                                            ? OTColors.onInverseSurface
                                            : textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu Matriks **27-Aturan Muqāranat al-Mutūn** bergaya Website V7 (`case-preview` & `kitab-row`).
class MatnComparisonOutcomeCard extends StatelessWidget {
  const MatnComparisonOutcomeCard({
    super.key,
    required this.outcome,
    this.serialNumber,
    this.onTapBook,
  });

  final MatnComparisonOutcome outcome;
  final int? serialNumber;
  final VoidCallback? onTapBook;

  void _copyOutcomeCitation(BuildContext context) {
    OTMotion.light();
    final text =
        '${outcome.targetBook.formatAttributionPhrase(isFirstInChain: true)} ${outcome.targetHadith.formattedCitation} (${outcome.formattedArabicVerdict})\n«${outcome.targetHadith.rawMatn}»';
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.success(
      context,
      'Kutipan takhrij ${outcome.targetBook.titleArabic} berhasil disalin.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);
    final borderSubtle = OTColors.borderSubtle(isDark);
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

    final taxonomyBadge = switch (outcome.targetBook.taxonomy) {
      HadithBookTaxonomy.musnadPrimary => 'كتاب مسند أصلي · أخرجه',
      HadithBookTaxonomy.zawaidNarrator => 'زوائد الرواة · في زوائده',
      HadithBookTaxonomy.secondaryCompilation => 'مصنف جامع · أورده',
      HadithBookTaxonomy.mustakhraj => 'مستخرج · أخرجه',
      HadithBookTaxonomy.muqaddimah => 'مقدمة الكتاب · أخرجه',
      HadithBookTaxonomy.serviceSharhTakhrij => 'شرح وتخريج · ذكره',
    };

    final originPercent = (outcome.rootCoverageOnOrigin * 100).round();
    final targetPercent = (outcome.rootCoverageOnTarget * 100).round();
    final seqPercent = (outcome.sequenceOrderRatio * 100).round();
    final serialStr = serialNumber != null
        ? serialNumber!.toString().padLeft(2, '0')
        : '•';

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: OTRadius.cardBorder,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Baris Atas: Nomor Seri V7 + Lencana Kaidah #1-27 + Metrik Tabular ──
          Padding(
            padding: const EdgeInsets.all(OTSpacing.base),
            child: Wrap(
              spacing: OTSpacing.sm,
              runSpacing: OTSpacing.xs,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  spacing: OTSpacing.sm,
                  runSpacing: OTSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      serialStr,
                      style: OTTypography.metadataTag(color: textSecondary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md,
                        vertical: OTSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceSubtle,
                        borderRadius: OTRadius.chipBorder,
                        border: Border.all(color: border),
                      ),
                      child: Text(
                        outcome.mutabaahRank.arabicLabel,
                        textDirection: TextDirection.rtl,
                        style: OTTypography.caption(color: textPrimary),
                      ),
                    ),
                  ],
                ),
                Text(
                  'الأصل: $originPercent% · المقابل: $targetPercent% · التتابع: $seqPercent%',
                  textDirection: TextDirection.rtl,
                  style: OTTypography.captionMedium(color: textSecondary),
                ),
              ],
            ),
          ),
          Container(height: 1, color: borderSubtle),

          // ── Isi Utama: Atribusi Kitab, Verdict 27 Kaidah, & Kutipan Matan ──
          Padding(
            padding: const EdgeInsets.all(OTSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${outcome.targetBook.formatAttributionPhrase(isFirstInChain: true)} ${outcome.targetHadith.formattedCitation}',
                            textDirection: TextDirection.rtl,
                            style: OTTypography.arabicReading(color: textPrimary),
                          ),
                          OTSpacing.gapXs,
                          Text(
                            '${outcome.targetHadith.sectionTitle} — ${outcome.targetHadith.chapterTitle} · طبعة: ${outcome.targetBook.primaryPrintEdition}',
                            textDirection: TextDirection.rtl,
                            style: OTTypography.caption(color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    OTSpacing.gapMd,
                    Wrap(
                      spacing: OTSpacing.xs,
                      children: [
                        OutlinedButton(
                          style: OTButtons.compactOutlined(isDark),
                          onPressed: () => _copyOutcomeCitation(context),
                          child: const Text('Salin'),
                        ),
                        if (onTapBook != null)
                          FilledButton(
                            style: OTButtons.compactTonal(isDark),
                            onPressed: onTapBook,
                            child: const Text('Buka di Tab Baru ↗'),
                          ),
                      ],
                    ),
                  ],
                ),
                OTSpacing.gapMd,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OTSpacing.md,
                    vertical: OTSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceSubtle,
                    borderRadius: OTRadius.xsBorder,
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    'صيغة المقارنة اللفظية: ${outcome.formattedArabicVerdict}${outcome.pivotRawiArabicName != null ? ' · مدار الالتقاء: ${outcome.pivotRawiArabicName}' : ''}',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.arabicReading(color: textPrimary),
                  ),
                ),
                OTSpacing.gapSm,
                Container(
                  padding: const EdgeInsets.all(OTSpacing.md),
                  decoration: BoxDecoration(
                    color: OTColors.canvas(isDark),
                    borderRadius: OTRadius.xsBorder,
                    border: Border.all(color: borderSubtle),
                  ),
                  child: SelectableText(
                    '« ${outcome.targetHadith.rawMatn} »',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.arabicReading(color: textPrimary),
                  ),
                ),
                if (outcome.diffSegments.isNotEmpty) ...[
                  OTSpacing.gapSm,
                  Text(
                    'مقاطع الفروق والزوائد المرصودة (≤ ١٥ كلمة): ${outcome.diffSegments.map((d) => '«$d»').join(' ، ')}',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.caption(color: textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel Inspector Biografi Perawi (*Tarjamat al-Rāwī & Aqwāl al-Jarḥ wa al-Ta‘dīl*)
/// Mengadopsi gaya `bibliography-sheet` & `dl.metadata` dari Website V7.
class RawiBiographyInspectorCard extends StatelessWidget {
  const RawiBiographyInspectorCard({
    super.key,
    required this.rawi,
    this.resolveRawiName,
    this.onSelectRelatedRawiId,
    this.onClose,
  });

  final RawiBiographyRecord rawi;
  final String Function(String rawiId)? resolveRawiName;
  final ValueChanged<String>? onSelectRelatedRawiId;
  final VoidCallback? onClose;

  void _copyBiography(BuildContext context) {
    OTMotion.light();
    final jarhText = rawi.jarhTadilStatements
        .map(
          (s) =>
              '- قال ${s.criticArabicName}: «${s.statementArabic}» [${s.sourceBookArabic}]',
        )
        .join('\n');
    final summary =
        '${rawi.fullNameArabic} (${rawi.esmShuhra})\n${rawi.tabaqaArabic} · الوفاة: ${rawi.deathYearHijri ?? '—'} هـ · الإقامة: ${rawi.livingCity}\nرتبة ابن حجر: ${rawi.martabaIbnHajar}\nرتبة الذهبي: ${rawi.martabaDzahabi}\n$jarhText';
    Clipboard.setData(ClipboardData(text: summary));
    AppSnackBar.success(
      context,
      'Biografi ${rawi.esmShuhra} berhasil disalin.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);
    final borderSubtle = OTColors.borderSubtle(isDark);
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: OTRadius.cardBorder,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header Biografi Perawi ──
          Padding(
            padding: const EdgeInsets.all(OTSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TARJAMAT AL-RĀWĪ · بطاقة الراوي',
                      style: OTTypography.sectionHeading(color: textSecondary),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          style: OTButtons.compactOutlined(isDark),
                          onPressed: () => _copyBiography(context),
                          child: const Text('Salin'),
                        ),
                        if (onClose != null) ...[
                          OTSpacing.gapXs,
                          OutlinedButton(
                            style: OTButtons.compactOutlined(isDark),
                            onPressed: onClose,
                            child: const Text('Tutup'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                OTSpacing.gapSm,
                Text(
                  rawi.fullNameArabic,
                  textDirection: TextDirection.rtl,
                  style: OTTypography.arabicDisplay(color: textPrimary),
                ),
                if (rawi.isMudallis || rawi.isMukhtalith) ...[
                  OTSpacing.gapXs,
                  Wrap(
                    spacing: OTSpacing.xs,
                    children: [
                      if (rawi.isMudallis)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OTSpacing.sm,
                            vertical: OTSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: surfaceSubtle,
                            borderRadius: OTRadius.chipBorder,
                            border: Border.all(
                              color: OTColors.borderStrong(isDark),
                            ),
                          ),
                          child: Text(
                            'موصوف بالتدليس (تُفحص عنعنته)',
                            textDirection: TextDirection.rtl,
                            style: OTTypography.captionMedium(color: textPrimary),
                          ),
                        ),
                      if (rawi.isMukhtalith)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OTSpacing.sm,
                            vertical: OTSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: surfaceSubtle,
                            borderRadius: OTRadius.chipBorder,
                            border: Border.all(
                              color: OTColors.borderStrong(isDark),
                            ),
                          ),
                          child: Text(
                            'تغير بأخرة (يفصل من سمع منه قديماً)',
                            textDirection: TextDirection.rtl,
                            style: OTTypography.captionMedium(color: textPrimary),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(height: 1, color: borderSubtle),

          // ── Tabel Metadata V7 (`dl.ai-facts` / `dl.metadata`) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OTSpacing.base),
            child: Column(
              children: [
                _V7FactRow(
                  label: 'اسم الشهرة والكنية',
                  value:
                      '${rawi.esmShuhra}${rawi.kunia.isNotEmpty ? ' · ${rawi.kunia}' : ''}',
                  isDark: isDark,
                ),
                _V7FactRow(
                  label: 'الطبقة',
                  value: rawi.tabaqaArabic,
                  isDark: isDark,
                ),
                _V7FactRow(
                  label: 'سنة الوفاة والإقامة',
                  value:
                      '${rawi.deathYearHijri != null && rawi.deathYearHijri! > 0 ? '${rawi.deathYearHijri} هـ' : 'صحابي'} · ${rawi.livingCity}',
                  isDark: isDark,
                ),
                _V7FactRow(
                  label: 'مروياته في المدونة',
                  value: '${rawi.totalHadithCountInCorpus} حديثاً',
                  isDark: isDark,
                ),
                _V7FactRow(
                  label: 'رتبة ابن حجر (التقريب)',
                  value: rawi.martabaIbnHajar,
                  isDark: isDark,
                ),
                _V7FactRow(
                  label: 'رتبة الذهبي (الكاشف)',
                  value: rawi.martabaDzahabi,
                  isDark: isDark,
                  showBottomBorder: false,
                ),
              ],
            ),
          ),

          // ── Navigasi Guru (Syuyukh) & Murid (Talamidz) Interaktif ──
          if (rawi.shyoukhIds.isNotEmpty || rawi.talamizIds.isNotEmpty) ...[
            Container(height: 1, color: borderSubtle),
            Padding(
              padding: const EdgeInsets.all(OTSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (rawi.shyoukhIds.isNotEmpty) ...[
                    Text(
                      'شيوخه في الإسناد (اضغط للانتقال):',
                      textDirection: TextDirection.rtl,
                      style: OTTypography.captionMedium(color: textSecondary),
                    ),
                    OTSpacing.gapXs,
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Wrap(
                        spacing: OTSpacing.xs,
                        runSpacing: OTSpacing.xs,
                        children: [
                          for (final shId in rawi.shyoukhIds)
                            OTChip(
                              label: resolveRawiName?.call(shId) ?? shId,
                              selected: false,
                              onSelected: () =>
                                  onSelectRelatedRawiId?.call(shId),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (rawi.shyoukhIds.isNotEmpty && rawi.talamizIds.isNotEmpty)
                    OTSpacing.gapSm,
                  if (rawi.talamizIds.isNotEmpty) ...[
                    Text(
                      'تلاميذه الرواة عنه (اضغط للانتقال):',
                      textDirection: TextDirection.rtl,
                      style: OTTypography.captionMedium(color: textSecondary),
                    ),
                    OTSpacing.gapXs,
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Wrap(
                        spacing: OTSpacing.xs,
                        runSpacing: OTSpacing.xs,
                        children: [
                          for (final stId in rawi.talamizIds)
                            OTChip(
                              label: resolveRawiName?.call(stId) ?? stId,
                              selected: false,
                              onSelected: () =>
                                  onSelectRelatedRawiId?.call(stId),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // ── Pernyataan Ulama Jarh wa Ta'dil ──
          if (rawi.jarhTadilStatements.isNotEmpty) ...[
            Container(height: 1, color: borderSubtle),
            Padding(
              padding: const EdgeInsets.all(OTSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'أقوال أئمة الجرح والتعديل المصنفة (${rawi.jarhTadilStatements.length})',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.cardTitle(color: textPrimary),
                  ),
                  OTSpacing.gapSm,
                  for (final st in rawi.jarhTadilStatements)
                    Padding(
                      padding: const EdgeInsets.only(bottom: OTSpacing.xs),
                      child: Container(
                        padding: const EdgeInsets.all(OTSpacing.sm),
                        decoration: BoxDecoration(
                          color: surfaceSubtle,
                          borderRadius: OTRadius.xsBorder,
                          border: Border.all(color: borderSubtle),
                        ),
                        child: Text(
                          '• قال ${st.criticArabicName}${st.transmitterArabicName != null ? ' (رواية ${st.transmitterArabicName})' : ''}: «${st.statementArabic}» — ${st.sourceBookArabic}',
                          textDirection: TextDirection.rtl,
                          style: OTTypography.arabicReading(color: textPrimary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _V7FactRow extends StatelessWidget {
  const _V7FactRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.showBottomBorder = true,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: OTSpacing.sm),
      decoration: BoxDecoration(
        border: showBottomBorder
            ? Border(
                bottom: BorderSide(color: OTColors.borderSubtle(isDark)),
              )
            : null,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: OTTypography.caption(
                color: OTColors.textSecondary(isDark),
              ),
            ),
            OTSpacing.gapMd,
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.left,
                textDirection: TextDirection.rtl,
                style: OTTypography.arabicReading(
                  color: OTColors.textPrimary(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
