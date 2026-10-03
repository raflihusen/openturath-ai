import '../widgets/desktop_shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_snackbar.dart';
import '../core/arabic_utils.dart';
import '../core/design/ot_colors.dart';
import '../widgets/ot_motion_widgets.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/bookmark_model.dart';
import '../models/open_turath_book.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';

/// Halaman Katalog Kitab Editorial OpenTurath (Monochrome Editorial)
class OpenTurathBookLibraryPage extends StatefulWidget {
  const OpenTurathBookLibraryPage({
    super.key,
    required this.books,
    required this.collectionName,
    this.onOpenBook,
  });

  final List<OpenTurathBook> books;
  final String collectionName;
  final ValueChanged<OpenTurathBook>? onOpenBook;

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
    final surface = OTColors.surface(isDark);
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

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
                          tooltip: Loc.tr('back'),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      Loc.tr('bookCatalog'),
                      style: ScholarlyFonts.outfit(
                        color: ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.collectionName,
                      style: ScholarlyFonts.outfit(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: ScholarlyFonts.outfit(color: ink, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: Loc.tr('ui_0ae09a2807'),
                        hintStyle: ScholarlyFonts.outfit(
                            color: textSecondary, fontSize: 13),
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
                        fillColor: surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: OTRadius.inputBorder,
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: OTRadius.inputBorder,
                          borderSide: BorderSide(color: border),
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
                            onTap: () =>
                                setState(() => _filter = _BookVolumeFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: Loc.tr('singleVolume'),
                            isSelected:
                                _filter == _BookVolumeFilter.singleVolume,
                            onTap: () => setState(
                                () => _filter = _BookVolumeFilter.singleVolume),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: Loc.tr('multipleVolumes'),
                            isSelected:
                                _filter == _BookVolumeFilter.multiVolume,
                            onTap: () => setState(
                                () => _filter = _BookVolumeFilter.multiVolume),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      Loc.tr('booksShown', [
                        '${visibleBooks.length}',
                        '${widget.books.length}',
                      ]),
                      style: ScholarlyFonts.outfit(
                        fontSize: 12,
                        color: textSecondary,
                      ),
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
                        Loc.tr('ui_54db73b3af'),
                        style: ScholarlyFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Loc.tr('ui_f7c779cb7d'),
                        style: ScholarlyFonts.outfit(
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
                // Grid kartu seragam: satu kolom di ponsel, dua atau tiga di layar lebar.
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent:
                        MediaQuery.textScalerOf(context).scale(220),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final book = visibleBooks[index];
                      return OTReveal(
                          index: index % 6,
                          child: _BookEditorialItem(
                        book: book,
                        index: index + 1,
                        onTap: () {
                          if (widget.onOpenBook != null) {
                            widget.onOpenBook!(book);
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  OpenTurathBookDetailPage(book: book),
                            ),
                          );
                        },
                      ));
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: surface,
      selectedColor: ink,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      shape: const StadiumBorder(),
      side: BorderSide(color: isSelected ? ink : border),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      labelStyle: ScholarlyFonts.outfit(
        color: isSelected ? OTColors.canvas(isDark) : ink,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _BookEditorialItem extends StatelessWidget {
  const _BookEditorialItem({
    required this.book,
    required this.index,
    required this.onTap,
  });

  final OpenTurathBook book;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    Widget fact(IconData icon, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    ScholarlyFonts.outfit(fontSize: 12, color: textSecondary),
              ),
            ),
          ],
        );

    return OTBentoTile(
      onTap: onTap,
      semanticLabel: '${book.title}, ${book.author}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  book.localizedSection,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OTTypography.caption(color: textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                book.deathLabel,
                maxLines: 1,
                style: OTTypography.caption(color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Judul Arab asli, maksimal dua baris agar tinggi kartu seragam.
          Text(
            book.title,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ScholarlyFonts.scheherazadeNew(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
          const Spacer(),
          Text(
            Loc.tr('authorCredit', [book.author]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ScholarlyFonts.outfit(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: border),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(child: fact(Icons.layers_outlined, book.volumeLabel)),
              const SizedBox(width: 12),
              Flexible(
                  child:
                      fact(Icons.description_outlined, book.pagesLabel)),
              const Spacer(),
              Icon(Icons.arrow_forward_rounded,
                  color: textSecondary, size: 16),
            ],
          ),
        ],
      ),
    );
  }
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
      verificationStatus: BookmarkVerificationStatus.verified,
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
${Loc.tr('ui_ad39f1c3af')}: ${book.editor}
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
    final surface = OTColors.surface(isDark);
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

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
                      tooltip: Loc.tr('back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        Loc.tr('bookReferenceLabel'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ScholarlyFonts.outfit(
                          color: ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy_rounded, color: ink, size: 20),
                      tooltip: Loc.tr('bookCitationCopy'),
                      onPressed: () => _handleCopyCitation(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.bookmark_add_outlined,
                          color: ink, size: 20),
                      tooltip: Loc.tr('bookSave'),
                      onPressed: () => _handleBookmark(context),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                child: Center(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Card Kitab
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                  child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: OTColors.primaryContainer(isDark),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  book.localizedSection,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: ScholarlyFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: OTColors.onPrimaryContainer(isDark),
                                  ),
                                ),
                              )),
                              const SizedBox(width: 12),
                              Text(
                                book.deathLabel,
                                style: ScholarlyFonts.outfit(
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
                                style: ScholarlyFonts.scheherazadeNew(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: ink,
                                  height: 1.85,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            book.author,
                            style: ScholarlyFonts.scheherazadeNew(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ink,
                              height: 1.85,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      Loc.tr('bookRecordMetadata'),
                      style: ScholarlyFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BookBentoGrid(book: book),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleCopyCitation(context),
                        icon: const Icon(Icons.content_copy_rounded, size: 18),
                        label: Text(
                          Loc.tr('ui_3f42b695cf'),
                          style: ScholarlyFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ink,
                          side: BorderSide(color: border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
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
      if (_has(book.edition))
        _BentoTile(
          icon: Icons.bookmark_border_rounded,
          label: Loc.tr('bookEdition'),
          value: book.edition,
        ),
    ];
    final wide = <_BentoTile>[
      if (_has(book.editor))
        _BentoTile(
          icon: Icons.edit_outlined,
          label: Loc.tr('ui_ad39f1c3af'),
          value: book.editor,
          wide: true,
        ),
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

    return LayoutBuilder(builder: (context, constraints) {
      const gap = OTSpacing.md;
      final width = constraints.maxWidth;
      // Kolom fakta mengikuti lebar: 2 di ponsel, 3 bila ruang cukup.
      final columns = facts.isEmpty
          ? 1
          : (width >= 560 ? facts.length.clamp(1, 3) : facts.length.clamp(1, 2));
      final factWidth = (width - gap * (columns - 1)) / columns;
      final wideColumns = width >= 560 && wide.length == 2 ? 2 : 1;
      final wideWidth = (width - gap * (wideColumns - 1)) / wideColumns;

      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < facts.length; i++)
            SizedBox(
                width: factWidth,
                child: OTReveal(index: i, child: facts[i])),
          for (var i = 0; i < wide.length; i++)
            SizedBox(
                width: wideWidth,
                child: OTReveal(index: facts.length + i, child: wide[i])),
        ],
      );
    });
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
    final isArabic = RegExp(r'[؀-ۿ]').hasMatch(displayValue);

    return Container(
      constraints: BoxConstraints(minHeight: wide ? 0 : 112),
      padding: const EdgeInsets.all(OTSpacing.base),
      decoration: BoxDecoration(
        color: OTColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OTColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: textSecondary),
              const SizedBox(width: OTSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ScholarlyFonts.outfit(
                      fontSize: 12, color: textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: wide ? OTSpacing.sm : OTSpacing.base),
          SizedBox(
            width: double.infinity,
            child: Text(
              displayValue,
              textDirection: isArabic ? TextDirection.rtl : null,
              style: isArabic
                  ? ScholarlyFonts.scheherazadeNew(
                      fontSize: wide ? 18 : 20,
                      height: 1.7,
                      fontWeight: FontWeight.w600,
                      color: ink)
                  : ScholarlyFonts.outfit(
                      fontSize: wide ? 15 : 20,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: ink),
            ),
          ),
        ],
      ),
    );
  }
}
