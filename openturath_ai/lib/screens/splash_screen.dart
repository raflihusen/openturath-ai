import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../widgets/native_components.dart';
import '../core/design/native_design.dart';

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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = NativeColors.canvas(dark);
    final textPrimary = NativeColors.textPrimary(dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: Center(
          child: FadeTransition(
            opacity: MediaQuery.disableAnimationsOf(context) ? const AlwaysStoppedAnimation(1.0) : _fadeAnimation,
            child: ScaleTransition(
              scale: MediaQuery.disableAnimationsOf(context) ? const AlwaysStoppedAnimation(1.0) : _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'OpenTurath',
                    style: GoogleFonts.newsreader(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const NativeLoading(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
