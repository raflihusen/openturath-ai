import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// OpenTurath AI: Google NotebookLM Design System
class AppTheme {
  // ── 1. Light Mode Tokens (NotebookLM Live Verified) ───────────────────────
  static const Color canvasLight          = Color(0xFFF0F4F9); // Soft Gemini Lavender/Blue-grey Canvas
  static const Color surfaceCardLight     = Color(0xFFFFFFFF); // Pure White Floating Card
  static const Color surfaceHeaderLight   = Color(0xFFF0F4F9); // Header Bar Canvas
  static const Color borderLight          = Color(0xFFE1E3E1); // 1px Subtle Outline
  static const Color borderSubtleLight    = Color(0xFFE0E3E7); 
  static const Color textPrimaryLight     = Color(0xFF1F1F1F); // Main Title & Body
  static const Color textSecondaryLight   = Color(0xFF5E5E5E); // Metadata & Subtitles
  static const Color textTertiaryLight    = Color(0xFF747775); // Disclaimers & Placeholders
  static const Color accentLight          = Color(0xFF0B57D0); // Google Gemini Blue
  static const Color pillActionBgLight    = Color(0xFF1F1F1F); // Solid Black Action Pill
  static const Color pillActionTextLight  = Color(0xFFFFFFFF);
  static const Color pillSecondaryBgLight = Color(0xFFE1E3E1);
  static const Color citationBgLight      = Color(0xFFD3E3FD); // [1] Soft Blue Chip
  static const Color citationTextLight    = Color(0xFF041E49); // Deep Navy Citation Text
  static const Color queryBoxBgLight      = Color(0xFFF0F4F9); // Stadium Chat Input
  static const Color queryBoxBorderLight  = Color(0xFFC4C7C5);

  // ── 2. Dark Mode Tokens (Figma Master Palette Verified) ───────────────────
  static const Color canvasDark           = Color(0xFF0B1118); // Deep Midnight Slate Canvas
  static const Color surfaceCardDark      = Color(0xFF131C26); // Figma Elevated Surface Card
  static const Color surfaceHeaderDark    = Color(0xFF0B1118); // Header Bar Canvas
  static const Color borderDark           = Color(0xFF1E2D3D); // Subtle 1px Dark Outline
  static const Color borderSubtleDark     = Color(0xFF172330);
  static const Color textPrimaryDark      = Color(0xFFF8FAFC); // Main Title & Body
  static const Color textSecondaryDark    = Color(0xFF94A3B8); // Slate 400 Subtitles
  static const Color textTertiaryDark     = Color(0xFF64748B); // Slate 500
  static const Color accentDark           = Color(0xFF22D3EE); // Figma Glowing Electric Cyan
  static const Color pillActionBgDark     = Color(0xFF22D3EE); // Solid Cyan Action Pill
  static const Color pillActionTextDark   = Color(0xFF0B1118);
  static const Color pillSecondaryBgDark  = Color(0xFF182330);
  static const Color citationBgDark       = Color(0xFF0E3047); // Soft Deep Cyan Pill
  static const Color citationTextDark     = Color(0xFF67E8F9); // Electric Cyan Citation Text
  static const Color queryBoxBgDark       = Color(0xFF131C26); // Stadium Chat Input
  static const Color queryBoxBorderDark   = Color(0xFF1E2D3D);
  static const Color surfaceElevated      = Color(0xFF182330); // Elevated chip / pill container

  // ── 3. Backwards Compatibility Aliases ────────────────────────────────────
  static const Color lmLightCanvas        = canvasLight;
  static const Color lmLightSurface       = surfaceCardLight;
  static const Color lmLightHeader        = surfaceHeaderLight;
  static const Color lmLightInput         = queryBoxBgLight;
  static const Color lmLightBorder        = borderLight;
  static const Color lmLightDivider       = borderSubtleLight;
  static const Color lmLightTextPrimary   = textPrimaryLight;
  static const Color lmLightTextSecondary = textSecondaryLight;
  static const Color lmLightTextTertiary  = textTertiaryLight;
  static const Color lmLightAccent        = accentLight;
  static const Color lmLightCitationBg    = citationBgLight;
  static const Color lmLightCitationText  = citationTextLight;
  static const Color lmLightPillAction    = pillActionBgLight;

  static const Color lmDarkCanvas         = canvasDark;
  static const Color lmDarkSurface        = surfaceCardDark;
  static const Color lmDarkHeader         = surfaceHeaderDark;
  static const Color lmDarkInput          = queryBoxBgDark;
  static const Color lmDarkBorder         = borderDark;
  static const Color lmDarkDivider        = borderSubtleDark;
  static const Color lmDarkTextPrimary    = textPrimaryDark;
  static const Color lmDarkTextSecondary  = textSecondaryDark;
  static const Color lmDarkTextTertiary   = textTertiaryDark;
  static const Color lmDarkAccent         = accentDark;
  static const Color lmDarkCitationBg     = citationBgDark;
  static const Color lmDarkCitationText   = citationTextDark;
  static const Color lmDarkPillAction     = pillActionBgDark;

  static const Color brandRed             = Color(0xFFBA1A1A);
  static const Color brandGreen           = Color(0xFF137333);
  static const Color brandBlue            = accentLight;

  static const Color bgBase               = canvasDark;
  static const Color bgDeep               = Color(0xFF0E0E0F);
  static const Color bgCanvas             = canvasDark;
  static const Color surfaceL1            = surfaceCardDark;
  static const Color surfaceL2            = surfaceHeaderDark;
  static const Color surfaceL3            = borderDark;

