import 'package:flutter/material.dart';
import 'scholarly_fonts.dart';
import 'design/ot_colors.dart';
import 'design/ot_radius.dart';
import 'design/ot_typography.dart';

// OpenTurath AI: Monochrome Editorial Theme (Quiet Scholar Adaptive)
class AppTheme {
  // ── 1. Light Mode Tokens (Warm Archival Paper) ───────────────────────────
  static const Color canvasLight = OTColors.canvasLight;
  static const Color groupedCanvasLight = OTColors.canvasLight;
  static const Color surfaceCardLight = OTColors.surfaceLight;
  static const Color surfaceHeaderLight = OTColors.surfaceLight;
  static const Color borderLight = OTColors.borderLight;
  static const Color borderSubtleLight = OTColors.borderSubtleLight;
  static const Color textPrimaryLight = OTColors.textPrimaryLight;
  static const Color textSecondaryLight = OTColors.textSecondaryLight;
  static const Color textTertiaryLight = OTColors.textTertiaryLight;
  static const Color accentLight = OTColors.accentLight;
  static const Color pillActionBgLight = OTColors.textPrimaryLight;
  static const Color pillActionTextLight = OTColors.surfaceLight;
  static const Color pillSecondaryBgLight = OTColors.surfaceSubtleLight;
  static const Color citationBgLight = OTColors.surfaceSubtleLight;
  static const Color citationTextLight = OTColors.textPrimaryLight;
  static const Color queryBoxBgLight = OTColors.surfaceLight;
  static const Color queryBoxBorderLight = OTColors.borderLight;

  // ── 1b. Token Navigasi & Status ───────────────────────────────────────────
  // Status kritis memakai merah bata redup dari OTColors, bukan merah neon iOS.
  static const Color navBarDark = OTColors.navigationDark;
  static const Color navBarLight = OTColors.navigationLight;
  static const Color navBarBorderDark = OTColors.borderDark;
  static const Color navBarBorderLight = OTColors.borderLight;
  static const double dividerIndent = 54.0;

  // ── 2. Dark Mode Tokens (Quiet Obsidian Scholar) ─────────────────────────
  static const Color canvasDark = OTColors.canvasDark;
  static const Color groupedCanvasDark = OTColors.canvasDark;
  static const Color surfaceCardDark = OTColors.surfaceDark;
  static const Color surfaceHeaderDark = OTColors.surfaceDark;
  static const Color borderDark = OTColors.borderDark;
  static const Color borderSubtleDark = OTColors.borderSubtleDark;
  static const Color textPrimaryDark = OTColors.textPrimaryDark;
  static const Color textSecondaryDark = OTColors.textSecondaryDark;
  static const Color textTertiaryDark = OTColors.textTertiaryDark;
  static const Color accentDark = OTColors.accentDark;
  static const Color pillActionBgDark = OTColors.textPrimaryDark;
  static const Color pillActionTextDark = OTColors.surfaceDark;
  static const Color pillSecondaryBgDark = OTColors.surfaceSubtleDark;
  static const Color citationBgDark = OTColors.surfaceSubtleDark;
  static const Color citationTextDark = OTColors.textPrimaryDark;
  static const Color queryBoxBgDark = OTColors.surfaceDark;
  static const Color queryBoxBorderDark = OTColors.borderDark;
  static const Color surfaceElevated = OTColors.surfaceSubtleDark;
  static const Color scholarlyIndigo = OTColors.textPrimaryDark;
  static const Color readingCanvasParchmentLight = OTColors.canvasLight;
  static const Color readingCanvasParchmentDark = OTColors.surfaceDark;

  // ── 3. Backwards Compatibility Aliases ────────────────────────────────────
  static const Color lmLightCanvas = canvasLight;
  static const Color lmLightSurface = surfaceCardLight;
  static const Color lmLightHeader = surfaceHeaderLight;
  static const Color lmLightInput = queryBoxBgLight;
  static const Color lmLightBorder = borderLight;
  static const Color lmLightDivider = borderSubtleLight;
  static const Color lmLightTextPrimary = textPrimaryLight;
  static const Color lmLightTextSecondary = textSecondaryLight;
  static const Color lmLightTextTertiary = textTertiaryLight;
  static const Color lmLightAccent = accentLight;
  static const Color lmLightCitationBg = citationBgLight;
  static const Color lmLightCitationText = citationTextLight;
  static const Color lmLightPillAction = pillActionBgLight;

