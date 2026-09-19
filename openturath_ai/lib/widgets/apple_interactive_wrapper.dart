import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pointer, keyboard and assistive actions share exactly one activation path.
class AppleInteractiveWrapper extends StatefulWidget {
  const AppleInteractiveWrapper({super.key, required this.child, this.onTap,
    this.onLongPress, this.pressedScale = .985,
    this.duration = const Duration(milliseconds: 140), this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.selection, this.borderRadius, this.semanticLabel});
  final Widget child;
  final VoidCallback? onTap, onLongPress;
  final double pressedScale;
  final Duration duration;
  final bool enableHaptic;
  final HapticFeedbackType hapticType;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  @override
  State<AppleInteractiveWrapper> createState() => _AppleInteractiveWrapperState();
}
enum HapticFeedbackType { light, medium, selection, none }
class _AppleInteractiveWrapperState extends State<AppleInteractiveWrapper> {
  bool _pressed = false, _focused = false, _hovered = false;
  bool get _enabled => widget.onTap != null || widget.onLongPress != null;
  void _activate([bool long = false]) {
    final action = long ? widget.onLongPress : widget.onTap;
    if (action == null) return;
    if (widget.enableHaptic) {
      switch (widget.hapticType) {
        case HapticFeedbackType.light: HapticFeedback.lightImpact(); break;
        case HapticFeedbackType.medium: HapticFeedback.lightImpact(); break;
        case HapticFeedbackType.selection: HapticFeedback.selectionClick(); break;
        case HapticFeedbackType.none: break;
      }
    }
    action();
  }
  void _press(bool value) { if (_pressed != value && mounted) setState(() => _pressed = value); }
  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final ink = Theme.of(context).colorScheme.onSurface;
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
        _activate(widget.onTap == null); return null;
      })},
      child: Semantics(button: true, enabled: true, label: widget.semanticLabel,
        onTap: widget.onTap == null ? null : () => _activate(),
        onLongPress: widget.onLongPress == null ? null : () => _activate(true),
        child: GestureDetector(behavior: HitTestBehavior.opaque, excludeFromSemantics: true,
          onTapDown: (_) => _press(true), onTapUp: (_) => _press(false), onTapCancel: () => _press(false),
          onTap: widget.onTap == null ? null : () => _activate(),
          onLongPress: widget.onLongPress == null ? null : () { _press(false); _activate(true); },
          child: AnimatedScale(scale: !reduce && _pressed ? widget.pressedScale : 1,
            duration: reduce ? Duration.zero : (_pressed ? widget.duration : const Duration(milliseconds: 220)),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(duration: reduce ? Duration.zero : const Duration(milliseconds: 140),
              foregroundDecoration: BoxDecoration(
                color: _hovered ? ink.withValues(alpha: .035) : Colors.transparent,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                border: _focused ? Border.all(color: ink, width: 2) : null),
              child: widget.child)),
        )),
    );
  }
}
