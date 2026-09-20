import 'package:flutter/material.dart';
import '../core/app_copy.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'tahawwulat_introduction_sheet.dart';

class TahawwulatFlagshipCard extends StatelessWidget {
  const TahawwulatFlagshipCard({super.key, required this.agent, required this.isSubscribed,
    required this.onOpenMain, required this.onOpenSubAgent, this.onOpenLibrary, this.onOpenIntroduction});
  final AgentModel agent;
  final bool isSubscribed;
  final VoidCallback onOpenMain;
  final void Function(SubAgentModel) onOpenSubAgent;
  final VoidCallback? onOpenLibrary;
  final VoidCallback? onOpenIntroduction;
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);
    return Container(padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: OTColors.surface(dark), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border)),
      child: Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(Loc.tr('tahawwulatHonor'), style: OTTypography.captionMedium(color: muted)),
          const SizedBox(height: 14),
          Text(agent.title, style: OTTypography.pageTitle(color: ink)),
          const SizedBox(height: 8),
          Text(Loc.tr('tahawwulatBenefit'), style: OTTypography.body(color: muted)),
          const SizedBox(height: 12),
          Text(isSubscribed ? AppCopy.activeSubscription : Loc.tr('collection'),
            style: OTTypography.captionMedium(color: muted)),
          const SizedBox(height: 18),
          for (final sub in agent.subAgents ?? <SubAgentModel>[]) ...[
            Divider(height: 1, color: border),
            ListTile(contentPadding: EdgeInsets.zero,
              title: Text(sub.name, style: OTTypography.cardTitle(color: ink)),
              subtitle: Text(sub.description, style: OTTypography.caption(color: muted)),
              trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
              onTap: () => onOpenSubAgent(sub)),
          ],
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 8, children: [
            FilledButton(onPressed: onOpenMain, child: Text(AppCopy.openAction)),
            OutlinedButton(onPressed: onOpenIntroduction ?? () => TahawwulatIntroductionSheet.show(
              context, agent: agent, onSelectSubAgent: onOpenSubAgent, onOpenMain: onOpenMain),
              child: Text(Loc.tr('introTitle'))),
            if (onOpenLibrary != null) TextButton.icon(onPressed: onOpenLibrary,
              icon: const Icon(Icons.menu_book_outlined, size: 18), label: Text(AppCopy.referenceBooks)),
          ]),
        ]),
      ),
    );
  }
}
