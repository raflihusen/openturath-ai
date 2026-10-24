import 'dart:convert';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/arabic_catalog.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import 'tahawwulat_module_screen.dart';
import 'tahawwulat_slide_art.dart';
import 'tahawwulat_slide_motion.dart';

/// Slide "Mengenal Fikih Tahawwulat": Hadis Jibril, kesatuan agama, lalu
/// pengenalan ilmu dan lima asisten. Satu naskah untuk ponsel dan desktop
/// (assets/data/slides_mengenal.json, dibuat dari slides_mengenal.py).
class TahawwulatSlidesScreen extends StatefulWidget {
  const TahawwulatSlidesScreen({super.key, this.onAsk, this.initialPage = 0});

  /// Dipanggil bila pengguna memilih mulai bertanya.
  final VoidCallback? onAsk;
  final int initialPage;

  static Future<void> show(BuildContext context, {VoidCallback? onAsk}) =>
      Navigator.of(context).push<void>(PageRouteBuilder<void>(
        transitionDuration: OTMotion.transition,
        reverseTransitionDuration: OTMotion.fast,
        pageBuilder: (_, __, ___) => TahawwulatSlidesScreen(onAsk: onAsk),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: OTMotion.curve),
            child: child),
      ));

  @override
  State<TahawwulatSlidesScreen> createState() => _TahawwulatSlidesScreenState();
}

class _TahawwulatSlidesScreenState extends State<TahawwulatSlidesScreen> {
  List<dynamic> _slides = const [];
  List<dynamic> _bab = const [];
  Object? _galat;
  late final PageController _page;
  final FocusNode _fokus = FocusNode();
  int _i = 0;

