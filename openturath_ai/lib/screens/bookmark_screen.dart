import '../core/localization.dart';
import '../widgets/native_theme.dart';
import '../widgets/native_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/design/native_fonts.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/arabic_utils.dart';
import '../core/bookmark_content.dart';
import '../core/design/native_design.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_colors.dart';
import '../core/navigation_guard.dart';
import '../core/routes.dart';
import '../models/bookmark_model.dart';
import '../models/book_model.dart';
import '../services/bookmark_service.dart';
import '../services/canonical_library_service.dart';
import '../widgets/note_editor_sheet.dart';
import 'note_reader_screen.dart';
import '../widgets/ot_motion_widgets.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_buttons.dart';

import '../widgets/ot_components.dart';
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
  bool _showSearch = false;

  String _bookmarkDiscipline(BookmarkModel b) {
    if (b.agentTitle.isNotEmpty) {
      return b.agentTitle
          .replaceFirst(RegExp(r'^AI\s+', caseSensitive: false), '')
          .trim();
    }
    if (b.fieldName.isNotEmpty &&
        !b.fieldName.toLowerCase().contains('catatan')) {
      return b.fieldName.trim();
    }
    if (b.bookReference.isNotEmpty) {
      return 'Kitab';
    }
    return 'Catatan';
  }

  List<String> get _categories {
    final disciplines = <String>{};
    for (final b in _allBookmarks) {
      final disc = _bookmarkDiscipline(b);
      if (disc.isNotEmpty) {
        disciplines.add(disc);
      }
    }
    if (disciplines.isEmpty) {
      return const [
        'Semua',
        'Fikih Syafi\'i',
        'Fikih Tahawwulat',
        'Hadis',
        'Tafsir',
      ];
    }
    return ['Semua', ...disciplines];
  }

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _bookmarkService.addListener(_onBookmarksChanged);
    _bookmarkService.syncWithCloud();
  }

  Future<void> _syncBookmarks() async {
    await _bookmarkService.syncWithCloud();
    await _loadBookmarks();
  }

  void _onBookmarksChanged() {
    if (mounted) {
      _loadBookmarks();
    }
  }

  @override
  void dispose() {
    _bookmarkService.removeListener(_onBookmarksChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final list = await _bookmarkService.getBookmarks();
    if (mounted) {
      setState(() {
        _allBookmarks = list;
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'Semua';
        }
        _filter();
        _isLoading = false;
      });
    }
  }

  void _filter() {
    final q = _searchQuery.toLowerCase().trim();
    _filteredBookmarks = _allBookmarks.where((b) {
      if (_selectedCategory != 'Semua') {
        final disc = _bookmarkDiscipline(b).toLowerCase();
        final sel = _selectedCategory.toLowerCase();
        if (disc != sel &&
            !b.agentTitle.toLowerCase().contains(sel) &&
            !b.fieldName.toLowerCase().contains(sel)) {
          return false;
        }
      }
      if (q.isEmpty) return true;
      return ArabicUtils.matches(b.title, q) ||
          ArabicUtils.matches(b.agentTitle, q) ||
          ArabicUtils.matches(b.bookReference, q) ||
          ArabicUtils.matches(b.arabicExcerpt, q) ||
          ArabicUtils.matches(b.fullAnswer, q);
    }).toList();
  }

  Future<void> _deleteBookmark(BookmarkModel item) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = NativeColors.surface(isDark);
    final textPrimary = NativeColors.textPrimary(isDark);
    final textSecondary = NativeColors.textSecondary(isDark);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
          title: Text(
            AppCopy.deleteNoteTitle,
            style: OTTypography.screenTitle(color: textPrimary)
                .copyWith(fontSize: OTFontSize.s18),
          ),
          content: Text(
            AppCopy.deleteNoteDesc,
            style: OTTypography.body(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                AppCopy.cancel,
                style: OTTypography.button(color: textSecondary),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: OTButtons.destructive(isDark),
              child: Text(
                AppCopy.delete,
                style:
                    OTTypography.button(color: NativeColors.onAccent(isDark)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _bookmarkService.deleteBookmark(item.id);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppCopy.bookmarkDeleted,
          action: SnackBarAction(
            label: AppCopy.undo,
            textColor: NativeColors.accent(isDark),
            onPressed: () => _bookmarkService.addBookmark(item),
          ),
        );
      }
    }
  }

  void _copyIbarah(String ibarah) {
    OTMotion.light();
    Clipboard.setData(ClipboardData(text: ibarah));
    AppSnackBar.success(context, AppCopy.ibarahCopied);
  }

  void _shareBookmark(BookmarkModel item) {
    final buffer = StringBuffer();
    if (item.arabicExcerpt.isNotEmpty) {
      buffer.writeln('"${item.arabicExcerpt}"');
      buffer.writeln();
    }
    buffer.write('— ');
    if (item.bookReference.isNotEmpty) {
      buffer.write('${NativeCopy.text('sources')}: ${item.bookReference}');
      if (item.pageNumber.isNotEmpty) {
        buffer.write(' (${NativeCopy.text('pages')}: ${item.pageNumber})');
      }
    } else {
      buffer.write(item.title);
    }
    if (item.author != null && item.author!.isNotEmpty) {
      buffer.write(', ${NativeCopy.text('author')}: ${item.author}');
    }
    buffer.write('.');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppSnackBar.success(
      context,
      AppCopy.referenceCopied,
    );
  }

  Future<void> _openNoteEditor([BookmarkModel? item]) async {
    final res = await NoteEditorSheet.show(context, item: item);
    if (res != null && mounted) {
      _loadBookmarks();
    }
  }

  Future<void> _openBookmarkItem(BookmarkModel item) async {
    if (item.id.startsWith('book_')) {
      final editionId = item.id.replaceFirst('book_', '');
      var books = CanonicalLibraryService.instance.cachedSyafiiBooks;
      if (books == null) {
        try {
          books = await CanonicalLibraryService.instance.loadSyafiiCatalog();
        } catch (_) {}
      }
      final matchedBook = books?.firstWhere(
        (b) => b.editionId == editionId,
        orElse: () => CanonicalBookPresentation(
          editionId: editionId,
          titleArabic: item.title,
          authorArabic: item.author ?? '',
        ),
      );

      if (matchedBook != null && mounted) {
        NavigationGuard.safePushNamed(
          context,
          AppRoutes.bookDetail,
          arguments: matchedBook,
        );
        return;
      }
    }

    if (!mounted) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => NativeTheme(child: NoteReaderScreen(item: item))),
    );
    if (changed == true && mounted) _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = NativeColors.canvas(isDark);
    final surface = NativeColors.surface(isDark);
    final surfaceSubtle = NativeColors.surfaceSubtle(isDark);
    final border = NativeColors.border(isDark);
    final textPrimary = NativeColors.textPrimary(isDark);
    final textSecondary = NativeColors.textSecondary(isDark);
    final accent = NativeColors.accent(isDark);

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppCopy.savedCollection,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: textPrimary),
            tooltip: AppCopy.addNote,
            onPressed: () => _openNoteEditor(),
          ),
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: textPrimary,
            ),
            tooltip:
                _showSearch ? AppCopy.closeSearch : AppCopy.searchSavedTooltip,
            onPressed: () {
              OTMotion.selection();
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                  _filter();
                }
              });
            },
          ),
          const SizedBox(width: OTSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              children: [
                // ── Search Field (collapsible) ──
                if (_showSearch)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OTSpacing.lg,
                      vertical: OTSpacing.xs + 2,
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      decoration: BoxDecoration(
                        color: surfaceSubtle,
                        borderRadius: OTRadius.inputBorder,
                        border: Border.all(color: border, width: 1),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                            _filter();
                          });
                        },
                        style: OTTypography.body(color: textPrimary),
                        decoration: InputDecoration(
                          hintText: AppCopy.searchSavedHint,
                          hintStyle: OTTypography.body(color: textSecondary),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: textSecondary,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: textSecondary,
                                  ),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _filter();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      OTSpacing.lg, 12, OTSpacing.lg, 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      AppCopy.savedNotesCount(_filteredBookmarks.length),
                      style:
                          OTTypography.caption(color: textSecondary).copyWith(
                        fontSize: OTFontSize.s12,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                // ── Horizontal Filter Pills (Pengelompokan Keilmuan) ──
                Container(
                  height:
                      MediaQuery.textScalerOf(context).scale(48).clamp(48, 100),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: OTSpacing.sm),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;

                      return Center(
                        child: OTChip(
                          label: Loc.text(cat),
                          selected: isSelected,
                          onSelected: () => setState(() {
                            _selectedCategory = cat;
                            _filter();
                          }),
                        ),
                      );
                    },
                  ),
                ),

                if (_bookmarkService.hasPendingSync)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        OTSpacing.base, 0, OTSpacing.base, OTSpacing.sm),
                    child: Semantics(
                      liveRegion: true,
                      child: Container(
                        padding: const EdgeInsetsDirectional.only(
                            start: OTSpacing.md, end: OTSpacing.xs),
                        decoration: BoxDecoration(
                          color: surfaceSubtle,
                          borderRadius: OTRadius.cardBorder,
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cloud_off_outlined,
                                size: 18, color: textSecondary),
                            const SizedBox(width: OTSpacing.sm),
                            Expanded(
                              child: Text(
                                Loc.tr('notesSyncPendingBanner',
                                    ['${_bookmarkService.pendingSyncCount}']),
                                style: NativeFonts.outfit(
                                    fontSize: OTFontSize.s14,
                                    height: 1.35,
                                    color: textSecondary),
                              ),
                            ),
                            TextButton(
                              onPressed: _syncBookmarks,
                              child: Text(Loc.tr('syncNow')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── List of Saved Bookmarks ──
                Expanded(
                  child: _isLoading
                      ? const Center(child: NativeLoading())
                      : RefreshIndicator(
                          onRefresh: _syncBookmarks,
                          color: accent,
                          backgroundColor: surface,
                          child: _filteredBookmarks.isEmpty
                              ? LayoutBuilder(
                                  builder: (context, constraints) =>
                                      SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(
                                      parent: BouncingScrollPhysics(),
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: OTSpacing.xl),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 68,
                                                height: 68,
                                                decoration: BoxDecoration(
                                                  color: surfaceSubtle,
                                                  borderRadius:
                                                      OTRadius.cardBorder,
                                                  border: Border.all(
                                                      color: border,
                                                      width: 1.0),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons
                                                        .collections_bookmark_outlined,
                                                    size: 30,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: OTSpacing.lg),
                                              Text(
                                                _allBookmarks.isEmpty
                                                    ? NativeCopy.text(
                                                        'notesEmpty')
                                                    : NativeCopy.text(
                                                        'noNotesResults'),
                                                style: OTTypography.cardTitle(
                                                        color: textPrimary)
                                                    .copyWith(
                                                  fontSize: OTFontSize.s16,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: OTSpacing.xs + 2),
                                              Text(
                                                _allBookmarks.isEmpty
                                                    ? NativeCopy.text(
                                                        'notesHint')
                                                    : NativeCopy.text(
                                                        'searchHint'),
                                                textAlign: TextAlign.center,
                                                style: OTTypography.body(
                                                        color: textSecondary)
                                                    .copyWith(
                                                  fontSize: OTFontSize.s14,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: OTSpacing.xl),
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  OTMotion.light();
                                                  if (_allBookmarks.isEmpty) {
                                                    _openNoteEditor();
                                                  } else {
                                                    _searchCtrl.clear();
                                                    setState(() {
                                                      _searchQuery = '';
                                                      _selectedCategory =
                                                          'Semua';
                                                      _filter();
                                                    });
                                                  }
                                                },
                                                icon: const Icon(
                                                    Icons.menu_book_outlined,
                                                    size: 16),
                                                label: Text(_allBookmarks
                                                        .isEmpty
                                                    ? NativeCopy.text('write')
                                                    : NativeCopy.text(
                                                        'resetSearch')),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                    OTSpacing.lg,
                                    OTSpacing.sm,
                                    OTSpacing.lg,
                                    96,
                                  ),
                                  // Jendela lebar: dua kolom kartu; ponsel: satu kolom.
                                  itemCount:
                                      MediaQuery.sizeOf(context).width >= 1000
                                          ? (_filteredBookmarks.length + 1) ~/ 2
                                          : _filteredBookmarks.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: OTSpacing.md),
                                  itemBuilder: (context, row) {
                                    Widget card(int index) {
                                      final item = _filteredBookmarks[index];
                                      return OTReveal(
                                          index: index % 6,
                                          child: _BookmarkCard(
                                            item: item,
                                            searchQuery: _searchQuery,
                                            surface: surface,
                                            surfaceSubtle: surfaceSubtle,
                                            border: border,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            accent: accent,
                                            onEdit: () => _openNoteEditor(item),
                                            onCopy: () => _copyIbarah(
                                                item.arabicExcerpt.isNotEmpty
                                                    ? item.arabicExcerpt
                                                    : item.fullAnswer),
                                            onOpen: () =>
                                                _openBookmarkItem(item),
                                            onShare: () => _shareBookmark(item),
                                            onDelete: () =>
                                                _deleteBookmark(item),
                                          ));
                                    }

                                    if (MediaQuery.sizeOf(context).width <
                                        1000) {
                                      return card(row);
                                    }
                                    final second = row * 2 + 1;
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: card(row * 2)),
                                        const SizedBox(width: OTSpacing.md),
                                        Expanded(
                                          child:
                                              second < _filteredBookmarks.length
                                                  ? card(second)
                                                  : const SizedBox.shrink(),
                                        ),
                                      ],
                                    );
                                  },
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

class _BookmarkCard extends StatefulWidget {
  final BookmarkModel item;
  final String searchQuery;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.item,
    required this.searchQuery,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onEdit,
    required this.onCopy,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  @override
  State<_BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<_BookmarkCard> {
  // Daftar arsip tidak pernah membuka isi panjang di tempat; detail dibuka
  // lewat ketukan kartu agar satu tangan tetap nyaman dipakai pada ponsel.
  final bool _isExpanded = false;

  String _formatRelativeTime(DateTime dt) =>
      MaterialLocalizations.of(context).formatMediumDate(dt);

  String _cleanSingleLine(String text) {
    final lines =
        text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    if (lines.isEmpty) return '';
    return lines.first.replaceAll(RegExp(r'[#*>`_~]'), '').trim();
  }

  String _getSnippet(String fullAnswer, String query) {
    final cleanQ = query.trim().toLowerCase();
    if (cleanQ.isEmpty) return _cleanSingleLine(fullAnswer);

    final lines =
        fullAnswer.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    for (final line in lines) {
      if (line.toLowerCase().contains(cleanQ) ||
          ArabicUtils.matches(line, cleanQ)) {
        return line.replaceAll(RegExp(r'[#*>`_~]'), '').trim();
      }
    }
    return _cleanSingleLine(fullAnswer);
  }

  String _buildSearchPattern(String query) {
    final clean = RegExp.escape(query.trim());
    const harakat = r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]*';
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      buffer.write(clean[i]);
      if (i < clean.length - 1) {
        buffer.write(harakat);
      }
    }
    return buffer.toString();
  }

  Widget _buildHighlightedText({
    required String text,
    required String query,
    required TextStyle baseStyle,
    required bool isDark,
    bool isRtl = false,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final cleanQ = query.trim();
    if (cleanQ.isEmpty || text.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        textDirection: isRtl ? TextDirection.rtl : null,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final pattern = _buildSearchPattern(cleanQ);
    final regex = RegExp(pattern, caseSensitive: false);
    final matches = regex.allMatches(text).toList();

    if (matches.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        textDirection: isRtl ? TextDirection.rtl : null,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final spans = <InlineSpan>[];
    int lastIndex = 0;

    for (final m in matches) {
      if (m.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, m.start),
          style: baseStyle,
        ));
      }
      final matchedPart = text.substring(m.start, m.end);
      // Untuk teks Arab dan Latin, gunakan TextSpan dengan background
      // agar tidak memotong ligatur huruf sambung (cursive shaping) teks Arab.
      spans.add(
        TextSpan(
          text: matchedPart,
          style: baseStyle.copyWith(
            color: isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
            backgroundColor:
                isDark ? OTColors.surfaceLight : OTColors.surfaceDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      lastIndex = m.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      textDirection: isRtl ? TextDirection.rtl : null,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  String _cleanExcerpt(String text, int maxLength) {
    final trimmed = text.trim();
    if (trimmed.length <= maxLength) return trimmed;
    final sub = trimmed.substring(0, maxLength);
    final lastSpace = sub.lastIndexOf(' ');
    if (lastSpace > maxLength ~/ 2) {
      return '${sub.substring(0, lastSpace)}...';
    }
    return '$sub...';
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBookRef = item.documentKind == BookmarkDocumentKind.bookReference;
    final hasValidBookRef = item.bookReference.isNotEmpty &&
        !item.bookReference.toLowerCase().contains('belum diidentifikasi');

    final pillLabel = switch (item.documentKind) {
      BookmarkDocumentKind.personalNote => AppCopy.navSaved,
      BookmarkDocumentKind.aiAnswer => item.agentTitle.isNotEmpty
          ? item.agentTitle
              .replaceFirst(RegExp(r'^AI\s+', caseSensitive: false), '')
          : (item.fieldName.contains('Catatan')
              ? AppCopy.navSaved
              : (item.fieldName.isNotEmpty
                  ? item.fieldName
                  : AppCopy.studySpace)),
      BookmarkDocumentKind.bookReference => AppCopy.bookReferenceLabel,
    };
    final displayTitle = item.documentKind == BookmarkDocumentKind.aiAnswer
        ? aiAnswerTitle(item.fullAnswer, item.agentTitle)
        : item.title;
    final readableAnswer = item.documentKind == BookmarkDocumentKind.aiAnswer
        ? readableAiAnswerMarkdown(item.fullAnswer)
        : item.fullAnswer;

    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : OTMotion.normal,
      curve: OTMotion.curve,
      child: InkWell(
        onTap: widget.onOpen,
        borderRadius: BorderRadius.circular(OTRadius.card),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: BorderRadius.circular(OTRadius.card),
            border: Border.all(
              color: _isExpanded
                  ? widget.accent.withValues(alpha: 0.4)
                  : widget.border,
              width: _isExpanded ? 1.0 : 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metadata Bar: Pill Asisten / Keilmuan berdampingan rapi dengan keterangan waktu
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: OTColors.primaryContainer(isDark),
                      borderRadius: OTRadius.chipBorder,
                    ),
                    child: Text(
                      pillLabel,
                      style: OTTypography.captionMedium(
                              color: OTColors.onPrimaryContainer(isDark))
                          .copyWith(
                        fontSize: OTFontSize.s11,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(
                      color: widget.textSecondary.withValues(alpha: 0.4),
                      fontSize: OTFontSize.s11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatRelativeTime(item.effectiveTime),
                    style: OTTypography.caption(
                      color: widget.textSecondary.withValues(alpha: 0.8),
                    ).copyWith(fontSize: OTFontSize.s11),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Title (dengan highlight pencarian)
              _buildHighlightedText(
                text: displayTitle,
                query: widget.searchQuery,
                baseStyle:
                    OTTypography.cardTitle(color: widget.textPrimary).copyWith(
                  fontSize: OTFontSize.s16,
                  fontWeight: FontWeight.w600,
                ),
                isDark: isDark,
                maxLines: _isExpanded ? null : 1,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),

              // Compact Preview (when collapsed, menampilkan cuplikan yang cocok dengan highlight)
              if (!_isExpanded && item.fullAnswer.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildHighlightedText(
                  text: item.documentKind == BookmarkDocumentKind.aiAnswer &&
                          widget.searchQuery.trim().isEmpty
                      ? parseAiAnswerContent(readableAnswer).preview
                      : _getSnippet(readableAnswer, widget.searchQuery),
                  query: widget.searchQuery,
                  baseStyle: OTTypography.caption(color: widget.textSecondary)
                      .copyWith(
                    fontSize: OTFontSize.s12,
                  ),
                  isDark: isDark,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Expanded Content
              if (_isExpanded) ...[
                if (hasValidBookRef) ...[
                  const SizedBox(height: OTSpacing.sm),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.surfaceSubtle,
                      borderRadius: OTRadius.chipBorder,
                      border: Border.all(
                        color: widget.border.withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
                    child: _buildHighlightedText(
                      text:
                          '${item.bookReference}${item.pageNumber.isNotEmpty ? " · Hlm. ${item.pageNumber}" : ""}',
                      query: widget.searchQuery,
                      baseStyle:
                          OTTypography.captionMedium(color: widget.textPrimary),
                      isDark: isDark,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                if (item.arabicExcerpt.isNotEmpty) ...[
                  const SizedBox(height: OTSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.surfaceSubtle,
                      borderRadius: BorderRadius.circular(OTRadius.input),
                      border: Border.all(
                        color: widget.border.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: _buildHighlightedText(
                      text: item.arabicExcerpt,
                      query: widget.searchQuery,
                      isRtl: true,
                      baseStyle: NativeFonts.scheherazadeNew(
                        fontSize: OTFontSize.s18,
                        fontWeight: FontWeight.w700,
                        height: 1.8,
                        color: widget.textPrimary,
                      ),
                      isDark: isDark,
                    ),
                  ),
                ],

                if (item.fullAnswer.trim().isNotEmpty) ...[
                  const SizedBox(height: OTSpacing.sm),
                  if (widget.searchQuery.trim().isNotEmpty)
                    _buildHighlightedText(
                      text: item.fullAnswer.length > 600
                          ? _cleanExcerpt(item.fullAnswer, 600)
                          : item.fullAnswer.trim(),
                      query: widget.searchQuery,
                      baseStyle: NativeFonts.outfit(
                        fontSize: OTFontSize.s14,
                        height: 1.5,
                        color: widget.textSecondary,
                      ),
                      isDark: isDark,
                    )
                  else
                    MarkdownBody(
                      data: item.fullAnswer.length > 300
                          ? _cleanExcerpt(item.fullAnswer, 300)
                          : item.fullAnswer.trim(),
                      styleSheet: MarkdownStyleSheet(
                        p: NativeFonts.outfit(
                          fontSize: OTFontSize.s14,
                          height: 1.5,
                          color: widget.textSecondary,
                        ),
                        strong: NativeFonts.outfit(
                          fontSize: OTFontSize.s14,
                          fontWeight: FontWeight.w700,
                          color: widget.textPrimary,
                        ),
                        blockquote: NativeFonts.outfit(
                          fontSize: OTFontSize.s12,
                          fontStyle: FontStyle.italic,
                          color: widget.textSecondary,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: OTSpacing.md),

                // Action Buttons
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: Text(Loc.tr('edit')),
                      style: OTButtons.compactOutlined(
                          Theme.of(context).brightness == Brightness.dark),
                    ),
                    const SizedBox(width: OTSpacing.xs + 2),
                    OutlinedButton.icon(
                      onPressed: widget.onCopy,
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: Text(
                        item.arabicExcerpt.isNotEmpty
                            ? AppCopy.copyIbarahAction
                            : (isBookRef
                                ? 'Salin rujukan'
                                : (item.fieldName.contains('Catatan')
                                    ? 'Salin catatan'
                                    : 'Salin jawaban')),
                      ),
                      style: OTButtons.compactOutlined(
                          Theme.of(context).brightness == Brightness.dark),
                    ),
                    if (isBookRef) ...[
                      const SizedBox(width: OTSpacing.xs + 2),
                      FilledButton.icon(
                        onPressed: widget.onOpen,
                        icon: const Icon(Icons.menu_book, size: 14),
                        label: Text(Loc.tr('viewBook')),
                        style: OTButtons.compactTonal(
                            Theme.of(context).brightness == Brightness.dark),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onShare,
                      icon: const Icon(Icons.share_outlined, size: 18),
                      tooltip: AppCopy.shareReferenceTooltip,
                      color: widget.textSecondary,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: widget.textSecondary.withValues(alpha: 0.7),
                      ),
                      tooltip: AppCopy.deleteNote,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
