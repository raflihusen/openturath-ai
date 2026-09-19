import 'package:flutter/material.dart';
import 'package:openturath_ai/core/design/ot_fonts.dart';
import 'design/ot_colors.dart';
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
  static const Color navBarDark = Color(0xCC111110);
  static const Color navBarLight = Color(0xD9F6F6F3);
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
  static const Color readingCanvasParchmentLight = Color(0xFFF6F6F3);
  static const Color readingCanvasParchmentDark = Color(0xFF181817);

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
  static const Color bgDeep = Color(0xFF0E0E0F);
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

  // ── 4. Geometri & Radius Apple HIG (3 Nilai Baku: 8, 16, 100) ───────────────
  static const double radiusXS = 8.0; // Kecil: chip / badge / tag
  static const double radiusCard = 16.0; // Sedang: card / dialog / bottom sheet
  static const double radiusM = 16.0; // Alias untuk kompatibilitas
  static const double radiusS = 8.0; // Diharmonisasi ke 8.0
  static const double radiusL = 16.0; // Diharmonisasi ke 16.0
  static const double radiusXL = 20.0; // Diharmonisasi ke 16.0
  static const double radiusFull = 100.0; // Bulat: pill / button / avatar
  static const double radiusPill = 100.0; // Stadium Pills & Buttons
  static const double radiusQuery = 100.0; // Chat Query Stadium Pill

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
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  static ThemeData get darkTheme => _theme(true);
  static ThemeData get lightTheme => _theme(false);

  static ThemeData _theme(bool dark) {
    final ink = OTColors.textPrimary(dark);
    final paper = OTColors.canvas(dark);
    final surface = OTColors.surface(dark);
    final border = OTColors.border(dark);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final button = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
      shape: WidgetStatePropertyAll(shape),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(OTTypography.button()),
      animationDuration: const Duration(milliseconds: 160),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: OTFonts.outfit().fontFamily,
      fontFamilyFallback: const ['Scheherazade New'],
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: ink,
        brightness: dark ? Brightness.dark : Brightness.light).copyWith(
        primary: ink, onPrimary: OTColors.onAccent(dark),
        primaryContainer: OTColors.surfaceSubtle(dark), onPrimaryContainer: ink,
        secondary: ink, onSecondary: OTColors.onAccent(dark),
        secondaryContainer: OTColors.surfaceSubtle(dark), onSecondaryContainer: ink,
        tertiary: ink, onTertiary: OTColors.onAccent(dark),
        tertiaryContainer: OTColors.surfaceSubtle(dark), onTertiaryContainer: ink,
        error: ink, onError: OTColors.onAccent(dark),
        errorContainer: OTColors.surfaceSubtle(dark), onErrorContainer: ink,
        surface: surface, onSurface: ink,
        surfaceContainerLowest: paper, surfaceContainerLow: paper,
        surfaceContainer: surface, surfaceContainerHigh: OTColors.surfaceSubtle(dark),
        surfaceContainerHighest: OTColors.surfaceSubtle(dark),
        onSurfaceVariant: OTColors.textSecondary(dark),
        outline: border, outlineVariant: border,
        surfaceTint: Colors.transparent,
        inverseSurface: ink, onInverseSurface: OTColors.onAccent(dark), inversePrimary: paper),
      textTheme: _buildTextTheme(dark ? Brightness.dark : Brightness.light),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: NoSplash.splashFactory,
      highlightColor: ink.withValues(alpha: .04),
      hoverColor: ink.withValues(alpha: .035),
      focusColor: ink.withValues(alpha: .1),
      iconTheme: IconThemeData(color: ink, size: 22),
      iconButtonTheme: IconButtonThemeData(style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        foregroundColor: WidgetStatePropertyAll(ink))),
      appBarTheme: AppBarTheme(backgroundColor: paper, foregroundColor: ink,
        surfaceTintColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0,
        centerTitle: false, titleTextStyle: OTTypography.screenTitle(color: ink)),
      cardTheme: CardThemeData(color: surface, surfaceTintColor: Colors.transparent,
        elevation: 0, margin: EdgeInsets.zero,
        shape: shape.copyWith(side: BorderSide(color: border, width: .8))),
      filledButtonTheme: FilledButtonThemeData(style: button.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.disabled) ? ink.withValues(alpha: .12) : ink),
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.disabled) ? ink.withValues(alpha: .4) : OTColors.onAccent(dark)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: button.copyWith(
        foregroundColor: WidgetStatePropertyAll(ink),
        side: WidgetStatePropertyAll(BorderSide(color: OTColors.borderStrong(dark), width: .8)))),
      textButtonTheme: TextButtonThemeData(style: button.copyWith(foregroundColor: WidgetStatePropertyAll(ink))),
      dividerTheme: DividerThemeData(color: border, thickness: .8, space: 1),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface,
        surfaceTintColor: Colors.transparent, elevation: 0, showDragHandle: true,
        dragHandleColor: OTColors.borderStrong(dark),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)))),
      dialogTheme: DialogThemeData(backgroundColor: surface, elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: OTTypography.bookTitle(color: ink),
        contentTextStyle: OTTypography.body(color: OTColors.textSecondary(dark)),
        shape: shape.copyWith(side: BorderSide(color: border))),
      snackBarTheme: SnackBarThemeData(backgroundColor: ink,
        contentTextStyle: OTTypography.body(color: OTColors.onAccent(dark)),
        shape: shape, behavior: SnackBarBehavior.floating, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: surface,
        hintStyle: OTTypography.body(color: OTColors.textTertiary(dark)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border, width: .8)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border, width: .8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ink, width: 1.5))),
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: ink,
        borderRadius: BorderRadius.circular(8)), textStyle: OTTypography.caption(color: OTColors.onAccent(dark))),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: QuietPageTransitionsBuilder(),
        TargetPlatform.iOS: QuietPageTransitionsBuilder(),
        TargetPlatform.macOS: QuietPageTransitionsBuilder(),
        TargetPlatform.windows: QuietPageTransitionsBuilder(),
        TargetPlatform.linux: QuietPageTransitionsBuilder(),
        TargetPlatform.fuchsia: QuietPageTransitionsBuilder(),
      }),
    );
  }

  static TextStyle _fontNewsreader({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return OTFonts.newsreader(
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
    return OTFonts.outfit(
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
      displaySmall: _fontNewsreader(fontSize: 32, fontWeight: FontWeight.w500,
          color: primary, letterSpacing: -0.5, height: 1.18),
      headlineSmall: _fontNewsreader(fontSize: 24, fontWeight: FontWeight.w500,
          color: primary, letterSpacing: -0.3, height: 1.25),
      labelMedium: _fontOutfit(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
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
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
    );
  }
}



/// Native iOS-style back swipe remains available through MaterialPageRoute.
class QuietPageTransitionsBuilder extends PageTransitionsBuilder {
  const QuietPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return const CupertinoPageTransitionsBuilder().buildTransitions(
      route, context, animation, secondaryAnimation, child);
  }
}
