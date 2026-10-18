import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../services/update_service.dart';
import '../core/scholarly_fonts.dart';
import '../core/localization.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';

/// Modal dialog elegan yang muncul otomatis saat pembaruan selesai diunduh di latar belakang
class UpdateReadyDialog extends StatelessWidget {
  final UpdateService updateService;

  const UpdateReadyDialog({
    super.key,
    required this.updateService,
  });

  static Future<void> show(
      BuildContext context, UpdateService updateService) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: OTColors.shadow.withValues(alpha: 0.65),
      builder: (ctx) => UpdateReadyDialog(updateService: updateService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
    final info = updateService.updateInfo;
    final version = info?.latestVersion ?? '';
    final releaseNotes =
        info?.releaseNotes ?? Loc.tr('updateReadyDefaultNotes');

    return Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: BorderSide(color: border, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ikon Lencana Pembaharuan Hening
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppTheme.borderDark
                    : AppTheme.pillSecondaryBgLight,
              ),
              child: Icon(
                Icons.system_update_rounded,
                color: OTColors.textPrimary(isDark),
                size: 26,
              ),
            ),
            const SizedBox(height: 16),

            // Judul Pembaruan
            Text(
              isDesktop
                  ? Loc.tr('updateReadyTitleDesktop')
                  : Loc.tr('updateReadyTitleMobile'),
              style: ScholarlyFonts.newsreader(
                fontSize: OTFontSize.s20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Nomor Versi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? OTColors.surfaceSubtleDark
                    : OTColors.borderSubtleLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Text(
                Loc.tr('updateReadyVersion', [version]),
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s12,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Penjelasan Status Unduhan
            Text(
              isDesktop
                  ? Loc.tr('updateReadyDescDesktop')
                  : Loc.tr('updateReadyDescMobile'),
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s14,
                height: 1.5,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Catatan Rilis Ringkas
            if (releaseNotes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? OTColors.surfaceDark
                      : OTColors.surfaceSubtleLight,
                  borderRadius: BorderRadius.circular(OTRadius.input),
                  border: Border.all(
                    color: border.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  releaseNotes,
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s12,
                    color: textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Tombol Aksi Pasang & Muat Ulang
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () async {
                  final opened = await updateService.installNow();
                  if (!context.mounted) return;
                  if (opened) {
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(Loc.tr('updateReadyOpenFailed')),
                    ));
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: OTColors.accent(isDark),
                  foregroundColor: OTColors.onAccent(isDark),
                  elevation: 0,
                ),
                child: Text(
                  isDesktop
                      ? Loc.tr('updateReadyActionDesktop')
                      : Loc.tr('updateReadyActionMobile'),
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Nanti Saja
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: textSecondary,
                ),
                child: Text(
                  Loc.tr('updateReadyLater'),
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