  static const Color lmDarkCanvas = canvasDark;
  static const Color lmDarkSurface = surfaceCardDark;
  static const Color lmDarkHeader = surfaceHeaderDark;
  static const Color lmDarkInput = queryBoxBgDark;
  static const Color lmDarkBorder = borderDark;
  static const Color lmDarkDivider = borderSubtleDark;
  static const Color lmDarkTextPrimary = textPrimaryDark;
  static const Color lmDarkTextSecondary = textSecondaryDark;
  static const Color lmDarkTextTertiary = textTertiaryDark;
  static const Color lmDarkAccent = accentDark;
  static const Color lmDarkCitationBg = citationBgDark;
  static const Color lmDarkCitationText = citationTextDark;
  static const Color lmDarkPillAction = pillActionBgDark;

  static const Color brandRed = OTColors.destructiveLight;
  static const Color brandGreen = OTColors.textSecondaryLight;
  static const Color brandBlue = accentLight;

  static const Color bgBase = canvasDark;
  static const Color bgDeep = OTColors.canvasDark;
  static const Color bgCanvas = canvasDark;
  static const Color surfaceL1 = surfaceCardDark;
  static const Color surfaceL2 = surfaceHeaderDark;
  static const Color surfaceL3 = borderDark;

  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textTertiary = textTertiaryDark;

  static const Color gold = accentLight;
  static const Color goldBright = accentDark;
  static const Color goldMuted = citationBgDark;

  static const Color success = OTColors.textPrimaryLight;
  static const Color error = OTColors.destructiveLight;
  static const Color warning = OTColors.textSecondaryLight;
  static const Color info = OTColors.textPrimaryLight;

  static const Color lightBg = canvasLight;
  static const Color lightSurface = surfaceCardLight;
  static const Color lightSurfaceL2 = surfaceHeaderLight;
  static const Color lightBorder = borderLight;
  static const Color lightTextPrimary = textPrimaryLight;
  static const Color lightTextSecondary = textSecondaryLight;

  // ── 4. Geometry compatibility aliases ────────────────────────────────────
  static const double radiusXS = OTRadius.small;
  static const double radiusCard = OTRadius.card;
  static const double radiusM = OTRadius.card;
  static const double radiusS = OTRadius.small;
  static const double radiusL = OTRadius.card;
  static const double radiusXL = OTRadius.sheet;
  static const double radiusFull = OTRadius.chip;
  static const double radiusPill = OTRadius.chip;
  static const double radiusQuery = OTRadius.input;

