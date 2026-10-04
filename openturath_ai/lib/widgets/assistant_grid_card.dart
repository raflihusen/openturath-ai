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

import 'package:openturath_ai/core/design/ot_typography.dart';
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

/// Kartu asisten di grid: nama dan angka pustaka di tengah; satu ketukan
/// membuka asisten, tautan "Pustaka" membuka daftar kitabnya.
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

    return OTBentoTile(
      onTap: onOpen,
      semanticLabel: '${Loc.tr('startStudy')} ${agent.title}',
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.base, OTSpacing.lg, OTSpacing.base, OTSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                Loc.text(agent.title),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: ScholarlyFonts.newsreader(
                  fontSize: OTFontSize.s20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  height: 1.2,
                  color: ink,
                ),
              ),
              if (agent.isComingSoon) ...[
                const SizedBox(height: OTSpacing.sm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: OTColors.surfaceSubtle(dark),
                    borderRadius: OTRadius.chipBorder,
                  ),
                  child: Text(
                    Loc.tr('comingSoon'),
                    style: ScholarlyFonts.outfit(fontSize: OTFontSize.s11, color: muted),
                  ),
                ),
              ],
              if (stats.isNotEmpty) ...[
                const SizedBox(height: OTSpacing.md),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final stat in stats)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: OTRadius.chipBorder,
                          border: Border.all(color: border),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: stat.value,
                            style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                            children: [
                              TextSpan(
                                text: ' ${stat.unit}',
                                style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s12,
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
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: onOpen,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(Loc.tr('startStudy')),
                  style: TextButton.styleFrom(
                    foregroundColor: ink,
                    textStyle: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s14, fontWeight: FontWeight.w600),
                  ),
                ),
                if (onOpenLibrary != null)
                  TextButton(
                    onPressed: onOpenLibrary,
                    style: TextButton.styleFrom(
                      foregroundColor: muted,
                      textStyle: ScholarlyFonts.outfit(fontSize: OTFontSize.s14),
                    ),
                    child: Text(Loc.tr('libraryShort')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
