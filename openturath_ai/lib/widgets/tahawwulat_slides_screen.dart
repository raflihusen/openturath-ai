import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import 'tahawwulat_module_screen.dart';

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
                    _bottom(dark, fg, sub, total),
                  ]),
          ),
        ),
      ),
    );
  }

  Widget _top(bool dark, Color fg, Color sub) {
    final cur = (_slides[_i] as Map)['bab'] as int;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.base, OTSpacing.sm, OTSpacing.sm, 0),
      child: Row(children: [
        Expanded(
          child: Row(children: [
            for (var b = 0; b < _bab.length; b++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: OTSpacing.xs),
                  child: AnimatedContainer(
                    duration: OTMotion.fast,
                    height: OTSpacing.xs,
                    decoration: BoxDecoration(
                      borderRadius: OTRadius.chipBorder,
                      color: b <= cur ? fg : OTColors.border(dark),
                    ),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(width: OTSpacing.md),
        Text(_t(_bab[cur]), style: OTTypography.captionMedium(color: sub)),
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
            child: Text('${_i + 1} / $total',
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

/// Muncul pelan: pudar dan naik sedikit, berurutan. Gerak dikurangi: langsung.
class _Reveal extends StatefulWidget {
  const _Reveal({required this.step, required this.child});
  final int step;
  final Widget child;
  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final Duration _delay = OTMotion.fast * (1 + widget.step * 2);
  late final AnimationController _c =
      AnimationController(vsync: this, duration: _delay + OTMotion.transition);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = (_delay + OTMotion.transition).inMilliseconds;
    final a = CurvedAnimation(
        parent: _c,
        curve:
            Interval(_delay.inMilliseconds / total, 1, curve: OTMotion.curve));
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(a),
        child: widget.child,
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    final fg = OTColors.textPrimary(dark), sub = OTColors.textSecondary(dark);
    final wide = MediaQuery.of(context).size.width >= 880;
    final big = wide
        ? OTTypography.displayLarge(color: fg)
        : OTTypography.pageTitle(color: fg);
    final hero = OTTypography.displayLarge(color: fg);
    final type = data['type'] as String;
    var step = 0;
    Widget r(Widget w) => _Reveal(step: step++, child: w);
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

    final children = <Widget>[];
    switch (type) {
      case 'title':
        children.addAll([
          kick(),
          r(Text(t(data['title']), style: hero)),
          gap(OTSpacing.md),
          r(Text(t(data['sub']), style: OTTypography.body(color: sub))),
          if (data['hint'] != null) ...[
            gap(OTSpacing.xl),
            r(Text(t(data['hint']), style: OTTypography.caption(color: sub))),
          ],
        ]);
      case 'text':
        children.addAll([
          kick(),
          if (data['title'] != null) r(Text(t(data['title']), style: big)),
          gap(OTSpacing.base),
          for (final l in (data['lines'] ?? const []) as List) ...[
            r(Text(t(l),
                style: OTTypography.body(color: fg)
                    .copyWith(fontSize: OTFontSize.s18, height: 1.6))),
            gap(OTSpacing.md),
          ],
          note(),
        ]);
      case 'lines':
        children.addAll([
          kick(),
          for (final l in data['lines'] as List) ...[
            r(Text(t(l),
                style: OTTypography.editorialHero(color: fg).copyWith(
                    fontSize: wide ? OTFontSize.s36 : OTFontSize.s26))),
            gap(OTSpacing.md),
          ],
          note(),
        ]);
      case 'question':
        children.addAll([
          r(Icon(Icons.help_outline_rounded,
              size: OTSpacing.massive, color: sub)),
          gap(OTSpacing.lg),
          r(Text(t(data['q']),
              textAlign: TextAlign.center,
              style: OTTypography.editorialHero(color: fg)
                  .copyWith(fontSize: wide ? OTFontSize.s36 : OTFontSize.s26))),
          if (data['hint'] != null) ...[
            gap(OTSpacing.lg),
            r(Text(t(data['hint']), style: OTTypography.caption(color: sub))),
          ],
        ]);
      case 'dialog':
        children.addAll([
          kick(),
          r(_bubble(t(data['asker']), false, fg, sub)),
          gap(OTSpacing.md),
          r(_bubble(t(data['answer']), true, fg, sub)),
          note(),
        ]);
      case 'quote':
        children.addAll([
          r(Directionality(
            textDirection: TextDirection.rtl,
            child: Text(data['arabic'] as String,
                textAlign: TextAlign.center,
                style: OTTypography.arabicDisplay(color: fg).copyWith(
                    fontSize: wide ? OTFontSize.s36 : OTFontSize.s26)),
          )),
          gap(OTSpacing.lg),
          r(Text(t(data['translation']),
              textAlign: TextAlign.center,
              style: OTTypography.body(color: fg)
                  .copyWith(fontSize: OTFontSize.s18))),
          gap(OTSpacing.sm),
          r(Text(t(data['source']), style: OTTypography.caption(color: sub))),
        ]);
      case 'list':
        children.addAll([
          r(Text(t(data['title']), style: big)),
          gap(OTSpacing.lg),
          for (final it in data['items'] as List) ...[
            r(_card(
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t(it['t']), style: OTTypography.cardTitle(color: fg)),
                  if (it['d'] != null) ...[
                    const SizedBox(height: OTSpacing.xs),
                    Text(t(it['d']), style: OTTypography.body(color: sub)),
                  ],
                ]),
                false)),
          ],
          note(),
        ]);
      case 'cards':
        final items = data['items'] as List;
        children.addAll([
          r(Text(t(data['title']), style: big)),
          gap(OTSpacing.lg),
          r(LayoutBuilder(builder: (ctx, box) {
            final cols = box.maxWidth >= 640 ? 2 : 1;
            final w = (box.maxWidth - (cols - 1) * OTSpacing.md) / cols;
            return Wrap(spacing: OTSpacing.md, children: [
              for (final it in items)
                SizedBox(
                  width: w,
                  child: _card(
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t(it['t']),
                                style: OTTypography.cardTitle(
                                    color: it['hl'] == true
                                        ? OTColors.textPrimary(!dark)
                                        : fg)),
                            if (it['d'] != null) ...[
                              const SizedBox(height: OTSpacing.xs),
                              Text(t(it['d']),
                                  style: OTTypography.body(
                                      color: it['hl'] == true
                                          ? OTColors.textSecondary(!dark)
                                          : sub)),
                            ],
                          ]),
                      it['hl'] == true),
                ),
            ]);
          })),
          note(),
        ]);
      case 'compare':
        final cols = data['cols'] as List;
        children.addAll([
          if (data['title'] != null) ...[
            r(Text(t(data['title']), style: big)),
            gap(OTSpacing.lg),
          ],
          for (final row in data['rows'] as List)
            r(_card(
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t(row[0]).toUpperCase(),
                      style: OTTypography.metadataTag(color: sub)),
                  const SizedBox(height: OTSpacing.md),
                  Text(t(cols[0]),
                      style: OTTypography.captionMedium(color: sub)),
                  Text(t(row[1]), style: OTTypography.body(color: sub)),
                  const SizedBox(height: OTSpacing.md),
                  Text(t(cols[1]),
                      style: OTTypography.captionMedium(color: fg)),
                  Text(t(row[2]), style: OTTypography.bodyMedium(color: fg)),
                ]),
                false)),
        ]);
      case 'assistant':
        children.addAll([
          if (data['start'] == true)
            r(Padding(
              padding: const EdgeInsets.only(bottom: OTSpacing.md),
              child: Chip(
                  label: Text(Loc.tr('moduleStartHere'),
                      style: OTTypography.captionMedium(
                          color: OTColors.textPrimary(!dark))),
                  backgroundColor: OTColors.inverseSurface(dark),
                  side: BorderSide.none),
            )),
          r(Directionality(
            textDirection: TextDirection.rtl,
            child: Text(data['ar'] as String,
                style: OTTypography.arabicDisplay(color: sub)),
          )),
          r(Text(data['name'] as String, style: hero)),
          gap(OTSpacing.xs),
          r(Text(t(data['role']).toUpperCase(),
              style: OTTypography.metadataTag(color: sub))),
          gap(OTSpacing.base),
          r(Text(t(data['desc']),
              style: OTTypography.body(color: fg)
                  .copyWith(fontSize: OTFontSize.s18, height: 1.6))),
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
        children.addAll([
          r(Text(t(data['title']), style: big)),
          gap(OTSpacing.lg),
          for (var n = 0; n < (data['items'] as List).length; n++)
            r(_card(
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: OTSpacing.xl + OTSpacing.sm,
                      child: Text('0${n + 1}',
                          style: OTTypography.captionMedium(color: sub))),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t((data['items'] as List)[n]['t']),
                              style: OTTypography.cardTitle(color: fg)),
                          const SizedBox(height: OTSpacing.xs),
                          Text(t((data['items'] as List)[n]['d']),
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

    final centered = type == 'question' || type == 'quote';
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: wide ? 820 : 640),
        child: LayoutBuilder(builder: (ctx, box) {
          final scroll = SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.lg, vertical: OTSpacing.base),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: box.maxHeight - OTSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: centered
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: children,
              ),
            ),
          );
          return scroll;
        }),
      ),
    );
  }

  Widget _bubble(String text, bool answer, Color fg, Color sub) {
    final fill =
        answer ? OTColors.inverseSurface(dark) : OTColors.surface(dark);
    final ink = answer ? OTColors.textPrimary(!dark) : fg;
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
        child: Text(text,
            style: OTTypography.body(color: ink)
                .copyWith(fontSize: OTFontSize.s18, height: 1.55)),
      ),
    );
  }

  Widget _card(Widget child, bool inverse) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: OTSpacing.md),
        padding: const EdgeInsets.all(OTSpacing.lg),
        decoration: BoxDecoration(
          color:
              inverse ? OTColors.inverseSurface(dark) : OTColors.surface(dark),
          borderRadius: OTRadius.cardBorder,
          border: Border.all(color: OTColors.border(dark)),
        ),
        child: child,
      );
}