  // ── 5. Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [canvasDark, canvasDark],
  );

  static const LinearGradient lightBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [canvasLight, canvasLight],
  );

  static const LinearGradient geminiSparkleGradient = LinearGradient(
    colors: [accentDark, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: accentDark,
        onPrimary: canvasDark,
        primaryContainer: citationBgDark,
        onPrimaryContainer: citationTextDark,
        secondary: pillActionBgDark,
        onSecondary: canvasDark,
        secondaryContainer: pillSecondaryBgDark,
        onSecondaryContainer: textPrimaryDark,
        tertiary: textSecondaryDark,
        onTertiary: canvasDark,
        tertiaryContainer: pillSecondaryBgDark,
        onTertiaryContainer: textPrimaryDark,
        error: error,
        onError: OTColors.onInverseSurface,
        errorContainer: pillSecondaryBgDark,
        onErrorContainer: OTColors.destructiveDark,
        surface: canvasDark,
        onSurface: textPrimaryDark,
        surfaceContainerLowest: canvasDark,
        surfaceContainerLow: canvasDark,
        surfaceContainer: surfaceCardDark,
        surfaceContainerHigh: surfaceElevated,
        surfaceContainerHighest: pillSecondaryBgDark,
        outline: borderDark,
        outlineVariant: borderSubtleDark,
        inverseSurface: surfaceCardLight,
        inversePrimary: accentLight,
        scrim: OTColors.scrim,
        shadow: OTColors.scrim,
      ),
      scaffoldBackgroundColor: canvasDark,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: canvasDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: ScholarlyFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimaryDark, size: 22),
        actionsIconTheme:
            const IconThemeData(color: textSecondaryDark, size: 22),
      ),
      cardTheme: CardThemeData(
        color: surfaceCardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pillActionBgDark,
          foregroundColor: pillActionTextDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
          textStyle: ScholarlyFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryDark,
          side: const BorderSide(color: borderDark, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
          textStyle: ScholarlyFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceCardDark,
        surfaceTintColor: OTColors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: ScholarlyFonts.outfit(
          color: textPrimaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: OTRadius.inputBorder,
          side: const BorderSide(color: borderDark, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: queryBoxBgDark,
        hintStyle: ScholarlyFonts.outfit(
          color: textTertiaryDark,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: OTRadius.inputBorder,
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: OTRadius.inputBorder,
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: accentDark, width: 1.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceElevated,
          borderRadius: BorderRadius.circular(radiusXS),
          border: Border.all(color: borderDark, width: 1),
        ),
        textStyle: ScholarlyFonts.outfit(
          color: textPrimaryDark,
          fontSize: 12,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCardDark,
        surfaceTintColor: OTColors.transparent,
        titleTextStyle: ScholarlyFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        contentTextStyle: ScholarlyFonts.outfit(
          fontSize: 14,
          color: textSecondaryDark,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusCard)),
          side: BorderSide(color: borderDark, width: 1),
        ),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: accentLight,
        onPrimary: OTColors.onAccentLight,
        primaryContainer: citationBgLight,
        onPrimaryContainer: citationTextLight,
        secondary: pillActionBgLight,
        onSecondary: OTColors.onAccentLight,
        secondaryContainer: pillSecondaryBgLight,
        onSecondaryContainer: textPrimaryLight,
        tertiary: textSecondaryLight,
        onTertiary: surfaceCardLight,
        tertiaryContainer: pillSecondaryBgLight,
        onTertiaryContainer: textPrimaryLight,
        error: error,
        onError: OTColors.onInverseSurface,
        errorContainer: pillSecondaryBgLight,
        onErrorContainer: OTColors.destructiveLight,
        surface: canvasLight,
        onSurface: textPrimaryLight,
        surfaceContainerLowest: OTColors.surfaceLight,
        surfaceContainerLow: canvasLight,
        surfaceContainer: surfaceCardLight,
        surfaceContainerHigh: pillSecondaryBgLight,
        surfaceContainerHighest: pillSecondaryBgLight,
        outline: borderLight,
        outlineVariant: borderSubtleLight,
        inverseSurface: surfaceCardDark,
        inversePrimary: accentDark,
        scrim: OTColors.scrim,
        shadow: OTColors.scrim,
      ),
      scaffoldBackgroundColor: canvasLight,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: canvasLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: ScholarlyFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight, size: 22),
        actionsIconTheme:
            const IconThemeData(color: textSecondaryLight, size: 22),
      ),
      cardTheme: CardThemeData(
        color: surfaceCardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pillActionBgLight,
          foregroundColor: pillActionTextLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
          textStyle: ScholarlyFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryLight,
          side: const BorderSide(color: borderLight, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
          textStyle: ScholarlyFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceCardLight,
        surfaceTintColor: OTColors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryLight,
        contentTextStyle: ScholarlyFonts.outfit(
          color: OTColors.onInverseSurface,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: OTRadius.inputBorder,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: queryBoxBgLight,
        hintStyle: ScholarlyFonts.outfit(
          color: textTertiaryLight,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: OTRadius.inputBorder,
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: OTRadius.inputBorder,
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: accentLight, width: 1.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textPrimaryLight,
          borderRadius: BorderRadius.circular(radiusXS),
        ),
        textStyle: ScholarlyFonts.outfit(
          color: OTColors.onInverseSurface,
          fontSize: 12,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCardLight,
        surfaceTintColor: OTColors.transparent,
        titleTextStyle: ScholarlyFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        contentTextStyle: ScholarlyFonts.outfit(
          fontSize: 14,
          color: textSecondaryLight,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusCard)),
          side: BorderSide(color: borderLight, width: 1),
        ),
      ),
    );
  }

  static TextStyle _fontNewsreader({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    if (OTTypography.useSystemFontFallback) {
      return TextStyle(
        fontFamily: 'Newsreader',
        fontFamilyFallback: const ['Scheherazade New'],
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
    return ScholarlyFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle _fontOutfit({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    if (OTTypography.useSystemFontFallback) {
      return TextStyle(
        fontFamily: 'Outfit',
        fontFamilyFallback: const ['Scheherazade New'],
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
    return ScholarlyFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ── Text Theme Generator ──────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? textPrimaryDark : textPrimaryLight;
    final secondary = isDark ? textSecondaryDark : textSecondaryLight;
    final tertiary = isDark ? textTertiaryDark : textTertiaryLight;

    return TextTheme(
      displayLarge: _fontNewsreader(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.6),
      displayMedium: _fontNewsreader(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.4),
      headlineLarge: _fontNewsreader(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.3),
      headlineMedium: _fontNewsreader(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.2),
      titleLarge: _fontNewsreader(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.1),
      titleMedium: _fontOutfit(
          fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleSmall: _fontOutfit(
          fontSize: 13, fontWeight: FontWeight.w600, color: secondary),
      bodyLarge: _fontOutfit(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: primary,
          height: 1.55),
      bodyMedium: _fontOutfit(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: secondary,
          height: 1.45),
      bodySmall: _fontOutfit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: tertiary,
          height: 1.4),
      labelLarge: _fontOutfit(
          fontSize: 13, fontWeight: FontWeight.w600, color: primary),
      labelSmall: _fontOutfit(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: tertiary,
          letterSpacing: 0.2),
    );
  }

  static LinearGradient agentGradient(String agentId) {
    return const LinearGradient(
      colors: [accentDark, accentDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
