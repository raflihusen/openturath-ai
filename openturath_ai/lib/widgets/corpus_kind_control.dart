import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/localization.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';

import 'package:openturath_ai/core/design/ot_radius.dart';

/// Pengalih direktori yang sengaja datar: ini navigasi, bukan kartu.
class CorpusKindControl extends StatelessWidget {
  const CorpusKindControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CorpusKind value;
  final ValueChanged<CorpusKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.8)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        children: [
          _CorpusKindTab(
            label: Loc.tr('corpusDisciplineTab'),
            selected: value == CorpusKind.discipline,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => onChanged(CorpusKind.discipline),
          ),
          _CorpusKindTab(
            label: Loc.tr('corpusScholarTab'),
            selected: value == CorpusKind.scholar,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => onChanged(CorpusKind.scholar),
          ),
        ],
      ),
    );
  }
}

class _CorpusKindTab extends StatelessWidget {
  const _CorpusKindTab({
    required this.label,
    required this.selected,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Lebar mengikuti label: tab rata awal, tidak diregangkan selebar jendela.
    return InkWell(
      onTap: () {
        OTMotion.selection();
        onTap();
      },
      borderRadius: BorderRadius.circular(OTRadius.xs),
      child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: IntrinsicWidth(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: OTTypography.bodyMedium(
                  color: selected ? textPrimary : textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: OTMotion.fast,
                curve: OTMotion.curve,
                height: 2,
                color: selected ? textPrimary : Colors.transparent,
              ),
            ],
          ))),
    );
  }
}
