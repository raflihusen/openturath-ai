import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'apple_interactive_wrapper.dart';
import 'tahawwulat_introduction_sheet.dart';

/// Featured collection card for Fikih Tahawwulat.
///
/// Emphasis comes from information hierarchy, not a separate dark-and-gold
/// visual language.
class TahawwulatFlagshipCard extends StatelessWidget {
  const TahawwulatFlagshipCard({
    super.key,
    required this.agent,
    required this.isSubscribed,
    required this.onOpenMain,
    required this.onOpenSubAgent,
    this.onOpenLibrary,
    this.onOpenIntroduction,
  });

  final AgentModel agent;
  final bool isSubscribed;
  final VoidCallback onOpenMain;
  final void Function(SubAgentModel subAgent) onOpenSubAgent;
  final VoidCallback? onOpenLibrary;
  final VoidCallback? onOpenIntroduction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final subtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);
    final onAccent = OTColors.onAccent(isDark);
    final subAgents = agent.subAgents ?? const <SubAgentModel>[];

    return Semantics(
      container: true,
      label: '${agent.title}, ${subAgents.length} asisten',
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.cardBorder,
          border: Border.all(color: border),
        ),
        padding: OTSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FIKIH TAHAWWULAT',
                          style: OTTypography.metadataTag(color: muted)),
                      OTSpacing.gapSm,
                      Text(agent.title,
                          style: OTTypography.editorialHero(color: ink)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OTSpacing.sm,
                    vertical: OTSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: subtle,
                    borderRadius: OTRadius.smallBorder,
                  ),
                  child: Text(
                    isSubscribed ? 'Aktif' : 'Berlangganan',
                    style: OTTypography.captionMedium(color: ink),
                  ),
                ),
              ],
            ),
            OTSpacing.gapSm,
            Text(
              agent.titleArabic,
              textDirection: TextDirection.rtl,
              style: OTTypography.arabicReading(color: ink),
            ),
            OTSpacing.gapMd,
            Text(
              agent.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: OTTypography.body(color: muted),
            ),
            if (subAgents.isNotEmpty) ...[
              OTSpacing.gapLg,
              Container(
                decoration: BoxDecoration(
                  color: subtle,
                  borderRadius: OTRadius.controlBorder,
                ),
                child: Column(
                  children: List.generate(subAgents.length, (index) {
                    final subAgent = subAgents[index];
                    return _AssistantRow(
                      subAgent: subAgent,
                      showDivider: index != subAgents.length - 1,
                      border: border,
                      ink: ink,
                      muted: muted,
                      onTap: () => onOpenSubAgent(subAgent),
                    );
                  }),
                ),
              ),
            ],
            OTSpacing.gapLg,
            Row(
              children: [
                Expanded(
                  child: AppleInteractiveWrapper(
                    onTap: onOpenMain,
                    borderRadius: OTRadius.controlBorder,
                    semanticLabel: 'Buka ${agent.title}',
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: OTRadius.controlBorder,
                      ),
                      alignment: Alignment.center,
                      child: Text('Buka asisten',
                          style: OTTypography.button(color: onAccent)),
                    ),
                  ),
                ),
                if (onOpenLibrary != null) ...[
                  OTSpacing.gapSm,
                  _SquareAction(
                    icon: Icons.menu_book_outlined,
                    label: 'Buka pustaka ${agent.title}',
                    border: border,
                    ink: ink,
                    onTap: onOpenLibrary!,
                  ),
                ],
                OTSpacing.gapSm,
                _SquareAction(
                  icon: Icons.info_outline_rounded,
                  label: 'Tentang Fikih Tahawwulat',
                  border: border,
                  ink: ink,
                  onTap: onOpenIntroduction ??
                      () => TahawwulatIntroductionSheet.show(
                            context,
                            agent: agent,
                            onSelectSubAgent: onOpenSubAgent,
                            onOpenMain: onOpenMain,
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantRow extends StatelessWidget {
  const _AssistantRow({
    required this.subAgent,
    required this.showDivider,
    required this.border,
    required this.ink,
    required this.muted,
    required this.onTap,
  });

  final SubAgentModel subAgent;
  final bool showDivider;
  final Color border;
  final Color ink;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: OTRadius.controlBorder,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.md,
            vertical: OTSpacing.sm,
          ),
          decoration: BoxDecoration(
            border:
                showDivider ? Border(bottom: BorderSide(color: border)) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subAgent.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.cardTitle(color: ink),
                    ),
                    OTSpacing.gapXs,
                    Text(
                      subAgent.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.caption(color: muted),
                    ),
                  ],
                ),
              ),
              OTSpacing.gapSm,
              Icon(Icons.chevron_right_rounded, size: 20, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({
    required this.icon,
    required this.label,
    required this.border,
    required this.ink,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color border;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppleInteractiveWrapper(
      onTap: onTap,
      borderRadius: OTRadius.controlBorder,
      semanticLabel: label,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: OTRadius.controlBorder,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: ink),
      ),
    );
  }
}
