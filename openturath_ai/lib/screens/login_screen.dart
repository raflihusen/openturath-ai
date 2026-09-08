import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../core/app_snackbar.dart';
import '../services/auth_service.dart';

/// LoginScreen: Gerbang Masuk Ruang Riset OpenTurath AI
/// Desain Out-of-the-box berestetika Celestial Astrolabe & Crystalline Bento Minimalist
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isButtonPressed = false;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl('https://openturath.ai/terms');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl('https://openturath.ai/privacy');

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openLegalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, 'Tidak dapat membuka tautan: $url');
      }
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (!mounted || user == null) return;
      Navigator.pushReplacementNamed(context, AppRoutes.googleSessionAuth);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Gagal masuk: $e. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _stagger({required int delayMs, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, animChild) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: animChild,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = isDark ? const Color(0xFF080C10) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final textTertiary = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;
    final surfaceGlass = isDark ? const Color(0x14FFFFFF) : const Color(0x08000000);
    final borderGlass = isDark ? const Color(0x1FFFFFFF) : const Color(0x12000000);

    return Scaffold(
      backgroundColor: canvas,
      body: Stack(
        children: [
          // ── A. Celestial Astrolabe Ambient Aura Background ──
          Positioned.fill(
            child: CustomPaint(
              painter: _AstrolabeBackgroundPainter(
                isDark: isDark,
                accent: accent,
              ),
            ),
          ),

          // ── B. Breathing Radial Glow ──
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 0.92 + (_pulseController.value * 0.16);
                final opacity = (isDark ? 0.22 : 0.12) * _pulseController.value;
                return Center(
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accent.withValues(alpha: opacity),
                            const Color(0xFF10B981).withValues(alpha: opacity * 0.5),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── C. Main Content Layer ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── 1. Hero Insignia with Breathing Halo ──
                      _stagger(
                        delayMs: 0,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accent.withValues(alpha: 0.35),
                                    const Color(0xFF10B981).withValues(alpha: 0.2),
                                    accent.withValues(alpha: 0.08),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: isDark ? 0.28 : 0.15),
                                    blurRadius: 32,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(3),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? const Color(0xFF0E151D) : Colors.white,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  'assets/images/notebooklm_round.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── 2. Basmalah Calligraphic Micro-Seal ──
                      _stagger(
                        delayMs: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: surfaceGlass,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: borderGlass, width: 0.8),
                          ),
                          child: Text(
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            style: GoogleFonts.amiri(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 3. Brand Title & Scholarly Motto ──
                      _stagger(
                        delayMs: 120,
                        child: Column(
                          children: [
                            Text(
                              'OpenTurath AI',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: textPrimary,
                                fontSize: 31,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '« نُورُ التُّرَاثِ • بِبَصِيرَةِ الذَّكَاءِ »',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.amiri(
                                color: accent,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Khazanah Turats Ilmiah & Dialektika Naskah Klasik Islam',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: textSecondary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── 4. Out-of-the-Box Bento Crystalline Pillar Triad ──
                      _stagger(
                        delayMs: 180,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F1722).withValues(alpha: 0.85) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: borderGlass,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _PillarItem(
                                icon: Icons.auto_stories_rounded,
                                iconColor: const Color(0xFF10B981),
                                title: '50.000+',
                                subtitle: 'Ibarah Kitab',
                                isDark: isDark,
                              ),
                              _VerticalDivider(isDark: isDark),
                              _PillarItem(
                                icon: Icons.balance_rounded,
                                iconColor: const Color(0xFF06B6D4),
                                title: '4 Mazhab',
                                subtitle: 'Fikih & Ushul',
                                isDark: isDark,
                              ),
                              _VerticalDivider(isDark: isDark),
                              _PillarItem(
                                icon: Icons.verified_rounded,
                                iconColor: const Color(0xFFF59E0B),
                                title: 'Presisi',
                                subtitle: 'Sanad Rujukan',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── 5. Google Sign-In Luxury Tactile Button ──
                      _stagger(
                        delayMs: 240,
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _isButtonPressed = true),
                          onTapUp: (_) => setState(() => _isButtonPressed = false),
                          onTapCancel: () => setState(() => _isButtonPressed = false),
                          child: AnimatedScale(
                            scale: _isButtonPressed ? 0.97 : 1.0,
                            duration: const Duration(milliseconds: 130),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              height: 52,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.white : const Color(0xFF0F172A)).withValues(alpha: isDark ? 0.12 : 0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: FilledButton(
                                onPressed: _isLoading ? null : _signIn,
                                style: FilledButton.styleFrom(
                                  backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                  foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _GoogleGVector(),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Lanjutkan dengan Google',
                                            style: GoogleFonts.outfit(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── 6. Trust Micro-Indicator ──
                      _stagger(
                        delayMs: 290,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: textTertiary),
                            const SizedBox(width: 6),
                            Text(
                              'Ruang Riset Terenkripsi • Otentikasi Resmi Google',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 7. Terms & Privacy Disclaimer ──
                      _stagger(
                        delayMs: 340,
                        child: Text.rich(
                          TextSpan(
                            text: 'Dengan masuk, Anda menyetujui ',
                            style: GoogleFonts.outfit(
                              color: textTertiary,
                              fontSize: 11,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'Ketentuan Layanan',
                                style: TextStyle(
                                  color: accent,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: _termsRecognizer,
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Kebijakan Privasi',
                                style: TextStyle(
                                  color: accent,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: _privacyRecognizer,
                              ),
                              const TextSpan(text: ' OpenTurath AI.'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarItem extends StatelessWidget {
  const _PillarItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: isDark ? 0.16 : 0.1),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDark ? const Color(0x1AFFFFFF) : const Color(0x12000000),
    );
  }
}

class _GoogleGVector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="20px" height="20px">
  <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"/>
  <path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"/>
  <path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"/>
  <path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"/>
</svg>
''',
      width: 20,
      height: 20,
    );
  }
}

class _AstrolabeBackgroundPainter extends CustomPainter {
  const _AstrolabeBackgroundPainter({
    required this.isDark,
    required this.accent,
  });

  final bool isDark;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.22);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.04 : 0.025);

    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = accent.withValues(alpha: isDark ? 0.07 : 0.04);

    // Celestial concentric horizon rings
    canvas.drawCircle(center, 90, paint);
    canvas.drawCircle(center, 150, paint);
    canvas.drawCircle(center, 220, accentPaint);
    canvas.drawCircle(center, 300, paint);

    // Subtle 8-point geometric quadrant guidelines
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final p1 = Offset(
        center.dx + 90 * math.cos(angle),
        center.dy + 90 * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + 220 * math.cos(angle),
        center.dy + 220 * math.sin(angle),
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AstrolabeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.accent != accent;
}
