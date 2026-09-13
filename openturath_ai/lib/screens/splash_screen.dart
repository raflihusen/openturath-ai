import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../widgets/app_loader.dart';
import '../widgets/openturath_brand.dart';

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
  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.05, 0.7, 0.1, 1.0),
      ),
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

      // Elegant breathing threshold: Ensure minimum 950ms display for graceful cold start
      final elapsed = DateTime.now().difference(_startTime);
      const minDisplayDuration = Duration(milliseconds: 950);
      if (elapsed < minDisplayDuration) {
        await Future.delayed(minDisplayDuration - elapsed);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, targetRoute);
    } catch (_) {
      final elapsed = DateTime.now().difference(_startTime);
      const minDisplayDuration = Duration(milliseconds: 950);
      if (elapsed < minDisplayDuration) {
        await Future.delayed(minDisplayDuration - elapsed);
      }
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
        statusBarColor: Colors.transparent,
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
                  const OpenTurathMark(size: 44),
                  const SizedBox(height: 18),
                  Text(
                    'OpenTurath',
                    style: GoogleFonts.newsreader(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Maktabah AI',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const AppLoader(color: accent, dotSize: 7, spacing: 4.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
