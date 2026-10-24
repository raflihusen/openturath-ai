import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_snackbar.dart';
import '../core/arabic_catalog.dart';
import '../core/localization.dart';
import '../widgets/book_detail_parts.dart';
import '../widgets/ot_motion_widgets.dart';
import '../core/catalog_section_label.dart';
import '../core/scholarly_fonts.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../services/research_notes_service.dart';

/// Halaman Detail Edisi Kitab Mandiri (Full-Screen Route).
/// Chrome follows the app locale; source titles and names retain Arabic RTL.
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
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    try {
      final noteId = 'book_${widget.book.editionId}';
      final isBookmarked = await BookmarkService().isBookmarked(noteId);
      if (mounted) {
        setState(() => _isSaved = isBookmarked);
      }
    } catch (_) {}
  }

  Future<void> _toggleSaveBook() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final noteId = 'book_${widget.book.editionId}';
      if (_isSaved) {
        await _notesService.deleteNote(noteId);
        await BookmarkService().deleteBookmark(noteId);
        if (mounted) {
          setState(() {
            _isSaved = false;
            _isSaving = false;
          });
          AppSnackBar.show(context, message: Loc.trAr('bookmarkDeleted'));
        }
      } else {
        final agent = _resolveTargetAgent();
        final deathYearStr = widget.book.verifiedDeathYearHijri != null
            ? ' (ت: ${widget.book.verifiedDeathYearHijri} هـ)'
            : '';
        final publisherStr = widget.book.publisher != null
            ? '، دار النشر: ${widget.book.publisher}'
            : '';
        final muhaqqiqStr = widget.book.muhaqqiq != null
            ? '، تحقيق: ${widget.book.muhaqqiq}'
            : '';

        final newNote = ResearchNote(
          id: noteId,
          agentId: agent.id,
          agentTitle: agent.title,
          title: widget.book.titleArabic,
          excerpt:
              'كتاب ${widget.book.titleArabic}، للمؤلف ${widget.book.authorArabic}$deathYearStr$publisherStr$muhaqqiqStr.',
          bookTitle: widget.book.titleArabic,
          bookVolume: widget.book.volumesCount?.toString(),
          tags: [
            'بطاقة كتاب',
            if (widget.book.reviewedTypeLabel != null)
              widget.book.reviewedTypeLabel!,
            if (widget.book.reviewedEraLabel != null)
              widget.book.reviewedEraLabel!,
          ],
          createdAt: DateTime.now(),
        );

        final newBookmark = BookmarkModel(
          id: noteId,
          title: widget.book.titleArabic,
          agentId: agent.id,
          agentTitle: agent.title,
          fieldName: 'بطاقة كتاب',
          fieldId: 'fiqh',
          arabicExcerpt: widget.book.titleArabic,
          fullAnswer:
              'كتاب ${widget.book.titleArabic}، للمؤلف ${widget.book.authorArabic}$deathYearStr$publisherStr$muhaqqiqStr.',
          bookReference: widget.book.titleArabic,
          pageNumber: '',
          author: widget.book.authorArabic,
          createdAt: DateTime.now(),
          documentKind: BookmarkDocumentKind.bookReference,
          verificationStatus: BookmarkVerificationStatus.needsReview,
        );

        await _notesService.saveNote(newNote);
        await BookmarkService().addBookmark(newBookmark);
        if (mounted) {
          setState(() {
            _isSaved = true;
            _isSaving = false;
          });
          HapticFeedback.mediumImpact();
          AppSnackBar.success(context, Loc.trAr('savedSuccess'));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.error(context, Loc.trAr('saveFailed'));
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

  void _copyScholarlyCitation() {
    final deathYearStr = widget.book.verifiedDeathYearHijri != null
        ? ' (ت: ${widget.book.verifiedDeathYearHijri} هـ)'
        : '';
    final publisherStr = widget.book.publisher != null
        ? '، دار النشر: ${widget.book.publisher}'
        : '';
    final muhaqqiqStr =
        widget.book.muhaqqiq != null ? '، تحقيق: ${widget.book.muhaqqiq}' : '';
    final volStr = (widget.book.volumesDescription != null &&
            widget.book.volumesDescription!.isNotEmpty)
        ? '، ${widget.book.volumesDescription}'
        : (widget.book.volumesCount != null
            ? '، ${widget.book.volumesCount} أجزاء'
            : '');
    final printYearStr =
        (widget.book.printYear != null && widget.book.printYear != '-')
            ? '، سنة الطبع: ${widget.book.printYear}'
            : '';

    final citation =
        '${widget.book.authorArabic}$deathYearStr، ${widget.book.titleArabic}$muhaqqiqStr$publisherStr$printYearStr$volStr.';

    Clipboard.setData(ClipboardData(text: citation));
    HapticFeedback.selectionClick();
    AppSnackBar.success(context, Loc.trAr('ui_e150b5de89'));
  }

  String _translateType(String? type) {
    if (type == null || type.isEmpty) return Loc.trAr('bookTypeWork');
    final l = type.toLowerCase();
    if (l.contains('matn') || l.contains('matan')) {
      return Loc.trAr('bookTypeMatn');
    }
    if (l.contains('syarah') || l.contains('sharh')) {
      return Loc.trAr('bookTypeSharh');
    }
    if (l.contains('hasyiyah') || l.contains('hashiyah')) {
      return Loc.trAr('bookTypeHashiyah');
    }
    if (l.contains('mukhtasar') || l.contains('ringkasan')) {
      return Loc.trAr('bookTypeSummary');
    }
    if (l.contains('ensiklopedia') || l.contains('mausuah')) {
      return Loc.trAr('bookTypeEncyclopedia');
    }
    if (l.contains('manzhumah') || l.contains('nazham')) {
      return Loc.trAr('bookTypePoem');
    }
    return Loc.textAr(type);
  }

  String _translateEra(String? era) {
    if (era == null || era.isEmpty) return Loc.trAr('bookEraHeritage');
    final l = era.toLowerCase();
    if (l.contains('mutaqaddim') || l.contains('awal')) {
      return Loc.trAr('bookEraEarly');
    }
    if (l.contains('mutawassith') || l.contains('pertengahan')) {
      return Loc.trAr('bookEraMiddle');
    }
    if (l.contains('muta\'akhkhir') ||
        l.contains('mutaakhir') ||
        l.contains('lanjut')) {
      return Loc.trAr('bookEraLate');
    }
    if (l.contains('mu\'ashir') ||
        l.contains('kontemporer') ||
        l.contains('modern')) {
      return Loc.trAr('bookEraModern');
    }
    return Loc.textAr(era);
  }

  String? _volumes() {
    final vd = widget.book.volumesDescription?.trim() ?? '';
    if (vd.isNotEmpty && vd != '-') {
      return RegExp(r'^[0-9٠-٩]+$').hasMatch(vd)
          ? ArabicCatalog.number(vd)
          : ArabicCatalog.digits(vd);
    }
    final count = widget.book.volumesCount;
    if (count != null && count > 0) return ArabicCatalog.number('$count');
    return null;
  }

  String? _pages() {
    final p = widget.book.pagesDescription?.trim() ?? '';
    if (p.isEmpty || p == '-') return null;
    return RegExp(r'^[0-9٠-٩.,،\s]+$').hasMatch(p)
        ? ArabicCatalog.number(p.replaceAll(RegExp(r'[.,،\s]'), ''))
        : ArabicCatalog.digits(p);
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = OTColors.canvas(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final book = widget.book;
    final death = ArabicCatalog.death(book.verifiedDeathYearHijri);
    final volumes = _volumes(), pages = _pages();
    final section = book.sectionArabic == null || book.sectionArabic!.isEmpty
        ? null
        : CatalogSectionLabel.of(book.sectionArabic!);
    const none = ArabicCatalog.notStatedShort;

    return Theme(
      data: ArabicCatalog.theme(Theme.of(context)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: BackButton(
              color: textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(ArabicCatalog.bookCard,
                style: ArabicCatalog.ui(
                    fontSize: OTFontSize.s20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.xxl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OTBentoTile(
                        padding: const EdgeInsets.all(OTSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (section != null) ...[
                              Text(section,
                                  style: ArabicCatalog.ui(
                                      fontSize: OTFontSize.s12,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary)),
                              const SizedBox(height: OTSpacing.md),
                            ],
                            Text(book.titleArabic,
                                textAlign: TextAlign.start,
                                style: ScholarlyFonts.scheherazadeNew(
                                    fontSize: OTFontSize.s26,
                                    fontWeight: FontWeight.w400,
                                    color: textPrimary,
                                    height: 1.75)),
                            if (book.shortTitleArabic != null &&
                                book.shortTitleArabic!.isNotEmpty &&
                                book.shortTitleArabic != book.titleArabic)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: OTSpacing.xs),
                                child: Text(book.shortTitleArabic!,
                                    style: ScholarlyFonts.scheherazadeNew(
                                        fontSize: OTFontSize.s16,
                                        color: textSecondary,
                                        height: 1.7)),
                              ),
                            const SizedBox(height: OTSpacing.sm),
                            Text(ArabicCatalog.authorName(book.authorArabic),
                                textAlign: TextAlign.start,
                                style: ScholarlyFonts.scheherazadeNew(
                                    fontSize: OTFontSize.s18,
                                    color: textSecondary,
                                    height: 1.7)),
                            const SizedBox(height: OTSpacing.lg),
                            LayoutBuilder(builder: (context, box) {
                              final copy = FilledButton.icon(
                                  onPressed: _copyScholarlyCitation,
                                  icon:
                                      const Icon(Icons.copy_rounded, size: 18),
                                  label:
                                      const Text(ArabicCatalog.copyCitation));
                              final save = OutlinedButton.icon(
                                  onPressed: _toggleSaveBook,
                                  icon: Icon(
                                      _isSaved
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_add_outlined,
                                      size: 18),
                                  label: Text(_isSaved
                                      ? ArabicCatalog.removeNote
                                      : ArabicCatalog.saveNote));
                              if (box.maxWidth < 420) {
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      copy,
                                      const SizedBox(height: OTSpacing.sm),
                                      save
                                    ]);
                              }
                              return Row(children: [
                                Expanded(child: copy),
                                const SizedBox(width: OTSpacing.md),
                                Expanded(child: save),
                              ]);
                            }),
                          ],
                        ),
                      ),
                      BookStatStrip(items: [
                        if (volumes != null)
                          BookStat(Icons.layers_outlined,
                              ArabicCatalog.lVolumes, volumes),
                        if (pages != null)
                          BookStat(Icons.description_outlined,
                              ArabicCatalog.lPages, pages),
                        if (death != null)
                          BookStat(
                              Icons.history_edu_outlined,
                              ArabicCatalog.lDeath,
                              death.replaceFirst('ت ', '')),
                      ]),
                      BookFactsCard(
                        title: Loc.trAr('bookClassification'),
                        rows: [
                          if (section != null)
                            BookFact(Icons.category_outlined,
                                Loc.trAr('bookScienceSection'), section),
                          if (book.reviewedTypeLabel != null &&
                              book.reviewedTypeLabel!.isNotEmpty)
                            BookFact(
                                Icons.menu_book_outlined,
                                Loc.trAr('bookTextType'),
                                _translateType(book.reviewedTypeLabel)),
                          if (book.reviewedEraLabel != null &&
                              book.reviewedEraLabel!.isNotEmpty)
                            BookFact(
                                Icons.history_edu_rounded,
                                Loc.trAr('bookAuthorEra'),
                                _translateEra(book.reviewedEraLabel)),
                        ],
                      ),
                      BookFactsCard(
                        title: ArabicCatalog.edition,
                        rows: [
                          BookFact(Icons.edit_outlined, ArabicCatalog.lEditor,
                              book.muhaqqiq ?? none),
                          BookFact(Icons.apartment_outlined,
                              ArabicCatalog.lPublisher, book.publisher ?? none),
                          if (book.printYear != null && book.printYear != '-')
                            BookFact(
                                Icons.bookmark_border_rounded,
                                Loc.trAr('bookPrintYear'),
                                ArabicCatalog.digits(book.printYear!)),
                        ],
                      ),
                      const SizedBox(height: OTSpacing.md),
                      Text(ArabicCatalog.notice,
                          style: ArabicCatalog.ui(
                              fontSize: OTFontSize.s12, color: textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
