import '../widgets/book_reading_rows.dart';
import '../widgets/desktop_shortcuts.dart';
import '../widgets/book_identity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_snackbar.dart';
import '../core/arabic_utils.dart';
import '../core/arabic_catalog.dart';
import '../core/design/ot_colors.dart';
import '../widgets/ot_motion_widgets.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_radius.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/bookmark_model.dart';
import '../models/open_turath_book.dart';
import '../services/auth_service.dart';
import '../services/open_turath_catalog_repository.dart';
import '../services/bookmark_service.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import '../widgets/ot_components.dart';
import '../widgets/ai_info_sheet.dart';

/// Halaman Katalog Kitab Editorial OpenTurath (Monochrome Editorial)
class OpenTurathBookLibraryPage extends StatefulWidget {
  const OpenTurathBookLibraryPage({
    super.key,
    required this.books,
    required this.collectionName,
    this.onOpenBook,
    this.metadata,
  });

  final List<OpenTurathBook> books;
  final String collectionName;
  final AiLibraryMetadata? metadata;
  final ValueChanged<OpenTurathBook>? onOpenBook;

  @override
  State<OpenTurathBookLibraryPage> createState() =>
      _OpenTurathBookLibraryPageState();
}

enum _BookSort { title, author, volumes }

enum _BookVolumeFilter {
  all,
  singleVolume,
  multiVolume,
}