  static const Color textPrimary          = textPrimaryDark;
  static const Color textSecondary        = textSecondaryDark;
  static const Color textTertiary         = textTertiaryDark;

  static const Color gold                 = accentLight;
  static const Color goldBright           = accentDark;
  static const Color goldMuted            = citationBgDark;

  static const Color success              = Color(0xFF34A353);
  static const Color error                = Color(0xFFE54335);
  static const Color warning              = Color(0xFFF6B704);
  static const Color info                 = Color(0xFF4280EF);

  static const Color lightBg              = canvasLight;
  static const Color lightSurface         = surfaceCardLight;
  static const Color lightSurfaceL2       = surfaceHeaderLight;
  static const Color lightBorder          = borderLight;
  static const Color lightTextPrimary     = textPrimaryLight;
  static const Color lightTextSecondary   = textSecondaryLight;

  // ── 4. Geometri & Radius M3 Expressive ─────────────────────────────────────
  static const double radiusXS   = 8.0;
  static const double radiusS    = 12.0;
  static const double radiusM    = 16.0;
  static const double radiusL    = 20.0;
  static const double radiusXL   = 28.0;
  static const double radiusFull = 100.0; // M3 Full Stadium Pill
  static const double radiusPill = 100.0; // Stadium Pills & Buttons
  static const double radiusQuery= 28.0;  // Chat Query Stadium Pill

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
    colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
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
        tertiary: brandGreen,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF0A2914),
        onTertiaryContainer: Color(0xFF7FECA0),
        error: error,
        onError: Colors.white,
        errorContainer: Color(0xFF3B0A07),
        onErrorContainer: Color(0xFFFFB3AC),
        surface: canvasDark,
        onSurface: textPrimaryDark,
        surfaceContainerLowest: Color(0xFF070C11),
        surfaceContainerLow: Color(0xFF0E1620),
        surfaceContainer: surfaceCardDark,
        surfaceContainerHigh: surfaceElevated,
        surfaceContainerHighest: pillSecondaryBgDark,
        outline: borderDark,
        outlineVariant: borderSubtleDark,
        inverseSurface: surfaceCardLight,
        inversePrimary: accentLight,
        scrim: Colors.black,
        shadow: Colors.black,
      ),
      scaffoldBackgroundColor: canvasDark,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: canvasDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimaryDark, size: 22),
        actionsIconTheme: const IconThemeData(color: textSecondaryDark, size: 22),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
          textStyle: GoogleFonts.outfit(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
          textStyle: GoogleFonts.outfit(
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: GoogleFonts.outfit(
          color: textPrimaryDark,
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: queryBoxBgDark,
        hintStyle: GoogleFonts.outfit(
          color: textTertiaryDark,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentDark, width: 1.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderDark, width: 1),
        ),
        textStyle: GoogleFonts.outfit(
          color: textPrimaryDark,
          fontSize: 12,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCardDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecondaryDark,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
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
        onPrimary: Colors.white,
        primaryContainer: citationBgLight,
        onPrimaryContainer: citationTextLight,
        secondary: pillActionBgLight,
        onSecondary: Colors.white,
        secondaryContainer: pillSecondaryBgLight,
        onSecondaryContainer: textPrimaryLight,
        tertiary: brandGreen,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFC7EBD1),
        onTertiaryContainer: Color(0xFF00210B),
        error: error,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: canvasLight,
        onSurface: textPrimaryLight,
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF7FAFD),
        surfaceContainer: surfaceCardLight,
        surfaceContainerHigh: Color(0xFFE8EEF5),
        surfaceContainerHighest: pillSecondaryBgLight,
        outline: borderLight,
        outlineVariant: borderSubtleLight,
        inverseSurface: surfaceCardDark,
        inversePrimary: accentDark,
        scrim: Colors.black,
        shadow: Colors.black,
      ),
      scaffoldBackgroundColor: canvasLight,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: canvasLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight, size: 22),
        actionsIconTheme: const IconThemeData(color: textSecondaryLight, size: 22),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
          textStyle: GoogleFonts.outfit(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
          textStyle: GoogleFonts.outfit(
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryLight,
        contentTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: queryBoxBgLight,
        hintStyle: GoogleFonts.outfit(
          color: textTertiaryLight,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentLight, width: 1.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textPrimaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCardLight,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecondaryLight,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: BorderSide(color: borderLight, width: 1),
        ),
      ),
    );
  }

  // ── Text Theme Generator ──────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? textPrimaryDark : textPrimaryLight;
    final secondary = isDark ? textSecondaryDark : textSecondaryLight;
    final tertiary = isDark ? textTertiaryDark : textTertiaryLight;

    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.8),
      displayMedium: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.5),
      headlineLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.4),
      headlineMedium: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.3),
      titleLarge: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.2),
      titleMedium: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleSmall: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w600, color: secondary),
      bodyLarge: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: primary, height: 1.55),
      bodyMedium: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w400, color: secondary, height: 1.45),
      bodySmall: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400, color: tertiary, height: 1.4),
      labelLarge: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w600, color: primary),
      labelSmall: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: tertiary, letterSpacing: 0.2),
    );
  }

  static LinearGradient agentGradient(String agentId) {
    return const LinearGradient(
      colors: [Color(0xFF0B57D0), Color(0xFF4285F4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
