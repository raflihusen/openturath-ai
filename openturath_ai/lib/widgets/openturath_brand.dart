import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';

/// Ikon Spiral Biru Resmi Google NotebookLM
class OpenTurathMark extends StatelessWidget {
  const OpenTurathMark({super.key, this.size = 40, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Gemini Notebook',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          'assets/images/notebooklm_round.svg',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Logo Header Resmi Google NotebookLM dengan Badge Turats Minimalis
class OpenTurathBrand extends StatelessWidget {
  const OpenTurathBrand({
    super.key,
    this.compact = false,
    this.onDark = false,
  });

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final svgAsset = onDark
        ? 'assets/images/gemini_notebook_with_text_only_dark.svg'
        : 'assets/images/gemini_notebook_with_text_only_light.svg';

    final badgeBg = onDark
        ? AppTheme.accentDark.withValues(alpha: 0.16)
        : AppTheme.accentLight.withValues(alpha: 0.12);
    final badgeText = onDark ? AppTheme.accentDark : AppTheme.accentLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgAsset,
          height: compact ? 22 : 26,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'TURATS',
            style: GoogleFonts.outfit(
              color: badgeText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
