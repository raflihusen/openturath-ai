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
import 'tahawwulat_slide_view.dart';

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
                          itemBuilder: (_, k) => TahawwulatSlideView(
                              key: ValueKey('slide$k'),
                              data: _slides[k] as Map<String, dynamic>,
                              bab: _t,
                              dark: dark,
                              active: k == _i,
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
