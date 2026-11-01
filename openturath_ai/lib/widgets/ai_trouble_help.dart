import 'dart:async';

import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'adaptive_sheet.dart';

/// Kunci naskah langkah pemulihan, berurutan dari yang paling sering berhasil.
const aiTroubleStepKeys = [
  'aiHelpStep1',
  'aiHelpStep2',
  'aiHelpStep3',
  'aiHelpStep4'
];

/// Langkah pemulihan dalam bahasa yang sedang dipakai.
List<String> aiTroubleSteps() => [for (final k in aiTroubleStepKeys) Loc.tr(k)];

/// Daftar bernomor, monokrom, mengikuti arah baca bahasa aktif.
class AiTroubleSteps extends StatelessWidget {
  const AiTroubleSteps({super.key, required this.steps});
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: OTColors.surfaceSubtle(isDark),
                  ),
                  child: Text('${i + 1}',
                      style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s12,
                          fontWeight: FontWeight.w600,
                          color: ink)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(steps[i],
                      style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s14,
                          height: 1.55,
                          color: muted)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Lembar bantuan: langkah pemulihan, dan (bila diberi) tombol tutup & buka ulang.
Future<void> showAiTroubleSheet(BuildContext context,
    {VoidCallback? onRestart}) {
  return showAdaptiveSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor:
        OTColors.surface(Theme.of(context).brightness == Brightness.dark),
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(Loc.tr('aiHelpTitle'),
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s18,
                        fontWeight: FontWeight.w600,
                        color: OTColors.textPrimary(isDark))),
                const SizedBox(height: 16),
                AiTroubleSteps(steps: aiTroubleSteps()),
                if (onRestart != null) ...[
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const ValueKey('ai-help-restart'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onRestart();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(Loc.tr('aiRestartAction')),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44)),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Kartu yang muncul setelah [delay] jika AI masih memuat: menyarankan menutup
/// lalu membuka lagi. Dipasang hanya selama layar muat tampil, sehingga
/// hitungannya mulai ulang setiap kali AI dibuka.
class AiSlowLoadHint extends StatefulWidget {
  const AiSlowLoadHint(
      {super.key,
      required this.onRestart,
      required this.onMore,
      this.delay = const Duration(seconds: 15)});
  final VoidCallback onRestart;
  final VoidCallback onMore;
  final Duration delay;

  @override
  State<AiSlowLoadHint> createState() => _AiSlowLoadHintState();
}

class _AiSlowLoadHintState extends State<AiSlowLoadHint> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    if (!_visible) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OTColors.surface(isDark),
              borderRadius: OTRadius.cardBorder,
              border: Border.all(color: OTColors.border(isDark)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(Loc.tr('aiSlowHint'),
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s14,
                        height: 1.55,
                        color: OTColors.textPrimary(isDark))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('ai-slow-restart'),
                        onPressed: widget.onRestart,
                        child: Text(Loc.tr('aiRestartAction')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      key: const ValueKey('ai-slow-more'),
                      onPressed: widget.onMore,
                      child: Text(Loc.tr('aiHelpMore')),
                    ),
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
