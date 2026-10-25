import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import 'tahawwulat_scene.dart';
import 'tahawwulat_scenes.dart';
import 'tahawwulat_slide_motion.dart';

final _arRun = RegExp(
    r'[«﴿\[]?[؀-ۿﭐ-﷿ﹰ-﻿]+(?:[\s«»﴿﴾\[\]:،]+[؀-ۿﭐ-﷿ﹰ-﻿]+)*[»﴾\]]?');
String _l(String id, String en, String ar) => switch (Loc.language) {
      'en' => en,
      'ar' => ar,
      _ => id,
    };

final _md = RegExp(r'\*\*\*(.+?)\*\*\*|\*\*(.+?)\*\*|\*(.+?)\*');

/// Mengubah teks `**tebal**` / `*miring*` dan sisipan Arab menjadi span.
List<InlineSpan> richSpans(String s, TextStyle base, TextStyle arabic) {
  final out = <InlineSpan>[];
  void plain(String t, TextStyle st) {
    var i = 0;
    for (final m in _arRun.allMatches(t)) {
      if (m.start > i) out.add(TextSpan(text: t.substring(i, m.start), style: st));
      out.add(TextSpan(
          text: m.group(0),
          style: arabic.copyWith(
              fontWeight: st.fontWeight, fontStyle: FontStyle.normal)));
      i = m.end;
    }
    if (i < t.length) out.add(TextSpan(text: t.substring(i), style: st));
  }

  void run(String t, TextStyle st) {
    var i = 0;
    for (final m in _md.allMatches(t)) {
      if (m.start > i) plain(t.substring(i, m.start), st);
      if (m.group(1) != null) {
        run(m.group(1)!,
            st.copyWith(fontWeight: FontWeight.w700, fontStyle: FontStyle.italic));
      } else if (m.group(2) != null) {
        run(m.group(2)!, st.copyWith(fontWeight: FontWeight.w700));
      } else {
        run(m.group(3)!, st.copyWith(fontStyle: FontStyle.italic));
      }
      i = m.end;
    }
    if (i < t.length) plain(t.substring(i), st);
  }

  run(s, base);
  return out;
}

/// Satu slide: adegan animasi dan teksnya berdampingan (lebar) atau
/// bertumpuk (sempit). Adegan tidak pernah berada di belakang teks.
class TahawwulatSlideView extends StatelessWidget {
  const TahawwulatSlideView({
    super.key,
    required this.data,
    required this.bab,
    required this.dark,
    required this.active,
    required this.onAsk,
    required this.onText,
  });
  final Map<String, dynamic> data;
  final String Function(dynamic) bab;
  final bool dark;
  final bool active;
  final VoidCallback? onAsk;
  final VoidCallback onText;

