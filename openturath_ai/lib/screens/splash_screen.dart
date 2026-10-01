import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../widgets/app_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.resolveInitialRoute});

  final String Function()? resolveInitialRoute;

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
    // Navigator's initial route must finish mounting before it is replaced.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkAuthAndNavigate();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAuthAndNavigate() {
    var targetRoute = AppRoutes.login;
    try {
      if (widget.resolveInitialRoute != null) {
        targetRoute = widget.resolveInitialRoute!();
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && !user.isAnonymous) {
          targetRoute = AppRoutes.dashboard;
        }
      }
    } catch (_) {
      // Reading auth state may fail, but must not leave an endless splash.
      targetRoute = AppRoutes.login;
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, targetRoute);
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
