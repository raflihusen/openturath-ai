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
import '../core/design/ot_colors.dart';
import '../core/app_snackbar.dart';
import '../services/auth_service.dart';
import '../widgets/openturath_brand.dart';
import '../widgets/language_switcher.dart';

/// A shared, theme-adaptive sign-in surface for mobile and desktop.
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
      ..onTap = () => _openLegalUrl('https://openturath.id/terms.html');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl('https://openturath.id/privacy.html');
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
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _desktopError = null;
    });
    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('network') ||
              e.toString().contains('SocketException')
          ? AppCopy.networkError
          : (e is FirebaseAuthException
              ? switch (e.code) {
                  'keychain-error' => AppCopy.desktopKeychainError,
                  'popup-closed-by-user' || 'canceled' => '',
                  _ => e.message ?? AppCopy.googleSignInFailed,
                }
              : AppCopy.googleSignInFailed);
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
          child: LayoutBuilder(
            builder: (context, viewport) {
              final bodyMinHeight =
                  viewport.maxHeight > 80 ? viewport.maxHeight - 80 : 0.0;
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: LanguageSwitcher(),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(minHeight: bodyMinHeight),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: OpenTurathMark(
                                        size: 44, color: primary),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    AppCopy.appName,
                                    style: ScholarlyFonts.newsreader(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                      color: primary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppCopy.appTagline,
                                    style: ScholarlyFonts.outfit(
                                      fontSize: 15,
                                      height: 1.5,
                                      color: secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  FilledButton.icon(
                                    onPressed: _isLoading ? null : _signIn,
                                    icon: _isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: secondary),
                                          )
                                        : _GoogleGVector(),
                                    label: Text(
                                      _isLoading
                                          ? Loc.tr('desktopConnectingGoogle')
                                          : AppCopy.continueWithGoogle,
                                      textAlign: TextAlign.center,
                                      style: ScholarlyFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: OTColors.accent(dark),
                                      foregroundColor: OTColors.onAccent(dark),
                                      disabledBackgroundColor:
                                          OTColors.surfaceSubtle(dark),
                                      disabledForegroundColor: secondary,
                                      minimumSize: const Size(0, 52),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                  if (_desktopError != null) ...[
                                    const SizedBox(height: 16),
                                    Semantics(
                                      liveRegion: true,
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: OTColors.surfaceSubtle(dark),
                                          border: Border.all(
                                              color: OTColors.border(dark)),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.error_outline_rounded,
                                                size: 18, color: primary),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                _desktopError!,
                                                style: ScholarlyFonts.outfit(
                                                    fontSize: 13,
                                                    height: 1.5,
                                                    color: primary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 28),
                                  Text.rich(
                                    TextSpan(
                                      text: '${AppCopy.termsAgreementPrefix} ',
                                      style: ScholarlyFonts.outfit(
                                          fontSize: 12,
                                          height: 1.6,
                                          color: secondary),
                                      children: [
                                        TextSpan(
                                          text: AppCopy.termsOfService,
                                          style: TextStyle(
                                            color: primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: _termsRecognizer,
                                        ),
                                        const TextSpan(text: ' · '),
                                        TextSpan(
                                          text: AppCopy.privacyPolicy,
                                          style: TextStyle(
                                            color: primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: _privacyRecognizer,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
