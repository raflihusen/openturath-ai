import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/l10n/app_dictionary.dart';
import 'core/l10n/language_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/specialist_list_screen.dart';
import 'screens/bookmark_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/google_session_auth_screen.dart';
import 'screens/book_catalog_screen.dart';
import 'screens/book_detail_screen.dart';
import 'models/book_model.dart';
import 'models/agent_model.dart';
import 'models/field_model.dart';
import 'widgets/editorial.dart';
import 'firebase_options.dart';

import 'core/app_config.dart';
import 'core/app_copy.dart';
import 'services/telemetry_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _Bootstrap()));
}

/// Paint the first frame before network or platform initialization starts.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}
class _BootstrapState extends State<_Bootstrap> {
  bool _ready = false;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }
  Future<void> _start() async {
    if (_busy || !mounted) return;
    setState(() { _busy = true; _error = null; });
    try {
      await AppConfig.init();
      // Firebase initialization isn't wrapped in a timeout: a timed-out native
      // initialization could otherwise race a second initialization on retry.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      TelemetryService.instance.init();
      if (mounted) setState(() => _ready = true);
    } catch (error, stack) {
      TelemetryService.instance.reportError(error, stack, context: 'bootstrap');
      if (mounted) setState(() => _error = error is UnsupportedError
          ? AppCopy.deviceNotSupportedMessage : AppCopy.cannotConnectMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_ready) return const OpenTurathApp();
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, darkTheme: AppTheme.darkTheme,
      themeMode: AppConfig.themeNotifier.value,
      locale: Locale(LocaleService.instance.current.languageCode),
      supportedLocales: const [Locale('id'), Locale('en'), Locale('ar')],
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: Scaffold(body: SafeArea(child: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360),
          child: Builder(builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.menu_book_outlined, size: 38),
            const SizedBox(height: 24),
            Text('OpenTurath', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 20),
            if (_error == null) Semantics(liveRegion: true,
              child: Text(context.tr('Menyiapkan ruang kajian…'))),
            if (_error != null) ...[
              Text(context.tr(_error!), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              EditorialButton(label: context.tr('Coba lagi'), onPressed: _busy ? null : _start),
            ],
          ])),
        ),
      )))),
    );
  }
}

class OpenTurathApp extends ConsumerWidget {
  const OpenTurathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppConfig.themeNotifier,
      builder: (context, currentTheme, _) {
        return Builder(builder: (context) {
            final platformBrightness = MediaQuery.maybePlatformBrightnessOf(context) ??
                WidgetsBinding.instance.platformDispatcher.platformBrightness;
            final isDark = currentTheme == ThemeMode.dark || 
                           (currentTheme == ThemeMode.system && platformBrightness == Brightness.dark);

            final overlayStyle = SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: isDark ? AppTheme.canvasDark : AppTheme.canvasLight,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            );

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlayStyle,
              child: MaterialApp(
                title: 'OpenTurath',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: currentTheme,
                locale: Locale(locale.languageCode),
                supportedLocales: const [Locale('id'), Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) => AppLocaleScope(locale: locale,
                  child: Directionality(
                    textDirection: locale.isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: child ?? const SizedBox.shrink(),
                  )),

              // ── Initial Route ──
              initialRoute: AppRoutes.splash,

              // ── Dynamic Route Generator with M3 Expressive Transitions ──
              onGenerateRoute: (settings) {
                Widget page;
                switch (settings.name) {
                  case AppRoutes.splash:
                    page = const SplashScreen();
                    break;
                  case AppRoutes.login:
                    page = const LoginScreen();
                    break;
                  case AppRoutes.dashboard:
                    page = const MainShellScreen();
                    break;
                  case AppRoutes.specialistList:
                    page = SpecialistListScreen(
                      field: settings.arguments is FieldModel ? settings.arguments as FieldModel : null);
                    break;
                  case AppRoutes.bookmark:
                    page = const BookmarkScreen();
                    break;
                  case AppRoutes.profile:
                    page = const ProfileScreen();
                    break;
                  case AppRoutes.agentWebview:
                    // Jalur lama tetap kompatibel, tetapi selalu kembali ke
                    // shell yang memiliki ruang kajian multi-tab persisten.
                    // Ini mencegah dua WebView dengan perilaku copy/close
                    // yang berbeda hidup bersamaan.
                    page = const MainShellScreen();
                    break;
                  case AppRoutes.subscription:
                    page = const SubscriptionScreen();
                    break;
                  case AppRoutes.googleSessionAuth:
                    page = const GoogleSessionAuthScreen();
                    break;
                  case AppRoutes.bookCatalog:
                    page = BookCatalogScreen(
                      agent: settings.arguments is AgentModel
                          ? settings.arguments as AgentModel
                          : null,
                    );
                    break;
                  case AppRoutes.bookDetail:
                    final book = settings.arguments;
                    page = book is CanonicalBookPresentation
                        ? BookDetailScreen(book: book)
                        : const MainShellScreen();
                    break;
                  default:
                    page = const SplashScreen();
                    break;
                }

                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (context) => page,
                );
              },
            ),
          );
        },
      );
    },
  );
}
}


