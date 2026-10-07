import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/scholarly_answer.dart';
import 'package:intl/intl.dart' show Bidi;
import '../core/design/native_fonts.dart';
import '../core/localization.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/bookmark_content.dart';
import '../core/design/native_design.dart';
import '../core/design/ot_spacing.dart';
import '../core/note_clipboard_content.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/note_editor_sheet.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
/// Focused reading surface: the archive list remains an index, not an editor.
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
              child: Text(AppCopy.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppCopy.delete)),
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

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = NativeColors.canvas(isDark);
    final primary = NativeColors.textPrimary(isDark);
    final secondary = NativeColors.textSecondary(isDark);
    final displayTitle = _item.documentKind == BookmarkDocumentKind.aiAnswer
        ? aiAnswerTitle(_item.fullAnswer, _item.agentTitle)
        : _item.title;
    final displayContent = _item.documentKind == BookmarkDocumentKind.aiAnswer
        ? readableAiAnswerMarkdown(_item.fullAnswer)
        : (_item.fullAnswer.isEmpty ? _item.arabicExcerpt : _item.fullAnswer);
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        title: Text(AppCopy.savedCollection),
        actions: [
          IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: AppCopy.copyContentTooltip,
              onPressed: _copy),
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
        child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SelectionArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.xl),
                    children: [
                      Text(_kindLabel(_item),
                          style: NativeFonts.outfit(
                              fontSize: OTFontSize.s11,
                              fontWeight: FontWeight.w700,
                              color: secondary,
                              letterSpacing: .6)),
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection:
                            Bidi.detectRtlDirectionality(displayTitle)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                        child: Text(
                          displayTitle,
                          style: Bidi.detectRtlDirectionality(displayTitle)
                              ? NativeFonts.scheherazadeNew(
                                  fontSize: OTFontSize.s26,
                                  height: 1.7,
                                  fontWeight: FontWeight.w600,
                                  color: primary)
                              : NativeFonts.newsreader(
                                  fontSize: OTFontSize.s26,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: primary),
                        ),
                      ),
                      if (_item.agentTitle.isNotEmpty &&
                          _item.documentKind == BookmarkDocumentKind.aiAnswer &&
                          !displayTitle.toLowerCase().contains(_item.agentTitle
                              .replaceFirst(
                                  RegExp(r'^AI\s+', caseSensitive: false), '')
                              .toLowerCase())) ...[
                        const SizedBox(height: 10),
                        Text(
                          _item.agentTitle.replaceFirst(
                              RegExp(r'^AI\s+', caseSensitive: false), ''),
                          style: NativeFonts.outfit(
                              fontSize: OTFontSize.s14, color: secondary),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Divider(color: secondary.withValues(alpha: .25)),
                      const SizedBox(height: 20),
                      ScholarlyAnswer(text: displayContent, ink: primary, muted: secondary),
                      if (_item.citations.isNotEmpty) ...[
                        const SizedBox(height: OTSpacing.xl),
                        Divider(color: secondary.withValues(alpha: .25)),
                        const SizedBox(height: OTSpacing.base),
                        Text(Loc.tr('sourceReferences'),
                            style: NativeFonts.outfit(
                                fontSize: OTFontSize.s12,
                                fontWeight: FontWeight.w700,
                                color: secondary,
                                letterSpacing: .6)),
                        const SizedBox(height: OTSpacing.sm),
                        for (final citation in _item.citations)
                          Padding(
                            padding: const EdgeInsets.only(bottom: OTSpacing.sm),
                            child: Directionality(
                              textDirection: Bidi.detectRtlDirectionality(
                                      citation.display)
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Text(citation.display,
                                  style: RegExp(r'[\u0600-\u06FF]')
                                          .hasMatch(citation.display)
                                      ? NativeFonts.scheherazadeNew(
                                          fontSize: OTFontSize.s18,
                                          height: 1.85,
                                          color: primary)
                                      : NativeFonts.outfit(
                                          fontSize: OTFontSize.s14,
                                          height: 1.5,
                                          color: primary)),
                            ),
                          ),
                      ],
                    ],
                  ),
                ))),
      ),
    );
  }

  String _kindLabel(BookmarkModel item) => switch (item.documentKind) {
        BookmarkDocumentKind.personalNote => AppCopy.navSaved,
        BookmarkDocumentKind.aiAnswer => item.agentTitle.isNotEmpty
            ? item.agentTitle
                .replaceFirst(RegExp(r'^AI\s+', caseSensitive: false), '')
            : (item.fieldName.isNotEmpty ? item.fieldName : AppCopy.studySpace),
        BookmarkDocumentKind.bookReference => AppCopy.bookReferenceLabel,
      };
}
