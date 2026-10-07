import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

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
    const ink = OTExpressive.white;
    const muted = OTExpressive.whiteMuted;
    final stats = LibraryStat.from(metadata).take(2).toList();
    return OTInkCard(
      watermark: agent.titleArabic,
      semanticLabel: '${Loc.tr('openAssistant')} ${agent.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(Loc.text(agent.title),
              style:
                  OTTypography.screenTitle(color: ink).copyWith(height: 1.25)),
          if (agent.isComingSoon) ...[
            const SizedBox(height: 8),
            Text(Loc.tr('comingSoon'),
                style: OTTypography.caption(color: muted)),
          ],
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(stats.map((s) => '${s.value} ${s.unit}').join(' · '),
                style: OTTypography.caption(color: muted)),
          ],
          const SizedBox(height: 20),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(
                onPressed: onOpen,
                style: FilledButton.styleFrom(
                    backgroundColor: ink, foregroundColor: OTExpressive.hero),
                icon: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back_rounded
                        : Icons.arrow_forward_rounded,
                    size: 16),
                label: Text(Loc.tr('openAssistant'))),
            if (onOpenLibrary != null)
              TextButton(
                  onPressed: onOpenLibrary,
                  style: TextButton.styleFrom(foregroundColor: muted),
                  child: Text(Loc.tr('viewReferences'))),
          ]),
        ],
      ),
    );
  }
}
