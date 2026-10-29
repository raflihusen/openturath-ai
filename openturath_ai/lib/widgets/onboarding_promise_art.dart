import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';

/// Daftar janji privasi pada slide terakhir pengenalan: baris bertanda centang,
/// monokrom, tanpa gerak.
class OnboardingPromiseArt extends StatelessWidget {
  const OnboardingPromiseArt(
      {super.key, required this.dark, required this.promises});

  final bool dark;
  final List<String> promises;

  @override
  Widget build(BuildContext context) {
    final fg = OTColors.textPrimary(dark);
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final p in promises)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: OTSpacing.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: OTSpacing.base, vertical: OTSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: OTRadius.cardBorder,
                  border: Border.all(color: OTColors.border(dark)),
                ),
                child: Row(children: [
                  Icon(Icons.check_rounded, size: 20, color: fg),
                  const SizedBox(width: OTSpacing.md),
                  Expanded(
                      child:
                          Text(p, style: OTTypography.bodyMedium(color: fg))),
                ]),
              ),
          ]),
        ),
      ),
    );
  }
}
