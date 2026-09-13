import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// OpenTurath AI: Google NotebookLM Design System
class AppTheme {
  // ── 1. Light Mode Tokens (Claude Minimalist Aesthetic) ───────────────────
  static const Color canvasLight          = Color(0xFFFFFFFF); // Putih Pekat Murni
  static const Color groupedCanvasLight   = Color(0xFFF6F6F8); // Apple System Grouped Gray Canvas
  static const Color surfaceCardLight     = Color(0xFFFFFFFF); // Pure White Floating Card
  static const Color surfaceHeaderLight   = Color(0xFFFFFFFF); // Header Bar Canvas
  static const Color borderLight          = Color(0xFFE5E7EB); // 1px Subtle Outline (Abu-abu Tipis)
  static const Color borderSubtleLight    = Color(0xFFF1F5F9); 
  static const Color textPrimaryLight     = Color(0xFF18181B); // Main Title & Body
  static const Color textSecondaryLight   = Color(0xFF71717A); // Metadata & Subtitles
  static const Color textTertiaryLight    = Color(0xFF6B7280); // WCAG AA Compliant (4.8:1) Placeholders & Subtitles
  static const Color accentLight          = Color(0xFF18181B); // Refined Monochrome Black
  static const Color pillActionBgLight    = Color(0xFF18181B); // Solid Black Action Pill
  static const Color pillActionTextLight  = Color(0xFFFFFFFF);
  static const Color pillSecondaryBgLight = Color(0xFFF4F4F5);
  static const Color citationBgLight      = Color(0xFFF1F5F9); // Soft Chip
  static const Color citationTextLight    = Color(0xFF18181B); // Citation Text
  static const Color queryBoxBgLight      = Color(0xFFFFFFFF); // Stadium Chat Input
  static const Color queryBoxBorderLight  = Color(0xFFE5E7EB);

  // ── 1b. Apple HIG Specific Tokens ─────────────────────────────────────────
  static const Color appleGreen          = Color(0xFF34C759); // Apple System Green Toggle
  static const Color appleRed            = Color(0xFFFF3B30); // Apple System Destructive Red
  static const Color navBarDark          = Color(0xCC0E0E10); // Translucent 80% Dark Canvas
  static const Color navBarLight         = Color(0xD9FFFFFF); // Translucent 85% Light Canvas
  static const Color navBarBorderDark    = Color(0x26FFFFFF); // 15% Hairline White
  static const Color navBarBorderLight   = Color(0x1F000000); // 12% Hairline Black
  static const double dividerIndent      = 54.0;              // iOS Inset Divider

  // ── 2. Dark Mode Tokens (Claude Pure Deep Black) ─────────────────────────
  static const Color canvasDark           = Color(0xFF0E0E10); // Hitam Pekat Murni
  static const Color groupedCanvasDark    = Color(0xFF0E0E10); // Hitam Pekat Murni Grouped
  static const Color surfaceCardDark      = Color(0xFF18181B); // Elevated Surface Card
  static const Color surfaceHeaderDark    = Color(0xFF0E0E10); // Header Bar Canvas
  static const Color borderDark           = Color(0xFF27272A); // Subtle 1px Dark Outline (Abu-abu Tipis)
  static const Color borderSubtleDark     = Color(0xFF1E1E22);
  static const Color textPrimaryDark      = Color(0xFFFAFAFA); // Main Title & Body
  static const Color textSecondaryDark    = Color(0xFFA1A1AA); // Muted Subtitles
  static const Color textTertiaryDark     = Color(0xFFA1A1AA); // WCAG AA Compliant (7.3:1) Disclaimers
  static const Color accentDark           = Color(0xFFFAFAFA); // Monochrome White Action
  static const Color pillActionBgDark     = Color(0xFFFFFFFF); // Solid White Action Pill
  static const Color pillActionTextDark   = Color(0xFF18181B);
  static const Color pillSecondaryBgDark  = Color(0xFF18181B);
  static const Color citationBgDark       = Color(0xFF1E1E22); // Deep Pill
  static const Color citationTextDark     = Color(0xFFFAFAFA); // Monochrome Citation Text
  static const Color queryBoxBgDark       = Color(0xFF18181B); // Stadium Chat Input
  static const Color queryBoxBorderDark   = Color(0xFF27272A);
  static const Color surfaceElevated      = Color(0xFF18181B); // Elevated chip / pill container
  static const Color scholarlyIndigo      = Color(0xFF18181B); // Monochrome Ink
  static const Color readingCanvasParchmentLight = Color(0xFFFBF7EE); // Warm parchment reading surface
  static const Color readingCanvasParchmentDark  = Color(0xFF1C1A17);

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

  // ── 4. Geometri & Radius Apple HIG (3 Nilai Baku: 8, 16, 100) ───────────────
  static const double radiusXS   = 8.0;   // Kecil: chip / badge / tag
  static const double radiusCard = 16.0;  // Sedang: card / dialog / bottom sheet
  static const double radiusM    = 16.0;  // Alias untuk kompatibilitas
  static const double radiusS    = 8.0;   // Diharmonisasi ke 8.0
  static const double radiusL    = 16.0;  // Diharmonisasi ke 16.0
  static const double radiusXL   = 16.0;  // Diharmonisasi ke 16.0
  static const double radiusFull = 100.0; // Bulat: pill / button / avatar
  static const double radiusPill = 100.0; // Stadium Pills & Buttons
  static const double radiusQuery= 100.0; // Chat Query Stadium Pill

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
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: GoogleFonts.outfit(
          color: textPrimaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
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
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryLight,
        contentTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
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
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
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
          borderRadius: BorderRadius.all(Radius.circular(radiusCard)),
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
      displayLarge: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.6),
      displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.4),
      headlineLarge: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.3),
      headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.2),
      titleLarge: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.1),
      titleMedium: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleSmall: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: secondary),
      bodyLarge: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: primary, height: 1.55),
      bodyMedium: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: secondary, height: 1.45),
      bodySmall: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400, color: tertiary, height: 1.4),
      labelLarge: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
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
