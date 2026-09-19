import '../core/l10n/app_dictionary.dart';
import '../core/l10n/library_dictionary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../widgets/editorial.dart';
import '../widgets/book_row_item.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../services/auth_service.dart';
import '../services/research_notes_service.dart';

/// A bibliographic dossier with independently directed Arabic source fields.
class BookDetailScreen extends StatefulWidget {
  final CanonicalBookPresentation book;
  final AgentModel? agent;

  const BookDetailScreen({
    super.key,
    required this.book,
    this.agent,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final ResearchNotesService _notesService = ResearchNotesService();
  String? _currentUid() {
    try { return AuthService().currentUser?.uid; }
    catch (_) { return null; }
  }
  late final String? _ownerUid;
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _ownerUid = _currentUid();
    _checkIfSaved();
  }

  void _checkOwner() {
    if (_currentUid() != _ownerUid) {
      throw StateError(context.tr('library.account_changed'));
    }
  }

  Future<void> _checkIfSaved() async {
    try {
      final noteId = 'book_${widget.book.editionId}';
      final isBookmarked = await BookmarkService().isBookmarked(noteId, userId: _ownerUid);
      if (mounted && _currentUid() == _ownerUid && !_isSaving) {
        setState(() => _isSaved = isBookmarked);
      }
    } catch (_) {}
  }

  Future<void> _toggleSaveBook() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      _checkOwner();
      final noteId = 'book_${widget.book.editionId}';
      if (_isSaved) {
        await _notesService.deleteNote(noteId, userId: _ownerUid);
        _checkOwner();
        await BookmarkService().deleteBookmark(noteId, userId: _ownerUid);
        if (mounted) {
          setState(() {
            _isSaved = false;
            _isSaving = false;
          });
          AppSnackBar.show(context, message: context.tr('library.removed'));
        }
      } else {
        final agent = _resolveTargetAgent();
        final newNote = ResearchNote(
          id: noteId,
          agentId: agent.id,
          agentTitle: context.agentTitle(agent),
          title: widget.book.titleArabic,
          excerpt: _citation,
          bookTitle: widget.book.titleArabic,
          // A catalogue volume count is not the cited volume of a passage.
          bookVolume: null,
          tags: [
            context.tr('library.book_card'),
            if (widget.book.reviewedTypeLabel != null)
              libraryDataLabel(widget.book.reviewedTypeLabel!, context.languageCode),
            if (widget.book.reviewedEraLabel != null)
              libraryDataLabel(widget.book.reviewedEraLabel!, context.languageCode),
          ],
          createdAt: DateTime.now(),
        );

        final newBookmark = BookmarkModel(
          id: noteId,
          title: widget.book.titleArabic,
          agentId: agent.id,
          agentTitle: context.agentTitle(agent),
          fieldName: context.tr('library.book_card'),
          fieldId: agent.fieldId,
          arabicExcerpt: widget.book.titleArabic,
          fullAnswer: _citation,
          bookReference: widget.book.titleArabic,
          pageNumber: '',
          author: widget.book.authorArabic,
          createdAt: DateTime.now(),
          documentKind: BookmarkDocumentKind.bookReference,
          verificationStatus: BookmarkVerificationStatus.needsReview,
        );

        await _notesService.saveNote(newNote, userId: _ownerUid);
        _checkOwner();
        await BookmarkService().addBookmark(newBookmark, userId: _ownerUid);
        if (mounted) {
          setState(() {
            _isSaved = true;
            _isSaving = false;
          });
          AppSnackBar.success(context, context.tr('library.saved'));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.error(context, context.tr('library.update_failed'));
      }
    }
  }