class _OpenTurathBookLibraryPageState extends State<OpenTurathBookLibraryPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  String _query = '';
  _BookSort _sort = _BookSort.title;
  bool _list = true;
  bool _opening = false;
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
    final result = widget.books.where((book) {
      final matchesQuery = _query.isEmpty ||
          [
            book.title,
            book.shortName,
            book.author,
            book.editor,
            book.publisher,
            book.section,
            book.localizedSection,
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
    result.sort((a, b) => switch (_sort) {
          _BookSort.title => a.title.compareTo(b.title),
          _BookSort.author => a.author.compareTo(b.author),
          _BookSort.volumes => (int.tryParse(a.volumes) ?? 0)
              .compareTo(int.tryParse(b.volumes) ?? 0),
        });
    return result;
  }

  @override
  Widget build(BuildContext context) => DesktopShortcuts(
        onFind: _searchFocusNode.requestFocus,
        onEscape: () {
          _searchController.clear();
          _searchFocusNode.unfocus();
        },
        child: _buildContent(context),
      );

  Widget _buildContent(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final visibleBooks = _filteredBooks;
    return LayoutBuilder(builder: (context, box) {
      final pageInset = ((box.maxWidth - 1160) / 2)
          .clamp(box.maxWidth < 600 ? 16.0 : 24.0, double.infinity);
      final available = box.maxWidth - 2 * pageInset;
      final largeText = MediaQuery.textScalerOf(context).scale(16) > 24;
      final columns = available >= 1100
          ? 3
          : available >= 720
              ? 2
              : 1;
      return Theme(
          data: ArabicCatalog.theme(Theme.of(context)),
          child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                backgroundColor: canvas,
                appBar: AppBar(
                  titleSpacing: otTitleSpacing(context),
                  backgroundColor: canvas,
                  title: Text(
                      (widget.metadata?.namaArab ?? '').trim().isNotEmpty
                          ? widget.metadata!.namaArab
                          : RegExp(r'[\u0600-\u06FF]')
                                  .hasMatch(widget.collectionName)
                              ? widget.collectionName
                              : ArabicCatalog.catalogTitle,
                      style: ScholarlyFonts.scheherazadeNew(
                          fontSize: OTFontSize.s26,
                          fontWeight: FontWeight.w700,
                          color: ink)),
                  actions: [
                    if (widget.metadata != null)
                      IconButton(
                        tooltip: ArabicCatalog.aiInfo,
                        icon: const Icon(Icons.info_outline_rounded),
                        onPressed: () =>
                            AiInfoSheet.show(context, widget.metadata!.keyName),
                      ),
                  ],
                ),
                body: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(pageInset, 8, pageInset, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.metadata != null) ...[
                                Text(
                                    ArabicCatalog.bookCount(
                                        widget.metadata!.totalKitab),
                                    style: ArabicCatalog.ui(
                                        fontSize: OTFontSize.s12,
                                        color: textSecondary)),
                                const SizedBox(height: 12),
                              ],
                              // Search Bar
                              TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                style: ArabicCatalog.ui(
                                    color: ink, fontSize: OTFontSize.s14),
                                decoration: InputDecoration(
                                  hintText: ArabicCatalog.searchHint,
                                  hintStyle: ArabicCatalog.ui(
                                      color: textSecondary,
                                      fontSize: OTFontSize.s14),
                                  prefixIcon: Icon(Icons.search_rounded,
                                      color: textSecondary, size: 20),
                                  suffixIcon: _query.isNotEmpty
                                      ? IconButton(
                                          tooltip: ArabicCatalog.clearSearch,
                                          icon: Icon(Icons.clear_rounded,
                                              color: textSecondary, size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            _searchFocusNode.requestFocus();
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: OTColors.surfaceSubtle(isDark),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: OTRadius.inputBorder,
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: OTRadius.inputBorder,
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: OTRadius.inputBorder,
                                    borderSide:
                                        BorderSide(color: ink, width: 1.2),
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
                                      label: ArabicCatalog.allBooks,
                                      isSelected:
                                          _filter == _BookVolumeFilter.all,
                                      onTap: () => setState(() =>
                                          _filter = _BookVolumeFilter.all),
                                    ),
                                    const SizedBox(width: 8),
                                    _FilterChip(
                                      label: ArabicCatalog.singleVolume,
                                      isSelected: _filter ==
                                          _BookVolumeFilter.singleVolume,
                                      onTap: () => setState(() => _filter =
                                          _BookVolumeFilter.singleVolume),
                                    ),
                                    const SizedBox(width: 8),
                                    _FilterChip(
                                      label: ArabicCatalog.multiVolume,
                                      isSelected: _filter ==
                                          _BookVolumeFilter.multiVolume,
                                      onTap: () => setState(() => _filter =
                                          _BookVolumeFilter.multiVolume),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: available < 240
                                            ? available - 100
                                            : 180,
                                        child: DropdownButton<_BookSort>(
                                            isExpanded: true,
                                            value: _sort,
                                            underline: const SizedBox.shrink(),
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() => _sort = v);
                                              }
                                            },
                                            items: const [
                                              DropdownMenuItem(
                                                  value: _BookSort.title,
                                                  child: Text(
                                                      ArabicCatalog.sortTitle)),
                                              DropdownMenuItem(
                                                  value: _BookSort.author,
                                                  child: Text(ArabicCatalog
                                                      .sortAuthor)),
                                              DropdownMenuItem(
                                                  value: _BookSort.volumes,
                                                  child: Text(ArabicCatalog
                                                      .sortVolumes)),
                                            ])),
                                    IconButton.filledTonal(
                                        tooltip: ArabicCatalog.cardView,
                                        isSelected: !_list,
                                        onPressed: () =>
                                            setState(() => _list = false),
                                        icon: const Icon(
                                            Icons.grid_view_rounded)),
                                    IconButton.filledTonal(
                                        tooltip: ArabicCatalog.listView,
                                        isSelected: _list,
                                        onPressed: () =>
                                            setState(() => _list = true),
                                        icon: const Icon(
                                            Icons.view_list_rounded)),
                                  ]),
                              const SizedBox(height: 8),
                              Text(
                                _query.isEmpty &&
                                        _filter == _BookVolumeFilter.all
                                    ? ArabicCatalog.bookCount(
                                        visibleBooks.length)
                                    : ArabicCatalog.shown(visibleBooks.length,
                                        widget.books.length),
                                style: ArabicCatalog.ui(
                                  fontSize: OTFontSize.s12,
                                  color: textSecondary,
                                ),
                              ),
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
                                  ArabicCatalog.noBooks,
                                  style: ArabicCatalog.ui(
                                    fontSize: OTFontSize.s16,
                                    fontWeight: FontWeight.w400,
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ArabicCatalog.tryAnother,
                                  style: ArabicCatalog.ui(
                                    fontSize: OTFontSize.s12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding:
                              EdgeInsets.fromLTRB(pageInset, 8, pageInset, 40),
                          sliver: Builder(builder: (context) {
                            final delegate =
                                SliverChildBuilderDelegate((context, index) {
                              final book = visibleBooks[index];
                              return _BookEditorialItem(
                                  book: book,
                                  index: index + 1,
                                  onTap: () async {
                                    if (_opening) return;
                                    if (widget.onOpenBook != null) {
                                      widget.onOpenBook!(book);
                                      return;
                                    }
                                    _opening = true;
                                    try {
                                      await Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  OpenTurathBookDetailPage(
                                                      book: book)));
                                    } finally {
                                      _opening = false;
                                    }
                                  });
                            }, childCount: visibleBooks.length);
                            if (_list || largeText || columns == 1) {
                              final readingColumns =
                                  bookReadingColumns(context, available);
                              return SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                      (context, row) => bookReadingRow(
                                          context,
                                          row,
                                          readingColumns,
                                          visibleBooks.length,
                                          (context, index) => delegate.builder(
                                              context, index)!),
                                      childCount:
                                          (visibleBooks.length / readingColumns)
                                              .ceil()));
                            }
                            return SliverGrid(
                                delegate: delegate,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent:
                                            MediaQuery.textScalerOf(context)
                                                .scale(280)));
                          }),
                        ),
                    ],
                  ),
                ),
              )));
    });
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
  Widget build(BuildContext context) =>
      OTChip(label: label, selected: isSelected, onSelected: onTap);
}

