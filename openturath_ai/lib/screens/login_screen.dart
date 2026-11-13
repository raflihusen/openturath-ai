import '../core/app_platform.dart';
import '../core/localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/scholarly_fonts.dart';

import '../core/app_copy.dart';
import '../core/login_error_message.dart';
import '../core/routes.dart';
import '../core/design/ot_buttons.dart';
import '../core/design/ot_colors.dart';
import '../widgets/ot_motion_widgets.dart';
import '../core/app_snackbar.dart';
import '../services/auth_service.dart';
import '../services/persistent_google_session.dart';
import '../widgets/openturath_brand.dart';
import '../widgets/language_switcher.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';

import '../widgets/legal_document_sheet.dart';
import '../widgets/app_loader.dart';
import '../core/design/ot_motion.dart';

/// A shared, theme-adaptive sign-in surface for mobile and desktop.
/// Desain monokrom obsidian murni: kartu terpusat, tanpa cover ramai,
/// langsung masuk dengan Google tanpa tahapan kedua.
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
      ..onTap = () {
        if (mounted) LegalDocumentSheet.showTermsOfService(context);
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        if (mounted) LegalDocumentSheet.showPrivacyPolicy(context);
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _desktopError = null;
    });
    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        final userEmail = user.email.trim().toLowerCase();
        await AuthService.reconcileWebSession(userEmail);
        try {
          await PersistentGoogleSession.instance
              .restoreSessionIfAvailable(userEmail)
              .timeout(const Duration(seconds: 2));
        } catch (_) {}
        if (!mounted ||
            !_authService.hasAuthenticatedSession ||
            _authService.cachedCurrentUser?.uid != user.uid) {
          return;
        }
        // Single login mulus: langsung masuk ke Dashboard tanpa memaksa layar kedua
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;
      final message = loginErrorMessage(e);
      if (message.isEmpty) return;
      if (AppPlatform.isDesktop) {
        setState(() => _desktopError = message);
      } else {
        AppSnackBar.error(context, message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(dark);
    final primary = OTColors.textPrimary(dark);
    final secondary = OTColors.textSecondary(dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: canvas,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: canvas,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, viewport) {
            Widget titleText() => OTReveal(
                  delayMs: OTMotion.loginHeadlineMs,
                  child: Text(
                    Loc.tr('loginTitle'),
                    textAlign: TextAlign.center,
                    style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      height: 1.2,
                      color: primary,
                    ),
                  ),
                );

            Widget subtitleText() => OTReveal(
                  delayMs: OTMotion.loginHeadlineMs + 50,
                  child: Text(
                    AppCopy.appTagline,
                    textAlign: TextAlign.center,
                    style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: secondary,
                    ),
                  ),
                );

            Widget signInButton() => OTReveal(
                  delayMs: OTMotion.loginButtonMs,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      style: dark ? OTButtons.onInverse(dark) : null,
                      onPressed: _isLoading ? null : _signIn,
                      icon: _isLoading
                          ? AppLoader(dotSize: 5, spacing: 2, color: primary)
                          : _GoogleGVector(),
                      label: Text(
                        _isLoading
                            ? Loc.tr('desktopConnectingGoogle')
                            : AppCopy.continueWithGoogle,
                        textAlign: TextAlign.center,
                        style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s16,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                );

            Widget errorBox() => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: OTColors.surfaceSubtle(dark),
                        border: Border.all(color: OTColors.border(dark)),
                        borderRadius: BorderRadius.circular(OTRadius.xs),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 18, color: primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _desktopError!,
                              style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s14,
                                  height: 1.5,
                                  color: primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

            Widget legalText() => OTReveal(
                  delayMs: OTMotion.loginLegalMs,
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      text: '${AppCopy.termsAgreementPrefix} ',
                      style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s12, height: 1.6, color: secondary),
                      children: [
                        TextSpan(
                          text: AppCopy.termsOfService.replaceAll(' ', '\u00A0'),
                          style: TextStyle(
                            color: primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _termsRecognizer,
                        ),
                        TextSpan(
                          text: switch (Loc.language) {
                            'en' => ' and ',
                            'ar' => ' و',
                            _ => ' dan ',
                          },
                        ),
                        TextSpan(
                          text: AppCopy.privacyPolicy.replaceAll(' ', '\u00A0'),
                          style: TextStyle(
                            color: primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _privacyRecognizer,
                        ),
                      ],
                    ),
                  ),
                );

            final header = Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 16, 0),
              child: Row(
                children: [
                  OpenTurathMark(size: 26, color: primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppCopy.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: primary,
                      ),
                    ),
                  ),
                  const LanguageSwitcher(),
                ],
              ),
            );

            return Column(
              children: [
                header,
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 32),
                          decoration: BoxDecoration(
                            color: OTColors.surface(dark),
                            borderRadius: BorderRadius.circular(OTRadius.dialog),
                            border: Border.all(color: OTColors.border(dark)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: OTColors.surfaceSubtle(dark),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: OTColors.border(dark)),
                                  ),
                                  child: OpenTurathMark(size: 32, color: primary),
                                ),
                              ),
                              const SizedBox(height: 20),
                              titleText(),
                              const SizedBox(height: 10),
                              subtitleText(),
                              const SizedBox(height: 28),
                              signInButton(),
                              if (_desktopError != null) errorBox(),
                              const SizedBox(height: 24),
                              legalText(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
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
