import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'apple_interactive_wrapper.dart';
import 'tahawwulat_introduction_sheet.dart';

/// Sovereign V6 card for the flagship Fikih Tahawwulat corpus.
///
/// The measured brass hairlines are deliberately exclusive to this card. The
/// hierarchy remains monochrome and editorial, with no gradients or glow.
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
    final subAgents = agent.subAgents ?? const <SubAgentModel>[];
    const radius = 24.0;

    return Semantics(
      container: true,
      label:
          '${agent.title}, koleksi utama, ${subAgents.length} asisten khusus',
      child: Container(
        decoration: BoxDecoration(
          color: OTColors.sovereignSurface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: OTColors.sovereignGold, width: 1),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius - 4),
            border: Border.all(color: OTColors.sovereignHairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: 12,
                top: 54,
                child: IgnorePointer(
                  child: Text(
                    'تحولات',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.arabicDisplay(
                      color: OTColors.sovereignGold.withValues(alpha: 0.10),
                      height: 1.9,
                    ).copyWith(fontSize: 72),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'DAULAT 01',
                          style: OTTypography.metadataTag(
                            color: OTColors.sovereignGold,
                          ).copyWith(letterSpacing: 1.6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: OTColors.sovereignHairline,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusBadge(isSubscribed: isSubscribed),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      agent.title,
                      style: OTTypography.editorialHero(
                        color: OTColors.sovereignInk,
                      ).copyWith(fontSize: 30, height: 1.08),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      agent.titleArabic,
                      textDirection: TextDirection.rtl,
                      style: OTTypography.arabicReading(
                        color: OTColors.sovereignGold,
                        height: 1.9,
                      ).copyWith(fontSize: 21),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      agent.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.body(
                        color: OTColors.sovereignMuted,
                      ).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, color: OTColors.sovereignHairline),
                    ...List.generate(subAgents.length, (index) {
                      final sub = subAgents[index];
                      return _SovereignAgentRow(
                        serial: (index + 1).toString().padLeft(2, '0'),
                        subAgent: sub,
                        showDivider: index != subAgents.length - 1,
                        onTap: () => onOpenSubAgent(sub),
                      );
                    }),
                    Container(height: 1, color: OTColors.sovereignHairline),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: AppleInteractiveWrapper(
                            onTap: onOpenIntroduction ??
                                () => TahawwulatIntroductionSheet.show(
                                      context,
                                      agent: agent,
                                      onSelectSubAgent: onOpenSubAgent,
                                      onOpenMain: onOpenMain,
                                    ),
                            semanticLabel: 'Mengenal Fikih Tahawwulat',
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: OTColors.sovereignInk,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.auto_stories_outlined,
                                    size: 18,
                                    color: OTColors.sovereignSurface,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Mengenal Fikih Tahawwulat',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: OTTypography.button(
                                        color: OTColors.sovereignSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 17,
                                    color: OTColors.sovereignSurface,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (onOpenLibrary != null) ...[
                          const SizedBox(width: 10),
                          AppleInteractiveWrapper(
                            onTap: onOpenLibrary,
                            semanticLabel: 'Buka pustaka ${agent.title}',
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: OTColors.sovereignSurfaceRaised,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: OTColors.sovereignHairline),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.menu_book_outlined,
                                size: 19,
                                color: OTColors.sovereignGold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isSubscribed});

  final bool isSubscribed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: OTColors.sovereignSurfaceRaised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: OTColors.sovereignHairline),
      ),
      child: Text(
        isSubscribed ? 'AKTIF' : 'PREMIUM',
        style: OTTypography.metadataTag(
          color: isSubscribed ? OTColors.sovereignInk : OTColors.sovereignGold,
        ).copyWith(fontSize: 9, letterSpacing: 1.1),
      ),
    );
  }
}

class _SovereignAgentRow extends StatelessWidget {
  const _SovereignAgentRow({
    required this.serial,
    required this.subAgent,
    required this.showDivider,
    required this.onTap,
  });

  final String serial;
  final SubAgentModel subAgent;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppleInteractiveWrapper(
      onTap: onTap,
      semanticLabel: 'Buka ${subAgent.name}',
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: OTColors.sovereignHairline),
                )
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                serial,
                style: OTTypography.metadataTag(
                  color: OTColors.sovereignGold,
                ).copyWith(fontFamily: 'monospace'),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subAgent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OTTypography.cardTitle(color: OTColors.sovereignInk),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subAgent.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OTTypography.caption(color: OTColors.sovereignMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.north_east_rounded,
              size: 16,
              color: OTColors.sovereignMuted,
            ),
          ],
        ),
      ),
    );
  }
}
