import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../widgets/native_theme.dart';
import 'package:flutter/services.dart';
import '../core/design/native_fonts.dart';
import '../core/localization.dart';
import '../core/arabic_utils.dart';
import '../core/design/native_design.dart';

import '../core/app_snackbar.dart';

import '../models/bookmark_model.dart';
import '../models/open_turath_book.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';

/// Halaman Katalog Kitab Editorial OpenTurath (Monochrome Editorial)
/// Unknown markers are not volume counts. Arabic-Indic digits are supported.
int? nativeVolumeCount(String value) {
  var normalized = value.trim();
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  for (var i = 0; i < 10; i++) {
    normalized = normalized.replaceAll(eastern[i], '$i').replaceAll(persian[i], '$i');
  }
  if (normalized.isEmpty || normalized == '-') return null;
  if (normalized.toLowerCase() == 'jilid tunggal') return 1;
  final match = RegExp(r'^(\d+)(?:\s*(?:jilid|volumes?|مجلدات?|أجزاء|جزء))?$').firstMatch(normalized);
  return match == null ? null : int.tryParse(match[1]!);
}

class OpenTurathBookLibraryPage extends StatefulWidget {
  const OpenTurathBookLibraryPage({
    super.key,
    required this.books,
    required this.collectionName,
    this.onOpenBook,
    this.onAbout,
  });

  final List<OpenTurathBook> books;
  final String collectionName;
  final ValueChanged<OpenTurathBook>? onOpenBook;
  final VoidCallback? onAbout;

  @override
  State<OpenTurathBookLibraryPage> createState() =>
      _OpenTurathBookLibraryPageState();
}

enum _BookVolumeFilter {
  all,
  singleVolume,
  multiVolume,
}

class _OpenTurathBookLibraryPageState extends State<OpenTurathBookLibraryPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  String _query = '';
  _BookVolumeFilter _filter = _BookVolumeFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() => _query = _searchController.text.trim().toLowerCase());
  }

  List<OpenTurathBook> get _filteredBooks {
    return widget.books.where((book) {
      final matchesQuery = _query.isEmpty ||
          [
            book.title,
            book.shortName,
            book.author,
            book.editor,
            book.publisher,
            book.section,
          ].any((value) => ArabicUtils.matches(value, _query));

      if (!matchesQuery) return false;

      switch (_filter) {
        case _BookVolumeFilter.all:
          return true;
        case _BookVolumeFilter.singleVolume:
          final vols = book.volumes.trim();
          return vols == '1' || vols.toLowerCase().contains('jilid tunggal');
        case _BookVolumeFilter.multiVolume:
          final vols = book.volumes.trim();
          final numVol = int.tryParse(vols);
          return (numVol != null && numVol > 1) ||
              vols.contains('+') ||
              vols.contains('-');
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = NativeColors.canvas(isDark);
    final surface = NativeColors.surface(isDark);
    final ink = NativeColors.textPrimary(isDark);
    final textSecondary = NativeColors.textSecondary(isDark);
    final border = NativeColors.border(isDark);

    final visibleBooks = _filteredBooks;

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_rounded,
                              color: ink, size: 22),
                          tooltip: NativeCopy.text('back'),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      NativeCopy.text('catalog'),
                      style: NativeFonts.newsreader(
                        color: ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.collectionName,
                      style: NativeFonts.outfit(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (widget.onAbout != null)
                      TextButton(
                          onPressed: widget.onAbout,
                          child: Text(NativeCopy.text('aboutCollection'))),
                    const SizedBox(height: 18),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: NativeFonts.outfit(color: ink, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: NativeCopy.text('searchBooks'),
                        hintStyle: NativeFonts.outfit(
                            color: textSecondary, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: textSecondary, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded,
                                    color: textSecondary, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: ink, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: NativeCopy.text('allBooks'),
                            isSelected: _filter == _BookVolumeFilter.all,
                            onTap: () =>
                                setState(() => _filter = _BookVolumeFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: NativeCopy.text('singleVolume'),
                            isSelected:
                                _filter == _BookVolumeFilter.singleVolume,
                            onTap: () => setState(
                                () => _filter = _BookVolumeFilter.singleVolume),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: NativeCopy.text('multiVolume'),
                            isSelected:
                                _filter == _BookVolumeFilter.multiVolume,
                            onTap: () => setState(
                                () => _filter = _BookVolumeFilter.multiVolume),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          NativeCopy.text('results', [
                            '${visibleBooks.length}',
                            '${widget.books.length}'
                          ]),
                          style: NativeFonts.outfit(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 0.8),
                  ],
                ),
              ),
            ),
            if (visibleBooks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 48, color: textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        NativeCopy.text('noBooks'),
                        style: NativeFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NativeCopy.text('searchHint'),
                        style: NativeFonts.outfit(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final book = visibleBooks[index];
                      return _BookEditorialItem(
                        book: book,
                        index: index + 1,
                        onTap: () {
                          if (widget.onOpenBook != null) {
                            widget.onOpenBook!(book);
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => NativeTheme(
                                  child: OpenTurathBookDetailPage(book: book)),
                            ),
                          );
                        },
                      );
                    },
                    childCount: visibleBooks.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = NativeColors.textPrimary(isDark);
    final surface = NativeColors.surface(isDark);
    final border = NativeColors.border(isDark);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ink : surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? ink : border),
        ),
        child: Text(
          label,
          style: NativeFonts.outfit(
            color: isSelected ? NativeColors.canvas(isDark) : ink,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BookEditorialItem extends StatelessWidget {
  const _BookEditorialItem(
      {required this.book, required this.index, required this.onTap});
  final OpenTurathBook book;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: NativeColors.border(dark), width: .8))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 16, runSpacing: 6, children: [
              Text(book.section, style: NativeType.meta(dark)),
              if (book.deathYear != null)
                Text(book.deathLabel, style: NativeType.meta(dark)),
            ]),
            const SizedBox(height: 12),
            Align(
                alignment: Alignment.centerRight,
                child: Text(book.title,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: NativeType.arabic(dark, size: 24))),
            const SizedBox(height: 8),
            Text(Loc.tr('authorCredit', [book.author]),
                style: NativeType.body(dark, size: 15)),
            if (book.editor.isNotEmpty && book.editor != '-') ...[
              const SizedBox(height: 4),
              Text(Loc.tr('editorCredit', [book.editor]),
                  style: NativeType.meta(dark)),
            ],
            const SizedBox(height: 12),
            Wrap(spacing: 16, runSpacing: 6, children: [
              Text(book.volumeLabel, style: NativeType.meta(dark)),
              Text(book.pagesLabel, style: NativeType.meta(dark)),
            ]),
          ]),
        ));
  }
}

