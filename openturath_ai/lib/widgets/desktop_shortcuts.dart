import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_platform.dart';

class DesktopShortcuts extends StatelessWidget {
  const DesktopShortcuts({super.key, required this.child, this.onFind,
    this.onCloseTab, this.onNewTab, this.onSettings, this.onReload, this.onEscape});
  final Widget child;
  final VoidCallback? onFind, onCloseTab, onNewTab, onSettings, onReload, onEscape;

  @override
  Widget build(BuildContext context) {
    if (!AppPlatform.isDesktop) return child;
    final bindings = <ShortcutActivator, VoidCallback>{};
    void bind(LogicalKeyboardKey key, VoidCallback? callback) {
      if (callback == null) return;
      bindings[SingleActivator(key, control: true, includeRepeats: false)] = callback;
      bindings[SingleActivator(key, meta: true, includeRepeats: false)] = callback;
    }
    bind(LogicalKeyboardKey.keyF, onFind);
    bind(LogicalKeyboardKey.keyW, onCloseTab);
    bind(LogicalKeyboardKey.keyT, onNewTab);
    bind(LogicalKeyboardKey.comma, onSettings);
    bind(LogicalKeyboardKey.keyR, onReload);
    if (onEscape != null) {
      bindings[const SingleActivator(LogicalKeyboardKey.escape)] = onEscape!;
    }
    return CallbackShortcuts(bindings: bindings,
      child: Focus(autofocus: true, child: child));
  }
}
