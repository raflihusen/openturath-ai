import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../core/scholarly_fonts.dart';
import '../widgets/app_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String targetRoute;

      if (user != null && !user.isAnonymous) {
        final prefs = await SharedPreferences.getInstance()
            .timeout(const Duration(seconds: 3));
        final isSessionReady = prefs.getBool('google_session_ready') ?? false;
        if (!isSessionReady) {
          targetRoute = AppRoutes.googleSessionAuth;
        } else {
          targetRoute = AppRoutes.dashboard;
        }
      } else {
        targetRoute = AppRoutes.login;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, targetRoute);
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = AppTheme.canvasDark;
    const textPrimary = AppTheme.textPrimaryDark;
    const accent = AppTheme.textSecondaryDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: OTColors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'OpenTurath',
                    style: ScholarlyFonts.newsreader(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const AppLoader(color: accent, dotSize: 7, spacing: 3.5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