/// Halaman Detail Kitab & Metadata Rujukan Ilmiah
class OpenTurathBookDetailPage extends StatefulWidget {
  const OpenTurathBookDetailPage({
    super.key,
    required this.book,
  });

  final OpenTurathBook book;

  @override
  State<OpenTurathBookDetailPage> createState() =>
      _OpenTurathBookDetailPageState();
}

String nativeBookReferenceId(OpenTurathBook book) =>
    'book_editorial_${sha256.convert(utf8.encode(jsonEncode([
          book.id,
          book.title,
          book.author,
          book.editor,
          book.publisher,
          book.edition,
          book.volumes,
          book.sourceFolder
        ])))}';

String nativeBookCitation(OpenTurathBook book) => [
      '[OpenTurath]',
      '${NativeCopy.text('sources')}: ${book.title}',
      '${NativeCopy.text('author')}: ${book.author} (${book.deathLabel})',
      if (book.editor.isNotEmpty)
        '${NativeCopy.text('editor')}: ${book.editor}',
      if (book.publisher.isNotEmpty)
        '${NativeCopy.text('publisher')}: ${book.publisher}',
      if (book.edition.isNotEmpty)
        '${NativeCopy.text('edition')}: ${book.edition}',
      '${NativeCopy.text('volumes')}: ${book.volumeLabel}',
      '${NativeCopy.text('pages')}: ${book.pagesLabel}',
      if (book.section.isNotEmpty)
        '${NativeCopy.text('disciplines')}: ${book.section}',
    ].join('\n');

