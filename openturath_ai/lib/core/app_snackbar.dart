import 'package:flutter/material.dart';

import 'theme.dart';

enum SnackType { info, success, warning, error }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration? duration,
    SnackBarAction? action,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sesuai DESIGN.md (The Quiet Scholar):
    // Gunakan elevated surface gelap monokromatis yang berwibawa di kedua tema,
    // teks putih tajam, dan aksen warna HANYA pada ikon 20dp & border hairline 0.8dp.
    final backgroundColor = isDark ? const Color(0xFF1E1E22) : const Color(0xFF18181B);
    const textColor = Colors.white;

    Color accentColor;
    IconData icon;

    switch (type) {
      case SnackType.success:
        accentColor = const Color(0xFF34D399); // Emerald lembut
        icon = Icons.check_circle_rounded;
        break;
      case SnackType.warning:
        accentColor = const Color(0xFFFBBF24); // Amber tenang
        icon = Icons.info_outline_rounded;
        break;
      case SnackType.error:
        accentColor = const Color(0xFFF87171); // Rose lembut
        icon = Icons.error_outline_rounded;
        break;
      case SnackType.info:
        accentColor = const Color(0xFF94A3B8); // Slate monokrom
        icon = Icons.info_outline_rounded;
        break;
    }

    final effectiveDuration = duration ??
        (type == SnackType.error
            ? const Duration(seconds: 4)
            : type == SnackType.warning
                ? const Duration(seconds: 3)
                : const Duration(milliseconds: 2200));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
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
            color: accentColor.withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        duration: effectiveDuration,
        action: action,
      ),
    );
  }

  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) =>
      show(context, message: message, type: SnackType.success, duration: duration, action: action);

  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) =>
      show(context, message: message, type: SnackType.error, duration: duration, action: action);

  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) =>
      show(context, message: message, type: SnackType.warning, duration: duration, action: action);

  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) =>
      show(context, message: message, type: SnackType.info, duration: duration, action: action);
}