class _BookEditorialItem extends StatelessWidget {
  const _BookEditorialItem(
      {required this.book, required this.index, required this.onTap});
  final OpenTurathBook book;
  final int index;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => BookIdentityCard(
        title: book.title,
        author: ArabicCatalog.authorName(book.author),
        deathLabel: ArabicCatalog.death(book.deathYear, book.deathText),
        facts: [
          ArabicCatalog.volumes(book.volumes),
          ArabicCatalog.pages(book.pages)
        ].whereType<String>().toList(),
        onTap: onTap,
      );
}

class OpenTurathBookDetailPage extends StatelessWidget {
  const OpenTurathBookDetailPage({
    super.key,
    required this.book,
  });

  final OpenTurathBook book;

  static String _atau(String v) =>
      v.trim().isEmpty || v.trim() == ArabicCatalog.notStated
          ? ArabicCatalog.notStatedShort
          : v.trim();

  /// Teks rujukan Arab lengkap untuk disalin atau disimpan.
  String get _citation {
    final death = ArabicCatalog.death(book.deathYear, book.deathText);
    final b = StringBuffer()
      ..writeln('${ArabicCatalog.lTitle}: ${book.title}')
      ..writeln(
          '${ArabicCatalog.lAuthor}: ${ArabicCatalog.authorName(book.author)}'
          '${death == null ? '' : ' ($death)'}')
      ..writeln('${ArabicCatalog.lEditor}: ${_atau(book.editorName)}');
    if (book.supervisor.isNotEmpty) {
      b.writeln('${ArabicCatalog.lSupervisor}: ${book.supervisor}');
    }
    b
      ..writeln('${ArabicCatalog.lPublisher}: ${_atau(book.publisher)}')
      ..writeln('${ArabicCatalog.lEdition}: ${_atau(book.edition)}');
    final facts = [
      ArabicCatalog.volumes(book.volumes),
      ArabicCatalog.pages(book.pages)
    ].whereType<String>();
    if (facts.isNotEmpty) b.writeln(facts.join(' · '));
    b.write('${ArabicCatalog.lScience}: ${book.section}');
    return b.toString();
  }

