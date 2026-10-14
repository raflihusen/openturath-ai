import '../widgets/book_reading_rows.dart';
import '../widgets/desktop_shortcuts.dart';
import '../widgets/book_identity_card.dart';
import 'package:flutter/material.dart';
import '../core/design/native_design.dart';
import 'package:flutter/services.dart';

import '../core/app_snackbar.dart';
import '../core/arabic_utils.dart';
import '../core/answer_direction.dart';
import '../widgets/tahawwulat_hero.dart';
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
      return Scaffold(
        backgroundColor: canvas,
        appBar: AppBar(
          titleSpacing: otTitleSpacing(context),
          backgroundColor: canvas,
          title: Text(widget.collectionName),
          actions: [
            if (widget.metadata != null)
              IconButton(
                tooltip: 'Info AI',
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
                  padding: EdgeInsets.fromLTRB(pageInset, 8, pageInset, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.metadata != null) ...[
                        Text(
                            '${Loc.tr('bookCount', [
                                  '${widget.metadata!.totalKitab}'
                                ])} · ${widget.metadata!.totalJilid}',
                            style: OTTypography.caption(color: textSecondary)),
                        const SizedBox(height: 12),
                      ],
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: ScholarlyFonts.outfit(
                            color: ink, fontSize: OTFontSize.s14),
                        decoration: InputDecoration(
                          hintText: Loc.tr('ui_0ae09a2807'),
                          hintStyle: ScholarlyFonts.outfit(
                              color: textSecondary, fontSize: OTFontSize.s14),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: textSecondary, size: 20),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  tooltip: Loc.tr('clearSearch'),
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
                              label: Loc.tr('allBooks'),
                              isSelected: _filter == _BookVolumeFilter.all,
                              onTap: () => setState(
                                  () => _filter = _BookVolumeFilter.all),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: Loc.tr('singleVolume'),
                              isSelected:
                                  _filter == _BookVolumeFilter.singleVolume,
                              onTap: () => setState(() =>
                                  _filter = _BookVolumeFilter.singleVolume),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: Loc.tr('multipleVolumes'),
                              isSelected:
                                  _filter == _BookVolumeFilter.multiVolume,
                              onTap: () => setState(() =>
                                  _filter = _BookVolumeFilter.multiVolume),
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
                                width: available < 240 ? available - 100 : 180,
                                child: DropdownButton<_BookSort>(
                                    isExpanded: true,
                                    value: _sort,
                                    underline: const SizedBox.shrink(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _sort = v);
                                    },
                                    items: [
                                      DropdownMenuItem(
                                          value: _BookSort.title,
                                          child: Text(reviewCopy(
                                              'Judul', 'العنوان', 'Title'))),
                                      DropdownMenuItem(
                                          value: _BookSort.author,
                                          child: Text(reviewCopy('Pengarang',
                                              'المؤلف', 'Author'))),
                                      DropdownMenuItem(
                                          value: _BookSort.volumes,
                                          child: Text(reviewCopy('Jumlah jilid',
                                              'عدد الأجزاء', 'Volumes'))),
                                    ])),
                            IconButton.filledTonal(
                                tooltip: reviewCopy('Tampilan kartu',
                                    'عرض البطاقات', 'Card view'),
                                isSelected: !_list,
                                onPressed: () => setState(() => _list = false),
                                icon: const Icon(Icons.grid_view_rounded)),
                            IconButton.filledTonal(
                                tooltip: reviewCopy('Daftar ringkas',
                                    'قائمة مختصرة', 'Compact list'),
                                isSelected: _list,
                                onPressed: () => setState(() => _list = true),
                                icon: const Icon(Icons.view_list_rounded)),
                          ]),
                      const SizedBox(height: 8),
                      Text(
                        _query.isEmpty && _filter == _BookVolumeFilter.all
                            ? Loc.tr('bookCount', ['${visibleBooks.length}'])
                            : Loc.tr('booksShown', [
                                '${visibleBooks.length}',
                                '${widget.books.length}',
                              ]),
                        style: ScholarlyFonts.outfit(
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
                          Loc.tr('ui_54db73b3af'),
                          style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s16,
                            fontWeight: FontWeight.w400,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Loc.tr('ui_f7c779cb7d'),
                          style: ScholarlyFonts.outfit(
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
                  padding: EdgeInsets.fromLTRB(pageInset, 8, pageInset, 40),
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
                                      builder: (_) => OpenTurathBookDetailPage(
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
                                  (context, index) =>
                                      delegate.builder(context, index)!),
                              childCount: (visibleBooks.length / readingColumns)
                                  .ceil()));
                    }
                    return SliverGrid(
                        delegate: delegate,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent:
                                MediaQuery.textScalerOf(context).scale(280)));
                  }),
                ),
            ],
          ),
        ),
      );
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
        author: book.author,
        deathLabel: book.deathYear == null ? null : book.deathLabel,
        facts: [book.volumeLabel, book.pagesLabel]
            .where((v) => v != Loc.tr('unknownMetadata'))
            .toList(),
        onTap: onTap,
      );
}

