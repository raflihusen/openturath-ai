import '../core/l10n/app_dictionary.dart';
import '../core/l10n/library_dictionary.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../models/book_model.dart';
import '../models/bookmark_model.dart';
import '../models/open_turath_book.dart';
import '../services/bookmark_service.dart';
import '../services/auth_service.dart';
import '../widgets/book_row_item.dart';
import '../widgets/editorial.dart';

class OpenTurathBookLibraryPage extends StatefulWidget {
  const OpenTurathBookLibraryPage({super.key, required this.books,
    required this.collectionName, this.collectionKey, this.onOpenBook});
  final List<OpenTurathBook> books;
  final String collectionName;
  final String? collectionKey;
  final ValueChanged<OpenTurathBook>? onOpenBook;

  @override
  State<OpenTurathBookLibraryPage> createState() => _OpenTurathBookLibraryPageState();
}

class _OpenTurathBookLibraryPageState extends State<OpenTurathBookLibraryPage> {
  final _search = TextEditingController();
  String _query = '';
  int _volumeFilter = 0;

  String _normalize(String value) => value.toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
      .replaceAll(RegExp('[أإآ]'), 'ا').replaceAll('ى', 'ي');

  int? _volumes(OpenTurathBook book) {
    var value = book.volumes.trim();
    const digits = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < digits.length; i++) { value = value.replaceAll(digits[i], '$i'); }
    if (value.toLowerCase().contains('jilid tunggal')) return 1;
    return int.tryParse(value) ?? int.tryParse(RegExp(r'^\d+(?=\s|$)').firstMatch(value)?.group(0) ?? '');
  }

  List<OpenTurathBook> get _books => widget.books.where((book) {
    final matches = _normalize([book.title, book.shortName, book.author,
      book.editor, book.publisher, book.section].join(' ')).contains(_normalize(_query));
    final volumes = _volumes(book);
    return matches && (_volumeFilter == 0 ||
      (_volumeFilter == 1 && volumes == 1) || (_volumeFilter == 2 && volumes != null && volumes > 1));
  }).toList();

  void _reset() { _search.clear(); setState(() { _query = ''; _volumeFilter = 0; }); }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final books = _books;
    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: CustomScrollView(slivers: [
          SliverPadding(padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
            sliver: SliverToBoxAdapter(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                EditorialHeader(title: context.tr('library.catalog'), eyebrow: context.tr('library.eyebrow'),
                  subtitle: libraryCollectionTitle(widget.collectionKey ?? '', widget.collectionName, context.languageCode), showBack: true),
                const SizedBox(height: 24),
                EditorialSearchField(controller: _search,
                  onChanged: (value) => setState(() => _query = value.trim()),
                  hintText: context.tr('library.search')),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (var i = 0; i < 3; i++) ChoiceChip(
                    label: Text([context.tr('library.all'), context.tr('library.single'), context.tr('library.multiple')][i]),
                    selected: _volumeFilter == i,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    onSelected: (_) => setState(() => _volumeFilter = i)),
                  if (_query.isNotEmpty || _volumeFilter != 0)
                    TextButton(onPressed: _reset, child: Text(context.tr('library.clear'))),
                ]),
                const SizedBox(height: 24),
                Text(context.tr('library.count', args: {'count': libraryBidi(context.uiNumber(books.length), context.languageCode), 'total': libraryBidi(context.uiNumber(widget.books.length), context.languageCode)}),
                  style: OTTypography.caption(color: OTColors.textSecondary(dark))),
                const SizedBox(height: 16),
              ],
            ))),
          if (books.isEmpty)
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(24),
              child: EditorialEmptyState(
                title: widget.books.isEmpty ? context.tr('library.unavailable') : context.tr('library.no_match'),
                description: widget.books.isEmpty ? context.tr('library.no_catalog') : context.tr('library.search_again'),
                action: widget.books.isEmpty ? null : EditorialButton(label: context.tr('library.clear'), onPressed: _reset))))
          else SliverPadding(padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 40),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
              final book = books[index];
              return Padding(padding: const EdgeInsets.only(bottom: 12), child: BookRowItem(
                book: CanonicalBookPresentation(editionId: '${book.id}', titleArabic: book.title,
                  authorArabic: book.author, sectionArabic: book.section,
                  verifiedDeathYearHijri: book.deathYear, volumesCount: _volumes(book)),
                onTap: () {
                  if (widget.onOpenBook != null) { widget.onOpenBook!(book); return; }
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => OpenTurathBookDetailPage(book: book)));
                },
              ));
            }, childCount: books.length))),
        ]),
      ))),
    );
  }
}

class OpenTurathBookDetailPage extends StatefulWidget {
  const OpenTurathBookDetailPage({super.key, required this.book});
  final OpenTurathBook book;

  @override
  State<OpenTurathBookDetailPage> createState() => _OpenTurathBookDetailPageState();
}

