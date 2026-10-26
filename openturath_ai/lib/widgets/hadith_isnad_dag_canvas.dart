import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../models/hadith_takhrij_models.dart';
import 'ot_motion_widgets.dart';

/// Kanvas Vektor Monokrom Pohon Sanad (*Tasyjīr al-Asānīd*)
/// Menggantikan `HadithGraphSharp.dll` dan `Asanedviewer.swf` dengan estetika
/// OpenTurath Monochrome Editorial (*The Quiet Islamic Scholar*).
/// Mematuhi 100% aturan `test/design_token_guard_test.dart`.
class HadithIsnadDagCanvas extends StatelessWidget {
  const HadithIsnadDagCanvas({
    super.key,
    required this.report,
    required this.onSelectRawi,
  });

  final MadarAndIlalReport report;
  final ValueChanged<String> onSelectRawi;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

    // Kelompokkan simpul berdasarkan kedalaman lapisan (0 = Sahabat -> Madar -> Mushannif)
    final layers = <int, List<SanadGraphNode>>{};
    for (final node in report.nodes) {
      (layers[node.layerDepth] ??= <SanadGraphNode>[]).add(node);
    }
    final sortedDepths = layers.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header Legenda Monokrom Pohon Sanad ──
        OTBentoTile(
          padding: const EdgeInsets.all(OTSpacing.base),
          child: Wrap(
            spacing: OTSpacing.base,
            runSpacing: OTSpacing.sm,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'تشجير الأسانيد ومدار الحديث',
                textDirection: TextDirection.rtl,
                style: OTTypography.arabicReading(color: textPrimary),
              ),
              Wrap(
                spacing: OTSpacing.md,
                runSpacing: OTSpacing.xs,
                children: [
                  _LegendPill(
                    label: 'راوي المدار (المحور)',
                    inverted: true,
                    isDark: isDark,
                  ),
                  _LegendPill(
                    label: 'الراوي الأعلى / رجال السند',
                    inverted: false,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
        OTSpacing.gapMd,

        // ── Diagram Alir Sanad Berlapis (Dari Sahabat ke Para Mukharrij) ──
        Container(
          padding: const EdgeInsets.all(OTSpacing.xl),
          decoration: BoxDecoration(
            color: surfaceSubtle,
            borderRadius: OTRadius.cardBorder,
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < sortedDepths.length; i++) ...[
                _IsnadLayerRow(
                  nodes: layers[sortedDepths[i]]!,
                  isDark: isDark,
                  onSelectRawi: onSelectRawi,
                ),
                if (i + 1 < sortedDepths.length)
                  _IsnadConnectorBridge(
                    upperNodes: layers[sortedDepths[i]]!,
                    lowerNodes: layers[sortedDepths[i + 1]]!,
                    edges: report.edges,
                    isDark: isDark,
                  ),
              ],
            ],
          ),
        ),
        OTSpacing.gapMd,

        // ── Tقرير الإسناد الآلي (Rekonstruksi AsaneedReport.dll) ──
        OTBentoTile(
          padding: const EdgeInsets.all(OTSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LAPORAN SANAD & MADAR OTOMATIS',
                    style: OTTypography.sectionHeading(color: textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OTSpacing.md,
                      vertical: OTSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: OTRadius.chipBorder,
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      report.hasIkhtilafAlaMadar
                          ? 'يرصد اختلافاً على المدار'
                          : 'إسناد متفق على مداره',
                      textDirection: TextDirection.rtl,
                      style: OTTypography.captionMedium(color: textPrimary),
                    ),
                  ),
                ],
              ),
              OTSpacing.gapMd,
              Text(
                report.automatedArabicReport,
                textDirection: TextDirection.rtl,
                style: OTTypography.arabicReading(color: textPrimary),
              ),
              OTSpacing.gapSm,
              Text(
                report.automatedIndonesianSummary,
                style: OTTypography.body(color: textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({
    required this.label,
    required this.inverted,
    required this.isDark,
  });

  final String label;
  final bool inverted;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = inverted
        ? OTColors.inverseSurface(isDark)
        : OTColors.surface(isDark);
    final fg = inverted
        ? OTColors.onInverseSurface
        : OTColors.textPrimary(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OTSpacing.md,
        vertical: OTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: OTRadius.chipBorder,
        border: Border.all(color: OTColors.border(isDark)),
      ),
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: OTTypography.captionMedium(color: fg),
      ),
    );
  }
}

