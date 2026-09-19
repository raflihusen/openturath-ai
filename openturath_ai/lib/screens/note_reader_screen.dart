import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/l10n/app_dictionary.dart';
import '../core/scholarly_citation.dart';
import '../widgets/parallel_scholarly_view.dart';
import '../core/app_snackbar.dart';
import '../core/bookmark_content.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/note_clipboard_content.dart';
import '../core/note_display_title.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/editorial.dart';
import '../widgets/note_editor_sheet.dart';
import '../widgets/scholarly_markdown.dart';

class NoteReaderScreen extends StatefulWidget {
  const NoteReaderScreen({super.key, required this.item});
  final BookmarkModel item;
  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  late BookmarkModel _item = widget.item;
  bool _busy = false;
  bool _focusedReading = false;
  bool _parallel = false;
  late final String _owner;
  StreamSubscription<User?>? _authSubscription;
  bool _invalidSession = false;

  @override
  void initState() {
    super.initState();
    _owner = FirebaseAuth.instance.currentUser?.uid ?? 'guest_local';
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted && (user?.uid ?? 'guest_local') != _owner) {
        setState(() => _invalidSession = true);
      }
    });
  }

  bool get _ownerValid => !_invalidSession &&
      (FirebaseAuth.instance.currentUser?.uid ?? 'guest_local') == _owner;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _edit() async {
    if (!_ownerValid) return;
    final updated = await NoteEditorSheet.show(context, item: _item);
    if (updated != null && mounted) setState(() => _item = updated);
  }

  Future<void> _delete() async {
    if (!_ownerValid) return;
    final remove = await showDialog<bool>(context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('notes.deleteTitle')),
        content: Text(dialogContext.tr('notes.deleteBody')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(dialogContext.tr('notes.cancel'))),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(dialogContext.tr('notes.delete'))),
        ],
      ),
    );
    if (remove != true || !mounted || !_ownerValid) return;
    setState(() => _busy = true);
    try {
      await BookmarkService().deleteBookmark(_item.id, userId: _owner);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        AppSnackBar.show(context, message: context.tr('notes.deleteFailed'));
      }
    }
  }

  Future<void> _copy({required bool includeSource}) async {
    if (!_ownerValid) return;
    try {
      await Clipboard.setData(ClipboardData(text: noteClipboardText(_item, includeSource: includeSource, languageCode: context.languageCode)));
      if (mounted) AppSnackBar.success(context, context.tr('notes.copied'));
    } catch (_) {
      if (mounted) AppSnackBar.show(context,
          message: context.tr('notes.copyRetry'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_invalidSession) {
      return EditorialPage(title: context.tr('notes.title'), showBack: true,
        children: [EditorialEmptyState(title: context.tr('notes.session'),
          description: context.tr('notes.sessionBody'))]);
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = OTColors.textSecondary(dark);
    final isAi = _item.documentKind == BookmarkDocumentKind.aiAnswer;
    final title = noteDisplayTitle(_item, untitled: context.tr('notes.untitled'),
        translateLabel: (label) => context.tr(label));
    final raw = _item.fullAnswer.trim().isEmpty ? _item.arabicExcerpt : _item.fullAnswer;
    final content = isAi ? readableAiAnswerMarkdown(raw) : raw;
    final canCompare = _item.arabicExcerpt.trim().isNotEmpty &&
        _item.fullAnswer.trim().isNotEmpty && _item.arabicExcerpt.trim() != _item.fullAnswer.trim();
    final citation = ScholarlyCitation(book: _item.bookReference,
      author: _item.author, volume: _item.volume, page: _item.pageNumber,
      appUrl: _item.appUrl,
      verified: _item.verificationStatus == BookmarkVerificationStatus.verified);
    void exitReading() { if (_focusedReading) setState(() => _focusedReading = false); }
    final page = EditorialPage(
      title: _focusedReading ? null : context.tr('notes.title'),
      showBack: !_focusedReading, maxWidth: _parallel && canCompare ? 1120 : 720,
      trailing: PopupMenuButton<String>(
        tooltip: context.tr('notes.actions'), enabled: !_busy,
        onSelected: (value) {
          if (value == 'edit') _edit();
          if (value == 'delete') _delete();
          if (value == 'text') _copy(includeSource: false);
          if (value == 'source') _copy(includeSource: true);
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'text', child: Builder(builder: (menuContext) => Text(menuContext.tr('notes.textOnly')))),
          PopupMenuItem(value: 'source', child: Builder(builder: (menuContext) => Text(menuContext.tr('notes.withSource')))),
          PopupMenuItem(value: 'edit', child: Builder(builder: (menuContext) => Text(menuContext.tr('notes.editNote')))),
          PopupMenuItem(value: 'delete', child: Builder(builder: (menuContext) => Text(menuContext.tr('notes.deleteNote')))),
        ],
      ),
      children: [
        if (!_focusedReading) ...[
          Text(_kindLabel, style: OTTypography.sectionHeading(color: secondary)),
          const SizedBox(height: 14),
          if (ScholarlyMarkdown.containsArabic(title))
            EditorialArabicText(title, fontSize: 32)
          else
            Text(title, style: OTTypography.pageTitle().copyWith(fontSize: 32, height: 1.25)),
          const SizedBox(height: 12),
          Text(context.tr('notes.savedDate', args: {'date': _date(_item.createdAt)}),
            style: OTTypography.caption(color: secondary)),
          if (isAi) ...[
            const SizedBox(height: 12),
            Text(context.tr('notes.aiNotice'), style: OTTypography.caption(color: secondary)),
          ],
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: [
            EditorialButton(label: context.tr('notes.reading'), icon: Icons.chrome_reader_mode_outlined,
                secondary: true, onPressed: () => setState(() => _focusedReading = true)),
            if (canCompare) FilterChip(label: Text(context.tr('notes.parallel')),
              selected: _parallel, onSelected: (value) => setState(() => _parallel = value)),
          ]),
          const SizedBox(height: 12),
          Tooltip(message: context.tr('notes.letterMethod'), child: Text(
            context.tr('notes.letters', args: {'count': countScholarlyLetters(_parallel && canCompare ? '${_item.arabicExcerpt}\n${_item.fullAnswer}' : raw)}),
            style: OTTypography.caption(color: secondary))),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 28),
        ],
        if (content.trim().isEmpty)
          EditorialEmptyState(title: context.tr('notes.noBody'), description: context.tr('notes.noBodyHint'))
        else if (_parallel && canCompare)
          ParallelScholarlyView(arabicExcerpt: _item.arabicExcerpt,
              commentary: isAi ? readableAiAnswerMarkdown(_item.fullAnswer) : _item.fullAnswer,
              isAiCommentary: isAi)
        else
          ScholarlyMarkdown(data: content),
        if (_item.bookReference.trim().isNotEmpty) ...[
          const SizedBox(height: 16), const Divider(height: 1), const SizedBox(height: 20),
          ScholarlyMarkdown(data: citation.format(languageCode: context.languageCode)),
        ],
        if (!_focusedReading) ...[
          const SizedBox(height: 24),
          EditorialButton(label: context.tr('notes.editNote'), icon: Icons.edit_outlined,
            secondary: true, onPressed: _busy ? null : _edit),
        ],
        if (_focusedReading) const SizedBox(height: 88),
      ],
    );
    // Keep platform system bars unchanged, so disposal needs no global UI restore.
    return PopScope(canPop: !_focusedReading,
      onPopInvokedWithResult: (didPop, result) { if (!didPop) exitReading(); },
      child: CallbackShortcuts(bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): exitReading,
      }, child: Focus(autofocus: true, child: Stack(children: [
        page,
        if (_focusedReading) PositionedDirectional(bottom: 16, start: 16, end: 16,
          child: SafeArea(child: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: exitReading, icon: const Icon(Icons.close_rounded),
            label: Text(context.tr('notes.exitReading'))))),
      ]))),
    );
  }

  String get _kindLabel => context.tr(switch (_item.documentKind) {
    BookmarkDocumentKind.personalNote => 'notes.personal',
    BookmarkDocumentKind.aiAnswer => 'notes.analysis',
    BookmarkDocumentKind.bookReference => 'notes.bookReference',
  });

  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
}
