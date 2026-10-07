import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';

/// Editorial illustration of the framework described in the introduction.
/// The labels are real text; each sector is reachable without hover.
class TahawwulatDiagram extends StatefulWidget {
  const TahawwulatDiagram({super.key, this.interactive = false, this.inverse = false});
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
    final ink = widget.inverse ? Colors.white : Theme.of(context).colorScheme.onSurface;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      AspectRatio(aspectRatio: 1.12, child: LayoutBuilder(builder: (context, box) {
        final extent = box.maxWidth;
        final positions = [(0.27,0.28),(0.73,0.28),(0.73,0.70),(0.27,0.70)];
        return Stack(children: [
          Positioned.fill(child: ExcludeSemantics(child: CustomPaint(painter: _SectorsPainter(selected: widget.interactive ? selected : -1, inverse: widget.inverse)))),
          for (var i=0; i<4; i++) Positioned(
            left: extent * (positions[i].$1 - .22), top: extent * (positions[i].$2 - .10),
            width: extent * .44, height: extent * .22,
            child: widget.interactive ? Semantics(selected: selected == i, child: TextButton(
              onPressed: () => setState(() => selected = i),
              style: TextButton.styleFrom(foregroundColor: i == selected ? Colors.white : ink, minimumSize: const Size(48,48)),
              child: _label(i, extent, i == selected ? Colors.white : ink),
            )) : Center(child: _label(i, extent, widget.inverse ? const Color(0xFFEEEEEE) : const Color(0xFF252525))),
          ),
        ]);
      })),
      if (widget.interactive) Padding(padding: const EdgeInsets.only(top: 12), child: Column(children: [
        Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
          for(var i=0; i<4;i++) ChoiceChip(label: Text(Loc.isArabic ? arabic[i] : labels[i]), selected: selected == i, onSelected: (_) => setState(() => selected = i)),
        ]),
        const SizedBox(height: 16),
        Semantics(liveRegion: true, child: Text(Loc.isArabic ? arabic[selected] : explanations[selected], textAlign: TextAlign.center, style: ScholarlyFonts.outfit(fontSize: 16, height: 1.6, color: ink))),
      ])),
    ]);
  }
  Widget _label(int i,double extent,Color color) => Text(arabic[i], textDirection: TextDirection.rtl, textAlign: TextAlign.center,
    style: TextStyle(fontFamily: 'NativeArabicUI', fontSize: (extent / 17).clamp(12.0,22.0), fontWeight: FontWeight.w600, color: color));
}
class _SectorsPainter extends CustomPainter {
  const _SectorsPainter({required this.selected,required this.inverse});
  final int selected;final bool inverse;
  @override
  void paint(Canvas canvas, Size size) {
    final r=math.min(size.width,size.height)*.44;
    final center=Offset(size.width/2,size.height/2-3);
    final shades=inverse ? [0xFF3B3B3B,0xFF494949,0xFF555555,0xFF686868] : [0xFFE5E5E5,0xFFD8D8D8,0xFFC9C9C9,0xFFB8B8B8];
    for(var i=0;i<4;i++) {
      final a = [-math.pi,-math.pi/2,0.0,math.pi/2][i];
      final mid=a+math.pi/4;
      final c=center+Offset(math.cos(mid)*7,math.sin(mid)*7);
      final path=Path()..moveTo(c.dx,c.dy)..lineTo(c.dx+math.cos(a)*r,c.dy+math.sin(a)*r)..arcTo(Rect.fromCircle(center:c,radius:r),a,math.pi/2,false)..close();
      canvas.save();canvas.translate(0,5);
      canvas.drawPath(path,Paint()..color=const Color(0xFF777777).withValues(alpha:inverse?.22:.18));canvas.restore();
      canvas.drawShadow(path,Colors.black.withValues(alpha:.15),3,false);
      canvas.drawPath(path,Paint()..color=Color(i==selected?0xFF242424:shades[i]));
    }
  }
  @override
  bool shouldRepaint(_SectorsPainter old)=> old.selected!=selected||old.inverse!=inverse;
}