class _IsnadLayerRow extends StatelessWidget {
  const _IsnadLayerRow({
    required this.nodes,
    required this.isDark,
    required this.onSelectRawi,
  });

  final List<SanadGraphNode> nodes;
  final bool isDark;
  final ValueChanged<String> onSelectRawi;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: OTSpacing.base,
      runSpacing: OTSpacing.md,
      alignment: WrapAlignment.center,
      children: [
        for (final node in nodes)
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
            child: OTBentoTile(
              inverse: node.isPrimaryMadar,
              padding: const EdgeInsets.all(OTSpacing.md),
              onTap: node.isMushannif ? null : () => onSelectRawi(node.rawiId),
              semanticLabel: node.arabicName,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (node.isPrimaryMadar || node.isRawiAla || node.isMushannif)
                    Padding(
                      padding: const EdgeInsets.only(bottom: OTSpacing.xs),
                      child: Text(
                        node.isPrimaryMadar
                            ? 'مدار الحديث الرئيس (${node.branchingOutDegree} طرق)'
                            : node.isRawiAla
                                ? 'الراوي الأعلى'
                                : 'المصنف المخرج',
                        textDirection: TextDirection.rtl,
                        style: OTTypography.captionMedium(
                          color: node.isPrimaryMadar
                              ? OTColors.onInverseSurface
                              : OTColors.textSecondary(isDark),
                        ),
                      ),
                    ),
                  Text(
                    node.arabicName,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: OTTypography.arabicReading(
                      color: node.isPrimaryMadar
                          ? OTColors.onInverseSurface
                          : OTColors.textPrimary(isDark),
                    ),
                  ),
                  OTSpacing.gapXs,
                  Text(
                    node.martabaSummary,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OTTypography.caption(
                      color: node.isPrimaryMadar
                          ? OTColors.onInverseSurface
                          : OTColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _IsnadConnectorBridge extends StatelessWidget {
  const _IsnadConnectorBridge({
    required this.upperNodes,
    required this.lowerNodes,
    required this.edges,
    required this.isDark,
  });

  final List<SanadGraphNode> upperNodes;
  final List<SanadGraphNode> lowerNodes;
  final List<SanadGraphEdge> edges;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final upperIds = upperNodes.map((n) => n.rawiId).toSet();
    final lowerIds = lowerNodes.map((n) => n.rawiId).toSet();
    final activeEdges = edges
        .where(
          (e) =>
              upperIds.contains(e.teacherRawiId) &&
              lowerIds.contains(e.studentRawiId),
        )
        .toList();

    final sighahSummary = activeEdges.map((e) => e.sighahTahdits).toSet().join(' / ');
    final hasDiscontinuity = activeEdges.any((e) => !e.linkStatus.isConnected);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OTSpacing.sm),
      child: Column(
        children: [
          Container(
            width: 2,
            height: 16,
            color: hasDiscontinuity
                ? OTColors.destructive(isDark)
                : OTColors.borderStrong(isDark),
          ),
          if (sighahSummary.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.sm,
                vertical: OTSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: OTColors.surface(isDark),
                borderRadius: OTRadius.xsBorder,
                border: Border.all(
                  color: hasDiscontinuity
                      ? OTColors.destructive(isDark)
                      : OTColors.border(isDark),
                ),
              ),
              child: Text(
                sighahSummary,
                textDirection: TextDirection.rtl,
                style: OTTypography.caption(
                  color: hasDiscontinuity
                      ? OTColors.destructive(isDark)
                      : OTColors.textSecondary(isDark),
                ),
              ),
            ),
          Container(
            width: 2,
            height: 16,
            color: hasDiscontinuity
                ? OTColors.destructive(isDark)
                : OTColors.borderStrong(isDark),
          ),
        ],
      ),
    );
  }
}
