import '../core/l10n/app_dictionary.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/arabic_utils.dart';
import '../core/bookmark_content.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/note_clipboard_content.dart';
import '../core/note_display_title.dart';
import '../core/routes.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../services/canonical_library_service.dart';
import '../widgets/editorial.dart';
import '../widgets/note_editor_sheet.dart';
import '../widgets/scholarly_markdown.dart';
import 'note_reader_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});
  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final _service = BookmarkService();
  final _search = TextEditingController();
  StreamSubscription<User?>? _authSubscription;
  List<BookmarkModel> _items = [];
  BookmarkDocumentKind? _kind;
  bool _loading = true;
  bool _syncing = false;
  String? _error;
  int _request = 0;
  int _visibleCount = 40;
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'guest_local';

  @override
  void initState() {
    super.initState();
    _service.addListener(_reload);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      if (!mounted) return;
      ++_request;
      setState(() { _items = []; _loading = true; _error = null; });
      _reload();
    });
    _reload();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _service.removeListener(_reload);
    _search.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final generation = ++_request;
    final owner = _uid;
    try {
      final items = await _service.getBookmarks(userId: owner);
      if (!mounted || generation != _request || owner != _uid) return;
      setState(() {
        _items = items..sort((a, b) => b.effectiveTime.compareTo(a.effectiveTime));
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (mounted && generation == _request) {
        setState(() { _loading = false; _error = 'notes.loadFailed'; });
      }
    }
  }

  Future<void> _sync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      await _service.syncWithCloud();
      await _reload();
    } catch (_) {
      if (mounted) setState(() => _error = 'notes.syncFailed');
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _edit([BookmarkModel? item]) async {
    await NoteEditorSheet.show(context, item: item);
    if (mounted) await _reload();
  }

  Future<void> _open(BookmarkModel item) async {
    final owner = _uid;
    if (item.documentKind == BookmarkDocumentKind.bookReference && item.id.startsWith('book_')) {
      try {
        final library = CanonicalLibraryService.instance;
        final books = library.cachedSyafiiBooks ?? await library.loadSyafiiCatalog();
        final matches = books.where((b) => b.editionId == item.id.substring(5));
        if (!mounted || owner != _uid) return;
        if (matches.isNotEmpty) {
          await Navigator.of(context).pushNamed(AppRoutes.bookDetail, arguments: matches.first);
          return;
        }
      } catch (_) {
        // The stored note remains readable when its catalog is unavailable.
      }
    }
    if (!mounted || owner != _uid) return;
    await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => NoteReaderScreen(item: item)));
    if (mounted) await _reload();
  }

  Future<void> _copy(BookmarkModel item) async {
    try {
      await Clipboard.setData(ClipboardData(text: noteClipboardText(item, includeSource: true, languageCode: context.languageCode)));
      if (mounted) _message(context.tr('notes.copied'));
    } catch (_) { if (mounted) _message(context.tr('notes.copyFailed')); }
  }

  Future<void> _delete(BookmarkModel item) async {
    final owner = _uid;
    final confirmed = await showDialog<bool>(context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('notes.deleteTitle')),
        content: Text(dialogContext.tr('notes.deleteBody')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(dialogContext.tr('notes.cancel'))),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(dialogContext.tr('notes.delete'))),
        ],
      ));
    if (confirmed != true || owner != _uid) return;
    try {
      await _service.deleteBookmark(item.id, userId: owner);
      if (mounted) _message(context.tr('notes.deleted'));
    } catch (_) { if (mounted) _message(context.tr('notes.deleteFailed')); }
  }

  void _message(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  List<BookmarkModel> get _filtered => _items.where((item) {
    if (_kind != null && item.documentKind != _kind) return false;
    final q = _search.text.trim();
    return q.isEmpty || [item.title, item.fullAnswer, item.arabicExcerpt,
      item.bookReference, item.agentTitle].any((text) => ArabicUtils.matches(text, q));
  }).toList();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = OTColors.textSecondary(dark);
    final items = _filtered;
    return EditorialPage(
      title: context.tr('notes.title'), eyebrow: context.tr('notes.privateSpace'), maxWidth: 900,
      subtitle: context.tr('notes.subtitle'),
      trailing: IconButton(tooltip: context.tr('notes.sync'),
          onPressed: _syncing ? null : _sync,
          icon: _syncing ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 1.5))
              : const Icon(Icons.sync_rounded, size: 22)),
      children: [
        EditorialButton(label: context.tr('notes.write'), icon: Icons.add_rounded,
            onPressed: () => _edit()),
        const SizedBox(height: 24),
        EditorialSearchField(controller: _search, hintText: context.tr('notes.search'),
            onChanged: (_) => setState(() => _visibleCount = 40)),
        const SizedBox(height: 16),
        SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Row(children: [
            _filter(null, context.tr('notes.all')),
            _filter(BookmarkDocumentKind.personalNote, context.tr('notes.title')),
            _filter(BookmarkDocumentKind.aiAnswer, context.tr('notes.analysis')),
            _filter(BookmarkDocumentKind.bookReference, context.tr('notes.references')),
          ])),
        const SizedBox(height: 24),
        if (_error != null) ...[
          EditorialEmptyState(title: context.tr(_error!), action:
              EditorialButton(label: context.tr('notes.retry'), secondary: true, onPressed: _sync)),
          const SizedBox(height: 20),
        ],
        if (_loading)
          const Padding(padding: EdgeInsets.all(48), child: Center(
              child: CircularProgressIndicator(strokeWidth: 1.5)))
        else if (items.isEmpty)
          EditorialEmptyState(
            title: _items.isEmpty ? context.tr('notes.emptyTitle') : context.tr('notes.noMatch'),
            description: _items.isEmpty
                ? context.tr('notes.emptyBody')
                : context.tr('notes.noMatchBody'),
            action: _items.isEmpty ? EditorialButton(label: context.tr('notes.first'),
                secondary: true, onPressed: () => _edit()) : null,
          )
        else ...[
          Text(context.tr('notes.savedCount', args: {'count': items.length}), style: OTTypography.caption(color: secondary)),
          const SizedBox(height: 12),
          for (final item in items.take(_visibleCount)) _noteRow(item, secondary),
          if (items.length > _visibleCount) ...[
            const SizedBox(height: 24),
            EditorialButton(label: context.tr('notes.more'), secondary: true,
                onPressed: () => setState(() => _visibleCount += 40)),
          ],
        ],
      ],
    );
  }

  Widget _filter(BookmarkDocumentKind? value, String label) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 8),
    child: ChoiceChip(label: Text(label), selected: _kind == value,
      showCheckmark: false, materialTapTargetSize: MaterialTapTargetSize.padded,
      onSelected: (_) => setState(() { _kind = value; _visibleCount = 40; })),
  );

  Widget _noteRow(BookmarkModel item, Color secondary) {
    final isAi = item.documentKind == BookmarkDocumentKind.aiAnswer;
    final title = noteDisplayTitle(item, untitled: context.tr('notes.untitled'),
        translateLabel: (label) => context.tr(label));
    final preview = (isAi ? parseAiAnswerContent(item.fullAnswer).preview
        : item.fullAnswer.isNotEmpty ? item.fullAnswer : item.arabicExcerpt)
        .replaceAll(RegExp(r'[#*>`_]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: InkWell(onTap: () => _open(item),
          borderRadius: BorderRadius.circular(8),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('${_label(item.documentKind)} · ${_date(item.effectiveTime)}',
                  style: OTTypography.caption(color: secondary)),
              const SizedBox(height: 8),
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  textDirection: ScholarlyMarkdown.directionOf(title),
                  style: ScholarlyMarkdown.containsArabic(title)
                      ? OTTypography.arabicReading(height: 1.9).copyWith(fontSize: 24)
                      : OTTypography.bookTitle().copyWith(fontSize: 21, height: 1.3)),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis,
                    textDirection: ScholarlyMarkdown.directionOf(preview),
                    style: ScholarlyMarkdown.containsArabic(preview)
                        ? OTTypography.arabicReading(color: secondary, height: 1.9)
                        : OTTypography.body(color: secondary)),
              ],
            ])))),
        Padding(padding: const EdgeInsets.only(top: 10),
          child: PopupMenuButton<String>(tooltip: context.tr('notes.actions'),
            onSelected: (value) {
              if (value == 'edit') _edit(item);
              if (value == 'copy') _copy(item);
              if (value == 'delete') _delete(item);
            }, itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Builder(builder: (menuContext) => Text(menuContext.tr('notes.edit')))),
              PopupMenuItem(value: 'copy', child: Builder(builder: (menuContext) => Text(menuContext.tr('notes.copy')))),
              PopupMenuItem(value: 'delete', child: Builder(builder: (menuContext) => Text(menuContext.tr('notes.delete')))),
            ])),
      ]),
      const Divider(height: 1),
    ]);
  }

  String _label(BookmarkDocumentKind value) => switch (value) {
    BookmarkDocumentKind.personalNote => context.tr('notes.personal'),
    BookmarkDocumentKind.aiAnswer => context.tr('notes.analysis'),
    BookmarkDocumentKind.bookReference => context.tr('notes.bookReference'),
  };
  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
}
