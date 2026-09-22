import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/design/native_design.dart';
import 'native_components.dart';

class SpecialistCard extends StatelessWidget {
  const SpecialistCard(
      {super.key,
      required this.title,
      required this.onOpen,
      this.scopeLabel,
      this.referenceLabel,
      this.titleArabic,
      this.emoji,
      this.icon,
      this.statusLabel,
      this.onOpenLibrary});
  final String title;
  final String? scopeLabel, referenceLabel, titleArabic, emoji, statusLabel;
  final IconData? icon;
  final VoidCallback? onOpen, onOpenLibrary;
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final name = Loc.isArabic && titleArabic?.isNotEmpty == true
        ? titleArabic!
        : Loc.text(title);
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: NativeColors.border(dark)))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            NativePress(
                onTap: onOpen,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(name,
                                    style: NativeType.title(dark, size: 19)),
                                if (scopeLabel?.isNotEmpty == true) ...[
                                  const SizedBox(height: 6),
                                  Text(Loc.text(scopeLabel!),
                                      style: NativeType.meta(dark)),
                                ],
                                if (statusLabel != null) ...[
                                  const SizedBox(height: 10),
                                  Text(statusLabel!,
                                      style: NativeType.meta(dark)),
                                ],
                              ])),
                          const SizedBox(width: 12),
                          Icon(Icons.chevron_right_rounded,
                              color: NativeColors.textSecondary(dark)),
                        ]))),
            if (onOpenLibrary != null)
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                  child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                          onPressed: onOpenLibrary,
                          icon: const Icon(Icons.menu_book_outlined, size: 18),
                          label: Text(NativeCopy.text('sources'))))),
          ]),
        ));
  }
}
