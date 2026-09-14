import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_spacing.dart';
import '../core/note_clipboard_content.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/note_editor_sheet.dart';

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
        title: const Text('Hapus catatan?'),
        content: const Text('Catatan ini akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (remove != true) return;
    await BookmarkService().deleteBookmark(_item.id);
    if (mounted) Navigator.pop(context, true);
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: noteClipboardText(_item)));
    AppSnackBar.success(context, 'Isi catatan disalin.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final primary = OTColors.textPrimary(isDark);
    final secondary = OTColors.textSecondary(isDark);
    final subtle = OTColors.surfaceSubtle(isDark);
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        title: Text('Catatan',
            style: GoogleFonts.newsreader(
                color: primary, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: 'Salin isi',
              onPressed: _copy),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _edit();
              if (value == 'delete') _delete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit catatan')),
              PopupMenuItem(value: 'delete', child: Text('Hapus catatan')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.xl),
            children: [
              Text(_kindLabel(_item.documentKind),
                  style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: secondary,
                      letterSpacing: .6)),
              const SizedBox(height: 8),
              Text(_item.title,
                  style: GoogleFonts.newsreader(
                      fontSize: 29,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: primary)),
              const SizedBox(height: 10),
              Text(_item.agentTitle,
                  style: GoogleFonts.outfit(fontSize: 13, color: secondary)),
              const SizedBox(height: 20),
              Divider(color: secondary.withValues(alpha: .25)),
              const SizedBox(height: 20),
              MarkdownBody(
                data: _item.fullAnswer.isEmpty
                    ? _item.arabicExcerpt
                    : _item.fullAnswer,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.outfit(
                      fontSize: 16, height: 1.72, color: primary),
                  h1: GoogleFonts.newsreader(
                      fontSize: 25,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: primary),
                  h2: GoogleFonts.newsreader(
                      fontSize: 20,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: primary),
                  blockquote: GoogleFonts.outfit(
                      fontSize: 15,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                      color: secondary),
                  blockquoteDecoration: BoxDecoration(
                      color: subtle,
                      border:
                          Border(left: BorderSide(color: secondary, width: 3))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _kindLabel(BookmarkDocumentKind kind) => switch (kind) {
        BookmarkDocumentKind.personalNote => 'CATATAN PRIBADI',
        BookmarkDocumentKind.aiAnswer => 'JAWABAN AI',
        BookmarkDocumentKind.bookReference => 'RUJUKAN KITAB',
      };
}
