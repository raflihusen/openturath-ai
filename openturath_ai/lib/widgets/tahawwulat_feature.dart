import 'package:flutter/material.dart';
import '../core/app_copy.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import 'openturath_brand.dart';

import 'package:openturath_ai/core/design/ot_radius.dart';
class TahawwulatFeature extends StatelessWidget {
  const TahawwulatFeature({super.key, required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = OTColors.border(dark);
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);

    return Material(
      color: OTColors.surface(dark),
      borderRadius: BorderRadius.circular(OTRadius.input),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(OTRadius.input),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OTRadius.input),
            border: Border.all(color: border, width: 1.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(OTRadius.input),
              border: Border.all(color: border.withValues(alpha: 0.6), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header: Mark + Honor Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const OpenTurathMark(size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: border.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(OTRadius.xs),
                            ),
                            child: Text(
                              Loc.tr('tahawwulatHonor'),
                              style: OTTypography.captionMedium(color: ink).copyWith(fontSize: OTFontSize.s11),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manhaj Al-Allamah Al-Habib Abu Bakr al-Masyhur',
                            style: OTTypography.caption(color: muted).copyWith(fontSize: OTFontSize.s11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main Title Dual (Latin & Arabic)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      AppCopy.planTahawwulat,
                      style: ScholarlyFonts.newsreader(
                        fontSize: OTFontSize.s22,
                        fontWeight: FontWeight.w700,
                        color: ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'فقه التحولات',
                      textDirection: TextDirection.rtl,
                      style: ScholarlyFonts.scheherazadeNew(
                        fontSize: OTFontSize.s20,
                        fontWeight: FontWeight.w700,
                        color: ink,
                        height: 1.85,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  Loc.tr('tahawwulatBenefit'),
                  style: OTTypography.body(color: muted).copyWith(fontSize: OTFontSize.s14, height: 1.4),
                ),
                const SizedBox(height: 16),

                // Feature Highlights Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _FeaturePill(label: 'Al-Muhaqqiq (Ibarah)', isDark: dark),
                    _FeaturePill(label: 'Al-Bayan (Konsep)', isDark: dark),
                    _FeaturePill(label: 'Al-Mukhtabir (Ujian)', isDark: dark),
                    _FeaturePill(label: 'Khazanah Lisan', isDark: dark),
                  ],
                ),
                const SizedBox(height: 18),

                // Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppCopy.openAction,
                      style: OTTypography.button(color: ink).copyWith(
                        decoration: TextDecoration.underline,
                        decorationThickness: 1.5,
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: ink),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final border = OTColors.border(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: OTColors.canvas(isDark),
        borderRadius: BorderRadius.circular(OTRadius.xs),
        border: Border.all(color: border.withValues(alpha: 0.7), width: 0.6),
      ),
      child: Text(
        label,
        style: ScholarlyFonts.outfit(fontSize: OTFontSize.s11, fontWeight: FontWeight.w400, color: textSecondary),
      ),
    );
  }
}
