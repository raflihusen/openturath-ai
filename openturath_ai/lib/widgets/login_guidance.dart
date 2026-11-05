import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/design/ot_colors.dart';
import 'legal_document_sheet.dart';

/// Explains the app and Google boundaries without changing authentication.
class LoginGuidance extends StatelessWidget {
  const LoginGuidance({super.key, this.compact = false, this.color});
  final bool compact;
  final Color? color;

  void _details(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: Text(Loc.tr('loginStagesTitle')),
              content: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final key in [
                    'loginStageOneTitle',
                    'loginStageOneBody',
                    'loginStageTwoTitle',
                    'loginStageTwoBody',
                    'loginGoogleSecurityDetails',
                    'loginPrivacyFacts',
                    'loginOptionalContinue'
                  ])
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(Loc.tr(key))),
                  TextButton(
                      onPressed: () =>
                          LegalDocumentSheet.showPrivacyPolicy(dialogContext),
                      child: Text(Loc.tr('privacyPolicy'))),
                ],
              )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(MaterialLocalizations.of(dialogContext)
                        .closeButtonLabel))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final ink = color ??
        OTColors.textPrimary(Theme.of(context).brightness == Brightness.dark);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!compact) ...[
        Text(Loc.tr('loginStageOneTitle'),
            style: TextStyle(color: ink, fontWeight: FontWeight.w600)),
        Text(Loc.tr('loginStageOneBody'),
            style: TextStyle(color: ink, fontSize: 13)),
        const SizedBox(height: 8),
        Text(Loc.tr('loginStageTwoTitle'),
            style: TextStyle(color: ink, fontWeight: FontWeight.w600)),
      ],
      Text(Loc.tr('loginStageTwoBody'),
          style: TextStyle(color: ink, fontSize: 13)),
      const SizedBox(height: 8),
      Text(Loc.tr('loginGoogleSecurityShort'),
          style: TextStyle(color: ink, fontSize: 13)),
      if (!compact) ...[
        const SizedBox(height: 8),
        Text(Loc.tr('loginPrivacyShort'),
            style: TextStyle(color: ink, fontSize: 13)),
      ],
      TextButton(
          onPressed: () => _details(context),
          style: TextButton.styleFrom(foregroundColor: ink),
          child: Text(Loc.tr('loginGuidanceDetails'))),
    ]);
  }
}
