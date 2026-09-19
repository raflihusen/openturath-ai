import '../core/l10n/app_dictionary.dart';
import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import 'apple_interactive_wrapper.dart';

/// Two quiet, keyboard-accessible views of the same research directory.
class CorpusKindControl extends StatelessWidget {
  const CorpusKindControl({super.key, required this.value, required this.onChanged});
  final CorpusKind value;
  final ValueChanged<CorpusKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      _tab(context, context.tr('membership.discipline'), CorpusKind.discipline, dark),
      const SizedBox(width: 16),
      _tab(context, context.tr('membership.scholar_heritage'), CorpusKind.scholar, dark),
    ]);
  }

  Widget _tab(BuildContext context, String label, CorpusKind kind, bool dark) {
    final selected = value == kind;
    return Expanded(child: Semantics(selected: selected,
      child: AppleInteractiveWrapper(onTap: () => onChanged(kind),
        hapticType: HapticFeedbackType.light,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(
            color: selected ? OTColors.textPrimary(dark) : OTColors.border(dark),
            width: selected ? 2 : 1))),
          child: Text(label, textAlign: TextAlign.center,
            style: OTTypography.bodyMedium(color: selected
                ? OTColors.textPrimary(dark) : OTColors.textSecondary(dark))),
        ),
      ),
    ));
  }
}
