import '../core/localization.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/design/native_fonts.dart';
import '../core/theme.dart';
import '../core/design/native_design.dart';
import '../services/update_service.dart';

class UpdateReadyBanner extends StatelessWidget {
  const UpdateReadyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final updateService = UpdateService();

    return AnimatedBuilder(
      animation: updateService,
      builder: (context, _) {
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
                height:
                    MediaQuery.textScalerOf(context).scale(48).clamp(48, 120),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.borderDark
                      : AppTheme.pillSecondaryBgLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update_rounded,
                  color: NativeColors.textPrimary(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Loc.tr(isDesktop ? 'updateAvailable' : 'updateReady',
                          [version]),
                      style: NativeFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      NativeCopy.text(
                          isDesktop ? 'updateDesktop' : 'updateMobile'),
                      style: NativeFonts.outfit(
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
                  backgroundColor: NativeColors.accent(isDark),
                  foregroundColor: NativeColors.onAccent(isDark),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(64, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  NativeCopy.text(isDesktop ? 'updateNow' : 'installNow'),
                  style: NativeFonts.outfit(
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
