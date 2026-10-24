import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/onboarding_copy.dart';
import '../core/routes.dart';
import '../services/onboarding_gate.dart';
import '../widgets/onboarding_art.dart';
import '../widgets/tahawwulat_slide_motion.dart';

/// Pengenalan aplikasi: empat slide singkat tentang OpenTurath, dengan grafik
/// gerak monokrom. Tampil sekali setelah pemasangan; bisa diputar ulang dari
/// Pengaturan ([replay]).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen(
      {super.key, this.next = AppRoutes.login, this.replay = false});

  /// Rute tujuan setelah selesai atau dilewati (diabaikan bila [replay]).
  final String next;
  final bool replay;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _count = 4;
  final PageController _page = PageController();
  final FocusNode _focus = FocusNode();
  int _i = 0;
  bool _leaving = false;

  @override
  void dispose() {
    _page.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_leaving) return;
    _leaving = true;
    await OnboardingGate.markSeen();
    if (!mounted) return;
    if (widget.replay) {
      Navigator.of(context).maybePop();
    } else {
      Navigator.of(context).pushReplacementNamed(widget.next);
    }
  }

  void _go(int d) {
    final n = (_i + d).clamp(0, _count - 1);
    if (n == _i) return;
    if (MediaQuery.of(context).disableAnimations) {
      _page.jumpToPage(n);
    } else {
      _page.animateToPage(n,
          duration: OTMotion.transition * 1.4, curve: OTMotion.curve);
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
    } else if (k == LogicalKeyboardKey.escape && widget.replay) {
      _finish();
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
    final last = _i == _count - 1;
    return Directionality(
      textDirection: Loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: OTColors.canvas(dark),
        body: SafeArea(
          child: Focus(
            focusNode: _focus,
            autofocus: true,
            onKeyEvent: _key,
            child: Column(children: [
              _top(dark, fg, sub),
              Expanded(
                child: ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.stylus,
                  }),
                  child: PageView.builder(
                    controller: _page,
                    itemCount: _count,
                    onPageChanged: (v) => setState(() => _i = v),
                    itemBuilder: (_, k) => AnimatedBuilder(
                      animation: _page,
                      builder: (context, child) {
                        final cur = _page.hasClients && _page.page != null
                            ? _page.page!
                            : _i.toDouble();
                        final d = (cur - k).clamp(-1.0, 1.0);
                        final dir = Loc.isArabic ? -1.0 : 1.0;
                        return Opacity(
                          opacity: 1 - d.abs() * 0.7,
                          child: Transform.translate(
                              offset: Offset(-d * 36 * dir, 0), child: child),
                        );
                      },
                      child: _OnboardingPage(index: k, dark: dark),
                    ),
                  ),
                ),
              ),
              _bottom(dark, fg, sub, last),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _top(bool dark, Color fg, Color sub) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
            OTSpacing.base, OTSpacing.sm, OTSpacing.sm, 0),
        child: Row(children: [
          Expanded(
            child: Row(children: [
              for (var b = 0; b < _count; b++)
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.only(end: OTSpacing.xs),
                    child: ClipRRect(
                      borderRadius: OTRadius.chipBorder,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: b <= _i ? 1 : 0),
                        duration: OTMotion.transition,
                        curve: OTMotion.curve,
                        builder: (_, v, __) => Stack(children: [
                          Container(
                              height: OTSpacing.xs,
                              color: OTColors.border(dark)),
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
          const SizedBox(width: OTSpacing.sm),
          TextButton(
            onPressed: _finish,
            child: Text(
                widget.replay ? OnboardingCopy.close : OnboardingCopy.skip),
          ),
        ]),
      );

  Widget _bottom(bool dark, Color fg, Color sub, bool last) => Padding(
        padding: const EdgeInsets.fromLTRB(
            OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, OTSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SizedBox(
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: OTMotion.fast,
                child: last
                    ? FilledButton(
                        key: const ValueKey('start'),
                        onPressed: _finish,
                        child: Text(OnboardingCopy.start,
                            style: OTTypography.button()),
                      )
                    : OutlinedButton(
                        key: const ValueKey('next'),
                        onPressed: () => _go(1),
                        child: Text(OnboardingCopy.next,
                            style: OTTypography.button()),
                      ),
              ),
            ),
          ),
        ),
      );
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.index, required this.dark});
  final int index;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = OTColors.textPrimary(dark), sub = OTColors.textSecondary(dark);
    final wide = MediaQuery.of(context).size.width >= 880;
    final ar = Loc.isArabic;
    TextStyle serif(double size) => ar
        ? OTTypography.arabicDisplay(color: fg).copyWith(fontSize: size)
        : OTTypography.editorialHero(color: fg).copyWith(fontSize: size);
    final titleStyle = serif(wide ? OTFontSize.s36 : OTFontSize.s26);
    final lead = OTTypography.body(color: sub)
        .copyWith(fontSize: OTFontSize.s18, height: 1.6);

    var step = 0;
    Widget r(Widget w) => SlideReveal(step: step++, child: w);
    Widget words(String t, TextStyle s) =>
        SlideWords(t, style: s, step: step++);

    late final Widget art;
    late final List<Widget> text;
    late final int artFlex;
    switch (index) {
      case 0:
        art = OnboardingLogoArt(dark: dark);
        artFlex = 5;
        text = [
          r(Text(OnboardingCopy.p1Kicker,
              style: OTTypography.metadataTag(color: sub))),
          const SizedBox(height: OTSpacing.md),
          words(OnboardingCopy.p1Title, titleStyle),
          const SizedBox(height: OTSpacing.base),
          words(OnboardingCopy.p1Body, lead),
        ];
      case 1:
        art = OnboardingVersusArt(
            dark: dark,
            left: OnboardingCopy.p2Left,
            right: OnboardingCopy.p2Right,
            rows: OnboardingCopy.p2Rows);
        artFlex = 6;
        text = [words(OnboardingCopy.p2Title, titleStyle)];
      case 2:
        art = OnboardingFieldsArt(
            dark: dark,
            labels: OnboardingCopy.p3Fields,
            exclusiveIndex: 1,
            exclusiveText: OnboardingCopy.p3Exclusive);
        artFlex = 5;
        text = [
          words(OnboardingCopy.p3Title, titleStyle),
          const SizedBox(height: OTSpacing.base),
          words(OnboardingCopy.p3Body, lead),
        ];
      default:
        art = OnboardingAskArt(
            dark: dark,
            question: OnboardingCopy.p4Question,
            explain: OnboardingCopy.p4Explain,
            passage: OnboardingCopy.p4Passage,
            reference: OnboardingCopy.p4Reference);
        artFlex = 6;
        text = [
          words(OnboardingCopy.p4Title, titleStyle),
          const SizedBox(height: OTSpacing.base),
          words(OnboardingCopy.p4Body, lead),
          const SizedBox(height: OTSpacing.base),
          r(Text(OnboardingCopy.p4Note,
              style: OTTypography.caption(color: sub))),
        ];
    }

    final textBlock = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: text,
    );

    if (wide) {
      // Jendela lebar: huruf sedikit lebih besar agar isi tidak mengambang.
      final mq = MediaQuery.of(context);
      return MediaQuery(
          data: mq.copyWith(
              textScaler: TextScaler.linear(mq.textScaler.scale(1) * 1.12)),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Row(children: [
                Expanded(
                    flex: 5,
                    child: Padding(
                        padding: const EdgeInsets.all(OTSpacing.xxl),
                        child: SingleChildScrollView(child: textBlock))),
                Expanded(
                    flex: 6,
                    child: Padding(
                        padding: const EdgeInsets.all(OTSpacing.xl),
                        child: ExcludeSemantics(child: art))),
              ]),
            ),
          ));
    }
    final artBox = Expanded(
      flex: artFlex,
      child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: OTSpacing.lg, vertical: OTSpacing.sm),
          child: ExcludeSemantics(child: art)),
    );
    final textBox = Expanded(
      flex: index == 1 ? 2 : 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.lg, vertical: OTSpacing.sm),
        child: Align(
            alignment: AlignmentDirectional.topStart,
            child: SingleChildScrollView(child: textBlock)),
      ),
    );
    // Perbandingan: judul di atas sebagai pertanyaan, jawabannya di bawah.
    return Column(children: index == 1 ? [textBox, artBox] : [artBox, textBox]);
  }
}
