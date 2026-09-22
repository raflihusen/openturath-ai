import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'widgets/native_theme.dart';
import 'models/field_model.dart';
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
import 'firebase_options.dart';

import 'core/app_config.dart';
import 'core/app_copy.dart';
import 'core/localization.dart';
import 'services/telemetry_service.dart';
import 'widgets/app_error_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Kunci orientasi: hanya portrait ──
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load configuration
  try {
    await AppConfig.init();
  } catch (_) {}

  // ── Status bar transparan awal ──
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // ── Inisialisasi Firebase ──
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ── Inisialisasi Silent Telemetry ──
    TelemetryService.instance.init();
    runApp(const OpenTurathApp());
  } catch (error, stackTrace) {
    debugPrint('[OpenTurath] Firebase initialization error: $error\n$stackTrace');
    TelemetryService.instance.reportError(
      error,
      stackTrace,
      context: 'firebase_init_failure',
      severity: 'critical',
    );
    final isUnsupportedPlatform = error is UnsupportedError;
    final title = isUnsupportedPlatform
        ? AppCopy.deviceNotSupportedTitle
        : AppCopy.cannotConnectTitle;
    final message = isUnsupportedPlatform
        ? AppCopy.deviceNotSupportedMessage
        : AppCopy.cannotConnectMessage;

    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: AppTheme.canvasDark,
        body: SafeArea(
          child: AppErrorState(
            title: title,
            message: message,
            onRetry: () => main(),
          ),
        ),
      ),
    ));
  }
}

class OpenTurathApp extends StatelessWidget {
  const OpenTurathApp({super.key});

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppConfig.themeNotifier,
      builder: (context, currentTheme, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppConfig.localeNotifier,
          builder: (context, currentLocale, _) {
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
                title: AppCopy.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: currentTheme,
                locale: Locale(currentLocale),
                supportedLocales: Loc.supportedLocales,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                builder: (context, child) => LocaleScope(child: Directionality(
                  textDirection: currentLocale == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
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
                    final args = settings.arguments;
                    final fieldId = args is Map ? args['fieldId'] : null;
                    final matches = FieldModel.defaultFields.where((field) => field.id == fieldId);
                    page = SpecialistListScreen(field: matches.firstOrNull);
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
                    final book = settings.arguments as CanonicalBookPresentation;
                    page = BookDetailScreen(book: book);
                    break;
                  default:
                    page = const SplashScreen();
                    break;
                }

                // Default Material 3 Expressive transition: FadeUpTransition (fade + subtle 30px slide-up)
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      page is MainShellScreen || page is GoogleSessionAuthScreen
                        ? page : NativeTheme(child: page),
                  transitionDuration: const Duration(milliseconds: 320),
                  reverseTransitionDuration: const Duration(milliseconds: 240),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    if (MediaQuery.disableAnimationsOf(context)) return child;
                    final curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    );
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.04),
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                        child: child,
                      ),
                    );
                  },
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
