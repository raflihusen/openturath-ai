import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'tahawwulat_introduction_sheet.dart';

/// Signature mobile dossier for Fikih Tahawwulat.
///
/// Its distinction comes from hierarchy and precision, not decorative gold,
/// glow, nested cards, or a website-sized feature block.
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final surface = OTColors.surface(dark);
    final subAgents = agent.subAgents ?? const <SubAgentModel>[];

    return Semantics(
      container: true,
      label: '${agent.title}, ${subAgents.length} asisten khusus',
      child: Container(
        padding: const EdgeInsets.all(OTSpacing.lg),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.featureBorder,
          border: Border.all(color: OTColors.borderStrong(dark), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'PILIHAN LENGKAP',
                    style: OTTypography.metadataTag(color: muted),
                  ),
                ),
                _AccessLabel(active: isSubscribed),
              ],
            ),
            const SizedBox(height: OTSpacing.lg),
            Text(
              agent.title,
              style:
                  OTTypography.editorialHero(color: ink).copyWith(fontSize: 29),
            ),
            const SizedBox(height: OTSpacing.xs),
            Text(
              agent.titleArabic,
              textDirection: TextDirection.rtl,
              style: OTTypography.arabicReading(color: muted)
                  .copyWith(fontSize: 20),
            ),
            const SizedBox(height: OTSpacing.sm),
            Text(
              agent.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: OTTypography.body(color: muted),
            ),
            if (subAgents.isNotEmpty) ...[
              const SizedBox(height: OTSpacing.lg),
              Text('Pilih cara belajar',
                  style: OTTypography.captionMedium(color: ink)),
              const SizedBox(height: OTSpacing.sm),
              Wrap(
                spacing: OTSpacing.sm,
                runSpacing: OTSpacing.sm,
                children: [
                  for (final subAgent in subAgents)
                    ActionChip(
                      onPressed: () => onOpenSubAgent(subAgent),
                      avatar: const Icon(Icons.arrow_forward_rounded, size: 15),
                      label: Text(subAgent.name),
                    ),
                ],
              ),
            ],
            const SizedBox(height: OTSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpenMain,
                    icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                    label: const Text('Buka asisten utama'),
                  ),
                ),
                if (onOpenLibrary != null) ...[
                  const SizedBox(width: OTSpacing.sm),
                  IconButton.outlined(
                    tooltip: 'Buka pustaka ${agent.title}',
                    onPressed: onOpenLibrary,
                    icon: const Icon(Icons.menu_book_outlined, size: 20),
                  ),
                ],
              ],
            ),
            const SizedBox(height: OTSpacing.sm),
            TextButton(
              onPressed: onOpenIntroduction ??
                  () => TahawwulatIntroductionSheet.show(
                        context,
                        agent: agent,
                        onSelectSubAgent: onOpenSubAgent,
                        onOpenMain: onOpenMain,
                      ),
              child: const Text('Tentang Fikih Tahawwulat'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessLabel extends StatelessWidget {
  const _AccessLabel({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? OTColors.accent(dark) : OTColors.surfaceSubtle(dark),
        borderRadius: OTRadius.chipBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: OTSpacing.md,
          vertical: OTSpacing.sm,
        ),
        child: Text(
          active ? 'Termasuk paket Anda' : 'Perlu akses',
          style: OTTypography.captionMedium(
            color:
                active ? OTColors.onAccent(dark) : OTColors.textSecondary(dark),
          ),
        ),
      ),
    );
  }
}
