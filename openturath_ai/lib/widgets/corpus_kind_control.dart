import 'package:flutter/material.dart';

import '../core/design/native_design.dart';
import '../core/localization.dart';
import '../core/design/ot_motion.dart';
import '../core/design/native_typography.dart';
import '../models/agent_model.dart';

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
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NativeColors.textPrimary(isDark);
    final textSecondary = NativeColors.textSecondary(isDark);
    final border = NativeColors.border(isDark);

    return Container(
      height: MediaQuery.textScalerOf(context).scale(52).clamp(52, 110),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.8)),
      ),
      child: Row(
        children: [
          _CorpusKindTab(
            label: NativeCopy.text('disciplines'),
            selected: value == CorpusKind.discipline,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => onChanged(CorpusKind.discipline),
          ),
          const SizedBox(width: 24),
          _CorpusKindTab(
            label: NativeCopy.text('scholars'),
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
    return Expanded(
      child: InkWell(
        onTap: () {
          OTMotion.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NativeTypography.bodyMedium(
                color: selected ? textPrimary : textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : OTMotion.fast,
              curve: OTMotion.curve,
              height: 2,
              width: selected ? 28 : 0,
              color: selected ? textPrimary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