  Future<void> _handleBookmark(BuildContext context) async {
    final uid = AuthService().currentUser?.uid;
    final bookmark = BookmarkModel(
      id: 'book_${book.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: book.title,
      agentId: 'pustaka_turats',
      agentTitle: book.section,
      fieldName: book.section,
      fieldId: 'pustaka',
      arabicExcerpt: book.title,
      fullAnswer: _citation,
      bookReference: '${book.title} - ${ArabicCatalog.authorName(book.author)}',
      pageNumber: ArabicCatalog.pages(book.pages) ?? '',
      author: book.author,
      createdAt: DateTime.now(),
      documentKind: BookmarkDocumentKind.bookReference,
      verificationStatus: book.needsMetadataReview
          ? BookmarkVerificationStatus.needsReview
          : BookmarkVerificationStatus.unverified,
    );

    await BookmarkService().addBookmark(bookmark, userId: uid);
    if (context.mounted) AppSnackBar.success(context, ArabicCatalog.saved);
  }

  Future<void> _handleCopyCitation(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: '$_citation\n[OpenTurath]'));
    if (context.mounted) AppSnackBar.success(context, ArabicCatalog.copied);
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final death = ArabicCatalog.death(book.deathYear, book.deathText);

    return Theme(
      data: ArabicCatalog.theme(Theme.of(context)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: canvas,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_rounded,
                              color: ink, size: 22),
                          tooltip: ArabicCatalog.back,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ArabicCatalog.bookCard,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ArabicCatalog.ui(
                                fontSize: OTFontSize.s20,
                                fontWeight: FontWeight.w700,
                                color: ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OTBentoTile(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(book.title,
                                      textAlign: TextAlign.start,
                                      style: ScholarlyFonts.scheherazadeNew(
                                          fontSize: OTFontSize.s36,
                                          fontWeight: FontWeight.w700,
                                          color: ink,
                                          height: 1.6)),
                                  const SizedBox(height: 8),
                                  Text(ArabicCatalog.authorName(book.author),
                                      textAlign: TextAlign.start,
                                      style: ScholarlyFonts.scheherazadeNew(
                                          fontSize: OTFontSize.s20,
                                          color: textSecondary,
                                          height: 1.7)),
                                  const SizedBox(height: 12),
                                  Wrap(spacing: 16, runSpacing: 8, children: [
                                    if (death != null)
                                      Text(death,
                                          style: ArabicCatalog.ui(
                                              fontSize: OTFontSize.s14,
                                              color: textSecondary)),
                                    if (book.section.isNotEmpty)
                                      Text(book.section,
                                          style: ArabicCatalog.ui(
                                              fontSize: OTFontSize.s14,
                                              color: textSecondary)),
                                  ]),
                                  const SizedBox(height: 20),
                                  Wrap(spacing: 12, runSpacing: 8, children: [
                                    FilledButton.icon(
                                        onPressed: () =>
                                            _handleCopyCitation(context),
                                        icon: const Icon(Icons.copy_rounded,
                                            size: 18),
                                        label: const Text(
                                            ArabicCatalog.copyCitation)),
                                    OutlinedButton.icon(
                                        onPressed: () =>
                                            _handleBookmark(context),
                                        icon: const Icon(
                                            Icons.bookmark_add_outlined,
                                            size: 18),
                                        label:
                                            const Text(ArabicCatalog.saveNote)),
                                  ]),
                                ],
                              ),
                            ),
                            const SizedBox(height: OTSpacing.md),
                            _BookBentoGrid(book: book),
                            const SizedBox(height: OTSpacing.md),
                            Text(ArabicCatalog.notice,
                                style: ArabicCatalog.ui(
                                    fontSize: OTFontSize.s12,
                                    color: textSecondary)),
                            if (book.needsMetadataReview)
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: OTSpacing.sm),
                                  child: Text(ArabicCatalog.reviewNotice,
                                      style: ArabicCatalog.ui(
                                          fontSize: OTFontSize.s14,
                                          fontWeight: FontWeight.w600,
                                          color: ink))),
                          ],
                        ),
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

