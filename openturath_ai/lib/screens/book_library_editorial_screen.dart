import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_layout.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../models/bookmark_model.dart';
import '../models/open_turath_book.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../widgets/ot_mobile_primitives.dart';

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

enum _BookVolumeFilter { all, singleVolume, multiVolume }

class _OpenTurathBookLibraryPageState extends State<OpenTurathBookLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  _BookVolumeFilter _filter = _BookVolumeFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          ].join(' ').toLowerCase().contains(_query);
      if (!matchesQuery) return false;

      final volumes = book.volumes.trim();
      final volumeCount = int.tryParse(volumes);
      return switch (_filter) {
        _BookVolumeFilter.all => true,
        _BookVolumeFilter.singleVolume =>
          volumes == '1' || volumes.toLowerCase().contains('jilid tunggal'),
        _BookVolumeFilter.multiVolume =>
          (volumeCount != null && volumeCount > 1) ||
              volumes.contains('+') ||
              volumes.contains('-'),
      };
    }).toList();
  }

  void _openBook(OpenTurathBook book) {
    if (widget.onOpenBook != null) {
      widget.onOpenBook!(book);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OpenTurathBookDetailPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final visibleBooks = _filteredBooks;

    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      appBar: AppBar(
        title: const Text('Katalog kitab'),
        backgroundColor: OTColors.canvas(dark),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: OTConstrainedContent(
          maxWidth: OTLayout.catalogueWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: OTSpacing.sm),
              Text(
                widget.collectionName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: OTTypography.body(
                  color: OTColors.textSecondary(dark),
                ),
              ),
              const SizedBox(height: OTSpacing.md),
              OTSearchField(
                controller: _searchController,
                hintText: 'Cari kitab, pengarang, atau penerbit',
                onChanged: (value) {
                  setState(() => _query = value.trim().toLowerCase());
                },
              ),
              const SizedBox(height: OTSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _VolumeChip(
                      label: 'Semua',
                      selected: _filter == _BookVolumeFilter.all,
                      onTap: () =>
                          setState(() => _filter = _BookVolumeFilter.all),
                    ),
                    _VolumeChip(
                      label: 'Satu jilid',
                      selected: _filter == _BookVolumeFilter.singleVolume,
                      onTap: () => setState(
                        () => _filter = _BookVolumeFilter.singleVolume,
                      ),
                    ),
                    _VolumeChip(
                      label: 'Beberapa jilid',
                      selected: _filter == _BookVolumeFilter.multiVolume,
                      onTap: () => setState(
                        () => _filter = _BookVolumeFilter.multiVolume,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OTSpacing.md),
              Text(
                '${visibleBooks.length} dari ${widget.books.length} kitab',
                style: OTTypography.caption(
                  color: OTColors.textSecondary(dark),
                ),
              ),
              const SizedBox(height: OTSpacing.xs),
              Expanded(
                child: visibleBooks.isEmpty
                    ? const OTEmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'Kitab tidak ditemukan',
                        message:
                            'Coba judul, nama pengarang, atau penerbit yang lain.',
                      )
                    : OTGroupedSection(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OTSpacing.base,
                        ),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 40),
                          itemCount: visibleBooks.length,
                          itemBuilder: (context, index) => _BookRow(
                            book: visibleBooks[index],
                            onTap: () => _openBook(visibleBooks[index]),
                          ),
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

class _VolumeChip extends StatelessWidget {
  const _VolumeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: OTSpacing.sm),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        label: Text(label),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.book, required this.onTap});

  final OpenTurathBook book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final details = [book.volumeLabel, book.pagesLabel]
        .where((value) => value.trim().isNotEmpty)
        .join(' · ');

    return InkWell(
      onTap: onTap,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.section,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OTTypography.metadataTag(
                              color: OTColors.textSecondary(dark),
                            ),
                          ),
                        ),
                        Text(
                          book.deathLabel,
                          style: OTTypography.caption(
                            color: OTColors.textSecondary(dark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OTSpacing.sm),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: OTTypography.arabicReading(
                        color: OTColors.textPrimary(dark),
                      ).copyWith(fontSize: 23, height: 1.55),
                    ),
                    const SizedBox(height: OTSpacing.xs),
                    Text(
                      book.author,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.captionMedium(
                        color: OTColors.textPrimary(dark),
                      ),
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: OTSpacing.xs),
                      Text(
                        details,
                        style: OTTypography.caption(
                          color: OTColors.textSecondary(dark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: OTSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 36),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: OTColors.textTertiary(dark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OpenTurathBookDetailPage extends StatelessWidget {
  const OpenTurathBookDetailPage({super.key, required this.book});

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
      fullAnswer:
          'Kitab ${book.title} karya ${book.author} (${book.deathLabel}). Tahqiq: ${book.editor}. Penerbit: ${book.publisher} (${book.edition}). Jilid: ${book.volumeLabel} (${book.pagesLabel}).',
      bookReference: '${book.title} - ${book.author}',
      pageNumber: book.pagesLabel,
      author: book.author,
      createdAt: DateTime.now(),
      documentKind: BookmarkDocumentKind.bookReference,
      verificationStatus: BookmarkVerificationStatus.verified,
    );
    await BookmarkService().addBookmark(bookmark, userId: uid);
    if (context.mounted) {
      AppSnackBar.success(context, 'Kitab disimpan ke Catatan');
    }
  }

  Future<void> _handleCopyCitation(BuildContext context) async {
    final citation = '''Rujukan kitab
Judul: ${book.title}
Pengarang: ${book.author} (${book.deathLabel})
Tahqiq: ${book.editor}
Penerbit: ${book.publisher} (${book.edition})
Jilid: ${book.volumeLabel}
Halaman: ${book.pagesLabel}
Bidang: ${book.section}''';
    await Clipboard.setData(ClipboardData(text: citation));
    if (context.mounted) {
      AppSnackBar.success(context, 'Rujukan berhasil disalin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      appBar: AppBar(
        title: const Text('Kitab'),
        backgroundColor: OTColors.canvas(dark),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Salin rujukan',
            onPressed: () => _handleCopyCitation(context),
            icon: const Icon(Icons.copy_outlined),
          ),
          IconButton(
            tooltip: 'Simpan ke Catatan',
            onPressed: () => _handleBookmark(context),
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: OTConstrainedContent(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: OTSpacing.sm, bottom: 40),
            children: [
              OTGroupedSection(
                padding: const EdgeInsets.all(OTSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.section.toUpperCase(),
                      style: OTTypography.metadataTag(
                        color: OTColors.textSecondary(dark),
                      ),
                    ),
                    const SizedBox(height: OTSpacing.md),
                    Text(
                      book.title,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: OTTypography.arabicReading(
                        color: OTColors.textPrimary(dark),
                      ).copyWith(fontSize: 27, height: 1.4),
                    ),
                    const SizedBox(height: OTSpacing.md),
                    Text(
                      book.author,
                      style: OTTypography.bodyMedium(
                        color: OTColors.textPrimary(dark),
                      ).copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: OTSpacing.xs),
                    Text(
                      book.deathLabel,
                      style: OTTypography.caption(
                        color: OTColors.textSecondary(dark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OTSpacing.xl),
              const OTSectionHeader(title: 'Data penerbitan'),
              const SizedBox(height: OTSpacing.sm),
              OTGroupedSection(
                padding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.base,
                ),
                child: Column(
                  children: [
                    _BookDetailRow(label: 'Tahqiq', value: book.editor),
                    _BookDetailRow(label: 'Penerbit', value: book.publisher),
                    _BookDetailRow(label: 'Cetakan', value: book.edition),
                    _BookDetailRow(label: 'Jilid', value: book.volumeLabel),
                    _BookDetailRow(
                      label: 'Halaman',
                      value: book.pagesLabel,
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OTSpacing.xl),
              OutlinedButton.icon(
                onPressed: () => _handleCopyCitation(context),
                icon: const Icon(Icons.content_copy_outlined, size: 18),
                label: const Text('Salin rujukan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookDetailRow extends StatelessWidget {
  const _BookDetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty || value.trim() == '-'
        ? 'Belum tercatat'
        : value.trim();
    return OTEditorialRow(
      title: label,
      subtitle: displayValue,
      showDivider: showDivider,
    );
  }
}
