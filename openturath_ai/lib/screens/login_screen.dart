import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/routes.dart';
import '../core/app_snackbar.dart';
import '../services/auth_service.dart';

/// LoginScreen: Gerbang Masuk Ruang Riset OpenTurath AI
/// Mengadopsi filosofi desain minimalis modern Claude:
/// - Dark mode hitam pekat (pure deep black)
/// - Light mode putih pekat (pure clean white)
/// - Shape minimalis dengan garis abu-abu tipis (subtle hairline border)
/// - Slogan resmi: "Bridging Turath and Intelligence" dengan tipografi editorial serif
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isGooglePressed = false;
  bool _isEmailPressed = false;
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
      duration: Duration(milliseconds: 350 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, animChild) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
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

    // Claude Palette:
    // Dark: Hitam pekat murni (#0E0E10), abu-abu tipis (#27272A)
    // Light: Putih pekat murni (#FFFFFF), abu-abu tipis (#E5E7EB)
    final bg = isDark ? const Color(0xFF0E0E10) : const Color(0xFFFFFFFF);
    final textPrimary = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF18181B);
    final textMuted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final borderHairline = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF141417) : const Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── 1. Top Brand Mark (Claude-style subtle header) ──
                  _stagger(
                    delayMs: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: SvgPicture.asset(
                            'assets/images/notebooklm_round.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text.rich(
                          TextSpan(
                            text: 'OpenTurath ',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: textPrimary,
                            ),
                            children: const [
                              TextSpan(
                                text: 'AI',
                                style: TextStyle(
                                  color: Color(0xFF22D3EE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── 2. Centerpiece Arch Artwork (Seamless Floating Graphic) ──
                  _stagger(
                    delayMs: 80,
                    child: SizedBox(
                      height: 180,
                      width: 180,
                      child: Image.asset(
                        isDark
                            ? 'assets/images/arch_dark_transparent.png'
                            : 'assets/images/arch_light_transparent.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── 3. Official Slogan: "Bridging Turath and Intelligence" (Editorial Serif) ──
                  _stagger(
                    delayMs: 140,
                    child: Text(
                      'Bridging Turath and Intelligence',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.newsreader(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.3,
                        color: textPrimary,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 52),

                  // ── 4. Continue with Google Button (Pill shape, High-contrast) ──
                  _stagger(
                    delayMs: 200,
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isGooglePressed = true),
                      onTapUp: (_) => setState(() => _isGooglePressed = false),
                      onTapCancel: () => setState(() => _isGooglePressed = false),
                      child: AnimatedScale(
                        scale: _isGooglePressed ? 0.975 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOutCubic,
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                              foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isDark ? const Color(0xFF18181B) : Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _GoogleGVector(),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Continue with Google',
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
                  const SizedBox(height: 18),

                  // ── 5. Claude-style Minimalist Divider: "OR" ──
                  _stagger(
                    delayMs: 240,
                    child: Row(
                      children: [
                        Expanded(child: Container(height: 1, color: borderHairline)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: textMuted,
                            ),
                          ),
                        ),
                        Expanded(child: Container(height: 1, color: borderHairline)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── 6. Secondary Action: "Enter your email" (Claude Minimal Shape with subtle gray hairline) ──
                  _stagger(
                    delayMs: 280,
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isEmailPressed = true),
                      onTapUp: (_) => setState(() => _isEmailPressed = false),
                      onTapCancel: () => setState(() => _isEmailPressed = false),
                      onTap: _signIn,
                      child: AnimatedScale(
                        scale: _isEmailPressed ? 0.98 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderHairline, width: 1.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Enter your email',
                            style: GoogleFonts.outfit(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── 7. Minimalist Legal Footer ──
                  _stagger(
                    delayMs: 320,
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to OpenTurath\'s ',
                        style: GoogleFonts.outfit(
                          color: textMuted,
                          fontSize: 11.5,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'Consumer Terms',
                            style: TextStyle(
                              color: textPrimary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Usage Policy',
                            style: TextStyle(
                              color: textPrimary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ', and acknowledge their '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: textPrimary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: _privacyRecognizer,
                          ),
                          const TextSpan(text: '.'),
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
