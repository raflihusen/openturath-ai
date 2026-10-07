import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/answer_direction.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/scholarly_fonts.dart';

/// One shared reading surface for chat and saved answers. Paragraphs retain
/// Markdown and their own base direction; embedded images cannot make requests.
class ScholarlyAnswer extends StatelessWidget {
  const ScholarlyAnswer(
      {super.key, required this.text, required this.ink, required this.muted});
  final String text;
  final Color ink;
  final Color muted;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final block in answerDisplayBlocks(text))
            if (block.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: OTSpacing.md),
                child: Directionality(
                  textDirection: answerDirection(block),
                  child: MarkdownBody(
                    data: isolateArabicPhrases(block),
                    selectable: true,
                    sizedImageBuilder: (config) => Text(config.alt ?? ''),
                    styleSheet: MarkdownStyleSheet(
                      p: answerDirection(block) == TextDirection.rtl
                          ? ScholarlyFonts.scheherazadeNew(
                              fontSize: OTFontSize.s22,
                              height: 1.85,
                              color: ink)
                          : ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s16,
                                  height: 1.7,
                                  color: ink)
                              .copyWith(
                                  fontFamilyFallback: const ['NativeArabic']),
                      strong:
                          TextStyle(fontWeight: FontWeight.w700, color: ink),
                      h1: OTTypography.pageTitle(color: ink),
                      h2: OTTypography.screenTitle(color: ink),
                      h3: OTTypography.cardTitle(color: ink),
                      blockquote: OTTypography.body(color: muted),
                      blockquoteDecoration: BoxDecoration(
                          color: OTColors.surfaceSubtle(
                              Theme.of(context).brightness == Brightness.dark),
                          borderRadius: BorderRadius.circular(OTRadius.xs)),
                      blockquotePadding: const EdgeInsets.all(OTSpacing.base),
                    ),
                  ),
                ),
              ),
        ],
      );
}
