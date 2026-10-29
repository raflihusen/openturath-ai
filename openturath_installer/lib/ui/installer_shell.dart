import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/mark.dart';
import '../design/tokens.dart';
import '../engine/install_engine.dart';
import '../l10n.dart';

enum _Stage { welcome, installing, done, error }

/// Layar tunggal installer. Seluruh perpindahan terjadi di tempat: tanda di
/// tengah menelusuri dirinya, lalu terisi mengikuti kemajuan nyata, sementara
/// gema arch memuai pelan di belakangnya.
class InstallerShell extends StatefulWidget {
  const InstallerShell({
    super.key,
    required this.engine,
    required this.initialLanguage,
    this.onClose,
    this.autoStart = false,
  });

  final InstallEngine engine;
  final String initialLanguage;
  final VoidCallback? onClose;

  /// Mulai memasang tanpa menunggu klik (mode otomatis dan pratinjau).
  final bool autoStart;

  @override
  State<InstallerShell> createState() => _InstallerShellState();
}

class _InstallerShellState extends State<InstallerShell>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );
  late final AnimationController _echo = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();
  late final AnimationController _level = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late Strings _s = Strings(widget.initialLanguage);
  _Stage _stage = _Stage.welcome;
  bool _optionsOpen = false;
  bool _desktop = true;
  String _phase = 'prepare';
  double _target = 0;
  late final TextEditingController _dir = TextEditingController(
    text: widget.engine.defaultDir,
  );
  StreamSubscription<InstallProgress>? _sub;
  bool _reduce = false;
  final ValueNotifier<Offset> _look = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      Future<void>.delayed(const Duration(milliseconds: 3600), () {
        if (mounted && _stage == _Stage.welcome) _start();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final r = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (r != _reduce || !_intro.isAnimating && _intro.value == 0) {
      _reduce = r;
      if (_reduce) {
        _intro.value = 1;
      } else if (_intro.value == 0) {
        _intro.forward();
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _intro.dispose();
    _echo.dispose();
    _level.dispose();
    _burst.dispose();
    _dir.dispose();
    _look.dispose();
    super.dispose();
  }

  void _start() {
    if (_dir.text.trim().isEmpty) return;
    setState(() {
      _stage = _Stage.installing;
      _phase = 'prepare';
      _target = 0;
    });
    _level.value = 0;
    _sub = widget.engine
        .install(
          InstallOptions(dir: _dir.text.trim(), desktopShortcut: _desktop),
        )
        .listen(
          (p) {
            if (!mounted) return;
            setState(() {
              _phase = p.phase;
              _target = p.value;
            });
            _level.animateTo(
              p.value.clamp(0, 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOut,
            );
          },
          onError: (_) {
            if (mounted) setState(() => _stage = _Stage.error);
          },
          onDone: () {
            if (!mounted || _stage != _Stage.installing) return;
            _level.animateTo(1, duration: const Duration(milliseconds: 380));
            setState(() => _stage = _Stage.done);
            if (!_reduce) _burst.forward(from: 0);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _s.rtl ? TextDirection.rtl : TextDirection.ltr,
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: _s.rtl ? OT.arabic : OT.sans,
          color: OT.ink,
          fontSize: 14,
          decoration: TextDecoration.none,
        ),
        child: ColoredBox(
          color: OT.bg,
          child: LayoutBuilder(
            builder: (context, c) {
              final markSize = math.min(170.0, c.maxHeight * 0.32);
              final markTop = math.max(28.0, c.maxHeight * 0.08);
              final center = Offset(c.maxWidth / 2, markTop + markSize / 2);
              return MouseRegion(
                onHover: (e) => _look.value = _reduce
                    ? Offset.zero
                    : Offset(
                        (e.localPosition.dx / c.maxWidth - .5) * 2,
                        (e.localPosition.dy / c.maxHeight - .5) * 2,
                      ),
                onExit: (_) => _look.value = Offset.zero,
                child: Stack(
                  children: [
                    // Gema arch di belakang.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _Parallax(
                          look: _look,
                          depth: 14,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _echo,
                              _level,
                              _burst,
                            ]),
                            builder: (_, _) => CustomPaint(
                              painter: EchoPainter(
                                phase: _echo.value,
                                center: center,
                                shock: _stage == _Stage.done ? _burst.value : 0,
                                intensity: switch (_stage) {
                                  _Stage.installing => 0.5 + 0.5 * _level.value,
                                  _Stage.done => 1 - _burst.value * 0.7,
                                  _ => 0.15 * _intro.value,
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Tanda.
                    Positioned(
                      top: markTop,
                      left: 0,
                      right: 0,
                      height: markSize,
                      child: _Parallax(
                        look: _look,
                        depth: 6,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _intro,
                            _level,
                            _burst,
                            _echo,
                          ]),
                          builder: (_, _) {
                            final trace = Curves.easeInOutCubic.transform(
                              (_intro.value / 0.62).clamp(0, 1),
                            );
                            final fillIn = ((_intro.value - 0.55) / 0.35).clamp(
                              0.0,
                              1.0,
                            );
                            final working = _stage == _Stage.installing;
                            final done = _stage == _Stage.done;
                            final pulse = done
                                ? 1 + 0.045 * math.sin(_burst.value * math.pi)
                                : 1.0;
                            final breathe =
                                _stage == _Stage.welcome && _intro.value >= 1
                                ? 1 +
                                      0.012 *
                                          math.sin(_echo.value * math.pi * 6)
                                : 1.0;
                            return Transform.scale(
                              scale: pulse * breathe,
                              child: CustomPaint(
                                painter: MarkPainter(
                                  trace: working || done ? 1 : trace,
                                  fill: working
                                      ? 0
                                      : (_stage == _Stage.error
                                            ? 0.35
                                            : fillIn),
                                  level: working || done ? _level.value : 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Isi bertahap.
                    Positioned.fill(
                      top: markTop + markSize + 18,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 420),
                        switchInCurve: OT.ease,
                        transitionBuilder: (child, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, .04),
                              end: Offset.zero,
                            ).animate(a),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_stage),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 44),
                            child: Center(
                              child: switch (_stage) {
                                _Stage.welcome => _welcome(),
                                _Stage.installing => _installing(),
                                _Stage.done => _done(),
                                _Stage.error => _error(),
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bilah atas.
                    Positioned(top: 10, left: 14, right: 14, child: _topBar()),
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'openturath.id  ·  ${_s.privacy}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: OT.sub,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Bilah atas: bahasa dan tutup ──
  Widget _topBar() => Row(
    children: [
      const Spacer(),
      for (final c in Strings.codes)
        _Chip(
          label: c.toUpperCase(),
          active: _s.code == c,
          onTap: () => setState(() => _s = Strings(c)),
        ),
      const SizedBox(width: 6),
      if (_stage != _Stage.installing)
        _IconBtn(
          icon: Icons.close_rounded,
          tip: _s.closeTip,
          onTap: widget.onClose,
        ),
    ],
  );

  // ── Layar-layar ──
  Widget _titleText(String t) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 260),
    child: Text(
      t,
      key: ValueKey('${_s.code}$t'),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: _s.rtl ? OT.arabic : OT.serif,
        fontSize: 40,
        height: 1.1,
        letterSpacing: -.5,
      ),
    ),
  );

  Widget _subText(String t) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 260),
    child: Text(
      t,
      key: ValueKey('${_s.code}$t'),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16, color: OT.sub, height: 1.5),
    ),
  );

  Widget _title(String t, {String? sub}) => Column(
    children: [
      _titleText(t),
      if (sub != null) ...[const SizedBox(height: 10), _subText(sub)],
    ],
  );

  Widget _welcome() => Column(
    children: [
      _Reveal(
        controller: _intro,
        from: .56,
        child: _titleText('OpenTurath AI'),
      ),
      const SizedBox(height: 10),
      _Reveal(controller: _intro, from: .64, child: _subText(_s.tagline)),
      const SizedBox(height: 26),
      _Reveal(
        controller: _intro,
        from: .72,
        child: _Primary(label: _s.install, onTap: _start),
      ),
      const SizedBox(height: 14),
      _Reveal(
        controller: _intro,
        from: .80,
        child: _Quiet(
          label: _s.options,
          open: _optionsOpen,
          onTap: () => setState(() => _optionsOpen = !_optionsOpen),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: OT.ease,
        alignment: Alignment.topCenter,
        child: _optionsOpen
            ? _optionsPanel()
            : const SizedBox(width: double.infinity),
      ),
    ],
  );

  Widget _optionsPanel() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: SizedBox(
      width: 420,
      child: Column(
        children: [
          TextField(
            controller: _dir,
            style: const TextStyle(fontSize: 12.5, color: OT.sub),
            decoration: InputDecoration(
              isDense: true,
              labelText: _s.location,
              labelStyle: const TextStyle(color: OT.sub, fontSize: 12),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: OT.line),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: OT.ink),
              ),
            ),
            cursorColor: OT.ink,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => setState(() => _desktop = !_desktop),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _desktop ? OT.ink : Colors.transparent,
                      border: Border.all(
                        color: _desktop ? OT.ink : OT.lineStrong,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: _desktop
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: OT.bg,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _s.shortcut,
                    style: const TextStyle(fontSize: 13, color: OT.sub),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _installing() {
    final pct = (_target * 100).clamp(0, 100).round();
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(end: pct.toDouble()),
          duration: const Duration(milliseconds: 300),
          builder: (_, v, _) => Text(
            '${v.round()}%',
            style: TextStyle(
              fontFamily: OT.serif,
              fontSize: 56,
              height: 1.1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 360,
          height: 3,
          child: AnimatedBuilder(
            animation: _level,
            builder: (_, _) => ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                children: [
                  const ColoredBox(color: OT.line, child: SizedBox.expand()),
                  FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: _level.value.clamp(0, 1),
                    child: const ColoredBox(
                      color: OT.ink,
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _s.phase(_phase),
            key: ValueKey('${_s.code}$_phase'),
            style: const TextStyle(fontSize: 13, color: OT.sub),
          ),
        ),
      ],
    );
  }

  Widget _done() => Column(
    children: [
      _title(_s.doneTitle, sub: _s.doneSub),
      const SizedBox(height: 26),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Primary(
            label: _s.open,
            onTap: () async {
              await widget.engine.launch(_dir.text.trim());
              widget.onClose?.call();
            },
          ),
          const SizedBox(width: 12),
          _Ghost(label: _s.close, onTap: widget.onClose),
        ],
      ),
    ],
  );

  Widget _error() => Column(
    children: [
      _title(_s.errorTitle, sub: _s.errorSub),
      const SizedBox(height: 26),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Primary(
            label: _s.retry,
            onTap: () => setState(() {
              _stage = _Stage.welcome;
              _level.value = 0;
            }),
          ),
          const SizedBox(width: 12),
          _Ghost(label: _s.close, onTap: widget.onClose),
        ],
      ),
    ],
  );
}

/// Menampilkan anak dengan jeda setelah gambar tanda selesai ditelusuri.
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.controller,
    required this.child,
    this.from = 0.6,
  });
  final AnimationController controller;
  final double from;
  final Widget child;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (_, c) {
      final t = Curves.easeOutCubic.transform(
        ((controller.value - from) / 0.28).clamp(0.0, 1.0),
      );
      return Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: c),
      );
    },
    child: child,
  );
}

class _Primary extends StatefulWidget {
  const _Primary({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;
  @override
  State<_Primary> createState() => _PrimaryState();
}

class _PrimaryState extends State<_Primary> {
  bool _hover = false, _down = false;
  @override
  Widget build(BuildContext context) => FocusableActionDetector(
    mouseCursor: SystemMouseCursors.click,
    onShowHoverHighlight: (v) => setState(() => _hover = v),
    actions: {
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (_) => widget.onTap?.call(),
      ),
    },
    child: GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? .97 : (_hover ? 1.03 : 1),
        duration: const Duration(milliseconds: 160),
        curve: OT.ease,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 34),
          decoration: BoxDecoration(
            color: _hover ? Colors.white : OT.ink,
            borderRadius: BorderRadius.circular(999),
            boxShadow: _hover
                ? const [BoxShadow(color: Color(0x33FAFAFA), blurRadius: 24)]
                : null,
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              widget.label,
              style: const TextStyle(
                color: OT.bg,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Ghost extends StatelessWidget {
  const _Ghost({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: OT.lineStrong),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    ),
  );
}

class _Quiet extends StatelessWidget {
  const _Quiet({required this.label, required this.open, required this.onTap});
  final String label;
  final bool open;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: OT.sub)),
          const SizedBox(width: 4),
          AnimatedRotation(
            turns: open ? .5 : 0,
            duration: const Duration(milliseconds: 260),
            child: const Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: OT.sub,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? OT.ink : Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: .6,
          color: active ? OT.ink : OT.sub,
        ),
      ),
    ),
  );
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.tip, required this.onTap});
  final IconData icon;
  final String tip;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: OT.sub),
      ),
    ),
  );
}

/// Menggeser anak sedikit mengikuti penunjuk, dengan peredaman, sehingga lapisan
/// belakang dan depan terasa punya kedalaman.
class _Parallax extends StatelessWidget {
  const _Parallax({
    required this.look,
    required this.depth,
    required this.child,
  });
  final ValueNotifier<Offset> look;
  final double depth;
  final Widget child;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Offset>(
    valueListenable: look,
    child: child,
    builder: (_, v, c) => TweenAnimationBuilder<Offset>(
      tween: Tween(end: v),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOut,
      child: c,
      builder: (_, o, c) => Transform.translate(
        offset: Offset(-o.dx * depth, -o.dy * depth),
        child: c,
      ),
    ),
  );
}
