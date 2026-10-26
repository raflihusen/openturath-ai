import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import '../services/feature_flags.dart';
import '../services/open_turath_catalog_repository.dart';
import 'assistant_grid_card.dart';
import 'tahawwulat_hero.dart';
import 'tahawwulat_ai_picker.dart';
import 'tahawwulat_slides_screen.dart';

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
        agents: subs,
        onSelect: onOpenSubAgent,
        isSoon: (sub) =>
            gateSubAgent(sub.id, FeatureFlagsService.current) ==
            SubAgentGate.comingSoon);
    // Dibangun ulang saat saklar jarak jauh berubah, tanpa memuat ulang layar.
    return ValueListenableBuilder<FeatureFlags>(
        valueListenable: FeatureFlagsService.notifier,
        builder: (context, _, __) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TahawwulatHero(
                  onOpen: choose,
                  onOpenLibrary: onOpenLibrary,
                  onIntroduction: onOpenIntroduction ??
                      () => TahawwulatSlidesScreen.show(context, onAsk: choose),
                  facts: LibraryStat.from(metadata)
                      .map((s) => '${s.value} ${s.unit}')
                      .toList()),
            ]));
  }
}
