import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_snackbar.dart';
import '../core/daily_scholarly_gem.dart';
import '../core/hijri_date_utils.dart';
import '../core/l10n/app_dictionary.dart';
import 'editorial.dart';

class DailyGemCard extends StatefulWidget {
  const DailyGemCard({super.key});
  @override
  State<DailyGemCard> createState() => _DailyGemCardState();
}
class _DailyGemCardState extends State<DailyGemCard> with WidgetsBindingObserver {
  DateTime _date = DateTime.now();
  Timer? _midnight;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }
  void _schedule() {
    _midnight?.cancel();
    final now = DateTime.now();
    _midnight = Timer(DateTime(now.year, now.month, now.day + 1)
      .difference(now) + const Duration(seconds: 1), _refresh);
  }
  void _refresh() {
    if (!mounted) return;
    setState(() => _date = DateTime.now());
    _schedule();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
    if (state == AppLifecycleState.paused) _midnight?.cancel();
  }
  @override
  void dispose() {
    _midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  Future<void> _copy(DailyScholarlyGem gem) async {
    try {
      // Explicit excerpt marker: never imply this is the full narration.
      final text = '${context.tr('gem.excerpt')}\n${gem.copyWithSanad(context.languageCode)}';
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) AppSnackBar.success(context, context.tr('gem.copied'));
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.tr('gem.copy_error'));
    }
  }
  @override
  Widget build(BuildContext context) {
    final gem = DailyScholarlyGem.forDate(_date);
    return EditorialSection(title: context.tr('gem.heading'), child: EditorialCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.tr('date.estimated'), style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(HijriDateUtils.formatHijriOnly(_date)),
        const SizedBox(height: 24),
        Text(context.tr('gem.excerpt'), style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 12),
        EditorialArabicText(gem.excerpt, fontSize: 27),
        if (context.languageCode != 'ar') ...[
          const SizedBox(height: 16),
          Text(context.tr(gem.meaningKey), style: Theme.of(context).textTheme.bodyLarge),
        ],
        const SizedBox(height: 16),
        Text(gem.source(context.languageCode), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          EditorialButton(label: context.tr('gem.copy'), icon: Icons.copy_outlined,
            secondary: true, onPressed: () => _copy(gem)),
          TextButton(onPressed: () => showModalBottomSheet<void>(context: context,
            isScrollControlled: true, useSafeArea: true,
            builder: (context) => SafeArea(top: false, child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(context.tr('gem.sanad'), style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                EditorialArabicText(gem.sanad, fontSize: 21),
                const SizedBox(height: 16),
                Text(context.tr('gem.note')),
                const SizedBox(height: 16),
                TextButton(onPressed: () async {
                  try {
                    final opened = await launchUrl(Uri.parse(gem.sourceUrl), mode: LaunchMode.externalApplication);
                    if (!opened && context.mounted) AppSnackBar.info(context, context.tr('gem.open_error'));
                  } catch (_) {
                    if (context.mounted) AppSnackBar.info(context, context.tr('gem.open_error'));
                  }
                }, child: Text(gem.source(context.languageCode))),
                OutlinedButton(onPressed: () => Navigator.pop(context),
                  child: Text(MaterialLocalizations.of(context).closeButtonLabel)),
              ]),
            ))), child: Text(context.tr('gem.sanad'))),
        ]),
      ]),
    ));
  }
}
