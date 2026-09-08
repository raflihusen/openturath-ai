import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/specialist_list_screen.dart';
import 'screens/bookmark_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/agent_webview_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/google_session_auth_screen.dart';
import 'firebase_options.dart';

import 'core/app_config.dart';
import 'core/localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Kunci orientasi: hanya portrait ──
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load configuration
  await AppConfig.init();

  // ── Status bar transparan ──
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
    runApp(const OpenTurathApp());
  } catch (e) {
    runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Aplikasi belum terhubung ke server Firebase.\n\nSilakan jalankan "flutterfire configure" di terminal komputer Anda, lalu periksa koneksi Firebase.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
            ),
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppConfig.themeNotifier,
      builder: (context, currentTheme, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppConfig.localeNotifier,
          builder: (context, currentLocale, _) {
            // Apply dynamic status bar theme based on mode (safe fallback)
            final platformBrightness = MediaQuery.maybePlatformBrightnessOf(context) ??
                WidgetsBinding.instance.platformDispatcher.platformBrightness;
            final isDark = currentTheme == ThemeMode.dark || 
                           (currentTheme == ThemeMode.system && platformBrightness == Brightness.dark);
            
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarColor: isDark ? AppTheme.canvasDark : AppTheme.canvasLight,
                systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
            );

            return MaterialApp(
              title: Loc.tr('app_name'),
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentTheme,
              locale: Locale(currentLocale),
              builder: (context, child) => Directionality(
                textDirection: currentLocale == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              ),

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
                    page = const SpecialistListScreen();
                    break;
                  case AppRoutes.bookmark:
                    page = const BookmarkScreen();
                    break;
                  case AppRoutes.profile:
                    page = const ProfileScreen();
                    break;
                  case AppRoutes.agentWebview:
                    page = const AgentWebviewScreen();
                    // Slide & cross-fade for immersive agent workspace
                    return PageRouteBuilder(
                      settings: settings,
                      pageBuilder: (context, animation, secondaryAnimation) => page,
                      transitionDuration: const Duration(milliseconds: 360),
                      reverseTransitionDuration: const Duration(milliseconds: 280),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        );
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.9, 0.0),
                            end: Offset.zero,
                          ).animate(curvedAnimation),
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 0.4, end: 1.0).animate(curvedAnimation),
                            child: child,
                          ),
                        );
                      },
                    );
                  case AppRoutes.subscription:
                    page = const SubscriptionScreen();
                    break;
                  case AppRoutes.googleSessionAuth:
                    page = const GoogleSessionAuthScreen();
                    break;
                  default:
                    page = const SplashScreen();
                    break;
                }

                // Default Material 3 Expressive transition: FadeUpTransition (fade + subtle 30px slide-up)
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, animation, secondaryAnimation) => page,
                  transitionDuration: const Duration(milliseconds: 320),
                  reverseTransitionDuration: const Duration(milliseconds: 240),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
            );
          },
        );
      },
    );
  }
}
