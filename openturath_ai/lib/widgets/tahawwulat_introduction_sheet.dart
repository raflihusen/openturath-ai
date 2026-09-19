import '../core/l10n/app_dictionary.dart';
import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'editorial.dart';

/// Concise introduction drawn from the existing Tahawwulat curriculum.
class TahawwulatIntroductionSheet extends StatelessWidget {
  const TahawwulatIntroductionSheet({super.key, this.agent,
    this.onSelectSubAgent, this.onOpenMain});
  final AgentModel? agent;
  final void Function(SubAgentModel subAgent)? onSelectSubAgent;
  final VoidCallback? onOpenMain;

  static Future<void> show(BuildContext context, {AgentModel? agent,
    void Function(SubAgentModel subAgent)? onSelectSubAgent, VoidCallback? onOpenMain}) {
    return showModalBottomSheet<void>(context: context, isScrollControlled: true,
      useSafeArea: true, backgroundColor: Colors.transparent,
      builder: (_) => TahawwulatIntroductionSheet(agent: agent,
        onSelectSubAgent: onSelectSubAgent, onOpenMain: onOpenMain));
  }

  static const _books = <(String, String)>[
    ('An-Nubżah aṣ-Ṣughrā', 'النُّبْذَةُ الصُّغْرَى'),
    ("Dawā’ir al-I’ādah", 'دَوَائِرُ الإِعَادَةِ'),
    ('Al-Iqlīd', 'الإِقْلِيدُ فِي فَتْحِ أَبْوَابِ العُلُومِ'),
    ('At-Talīd wat-Ṭarīf', 'التَّلِيدُ وَالطَّارِفُ'),
    ('Al-Mukhtaṣar al-Ḥabīk / Siyāḥatul Fikr', 'المُخْتَصَرُ الحَبِيك'),
    ('Al-Usūs wal-Munṭalaqāt', 'الأُسُسُ وَالمُنْطَلَقَاتُ'),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final body = OTTypography.body(color: OTColors.textSecondary(dark));
    final roles = agent?.subAgents ?? const <SubAgentModel>[];
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .88, maxWidth: 760),
      decoration: BoxDecoration(color: OTColors.surface(dark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: SafeArea(top: false, child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(context.tr('membership.tahawwulat_intro'),
              style: OTTypography.corpusTitle(color: OTColors.textPrimary(dark)).copyWith(fontSize: 30))),
            IconButton(tooltip: context.tr('membership.close_intro'), onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const EditorialArabicText('فِقْهُ التَّحَوُّلَاتِ'),
          const SizedBox(height: 20),
          Text(context.tr('membership.tahawwulat_definition'), style: body),
          const SizedBox(height: 24),
          EditorialSection(title: context.tr('membership.study_direction'), child: Text(
            context.tr('membership.tahawwulat_method'), style: body)),
          const SizedBox(height: 20),
          ExpansionTile(tilePadding: EdgeInsets.zero,
            title: Text(context.tr('membership.six_books')),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final book in _books) Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(context.languageCode == 'ar' ? book.$2 : book.$1, style: OTTypography.bodyMedium(color: OTColors.textPrimary(dark))),
                if (context.languageCode != 'ar') EditorialArabicText(book.$2, fontSize: 22),
              ]))]),
          if (roles.isNotEmpty) ...[
            const SizedBox(height: 20),
            EditorialSection(title: context.tr('membership.choose_role'), child: Column(children: [
              for (final role in roles) EditorialRow(title: context.tr(role.name), subtitle: context.tr(role.description),
                onTap: onSelectSubAgent == null ? null : () {
                  Navigator.pop(context);
                  onSelectSubAgent!(role);
                }),
            ])),
          ],
          if (onOpenMain != null) ...[
            const SizedBox(height: 24),
            EditorialButton(label: context.tr('membership.open_study'), icon: Icons.arrow_forward_rounded,
              onPressed: () { Navigator.pop(context); onOpenMain!(); }),
          ],
        ]),
      )),
    );
  }
}
