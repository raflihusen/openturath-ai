import '../core/design/ot_typography.dart';
import '../core/design/ot_expressive.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';

/// Editorial illustration of the framework described in the introduction.
/// The labels are real text; each sector is reachable without hover.
class TahawwulatDiagram extends StatefulWidget {
  const TahawwulatDiagram(
      {super.key, this.interactive = false, this.inverse = false});
  final bool interactive;
  final bool inverse;
  @override
  State<TahawwulatDiagram> createState() => _TahawwulatDiagramState();
}

class _TahawwulatDiagramState extends State<TahawwulatDiagram> {
  int selected = 3;
  static const arabic = ['الإيمان', 'الإسلام', 'الإحسان', 'علامات الساعة'];
  static const labels = ['Iman', 'Islam', 'Ihsan', 'Tanda-tanda kiamat'];
  static const explanations = [
    'Keyakinan kepada Allah, malaikat, kitab, rasul, hari akhir, dan takdir.',
    'Ibadah dan syariat dalam kehidupan seorang muslim.',
    'Beribadah kepada Allah dengan kesadaran dan kejernihan batin.',
    'Membaca perubahan zaman dalam kerangka Fikih Tahawwulat Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur.',
  ];
  @override
  Widget build(BuildContext context) {
    final ink = widget.inverse
        ? OTExpressive.white
        : Theme.of(context).colorScheme.onSurface;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      AspectRatio(
          aspectRatio: 1.12,
          child: LayoutBuilder(builder: (context, box) {
            final extent = box.maxWidth;
            final positions = [
              (0.30, 0.26),
              (0.70, 0.26),
              (0.70, 0.62),
              (0.30, 0.62)
            ];
            return Stack(children: [
              Positioned.fill(
                  child: ExcludeSemantics(
                      child: CustomPaint(
                          painter: _SectorsPainter(
                              selected: widget.interactive ? selected : -1,
                              inverse: widget.inverse)))),
              for (var i = 0; i < 4; i++)
                Positioned(
                  left: extent * (positions[i].$1 - .22),
                  top: extent * (positions[i].$2 - .10),
                  width: extent * .44,
                  height: extent * .22,
                  child: widget.interactive
                      ? Semantics(
                          selected: selected == i,
                          child: TextButton(
                            onPressed: () => setState(() => selected = i),
                            style: TextButton.styleFrom(
                                foregroundColor: i == selected
                                    ? OTExpressive.white
                                    : widget.inverse
                                        ? OTExpressive.white
                                        : OTExpressive.ink,
                                minimumSize: const Size(48, 48)),
                            child: _label(
                                i,
                                extent,
                                i == selected
                                    ? OTExpressive.white
                                    : widget.inverse
                                        ? OTExpressive.white
                                        : OTExpressive.ink),
                          ))
                      : Center(
                          child: _label(
                              i,
                              extent,
                              widget.inverse
                                  ? OTExpressive.diagramLabel
                                  : OTExpressive.ink)),
                ),
            ]);
          })),
      if (widget.interactive)
        Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(children: [
              Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < 4; i++)
                      ChoiceChip(
                          label: Text(Loc.isArabic ? arabic[i] : labels[i]),
                          selected: selected == i,
                          onSelected: (_) => setState(() => selected = i)),
                  ]),
              const SizedBox(height: 16),
              Semantics(
                  liveRegion: true,
                  child: Text(
                      Loc.isArabic ? arabic[selected] : explanations[selected],
                      textAlign: TextAlign.center,
                      style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s16, height: 1.6, color: ink))),
            ])),
    ]);
  }

  Widget _label(int i, double extent, Color color) =>
      Text(i == 3 ? 'علامات\nالساعة' : arabic[i],
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'NativeArabicUI',
              fontSize: OTExpressive.diagramFontSize(extent),
              fontWeight: FontWeight.w600,
              color: color));
}

class _SectorsPainter extends CustomPainter {
  const _SectorsPainter({required this.selected, required this.inverse});
  final int selected;
  final bool inverse;
  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) * .44;
    final center = Offset(size.width / 2, size.height / 2 - 3);
    final shades =
        inverse ? OTExpressive.diagramDark : OTExpressive.diagramLight;
    for (var i = 0; i < 4; i++) {
      final a = [-math.pi, -math.pi / 2, 0.0, math.pi / 2][i];
      final mid = a + math.pi / 4;
      final c = center + Offset(math.cos(mid) * 7, math.sin(mid) * 7);
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r)
        ..arcTo(Rect.fromCircle(center: c, radius: r), a, math.pi / 2, false)
        ..close();
      canvas.save();
      canvas.translate(0, 5);
      canvas.drawPath(
          path,
          Paint()
            ..color = OTExpressive.diagramEdge
                .withValues(alpha: inverse ? .22 : .18));
      canvas.restore();
      canvas.drawShadow(
          path, OTExpressive.black.withValues(alpha: .15), 3, false);
      canvas.drawPath(
          path,
          Paint()
            ..color = Color(
                i == selected ? OTExpressive.diagramSelected : shades[i]));
    }
  }

  @override
  bool shouldRepaint(_SectorsPainter old) =>
      old.selected != selected || old.inverse != inverse;
}
