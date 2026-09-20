import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';

class ScholarsComingSoon extends StatelessWidget {
  const ScholarsComingSoon({super.key});
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520),
        child: Container(padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: OTColors.surface(dark), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OTColors.border(dark))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.lock_outline_rounded, size: 30, color: OTColors.textSecondary(dark)),
            const SizedBox(height: 20),
            Text(Loc.tr('scholarPreparing'), textAlign: TextAlign.center,
              style: OTTypography.pageTitle(color: OTColors.textPrimary(dark))),
            const SizedBox(height: 12),
            Text(Loc.tr('scholarPreparingBody'), textAlign: TextAlign.center,
              style: OTTypography.body(color: OTColors.textSecondary(dark))),
          ]),
        ),
      ),
    ));
  }
}
