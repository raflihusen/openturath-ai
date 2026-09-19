import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n/app_dictionary.dart';
import '../core/l10n/language_notifier.dart';
import '../core/app_snackbar.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});
  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context, isScrollControlled: true, useSafeArea: true,
    builder: (_) => const LanguageSwitcher());
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    Future<void> save(Future<bool> result) async {
      if (!await result && context.mounted) {
        AppSnackBar.info(context, context.tr('locale.save_error'));
      }
    }
    return SafeArea(top: false, child: SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('locale.title'), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(context.tr('locale.description')),
          const SizedBox(height: 24),
          for (final language in AppLanguage.values)
            Semantics(selected: locale.language == language, child: ListTile(
              minVerticalPadding: 16, contentPadding: EdgeInsets.zero,
              title: Text(switch (language) {
                AppLanguage.id => 'Bahasa Indonesia', AppLanguage.en => 'English', AppLanguage.ar => 'العربية',
              }, textDirection: language == AppLanguage.ar ? TextDirection.rtl : TextDirection.ltr,
                style: language == AppLanguage.ar ? const TextStyle(fontFamily: 'Scheherazade New', height: 1.85) : null),
              trailing: locale.language == language ? const Icon(Icons.check_rounded) : null,
              onTap: () => save(ref.read(languageProvider.notifier).setLanguage(language)),
            )),
          const Divider(),
          SwitchListTile.adaptive(contentPadding: EdgeInsets.zero,
            title: Text(context.tr('locale.digits')),
            subtitle: Text(context.tr('locale.digits_help')),
            value: locale.easternArabicDigits,
            onChanged: (value) => save(ref.read(languageProvider.notifier).setEasternArabicDigits(value))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel))),
        ],
      ),
    ));
  }
}
