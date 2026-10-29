import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/routes.dart';
import '../core/scholarly_fonts.dart';
import '../services/language_gate.dart';
import '../services/onboarding_gate.dart';

/// Layar pertama pada pemasangan baru: pilih bahasa sebelum apa pun dibaca.
/// Urutannya: bahasa, pengenalan AI, lalu masuk akun. Judul ditulis dalam tiga
/// bahasa sekaligus karena pengguna belum memilih satu pun.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key, this.next = AppRoutes.login});

  /// Tujuan setelah pengenalan (atau langsung, bila pengenalan sudah dilihat).
  final String next;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _picked = LanguageGate.suggest();
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    // Layar langsung memakai usulan dari bahasa perangkat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Loc.language != _picked) {
        AppConfig.localeNotifier.value = _picked;
      }
    });
  }

  Future<void> _pick(String code) async {
    if (_leaving) return;
    setState(() => _picked = code);
    try {
      await AppConfig.setLocale(code);
    } catch (_) {
      // Bahasa tetap aktif di memori walau penyimpanan gagal.
    }
  }

  Future<void> _continue() async {
    if (_leaving) return;
    _leaving = true;
    try {
      await AppConfig.setLocale(_picked);
    } catch (_) {}
    await LanguageGate.markChosen();
    final introSeen = await OnboardingGate.seen();
    if (!mounted) return;
    if (introSeen) {
      Navigator.of(context).pushReplacementNamed(widget.next);
    } else {
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.onboarding, arguments: widget.next);
    }
  }

  static String _continueLabel(String code) => switch (code) {
        'en' => 'Continue',
        'ar' => 'متابعة',
        _ => 'Lanjutkan',
      };

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = OTColors.textPrimary(dark), sub = OTColors.textSecondary(dark);
    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(OTSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('OPENTURATH AI',
                      textAlign: TextAlign.center,
                      style: OTTypography.captionMedium(color: sub)
                          .copyWith(letterSpacing: 2)),
                  const SizedBox(height: OTSpacing.xl),
                  Text('Pilih bahasa',
                      textAlign: TextAlign.center,
                      style: OTTypography.screenTitle(color: fg)),
                  const SizedBox(height: OTSpacing.xs),
                  Text('Choose your language',
                      textAlign: TextAlign.center,
                      style: OTTypography.body(color: sub)),
                  const SizedBox(height: OTSpacing.xs),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text('اختر اللغة',
                        textAlign: TextAlign.center,
                        style: ScholarlyFonts.scheherazadeNew(
                            height: 1.6, color: sub, fontSize: OTFontSize.s18)),
                  ),
                  const SizedBox(height: OTSpacing.xxl),
                  for (final code in Loc.supportedCodes) ...[
                    _Tile(
                      code: code,
                      name: Loc.languageNames[code]!,
                      selected: code == _picked,
                      dark: dark,
                      onTap: () => _pick(code),
                    ),
                    const SizedBox(height: OTSpacing.sm),
                  ],
                  const SizedBox(height: OTSpacing.base),
                  FilledButton(
                    key: const ValueKey('language-continue'),
                    onPressed: _continue,
                    child: Text(_continueLabel(_picked),
                        style: OTTypography.button()),
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

class _Tile extends StatelessWidget {
  const _Tile({
    required this.code,
    required this.name,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  final String code, name;
  final bool selected, dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = OTColors.textPrimary(dark);
    final ar = code == 'ar';
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: Material(
        color: selected ? OTColors.surfaceSubtle(dark) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: OTRadius.cardBorder,
          side: BorderSide(
              color: selected ? fg : OTColors.border(dark),
              width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          key: ValueKey('language-$code'),
          borderRadius: OTRadius.cardBorder,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.lg, vertical: OTSpacing.base),
            child: Row(children: [
              Expanded(
                child: Text(
                  name,
                  textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
                  style: ar
                      ? ScholarlyFonts.scheherazadeNew(
                          height: 1.6, color: fg, fontSize: OTFontSize.s20)
                      : OTTypography.bodyMedium(color: fg),
                ),
              ),
              if (selected) Icon(Icons.check_rounded, color: fg, size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}