class _OpenTurathBookDetailPageState extends State<OpenTurathBookDetailPage> {
  OpenTurathBook get book => widget.book;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _readSaved();
  }

  Future<void> _readSaved() async {
    try {
      final saved =
          await BookmarkService().isBookmarked(nativeBookReferenceId(book));
      if (mounted) setState(() => _saved = saved);
    } catch (_) {
      // Saving remains available even if the initial storage read fails.
    }
  }

  Future<void> _handleBookmark(BuildContext context) async {
    if (_saving || _saved) return;
    setState(() => _saving = true);
    try {
      final uid = AuthService().currentUser?.uid;
      final bookmark = BookmarkModel(
        id: nativeBookReferenceId(book),
        title: book.title,
        agentId: 'pustaka_turats',
        agentTitle: book.section,
        fieldName: book.section,
        fieldId: 'pustaka',
        arabicExcerpt: book.title,
        fullAnswer: nativeBookCitation(book),
        bookReference: '${book.title} - ${book.author}',
        pageNumber: book.pagesLabel,
        author: book.author,
        createdAt: DateTime.now(),
        documentKind: BookmarkDocumentKind.bookReference,
        verificationStatus: BookmarkVerificationStatus.verified,
      );

      await BookmarkService().addBookmark(bookmark, userId: uid);
      if (context.mounted) {
        setState(() => _saved = true);
        AppSnackBar.success(context, NativeCopy.text('saved'));
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, NativeCopy.text('saveFailed'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _handleCopyCitation(BuildContext context) async {
    final citation = nativeBookCitation(book);

    await Clipboard.setData(ClipboardData(text: citation));
    if (context.mounted) {
      AppSnackBar.success(context, NativeCopy.text('copied'));
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = NativeColors.canvas(isDark);
    final surface = NativeColors.surface(isDark);
    final ink = NativeColors.textPrimary(isDark);
    final textSecondary = NativeColors.textSecondary(isDark);
    final border = NativeColors.border(isDark);

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.arrow_back_rounded, color: ink, size: 22),
                      tooltip: NativeCopy.text('back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                      NativeCopy.text('sources'),
                      style: NativeFonts.outfit(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    IconButton(
                      icon: Icon(Icons.copy_rounded, color: ink, size: 20),
                      tooltip: NativeCopy.text('copyReference'),
                      onPressed: () => _handleCopyCitation(context),
                    ),
                    IconButton(
                      icon: Icon(
                          _saved
                              ? Icons.bookmark_added_outlined
                              : Icons.bookmark_add_outlined,
                          color: ink,
                          size: 20),
                      tooltip:
                          NativeCopy.text(_saved ? 'saved' : 'saveReference'),
                      onPressed: _saving || _saved
                          ? null
                          : () => _handleBookmark(context),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Card Kitab
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF222220)
                                      : const Color(0xFFEEEEEB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  book.section.toUpperCase(),
                                  style: NativeFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                book.deathLabel,
                                style: NativeFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                book.title,
                                textAlign: TextAlign.right,
                                style: NativeFonts.scheherazadeNew(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: ink,
                                  height: 1.9,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            book.author,
                            style: NativeFonts.newsreader(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      NativeCopy.text('edition'),
                      style: NativeFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                              label: NativeCopy.text('editor'),
                              value: book.editor),
                          _DetailRow(
                              label: NativeCopy.text('publisher'),
                              value: book.publisher),
                          _DetailRow(
                              label: NativeCopy.text('year'),
                              value: book.edition),
                          _DetailRow(
                              label: NativeCopy.text('volumes'),
                              value: book.volumeLabel),
                          _DetailRow(
                              label: NativeCopy.text('pages'),
                              value: book.pagesLabel),
                          _DetailRow(
                              label: NativeCopy.text('sources'),
                              value: book.sourceFolder,
                              isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: _saving || _saved
                          ? null
                          : () => _handleBookmark(context),
                      icon: Icon(_saved
                          ? Icons.bookmark_added_outlined
                          : Icons.bookmark_add_outlined),
                      label: Text(NativeCopy.text(_saving
                          ? 'loading'
                          : _saved
                              ? 'saved'
                              : 'saveReference')),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleCopyCitation(context),
                        icon: const Icon(Icons.content_copy_rounded, size: 18),
                        label: Text(
                          NativeCopy.text('copyReference'),
                          style: NativeFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ink,
                          side: BorderSide(color: border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = NativeColors.textPrimary(isDark);
    final textSecondary = NativeColors.textSecondary(isDark);
    final border = NativeColors.border(isDark);

    final displayValue = value.trim().isEmpty ? '-' : value.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: border, width: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width < 400 ? 100 : 130,
            child: Text(
              label,
              style: NativeFonts.outfit(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: NativeFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
