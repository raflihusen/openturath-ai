import '../core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:openturath_ai/core/design/ot_fonts.dart';

import '../core/theme.dart';

/// Ikon Gerbang Kubah Resmi OpenTurath
class OpenTurathMark extends StatelessWidget {
  const OpenTurathMark({super.key, this.size = 36, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'OpenTurath',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          isDark
              ? 'assets/images/arch_dark_transparent.png'
              : 'assets/images/arch_light_transparent.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Logo Header Resmi OpenTurath (Arch + Wordmark Newsreader)
class OpenTurathBrand extends StatelessWidget {
  const OpenTurathBrand({
    super.key,
    this.compact = false,
    this.onDark = false,
    this.showSlogan = false,
  });

  final bool compact;
  final bool onDark;
  final bool showSlogan;

  @override
  Widget build(BuildContext context) {
    final isDark = onDark || Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final iconSize = compact ? 22.0 : 28.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          isDark
              ? 'assets/images/arch_dark_transparent.png'
              : 'assets/images/arch_light_transparent.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OpenTurath',
              style: OTFonts.newsreader(
                fontSize: compact ? 18 : 21,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            if (showSlogan) ...[
              const SizedBox(height: 1),
              Text(
                context.tr('Membaca kitab, menelusuri ibarah.'),
                style: OTFonts.newsreader(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: textSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}


