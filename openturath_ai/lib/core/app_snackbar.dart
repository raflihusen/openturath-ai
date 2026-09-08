import 'package:flutter/material.dart';

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

    Color backgroundColor;
    Color foregroundColor;
    IconData icon;

    switch (type) {
      case SnackType.success:
        backgroundColor = isDark ? const Color(0xFF0F392B) : const Color(0xFFE6F4EA);
        foregroundColor = isDark ? const Color(0xFF81C995) : const Color(0xFF137333);
        icon = Icons.check_circle_rounded;
        break;
      case SnackType.warning:
        backgroundColor = isDark ? const Color(0xFF3B2F0F) : const Color(0xFFFEF7E0);
        foregroundColor = isDark ? const Color(0xFFFDD663) : const Color(0xFFB06000);
        icon = Icons.warning_amber_rounded;
        break;
      case SnackType.error:
        backgroundColor = isDark ? const Color(0xFF3C1B1B) : const Color(0xFFFCE8E6);
        foregroundColor = isDark ? const Color(0xFFF28B82) : const Color(0xFFC5221F);
        icon = Icons.error_outline_rounded;
        break;
      case SnackType.info:
        backgroundColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE8F0FE);
        foregroundColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1A73E8);
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
            Icon(icon, color: foregroundColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
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
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: foregroundColor.withValues(alpha: 0.25),
            width: 1,
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
