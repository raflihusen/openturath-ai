import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import '../services/open_turath_catalog_repository.dart';
import 'assistant_grid_card.dart';
import 'tahawwulat_hero.dart';
import 'tahawwulat_ai_picker.dart';
import 'tahawwulat_introduction_sheet.dart';

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
  final void Function(SubAgentModel) onOpenSubAgent;
  final VoidCallback? onOpenLibrary;
  final VoidCallback? onOpenIntroduction;
  final AiLibraryMetadata? metadata;
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final subs = agent.subAgents ?? const <SubAgentModel>[];
    void choose() => TahawwulatAiPicker.show(context,
        agents: subs, onSelect: onOpenSubAgent);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TahawwulatHero(
          onOpen: choose,
          onIntroduction: onOpenIntroduction ??
              () => TahawwulatIntroductionSheet.show(context,
                  agent: agent,
                  onSelectSubAgent: onOpenSubAgent,
                  onOpenMain: choose),
          facts: LibraryStat.from(metadata)
              .map((s) => '${s.value} ${s.unit}')
              .toList()),
      if (onOpenLibrary != null)
        Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                    onPressed: onOpenLibrary,
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: Text(Loc.tr('viewReferences'))))),
    ]);
  }
}
