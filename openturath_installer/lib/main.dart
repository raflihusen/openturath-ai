import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'design/tokens.dart';
import 'engine/fake_engine.dart';
import 'engine/install_engine.dart';
import 'engine/windows_engine.dart';
import 'l10n.dart';
import 'ui/installer_shell.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const size = Size(760, 540);
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: size,
      minimumSize: size,
      maximumSize: size,
      center: true,
      title: 'OpenTurath AI',
      backgroundColor: OT.bg,
      titleBarStyle: TitleBarStyle.hidden,
    ),
    () async {
      await windowManager.setResizable(false);
      await windowManager.show();
    },
  );
  runApp(InstallerApp(engine: _engineFor(args)));
}

/// `--demo` memakai mesin tiruan (pratinjau di macOS). Di Windows rilis, mesin
/// sungguhan dipasang di sini.
InstallEngine _engineFor(List<String> args) {
  if (args.contains('--demo') || !Platform.isWindows) {
    return FakeInstallEngine();
  }
  return WindowsInstallEngine.fromManifest() ?? MissingPayloadEngine();
}

class InstallerApp extends StatelessWidget {
  const InstallerApp({super.key, required this.engine});
  final InstallEngine engine;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'OpenTurath AI',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: OT.bg,
      useMaterial3: true,
    ),
    home: Scaffold(
      backgroundColor: OT.bg,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) => windowManager.startDragging(),
        child: InstallerShell(
          engine: engine,
          autoStart: const bool.fromEnvironment('OT_AUTOSTART'),
          initialLanguage: Strings.detect(
            ui.PlatformDispatcher.instance.locale.languageCode,
          ),
          onClose: () => exit(0),
        ),
      ),
    ),
  );
}
