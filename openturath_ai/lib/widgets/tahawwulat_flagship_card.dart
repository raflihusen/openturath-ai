import '../core/l10n/app_dictionary.dart';
import 'package:flutter/material.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_colors.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'editorial.dart';
import 'tahawwulat_introduction_sheet.dart';

class TahawwulatFlagshipCard extends StatelessWidget {
  const TahawwulatFlagshipCard({super.key, required this.agent,
    required this.isSubscribed, required this.onOpenMain,
    required this.onOpenSubAgent, this.onOpenLibrary, this.onOpenIntroduction});
  final AgentModel agent;
  final bool isSubscribed;
  final VoidCallback onOpenMain;
  final void Function(SubAgentModel subAgent) onOpenSubAgent;
  final VoidCallback? onOpenLibrary, onOpenIntroduction;

  @override
  Widget build(BuildContext context) {
    const ink = OTColors.canvasDark;
    const paper = OTColors.canvasLight;
    const muted = OTColors.textSecondaryDark;
    final roles = agent.subAgents ?? const <SubAgentModel>[];
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          brightness: Brightness.dark, surface: ink, onSurface: paper,
          primary: paper, onPrimary: ink, outline: OTColors.borderStrongDark),
        dividerColor: OTColors.borderStrongDark),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(12)),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('membership.main_collection'), style: OTTypography.caption(color: muted).copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Text(context.tr(agent.title), style: OTTypography.corpusTitle(color: paper).copyWith(fontSize: 30)),
          const SizedBox(height: 8),
          Text(context.tr('membership.tahawwulat_scope'),
            style: OTTypography.body(color: muted)),
          const SizedBox(height: 20),
          EditorialButton(label: isSubscribed ? context.tr('membership.open_study') : context.tr('membership.view_access'),
            icon: Icons.arrow_forward_rounded, onPressed: onOpenMain),
          const SizedBox(height: 8),
          Wrap(spacing: 16, children: [
            TextButton(onPressed: onOpenIntroduction ?? () => TahawwulatIntroductionSheet.show(
              context, agent: agent, onSelectSubAgent: onOpenSubAgent, onOpenMain: onOpenMain),
              child: Text(context.tr('membership.discover_tahawwulat'), style: const TextStyle(color: OTColors.canvasLight))),
            if (onOpenLibrary != null) TextButton(onPressed: onOpenLibrary,
              child: Text(context.tr('membership.reference_library'), style: const TextStyle(color: OTColors.canvasLight))),
          ]),
          if (roles.isNotEmpty) ExpansionTile(
            tilePadding: EdgeInsets.zero,
            iconColor: paper, collapsedIconColor: muted,
            title: Text(context.tr('membership.specialist_count', args: {'count': roles.length}), style: OTTypography.bodyMedium(color: paper)),
            children: [for (final role in roles) ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr(role.name), style: OTTypography.bookTitle(color: paper)),
              subtitle: Text(context.tr(role.description), style: OTTypography.caption(color: muted)),
              trailing: const Icon(Icons.arrow_forward_rounded, color: muted, size: 20),
              onTap: () => onOpenSubAgent(role),
            )],
          ),
        ],
      )),
    );
  }
}
