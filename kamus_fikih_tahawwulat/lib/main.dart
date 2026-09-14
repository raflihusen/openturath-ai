import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/app_engine_provider.dart';
import 'v1_classic/classic_shell.dart';
import 'v2_openturath/ot_shell.dart';
import 'v2_openturath/theme/ot_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: KamusFikihTahawwulatApp()));
}

class KamusFikihTahawwulatApp extends ConsumerWidget {
  const KamusFikihTahawwulatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesProvider);

    return MaterialApp(
      title: 'قاموس فقه التحولات',
      debugShowCheckedModeBanner: false,
      themeMode: prefs.themeMode,

      // Light Theme — OpenTurath Warm Stone Canvas
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: OTColors.canvasLight,
        colorScheme: ColorScheme.light(
          surface: OTColors.surfaceLight,
          primary: OTColors.accentLight,
        ),
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),

      // Dark Theme — OpenTurath Deep Obsidian
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: OTColors.canvasDark,
        colorScheme: ColorScheme.dark(
          surface: OTColors.surfaceDark,
          primary: OTColors.accentDark,
        ),
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),

      home: _EngineRouter(engineVariant: prefs.engineVariant),
    );
  }
}

/// Routes to the active design engine shell
class _EngineRouter extends StatelessWidget {
  final AppEngineVariant engineVariant;
  const _EngineRouter({required this.engineVariant});

  @override
  Widget build(BuildContext context) {
    switch (engineVariant) {
      case AppEngineVariant.classic:
        return const ClassicShell();
      case AppEngineVariant.openTurath:
        return const OTShell();
    }
  }
}
