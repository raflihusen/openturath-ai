import 'package:flutter/material.dart';
import 'package:openturath_ai/core/design/ot_buttons.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/localization.dart';
import '../models/agent_model.dart';
import '../services/open_turath_catalog_repository.dart';
import 'ot_ink_card.dart';
import '../core/design/ot_expressive.dart';

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
    const dark = true;
    const ink = OTExpressive.white;
    const muted = OTExpressive.whiteMuted;
    final stats = LibraryStat.from(metadata);

    return OTInkCard(
      watermark: agent.titleArabic,
      semanticLabel: '${Loc.tr('openAssistant')} ${agent.title}',
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.lg, OTSpacing.lg, OTSpacing.sm, OTSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Loc.text(agent.title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    OTTypography.screenTitle(color: ink).copyWith(height: 1.2),
              ),
              if (agent.isComingSoon) ...[
                const SizedBox(height: OTSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: OTSpacing.sm, vertical: OTSpacing.xs),
                  decoration: BoxDecoration(
                    color: OTColors.surfaceSubtle(dark),
                    borderRadius: OTRadius.chipBorder,
                  ),
                  child: Text(
                    Loc.tr('comingSoon'),
                    style: OTTypography.metadataTag(color: muted),
                  ),
                ),
              ],
              // Satu baris metadata, bukan deretan pil: angka tetap terbaca
              // tanpa membuat kartu terasa seperti kumpulan tombol.
              if (stats.isNotEmpty) ...[
                const SizedBox(height: OTSpacing.sm),
                Text.rich(
                  TextSpan(children: [
                    for (final (index, stat) in stats.indexed) ...[
                      if (index > 0) const TextSpan(text: ' · '),
                      TextSpan(
                        text: stat.value,
                        style: const TextStyle(
                            color: ink, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' ${stat.unit}'),
                    ],
                  ]),
                  style: OTTypography.caption(color: muted),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: OTSpacing.md),
            child: Row(
              children: [
                TextButton(
                    onPressed: onOpen,
                    style: OTButtons.quiet(dark),
                    child: Text(Loc.tr('openAssistant'))),
                const SizedBox(width: OTSpacing.xs),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_forward_rounded,
                  size: 16,
                  color: ink,
                ),
                const Spacer(),
                if (onOpenLibrary != null)
                  TextButton(
                    onPressed: onOpenLibrary,
                    style: OTButtons.quiet(dark),
                    child: Text(Loc.tr('viewReferences')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
