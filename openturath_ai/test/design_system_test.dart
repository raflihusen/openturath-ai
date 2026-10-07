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

  group('OpenTurath Material 3 design tokens', () {
    test('monochrome text and actions remain readable in both themes', () {
      double contrast(Color a, Color b) {
        final x = a.computeLuminance();
        final y = b.computeLuminance();
        return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
      }
      for (final dark in [false, true]) {
        final neutral = [OTColors.canvas(dark), OTColors.surface(dark),
          OTColors.surfaceSubtle(dark), OTColors.textPrimary(dark),
          OTColors.textSecondary(dark), OTColors.accent(dark),
          OTColors.primaryContainer(dark), OTColors.marja(dark)];
        for (final color in neutral) {
          expect(color.r, color.g);
          expect(color.g, color.b);
        }
        for (final background in [OTColors.canvas(dark), OTColors.surface(dark)]) {
          expect(contrast(OTColors.textPrimary(dark), background), greaterThanOrEqualTo(4.5));
          expect(contrast(OTColors.textSecondary(dark), background), greaterThanOrEqualTo(4.5));
          expect(contrast(OTColors.textTertiary(dark), background), greaterThanOrEqualTo(4.5));
          // Merah galat adalah satu-satunya warna di luar tinta dan kertas.
          expect(contrast(OTColors.destructive(dark), background), greaterThanOrEqualTo(4.5));
        }
        expect(contrast(OTColors.accent(dark), OTColors.onAccent(dark)), greaterThanOrEqualTo(4.5));
        expect(contrast(OTColors.primaryContainer(dark), OTColors.onPrimaryContainer(dark)), greaterThanOrEqualTo(4.5));
      }
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
      expect(card.fontSize, 16);
      expect(card.fontWeight, FontWeight.w600);

      final body = OTTypography.body();
      expect(body.fontSize, 14);
      expect(body.fontWeight, FontWeight.w400);

      final caption = OTTypography.caption();
      expect(caption.fontSize, 12);

      final button = OTTypography.button();
      expect(button.fontSize, 14);
      expect(button.fontWeight, FontWeight.w600);

      // 3. Arabic Scholarly layer (Tajawal)
      final arDisplay = OTTypography.arabicDisplay();
      expect(arDisplay.fontSize, 26);
      expect(arDisplay.fontWeight, FontWeight.w700);
      expect(arDisplay.height, 1.85);

      final arReading = OTTypography.arabicReading();
      expect(arReading.fontSize, 18);
      expect(arReading.fontWeight, FontWeight.w400);
      expect(arReading.height, 1.85);

      final arQuote = OTTypography.arabicQuote();
      expect(arQuote.fontSize, 16);
      expect(arQuote.height, 1.85);
    });

    test('OTRadius enforces disciplined curvature without bubble-boxing', () {
      expect(OTRadius.input, 28.0);
      expect(OTRadius.card, 24.0);
      expect(OTRadius.sheet, 32.0);
      expect(OTRadius.dialog, 28.0);
      expect(OTRadius.chip, 999.0);
      expect(OTRadius.button, 999.0);

      expect(OTRadius.inputBorder, BorderRadius.circular(28.0));
      expect(OTRadius.cardBorder, BorderRadius.circular(24.0));
      expect(OTRadius.dialogBorder, BorderRadius.circular(28.0));
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
