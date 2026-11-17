import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' show NumberFormat;
import '../core/scholarly_fonts.dart';

import '../core/localization.dart';
import '../core/app_copy.dart';
import '../core/routes.dart';
import '../core/google_connection_flow.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_expressive.dart';
import '../widgets/ot_motion_widgets.dart';
import '../widgets/openturath_brand.dart';
import '../widgets/language_switcher.dart';
import '../widgets/arch_echo_canvas.dart';
import '../services/open_turath_catalog_repository.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';

import '../widgets/legal_document_sheet.dart';
import '../widgets/app_loader.dart';
import '../core/design/ot_motion.dart';

/// A shared, theme-adaptive sign-in surface for mobile and desktop.
/// Desain otentik: kartu gelap penuh dengan kanvas gerbang lengkung Islam (ArchEchoCanvas)
/// di ponsel (Foto 2) dan tata letak 2-kolom scholarly editorial di desktop.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      await Navigator.pushNamed(
        context,
        AppRoutes.googleSessionAuth,
        arguments: GoogleConnectionPurpose.appEntry,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    // Paduan latar putih editorial dengan kartu obsidian gerbang lengkung Islam (Foto 2)
    const outerCanvas = OTColors.canvasLight;
    const headerPrimary = OTColors.textPrimaryLight;
    const headerSecondary = OTColors.textSecondaryLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: outerCanvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: outerCanvas,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, viewport) {
            final isPhone = viewport.maxWidth < 900;

            const onCard = OTExpressive.white;
            const onCardMuted = OTExpressive.whiteMuted;

            Widget titleText(Color color) => OTReveal(
                  delayMs: OTMotion.loginHeadlineMs,
                  child: Text(
                    Loc.tr('loginTitle'),
                    textAlign: TextAlign.center,
                    style: ScholarlyFonts.outfit(
                      fontSize: viewport.maxHeight < 700 ? OTFontSize.s26 : OTFontSize.s36,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      height: 1.15,
                      color: color,
                    ),
                  ),
                );

            Widget signInButton(ButtonStyle? style, Color loader) => OTReveal(
                  delayMs: OTMotion.loginButtonMs,
                  child: FilledButton.icon(
                    style: style ??
                        FilledButton.styleFrom(
                          backgroundColor: OTColors.surfaceLight,
                          foregroundColor: OTColors.textPrimaryLight,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                    onPressed: _isLoading ? null : _signIn,
                    icon: _isLoading
                        ? AppLoader(dotSize: 5, spacing: 2, color: loader)
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
                );

            Widget errorBox() => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: OTColors.surfaceLight,
                        border: Border.all(color: OTColors.borderLight),
                        borderRadius: BorderRadius.circular(OTRadius.xs),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 18, color: headerPrimary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _desktopError!,
                              style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s14,
                                  height: 1.5,
                                  color: headerPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

            Widget legalText(Color muted, Color link) => OTReveal(
                  delayMs: OTMotion.loginLegalMs,
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      text: '${AppCopy.termsAgreementPrefix} ',
                      style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s12, height: 1.6, color: muted),
                      children: [
                        TextSpan(
                          text: AppCopy.termsOfService.replaceAll(' ', '\u00A0'),
                          style: TextStyle(
                            color: link,
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
                            color: link,
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
                  const OpenTurathMark(size: 26, color: headerPrimary),
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
                        color: headerPrimary,
                      ),
                    ),
                  ),
                  const LanguageSwitcher(),
                ],
              ),
            );

            // ── Tampilan Ponsel (Foto 2 Otentik Full-Bleed) ───
            if (isPhone) {
              final content = Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleText(onCard),
                    const SizedBox(height: 24),
                    signInButton(
                      FilledButton.styleFrom(
                        backgroundColor: OTColors.surfaceLight,
                        foregroundColor: OTColors.textPrimaryLight,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      OTColors.textPrimaryLight,
                    ),
                    if (_desktopError != null) errorBox(),
                    const SizedBox(height: 20),
                    legalText(onCardMuted, onCard),
                  ],
                ),
              );

              return Column(
                children: [
                  header,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: OTColors.canvasDark,
                          borderRadius: BorderRadius.circular(OTRadius.sheet),
                          border: Border.all(
                              color: OTColors.surfaceLight.withValues(alpha: 0.12)),
                        ),
                        child: LayoutBuilder(builder: (context, card) {
                          if (card.maxHeight < 520) {
                            return Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 24),
                                child: content,
                              ),
                            );
                          }
                          return Column(
                            children: [
                              const Expanded(
                                child: ExcludeSemantics(
                                  child: ArchEchoCanvas(compact: true),
                                ),
                              ),
                              content,
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              );
            }

            // ── Tampilan Desktop (Paduan Putih Editorial di Kiri, Hitam di Kanan) ──
            final formColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: OTReveal(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              titleText(headerPrimary),
                              const SizedBox(height: 24),
                              signInButton(
                                FilledButton.styleFrom(
                                  backgroundColor: OTColors.accentLight,
                                  foregroundColor: OTColors.onAccentLight,
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                OTColors.onAccentLight,
                              ),
                              if (_desktopError != null) errorBox(),
                              const SizedBox(height: 20),
                              legalText(headerSecondary, headerPrimary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );

            return Row(
              children: [
                Expanded(flex: 5, child: formColumn),
                const Expanded(flex: 6, child: _LoginAside()),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _LoginAside extends StatelessWidget {
  const _LoginAside();

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    const ink = OTColors.onInverseSurface;
    final muted = ink.withValues(alpha: 0.66);
    final line = ink.withValues(alpha: 0.14);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: OTColors.inverseSurface(dark),
          borderRadius: BorderRadius.circular(OTRadius.dialog),
          border: Border.all(
              color:
                  dark ? OTColors.border(dark) : OTColors.inverseSurface(dark)),
        ),
        child: Stack(
          children: [
            // Lengkung logo bersarang dengan cahaya yang bernapas pelan.
            const Positioned.fill(
              child: ExcludeSemantics(child: ArchEchoCanvas()),
            ),
            // Gradasi bawah agar teks tetap terbaca di atas kanvas.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 0.72],
                      colors: [
                        OTColors.inverseSurface(dark).withValues(alpha: 0),
                        OTColors.inverseSurface(dark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  OTReveal(
                    child: Text(
                      AppCopy.appTagline,
                      style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s36,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -1.1,
                        height: 1.08,
                        color: ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OTReveal(
                    index: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Text(
                        Loc.tr('loginAsideBody'),
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s16,
                            height: 1.55,
                            color: muted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: line),
                  const SizedBox(height: 16),
                  // Angka pustaka dari metadata; tanpa ikon.
                  OTReveal(
                      index: 2, child: _LibraryTotals(ink: ink, muted: muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryTotals extends StatelessWidget {
  const _LibraryTotals({required this.ink, required this.muted});

  final Color ink;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, AiLibraryMetadata>>(
      future: OpenTurathCatalogRepository.instance.loadAllMetadata(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <String, AiLibraryMetadata>{};
        if (snapshot.hasError) return Text(Loc.tr('catalogFailure'));
        if (all.isEmpty) return const SizedBox(height: 44);
        final number = NumberFormat.decimalPattern(Loc.language);
        final entries =
            all.values.fold<int>(0, (sum, item) => sum + item.totalKitab);
        final pages =
            all.values.fold<int>(0, (sum, item) => sum + item.totalHalaman);
        Widget stat(String value, String label) => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: ink,
                    ).copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(height: 2),
                  Text(label,
                      style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s12, color: muted)),
                ],
              ),
            );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            stat(number.format(all.length), Loc.tr('loginStatLibraries')),
            stat(Loc.atLeast(number.format(entries ~/ 100 * 100)),
                Loc.tr('loginStatEntries')),
            stat(
                Loc.atLeast(
                    number.format(pages ~/ 100000 / 10), Loc.tr('unitMillion')),
                Loc.tr('loginStatPages')),
          ],
        );
      },
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
