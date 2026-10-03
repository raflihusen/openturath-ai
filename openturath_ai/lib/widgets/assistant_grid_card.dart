import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import '../services/open_turath_catalog_repository.dart';
import 'ot_motion_widgets.dart';

/// Satu angka pustaka sebagai pil: angka tegas, satuan redup.
class LibraryStat {
  const LibraryStat(this.value, this.unit);
  final String value;
  final String unit;

  /// Angka pustaka yang benar-benar tercatat; yang kosong tidak ditampilkan.
  static List<LibraryStat> from(AiLibraryMetadata? metadata) {
    if (metadata == null) return const [];
    final number = NumberFormat.decimalPattern(Loc.language);
    final volumes = RegExp(r'^\s*([\d.,]+\+?)\s*jilid', caseSensitive: false)
        .firstMatch(metadata.totalJilid)
        ?.group(1);
    return [
      if (metadata.totalKitab > 0)
        LibraryStat(number.format(metadata.totalKitab), Loc.tr('unitBooks')),
      if (volumes != null) LibraryStat(volumes, Loc.tr('unitVolumes')),
      if (metadata.totalHalaman > 0)
        LibraryStat(number.format(metadata.totalHalaman), Loc.tr('unitPages')),
      if ((metadata.totalMuhadharah ?? 0) > 0)
        LibraryStat(
            number.format(metadata.totalMuhadharah), Loc.tr('unitLectures')),
    ];
  }
}

/// Kartu asisten di grid: satu ketukan membuka asisten, ikon buku membuka pustaka.
class AssistantGridCard extends StatelessWidget {
  const AssistantGridCard({
    super.key,
    required this.agent,
    required this.onOpen,
    this.metadata,
    this.onOpenLibrary,
  });

  final AgentModel agent;
  final AiLibraryMetadata? metadata;
  final VoidCallback onOpen;
  final VoidCallback? onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);
    final stats = LibraryStat.from(metadata);
    final scope = agent.subtitleAcademic.trim();
    final showScope =
        scope.isNotEmpty && (Loc.language == 'id' || Loc.text(scope) != scope);

    return OTBentoTile(
      onTap: onOpen,
      semanticLabel: '${Loc.tr('startStudy')} ${agent.title}',
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.base, OTSpacing.base, OTSpacing.base, OTSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      Loc.text(agent.title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ScholarlyFonts.newsreader(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        height: 1.2,
                        color: ink,
                      ),
                    ),
                  ),
                  if (agent.isComingSoon) ...[
                    const SizedBox(width: OTSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: OTColors.surfaceSubtle(dark),
                        borderRadius: OTRadius.chipBorder,
                      ),
                      child: Text(
                        Loc.tr('comingSoon'),
                        style:
                            ScholarlyFonts.outfit(fontSize: 11, color: muted),
                      ),
                    ),
                  ],
                ],
              ),
              if (agent.titleArabic.isNotEmpty && !Loc.isArabic)
                Text(
                  agent.titleArabic,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ScholarlyFonts.scheherazadeNew(
                      fontSize: 17, height: 1.7, color: muted),
                ),
              if (showScope) ...[
                const SizedBox(height: 4),
                Text(
                  scope,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ScholarlyFonts.outfit(
                      fontSize: 13, height: 1.45, color: muted),
                ),
              ],
              if (stats.isNotEmpty) ...[
                const SizedBox(height: OTSpacing.md),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final stat in stats)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: OTRadius.chipBorder,
                          border: Border.all(color: border),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: stat.value,
                            style: ScholarlyFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                            children: [
                              TextSpan(
                                text: ' ${stat.unit}',
                                style: ScholarlyFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: OTSpacing.md),
            child: Row(
              children: [
                Text(
                  Loc.tr('startStudy'),
                  style: ScholarlyFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16, color: ink),
                const Spacer(),
                if (onOpenLibrary != null)
                  IconButton(
                    onPressed: onOpenLibrary,
                    tooltip: Loc.tr('assistantLibrary'),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.auto_stories_outlined,
                        size: 19, color: muted),
                  )
                else
                  const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
