import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_config.dart';
import 'core/app_platform.dart';
import 'core/theme.dart';
import 'screens/browser_workspace_screen.dart';

// The native apps are launchers for the shared browser workspace. They do not
// authenticate Firebase separately or create a second Google cookie store.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppPlatform.isAndroid) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  try {
    await AppConfig.init();
  } catch (_) {
    // Local display preferences must not prevent opening the browser.
  }
  runApp(const OpenTurathApp());
}

class OpenTurathApp extends StatelessWidget {
  const OpenTurathApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
        valueListenable: AppConfig.themeNotifier,
        builder: (context, mode, _) => MaterialApp(
          title: 'OpenTurath',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const BrowserWorkspaceScreen(),
        ),
      );
}
