import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';

/// Dialog "Hentikan jawaban?" bergaya OpenTurath, menggantikan dialog Google.
///
/// Hanya judul dan dua pilihan, monokrom (tanpa warna aksen). Mengembalikan
/// `true` bila pengguna memilih menghentikan; `false` bila melanjutkan atau
/// menutup dialog.
Future<bool> showStopGeneratingDialog(BuildContext context) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: Loc.tr('stopGeneratingKeep'),
    barrierColor: Colors.black.withValues(alpha: 0.42),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => const _StopGeneratingDialog(),
    transitionBuilder: (context, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
  return result ?? false;
}

class _StopGeneratingDialog extends StatelessWidget {
  const _StopGeneratingDialog();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final onInk = OTColors.onInverted(dark);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          color: OTColors.surface(dark),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OTRadius.card),
            side: BorderSide(color: OTColors.border(dark), width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Loc.tr('stopGeneratingTitle'),
                  style: OTTypography.cardTitle(color: ink),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: muted,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        child: Text(Loc.tr('stopGeneratingKeep'),
                            style: ScholarlyFonts.outfit(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      FilledButton(
                        autofocus: true,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop(true);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: ink,
                          foregroundColor: onInk,
                          elevation: 0,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                        ),
                        child: Text(Loc.tr('stopGeneratingConfirm'),
                            style: ScholarlyFonts.outfit(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
