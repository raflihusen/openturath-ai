import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import '../services/open_turath_catalog_repository.dart';
import 'assistant_grid_card.dart';
import 'tahawwulat_hero.dart';
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final subs = agent.subAgents ?? const <SubAgentModel>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TahawwulatHero(
          onOpen: onOpenMain,
          onIntroduction: onOpenIntroduction ??
              () => TahawwulatIntroductionSheet.show(context,
                  agent: agent,
                  onSelectSubAgent: onOpenSubAgent,
                  onOpenMain: onOpenMain),
          facts: LibraryStat.from(metadata)
              .map((s) => '${s.value} ${s.unit}')
              .toList()),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(
            child: Text(Loc.tr('flagshipExplore', ['${subs.length}']),
                style: OTTypography.screenTitle(color: ink))),
        if (isSubscribed) Chip(label: Text(Loc.tr('flagshipActive')))
      ]),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, box) {
        final columns = MediaQuery.textScalerOf(context).scale(16) > 24
            ? 1
            : box.maxWidth >= 900
                ? 5
                : box.maxWidth >= 420
                    ? 2
                    : 1;
        final width = (box.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final sub in subs)
                SizedBox(
                    width: width,
                    child: FilledButton.tonal(
                      onPressed: () => onOpenSubAgent(sub),
                      style: FilledButton.styleFrom(
                          backgroundColor: OTColors.surfaceSubtle(dark),
                          foregroundColor: ink,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: OTRadius.cardBorder)),
                      child: Text(Loc.isArabic ? sub.nameArabic : sub.name,
                          textAlign: TextAlign.center,
                          style: OTTypography.bodyMedium(color: ink)),
                    ))
            ]);
      }),
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
