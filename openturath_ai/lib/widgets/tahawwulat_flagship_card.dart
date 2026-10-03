import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'apple_interactive_wrapper.dart';
import 'tahawwulat_introduction_sheet.dart';
import 'assistant_grid_card.dart';
import '../services/open_turath_catalog_repository.dart';

/// Kartu monokrom untuk paket utama OpenTurath.
///
/// Kemewahan dibangun melalui ruang, tipografi, dan detail hairline. Seluruh
/// asisten berada dalam satu daftar editorial agar kartu tetap tenang dan tidak
/// berubah menjadi kumpulan kartu kecil yang ramai.
class TahawwulatFlagshipCard extends StatelessWidget {
  final AgentModel agent;
  final bool isSubscribed;
  final VoidCallback onOpenMain;
  final void Function(SubAgentModel subAgent) onOpenSubAgent;
  final VoidCallback? onOpenLibrary;
  final VoidCallback? onOpenIntroduction;
  final AiLibraryMetadata? metadata;

  const TahawwulatFlagshipCard({
    super.key,
    required this.agent,
    required this.isSubscribed,
    required this.onOpenMain,
    required this.onOpenSubAgent,
    this.onOpenLibrary,
    this.onOpenIntroduction,
    this.metadata,
  });

  static const _obsidian = Color(0xFF111111);
    static const _pearl = Color(0xFFF5F5F5);
  static const _silver = Color(0xFFE8E8E8);
  static const _muted = Color(0xFFB8B8B8);
  static const _hairline = Color(0xFF454545);


  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final subAgents = agent.subAgents ?? const <SubAgentModel>[];

    return Semantics(
      container: true,
      label: '${agent.title}. ${Loc.tr('flagshipExplore', [
            '${subAgents.length}'
          ])}',
      child: Container(
        decoration: BoxDecoration(
          color: _obsidian,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
            width: 0.8,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        Loc.tr('planFeaturedLabel'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ScholarlyFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: _silver,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isSubscribed
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.17),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _pearl,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isSubscribed
                                ? Loc.tr('flagshipActive')
                                : Loc.tr('flagshipPremium'),
                            style: ScholarlyFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                              color: _pearl,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  agent.title,
                  style: ScholarlyFonts.newsreader(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.8,
                    height: 1.05,
                    color: _pearl,
                  ),
                ),
                const SizedBox(height: 5),
                if (!Loc.isArabic)
                  Text(
                    agent.titleArabic,
                    textDirection: TextDirection.rtl,
                    style: ScholarlyFonts.scheherazadeNew(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      height: 1.85,
                      color: _silver,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  Loc.tr('flagshipPositioning'),
                  style: ScholarlyFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _silver,
                    height: 1.5,
                  ),
                ),
                // Angka pustaka tampil besar: bukti kerja di balik koleksi ini.
                if (LibraryStat.from(metadata).isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 28,
                    runSpacing: 12,
                    children: [
                      for (final stat in LibraryStat.from(metadata))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              stat.value,
                              style: ScholarlyFonts.newsreader(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.8,
                                height: 1.05,
                                color: _pearl,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stat.unit,
                              style: ScholarlyFonts.outfit(
                                  fontSize: 12, color: _muted),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Container(height: 0.8, color: _hairline),
                ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  iconColor: _pearl,
                  collapsedIconColor: _silver,
                  title: Text(
                    Loc.tr('flagshipExplore', ['${subAgents.length}']),
                    style: ScholarlyFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _pearl,
                    ),
                  ),
                  children: [
                    // Lima asisten sebagai ubin: dua kolom bila lebar cukup.
                    LayoutBuilder(builder: (context, box) {
                      const gap = 8.0;
                      final columns = box.maxWidth >= 520 ? 2 : 1;
                      final tileWidth =
                          (box.maxWidth - gap * (columns - 1)) / columns;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: List.generate(subAgents.length, (index) {
                    final sub = subAgents[index];

                    return SizedBox(
                        width: tileWidth,
                        child: AppleInteractiveWrapper(
                      onTap: () => onOpenSubAgent(sub),
                      pressedScale: 0.985,
                      borderRadius: BorderRadius.circular(12),
                      semanticLabel:
                          '${Loc.tr('startStudy')} ${Loc.isArabic ? sub.nameArabic : sub.name}',
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 54),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Loc.isArabic ? sub.nameArabic : sub.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ScholarlyFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.1,
                                      color: _pearl,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    Loc.isArabic
                                        ? sub.descriptionArabic
                                        : Loc.text(sub.description),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ScholarlyFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.north_east_rounded,
                              size: 16,
                              color: _silver,
                            ),
                          ],
                        ),
                      ),
                    ));
                          }),
                        ),
                      );
                    }),
                  ],
                ),
                Container(height: 0.8, color: _hairline),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Aksi sekunder: tombol bergaris selebar labelnya, bukan blok putih penuh.
                    Flexible(
                      child: AppleInteractiveWrapper(
                        onTap: onOpenIntroduction ??
                            () => TahawwulatIntroductionSheet.show(
                                  context,
                                  agent: agent,
                                  onSelectSubAgent: onOpenSubAgent,
                                  onOpenMain: onOpenMain,
                                ),
                        pressedScale: 0.985,
                        borderRadius: BorderRadius.circular(10),
                        semanticLabel: Loc.tr('flagshipIntroduction'),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_stories_rounded,
                                size: 18,
                                color: _pearl,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  Loc.tr('flagshipIntroduction'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ScholarlyFonts.outfit(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.15,
                                    color: _pearl,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 17,
                                color: _pearl,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (onOpenLibrary != null) ...[
                      const Spacer(),
                      const SizedBox(width: 10),
                      AppleInteractiveWrapper(
                        onTap: onOpenLibrary,
                        pressedScale: 0.96,
                        borderRadius: BorderRadius.circular(10),
                        semanticLabel:
                            '${Loc.tr('assistantLibrary')} ${agent.title}',
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _obsidian,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                              width: 0.8,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.auto_stories_outlined,
                            size: 19,
                            color: _pearl,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
