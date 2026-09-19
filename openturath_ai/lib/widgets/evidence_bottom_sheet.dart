import '../core/l10n/app_dictionary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_snackbar.dart';
import '../core/scholarly_citation.dart';
import 'parallel_scholarly_view.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import 'editorial.dart';
import 'scholarly_markdown.dart';

/// Renders supplied evidence without claiming a verification step took place.
/// Missing edition metadata is left missing; external fallback is a book search.
class EvidenceBottomSheet extends StatelessWidget {
  const EvidenceBottomSheet({
    super.key,
    required this.citationNumber,
    required this.bookName,
    required this.author,
    required this.pageNumber,
    required this.category,
    required this.arabicExcerpt,
    required this.explanation,
    this.externalUrl,
    this.volume,
    this.verified = false,
    this.isAiExplanation = false,
  });

  final int citationNumber;
  final String bookName;
  final String author;
  final String pageNumber;
  final String category;
  final String arabicExcerpt;
  final String explanation;
  final String? externalUrl;
  final String? volume;
  final bool verified, isAiExplanation;

  Uri? get _externalTarget {
    final supplied = externalUrl?.trim() ?? '';
    final uri = supplied.isNotEmpty
        ? Uri.tryParse(supplied)
        : bookName.trim().isNotEmpty
            ? Uri.https('shamela.ws', '/search', {'q': bookName.trim()})
            : null;
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty ||
        uri.userInfo.isNotEmpty || (uri.hasPort && uri.port != 443)) return null;
    return uri;
  }

  Future<void> _launchExternal(BuildContext context) async {
    final uri = _externalTarget;
    if (uri == null) return;
    final confirmed = await showDialog<bool>(context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('notes.openTitle')),
        content: SelectableText(uri.toString()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(dialogContext.tr('notes.cancel'))),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(dialogContext.tr('notes.openLink'))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        AppSnackBar.show(context, message: context.tr('notes.referenceFailed'));
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(context, message: context.tr('notes.referenceFailed'));
      }
    }
  }

  String _clipboardText(BuildContext context, {required bool includeExplanation}) {
    final citation = ScholarlyCitation(book: bookName, author: author,
      volume: volume, page: pageNumber, appUrl: externalUrl, verified: verified)
        .format(languageCode: context.languageCode);
    return <String>[
      if (arabicExcerpt.trim().isNotEmpty) arabicExcerpt.trim(),
      if (citation.isNotEmpty) citation,
      if (includeExplanation && category.trim().isNotEmpty)
        '${context.tr('notes.field')}: ${category.trim()}',
      if (includeExplanation && explanation.trim().isNotEmpty)
        '${context.tr(isAiExplanation ? 'notes.aiCommentary' : 'notes.commentary')}:\n${explanation.trim()}',
    ].join('\n\n');
  }

  Future<void> _copy(BuildContext context, {required bool full}) async {
    final text = _clipboardText(context, includeExplanation: full);
    if (text.isEmpty) return;
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        AppSnackBar.success(context, full ? context.tr('notes.referenceCopied') : context.tr('notes.excerptCopied'));
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(context, message: context.tr('notes.textCopyFailed'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = OTColors.textSecondary(dark);
    final target = _externalTarget;
    final hasExcerpt = arabicExcerpt.trim().isNotEmpty;
    final hasContent = _clipboardText(context, includeExplanation: true).isNotEmpty;
    return DraggableScrollableSheet(
      initialChildSize: .72, minChildSize: .40, maxChildSize: .94,
      builder: (context, scrollController) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: OTColors.canvas(dark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: OTColors.border(dark), width: .8),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SafeArea(top: false, child: ListView(
                controller: scrollController,
                padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 28),
                children: [
                  Center(child: Container(width: 32, height: 3,
                      decoration: BoxDecoration(color: OTColors.border(dark),
                          borderRadius: BorderRadius.circular(3)))),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: Semantics(header: true, child: Text(context.tr('notes.evidenceTitle'),
                        style: OTTypography.screenTitle()))),
                    IconButton(tooltip: context.tr('notes.closeReference'),
                      constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 22)),
                  ]),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  Text(citationNumber > 0 ? context.tr('notes.referenceNumber', args: {'number': citationNumber}) : context.tr('notes.reference'),
                      style: OTTypography.sectionHeading(color: secondary)),
                  const SizedBox(height: 12),
                  if (bookName.trim().isNotEmpty)
                    _scholarlyText(bookName, heading: true)
                  else
                    Text(context.tr('notes.bookMissing'), style: OTTypography.bookTitle()),
                  const SizedBox(height: 20),
                  if (author.trim().isNotEmpty) _metadata(context.tr('notes.author'), author, secondary),
                  if (pageNumber.trim().isNotEmpty) _metadata(context.tr('notes.page'), pageNumber, secondary),
                  if (category.trim().isNotEmpty) _metadata(context.tr('notes.field'), category, secondary),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  if (hasExcerpt || explanation.trim().isNotEmpty)
                    ParallelScholarlyView(arabicExcerpt: arabicExcerpt,
                      commentary: explanation, isAiCommentary: isAiExplanation),
                  if (!hasExcerpt && explanation.trim().isEmpty)
                    EditorialEmptyState(title: context.tr('notes.excerptMissing'),
                        description: context.tr('notes.metadataNotice')),
                  const SizedBox(height: 20),
                  if (hasExcerpt) ...[
                    EditorialButton(label: context.tr('notes.copyExcerpt'), icon: Icons.copy_outlined,
                        expanded: true, onPressed: () => _copy(context, full: false)),
                    const SizedBox(height: 10),
                  ],
                  if (hasContent && (explanation.trim().isNotEmpty || !hasExcerpt)) ...[
                    EditorialButton(label: context.tr('notes.copyFull'), secondary: true,
                        expanded: true, onPressed: () => _copy(context, full: true)),
                    const SizedBox(height: 10),
                  ],
                  if (target != null)
                    EditorialButton(label: externalUrl?.trim().isNotEmpty == true
                        ? context.tr('notes.openReference') : context.tr('notes.searchShamela'),
                      secondary: true, expanded: true, icon: Icons.open_in_new_rounded,
                      onPressed: () => _launchExternal(context)),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metadata(String label, String value, Color secondary) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(label, style: OTTypography.caption(color: secondary)),
      const SizedBox(height: 4),
      _scholarlyText(value),
    ]),
  );

  Widget _scholarlyText(String value, {bool heading = false}) => SelectableText(
    value,
    textDirection: ScholarlyMarkdown.directionOf(value),
    style: ScholarlyMarkdown.containsArabic(value)
        ? OTTypography.arabicReading(height: 1.95).copyWith(fontSize: heading ? 28 : 22)
        : heading ? OTTypography.pageTitle().copyWith(height: 1.35)
            : OTTypography.body().copyWith(fontSize: 15, height: 1.6),
  );
}
