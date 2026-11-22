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

/// Penanda muat lambat 3 tahap agar ramah koneksi lambat:
/// - Tahap 1 (0 s.d. [noticeDelay], bawaan 20 detik): hening, hanya loader.
/// - Tahap 2 ([noticeDelay] s.d. [delay], bawaan 20–50 detik): keterangan lembut
///   agar pengguna menunggu karena koneksi mungkin lambat (tanpa tombol tutup/ulangi).
/// - Tahap 3 (>= [delay], bawaan >= 50 detik): opsi pemulihan ("Tutup & buka ulang"
///   dan "Solusi lain") sambil tetap membiarkan WebView memuat di latar belakang.
class AiSlowLoadHint extends StatefulWidget {
  const AiSlowLoadHint({
    super.key,
    required this.onRestart,
    required this.onMore,
    this.noticeDelay = const Duration(seconds: 20),
    this.delay = const Duration(seconds: 50),
  });
  final VoidCallback onRestart;
  final VoidCallback onMore;
  final Duration noticeDelay;
  final Duration delay;

  @override
  State<AiSlowLoadHint> createState() => _AiSlowLoadHintState();
}

enum _SlowLoadStage { hidden, waiting, actions }

class _AiSlowLoadHintState extends State<AiSlowLoadHint> {
  Timer? _noticeTimer;
  Timer? _actionsTimer;
  _SlowLoadStage _stage = _SlowLoadStage.hidden;

  @override
  void initState() {
    super.initState();
    if (widget.noticeDelay < widget.delay) {
      _noticeTimer = Timer(widget.noticeDelay, () {
        if (mounted && _stage == _SlowLoadStage.hidden) {
          setState(() => _stage = _SlowLoadStage.waiting);
        }
      });
    }
    _actionsTimer = Timer(widget.delay, () {
      if (mounted) setState(() => _stage = _SlowLoadStage.actions);
    });
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _actionsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    if (_stage == _SlowLoadStage.hidden) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: _stage == _SlowLoadStage.waiting
                ? Container(
                    key: const ValueKey('ai-slow-waiting'),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: OTColors.surface(isDark),
                      borderRadius: OTRadius.cardBorder,
                      border: Border.all(color: OTColors.border(isDark)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 18,
                          color: OTColors.textSecondary(isDark),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            Loc.tr('aiSlowWaiting'),
                            style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s14,
                              height: 1.5,
                              color: OTColors.textSecondary(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    key: const ValueKey('ai-slow-actions'),
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
      ),
    );
  }
}