/// Tabel بيانات الطبعة: satu permukaan dengan garis pemisah. Kolom yang tidak
/// disebut sumber ditulis «غير مذكور في المصدر» (untuk المحقق/الناشر/الطبعة)
/// atau tidak ditampilkan (kolom tambahan).
class _BookBentoGrid extends StatelessWidget {
  const _BookBentoGrid({required this.book});

  final OpenTurathBook book;

  static bool _has(String value) =>
      value.trim().isNotEmpty &&
      value.trim() != '-' &&
      value.trim() != ArabicCatalog.notStated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rows = <_BentoTile>[
      if (ArabicCatalog.volumes(book.volumes) != null)
        _BentoTile(
            icon: Icons.layers_outlined,
            label: ArabicCatalog.lVolumes,
            value: ArabicCatalog.number(book.volumes)),
      if (ArabicCatalog.pages(book.pages) != null)
        _BentoTile(
            icon: Icons.description_outlined,
            label: ArabicCatalog.lPages,
            value: ArabicCatalog.number(book.pages)),
      _BentoTile(
          icon: Icons.edit_outlined,
          label: ArabicCatalog.lEditor,
          value: _has(book.editorName)
              ? book.editorName
              : ArabicCatalog.notStatedShort),
      if (_has(book.supervisor))
        _BentoTile(
            icon: Icons.school_outlined,
            label: ArabicCatalog.lSupervisor,
            value: book.supervisor),
      _BentoTile(
          icon: Icons.apartment_outlined,
          label: ArabicCatalog.lPublisher,
          value: _has(book.publisher)
              ? book.publisher
              : ArabicCatalog.notStatedShort),
      _BentoTile(
          icon: Icons.bookmark_border_rounded,
          label: ArabicCatalog.lEdition,
          value: _has(book.edition)
              ? ArabicCatalog.digits(book.edition)
              : ArabicCatalog.notStatedShort),
      if (_has(book.bookType))
        _BentoTile(
            icon: Icons.workspace_premium_outlined,
            label: ArabicCatalog.lType,
            value: book.bookType),
      if (_has(book.editionWarning))
        _BentoTile(
            icon: Icons.info_outline_rounded,
            label: ArabicCatalog.lWarning,
            value: book.editionWarning),
      if (_has(book.editionNote))
        _BentoTile(
            icon: Icons.info_outline_rounded,
            label: ArabicCatalog.lWarning,
            value: book.editionNote),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.base, OTSpacing.md, OTSpacing.base, OTSpacing.xs),
      decoration: BoxDecoration(
        color: OTColors.surface(isDark),
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: OTColors.surface(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ArabicCatalog.edition,
            style: ArabicCatalog.ui(
                fontSize: OTFontSize.s14,
                fontWeight: FontWeight.w700,
                color: OTColors.textSecondary(isDark)),
          ),
          const SizedBox(height: OTSpacing.xs),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: OTColors.borderSubtle(isDark)),
            OTReveal(index: i, child: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final kosong = value == ArabicCatalog.notStatedShort;

    final valueText = Text(
      value.trim(),
      textAlign: TextAlign.start,
      style: kosong
          ? ArabicCatalog.ui(fontSize: OTFontSize.s14, color: textSecondary)
          : ScholarlyFonts.scheherazadeNew(
              fontSize: OTFontSize.s20, height: 1.7, color: ink),
    );
    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: OTSpacing.sm),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArabicCatalog.ui(
                fontSize: OTFontSize.s14, color: textSecondary),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
      child: LayoutBuilder(builder: (context, box) {
        if (box.maxWidth < 560) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                labelRow,
                const SizedBox(height: OTSpacing.xs),
                valueText
              ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(width: 168, child: labelRow),
          const SizedBox(width: OTSpacing.lg),
          Expanded(child: valueText),
        ]);
      }),
    );
  }
}
