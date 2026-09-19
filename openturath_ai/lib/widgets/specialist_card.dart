import '../core/l10n/app_dictionary.dart';
import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import 'editorial.dart';

/// Compact directory entry; details stay available without crowding the list.
class SpecialistCard extends StatelessWidget {
  const SpecialistCard({super.key, required this.title, this.scopeLabel,
    required this.onOpen, this.titleArabic, this.emoji, this.icon,
    this.statusLabel, this.onOpenLibrary});
  final String title;
  final String? scopeLabel, titleArabic, emoji, statusLabel;
  final IconData? icon;
  final VoidCallback? onOpen, onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: OTColors.border(dark)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        EditorialRow(
          title: context.tr(title),
          subtitle: statusLabel == null ? null : context.tr(statusLabel!),
          onTap: onOpen,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (onOpenLibrary != null) IconButton(
              tooltip: context.tr('membership.library_title', args: {'title': context.tr(title)}), onPressed: onOpenLibrary,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.menu_book_outlined, size: 20)),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ]),
        ),
        if ((scopeLabel?.isNotEmpty ?? false) || (titleArabic?.isNotEmpty ?? false))
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(context.tr('membership.about_assistant'), style: OTTypography.caption(color: OTColors.textSecondary(dark))),
            childrenPadding: const EdgeInsets.only(bottom: 20),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (titleArabic?.isNotEmpty ?? false) EditorialArabicText(titleArabic!),
              if (scopeLabel?.isNotEmpty ?? false) Text(context.tr(scopeLabel!), style: OTTypography.body(color: OTColors.textSecondary(dark))),
            ],
          ),
      ]),
    );
  }
}
