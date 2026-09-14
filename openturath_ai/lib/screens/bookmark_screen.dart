import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../core/routes.dart';
import '../models/bookmark_model.dart';
import '../models/book_model.dart';
import '../services/bookmark_service.dart';
import '../services/canonical_library_service.dart';
import '../widgets/note_editor_sheet.dart';
import 'main_shell_screen.dart';

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

  static const List<String> _categories = [
    'Semua',
    'Catatan',
    'Ibarah Kitab',
    'Rujukan Kitab',
    'Fikih',
    'Hadis',
    'Tafsir',
    'Akidah',
    'Usul Fikih',
    'Bahasa Arab',
    'Sejarah',
    'Tasawuf & Akhlak',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _bookmarkService.addListener(_onBookmarksChanged);
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
        _filter();
        _isLoading = false;
      });
    }
  }

  void _filter() {
    final q = _searchQuery.toLowerCase().trim();
    _filteredBookmarks = _allBookmarks.where((b) {
      final fieldLower = b.fieldName.toLowerCase();
      final isBookRef = b.id.startsWith('book_') || fieldLower.contains('rujukan kitab');

      bool matchesCategory;
      if (_selectedCategory == 'Semua') {
        matchesCategory = true;
      } else if (_selectedCategory == 'Rujukan Kitab') {
        matchesCategory = isBookRef;
      } else if (_selectedCategory == 'Ibarah Kitab') {
        matchesCategory = !isBookRef && !fieldLower.contains('catatan');
      } else if (_selectedCategory == 'Catatan') {
        matchesCategory = fieldLower.contains('catatan');
      } else {
        matchesCategory = fieldLower.contains(_selectedCategory.toLowerCase()) ||
            (_selectedCategory == 'Hadis' && fieldLower.contains('hadits')) ||
            (_selectedCategory == 'Sejarah' && fieldLower.contains('tarikh')) ||
            (_selectedCategory == 'Akidah' && fieldLower.contains('aqidah')) ||
            (_selectedCategory == 'Usul Fikih' && fieldLower.contains('ushul')) ||
            (_selectedCategory == 'Tasawuf & Akhlak' &&
                (fieldLower.contains('tasawuf') ||
                    fieldLower.contains('tasawwuf') ||
                    fieldLower.contains('akhlak')));
      }

      if (!matchesCategory) return false;
      if (q.isEmpty) return true;
      return b.title.toLowerCase().contains(q) ||
          b.agentTitle.toLowerCase().contains(q) ||
          b.bookReference.toLowerCase().contains(q) ||
          b.arabicExcerpt.contains(q) ||
          b.fullAnswer.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _deleteBookmark(BookmarkModel item) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
          title: Text(
            'Hapus catatan?',
            style: OTTypography.screenTitle(color: textPrimary).copyWith(fontSize: 18),
          ),
          content: Text(
            'Catatan ini akan dihapus permanen.',
            style: OTTypography.body(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Batal',
                style: OTTypography.button(color: textSecondary),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive,
                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(
                'Hapus',
                style: OTTypography.button(color: Colors.white),
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
          message: 'Catatan dihapus.',
          action: SnackBarAction(
            label: 'Urungkan',
            textColor: OTColors.accent(isDark),
            onPressed: () => _bookmarkService.addBookmark(item),
          ),
        );
      }
    }
  }

  void _copyIbarah(String ibarah) {
    OTMotion.light();
    Clipboard.setData(ClipboardData(text: ibarah));
    AppSnackBar.success(context, 'Ibarah tersalin.');
  }

  void _shareBookmark(BookmarkModel item) {
    final buffer = StringBuffer();
    if (item.arabicExcerpt.isNotEmpty) {
      buffer.writeln('"${item.arabicExcerpt}"');
      buffer.writeln();
    }
    buffer.write('— ');
    if (item.bookReference.isNotEmpty) {
      buffer.write('Kitab ${item.bookReference}');
      if (item.pageNumber.isNotEmpty) {
        buffer.write(' (Hal. ${item.pageNumber})');
      }
    } else {
      buffer.write(item.title);
    }
    if (item.author != null && item.author!.isNotEmpty) {
      buffer.write(', karya ${item.author}');
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
        Navigator.pushNamed(
          context,
          AppRoutes.bookDetail,
          arguments: matchedBook,
        );
        return;
      }
    }

    _openNoteEditor(item);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Catatan',
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: textPrimary),
            tooltip: 'Tambah catatan',
            onPressed: () => _openNoteEditor(),
          ),
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: textPrimary,
            ),
            tooltip: _showSearch ? 'Tutup pencarian' : AppCopy.searchSavedTooltip,
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
                  height: 44,
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),

            // ── Horizontal Filter Pills ──
            Container(
              height: 38,
              margin: const EdgeInsets.symmetric(vertical: OTSpacing.xs + 2),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: OTSpacing.sm),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      OTMotion.selection();
                      setState(() {
                        _selectedCategory = cat;
                        _filter();
                      });
                    },
                    child: AnimatedContainer(
                      duration: OTMotion.fast,
                      curve: OTMotion.curve,
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md + 2,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? textPrimary : surface,
                        borderRadius: OTRadius.chipBorder,
                        border: Border.all(
                          color: isSelected ? textPrimary : border.withValues(alpha: 0.7),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: OTTypography.caption(
                            color: isSelected ? canvas : textSecondary,
                          ).copyWith(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── List of Saved Bookmarks ──
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: accent,
                      ),
                    )
                  : _filteredBookmarks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: OTSpacing.xl),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: surfaceSubtle,
                                    borderRadius: OTRadius.cardBorder,
                                    border: Border.all(color: border, width: 1.0),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.collections_bookmark_outlined,
                                      size: 30,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: OTSpacing.lg),
                                Text(
                                  AppCopy.noSavedTitle,
                                  style: OTTypography.cardTitle(color: textPrimary).copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: OTSpacing.xs + 2),
                                Text(
                                  AppCopy.noSavedDescription,
                                  textAlign: TextAlign.center,
                                  style: OTTypography.body(color: textSecondary).copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: OTSpacing.xl),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    OTMotion.light();
                                    final shell = MainShellController.of(context);
                                    shell?.switchTab(1);
                                  },
                                  icon: const Icon(Icons.menu_book_outlined, size: 16),
                                  label: const Text('Mulai telaah'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: textPrimary,
                                    side: BorderSide(color: border, width: 1.0),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: OTSpacing.lg,
                                      vertical: OTSpacing.md,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: OTRadius.buttonBorder,
                                    ),
                                    textStyle: OTTypography.button(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            OTSpacing.lg,
                            OTSpacing.sm,
                            OTSpacing.lg,
                            108,
                          ),
                          itemCount: _filteredBookmarks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: OTSpacing.md),
                          itemBuilder: (context, index) {
                            final item = _filteredBookmarks[index];
                            return _BookmarkCard(
                              item: item,
                              surface: surface,
                              surfaceSubtle: surfaceSubtle,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              accent: accent,
                              onEdit: () => _openNoteEditor(item),
                              onCopy: () => _copyIbarah(item.arabicExcerpt.isNotEmpty ? item.arabicExcerpt : item.fullAnswer),
                              onOpen: () => _openBookmarkItem(item),
                              onShare: () => _shareBookmark(item),
                              onDelete: () => _deleteBookmark(item),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final BookmarkModel item;
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
  Widget build(BuildContext context) {
    final isBookRef = item.id.startsWith('book_') || item.fieldName == 'Rujukan Kitab';
    final hasValidBookRef = item.bookReference.isNotEmpty &&
        !item.bookReference.toLowerCase().contains('belum diidentifikasi');

    return InkWell(
      onTap: onEdit,
      borderRadius: OTRadius.cardBorder,
      child: Container(
        padding: const EdgeInsets.all(OTSpacing.base),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.cardBorder,
          border: Border.all(color: border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category Pill + Agent Title + Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: OTRadius.chipBorder,
                        ),
                        child: Text(
                          isBookRef
                              ? 'Rujukan Kitab'
                              : (item.fieldName.contains('Catatan') ? 'Catatan' : item.fieldName),
                          style: OTTypography.captionMedium(color: accent).copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: OTSpacing.sm),
                      Flexible(
                        child: Text(
                          item.agentTitle,
                          style: OTTypography.caption(color: textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: textSecondary.withValues(alpha: 0.7),
                  ),
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  tooltip: 'Hapus catatan',
                  onPressed: onDelete,
                ),
              ],
            ),

            const SizedBox(height: OTSpacing.sm),

            // Title
            Text(
              item.title,
              style: OTTypography.cardTitle(color: textPrimary),
            ),

            if (hasValidBookRef) ...[
              const SizedBox(height: OTSpacing.sm),
              // Book Reference Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: surfaceSubtle,
                  borderRadius: OTRadius.chipBorder,
                  border: Border.all(color: border.withValues(alpha: 0.6), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_rounded, size: 14, color: accent),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${item.bookReference}${item.pageNumber.isNotEmpty ? " · Hlm. ${item.pageNumber}" : ""}',
                        style: OTTypography.captionMedium(color: textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (item.arabicExcerpt.isNotEmpty) ...[
              const SizedBox(height: OTSpacing.md),
              // Arabic Excerpt Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: surfaceSubtle,
                  borderRadius: BorderRadius.circular(OTRadius.input),
                  border: Border.all(color: border.withValues(alpha: 0.4), width: 0.8),
                ),
                child: Text(
                  item.arabicExcerpt,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                    color: textPrimary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Markdown Body Excerpt
            if (item.fullAnswer.trim().isNotEmpty) ...[
              const SizedBox(height: OTSpacing.sm),
              MarkdownBody(
                data: item.fullAnswer.length > 250
                    ? '${item.fullAnswer.substring(0, 250).trim()}...'
                    : item.fullAnswer.trim(),
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.outfit(
                    fontSize: 13,
                    height: 1.5,
                    color: textSecondary,
                  ),
                  strong: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  blockquote: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: textSecondary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: OTSpacing.md),

            // Action Buttons
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    side: BorderSide(color: border, width: 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: OTTypography.captionMedium(),
                    shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                  ),
                ),
                const SizedBox(width: OTSpacing.xs + 2),
                OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: Text(
                    item.arabicExcerpt.isNotEmpty
                        ? AppCopy.copyIbarahAction
                        : (isBookRef
                            ? 'Salin rujukan'
                            : (item.fieldName.contains('Catatan') ? 'Salin catatan' : 'Salin jawaban')),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    side: BorderSide(color: border, width: 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: OTTypography.captionMedium(),
                    shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                  ),
                ),
                if (isBookRef) ...[
                  const SizedBox(width: OTSpacing.xs + 2),
                  FilledButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.menu_book, size: 14),
                    label: const Text('Lihat rujukan'),
                    style: FilledButton.styleFrom(
                      backgroundColor: surfaceSubtle,
                      foregroundColor: textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: OTTypography.captionMedium(),
                      shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  tooltip: AppCopy.shareReferenceTooltip,
                  color: textSecondary,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
