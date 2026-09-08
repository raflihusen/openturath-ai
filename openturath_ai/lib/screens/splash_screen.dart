import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';
import '../core/theme.dart';
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
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
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      String targetRoute;

      if (user != null && !user.isAnonymous) {
        final prefs = await SharedPreferences.getInstance()
            .timeout(const Duration(seconds: 4));
        final isSessionReady = prefs.getBool('google_session_ready') ?? false;
        if (!isSessionReady) {
          targetRoute = AppRoutes.googleSessionAuth;
        } else {
          targetRoute = AppRoutes.dashboard;
        }
      } else {
        targetRoute = AppRoutes.login;
      }

      // Smooth exit transition before navigating
      if (mounted) {
        await _controller.animateBack(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInCubic,
        );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.lmDarkTextPrimary : AppTheme.lmLightTextPrimary;
    final textSecondary = isDark ? AppTheme.lmDarkTextSecondary : AppTheme.lmLightTextSecondary;
    final accent = isDark ? AppTheme.lmDarkAccent : AppTheme.lmLightAccent;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.lmDarkCanvas : AppTheme.lmLightCanvas,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OpenTurathMark(size: 68, color: accent),
                const SizedBox(height: 22),
                Text(
                  'OpenTurath AI',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.6,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ruang Riset Turats Berbasis Kitab',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 44),
                _PulsingDots(color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  final Color color;
  const _PulsingDots({required this.color});

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final shift = (index * 0.25);
            final phase = ((_pulse.value + shift) % 1.0);
            final wave = (0.5 - (phase - 0.5).abs()) * 2; // 0.0 -> 1.0 -> 0.0
            final scale = 0.7 + (0.45 * wave);
            final opacity = (0.3 + (0.7 * wave)).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              width: 7,
              height: 7,
              transform: Matrix4.diagonal3Values(scale, scale, 1.0),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
