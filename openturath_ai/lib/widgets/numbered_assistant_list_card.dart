import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import 'apple_interactive_wrapper.dart';

/// Kartu kontainer asisten dengan sudut membulat (rounded corner 24)
/// dan penomoran dua digit (01, 02, 03...) bersih tanpa teks rujukan/subtitle di bawahnya.
class NumberedAssistantListCard extends StatelessWidget {
  final List<AgentModel> agents;
  final String? selectedAgentId;
  final ValueChanged<AgentModel> onSelect;
  final bool isDark;

  const NumberedAssistantListCard({
    super.key,
    required this.agents,
    required this.selectedAgentId,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (agents.isEmpty) {
      return const SizedBox.shrink();
    }

    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final borderSubtle = OTColors.borderSubtle(isDark);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < agents.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 0.8,
                indent: 18,
                endIndent: 18,
                color: borderSubtle,
              ),
            _NumberedAssistantRow(
              index: i + 1,
              agent: agents[i],
              isSelected: agents[i].id == selectedAgentId,
              onTap: () {
                OTMotion.light();
                onSelect(agents[i]);
              },
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _NumberedAssistantRow extends StatelessWidget {
  final int index;
  final AgentModel agent;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NumberedAssistantRow({
    required this.index,
    required this.agent,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: 0.985,
      hapticType: HapticFeedbackType.selection,
      child: Ink(
        color: isSelected
            ? (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03))
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Nomor urut dua digit (01, 02, 03...)
              SizedBox(
                width: 26,
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: ScholarlyFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // 2. Judul asisten saja (bersih, tanpa kata-kata/kitab di bawahnya)
              Expanded(
                child: Text(
                  agent.title,
                  style: ScholarlyFonts.outfit(
                    fontSize: 15.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              // 3. Panah indikator modern hairline
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: textSecondary.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
