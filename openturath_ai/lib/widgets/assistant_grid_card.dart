import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../core/localization.dart';
import '../core/arabic_ui_labels.dart';
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
    this.isLocked,
  });

  final AgentModel agent;
  final AiLibraryMetadata? metadata;
  final VoidCallback onOpen;
  final VoidCallback? onOpenLibrary;
  final bool? isLocked;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    const ink = OTExpressive.white;
    const muted = OTExpressive.whiteMuted;
    final locked = isLocked ?? agent.isComingSoon;
    final stats = LibraryStat.from(metadata).take(2).toList();
    final openLabel = locked
        ? Loc.tr('comingSoon')
        : Loc.tr('openNamedAI', [Loc.text(agent.title)]);
    return OTInkCard(
      watermark: ArabicUiLabels.forAgent(agent.id, agent.titleArabic),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(Loc.text(agent.title),
              textAlign: TextAlign.center,
              maxLines: 2,
              style:
                  OTTypography.screenTitle(color: ink).copyWith(height: 1.25)),
          if (locked) ...[
            const SizedBox(height: 8),
            Text(Loc.tr('comingSoon'),
                style: OTTypography.caption(color: muted)),
          ],
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(stats.map((s) => '${s.value} ${s.unit}').join(' · '),
                textAlign: TextAlign.center,
                style: OTTypography.caption(color: muted)),
          ],
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Tooltip(
                message: openLabel,
                excludeFromSemantics: true,
                child: SizedBox(
                    width: 72,
                    height: 48,
                    child: FilledButton(
                        onPressed: onOpen,
                        style: FilledButton.styleFrom(
                            backgroundColor: locked
                                ? ink.withValues(alpha: .14)
                                : ink,
                            foregroundColor:
                                locked ? ink : OTExpressive.hero,
                            padding: EdgeInsets.zero),
                        child: Icon(
                            locked
                                ? Icons.lock_outline_rounded
                                : Icons.chat_bubble_outline_rounded,
                            semanticLabel: openLabel,
                            size: 24)))),
            if (!locked && onOpenLibrary != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                  message:
                      '${Loc.tr('viewReferences')} ${Loc.text(agent.title)}',
                  excludeFromSemantics: true,
                  child: SizedBox.square(
                      dimension: 48,
                      child: IconButton.filledTonal(
                          onPressed: onOpenLibrary,
                          style: IconButton.styleFrom(
                              backgroundColor: ink.withValues(alpha: .12),
                              foregroundColor: ink),
                          icon: Icon(Icons.auto_stories_outlined,
                              semanticLabel:
                                  '${Loc.tr('viewReferences')} ${Loc.text(agent.title)}',
                              size: 24)))),
            ],
          ]),
        ],
      ),
    );
  }
}
