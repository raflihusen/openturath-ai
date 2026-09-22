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
    final surface = dark ? OTColors.surface(dark) : OTColors.accent(dark);
    final ink = dark ? OTColors.textPrimary(dark) : OTColors.onAccent(dark);
    final muted = ink.withValues(alpha: 0.68);
    final subAgents = agent.subAgents ?? const <SubAgentModel>[];

    return Semantics(
      container: true,
      label: '${agent.title}, ${subAgents.length} asisten khusus',
      child: Container(
        padding: const EdgeInsets.all(OTSpacing.lg),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.featureBorder,
          boxShadow: dark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 30,
                    offset: Offset(0, 14),
                  ),
                ],
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
                _AccessLabel(
                  active: isSubscribed,
                  foreground: ink,
                ),
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
                    InkWell(
                      onTap: () => onOpenSubAgent(subAgent),
                      borderRadius: OTRadius.rowBorder,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OTSpacing.md,
                          vertical: OTSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: ink.withValues(alpha: 0.1),
                          borderRadius: OTRadius.rowBorder,
                        ),
                        child: Text(
                          subAgent.name,
                          style: OTTypography.captionMedium(color: ink),
                        ),
                      ),
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
                    style: FilledButton.styleFrom(
                      backgroundColor: ink,
                      foregroundColor: surface,
                    ),
                    icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                    label: const Text('Buka asisten utama'),
                  ),
                ),
                if (onOpenLibrary != null) ...[
                  const SizedBox(width: OTSpacing.sm),
                  IconButton(
                    tooltip: 'Buka pustaka ${agent.title}',
                    onPressed: onOpenLibrary,
                    color: ink,
                    icon: const Icon(Icons.menu_book_outlined, size: 20),
                  ),
                ],
              ],
            ),
            const SizedBox(height: OTSpacing.sm),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: muted),
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
  const _AccessLabel({required this.active, required this.foreground});

  final bool active;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: active ? 0.14 : 0.08),
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
            color: foreground,
          ),
        ),
      ),
    );
  }
}
