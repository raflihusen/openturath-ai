import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/core/design/ot_colors.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';
import 'package:openturath_ai/core/design/ot_motion.dart';
import 'package:openturath_ai/core/design/ot_spacing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  OTTypography.useSystemFontFallback = true;

  group('Quiet Scholar Design System — Tokens Suite', () {
    test('OTColors provides calm, scholarly palettes without gold leaks', () {
      // 1. Light palette checks
      expect(OTColors.canvasLight, const Color(0xFFFAFAF9));
      expect(OTColors.surfaceLight, const Color(0xFFFFFFFF));
      expect(OTColors.textPrimaryLight, const Color(0xFF18181B));
      expect(OTColors.textSecondaryLight, const Color(0xFF52525B));

      // 2. Dark palette checks
      expect(OTColors.canvasDark, const Color(0xFF0E0E10));
      expect(OTColors.surfaceDark, const Color(0xFF18181B));
      expect(OTColors.textPrimaryDark, const Color(0xFFFAFAFA));
      expect(OTColors.textSecondaryDark, const Color(0xFFA1A1AA));

      // 3. Scholarly sapphire accents
      expect(OTColors.accentLight, const Color(0xFF2563EB));
      expect(OTColors.accentDark, const Color(0xFF60A5FA));

      // 4. Adaptive context helpers
      expect(OTColors.canvas(false), OTColors.canvasLight);
      expect(OTColors.canvas(true), OTColors.canvasDark);
      expect(OTColors.surface(false), OTColors.surfaceLight);
      expect(OTColors.surface(true), OTColors.surfaceDark);
      expect(OTColors.textPrimary(false), OTColors.textPrimaryLight);
      expect(OTColors.textPrimary(true), OTColors.textPrimaryDark);
      expect(OTColors.textSecondary(false), OTColors.textSecondaryLight);
      expect(OTColors.textSecondary(true), OTColors.textSecondaryDark);
      expect(OTColors.accent(false), OTColors.accentLight);
      expect(OTColors.accent(true), OTColors.accentDark);
    });

    test('OTTypography strictly separates Brand, Interface, and Arabic layers', () {
      // 1. Brand / Editorial layer (Newsreader)
      final brand = OTTypography.brandLogo();
      expect(brand.fontSize, 22);
      expect(brand.fontWeight, FontWeight.w600);

      final hero = OTTypography.editorialHero();
      expect(hero.fontSize, 26);
      expect(hero.fontWeight, FontWeight.w600);
      expect(hero.height, 1.25);

      final corpus = OTTypography.corpusTitle();
      expect(corpus.fontSize, 18);
      expect(corpus.fontWeight, FontWeight.w600);

      // 2. Interface layer (Outfit)
      final screen = OTTypography.screenTitle();
      expect(screen.fontSize, 20);
      expect(screen.fontWeight, FontWeight.w600);

      final card = OTTypography.cardTitle();
      expect(card.fontSize, 15);
      expect(card.fontWeight, FontWeight.w600);

      final body = OTTypography.body();
      expect(body.fontSize, 14);
      expect(body.fontWeight, FontWeight.w400);

      final caption = OTTypography.caption();
      expect(caption.fontSize, 12);

      final button = OTTypography.button();
      expect(button.fontSize, 14);
      expect(button.fontWeight, FontWeight.w600);

      // 3. Arabic Scholarly layer (Amiri)
      final arDisplay = OTTypography.arabicDisplay();
      expect(arDisplay.fontSize, 24);
      expect(arDisplay.fontWeight, FontWeight.w700);
      expect(arDisplay.height, 1.6);

      final arReading = OTTypography.arabicReading();
      expect(arReading.fontSize, 19);
      expect(arReading.fontWeight, FontWeight.w500);
      expect(arReading.height, 1.75);

      final arQuote = OTTypography.arabicQuote();
      expect(arQuote.fontSize, 16);
      expect(arQuote.height, 1.8);
    });

    test('OTRadius enforces disciplined curvature without bubble-boxing', () {
      expect(OTRadius.input, 14.0);
      expect(OTRadius.card, 16.0);
      expect(OTRadius.sheet, 24.0);
      expect(OTRadius.dialog, 20.0);
      expect(OTRadius.chip, 999.0);
      expect(OTRadius.button, 999.0);

      expect(OTRadius.inputBorder, BorderRadius.circular(14.0));
      expect(OTRadius.cardBorder, BorderRadius.circular(16.0));
      expect(OTRadius.dialogBorder, BorderRadius.circular(20.0));
      expect(OTRadius.chipBorder, BorderRadius.circular(999.0));
      expect(OTRadius.buttonBorder, BorderRadius.circular(999.0));
    });

    test('OTMotion provides quiet, restrained animations and easing', () {
      expect(OTMotion.fast, const Duration(milliseconds: 180));
      expect(OTMotion.normal, const Duration(milliseconds: 220));
      expect(OTMotion.sheet, const Duration(milliseconds: 280));
      expect(OTMotion.transition, const Duration(milliseconds: 320));

      expect(OTMotion.curve, Curves.easeOutCubic);
      expect(OTMotion.sheetCurve, Curves.easeOutQuart);
    });

    test('OTSpacing maintains strict base-4 rhythm', () {
      expect(OTSpacing.xs, 4.0);
      expect(OTSpacing.sm, 8.0);
      expect(OTSpacing.md, 12.0);
      expect(OTSpacing.base, 16.0);
      expect(OTSpacing.lg, 20.0);
      expect(OTSpacing.xl, 24.0);
      expect(OTSpacing.xxl, 32.0);
      expect(OTSpacing.huge, 40.0);
      expect(OTSpacing.massive, 48.0);
      expect(OTSpacing.jumbo, 64.0);

      // Verify all spacing values are strictly divisible by 4
      for (final val in [
        OTSpacing.xs,
        OTSpacing.sm,
        OTSpacing.md,
        OTSpacing.base,
        OTSpacing.lg,
        OTSpacing.xl,
        OTSpacing.xxl,
        OTSpacing.huge,
        OTSpacing.massive,
        OTSpacing.jumbo,
      ]) {
        expect(val % 4.0, 0.0);
      }
    });
  });
}
