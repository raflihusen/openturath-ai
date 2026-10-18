import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_platform.dart';

import 'package:openturath_ai/core/design/ot_radius.dart';

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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OTRadius.card)),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final height = math.min(760.0, constraints.maxHeight);
        final width = math.min(560.0, constraints.maxWidth);
        final content = MediaQuery(
          data: media.copyWith(size: Size(width, height)),
          child: Builder(builder: builder),
        );
        // Tinggi mengikuti isi sampai batas jendela: lembar pendek tidak
        // menyisakan ruang kosong, lembar panjang tetap bisa digulir.
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height),
          child: SizedBox(
            width: width,
            child: isScrollControlled
                ? content
                : SingleChildScrollView(child: content),
          ),
        );
      }),
    ),
  );
}

/// Pegangan seret di puncak lembar bawah. Di desktop lembar tampil sebagai
/// dialog yang tidak bisa diseret, jadi pegangan tidak digambar.
class SheetGrabber extends StatelessWidget {
  const SheetGrabber({super.key, this.top = 0, this.bottom = 0});

  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    if (AppPlatform.isDesktop) return const SizedBox.shrink();
    return Container(
      width: 36,
      height: 4,
      margin: EdgeInsets.only(top: top, bottom: bottom),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .onSurfaceVariant
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(OTRadius.xs),
      ),
    );
  }
}