  @override
  Widget build(BuildContext context) {
    final fg = OTColors.textPrimary(dark);
    final sub = OTColors.textSecondary(dark);
    final ar = Loc.isArabic;
    final scene = sceneFor(data['scene'] as String);
    final isTitle = data['kind'] == 'title';
    final isEnd = data['scene'] == 's84';
    final isText = data['lvl'] == 'text' || scene == null;

    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= 860 && !isText;
      final textStyle =
          OTTypography.body(color: fg).copyWith(fontSize: OTFontSize.s18, height: 1.65);
      final arStyle = OTTypography.arabicReading(color: fg)
          .copyWith(fontSize: OTFontSize.s22, height: 1.9);
      final serif = ar
          ? OTTypography.arabicDisplay(color: fg)
          : OTTypography.editorialHero(color: fg);

      var step = 0;
      Widget r(Widget w) => SlideReveal(step: step++, child: w);
      Widget gap([double h = OTSpacing.base]) => SizedBox(height: h);

      final body = <Widget>[];
      if (isTitle) {
        final kicker = data['kicker'] as String;
        final title = data['title'] as String;
        final sub0 = data['sub'] as String?;
        body.addAll([
          r(Text(kicker.toUpperCase(),
              style: OTTypography.metadataTag(color: sub))),
          gap(OTSpacing.md),
          r(Text(title, style: serif.copyWith(fontSize: wide ? OTFontSize.s36 : OTFontSize.s26, height: 1.15))),
          if (sub0 != null) ...[
            gap(OTSpacing.md),
            r(Text.rich(
                TextSpan(
                    children:
                        richSpans(sub0, textStyle.copyWith(color: sub), arStyle)),
                style: textStyle)),
          ],
        ]);
      } else {
        final blocks = (data['blocks'] as List).cast<Map<String, dynamic>>();
        for (var i = 0; i < blocks.length; i++) {
          final b = blocks[i];
          if (b['p'] != null) {
            final txt = b['p'] as String;
            final isHead = i == 0 &&
                txt.startsWith('**') &&
                txt.endsWith('**') &&
                !txt.substring(2, txt.length - 2).contains('**');
            if (isHead) {
              body.add(r(Text.rich(TextSpan(
                  children: richSpans(
                      txt.substring(2, txt.length - 2),
                      serif.copyWith(fontSize: wide ? OTFontSize.s26 : OTFontSize.s22, height: 1.3),
                      arStyle.copyWith(fontSize: wide ? OTFontSize.s26 : OTFontSize.s22))))));
            } else {
              body.add(r(Text.rich(
                  TextSpan(children: richSpans(txt, textStyle, arStyle)))));
            }
            body.add(gap(OTSpacing.md));
          } else if (b['lines'] != null) {
            final ls = (b['lines'] as List).cast<String>();
            for (var k = 0; k < ls.length; k++) {
              body.add(r(Text(ls[k],
                  style: k == 0
                      ? textStyle.copyWith(color: sub)
                      : serif.copyWith(fontSize: wide ? OTFontSize.s22 : OTFontSize.s20, height: 1.35))));
              body.add(gap(k == 0 ? OTSpacing.md : OTSpacing.sm));
            }
          } else if (b['ul'] != null || b['ol'] != null) {
            final ordered = b['ol'] != null;
            final items = ((b['ol'] ?? b['ul']) as List).cast<String>();
            for (var k = 0; k < items.length; k++) {
              body.add(r(Padding(
                padding: const EdgeInsets.only(bottom: OTSpacing.md),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 28,
                        child: ordered
                            ? Text(ar ? '${k + 1}' : '${k + 1}.',
                                style: textStyle.copyWith(
                                    color: sub, fontWeight: FontWeight.w600))
                            : Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                          color: sub, shape: BoxShape.circle)),
                                ),
                              ),
                      ),
                      Expanded(
                          child: Text.rich(TextSpan(
                              children: richSpans(items[k], textStyle, arStyle)))),
                    ]),
              )));
            }
          } else if (b['ar'] != null) {
            body.add(r(Padding(
              padding: const EdgeInsets.symmetric(vertical: OTSpacing.sm),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: OTSpacing.base, vertical: OTSpacing.md),
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                        end: BorderSide(color: fg, width: 2)),
                  ),
                  child: Text(b['ar'] as String,
                      style: arStyle.copyWith(
                          fontSize: wide ? OTFontSize.s26 : OTFontSize.s22, height: 1.9)),
                ),
              ),
            )));
          } else if (b['cap'] != null) {
            body.add(r(Padding(
              padding: const EdgeInsets.only(top: OTSpacing.xs),
              child: Text(b['cap'] as String,
                  style: OTTypography.caption(color: sub)),
            )));
          } else if (b['table'] != null) {
            body.add(r(_table(b['table'] as Map<String, dynamic>, fg, sub,
                textStyle, arStyle)));
            body.add(gap(OTSpacing.md));
          } else if (b['trio'] != null) {
            body.add(r(_trio((b['trio'] as List).cast<Map<String, dynamic>>(),
                fg, sub, textStyle, wide)));
          }
        }
      }
      if (isEnd) {
        body.addAll([
          gap(OTSpacing.lg),
          r(Wrap(spacing: OTSpacing.md, runSpacing: OTSpacing.md, children: [
            FilledButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                  onAsk?.call();
                },
                child: Text(
                    _l('Mulai bertanya', 'Start asking', 'ابدأ بالسؤال'),
                    style: OTTypography.button())),
            OutlinedButton(
                onPressed: onText,
                child: Text(
                    _l('Pilih jalur belajar', 'Choose a study path',
                        'اختر مسار التعلّم'),
                    style: OTTypography.button())),
          ])),
        ]);
      }

      final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: body);
      final sceneWidget = scene == null
          ? null
          : AspectRatio(
              aspectRatio: kSceneW / kSceneH,
              child: SceneView(def: scene, active: active, dark: dark));

      if (wide) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: OTSpacing.xl, vertical: OTSpacing.base),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              flex: 5,
              child: Center(
                child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: text)),
              ),
            ),
            const SizedBox(width: OTSpacing.xl),
            Expanded(flex: 6, child: Center(child: sceneWidget)),
          ]),
        );
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            OTSpacing.base, OTSpacing.sm, OTSpacing.base, OTSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (sceneWidget != null) ...[sceneWidget, gap(OTSpacing.md)],
              text,
            ]),
          ),
        ),
      );
    });
  }

  Widget _table(Map<String, dynamic> t, Color fg, Color sub, TextStyle ts,
      TextStyle arStyle) {
    final head = (t['head'] as List).cast<String>();
    final rows = (t['rows'] as List).map((e) => (e as List).cast<String>()).toList();
    final small = ts.copyWith(fontSize: OTFontSize.s14, height: 1.5);
    Widget cell(String s, {bool header = false, bool first = false}) => Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: OTSpacing.md, vertical: OTSpacing.sm),
          child: Text.rich(TextSpan(
              children: richSpans(
                  s,
                  header
                      ? small.copyWith(
                          color: sub, fontWeight: FontWeight.w600, fontSize: OTFontSize.s12)
                      : small.copyWith(
                          fontWeight: first ? FontWeight.w600 : FontWeight.w400),
                  arStyle.copyWith(fontSize: OTFontSize.s18)))),
        );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: OTColors.border(dark)),
        borderRadius: OTRadius.xsBorder,
      ),
      child: ClipRRect(
        borderRadius: OTRadius.xsBorder,
        child: Table(
          columnWidths: const {0: FlexColumnWidth(1.0)},
          defaultColumnWidth: const FlexColumnWidth(1.4),
          border: TableBorder(
              horizontalInside: BorderSide(color: OTColors.borderSubtle(dark)),
              verticalInside: BorderSide(color: OTColors.borderSubtle(dark))),
          children: [
            TableRow(
                decoration: BoxDecoration(color: OTColors.surfaceSubtle(dark)),
                children: [for (final h in head) cell(h, header: true)]),
            for (final row in rows)
              TableRow(children: [
                for (var i = 0; i < row.length; i++) cell(row[i], first: i == 0)
              ]),
          ],
        ),
      ),
    );
  }

  Widget _trio(List<Map<String, dynamic>> items, Color fg, Color sub,
      TextStyle ts, bool wide) {
    Widget card(Map<String, dynamic> m) => Container(
          padding: const EdgeInsets.all(OTSpacing.md),
          decoration: BoxDecoration(
            color: OTColors.surface(dark),
            border: Border.all(color: OTColors.border(dark)),
            borderRadius: OTRadius.xsBorder,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['t'] as String,
                style: OTTypography.cardTitle(color: fg)),
            const SizedBox(height: OTSpacing.xs),
            Text(m['b'] as String,
                style: ts.copyWith(fontSize: OTFontSize.s14, color: sub, height: 1.5)),
            const SizedBox(height: OTSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.md, vertical: OTSpacing.xs),
              decoration: BoxDecoration(
                color: OTColors.inverted(dark),
                borderRadius: BorderRadius.circular(OTRadius.chip),
              ),
              child: Text(m['tag'] as String,
                  style: OTTypography.captionMedium(
                      color: OTColors.onInverted(dark))),
            ),
          ]),
        );
    return Column(children: [
      for (final m in items)
        Padding(
            padding: const EdgeInsets.only(bottom: OTSpacing.sm), child: card(m)),
    ]);
  }
}