class _OpenTurathBookDetailPageState extends State<OpenTurathBookDetailPage> {
  String? _currentUid() {
    try { return AuthService().currentUser?.uid; }
    catch (_) { return null; }
  }
  late final String? _ownerUid;
  bool _saved = false;
  bool _busy = false;
  // Include source identity because numerical IDs may repeat across collections.
  String get _bookmarkId => 'book_ot_${sha256.convert(utf8.encode('${widget.book.sourceFolder}|${widget.book.id}|${widget.book.title}'))}';
  String get _citation {
    final book = widget.book;
    String field(String key, String? value, {bool source = false}) {
      final clean = value?.trim();
      final text = clean == null || clean.isEmpty || clean == '-'
          ? context.tr('library.unknown')
          : source
              ? libraryBidi(librarySourceLabel(clean, context.languageCode), context.languageCode)
              : libraryDataLabel(clean, context.languageCode);
      return '${context.tr('library.$key')}: \u2068$text\u2069';
    }
    return [
      field('book', book.title, source: true),
      field('author', book.author, source: true),
      field('death', book.deathYear == null ? null : context.tr(
        'library.year', args: {'year': libraryBidi('${book.deathYear}', context.languageCode)})),
      field('editor', book.editor, source: true),
      field('publisher', book.publisher, source: true),
      field('print_year', book.edition),
      field('volumes', book.volumes),
      field('pages', book.pages),
      field('field', book.section),
    ].join('\n');
  }

  @override
  void initState() {
    super.initState();
    _ownerUid = _currentUid();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await BookmarkService().isBookmarked(_bookmarkId, userId: _ownerUid);
      if (mounted && _currentUid() == _ownerUid && !_busy) setState(() => _saved = saved);
    } catch (_) { /* Saving remains retryable when initial local lookup fails. */ }
  }

  Future<void> _toggleBookmark() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_currentUid() != _ownerUid) {
        throw StateError(context.tr('library.account_changed'));
      }
      if (_saved) { await BookmarkService().deleteBookmark(_bookmarkId, userId: _ownerUid); }
      else {
        final book = widget.book;
        await BookmarkService().addBookmark(BookmarkModel(
          id: _bookmarkId, title: book.title, agentId: 'pustaka_turats',
          agentTitle: book.section, fieldName: book.section, fieldId: 'pustaka',
          arabicExcerpt: book.title, fullAnswer: _citation, bookReference: book.title,
          pageNumber: '', author: book.author, createdAt: DateTime.now(),
          documentKind: BookmarkDocumentKind.bookReference,
          verificationStatus: BookmarkVerificationStatus.needsReview,
        ), userId: _ownerUid);
      }
      if (mounted) {
        setState(() => _saved = !_saved);
        AppSnackBar.success(context, _saved ? context.tr('library.saved') : context.tr('library.removed'));
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.tr('library.reference_failed'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: _citation));
      if (mounted) AppSnackBar.success(context, context.tr('library.copied'));
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.tr('library.copy_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return EditorialPage(maxWidth: 720, showBack: true, title: context.tr('library.reference'),
      eyebrow: context.tr('library.detail_eyebrow'), children: [
        EditorialArabicText(book.title, fontSize: 30),
        const SizedBox(height: 24),
        Wrap(spacing: 12, runSpacing: 12, children: [
          EditorialButton(label: _saved ? context.tr('library.saved_button') : context.tr('library.save'),
            icon: _saved ? Icons.bookmark : Icons.bookmark_border,
            busy: _busy, onPressed: _busy ? null : _toggleBookmark),
          EditorialButton(label: context.tr('library.copy'), icon: Icons.copy_outlined,
            secondary: true, onPressed: _copy),
        ]),
        const SizedBox(height: 40),
        EditorialSection(title: context.tr('library.author'), child: Column(children: [
          BibliographicField(sourceText: true, label: context.tr('library.author_name'), value: book.author),
          BibliographicField(label: context.tr('library.death'), value: book.deathYear == null ? null : context.tr('library.year', args: {'year': libraryBidi('${book.deathYear}', context.languageCode)})),
        ])),
        const SizedBox(height: 32),
        EditorialSection(title: context.tr('library.edition'), child: Column(children: [
          BibliographicField(sourceText: true, label: context.tr('library.editor'), value: book.editor),
          BibliographicField(sourceText: true, label: context.tr('library.publisher'), value: book.publisher),
          BibliographicField(label: context.tr('library.print_year'), value: book.edition),
          BibliographicField(label: context.tr('library.volumes'), value: book.volumes),
          BibliographicField(label: context.tr('library.pages'), value: book.pages),
          BibliographicField(label: context.tr('library.field'), value: book.section),
        ])),
        const SizedBox(height: 32),
        Text(context.tr('library.bibliography_notice')),
      ]);
  }
}
