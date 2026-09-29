import 'dart:async';
import 'package:flutter/material.dart';

import 'theme.dart';
import 'design/ot_colors.dart';

enum SnackType { info, success, warning, error }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration? duration,
    SnackBarAction? action,
    bool persist = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Notifikasi monokrom editorial: status dibedakan lewat BENTUK IKON dan
    // kalimat, bukan lewat warna jenuh. Hanya status kritis yang diberi
    // isyarat merah bata redup agar tetap terbaca tanpa merusak ketenangan.
    final backgroundColor = OTColors.inverseSurface(isDark);
    final textColor = isDark ? OTColors.onInverseSurface : OTColors.surfaceLight;

    final Color accentColor;
    final IconData icon;

    switch (type) {
      case SnackType.success:
        accentColor = textColor;
        icon = Icons.check_circle_outline;
        break;
      case SnackType.warning:
        accentColor = textColor;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackType.error:
        accentColor = OTColors.destructiveDark; // Merah bata redup, bukan neon
        icon = Icons.error_outline;
        break;
      case SnackType.info:
        accentColor = textColor;
        icon = Icons.info_outline;
        break;
    }

    // Garis batas tetap hairline netral; hanya galat yang meninggalkan jejak warna.
    final borderColor = type == SnackType.error
        ? accentColor.withValues(alpha: 0.45)
        : OTColors.onInverseSurface.withValues(alpha: 0.18);

    final effectiveDuration = duration ??
        (type == SnackType.error
            ? const Duration(seconds: 4)
            : type == SnackType.warning
                ? const Duration(seconds: 3)
                : const Duration(milliseconds: 2600));

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: BorderSide(
            color: borderColor,
            width: 0.8,
          ),
        ),
        duration: effectiveDuration,
        persist: persist,
        dismissDirection: DismissDirection.horizontal,
        action: action,
      ),
    );

    // Safeguard timeout: jamin snackbar selalu tertutup otomatis setelah durasi habis,
    // bahkan jika ada persistensi bawaan framework saat action != null atau service aksesibilitas aktif.
    if (!persist) {
      Timer(effectiveDuration + const Duration(milliseconds: 200), () {
        try {
          messenger.clearSnackBars();
        } catch (_) {}
      });
    }
  }

  static void hide(BuildContext context) {
    try {
      ScaffoldMessenger.of(context).clearSnackBars();
    } catch (_) {}
  }

  static void clear(BuildContext context) {
    try {
      ScaffoldMessenger.of(context).clearSnackBars();
    } catch (_) {}
  }

  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    bool persist = false,
  }) =>
      show(
        context,
        message: message,
        type: SnackType.success,
        duration: duration,
        action: action,
        persist: persist,
      );

  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    bool persist = false,
  }) =>
      show(
        context,
        message: message,
        type: SnackType.error,
        duration: duration,
        action: action,
        persist: persist,
      );

  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    bool persist = false,
  }) =>
      show(
        context,
        message: message,
        type: SnackType.warning,
        duration: duration,
        action: action,
        persist: persist,
      );

  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    bool persist = false,
  }) =>
      show(
        context,
        message: message,
        type: SnackType.info,
        duration: duration,
        action: action,
        persist: persist,
      );
}

