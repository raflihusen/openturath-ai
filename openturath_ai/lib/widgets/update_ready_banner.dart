import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../services/update_service.dart';
import '../core/scholarly_fonts.dart';
import '../core/localization.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';

class UpdateReadyBanner extends StatelessWidget {
  const UpdateReadyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final updateService = UpdateService();

    return AnimatedBuilder(
      animation: updateService,
      builder: (context, _) {
        if (updateService.status == UpdateStatus.downloading ||
            updateService.isInstalling ||
            updateService.status == UpdateStatus.error) {
          final failed = updateService.status == UpdateStatus.error;
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(failed
                        ? updateService.lastError ??
                            Loc.tr('updateDownloadFailed')
                        : Loc.tr(updateService.isInstalling
                            ? 'updateInstalling'
                            : 'updateDownloading')),
                    if (failed)
                      TextButton(
                          onPressed: updateService.retry,
                          child: Text(Loc.tr('updateRetry')))
                    else
                      LinearProgressIndicator(
                          value: updateService.isInstalling
                              ? null
                              : updateService.updateInfo?.downloadProgress,
                          color: OTColors.textPrimary(
                              Theme.of(context).brightness == Brightness.dark)),
                  ]));
        }
        if (updateService.status == UpdateStatus.awaitingDownload) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Loc.tr('updateMeteredBody')),
                    TextButton(
                        onPressed: updateService.downloadOnMeteredNetwork,
                        child: Text(Loc.tr('updateDownloadNow'))),
                  ]));
        }
        if (!updateService.isUpdateReady) {
          return const SizedBox.shrink();
        }

        final isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface =
            isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
        final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
        final textPrimary =
            isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
        final textSecondary =
            isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
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
                  color: isDark
                      ? AppTheme.borderDark
                      : AppTheme.pillSecondaryBgLight,
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
                      isDesktop
                          ? Loc.tr('updateBannerTitleDesktop', [version])
                          : Loc.tr('updateBannerTitleMobile', [version]),
                      style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDesktop
                          ? Loc.tr('updateBannerDescDesktop')
                          : Loc.tr('updateBannerDescMobile'),
                      style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s12,
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
                onPressed: () async {
                  final opened = await updateService.installNow();
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(updateService.lastError ??
                          Loc.tr('updateReadyOpenFailed')),
                    ));
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: OTColors.accent(isDark),
                  foregroundColor: OTColors.onAccent(isDark),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(64, 36),
                  elevation: 0,
                ),
                child: Text(
                  isDesktop
                      ? Loc.tr('updateBannerActionDesktop')
                      : Loc.tr('updateBannerActionMobile'),
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14,
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
