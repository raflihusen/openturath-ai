import 'package:flutter/material.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_expressive.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'tahawwulat_artwork.dart';

/// The generated sculpture has textual choices and keyboard-accessible sectors.
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
  static const english = ['Faith', 'Islam', 'Ihsan', 'Signs of the Hour'];
  static const explanations = [
    'Keyakinan kepada Allah, malaikat, kitab, rasul, hari akhir, dan takdir.',
    'Ibadah dan syariat dalam kehidupan seorang muslim.',
    'Beribadah kepada Allah dengan kesadaran dan kejernihan batin.',
    'Membaca perubahan zaman dalam kerangka Fikih Tahawwulat Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur.',
  ];
  static const explanationsArabic = [
    'الإيمان بالله وملائكته وكتبه ورسله واليوم الآخر والقدر.',
    'العبادة والشريعة في حياة المسلم.',
    'عبادة الله بحضور القلب وصفاء الباطن.',
    'قراءة تحولات الزمان في إطار فقه التحولات عند الحبيب أبي بكر العدني بن علي المشهور.',
  ];
  static const explanationsEnglish = [
    'Belief in Allah, the angels, scriptures, messengers, the Last Day, and divine decree.',
    "Worship and religious practice in a Muslim's life.",
    'Worshipping Allah with awareness and clarity of heart.',
    'Reading changing times through the Fiqh Tahawwulat framework of Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur.',
  ];
  String label(int i) => Loc.isArabic
      ? arabic[i]
      : Loc.language == 'en'
          ? english[i]
          : labels[i];
  @override
  Widget build(BuildContext context) {
    final ink = widget.inverse
        ? OTExpressive.white
        : Theme.of(context).colorScheme.onSurface;
    final artwork = TahawwulatArtwork(blendEdges: widget.inverse);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (!widget.interactive)
        Semantics(image: true, label: labels.join(', '), child: artwork)
      else
        AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(builder: (context, box) {
              final half = box.maxWidth / 2;
              return Stack(children: [
                Positioned.fill(child: artwork),
                for (var i = 0; i < 4; i++)
                  Positioned(
                      left: i == 0 || i == 3 ? 0 : half,
                      top: i < 2 ? 0 : half,
                      width: half,
                      height: half,
                      child: Semantics(
                          button: true,
                          selected: selected == i,
                          label: label(i),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  overlayColor: OTExpressive.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(OTExpressive.panelRadius))),
                              onPressed: () => setState(() => selected = i),
                              child: const SizedBox.expand()))),
              ]);
            })),
      if (widget.interactive) ...[
        const SizedBox(height: 16),
        Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 4; i++)
                ChoiceChip(
                    label: Text(label(i)),
                    selected: selected == i,
                    onSelected: (_) => setState(() => selected = i))
            ]),
        const SizedBox(height: 16),
        Semantics(
            liveRegion: true,
            child: Text(
                Loc.isArabic
                    ? explanationsArabic[selected]
                    : Loc.language == 'en'
                        ? explanationsEnglish[selected]
                        : explanations[selected],
                textAlign: TextAlign.center,
                textDirection:
                    Loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s16, height: 1.6, color: ink))),
      ],
    ]);
  }
}
