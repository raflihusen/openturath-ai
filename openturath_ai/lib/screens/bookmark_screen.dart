import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/arabic_utils.dart';
import '../core/bookmark_content.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_layout.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/navigation_guard.dart';
import '../core/routes.dart';
import '../models/book_model.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../services/canonical_library_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/note_editor_sheet.dart';
import '../widgets/ot_mobile_primitives.dart';
import 'main_shell_screen.dart';
import 'note_reader_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<BookmarkModel> _allBookmarks = [];
  List<BookmarkModel> _filteredBookmarks = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _bookmarkService
      ..addListener(_onBookmarksChanged)
      ..syncWithCloud();
  }

  @override
  void dispose() {
    _bookmarkService.removeListener(_onBookmarksChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  String _bookmarkDiscipline(BookmarkModel item) {
    final assistant = item.agentTitle
        .replaceFirst(RegExp(r'^AI\s+', caseSensitive: false), '')
        .trim();
    if (assistant.isNotEmpty) return assistant;
    if (item.fieldName.trim().isNotEmpty &&
        !item.fieldName.toLowerCase().contains('catatan')) {
      return item.fieldName.trim();
    }
    if (item.bookReference.isNotEmpty) return 'Kitab';
    return 'Catatan pribadi';
  }

  List<String> get _categories {
    final values = _allBookmarks.map(_bookmarkDiscipline).toSet().toList()
      ..sort();
    return ['Semua', ...values];
  }

  Future<void> _loadBookmarks() async {
    final list = await _bookmarkService.getBookmarks();
    if (!mounted) return;
    setState(() {
      _allBookmarks = list;
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = 'Semua';
      }
      _filter();
      _isLoading = false;
    });
  }

  Future<void> _syncBookmarks() async {
    await _bookmarkService.syncWithCloud();
    await _loadBookmarks();
  }

  void _onBookmarksChanged() {
    if (mounted) _loadBookmarks();
  }

  void _filter() {
    final query = _searchQuery.trim().toLowerCase();
    _filteredBookmarks = _allBookmarks.where((item) {
      if (_selectedCategory != 'Semua' &&
          _bookmarkDiscipline(item) != _selectedCategory) {
        return false;
      }
      if (query.isEmpty) return true;
      return ArabicUtils.matches(item.title, query) ||
          ArabicUtils.matches(item.agentTitle, query) ||
          ArabicUtils.matches(item.bookReference, query) ||
          ArabicUtils.matches(item.arabicExcerpt, query) ||
          ArabicUtils.matches(item.fullAnswer, query);
    }).toList();
  }

  Future<void> _openEditor([BookmarkModel? item]) async {
    final updated = await NoteEditorSheet.show(context, item: item);
    if (updated != null && mounted) await _loadBookmarks();
  }

  Future<void> _openItem(BookmarkModel item) async {
    if (item.id.startsWith('book_')) {
      final editionId = item.id.replaceFirst('book_', '');
      var books = CanonicalLibraryService.instance.cachedSyafiiBooks;
      try {
        books ??= await CanonicalLibraryService.instance.loadSyafiiCatalog();
      } catch (_) {}
      final book = books?.firstWhere(
        (entry) => entry.editionId == editionId,
        orElse: () => CanonicalBookPresentation(
          editionId: editionId,
          titleArabic: item.title,
          authorArabic: item.author ?? '',
        ),
      );
      if (book != null && mounted) {
        NavigationGuard.safePushNamed(
          context,
          AppRoutes.bookDetail,
          arguments: book,
        );
        return;
      }
    }

    if (!mounted) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NoteReaderScreen(item: item)),
    );
    if (changed == true && mounted) await _loadBookmarks();
  }

  Future<void> _delete(BookmarkModel item) async {
    final confirmed = await showDialog<bool>(
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
    if (confirmed != true) return;
    await _bookmarkService.deleteBookmark(item.id);
    if (mounted) AppSnackBar.success(context, AppCopy.bookmarkDeleted);
  }

  void _copy(BookmarkModel item) {
    final content =
        item.arabicExcerpt.isNotEmpty ? item.arabicExcerpt : item.fullAnswer;
    Clipboard.setData(ClipboardData(text: content));
    AppSnackBar.success(context, AppCopy.noteContentCopied);
  }

  void _copyReference(BookmarkModel item) {
    final buffer = StringBuffer();
    if (item.arabicExcerpt.isNotEmpty) {
      buffer.writeln('“${item.arabicExcerpt}”');
      buffer.writeln();
    }
    if (item.bookReference.isNotEmpty) {
      buffer.write(item.bookReference);
      if (item.pageNumber.isNotEmpty) buffer.write(', hlm. ${item.pageNumber}');
    } else {
      buffer.write(item.title);
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppSnackBar.success(context, AppCopy.referenceCopied);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      appBar: AppBar(
        title: Text(AppCopy.savedCollection),
        backgroundColor: OTColors.canvas(dark),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: AppCopy.addNote,
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: OTConstrainedContent(
          maxWidth: OTLayout.catalogueWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OTSearchField(
                controller: _searchCtrl,
                hintText: 'Cari dalam catatan',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filter();
                  });
                },
              ),
              const SizedBox(height: OTSpacing.sm),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: OTSpacing.sm),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ChoiceChip(
                      label: Text(category),
                      selected: category == _selectedCategory,
                      onSelected: (_) {
                        OTMotion.selection();
                        setState(() {
                          _selectedCategory = category;
                          _filter();
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: OTSpacing.sm),
              Text(
                AppCopy.savedNotesCount(_filteredBookmarks.length),
                style: OTTypography.caption(
                  color: OTColors.textSecondary(dark),
                ),
              ),
              const SizedBox(height: OTSpacing.xs),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: AppLoader(title: 'Menyiapkan catatan…'),
                      )
                    : RefreshIndicator(
                        onRefresh: _syncBookmarks,
                        child: _filteredBookmarks.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  OTEmptyState(
                                    icon: Icons.bookmark_border_rounded,
                                    title: 'Belum ada catatan',
                                    message:
                                        'Simpan jawaban, rujukan kitab, atau tulis catatan Anda sendiri.',
                                    actionLabel: 'Mulai kajian',
                                    onAction: () =>
                                        MainShellController.of(context)
                                            ?.switchTab(1),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: const EdgeInsets.only(bottom: 108),
                                itemCount: _filteredBookmarks.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredBookmarks[index];
                                  return _NoteIndexRow(
                                    item: item,
                                    source: _bookmarkDiscipline(item),
                                    onOpen: () => _openItem(item),
                                    onEdit: () => _openEditor(item),
                                    onCopy: () => _copy(item),
                                    onCopyReference: () => _copyReference(item),
                                    onDelete: () => _delete(item),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteIndexRow extends StatelessWidget {
  const _NoteIndexRow({
    required this.item,
    required this.source,
    required this.onOpen,
    required this.onEdit,
    required this.onCopy,
    required this.onCopyReference,
    required this.onDelete,
  });

  final BookmarkModel item;
  final String source;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onCopyReference;
  final VoidCallback onDelete;

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays == 1) return 'Kemarin';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _preview(String content) {
    return content
        .replaceAll(RegExp(r'[#*>`_~]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final title = item.documentKind == BookmarkDocumentKind.aiAnswer
        ? aiAnswerTitle(item.fullAnswer, item.agentTitle)
        : item.title;
    final content = item.documentKind == BookmarkDocumentKind.aiAnswer
        ? readableAiAnswerMarkdown(item.fullAnswer)
        : item.fullAnswer;

    return InkWell(
      onTap: onOpen,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: OTColors.border(dark)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: OTSpacing.base),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$source · ${_relativeTime(item.effectiveTime)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.caption(
                        color: OTColors.textSecondary(dark),
                      ),
                    ),
                    const SizedBox(height: OTSpacing.xs),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.cardTitle(
                        color: OTColors.textPrimary(dark),
                      ),
                    ),
                    if (content.trim().isNotEmpty) ...[
                      const SizedBox(height: OTSpacing.xs),
                      Text(
                        _preview(content),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OTTypography.caption(
                          color: OTColors.textSecondary(dark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Pilihan catatan',
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'copy':
                      onCopy();
                      break;
                    case 'reference':
                      onCopyReference();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'copy', child: Text('Salin isi')),
                  if (item.bookReference.isNotEmpty)
                    const PopupMenuItem(
                      value: 'reference',
                      child: Text('Salin rujukan'),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
