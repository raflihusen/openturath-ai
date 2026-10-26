import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'ot_popup_menu.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    return PopupMenuButton<String>(
      tooltip: Loc.tr('language'),
      initialValue: Loc.language,
      icon: const Icon(Icons.translate_rounded, size: 22),
      onSelected: (language) async {
        try {
          await AppConfig.setLocale(language);
        } catch (_) {
          // The chosen language remains active even if local persistence fails.
        }
      },
      itemBuilder: (_) => Loc.languageNames.entries
          .map(
            (entry) => OTPopupMenuItem<String>(
                value: entry.key,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                      width: 24,
                      child: entry.key == Loc.language
                          ? const Icon(Icons.check_rounded, size: 18)
                          : null),
                  Text(entry.value,
                      style: entry.key == 'ar'
                          ? ScholarlyFonts.scheherazadeNew(height: 1.85)
                          : null,
                      textDirection: entry.key == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr),
                ])),
          )
          .toList(),
    );
  }
}
