import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/design/native_fonts.dart';
import '../core/theme.dart';
import '../core/design/native_design.dart';
import '../services/update_service.dart';

/// Modal dialog elegan yang muncul otomatis saat pembaruan selesai diunduh di latar belakang
class UpdateReadyDialog extends StatelessWidget {
  final UpdateService updateService;

  const UpdateReadyDialog({
    super.key,
    required this.updateService,
  });

  static Future<void> show(BuildContext context, UpdateService updateService) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => UpdateReadyDialog(updateService: updateService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
    final info = updateService.updateInfo;
    final version = info?.latestVersion ?? '';
    final releaseNotes = info?.releaseNotes ?? 'Penyempurnaan stabilitas telaah dan sistem keilmuan.';

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
                color: isDark ? AppTheme.borderDark : AppTheme.pillSecondaryBgLight,
              ),
              child: Icon(
                Icons.system_update_rounded,
                color: NativeColors.textPrimary(isDark),
                size: 26,
              ),
            ),
            const SizedBox(height: 16),

            // Judul Pembaruan
            Text(
              isDesktop ? 'Pembaruan Tersedia' : 'Pembaruan Telah Siap',
              style: NativeFonts.newsreader(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Nomor Versi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1D) : const Color(0xFFEAEAE6),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Text(
                'Versi $version',
                style: NativeFonts.outfit(
                  fontSize: 12,
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
                  ? 'Tersedia versi desktop terbaru dengan peningkatan keilmuan dan stabilitas. Buka tautan untuk memperbarui.'
                  : 'Aplikasi telah selesai mengunduh pembaruan di latar belakang secara senyap. Ketuk tombol di bawah untuk memasang dan memuat ulang aplikasi.',
              style: NativeFonts.outfit(
                fontSize: 13,
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
                  color: isDark ? const Color(0xFF161615) : const Color(0xFFF2F2EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: border.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  releaseNotes,
                  style: NativeFonts.outfit(
                    fontSize: 12,
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
                onPressed: () {
                  Navigator.of(context).pop();
                  updateService.installNow();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: NativeColors.accent(isDark),
                  foregroundColor: NativeColors.onAccent(isDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isDesktop ? 'Perbarui Sekarang' : 'Pasang & Muat Ulang Sekarang',
                  style: NativeFonts.outfit(
                    fontSize: 14,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                ),
                child: Text(
                  'Nanti Saja',
                  style: NativeFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
