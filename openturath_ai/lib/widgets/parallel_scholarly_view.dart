import 'package:flutter/material.dart';
import '../core/l10n/app_dictionary.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import 'scholarly_markdown.dart';

/// The stored source passage and commentary are independent texts. The second
/// pane is never described as a historical sharh merely because it was saved.
class ParallelScholarlyView extends StatelessWidget {
  const ParallelScholarlyView({super.key, required this.arabicExcerpt,
    required this.commentary, this.isAiCommentary = false});
  final String arabicExcerpt, commentary;
  final bool isAiCommentary;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget panel(String title, Widget content) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: OTColors.surfaceSubtle(dark),
        border: Border.all(color: OTColors.border(dark)),
        borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Semantics(header: true, child: Text(title,
          style: OTTypography.sectionHeading(color: OTColors.textSecondary(dark)))),
        const SizedBox(height: 16), content,
      ]),
    );
    final source = panel(context.tr('notes.excerpt'), SelectableText(
      arabicExcerpt, textDirection: TextDirection.rtl, textAlign: TextAlign.start,
      style: OTTypography.arabicReading(height: 1.95)
          .copyWith(fontSize: 26, fontStyle: FontStyle.normal)));
    final explanation = panel(context.tr(isAiCommentary
        ? 'notes.aiCommentary' : 'notes.commentary'), ScholarlyMarkdown(data: commentary));
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 760 || MediaQuery.textScalerOf(context).scale(16) > 24) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (arabicExcerpt.trim().isNotEmpty) source,
          if (arabicExcerpt.trim().isNotEmpty && commentary.trim().isNotEmpty)
            const SizedBox(height: 20),
          if (commentary.trim().isNotEmpty) explanation,
        ]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (arabicExcerpt.trim().isNotEmpty) Expanded(child: source),
        if (arabicExcerpt.trim().isNotEmpty && commentary.trim().isNotEmpty)
          const SizedBox(width: 24),
        if (commentary.trim().isNotEmpty) Expanded(child: explanation),
      ]);
    });
  }
}