class OpenTurathBookDetailPage extends StatelessWidget {
  const OpenTurathBookDetailPage({
    super.key,
    required this.book,
  });

  final OpenTurathBook book;

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
      fullAnswer: '${book.title}. ${Loc.tr('authorCredit', [book.author])}. '
          '${Loc.tr('editorCredit', [book.editor])}. '
          '${Loc.tr('bookPublisher')}: ${book.publisher} (${book.edition}). '
          '${book.volumeLabel}; ${book.pagesLabel}.',
      bookReference: '${book.title} - ${book.author}',
      pageNumber: book.pagesLabel,
      author: book.author,
      createdAt: DateTime.now(),
      documentKind: BookmarkDocumentKind.bookReference,
      verificationStatus: book.needsMetadataReview
          ? BookmarkVerificationStatus.needsReview
          : BookmarkVerificationStatus.unverified,
    );

    await BookmarkService().addBookmark(bookmark, userId: uid);
    if (context.mounted) {
      AppSnackBar.success(context, Loc.tr('ui_225b7ddde1'));
    }
  }

  Future<void> _handleCopyCitation(BuildContext context) async {
    final citation = '''[OpenTurath AI]
${Loc.tr('bookReferenceLabel')}: ${book.title}
${Loc.tr('authorCredit', [book.author])} (${book.deathLabel})
${Loc.tr('ui_ad39f1c3af')}: ${book.editorName.isEmpty ? Loc.tr('editorNotRecorded') : book.editorName}
${book.editionNote.isEmpty ? '' : '${Loc.tr('editionNote')}: ${book.editionNote}'}
${Loc.tr('bookPublisher')}: ${book.publisher} (${book.edition})
${book.volumeLabel} | ${book.pagesLabel}
${Loc.tr('bookScienceSection')}: ${book.section}''';

    await Clipboard.setData(ClipboardData(text: citation));
    if (context.mounted) {
      AppSnackBar.success(context, Loc.tr('ui_e150b5de89'));
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Scaffold(
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
                      icon:
                          Icon(Icons.arrow_back_rounded, color: ink, size: 22),
                      tooltip: Loc.tr('back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        Loc.tr('bookReferenceLabel'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OTTypography.screenTitle(color: ink),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OTBentoTile(
                                padding: const EdgeInsets.all(24),
                                child: Directionality(
                                    textDirection: answerDirection(book.title),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(book.title,
                                              textDirection:
                                                  answerDirection(book.title),
                                              textAlign: TextAlign.start,
                                              style: answerDirection(
                                                          book.title) ==
                                                      TextDirection.rtl
                                                  ? ScholarlyFonts
                                                      .scheherazadeNew(
                                                          fontSize:
                                                              OTFontSize.s36,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: ink,
                                                          height: 1.6)
                                                  : OTTypography.pageTitle(
                                                      color: ink)),
                                          const SizedBox(height: 8),
                                          Text(book.author,
                                              textDirection:
                                                  answerDirection(book.author),
                                              textAlign: TextAlign.start,
                                              style: ScholarlyFonts
                                                  .scheherazadeNew(
                                                      fontSize: OTFontSize.s18,
                                                      color: textSecondary,
                                                      height: 1.7)),
                                          const SizedBox(height: 16),
                                          Wrap(
                                              spacing: 16,
                                              runSpacing: 8,
                                              children: [
                                                Text(book.localizedSection,
                                                    style: OTTypography.body(
                                                        color: textSecondary)),
                                                if (book.deathYear != null &&
                                                    !RegExp(r'[0-9٠-٩]')
                                                        .hasMatch(book.author))
                                                  Text(book.deathLabel,
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      style: OTTypography.body(
                                                          color: textSecondary))
                                              ]),
                                          const SizedBox(height: 20),
                                          Wrap(
                                              spacing: 12,
                                              runSpacing: 8,
                                              children: [
                                                FilledButton.icon(
                                                    onPressed: () =>
                                                        _handleCopyCitation(
                                                            context),
                                                    icon: const Icon(
                                                        Icons.copy_rounded,
                                                        size: 18),
                                                    label: Text(Loc.tr(
                                                        'bookCitationCopy'))),
                                                OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _handleBookmark(
                                                            context),
                                                    icon: const Icon(
                                                        Icons
                                                            .bookmark_add_outlined,
                                                        size: 18),
                                                    label: Text(
                                                        Loc.tr('bookSave'))),
                                              ]),
                                        ]))),
                            const SizedBox(height: OTSpacing.md),
                            _BookBentoGrid(book: book),
                            const SizedBox(height: OTSpacing.md),
                            Text(Loc.tr('verificationNotice'),
                                style:
                                    OTTypography.caption(color: textSecondary)),
                            if (book.needsMetadataReview)
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: OTSpacing.sm),
                                  child: Text(Loc.tr('metadataReview'),
                                      style:
                                          OTTypography.bodyMedium(color: ink))),
                          ],
                        ))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data edisi kitab sebagai bento: fakta singkat di ubin kecil, teks panjang