  AgentModel _resolveTargetAgent() {
    if (widget.agent != null) return widget.agent!;
    try {
      return AgentModel.defaultAgents.firstWhere(
        (a) => a.catalogId == 'canonical_syafii' || a.id == 'fiqh',
        orElse: () => AgentModel.defaultAgents.first,
      );
    } catch (_) {
      return AgentModel.defaultAgents.first;
    }
  }

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
      field('book', book.titleArabic, source: true),
      field('author', book.authorArabic, source: true),
      field('death', book.verifiedDeathYearHijri == null ? null : context.tr(
        'library.year', args: {'year': libraryBidi('${book.verifiedDeathYearHijri}', context.languageCode)})),
      field('editor', book.muhaqqiq, source: true),
      field('publisher', book.publisher, source: true),
      field('print_year', book.printYear),
      field('volumes', book.volumesDescription ?? book.volumesCount?.toString()),
      field('pages', book.pagesDescription),
      field('catalog_number', book.editionId),
    ].join('\n');
  }

  Future<void> _copyScholarlyCitation() async {
    final citation = _citation;
    try {
      await Clipboard.setData(ClipboardData(text: citation));
      if (mounted) AppSnackBar.success(context, context.tr('library.copied'));
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.tr('library.copy_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return EditorialPage(
      maxWidth: 720,
      showBack: true,
      eyebrow: context.tr('library.detail_eyebrow'),
      title: context.tr('library.reference'),
      children: [
        EditorialArabicText(librarySourceLabel(book.titleArabic, context.languageCode), fontSize: 30),
        if (book.titleLatin?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          Text(book.titleLatin!, textDirection: TextDirection.ltr, style: OTTypography.body(color: OTColors.textSecondary(dark))),
        ],
        const SizedBox(height: 24),
        Wrap(spacing: 12, runSpacing: 12, children: [
          EditorialButton(label: _isSaved ? context.tr('library.saved_button') : context.tr('library.save'),
            icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
            busy: _isSaving, onPressed: _isSaving ? null : _toggleSaveBook),
          EditorialButton(label: context.tr('library.copy'), icon: Icons.copy_outlined,
            secondary: true, onPressed: _copyScholarlyCitation),
        ]),
        const SizedBox(height: 40),
        EditorialSection(title: context.tr('library.author'), child: Column(children: [
          BibliographicField(sourceText: true, label: context.tr('library.author_name'), value: book.authorArabic),
          if (book.authorLatin?.trim().isNotEmpty == true)
            BibliographicField(sourceText: true, label: context.tr('library.transliteration'), value: book.authorLatin),
          BibliographicField(label: context.tr('library.death'),
            value: book.verifiedDeathYearHijri == null ? null : context.tr('library.year', args: {'year': libraryBidi('${book.verifiedDeathYearHijri}', context.languageCode)})),
        ])),
        const SizedBox(height: 32),
        EditorialSection(title: context.tr('library.edition'), child: Column(children: [
          BibliographicField(sourceText: true, label: context.tr('library.publisher'), value: book.publisher),
          BibliographicField(sourceText: true, label: context.tr('library.editor'), value: book.muhaqqiq),
          BibliographicField(label: context.tr('library.print_year'), value: book.printYear),
          BibliographicField(label: context.tr('library.volumes'), value: book.volumesDescription ?? book.volumesCount?.toString()),
          BibliographicField(label: context.tr('library.pages'), value: book.pagesDescription),
        ])),
        const SizedBox(height: 32),
        EditorialSection(title: context.tr('library.classification'), child: Column(children: [
          BibliographicField(label: context.tr('library.field'), value: book.sectionArabic),
          if (book.reviewedTypeLabel != null)
            BibliographicField(label: context.tr('library.type'), value: book.reviewedTypeLabel),
          if (book.reviewedEraLabel != null)
            BibliographicField(label: context.tr('library.period'), value: book.reviewedEraLabel),
          if (book.canShowAuthority) ...[
            BibliographicField(label: context.tr('library.authority'), value: book.reviewedAuthorityLabel),
            BibliographicField(label: context.tr('library.evidence'), value: book.authorityEvidence),
          ],
          BibliographicField(label: context.tr('library.catalog_number'), value: book.editionId),
        ])),
        const SizedBox(height: 32),
        Text(context.tr('library.bibliography_notice'),
          style: OTTypography.body(color: OTColors.textSecondary(dark))),
      ],
    );
  }
}
