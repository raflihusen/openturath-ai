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
/// Material 3 Expressive dengan animasi stagger entrance dan micro-interactions
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isButtonPressed = false;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl('https://openturath.ai/terms');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl('https://openturath.ai/privacy');
  }

  @override
  void dispose() {
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
        AppSnackBar.error(context, 'Tidak dapat membuka browser: $url');
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
          offset: Offset(0, 22 * (1 - value)),
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
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final textTertiary = isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;
    final pillAction = isDark ? AppTheme.pillActionBgDark : AppTheme.pillActionBgLight;

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // ── 1. Hero Brand with Ambient Glow (Stagger 0ms) ──
                  _stagger(
                    delayMs: 0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: isDark ? 0.35 : 0.18),
                            blurRadius: 36,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/notebooklm_round.svg',
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 2. Scholarly Typography (Stagger 80ms) ──
                  _stagger(
                    delayMs: 80,
                    child: Column(
                      children: [
                        Text(
                          'OpenTurath AI',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Khazanah Turats Ilmiah. Ditopang Nalar AI.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: textSecondary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── 3. Minimalist Feature Pills (Stagger 160ms) ──
                  _stagger(
                    delayMs: 160,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _BadgePill(icon: Icons.menu_book_rounded, label: 'Puluhan Ribu Ibarah', isDark: isDark),
                        _BadgePill(icon: Icons.format_quote_rounded, label: 'Sitasi Presisi', isDark: isDark),
                        _BadgePill(icon: Icons.auto_awesome, label: 'Gemini 2.5 Flash', isDark: isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 44),

                  // ── 4. Google Sign-In Button with Press Feedback (Stagger 240ms) ──
                  _stagger(
                    delayMs: 240,
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isButtonPressed = true),
                      onTapUp: (_) => setState(() => _isButtonPressed = false),
                      onTapCancel: () => setState(() => _isButtonPressed = false),
                      child: AnimatedScale(
                        scale: _isButtonPressed ? 0.97 : 1.0,
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutCubic,
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: FilledButton.styleFrom(
                              backgroundColor: pillAction,
                              foregroundColor: isDark ? AppTheme.canvasDark : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isDark ? AppTheme.canvasDark : Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          'G',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF0B57D0),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Lanjutkan dengan Google',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── 5. Privacy & Terms (Stagger 320ms) ──
                  _stagger(
                    delayMs: 320,
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
                              color: isDark ? AppTheme.accentDark : AppTheme.accentLight,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ' & '),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: TextStyle(
                              color: isDark ? AppTheme.accentDark : AppTheme.accentLight,
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
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000);
    final border = isDark ? const Color(0x1FFFFFFF) : const Color(0x14000000);
    final textColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final iconColor = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
