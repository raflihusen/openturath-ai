import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/app_copy.dart';
import '../core/design/native_design.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'native_components.dart';
import 'native_theme.dart';
import 'openturath_brand.dart';
import 'tahawwulat_introduction_sheet.dart';

class TahawwulatFlagshipCard extends StatelessWidget {
  const TahawwulatFlagshipCard(
      {super.key,
      required this.agent,
      required this.isSubscribed,
      required this.onOpenMain,
      required this.onOpenSubAgent,
      this.onOpenLibrary,
      this.onOpenIntroduction});
  final AgentModel agent;
  final bool isSubscribed;
  final VoidCallback onOpenMain;
  final ValueChanged<SubAgentModel> onOpenSubAgent;
  final VoidCallback? onOpenLibrary;
  final VoidCallback? onOpenIntroduction;

  void _explore(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => NativeTheme(
                child: TahawwulatCollectionPage(
              agent: agent,
              isSubscribed: isSubscribed,
              onOpenMain: () {
                Navigator.of(context).pop();
                onOpenMain();
              },
              onOpenSubAgent: (sub) {
                Navigator.of(context).pop();
                onOpenSubAgent(sub);
              },
              onOpenLibrary: onOpenLibrary == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      onOpenLibrary!();
                    },
              onOpenIntroduction: onOpenIntroduction,
            ))));
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return NativeSection(
        collection: true,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            OpenTurathMark(size: 24, color: NativeColors.textPrimary(dark)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(NativeCopy.text('exclusive'),
                    style: NativeType.meta(dark))),
            if (isSubscribed)
              Tooltip(
                  message: NativeCopy.text('active'),
                  child: Icon(Icons.check_circle_outline,
                      size: 20, color: NativeColors.accent(dark))),
          ]),
          const SizedBox(height: 12),
          Text(AppCopy.planTahawwulat, style: NativeType.title(dark, size: 24)),
          const SizedBox(height: 6),
          Text(NativeCopy.text('chooseRole'), style: NativeType.meta(dark)),
          const SizedBox(height: 8),
          Wrap(spacing: 4, runSpacing: 0, children: [
            for (final sub in agent.subAgents ?? <SubAgentModel>[])
              TextButton(
                  onPressed: () => onOpenSubAgent(sub),
                  child: Text(sub.name,
                      style: NativeType.body(dark, size: 13)
                          .copyWith(color: NativeColors.accent(dark)))),
          ]),
          const Divider(height: 12),
          Wrap(spacing: 8, children: [
            TextButton(
                onPressed: () => _explore(context),
                child: Text(NativeCopy.text('explore'))),
            TextButton(
                onPressed: onOpenMain,
                child: Text(NativeCopy.text(isSubscribed ? 'open' : 'access'))),
          ]),
        ]));
  }
}

class TahawwulatCollectionPage extends StatelessWidget {
  const TahawwulatCollectionPage(
      {super.key,
      required this.agent,
      required this.isSubscribed,
      required this.onOpenMain,
      required this.onOpenSubAgent,
      this.onOpenLibrary,
      this.onOpenIntroduction});
  final AgentModel agent;
  final bool isSubscribed;
  final VoidCallback onOpenMain;
  final ValueChanged<SubAgentModel> onOpenSubAgent;
  final VoidCallback? onOpenLibrary;
  final VoidCallback? onOpenIntroduction;

  static const roleIcons = <String, IconData>{
    'muhaqqiq': Icons.find_in_page_outlined,
    'bayan': Icons.lightbulb_outline,
    'mukhtabir': Icons.quiz_outlined,
    'habib': Icons.mic_none_rounded,
    'khatib': Icons.edit_note_rounded,
  };

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final roles = agent.subAgents ?? <SubAgentModel>[];
    return Scaffold(
      backgroundColor: NativeColors.canvas(dark),
      appBar: AppBar(
          backgroundColor: NativeColors.canvas(dark),
          title:
              Text(NativeCopy.text('exclusive'), style: NativeType.meta(dark))),
      body: SafeArea(
          top: false,
          child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      NativeEntrance(
                          child: NativeSection(
                              collection: true,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OpenTurathMark(
                                      size: 42,
                                      color: NativeColors.brass(dark)),
                                  const SizedBox(height: 16),
                                  Text(agent.titleArabic,
                                      textDirection: TextDirection.rtl,
                                      style: NativeType.arabic(dark, size: 36)),
                                  if (!Loc.isArabic)
                                    Text(AppCopy.planTahawwulat,
                                        style:
                                            NativeType.title(dark, size: 30)),
                                  const SizedBox(height: 8),
                                  Text(NativeCopy.text('lineage'),
                                      style: NativeType.meta(dark)),
                                  const SizedBox(height: 16),
                                  Text(NativeCopy.text('collectionBody'),
                                      style: NativeType.body(dark)),
                                  const SizedBox(height: 20),
                                  FilledButton(
                                      onPressed: onOpenMain,
                                      child: Text(isSubscribed
                                          ? NativeCopy.text('open')
                                          : NativeCopy.text('access'))),
                                ],
                              ))),
                      const SizedBox(height: 32),
                      Text(NativeCopy.text('fivePaths'),
                          style: NativeType.title(dark, size: 24)),
                      const SizedBox(height: 8),
                      Text(NativeCopy.text('chooseRole'),
                          style: NativeType.meta(dark)),
                      const SizedBox(height: 16),
                      NativeSection(
                          padding: EdgeInsets.zero,
                          child: Column(children: [
                            for (var i = 0; i < roles.length; i++) ...[
                              if (i != 0)
                                Divider(
                                    height: 1,
                                    indent: 20,
                                    endIndent: 20,
                                    color: NativeColors.border(dark)),
                              NativePress(
                                  label:
                                      '${roles[i].name}. ${NativeCopy.role(roles[i].id)}',
                                  onTap: () => onOpenSubAgent(roles[i]),
                                  child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Icon(
                                                    roleIcons[roles[i]
                                                            .id
                                                            .split('_')
                                                            .last] ??
                                                        Icons
                                                            .menu_book_outlined,
                                                    color: NativeColors.brass(
                                                        dark),
                                                    size: 24)),
                                            const SizedBox(width: 16),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(roles[i].name,
                                                      style: NativeType.title(
                                                          dark,
                                                          size: 22)),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                      NativeCopy.role(
                                                          roles[i].id),
                                                      style: NativeType.meta(
                                                          dark)),
                                                ])),
                                            const SizedBox(width: 8),
                                            const Icon(
                                                Icons.chevron_right_rounded,
                                                size: 20),
                                          ]))),
                            ],
                          ])),
                      const SizedBox(height: 24),
                      if (onOpenLibrary != null)
                        OutlinedButton.icon(
                            onPressed: onOpenLibrary,
                            icon: const Icon(Icons.menu_book_outlined),
                            label: Text(NativeCopy.text('sources'))),
                      TextButton(
                          onPressed: onOpenIntroduction ??
                              () => TahawwulatIntroductionSheet.show(context,
                                  agent: agent,
                                  onSelectSubAgent: onOpenSubAgent,
                                  onOpenMain: onOpenMain),
                          child: Text(NativeCopy.text('intro'))),
                      const SizedBox(height: 12),
                      Text(NativeCopy.text('studyReminder'),
                          style: NativeType.meta(dark),
                          textAlign: TextAlign.center),
                    ]),
              ))),
    );
  }
}
