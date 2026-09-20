import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../services/update_service.dart';

class UpdateReadyBanner extends StatelessWidget {
  const UpdateReadyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final updateService = UpdateService();

    return AnimatedBuilder(
      animation: updateService,
      builder: (context, _) {
        if (!updateService.isUpdateReady) {
          return const SizedBox.shrink();
        }

        final isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
        final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
        final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
        final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
        final info = updateService.updateInfo;
        final version = info?.latestVersion ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.borderDark : AppTheme.pillSecondaryBgLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update_rounded,
                  color: OTColors.textPrimary(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDesktop ? 'Pembaruan v$version Tersedia' : 'Pembaruan v$version Siap Dipasang',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDesktop
                          ? 'Ketuk untuk membuka tautan pembaruan versi desktop terbaru.'
                          : 'Selesai diunduh di latar belakang. Ketuk pasang untuk menerapkan.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () => updateService.installNow(),
                style: FilledButton.styleFrom(
                  backgroundColor: OTColors.accent(isDark),
                  foregroundColor: OTColors.onAccent(isDark),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(64, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isDesktop ? 'Perbarui' : 'Pasang',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
