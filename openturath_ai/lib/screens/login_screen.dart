import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_platform.dart';
import '../core/localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/scholarly_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_copy.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../core/app_snackbar.dart';
import '../services/auth_service.dart';
import '../widgets/apple_interactive_wrapper.dart';
import '../widgets/openturath_brand.dart';
import '../widgets/language_switcher.dart';
import '../widgets/desktop_in_app_auth_dialog.dart';

/// LoginScreen: Gerbang Masuk OpenTurath
/// Mengadopsi filosofi desain minimalis modern Claude:
/// - Dark mode hitam pekat (pure deep black)
/// - Light mode putih pekat (pure clean white)
/// - Shape minimalis dengan garis abu-abu tipis (subtle hairline border)
/// - Slogan resmi: "Membaca kitab, menelusuri ibarah." dengan tipografi editorial serif
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _desktopError;
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
        AppSnackBar.error(context, Loc.tr('ui_0fb589d0e6'));
      }
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _desktopError = null;
    });
    try {
      if (AppPlatform.isDesktop) {
        // Desktop In-App Google Sign-In: langsung menyelaraskan sesi Firebase Auth
        // dan sesi browser internal WKWebView sekaligus (1x masuk tanpa perlu 2x).
        final result = await DesktopInAppAuthDialog.show(context);
        if (result != null && result['idToken'] != null) {
          final user = await _authService.signInWithDesktopGoogleToken(
            idToken: result['idToken'] as String,
            email: result['email'] as String?,
            displayName: result['name'] as String?,
          );
          if (user != null && mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            return;
          }
        } else {
          // Dialog ditutup atau dibatalkan oleh pengguna
          return;
        }
      } else {
        final user = await _authService.signInWithGoogle();
        if (!mounted || user == null) return;
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.googleSessionAuth,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('network') ||
              e.toString().contains('SocketException')
          ? AppCopy.networkError
          : (e is FirebaseAuthException && e.code.startsWith('desktop-')
              ? switch (e.code) {
                  'desktop-listener-unavailable' =>
                    AppCopy.desktopListenerError,
                  'desktop-browser-unavailable' =>
                    AppCopy.desktopBrowserError,
                  'desktop-login-timeout' => AppCopy.desktopTimeoutError,
                  _ => e.message ?? AppCopy.googleSignInFailed,
                }
              : e is FirebaseAuthException && AppPlatform.isDesktop
                  ? e.code == 'keychain-error'
                      ? AppCopy.desktopKeychainError
                      : '${AppCopy.googleSignInFailed} (${e.code})'
                  : AppCopy.googleSignInFailed);
      if (AppPlatform.isDesktop) {
        setState(() => _desktopError = message);
      } else {
        AppSnackBar.error(context, message);
      }
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
    Loc.watch(context);
    if (AppPlatform.isDesktop) return _buildDesktopLogin(context);
    const bg = AppTheme.canvasDark;
    const textPrimary = AppTheme.textPrimaryDark;
    const textMuted = AppTheme.textSecondaryDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // ── 1. Visual Symbol: Arch Artwork dengan Fade Bawah Mulus ──
                    _stagger(
                      delayMs: 40,
                      child: const OpenTurathMark(
                          size: 148, color: AppTheme.textPrimaryDark),
                    ),
                    const LanguageSwitcher(),

                    // ── 2. Brand Wordmark: "OpenTurath" ──
                    _stagger(
                      delayMs: 90,
                      child: Text(
                        AppCopy.appName,
                        textAlign: TextAlign.center,
                        style: ScholarlyFonts.newsreader(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                          color: textPrimary,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── 3. Academic Editorial Slogan: "AI for Islamic Scholarship" ──
                    _stagger(
                      delayMs: 140,
                      child: Text(
                        'AI for Islamic Scholarship',
                        textAlign: TextAlign.center,
                        style: ScholarlyFonts.newsreader(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -0.1,
                          color: textMuted,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 56),

                    // ── 4. High-Contrast Solid White Action Pill ──
                    _stagger(
                      delayMs: 200,
                      child: AppleInteractiveWrapper(
                        onTap: _isLoading ? null : _signIn,
                        hapticType: HapticFeedbackType.medium,
                        child: SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0E0E10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0E0E10),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _GoogleGVector(),
                                      const SizedBox(width: 12),
                                      Text(
                                        AppCopy.continueWithGoogle,
                                        style: ScholarlyFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.1,
                                          color: const Color(0xFF0E0E10),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── 5. Minimalist Legal Disclaimer (Proporsional 2-Baris Seimbang) ──
                    _stagger(
                      delayMs: 260,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text.rich(
                          TextSpan(
                            text: '${AppCopy.termsAgreementPrefix}\n',
                            style: ScholarlyFonts.outfit(
                              color: textMuted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: AppCopy.termsOfService,
                                style: const TextStyle(
                                  color: textPrimary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: _termsRecognizer,
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: AppCopy.privacyPolicy,
                                style: const TextStyle(
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
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLogin(BuildContext context) {
    return Scaffold(
      backgroundColor: OTColors.canvasLight,
      body: LayoutBuilder(builder: (context, size) {
        final compact = size.maxWidth < 820;
        final story = Container(
          constraints: BoxConstraints(minHeight: compact ? 260 : 540),
          padding: const EdgeInsets.all(42),
          decoration: BoxDecoration(
            color: OTColors.canvasDark,
            borderRadius: compact
                ? const BorderRadius.vertical(top: Radius.circular(28))
                : const BorderRadius.horizontal(left: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OpenTurathMark(size: 48, color: OTColors.accentDark),
              if (!compact) const Spacer(),
              if (compact) const SizedBox(height: 36),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: OTColors.surfaceSubtleDark,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(Loc.tr('academicSlogan'),
                    style: ScholarlyFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OTColors.textSecondaryDark)),
              ),
              const SizedBox(height: 22),
              Text(AppCopy.appName,
                  style: ScholarlyFonts.newsreader(
                      fontSize: compact ? 38 : 48,
                      fontWeight: FontWeight.w600,
                      color: OTColors.textPrimaryDark)),
              const SizedBox(height: 10),
              Text(Loc.tr('appTagline'),
                  style: ScholarlyFonts.newsreader(
                      fontSize: 21, color: OTColors.textSecondaryDark)),
              const SizedBox(height: 22),
              Text(Loc.tr('desktopLoginIntro'),
                  style: ScholarlyFonts.outfit(
                      fontSize: 15,
                      height: 1.5,
                      color: OTColors.textSecondaryDark)),
              if (!compact) const Spacer(),
            ],
          ),
        );

        final form = Container(
          constraints: BoxConstraints(minHeight: compact ? 360 : 540),
          padding: const EdgeInsets.all(42),
          decoration: BoxDecoration(
            color: OTColors.surfaceLight,
            borderRadius: compact
                ? const BorderRadius.vertical(bottom: Radius.circular(28))
                : const BorderRadius.horizontal(right: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: LanguageSwitcher()),
              if (!compact) const Spacer(),
              if (compact) const SizedBox(height: 18),
              Text(Loc.tr('desktopLoginTitle'),
                  style: ScholarlyFonts.newsreader(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: OTColors.textPrimaryLight)),
              const SizedBox(height: 12),
              Text(Loc.tr('desktopLoginHelp'),
                  style: ScholarlyFonts.outfit(
                      fontSize: 15,
                      height: 1.45,
                      color: OTColors.textSecondaryLight)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _signIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: OTColors.onAccentLight))
                      : _GoogleGVector(),
                  label: Text(
                      _isLoading
                          ? Loc.tr('desktopConnectingGoogle')
                          : AppCopy.continueWithGoogle,
                      style: ScholarlyFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: OTColors.onAccentLight)),
                  style: FilledButton.styleFrom(
                    backgroundColor: OTColors.accentLight,
                    foregroundColor: OTColors.onAccentLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              if (_desktopError != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: OTColors.surfaceSubtleLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 20, color: OTColors.destructiveLight),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(_desktopError!,
                              style: ScholarlyFonts.outfit(
                                  fontSize: 13,
                                  color: OTColors.textPrimaryLight))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(Loc.tr('desktopBrowserHelp'),
                  style: ScholarlyFonts.outfit(
                      fontSize: 12, color: OTColors.textSecondaryLight)),
              if (!compact) const Spacer(),
              if (compact) const SizedBox(height: 32),
              const Divider(color: OTColors.borderSubtleLight),
              const SizedBox(height: 12),
              Text.rich(TextSpan(
                text: '${AppCopy.termsAgreementPrefix} ',
                style: ScholarlyFonts.outfit(
                    fontSize: 12,
                    height: 1.5,
                    color: OTColors.textSecondaryLight),
                children: [
                  TextSpan(
                      text: AppCopy.termsOfService,
                      style:
                          const TextStyle(decoration: TextDecoration.underline),
                      recognizer: _termsRecognizer),
                  const TextSpan(text: ' · '),
                  TextSpan(
                      text: AppCopy.privacyPolicy,
                      style:
                          const TextStyle(decoration: TextDecoration.underline),
                      recognizer: _privacyRecognizer),
                ],
              )),
            ],
          ),
        );

        return Center(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1020),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: OTColors.borderSubtleLight),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: compact
                    ? Column(children: [story, form])
                    : SizedBox(
                        height: 540,
                        child: Row(children: [
                          Expanded(flex: 11, child: story),
                          Expanded(flex: 9, child: form),
                        ])),
              ),
            ),
          ),
        ));
      }),
    );
  }
}

class _GoogleGVector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
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