  @override
  void initState() {
    super.initState();
    _i = widget.initialPage;
    _page = PageController(initialPage: widget.initialPage);
    rootBundle.loadString('assets/data/slides_mengenal.json').then((s) {
      final j = jsonDecode(s) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _slides = j['slides'] as List;
          _bab = j['bab'] as List;
        });
      }
    }).catchError((Object e) {
      if (mounted) setState(() => _galat = e);
    });
  }

  @override
  void dispose() {
    _page.dispose();
    _fokus.dispose();
    super.dispose();
  }

  String _t(dynamic v) {
    final m = v as Map;
    return (m[Loc.language] ?? m['id']) as String;
  }

  void _go(int d) {
    final n = (_i + d).clamp(0, _slides.length - 1);
    if (n == _i) return;
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      _page.jumpToPage(n);
    } else {
      _page.animateToPage(n,
          duration: OTMotion.transition, curve: OTMotion.curve);
    }
  }

  KeyEventResult _key(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final rtl = Loc.isArabic;
    if (k == LogicalKeyboardKey.arrowRight) {
      _go(rtl ? -1 : 1);
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _go(rtl ? 1 : -1);
    } else if (k == LogicalKeyboardKey.space ||
        k == LogicalKeyboardKey.arrowDown) {
      _go(1);
    } else if (k == LogicalKeyboardKey.arrowUp) {
      _go(-1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = OTColors.textPrimary(dark), sub = OTColors.textSecondary(dark);
    final total = _slides.length;
    return Directionality(
      textDirection: Loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: OTColors.canvas(dark),
        body: SafeArea(
          child: Focus(
            focusNode: _fokus,
            autofocus: true,
            onKeyEvent: _key,
            child: total == 0
                ? Center(
                    child: _galat == null
                        ? const CircularProgressIndicator()
                        : Text(Loc.tr('moduleLoadFailed'),
                            style: OTTypography.body(color: sub)))
                : Column(children: [
                    _top(dark, fg, sub),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.trackpad,
                          PointerDeviceKind.stylus,
                        }),
                        child: PageView.builder(
                          controller: _page,
                          itemCount: total,
                          onPageChanged: (v) => setState(() => _i = v),
                          itemBuilder: (_, k) => _SlideBody(
                              key: ValueKey('slide$k'),
                              data: _slides[k] as Map<String, dynamic>,
                              t: _t,
                              dark: dark,
                              onAsk: widget.onAsk,
                              onText: () => TahawwulatModuleScreen.show(context,
                                  onAsk: widget.onAsk)),
                        ),
                      ),
                    ),
                    _bottom(dark, fg, sub, total),
                  ]),
          ),
        ),
      ),
    );
  }

  Widget _top(bool dark, Color fg, Color sub) {
    final cur = (_slides[_i] as Map)['bab'] as int;
    int inBab(int b) => _slides.where((e) => (e as Map)['bab'] == b).length;
    final pos = _slides
        .sublist(0, _i + 1)
        .where((e) => (e as Map)['bab'] == cur)
        .length;
    double fill(int b) => b < cur
        ? 1
        : b == cur
            ? pos / inBab(b)
            : 0;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
          OTSpacing.base, OTSpacing.sm, OTSpacing.sm, 0),
      child: Row(children: [
        Expanded(
          child: Row(children: [
            for (var b = 0; b < _bab.length; b++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: OTSpacing.xs),
                  child: ClipRRect(
                    borderRadius: OTRadius.chipBorder,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: fill(b)),
                      duration: OTMotion.transition,
                      curve: OTMotion.curve,
                      builder: (_, v, __) => Stack(children: [
                        Container(
                            height: OTSpacing.xs, color: OTColors.border(dark)),
                        FractionallySizedBox(
                          widthFactor: v,
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(height: OTSpacing.xs, color: fg),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(width: OTSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 112),
          child: Text(_t(_bab[cur]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OTTypography.captionMedium(color: sub)),
        ),
        IconButton(
          tooltip: Loc.tr('moduleClose'),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.close_rounded, color: fg),
        ),
      ]),
    );
  }

  Widget _bottom(bool dark, Color fg, Color sub, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.base, OTSpacing.xs, OTSpacing.base, OTSpacing.md),
      child: Row(children: [
        IconButton.outlined(
          tooltip: Loc.tr('modulePrev'),
          onPressed: _i == 0 ? null : () => _go(-1),
          icon: Icon(Loc.isArabic
              ? Icons.arrow_forward_rounded
              : Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Center(
            child: Text(
                Loc.isArabic
                    ? '${ArabicCatalog.digits('${_i + 1}')} من ${ArabicCatalog.digits('$total')}'
                    : '${_i + 1} / $total',
                style: OTTypography.captionMedium(color: sub)),
          ),
        ),
        IconButton.filled(
          tooltip: Loc.tr('moduleNext'),
          onPressed: _i == total - 1 ? null : () => _go(1),
          icon: Icon(Loc.isArabic
              ? Icons.arrow_back_rounded
              : Icons.arrow_forward_rounded),
        ),
      ]),
    );
  }
}

const _fullWidth = {'compare', 'signs', 'stats'};
const _compactStage = {'title', 'branch', 'assistant', 'dialog'};

String _defaultArt(String type, int bab) {
  if (type == 'end') return 'arch';
  if (bab == 1) return 'arch';
  if (bab == 4 || bab == 5) return 'radial';
  return 'rings';
}

class _SlideBody extends StatelessWidget {
  const _SlideBody(
      {super.key,
      required this.data,
      required this.t,
      required this.dark,
      required this.onAsk,
      required this.onText});
  final Map<String, dynamic> data;
  final String Function(dynamic) t;
  final bool dark;
  final VoidCallback? onAsk;
  final VoidCallback onText;

  String _l(String id, String en, String ar) => switch (Loc.language) {
        'en' => en,
        'ar' => ar,
        _ => id,
      };

  @override
  Widget build(BuildContext context) {
    final fg = OTColors.textPrimary(dark), sub = OTColors.textSecondary(dark);
    final wide = MediaQuery.of(context).size.width >= 880;
    final ar = Loc.isArabic;
    final type = data['type'] as String;
    final bab = data['bab'] as int;

    TextStyle serif(Color c, double size) => ar
        ? OTTypography.arabicDisplay(color: c).copyWith(fontSize: size)
        : OTTypography.editorialHero(color: c).copyWith(fontSize: size);
    final hero = serif(fg, OTFontSize.s36);
    final big = serif(fg, wide ? OTFontSize.s36 : OTFontSize.s26);
    final lead = OTTypography.body(color: fg)
        .copyWith(fontSize: OTFontSize.s18, height: 1.6);

    var step = 0;
    Widget r(Widget w, {double dx = 0}) =>
        SlideReveal(step: step++, dx: dx, child: w);
    Widget words(String text, TextStyle style, {TextAlign? align}) =>
        SlideWords(text, style: style, step: step++, textAlign: align);
    Widget gap([double h = OTSpacing.base]) => SizedBox(height: h);
    Widget kick() => data['kicker'] == null
        ? const SizedBox.shrink()
        : r(Padding(
            padding: const EdgeInsets.only(bottom: OTSpacing.md),
            child: Text(t(data['kicker']).toUpperCase(),
                style: OTTypography.metadataTag(color: sub))));
    Widget note() => data['note'] == null
        ? const SizedBox.shrink()
        : r(Padding(
            padding: const EdgeInsets.only(top: OTSpacing.lg),
            child: Text(t(data['note']),
                style: OTTypography.caption(color: sub))));
    Widget index(int n) => SizedBox(
        width: OTSpacing.jumbo - OTSpacing.base,
        child: Text(ar ? ArabicCatalog.digits('0${n + 1}') : '0${n + 1}',
            style: OTTypography.captionMedium(color: sub)));

    final children = <Widget>[];
    var fullWidth = _fullWidth.contains(type);
    var centered = false;
    var split = true;

    switch (type) {
      case 'title':
        children.addAll([
          kick(),
          words(t(data['title']), hero),
          gap(OTSpacing.md),
          r(Text(t(data['sub']), style: lead.copyWith(color: sub))),
          if (data['hint'] != null) ...[
            gap(OTSpacing.xl),
            r(Text(t(data['hint']), style: OTTypography.caption(color: sub))),
          ],
        ]);
      case 'text':
        children.addAll([
          kick(),
          if (data['title'] != null) words(t(data['title']), big),
          gap(OTSpacing.base),
          for (final l in (data['lines'] ?? const []) as List) ...[
            words(t(l), lead),
            gap(OTSpacing.md),
          ],
          note(),
        ]);
      case 'lines':
        children.addAll([
          kick(),
          for (final l in data['lines'] as List) ...[
            words(t(l), big),
            gap(OTSpacing.md),
          ],
          note(),
        ]);
      case 'question':
        centered = true;
        split = false;
        children.addAll([
          words(t(data['q']), big, align: TextAlign.center),
          if (data['hint'] != null) ...[
            gap(OTSpacing.lg),
            r(Text(t(data['hint']), style: OTTypography.caption(color: sub))),
          ],
        ]);
      case 'dialog':
        children.addAll([
          kick(),
          r(_bubble(Text(t(data['asker']), style: lead), false, fg), dx: -0.04),
          gap(OTSpacing.md),
          r(
              _bubble(
                  SlideWords(t(data['answer']),
                      style: lead.copyWith(color: OTColors.onInverted(dark)),
                      step: step + 1),
                  true,
                  fg),
              dx: 0.04),
          note(),
        ]);
      case 'quote':
        centered = true;
        split = false;
        children.addAll([
          Directionality(
            textDirection: TextDirection.rtl,
            child: SlideWords(data['arabic'] as String,
                step: step++,
                textAlign: TextAlign.center,
                style: OTTypography.arabicDisplay(color: fg).copyWith(
                    fontSize: wide ? OTFontSize.s36 : OTFontSize.s26)),
          ),
          gap(OTSpacing.lg),
          words(t(data['translation']), lead, align: TextAlign.center),
          gap(OTSpacing.sm),
          r(Text(t(data['source']), style: OTTypography.caption(color: sub))),
        ]);
      case 'list':
        final items = data['items'] as List;
        fullWidth = data['art'] == null;
        children.addAll([
          words(t(data['title']), big),
          gap(OTSpacing.lg),
          r(LayoutBuilder(builder: (ctx, box) {
            final cols = box.maxWidth >= 720 && items.length >= 4 ? 2 : 1;
            final w = (box.maxWidth - (cols - 1) * OTSpacing.md) / cols;
            return Wrap(spacing: OTSpacing.md, children: [
              for (var n = 0; n < items.length; n++)
                SizedBox(
                  width: w,
                  child: _card(
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            index(n),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t(items[n]['t']),
                                        style:
                                            OTTypography.cardTitle(color: fg)),
                                    if (items[n]['d'] != null) ...[
                                      const SizedBox(height: OTSpacing.xs),
                                      Text(t(items[n]['d']),
                                          style: OTTypography.body(color: sub)),
                                    ],
                                  ]),
                            ),
                          ]),
                      false),
                ),
            ]);
          })),
          note(),
        ]);
      case 'cards':
        final items = data['items'] as List;
        fullWidth = data['art'] == null;
        children.addAll([
          words(t(data['title']), big),
          gap(OTSpacing.lg),
          LayoutBuilder(builder: (ctx, box) {
            final cols = box.maxWidth >= 900 && items.length >= 4
                ? 4
                : box.maxWidth >= 720 && items.length == 3
                    ? 3
                    : box.maxWidth >= 560
                        ? 2
                        : 1;
            final tiles = <Widget>[
              for (var n = 0; n < items.length; n++)
                SlideReveal(
                  step: step + n,
                  child: _card(
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                ar
                                    ? ArabicCatalog.digits('0${n + 1}')
                                    : '0${n + 1}',
                                style: OTTypography.metadataTag(
                                    color: items[n]['hl'] == true
                                        ? OTColors.onInvertedMuted(dark)
                                        : sub)),
                            const SizedBox(height: OTSpacing.md),
                            Text(t(items[n]['t']),
                                style: OTTypography.cardTitle(
                                    color: items[n]['hl'] == true
                                        ? OTColors.onInverted(dark)
                                        : fg)),
                            if (items[n]['d'] != null) ...[
                              const SizedBox(height: OTSpacing.xs),
                              Text(t(items[n]['d']),
                                  style: OTTypography.body(
                                      color: items[n]['hl'] == true
                                          ? OTColors.onInvertedMuted(dark)
                                          : sub)),
                            ],
                          ]),
                      items[n]['hl'] == true),
                ),
            ];
            if (cols == 1) return Column(children: tiles);
            return Column(children: [
              for (var r0 = 0; r0 < tiles.length; r0 += cols)
                Padding(
                  padding: const EdgeInsets.only(bottom: OTSpacing.md),
                  child: IntrinsicHeight(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var c0 = 0; c0 < cols; c0++) ...[
                            if (c0 > 0) const SizedBox(width: OTSpacing.md),
                            Expanded(
                                child: r0 + c0 < tiles.length
                                    ? tiles[r0 + c0]
                                    : const SizedBox.shrink()),
                          ]
                        ]),
                  ),
                ),
            ]);
          }),
          note(),
        ]);
      case 'compare':
        final cols = data['cols'] as List;
        children.addAll([
          if (data['title'] != null) ...[
            words(t(data['title']), big),
            gap(OTSpacing.lg),
          ],
          if (wide)
            r(Padding(
              padding: const EdgeInsets.only(bottom: OTSpacing.md),
              child: Row(children: [
                Expanded(
                    child: Text(t(cols[0]),
                        style: OTTypography.captionMedium(color: sub))),
                const SizedBox(width: OTSpacing.md),
                Expanded(
                    child: Text(t(cols[1]),
                        style: OTTypography.captionMedium(color: fg))),
              ]),
            )),
          for (var n = 0; n < (data['rows'] as List).length; n++)
            _versus((data['rows'] as List)[n], cols, wide, step + n * 3),
        ]);
      case 'stats':
        final items = data['items'] as List;
        children.addAll([
          words(t(data['title']), big),
          gap(OTSpacing.xl),
          LayoutBuilder(builder: (ctx, box) {
            final row = box.maxWidth >= 640;
            final cards = [
              for (var n = 0; n < items.length; n++)
                SlideReveal(
                  step: step + n,
                  child: _card(
                      Column(children: [
                        SlideRing(
                          fraction: (items[n]['n'] as int) / 6,
                          ink: fg,
                          size: 132,
                          step: step + n,
                          child: SlideCount(items[n]['n'] as int,
                              step: step + n,
                              style: OTTypography.displayLarge(color: fg)),
                        ),
                        const SizedBox(height: OTSpacing.base),
                        Text(t(items[n]['t']),
                            textAlign: TextAlign.center,
                            style: OTTypography.cardTitle(color: fg)),
                        Text(t(items[n]['d']),
                            textAlign: TextAlign.center,
                            style: OTTypography.body(color: sub)),
                      ]),
                      false),
                ),
            ];
            return row
                ? IntrinsicHeight(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        for (var n = 0; n < cards.length; n++) ...[
                          if (n > 0) const SizedBox(width: OTSpacing.md),
                          Expanded(child: cards[n]),
                        ]
                      ]))
                : Column(children: cards);
          }),
          gap(OTSpacing.base),
          for (final l in data['lines'] as List) ...[
            words(t(l), lead),
            gap(OTSpacing.sm),
          ],
        ]);
      case 'signs':
        final items = data['items'] as List;
        final cols = data['cols'] as List;
        children.addAll([
          words(t(data['title']), big),
          gap(OTSpacing.xl),
          LayoutBuilder(builder: (ctx, box) {
            final row = box.maxWidth >= 720;
            final cols2 = [
              for (var n = 0; n < items.length; n++)
                _signColumn(items[n] as Map, cols, step + n * 3, fg, sub),
            ];
            return row
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    for (var n = 0; n < cols2.length; n++) ...[
                      if (n > 0) const SizedBox(width: OTSpacing.base),
                      Expanded(child: cols2[n]),
                    ]
                  ])
                : Column(children: [
                    for (var n = 0; n < cols2.length; n++) ...[
                      if (n > 0) const SizedBox(height: OTSpacing.lg),
                      cols2[n],
                    ]
                  ]);
          }),
        ]);
      case 'branchmap':
        final items = data['items'] as List;
        split = false;
        fullWidth = true;
        final list =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          words(t(data['title']), big),
          gap(OTSpacing.lg),
          for (var n = 0; n < items.length; n++)
            r(Padding(
              padding: const EdgeInsets.only(bottom: OTSpacing.md),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _badge(n + 1, false, fg),
                const SizedBox(width: OTSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: OTSpacing.sm),
                    child: Text(t(items[n]['t']),
                        style: OTTypography.cardTitle(color: fg)),
                  ),
                ),
              ]),
            )),
          note(),
        ]);
        children.add(wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                    flex: 5,
                    child: SizedBox(
                        height: 420,
                        child:
                            SlideStage(kind: SlideArtKind.radial, dark: dark))),
                const SizedBox(width: OTSpacing.xxl),
                Expanded(flex: 6, child: list),
              ])
            : Column(children: [
                SizedBox(
                    height: 220,
                    child: SlideStage(kind: SlideArtKind.radial, dark: dark)),
                gap(OTSpacing.base),
                list,
              ]));
      case 'branch':
        final n = data['n'] as int;
        final qs = data['qs'] as List;
        children.addAll([
          r(Padding(
            padding: const EdgeInsets.only(bottom: OTSpacing.md),
            child: Row(children: [
              _badge(n, true, fg),
              const SizedBox(width: OTSpacing.md),
              Text(
                  _l('Cabang $n dari 5', 'Branch $n of 5',
                          'الفرع ${ArabicCatalog.digits('$n')} من ${ArabicCatalog.digits('5')}')
                      .toUpperCase(),
                  style: OTTypography.metadataTag(color: sub)),
            ]),
          )),
          words(t(data['name']), big),
          gap(OTSpacing.md),
          words(t(data['desc']), lead.copyWith(color: sub)),
          gap(OTSpacing.lg),
          r(Text(Loc.tr('moduleExample').toUpperCase(),
              style: OTTypography.metadataTag(color: sub))),
          gap(OTSpacing.sm),
          for (final q in qs)
            r(Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: OTSpacing.sm),
              padding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.base, vertical: OTSpacing.md),
              decoration: BoxDecoration(
                borderRadius: OTRadius.cardBorder,
                border: Border.all(color: OTColors.border(dark)),
                color: OTColors.surface(dark),
              ),
              child: Row(children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: OTSpacing.lg, color: sub),
                const SizedBox(width: OTSpacing.md),
                Expanded(
                    child:
                        Text(t(q), style: OTTypography.bodyMedium(color: fg))),
              ]),
            )),
          note(),
        ]);
      case 'assistant':
        children.addAll([
          if (data['start'] == true)
            r(Padding(
              padding: const EdgeInsets.only(bottom: OTSpacing.md),
              child: Chip(
                  label: Text(Loc.tr('moduleStartHere'),
                      style: OTTypography.captionMedium(
                          color: OTColors.onInverted(dark))),
                  backgroundColor: OTColors.inverted(dark),
                  side: BorderSide.none),
            )),
          if (ar)
            words(data['ar'] as String, hero)
          else ...[
            r(Directionality(
              textDirection: TextDirection.rtl,
              child: Text(data['ar'] as String,
                  style: OTTypography.arabicDisplay(color: sub)),
            )),
            words(data['name'] as String, hero),
          ],
          gap(OTSpacing.xs),
          r(Text(t(data['role']).toUpperCase(),
              style: OTTypography.metadataTag(color: sub))),
          gap(OTSpacing.base),
          words(t(data['desc']), lead),
          gap(OTSpacing.lg),
          r(_card(
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(Loc.tr('moduleExample').toUpperCase(),
                    style: OTTypography.metadataTag(color: sub)),
                const SizedBox(height: OTSpacing.sm),
                Text(t(data['ask']), style: OTTypography.bodyMedium(color: fg)),
              ]),
              false)),
        ]);
      case 'end':
        final items = data['items'] as List;
        children.addAll([
          words(t(data['title']), big),
          gap(OTSpacing.lg),
          for (var n = 0; n < items.length; n++)
            r(_card(
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  index(n),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t(items[n]['t']),
                              style: OTTypography.cardTitle(color: fg)),
                          const SizedBox(height: OTSpacing.xs),
                          Text(t(items[n]['d']),
                              style: OTTypography.body(color: sub)),
                        ]),
                  ),
                ]),
                false)),
          gap(OTSpacing.md),
          r(FilledButton(
            onPressed: () {
              Navigator.of(context).maybePop();
              onAsk?.call();
            },
            child: Text(t(data['cta']), style: OTTypography.button()),
          )),
          gap(OTSpacing.sm),
          r(OutlinedButton(
            onPressed: onText,
            child: Text(t(data['cta2']), style: OTTypography.button()),
          )),
        ]);
    }

    final artKey = data['art'] as String? ??
        (fullWidth && type != 'branchmap' ? null : _defaultArt(type, bab));
    final kind = slideArtOf(artKey);
    final labels = [
      for (final x in (data['labels'] as List? ?? const [])) t(x)
    ];
    final hl = (data['hl'] as int?) ?? -1;

    Widget stage({double? height}) {
      final s = SlideStage(
          key: ValueKey('stage${data['type']}$hl$bab'),
          kind: kind,
          dark: dark,
          hl: hl,
          labels: labels);
      final art = ExcludeSemantics(child: s);
      return height == null ? art : SizedBox(height: height, child: art);
    }

    Widget scroller(List<Widget> kids, {required bool center}) =>
        LayoutBuilder(builder: (ctx, box) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.lg, vertical: OTSpacing.base),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: box.maxHeight - OTSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: center
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: kids,
              ),
            ),
          );
        });

    if (type == 'question' || type == 'quote') {
      return Stack(children: [
        if (kind != SlideArtKind.none)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(OTSpacing.xl),
              child: Opacity(
                  opacity: type == 'quote' ? 0.18 : (wide ? 0.5 : 0.28),
                  child: stage()),
            ),
          ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 900 : 640),
            child: scroller(children, center: true),
          ),
        ),
      ]);
    }

    if (wide && split && !fullWidth && kind != SlideArtKind.none) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(children: [
            Expanded(flex: 6, child: scroller(children, center: false)),
            const SizedBox(width: OTSpacing.xl),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: OTSpacing.lg, vertical: OTSpacing.xl),
                child: stage(),
              ),
            ),
          ]),
        ),
      );
    }

    final kids = [
      if (!wide &&
          split &&
          kind != SlideArtKind.none &&
          _compactStage.contains(type)) ...[
        r(stage(height: 150)),
        gap(OTSpacing.base),
      ],
      ...children,
    ];
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: wide ? (fullWidth ? 1080 : 820) : 640),
        child: scroller(kids, center: centered),
      ),
    );
  }

  Widget _badge(int n, bool lit, Color fg) => Container(
        width: OTSpacing.massive - OTSpacing.sm,
        height: OTSpacing.massive - OTSpacing.sm,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: lit ? fg : OTColors.surface(dark),
          border: Border.all(color: lit ? fg : OTColors.borderStrong(dark)),
        ),
        child: Text(Loc.isArabic ? ArabicCatalog.digits('$n') : '$n',
            style: OTTypography.cardTitle(
                color: lit ? OTColors.canvas(dark) : fg)),
      );

  Widget _versus(dynamic row, List cols, bool wide, int step) {
    final fg = OTColors.textPrimary(dark), sub = OTColors.textSecondary(dark);
    final inv = OTColors.onInverted(dark);
    final left = _card(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!wide)
            Text(t(cols[0]), style: OTTypography.captionMedium(color: sub)),
          Text(t(row[1]),
              style: OTTypography.body(color: sub).copyWith(
                  fontSize: wide ? OTFontSize.s18 : null, height: 1.5)),
        ]),
        false,
        bottom: wide ? 0 : OTSpacing.sm);
    final right = _card(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!wide)
            Text(t(cols[1]),
                style: OTTypography.captionMedium(
                    color: OTColors.onInvertedMuted(dark))),
          Text(t(row[2]),
              style: OTTypography.bodyMedium(color: inv).copyWith(
                  fontSize: wide ? OTFontSize.s18 : null, height: 1.5)),
        ]),
        true,
        bottom: wide ? 0 : OTSpacing.md);
    return Padding(
      padding: const EdgeInsets.only(bottom: OTSpacing.base),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SlideReveal(
            step: step,
            child: Padding(
              padding: const EdgeInsets.only(bottom: OTSpacing.sm),
              child: Text(t(row[0]).toUpperCase(),
                  style: OTTypography.metadataTag(color: fg)),
            )),
        if (wide)
          IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(
                  child: SlideReveal(step: step + 1, dx: -0.03, child: left)),
              const SizedBox(width: OTSpacing.md),
              Expanded(
                  child: SlideReveal(step: step + 2, dx: 0.03, child: right)),
            ]),
          )
        else ...[
          SlideReveal(step: step + 1, child: left),
          SlideReveal(step: step + 2, child: right),
        ],
      ]),
    );
  }

  Widget _signColumn(Map item, List cols, int step, Color fg, Color sub) {
    final ar = Loc.isArabic;
    final inv = OTColors.onInverted(dark);
    final invSub = OTColors.onInvertedMuted(dark);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SlideReveal(
        step: step,
        child: _card(
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t(cols[0]).toUpperCase(),
                  style: OTTypography.metadataTag(color: sub)),
              const SizedBox(height: OTSpacing.md),
              Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(item['signAr'] as String,
                      textAlign: ar ? TextAlign.start : TextAlign.end,
                      style: OTTypography.arabicReading(color: fg)
                          .copyWith(fontSize: OTFontSize.s22)),
                ),
              ),
              if (!ar) ...[
                const SizedBox(height: OTSpacing.xs),
                Text(t(item['sign']),
                    style: OTTypography.bodyMedium(color: fg)),
              ],
            ]),
            false,
            bottom: 0),
      ),
      SlideReveal(
        step: step + 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: OTSpacing.sm),
          child: Icon(Icons.south_rounded, color: sub),
        ),
      ),
      SlideReveal(
        step: step + 2,
        child: _card(
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t(cols[1]).toUpperCase(),
                  style: OTTypography.metadataTag(color: invSub)),
              const SizedBox(height: OTSpacing.md),
              Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(item['ar'] as String,
                      textAlign: ar ? TextAlign.start : TextAlign.end,
                      style: OTTypography.arabicDisplay(color: inv)
                          .copyWith(fontSize: OTFontSize.s36)),
                ),
              ),
              if (!ar) ...[
                Text(item['tr'] as String,
                    style: OTTypography.caption(color: invSub)
                        .copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: OTSpacing.md),
                Text(t(item['name']),
                    style: OTTypography.cardTitle(color: inv)),
              ],
              const SizedBox(height: OTSpacing.xs),
              Text(t(item['d']), style: OTTypography.body(color: invSub)),
            ]),
            true,
            bottom: 0),
      ),
    ]);
  }

  Widget _bubble(Widget child, bool answer, Color fg) {
    final fill = answer ? OTColors.inverted(dark) : OTColors.surface(dark);
    return Align(
      alignment: answer
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(OTSpacing.lg),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: OTRadius.cardBorder,
          border: answer ? null : Border.all(color: OTColors.border(dark)),
        ),
        child: child,
      ),
    );
  }

  Widget _card(Widget child, bool inverse, {double bottom = OTSpacing.md}) =>
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: bottom),
        padding: const EdgeInsets.all(OTSpacing.lg),
        decoration: BoxDecoration(
          color: inverse ? OTColors.inverted(dark) : OTColors.surface(dark),
          borderRadius: OTRadius.cardBorder,
          border: Border.all(color: OTColors.border(dark)),
        ),
        child: child,
      );
}
