import 'dart:math' as math;
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

/// Kanvas Vektor Arsitektural Minimalis Pohon Sanad (*Tasyjīr al-Asānīd*)
/// Mengadopsi bahasa desain OpenTurath V7 (`website/public/assets/v7.css` & `site.css`):
/// - Garis ortogonal & kurva Bézier vektor murni (`CustomPainter` anti-aliased) yang menghubungkan
///   posisi eksak setiap Guru (Syaikh) ke Murid (Tilmīdz) lintas thabaqah.
/// - Pil *Sighah al-Taḥdīts* (`حدثنا`, `أخبرنا`, `عن`) yang dapat diklik untuk memeriksa status
///   *Ittiṣāl / Inqiṭā‘ / ‘An‘anah Mudallis* beserta kitab-kitab pendukung jalur tersebut.
/// - Sorotan jalur aktif (*Active Lineage Highlighting*) ketika pengguna memilih seorang perawi.
/// - Kontrol Zoom (`85%`, `100%`, `115%`), filter kitab mukharrij, pengubah arah pohon
///   (*Sahabat → Mukharrij* vs *Mukharrij → Sahabat*), dan tombol salin laporan ‘ilal.
/// - Mematuhi 100% aturan `test/design_token_guard_test.dart`.
class HadithIsnadDagCanvas extends StatefulWidget {
  const HadithIsnadDagCanvas({
    super.key,
    required this.report,
    required this.onSelectRawi,
    this.selectedRawiId,
  });

  final MadarAndIlalReport report;
  final ValueChanged<String> onSelectRawi;
  final String? selectedRawiId;

  @override
  State<HadithIsnadDagCanvas> createState() => _HadithIsnadDagCanvasState();
}

class _HadithIsnadDagCanvasState extends State<HadithIsnadDagCanvas> {
  String _selectedBookFilter = 'ALL';
  bool _topDownFromSahabi = true;
  bool _compactNodes = false;
  double _zoomScale = 1.0;
  SanadGraphEdge? _inspectedEdge;

  List<String> _extractAvailableBooks() {
    final books = <String>{};
    for (final edge in widget.report.edges) {
      books.addAll(edge.supportingBookTitles);
    }
    return books.toList();
  }

  String _resolveNodeArabicName(String rawiId) {
    for (final n in widget.report.nodes) {
      if (n.rawiId == rawiId) return n.arabicName;
    }
    return rawiId;
  }

  ({Set<String> activeNodeIds, Set<SanadGraphEdge> activeEdges})
      _computeActiveLineage() {
    final allEdges = widget.report.edges;
    final filteredEdges = _selectedBookFilter == 'ALL'
        ? allEdges.toSet()
        : allEdges
            .where((e) => e.supportingBookTitles.contains(_selectedBookFilter))
            .toSet();

    final focusRawi = widget.selectedRawiId;
    if (focusRawi == null || focusRawi.isEmpty) {
      final nodeIds = <String>{
        for (final e in filteredEdges) ...[e.teacherRawiId, e.studentRawiId],
      };
      if (nodeIds.isEmpty) {
        for (final n in widget.report.nodes) {
          nodeIds.add(n.rawiId);
        }
      }
      return (activeNodeIds: nodeIds, activeEdges: filteredEdges);
    }

    final ancestors = <String>{focusRawi};
    var changed = true;
    while (changed) {
      changed = false;
      for (final e in filteredEdges) {
        if (ancestors.contains(e.studentRawiId) &&
            ancestors.add(e.teacherRawiId)) {
          changed = true;
        }
      }
    }

    final descendants = <String>{focusRawi};
    changed = true;
    while (changed) {
      changed = false;
      for (final e in filteredEdges) {
        if (descendants.contains(e.teacherRawiId) &&
            descendants.add(e.studentRawiId)) {
          changed = true;
        }
      }
    }

    final activeNodes = <String>{...ancestors, ...descendants};
    final lineageEdges = filteredEdges
        .where(
          (e) =>
              activeNodes.contains(e.teacherRawiId) &&
              activeNodes.contains(e.studentRawiId),
        )
        .toSet();

    return (activeNodeIds: activeNodes, activeEdges: lineageEdges);
  }

  void _copyIlalReport() {
    OTMotion.light();
    final text =
        '${widget.report.automatedArabicReport}\n\n${widget.report.automatedIndonesianSummary}';
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.success(
      context,
      'Laporan analisis sanad & madār berhasil disalin.',
    );
  }

