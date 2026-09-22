import 'package:flutter/material.dart';
import '../core/design/native_design.dart';
import '../core/localization.dart';

/// Applied to native route content, never above the shell's AI overlay.
class NativeTheme extends StatelessWidget {
  const NativeTheme({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;
    final ink = NativeColors.textPrimary(dark);
    final surface = NativeColors.surface(dark);
    return Theme(
        data: base.copyWith(
          scaffoldBackgroundColor: NativeColors.canvas(dark),
          textTheme: base.textTheme.apply(fontFamily: Loc.isArabic ? 'NativeArabic' : 'NativeInter', bodyColor: ink, displayColor: ink),
          colorScheme: base.colorScheme.copyWith(
              primary: NativeColors.accent(dark),
              onPrimary: NativeColors.onAccent(dark),
              surface: surface,
              onSurface: ink,
              outline: NativeColors.borderStrong(dark),
              outlineVariant: NativeColors.border(dark)),
          appBarTheme: base.appBarTheme.copyWith(
              backgroundColor: NativeColors.canvas(dark),
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleTextStyle: NativeType.title(dark, size: 26)),
          filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                  backgroundColor: NativeColors.actionFill(dark),
                  foregroundColor: NativeColors.onAccent(dark),
                  minimumSize: const Size(48, 48),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  textStyle: NativeType.body(dark, size: 17),
                  shape: const StadiumBorder(),
                  elevation: 0)),
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                  foregroundColor: NativeColors.accent(dark),
                  minimumSize: const Size(48, 48),
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: NativeType.body(dark, size: 15))),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: ink,
                  minimumSize: const Size(48, 48),
                  textStyle: NativeType.body(dark, size: 14))),
          iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48), foregroundColor: ink)),
          dividerTheme: DividerThemeData(
              color: NativeColors.border(dark), thickness: .8, space: 1),
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)))),
        ),
        child: child);
  }
}
