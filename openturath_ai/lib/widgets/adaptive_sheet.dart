import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_platform.dart';

/// Keeps mobile sheets while giving desktop forms a bounded, centered surface.
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
  ShapeBorder? shape,
  bool useRootNavigator = false,
  bool enableDrag = true,
  bool isDismissible = true,
  bool? showDragHandle,
}) {
  if (!AppPlatform.isDesktop) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      shape: shape,
      useRootNavigator: useRootNavigator,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      showDragHandle: showDragHandle,
    );
  }
  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: isDismissible,
    builder: (dialogContext) => Dialog(
      backgroundColor: backgroundColor,
      insetPadding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 560),
      // Dialog sungguhan di desktop: keempat sudut membulat dan isi diklip.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final height = math.min(760.0, constraints.maxHeight);
        final width = math.min(560.0, constraints.maxWidth);
        final content = MediaQuery(
          data: media.copyWith(size: Size(width, height)),
          child: Builder(builder: builder),
        );
        return SizedBox(
          width: width,
          height: isScrollControlled ? height : null,
          child: isScrollControlled
              ? content
              : SingleChildScrollView(child: content),
        );
      }),
    ),
  );
}
