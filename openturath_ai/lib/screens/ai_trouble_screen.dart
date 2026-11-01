import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../core/design/ot_typography.dart';
import '../widgets/ai_trouble_help.dart';

/// Halaman Bantuan "AI bermasalah?": solusi tetap yang bisa dibaca kapan saja.
class AiTroubleScreen extends StatelessWidget {
  const AiTroubleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: OTColors.canvas(isDark),
      appBar: AppBar(
        backgroundColor: OTColors.canvas(isDark),
        elevation: 0,
        title: Text(Loc.tr('aiHelpTitle')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Text(Loc.tr('aiHelpSubtitle'),
                  style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s14,
                      height: 1.55,
                      color: OTColors.textSecondary(isDark))),
              const SizedBox(height: 20),
              AiTroubleSteps(steps: aiTroubleSteps()),
            ],
          ),
        ),
      ),
    );
  }
}