/// (muhaqqiq, penerbit) di ubin lebar. Ubin tanpa data tidak ditampilkan.
class _BookBentoGrid extends StatelessWidget {
  const _BookBentoGrid({required this.book});

  final OpenTurathBook book;

  static bool _has(String value) => value.trim().isNotEmpty && value != '-';

  // Teks Arab atau panjang tidak muat sebagai angka besar di ubin kecil.
  static bool _isLong(String value) =>
      value.trim().length > 14 || RegExp(r'[\u0600-\u06FF]').hasMatch(value);

  @override
  Widget build(BuildContext context) {
    final facts = <_BentoTile>[
      if (_has(book.volumes))
        _BentoTile(
          icon: Icons.layers_outlined,
          label: Loc.tr('bookVolumes'),
          value: book.volumeLabel,
        ),
      if (_has(book.pages))
        _BentoTile(
          icon: Icons.description_outlined,
          label: Loc.tr('bookPages'),
          value: book.pagesLabel,
        ),
      if (_has(book.edition) && !_isLong(book.edition))
        _BentoTile(
          icon: Icons.bookmark_border_rounded,
          label: Loc.tr('bookEdition'),
          value: book.edition,
        ),
    ];
    final wide = <_BentoTile>[
      if (_has(book.edition) && _isLong(book.edition))
        _BentoTile(
          icon: Icons.bookmark_border_rounded,
          label: Loc.tr('bookEdition'),
          value: book.edition,
          wide: true,
        ),
      _BentoTile(
        icon: Icons.edit_outlined,
        label: Loc.tr('ui_ad39f1c3af'),
        value: book.editorName.isEmpty
            ? Loc.tr('editorNotRecorded')
            : book.editorName,
        wide: true,
      ),
      if (_has(book.editionNote))
        _BentoTile(
            icon: Icons.info_outline_rounded,
            label: Loc.tr('editionNote'),
            value: book.editionNote,
            wide: true),
      if (_has(book.publisher))
        _BentoTile(
          icon: Icons.apartment_outlined,
          label: Loc.tr('bookPublisher'),
          value: book.publisher,
          wide: true,
        ),
    ];
    if (facts.isEmpty && wide.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
        child: Text(Loc.tr('unknownMetadata')),
      );
    }

    // Satu tabel identitas edisi: kartu hanya untuk benda yang bisa dibuka,
    // jadi fakta-fakta ini berbagi satu permukaan dengan garis pemisah.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rows = [...facts, ...wide];
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
            NativeCopy.text('edition').toUpperCase(),
            style: OTTypography.sectionHeading(
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
    this.wide = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final displayValue = value.trim();
    final isArabic = answerDirection(displayValue) == TextDirection.rtl;

    final valueText = Text(
      displayValue,
      textDirection: answerDirection(displayValue),
      textAlign: TextAlign.start,
      style: isArabic
          ? ScholarlyFonts.scheherazadeNew(
              fontSize: OTFontSize.s18, height: 1.7, color: ink)
          : OTTypography.bodyMedium(color: ink),
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
            style: OTTypography.caption(color: textSecondary),
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
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 168, child: labelRow),
          const SizedBox(width: OTSpacing.lg),
          Expanded(child: valueText),
        ]);
      }),
    );
  }
}
