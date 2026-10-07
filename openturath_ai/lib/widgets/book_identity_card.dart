import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/scholarly_fonts.dart';
import '../core/answer_direction.dart';
import '../core/design/ot_radius.dart';
import 'ot_motion_widgets.dart';

/// One bibliographic identity, shared by the collection and canonical catalogs.
class BookIdentityCard extends StatelessWidget {
  const BookIdentityCard(
      {super.key,
      required this.title,
      required this.author,
      required this.facts,
      required this.onTap,
      this.deathLabel});
  final String title, author;
  final List<String> facts;
  final String? deathLabel;
  final VoidCallback onTap;

  bool get hasAuthorDate => RegExp(r'[0-9٠-٩]').hasMatch(author);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        final ink = OTColors.textPrimary(dark),
            muted = OTColors.textSecondary(dark);
        final rtl = answerDirection(title) == TextDirection.rtl;
        final identity = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  textDirection: answerDirection(title),
                  textAlign: rtl ? TextAlign.right : TextAlign.left,
                  maxLines: box.hasBoundedHeight ? 3 : null,
                  overflow: box.hasBoundedHeight
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible,
                  style: rtl
                      ? ScholarlyFonts.scheherazadeNew(
                          fontSize: OTFontSize.s22,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: ink)
                      : OTTypography.screenTitle(color: ink)),
              const SizedBox(height: 8),
              Text(author,
                  textDirection: answerDirection(author),
                  textAlign: answerDirection(author) == TextDirection.rtl
                      ? TextAlign.right
                      : TextAlign.left,
                  maxLines: box.hasBoundedHeight ? 2 : null,
                  overflow: box.hasBoundedHeight
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible,
                  style: answerDirection(author) == TextDirection.rtl
                      ? ScholarlyFonts.scheherazadeNew(
                          fontSize: OTFontSize.s16, height: 1.5, color: muted)
                      : OTTypography.caption(color: muted)),
            ]);
        final factsView = Wrap(
            alignment: rtl ? WrapAlignment.end : WrapAlignment.start,
            spacing: 8, runSpacing: 8, children: [
          for (final fact in facts)
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: OTColors.surfaceSubtle(dark),
                    borderRadius: OTRadius.pillBorder),
                child: Text(fact,
                    textDirection: answerDirection(fact),
                    style: OTTypography.caption(color: muted))),
        ]);
        final dateView = deathLabel != null && !hasAuthorDate
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(deathLabel!,
                    textDirection: TextDirection.ltr,
                    style: OTTypography.caption(color: muted)))
            : const SizedBox.shrink();
        final textIdentity = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [identity, dateView]);
        return Padding(
            padding: EdgeInsets.only(bottom: box.hasBoundedHeight ? 0 : 12),
            child: OTBentoTile(
              onTap: onTap,
              semanticLabel: '$title, $author',
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    textIdentity,
                    if (facts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Divider(height: 1, color: OTColors.borderSubtle(dark)),
                      const SizedBox(height: 12),
                      factsView,
                    ],
                  ]),
            ));
      });
}