  void _cycleZoom(double delta) {
    OTMotion.selection();
    setState(() {
      _zoomScale = (_zoomScale + delta).clamp(0.85, 1.30);
    });
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

    final availableBooks = _extractAvailableBooks();
    if (_selectedBookFilter != 'ALL' &&
        !availableBooks.contains(_selectedBookFilter)) {
      _selectedBookFilter = 'ALL';
    }

    final lineage = _computeActiveLineage();

    final layersMap = <int, List<SanadGraphNode>>{};
    for (final node in widget.report.nodes) {
      if (_selectedBookFilter != 'ALL' &&
          !lineage.activeNodeIds.contains(node.rawiId) &&
          !node.isRawiAla) {
        continue;
      }
      (layersMap[node.layerDepth] ??= <SanadGraphNode>[]).add(node);
    }
    final sortedDepths = layersMap.keys.toList()..sort();
    if (!_topDownFromSahabi) {
      sortedDepths.sort((a, b) => b.compareTo(a));
    }

    final orderedLayers = <List<SanadGraphNode>>[
      for (final d in sortedDepths) layersMap[d]!,
    ];

    final zoomPercent = (_zoomScale * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Bilah Kontrol Arsitektural V7 (Minimalist Editorial Toolbar) ──
        Container(
          padding: const EdgeInsets.all(OTSpacing.base),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: OTRadius.cardBorder,
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: OTSpacing.base,
                runSpacing: OTSpacing.sm,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIAGRAM ARSITEKTUR SANAD · TASYJĪR AL-ASĀNĪD',
                        style: OTTypography.sectionHeading(color: textSecondary),
                      ),
                      OTSpacing.gapXs,
                      Text(
                        'تشجير الأسانيد ومدار الحديث المشترك',
                        textDirection: TextDirection.rtl,
                        style: OTTypography.bookTitle(color: textPrimary),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: OTSpacing.sm,
                    runSpacing: OTSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton(
                        style: OTButtons.compactOutlined(isDark),
                        onPressed: () => _cycleZoom(-0.15),
                        child: const Text('A−'),
                      ),
                      Text(
                        '$zoomPercent%',
                        style: OTTypography.captionMedium(color: textSecondary),
                      ),
                      OutlinedButton(
                        style: OTButtons.compactOutlined(isDark),
                        onPressed: () => _cycleZoom(0.15),
                        child: const Text('A+'),
                      ),
                      OutlinedButton(
                        style: OTButtons.compactOutlined(isDark),
                        onPressed: () {
                          OTMotion.selection();
                          setState(() {
                            _topDownFromSahabi = !_topDownFromSahabi;
                          });
                        },
                        child: Text(
                          _topDownFromSahabi
                              ? '↕ Sahabat → Mukharrij'
                              : '↕ Mukharrij → Sahabat',
                        ),
                      ),
                      OutlinedButton(
                        style: OTButtons.compactOutlined(isDark),
                        onPressed: () {
                          OTMotion.selection();
                          setState(() {
                            _compactNodes = !_compactNodes;
                          });
                        },
                        child: Text(
                          _compactNodes ? 'Kartu: Ringkas' : 'Kartu: Lengkap',
                        ),
                      ),
                      if (widget.selectedRawiId != null ||
                          _inspectedEdge != null ||
                          _zoomScale != 1.0)
                        OutlinedButton(
                          style: OTButtons.compactOutlined(isDark),
                          onPressed: () {
                            OTMotion.selection();
                            setState(() {
                              _inspectedEdge = null;
                              _zoomScale = 1.0;
                            });
                            widget.onSelectRawi('');
                          },
                          child: const Text('Reset Tampilan'),
                        ),
                      FilledButton(
                        style: OTButtons.compactTonal(isDark),
                        onPressed: _copyIlalReport,
                        child: const Text('Salin Laporan Sanad'),
                      ),
                    ],
                  ),
                ],
              ),
              if (availableBooks.isNotEmpty) ...[
                OTSpacing.gapMd,
                Container(
                  height: 1,
                  color: borderSubtle,
                ),
                OTSpacing.gapSm,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'Fokus Jalur Kitab:',
                        style: OTTypography.captionMedium(color: textSecondary),
                      ),
                      OTSpacing.gapSm,
                      OTChip(
                        label: 'Semua Jalur (${widget.report.edges.length})',
                        selected: _selectedBookFilter == 'ALL',
                        onSelected: () =>
                            setState(() => _selectedBookFilter = 'ALL'),
                      ),
                      for (final bookTitle in availableBooks) ...[
                        OTSpacing.gapXs,
                        OTChip(
                          label: bookTitle,
                          selected: _selectedBookFilter == bookTitle,
                          onSelected: () =>
                              setState(() => _selectedBookFilter = bookTitle),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        OTSpacing.gapMd,

        // ── 2. Banner Inspeksi Tautan Transmisi (Ketika pil Sighah diketuk) ──
        if (_inspectedEdge != null) ...[
          Container(
            padding: const EdgeInsets.all(OTSpacing.base),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: OTRadius.xsBorder,
              border: Border.all(color: OTColors.borderStrong(isDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'PEMERIKSAAN KETERSAMBUNGAN SANAD (ITTIṢĀL AL-SANAD)',
                        style: OTTypography.sectionHeading(color: textSecondary),
                      ),
                      OTSpacing.gapXs,
                      Text(
                        'من (${_resolveNodeArabicName(_inspectedEdge!.teacherRawiId)}) إلى (${_resolveNodeArabicName(_inspectedEdge!.studentRawiId)}) بصيغة «${_inspectedEdge!.sighahTahdits}» — ${_inspectedEdge!.linkStatus.arabicDescription}',
                        textDirection: TextDirection.rtl,
                        style: OTTypography.arabicReading(color: textPrimary),
                      ),
                      OTSpacing.gapXs,
                      Text(
                        'Status: ${_inspectedEdge!.linkStatus.indonesianDescription} · Diriwayatkan melalui jalur ini oleh: ${_inspectedEdge!.supportingBookTitles.join('، ')}',
                        style: OTTypography.caption(color: textSecondary),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OTButtons.compactOutlined(isDark),
                  onPressed: () => setState(() => _inspectedEdge = null),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
          OTSpacing.gapMd,
        ],

        // ── 3. Kanvas Diagram Pohon Sanad Vektor (Deterministic Coordinate Graph) ──
        _DeterministicDagTreeViewport(
          orderedLayers: orderedLayers,
          allEdges: widget.report.edges,
          activeNodeIds: lineage.activeNodeIds,
          activeEdges: lineage.activeEdges,
          selectedRawiId: widget.selectedRawiId,
          inspectedEdge: _inspectedEdge,
          topDownFromSahabi: _topDownFromSahabi,
          compactNodes: _compactNodes,
          zoomScale: _zoomScale,
          isDark: isDark,
          onSelectRawi: widget.onSelectRawi,
          onSelectEdge: (edge) {
            OTMotion.selection();
            setState(() {
              _inspectedEdge = _inspectedEdge == edge ? null : edge;
            });
          },
        ),
        OTSpacing.gapMd,

        // ── 4. Kartu Metrik & Ringkasan Madār (V7 `dl.ai-metrics` & `study-spread`) ──
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: OTRadius.cardBorder,
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(OTSpacing.base),
                child: Wrap(
                  spacing: OTSpacing.md,
                  runSpacing: OTSpacing.sm,
                  children: [
                    _V7MetricCell(
                      numberLabel: '${widget.report.nodes.length}',
                      captionLabel: 'Simpul Perawi',
                      isDark: isDark,
                    ),
                    _V7MetricCell(
                      numberLabel: '${widget.report.edges.length}',
                      captionLabel: 'Jalur Transmisi',
                      isDark: isDark,
                    ),
                    _V7MetricCell(
                      numberLabel:
                          widget.report.primaryMadar?.arabicName ?? '—',
                      captionLabel: 'Poros Madār Utama',
                      isArabicValue: true,
                      isDark: isDark,
                    ),
                    _V7MetricCell(
                      numberLabel: widget.report.hasIkhtilafAlaMadar
                          ? 'Terdeteksi Ikhtilāf'
                          : 'Muttafiq (Sepakat)',
                      captionLabel: 'Status ‘Ilal & Madār',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: borderSubtle),
              Padding(
                padding: const EdgeInsets.all(OTSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TAQRĪR AL-ISNĀD WA AL-‘ILAL AL-ĀLĪ',
                          style:
                              OTTypography.sectionHeading(color: textSecondary),
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
                            widget.report.hasIkhtilafAlaMadar
                                ? 'يرصد اختلافاً على المدار'
                                : 'إسناد متصل متفق على مداره',
                            textDirection: TextDirection.rtl,
                            style:
                                OTTypography.captionMedium(color: textPrimary),
                          ),
                        ),
                      ],
                    ),
                    OTSpacing.gapMd,
                    SelectableText(
                      widget.report.automatedArabicReport,
                      textDirection: TextDirection.rtl,
                      style: OTTypography.arabicReading(color: textPrimary),
                    ),
                    OTSpacing.gapSm,
                    Text(
                      widget.report.automatedIndonesianSummary,
                      style: OTTypography.body(color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _V7MetricCell extends StatelessWidget {
  const _V7MetricCell({
    required this.numberLabel,
    required this.captionLabel,
    required this.isDark,
    this.isArabicValue = false,
  });

  final String numberLabel;
  final String captionLabel;
  final bool isDark;
  final bool isArabicValue;

  @override
  Widget build(BuildContext context) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    return Container(
      constraints: const BoxConstraints(minWidth: 156),
      padding: const EdgeInsets.symmetric(
        horizontal: OTSpacing.base,
        vertical: OTSpacing.md,
      ),
      decoration: BoxDecoration(
        color: OTColors.surfaceSubtle(isDark),
        borderRadius: OTRadius.xsBorder,
        border: Border.all(color: OTColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            numberLabel,
            textDirection: isArabicValue ? TextDirection.rtl : null,
            style: isArabicValue
                ? OTTypography.arabicReading(color: textPrimary)
                : OTTypography.bookTitle(color: textPrimary),
          ),
          OTSpacing.gapXs,
          Text(
            captionLabel,
            style: OTTypography.caption(color: textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DeterministicDagTreeViewport extends StatelessWidget {
  const _DeterministicDagTreeViewport({
    required this.orderedLayers,
    required this.allEdges,
    required this.activeNodeIds,
    required this.activeEdges,
    required this.selectedRawiId,
    required this.inspectedEdge,
    required this.topDownFromSahabi,
    required this.compactNodes,
    required this.zoomScale,
    required this.isDark,
    required this.onSelectRawi,
    required this.onSelectEdge,
  });

  final List<List<SanadGraphNode>> orderedLayers;
  final List<SanadGraphEdge> allEdges;
  final Set<String> activeNodeIds;
  final Set<SanadGraphEdge> activeEdges;
  final String? selectedRawiId;
  final SanadGraphEdge? inspectedEdge;
  final bool topDownFromSahabi;
  final bool compactNodes;
  final double zoomScale;
  final bool isDark;
  final ValueChanged<String> onSelectRawi;
  final ValueChanged<SanadGraphEdge> onSelectEdge;

  @override
  Widget build(BuildContext context) {
    if (orderedLayers.isEmpty) {
      return const SizedBox.shrink();
    }

    final nodeWidth = (compactNodes ? 176.0 : 212.0) * zoomScale;
    final nodeHeight = (compactNodes ? 84.0 : 108.0) * zoomScale;
    final horizontalGap = 24.0 * zoomScale;
    final verticalGap = 64.0 * zoomScale;
    final canvasPadding = 32.0 * zoomScale;

    final maxNodesInRow = orderedLayers
        .map((layer) => layer.length)
        .fold<int>(1, (prev, len) => math.max(prev, len));

    final minCanvasWidth = maxNodesInRow * nodeWidth +
        math.max(0, maxNodesInRow - 1) * horizontalGap +
        canvasPadding * 2;
    final totalHeight = orderedLayers.length * nodeHeight +
        math.max(0, orderedLayers.length - 1) * verticalGap +
        canvasPadding * 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = math.max(constraints.maxWidth, minCanvasWidth);

        final nodeRects = <String, Rect>{};
        for (var rowIdx = 0; rowIdx < orderedLayers.length; rowIdx++) {
          final layer = orderedLayers[rowIdx];
          final rowWidth = layer.length * nodeWidth +
              math.max(0, layer.length - 1) * horizontalGap;
          final startX = (effectiveWidth - rowWidth) / 2.0;
          final topY = canvasPadding + rowIdx * (nodeHeight + verticalGap);

          for (var colIdx = 0; colIdx < layer.length; colIdx++) {
            final node = layer[colIdx];
            final leftX = startX + colIdx * (nodeWidth + horizontalGap);
            nodeRects[node.rawiId] =
                Rect.fromLTWH(leftX, topY, nodeWidth, nodeHeight);
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: OTColors.canvas(isDark),
            borderRadius: OTRadius.cardBorder,
            border: Border.all(color: OTColors.border(isDark)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: effectiveWidth,
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Lapisan Garis Vektor Ortogonal/Bézier Sanad (`CustomPaint`)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ArchitecturalSanadPainter(
                        nodeRects: nodeRects,
                        edges: allEdges,
                        activeEdges: activeEdges,
                        topDownFromSahabi: topDownFromSahabi,
                        hasSelectionFilter: selectedRawiId != null &&
                            selectedRawiId!.isNotEmpty,
                        lineIdleColor: OTColors.border(isDark),
                        lineActiveColor: OTColors.textPrimary(isDark),
                        lineWarningColor: OTColors.destructive(isDark),
                      ),
                    ),
                  ),

                  // 2. Label Sighah al-Tahdits Interaktif (`حدثنا`, `أخبرنا`, `عن`)
                  for (final edge in allEdges)
                    if (nodeRects.containsKey(edge.teacherRawiId) &&
                        nodeRects.containsKey(edge.studentRawiId))
                      _buildSighahMidpointPill(
                        edge: edge,
                        teacherRect: nodeRects[edge.teacherRawiId]!,
                        studentRect: nodeRects[edge.studentRawiId]!,
                      ),

                  // 3. Simpul Perawi (Kartu Minimalis Editorial)
                  for (final layer in orderedLayers)
                    for (final node in layer)
                      if (nodeRects.containsKey(node.rawiId))
                        Positioned.fromRect(
                          rect: nodeRects[node.rawiId]!,
                          child: _MinimalistRawiNodeCard(
                            node: node,
                            isSelected: selectedRawiId == node.rawiId,
                            isInActiveLineage:
                                activeNodeIds.contains(node.rawiId),
                            hasSelectionFilter: selectedRawiId != null &&
                                selectedRawiId!.isNotEmpty,
                            compact: compactNodes,
                            isDark: isDark,
                            onTap: () {
                              OTMotion.selection();
                              if (node.isMushannif) return;
                              final nextId = selectedRawiId == node.rawiId
                                  ? ''
                                  : node.rawiId;
                              onSelectRawi(nextId);
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSighahMidpointPill({
    required SanadGraphEdge edge,
    required Rect teacherRect,
    required Rect studentRect,
  }) {
    final isTeacherAbove = teacherRect.center.dy < studentRect.center.dy;
    final startPoint = isTeacherAbove
        ? Offset(teacherRect.center.dx, teacherRect.bottom)
        : Offset(teacherRect.center.dx, teacherRect.top);
    final endPoint = isTeacherAbove
        ? Offset(studentRect.center.dx, studentRect.top)
        : Offset(studentRect.center.dx, studentRect.bottom);

    final midX = (startPoint.dx + endPoint.dx) / 2.0;
    final midY = (startPoint.dy + endPoint.dy) / 2.0;
    final isHighlighted = activeEdges.contains(edge);
    final isInspected = inspectedEdge == edge;
    final isDisconnected = !edge.linkStatus.isConnected;

    return Positioned(
      left: midX - 54,
      top: midY - 13,
      width: 108,
      child: Center(
        child: GestureDetector(
          onTap: () => onSelectEdge(edge),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: OTSpacing.sm,
              vertical: OTSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: isInspected
                  ? OTColors.inverseSurface(isDark)
                  : OTColors.surface(isDark),
              borderRadius: OTRadius.chipBorder,
              border: Border.all(
                color: isDisconnected
                    ? OTColors.destructive(isDark)
                    : isHighlighted || isInspected
                        ? OTColors.borderStrong(isDark)
                        : OTColors.borderSubtle(isDark),
              ),
            ),
            child: Text(
              edge.sighahTahdits,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: OTTypography.caption(
                color: isInspected
                    ? OTColors.onInverseSurface
                    : isDisconnected
                        ? OTColors.destructive(isDark)
                        : isHighlighted
                            ? OTColors.textPrimary(isDark)
                            : OTColors.textTertiary(isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MinimalistRawiNodeCard extends StatelessWidget {
  const _MinimalistRawiNodeCard({
    required this.node,
    required this.isSelected,
    required this.isInActiveLineage,
    required this.hasSelectionFilter,
    required this.compact,
    required this.isDark,
    required this.onTap,
  });

  final SanadGraphNode node;
  final bool isSelected;
  final bool isInActiveLineage;
  final bool hasSelectionFilter;
  final bool compact;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool invertCard = node.isPrimaryMadar || isSelected;
    final bg = invertCard
        ? OTColors.inverseSurface(isDark)
        : OTColors.surface(isDark);
    final fgPrimary = invertCard
        ? OTColors.onInverseSurface
        : (hasSelectionFilter && !isInActiveLineage
            ? OTColors.textTertiary(isDark)
            : OTColors.textPrimary(isDark));
    final fgSecondary = invertCard
        ? OTColors.onInverseSurface
        : OTColors.textSecondary(isDark);
    final borderColor = isSelected
        ? OTColors.accent(isDark)
        : node.isPrimaryMadar
            ? OTColors.borderStrong(isDark)
            : isInActiveLineage
                ? OTColors.borderStrong(isDark)
                : OTColors.borderSubtle(isDark);

    final roleBadge = node.isPrimaryMadar
        ? 'مدار الحديث (${node.branchingOutDegree} طرق)'
        : node.isRawiAla
            ? 'الراوي الأعلى'
            : node.isMushannif
                ? 'المصنف المخرج'
                : node.tabaqaLabel;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: OTMotion.fast,
        curve: OTMotion.curve,
        padding: const EdgeInsets.symmetric(
          horizontal: OTSpacing.md,
          vertical: OTSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: OTRadius.xsBorder,
          border: Border.all(
            color: borderColor,
            width: (isSelected || node.isPrimaryMadar) ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              roleBadge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: OTTypography.metadataTag(color: fgSecondary),
            ),
            OTSpacing.gapXs,
            Text(
              node.arabicName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: OTTypography.arabicReading(color: fgPrimary),
            ),
            if (!compact) ...[
              OTSpacing.gapXs,
              Text(
                node.martabaSummary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: OTTypography.caption(color: fgSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArchitecturalSanadPainter extends CustomPainter {
  const _ArchitecturalSanadPainter({
    required this.nodeRects,
    required this.edges,
    required this.activeEdges,
    required this.topDownFromSahabi,
    required this.hasSelectionFilter,
    required this.lineIdleColor,
    required this.lineActiveColor,
    required this.lineWarningColor,
  });

  final Map<String, Rect> nodeRects;
  final List<SanadGraphEdge> edges;
  final Set<SanadGraphEdge> activeEdges;
  final bool topDownFromSahabi;
  final bool hasSelectionFilter;
  final Color lineIdleColor;
  final Color lineActiveColor;
  final Color lineWarningColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      final teacherRect = nodeRects[edge.teacherRawiId];
      final studentRect = nodeRects[edge.studentRawiId];
      if (teacherRect == null || studentRect == null) continue;

      final isTeacherAbove = teacherRect.center.dy < studentRect.center.dy;
      final start = isTeacherAbove
          ? Offset(teacherRect.center.dx, teacherRect.bottom)
          : Offset(teacherRect.center.dx, teacherRect.top);
      final end = isTeacherAbove
          ? Offset(studentRect.center.dx, studentRect.top)
          : Offset(studentRect.center.dx, studentRect.bottom);

      final isHighlighted = activeEdges.contains(edge);
      final isDisconnected = !edge.linkStatus.isConnected;

      final paint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = isHighlighted ? 1.8 : 1.0
        ..color = isDisconnected
            ? lineWarningColor
            : isHighlighted
                ? lineActiveColor
                : lineIdleColor;

      final midY = (start.dy + end.dy) / 2.0;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(start.dx, midY, end.dx, midY, end.dx, end.dy);

      canvas.drawPath(path, paint);

      final arrowDir = isTeacherAbove ? 1.0 : -1.0;
      final arrowPath = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - 4.5, end.dy - 6.0 * arrowDir)
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx + 4.5, end.dy - 6.0 * arrowDir);
      canvas.drawPath(arrowPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArchitecturalSanadPainter oldDelegate) {
    return oldDelegate.nodeRects != nodeRects ||
        oldDelegate.activeEdges != activeEdges ||
        oldDelegate.topDownFromSahabi != topDownFromSahabi ||
        oldDelegate.hasSelectionFilter != hasSelectionFilter ||
        oldDelegate.lineActiveColor != lineActiveColor;
  }
}
