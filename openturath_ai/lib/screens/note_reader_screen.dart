import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/bookmark_content.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_layout.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/note_clipboard_content.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/note_editor_sheet.dart';

class NoteReaderScreen extends StatefulWidget {
  const NoteReaderScreen({super.key, required this.item});

  final BookmarkModel item;

  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  late BookmarkModel _item = widget.item;

  Future<void> _edit() async {
    final updated = await NoteEditorSheet.show(context, item: _item);
    if (updated != null && mounted) setState(() => _item = updated);
  }

  Future<void> _delete() async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppCopy.deleteNoteTitle),
        content: Text(AppCopy.deleteNoteDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppCopy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppCopy.delete),
          ),
        ],
      ),
    );
    if (remove != true) return;
    await BookmarkService().deleteBookmark(_item.id);
    if (mounted) Navigator.pop(context, true);
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: noteClipboardText(_item)));
    AppSnackBar.success(context, AppCopy.noteContentCopied);
  }

  String _sourceLabel() {
    if (_item.documentKind == BookmarkDocumentKind.personalNote) {
      return 'Catatan pribadi';
    }
    if (_item.documentKind == BookmarkDocumentKind.bookReference) {
      return 'Rujukan kitab';
    }
    final source = _item.agentTitle
        .replaceFirst(RegExp(r'^AI\s+', caseSensitive: false), '')
        .trim();
    return source.isEmpty ? 'Hasil kajian' : source;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = OTColors.textPrimary(dark);
    final secondary = OTColors.textSecondary(dark);
    final subtle = OTColors.surfaceSubtle(dark);
    final title = _item.documentKind == BookmarkDocumentKind.aiAnswer
        ? aiAnswerTitle(_item.fullAnswer, _item.agentTitle)
        : _item.title;
    final content = _item.documentKind == BookmarkDocumentKind.aiAnswer
        ? readableAiAnswerMarkdown(_item.fullAnswer)
        : (_item.fullAnswer.isEmpty ? _item.arabicExcerpt : _item.fullAnswer);

    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      appBar: AppBar(
        title: const Text('Catatan'),
        backgroundColor: OTColors.canvas(dark),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: AppCopy.copyContentTooltip,
            onPressed: _copy,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _edit();
              if (value == 'delete') _delete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(AppCopy.editNote)),
              PopupMenuItem(value: 'delete', child: Text(AppCopy.deleteNote)),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SelectionArea(
          child: OTConstrainedContent(
            child: ListView(
              padding: const EdgeInsets.only(
                top: OTSpacing.md,
                bottom: OTSpacing.xl,
              ),
              children: [
                Text(title, style: OTTypography.pageTitle(color: primary)),
                const SizedBox(height: OTSpacing.sm),
                Text(
                  _sourceLabel(),
                  style: OTTypography.caption(color: secondary),
                ),
                const SizedBox(height: OTSpacing.lg),
                Divider(color: OTColors.border(dark)),
                const SizedBox(height: OTSpacing.lg),
                MarkdownBody(
                  data: content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: OTTypography.readingBody(color: primary),
                    h1: OTTypography.pageTitle(color: primary)
                        .copyWith(fontSize: 25),
                    h2: OTTypography.sectionTitle(color: primary)
                        .copyWith(fontSize: 20),
                    blockquote: OTTypography.body(color: secondary).copyWith(
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      color: subtle,
                      border: Border(
                        left: BorderSide(color: secondary, width: 3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
