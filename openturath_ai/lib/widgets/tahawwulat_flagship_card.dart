import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import '../services/open_turath_catalog_repository.dart';
import 'assistant_grid_card.dart';
import 'ot_motion_widgets.dart';
import 'tahawwulat_hero.dart';
import 'tahawwulat_introduction_sheet.dart';

/// The main collection uses the same calm surface as the rest of the library.
class TahawwulatFlagshipCard extends StatelessWidget {
  const TahawwulatFlagshipCard(
      {super.key,
      required this.agent,
      required this.isSubscribed,
      required this.onOpenMain,
      required this.onOpenSubAgent,
      this.onOpenLibrary,
      this.onOpenIntroduction,
      this.metadata});
  final AgentModel agent;
  final bool isSubscribed;
  final VoidCallback onOpenMain;
  final void Function(SubAgentModel subAgent) onOpenSubAgent;
  final VoidCallback? onOpenLibrary;
  final VoidCallback? onOpenIntroduction;
  final AiLibraryMetadata? metadata;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final subs = agent.subAgents ?? const <SubAgentModel>[];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: OTColors.surface(dark),
          borderRadius: BorderRadius.circular(OTRadius.hero)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TahawwulatHero(onOpen: onOpenMain, onIntroduction: onOpenIntroduction ?? () => TahawwulatIntroductionSheet.show(context, agent: agent, onSelectSubAgent: onOpenSubAgent, onOpenMain: onOpenMain), facts: LibraryStat.from(metadata).map((s) => '${s.value} ${s.unit}').toList()),
        const SizedBox(height: 24),
        const SizedBox(height: 8),
        for (final sub in subs)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(Loc.isArabic ? sub.nameArabic : sub.name,
                style: OTTypography.bodyMedium(color: ink)),
            trailing: Icon(otChevronIcon(context), size: 18, color: muted),
            onTap: () => onOpenSubAgent(sub),
          ),
        const SizedBox(height: 16),
        Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                  onPressed: onOpenMain, child: Text(Loc.tr('openAssistant'))),
              if (onOpenLibrary != null)
                TextButton(
                    onPressed: onOpenLibrary,
                    child: Text(Loc.tr('viewReferences'))),
              TextButton(
                  onPressed: onOpenIntroduction ??
                      () => TahawwulatIntroductionSheet.show(context,
                          agent: agent,
                          onSelectSubAgent: onOpenSubAgent,
                          onOpenMain: onOpenMain),
                  child: Text(Loc.tr('flagshipIntroduction'))),
            ]),
      ]),
    );
  }
}
