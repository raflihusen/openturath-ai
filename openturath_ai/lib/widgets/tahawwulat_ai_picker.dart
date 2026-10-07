import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../models/sub_agent_model.dart';
import 'tahawwulat_hero.dart';

/// A deliberate entry into the five complementary Tahawwulat study tools.
class TahawwulatAiPicker {
  static Future<void> show(
    BuildContext context, {
    required List<SubAgentModel> agents,
    required void Function(SubAgentModel) onSelect,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        constraints: const BoxConstraints(maxWidth: 760),
        shape: RoundedRectangleBorder(borderRadius: OTRadius.sheetBorder),
        builder: (ctx) {
          final dark = Theme.of(ctx).brightness == Brightness.dark;
          final ink = OTColors.textPrimary(dark);
          const icons = [
            Icons.manage_search_rounded,
            Icons.lightbulb_outline_rounded,
            Icons.quiz_outlined,
            Icons.mic_none_rounded,
            Icons.edit_note_rounded
          ];
          return SafeArea(
              child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * .85),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        reviewCopy(
                            'AI Fikih Tahawwulat',
                            'الذكاء الاصطناعي لفقه التحولات',
                            'Fiqh Tahawwulat AI'),
                        style: OTTypography.screenTitle(color: ink)),
                    const SizedBox(height: 8),
                    Text(
                        reviewCopy(
                            'Pilih AI sesuai tujuan telaah Anda.',
                            'اختر الأداة المناسبة لغرض دراستك.',
                            'Choose an AI for your study purpose.'),
                        style: OTTypography.body(
                            color: OTColors.textSecondary(dark))),
                    const SizedBox(height: 24),
                    for (var i = 0; i < agents.length; i++) ...[
                      Semantics(
                          button: true,
                          child: Material(
                            color: OTColors.surfaceSubtle(dark),
                            borderRadius: OTRadius.cardBorder,
                            child: InkWell(
                                borderRadius: OTRadius.cardBorder,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onSelect(agents[i]);
                                },
                                child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(children: [
                                      Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                              color: OTColors.surface(dark),
                                              borderRadius:
                                                  OTRadius.inputBorder),
                                          child: Icon(icons[i % icons.length],
                                              color: ink)),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(agents[i].name,
                                                style: OTTypography.bodyMedium(
                                                    color: ink)),
                                            const SizedBox(height: 4),
                                            Text(
                                                reviewCopy(
                                                    const [
                                                      'Telusuri teks kitab dan ibarah rujukan.',
                                                      'Pahami konsep dan istilah dengan penjelasan ringkas.',
                                                      'Uji pemahaman melalui latihan interaktif.',
                                                      'Telusuri arsip muhadarah Habib Abu Bakar.',
                                                      'Susun bahan dakwah dan khutbah.'
                                                    ][i % 5],
                                                    agents[i].descriptionArabic,
                                                    const [
                                                      'Explore source texts and book references.',
                                                      'Understand concepts through concise explanations.',
                                                      'Test your understanding with interactive exercises.',
                                                      'Explore Habib Abu Bakar’s lecture archive.',
                                                      'Prepare material for talks and sermons.'
                                                    ][i % 5]),
                                                style: OTTypography.caption(
                                                    color:
                                                        OTColors.textSecondary(
                                                            dark))),
                                          ])),
                                      const SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded,
                                          color: ink, size: 18),
                                    ]))),
                          )),
                      if (i < agents.length - 1) const SizedBox(height: 12),
                    ],
                  ]),
            ),
          ));
        },
      );
}
