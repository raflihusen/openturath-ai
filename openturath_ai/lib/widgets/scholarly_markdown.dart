import '../core/l10n/app_dictionary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';

/// A reading surface with independent bidi contexts for prose blocks. Fenced
/// code is kept intact; Arabic glyphs are never slanted or line-height clipped.
class ScholarlyMarkdown extends StatelessWidget {
  const ScholarlyMarkdown({super.key, required this.data});
  final String data;

  static bool containsArabic(String text) =>
      RegExp(r'[\u0600-\u06ff\u0750-\u077f\u08a0-\u08ff]').hasMatch(text);

  static TextDirection directionOf(String text) {
    final first = RegExp(r'[A-Za-z\u0620-\u064a\u066e-\u06d3]')
        .firstMatch(text)?.group(0);
    return first != null && containsArabic(first)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  // Keep list continuations, tables and fenced code together. A paragraph
  // boundary otherwise starts a new bidi context rather than flipping a page.
  static List<String> blocks(String data) {
    final result = <String>[];
    final current = <String>[];
    String? fence;
    for (final line in data.split('\n')) {
      final marker = RegExp(r'^\s*(`{3,}|~{3,})').firstMatch(line)?.group(1);
      if (marker != null) {
        if (fence == null) {
          fence = marker[0];
        } else if (marker[0] == fence) {
          fence = null;
        }
      }
      if (line.trim().isEmpty && fence == null && current.isNotEmpty &&
          !RegExp(r'^\s*(?:[-*+] |\d+\. |>)').hasMatch(current.first)) {
        result.add(current.join('\n'));
        current.clear();
      } else {
        current.add(line);
      }
    }
    if (current.join().trim().isNotEmpty) result.add(current.join('\n'));
    return result;
  }

  Future<void> _openLink(BuildContext context, String? href) async {
    final uri = Uri.tryParse(href ?? '');
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('notes.linkFailed'))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('notes.linkFailed'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks(data).map((block) {
        final arabic = containsArabic(block);
        final direction = directionOf(block);
        final body = arabic
            ? OTTypography.arabicReading(color: ink, height: 1.95)
                .copyWith(fontSize: 24, fontStyle: FontStyle.normal,
                    fontFamilyFallback: const ['Inter'])
            : OTTypography.body(color: ink).copyWith(fontSize: 16, height: 1.8,
                fontFamilyFallback: const ['Scheherazade New']);
        final heading = arabic
            ? body.copyWith(fontWeight: FontWeight.w600)
            : OTTypography.pageTitle(color: ink).copyWith(height: 1.35);
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Directionality(
            textDirection: direction,
            child: MarkdownBody(
              data: block,
              selectable: true,
              onTapLink: (text, href, title) => _openLink(context, href),
              // Notes must not silently fetch tracking pixels or external media.
              // ignore: deprecated_member_use
              imageBuilder: (uri, title, alt) => Text(
                alt?.isNotEmpty == true ? context.tr('notes.imageAlt', args: {'alt': alt ?? ''}) : context.tr('notes.image'),
                style: OTTypography.caption(color: OTColors.textSecondary(dark)),
              ),
              styleSheet: MarkdownStyleSheet(
                p: body,
                h1: heading,
                h2: heading.copyWith(fontSize: arabic ? 26 : 24),
                h3: heading.copyWith(fontSize: arabic ? 25 : 21),
                h4: heading.copyWith(fontSize: arabic ? 24 : 19),
                h5: heading.copyWith(fontSize: arabic ? 24 : 18),
                h6: heading.copyWith(fontSize: arabic ? 24 : 17),
                em: body.copyWith(fontStyle:
                    arabic ? FontStyle.normal : FontStyle.italic),
                strong: body.copyWith(fontWeight: FontWeight.w600),
                blockquote: body.copyWith(fontStyle: FontStyle.normal),
                a: body.copyWith(decoration: TextDecoration.underline),
                listBullet: body,
                tableBody: body,
                blockquotePadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                blockquoteDecoration: BoxDecoration(
                  color: OTColors.surfaceSubtle(dark),
                  border: BorderDirectional(start: BorderSide(
                      color: OTColors.border(dark), width: 2)),
                ),
                code: TextStyle(fontFamily: 'monospace', fontSize: 13,
                    color: ink, height: 1.7),
                codeblockDecoration: BoxDecoration(
                    color: OTColors.surfaceSubtle(dark),
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
