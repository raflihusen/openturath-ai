import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_snackbar.dart';
import '../core/localization.dart';
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

import 'package:openturath_ai/core/design/ot_radius.dart';

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
          AppSnackBar.show(context, message: Loc.tr('bookmarkDeleted'));
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
          AppSnackBar.success(context, Loc.tr('savedSuccess'));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.error(context, Loc.tr('saveFailed'));
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
    AppSnackBar.success(context, Loc.tr('ui_e150b5de89'));
  }

  String _translateType(String? type) {
    if (type == null || type.isEmpty) return Loc.tr('bookTypeWork');
    final l = type.toLowerCase();
    if (l.contains('matn') || l.contains('matan')) {
      return Loc.tr('bookTypeMatn');
    }
    if (l.contains('syarah') || l.contains('sharh')) {
      return Loc.tr('bookTypeSharh');
    }
    if (l.contains('hasyiyah') || l.contains('hashiyah')) {
      return Loc.tr('bookTypeHashiyah');
    }
    if (l.contains('mukhtasar') || l.contains('ringkasan')) {
      return Loc.tr('bookTypeSummary');
    }
    if (l.contains('ensiklopedia') || l.contains('mausuah')) {
      return Loc.tr('bookTypeEncyclopedia');
    }
    if (l.contains('manzhumah') || l.contains('nazham')) {
      return Loc.tr('bookTypePoem');
    }
    return Loc.text(type);
  }

  String _translateEra(String? era) {
    if (era == null || era.isEmpty) return Loc.tr('bookEraHeritage');
    final l = era.toLowerCase();
    if (l.contains('mutaqaddim') || l.contains('awal')) {
      return Loc.tr('bookEraEarly');
    }
    if (l.contains('mutawassith') || l.contains('pertengahan')) {
      return Loc.tr('bookEraMiddle');
    }
    if (l.contains('muta\'akhkhir') ||
        l.contains('mutaakhir') ||
        l.contains('lanjut')) {
      return Loc.tr('bookEraLate');
    }
    if (l.contains('mu\'ashir') ||
        l.contains('kontemporer') ||
        l.contains('modern')) {
      return Loc.tr('bookEraModern');
    }
    return Loc.text(era);
  }

  String _formatVolumes() {
    final vd = widget.book.volumesDescription;
    if (vd != null && vd.isNotEmpty) {
      return (vd.contains('جزء') ||
              vd.contains('مجلد') ||
              vd.toLowerCase().contains('jilid'))
          ? vd
          : Loc.tr('volumeCount', [vd]);
    }
    final count = widget.book.volumesCount;
    if (count != null && count > 0) {
      return Loc.tr('volumeCount', ['$count']);
    }
    return Loc.tr('unknownMetadata');
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final background = OTColors.canvas(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

    return Directionality(
      textDirection: Loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
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
          title: Text(
            Loc.tr('bookDetails'),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: _isSaved ? OTColors.accent(isDark) : textSecondary,
              ),
              tooltip: _isSaved ? Loc.tr('bookRemove') : Loc.tr('bookSave'),
              onPressed: _toggleSaveBook,
            ),
            IconButton(
              icon: Icon(Icons.share_outlined, color: textSecondary),
              tooltip: Loc.tr('bookCitationCopy'),
              onPressed: _copyScholarlyCitation,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: OTSpacing.lg,
              vertical: OTSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── KARTU 1: IDENTITAS KITAB (ARABIC HERO) ──
                _buildCard(
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: OTColors.primaryContainer(isDark),
                                borderRadius:
                                    BorderRadius.circular(OTRadius.input),
                              ),
                              child: Text(
                                widget.book.sectionArabic == null
                                    ? Loc.tr('unclassified')
                                    : CatalogSectionLabel.of(
                                        widget.book.sectionArabic!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: OTTypography.caption(
                                        color:
                                            OTColors.onPrimaryContainer(isDark))
                                    .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: OTFontSize.s11,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                widget.book.editionId,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style:
                                    OTTypography.caption(color: textSecondary)
                                        .copyWith(
                                  fontFamily: 'Courier',
                                  fontSize: OTFontSize.s11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OTSpacing.md),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          widget.book.titleArabic,
                          textAlign: TextAlign.start,
                          style: OTTypography.arabicDisplay(color: textPrimary)
                              .copyWith(
                            fontSize: OTFontSize.s26,
                            fontWeight: FontWeight.w700,
                            height: 1.85,
                          ),
                        ),
                      ),
                      if (widget.book.shortTitleArabic != null &&
                          widget.book.shortTitleArabic!.isNotEmpty &&
                          widget.book.shortTitleArabic !=
                              widget.book.titleArabic) ...[
                        const SizedBox(height: 6),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            widget.book.shortTitleArabic!,
                            textAlign: TextAlign.start,
                            style:
                                OTTypography.arabicReading(color: textSecondary)
                                    .copyWith(
                              fontSize: OTFontSize.s14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                      if (widget.book.titleLatin != null &&
                          widget.book.titleLatin!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            widget.book.titleLatin!,
                            textAlign: TextAlign.start,
                            style: OTTypography.body(color: textSecondary)
                                .copyWith(
                              fontStyle: FontStyle.italic,
                              fontSize: OTFontSize.s14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: OTSpacing.md),

                // ── KARTU 2: MUALLIF / PENGARANG ──
                _buildCard(
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                          Loc.tr('bookAuthorDeath'), textSecondary),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    widget.book.authorArabic,
                                    textAlign: TextAlign.start,
                                    style: OTTypography.arabicReading(
                                            color: textPrimary)
                                        .copyWith(
                                      fontSize: OTFontSize.s18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (widget.book.authorLatin != null) ...[
                                  const SizedBox(height: 2),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      widget.book.authorLatin!,
                                      style: OTTypography.caption(
                                          color: textSecondary),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surfaceSubtle,
                                    borderRadius:
                                        BorderRadius.circular(OTRadius.input),
                                  ),
                                  child: Text(
                                    widget.book.verifiedDeathYearHijri != null
                                        ? Loc.tr('deathYear', [
                                            '${widget.book.verifiedDeathYearHijri}'
                                          ])
                                        : Loc.tr('unknownMetadata'),
                                    style: ScholarlyFonts.outfit(
                                            color: textSecondary)
                                        .copyWith(
                                      fontSize: OTFontSize.s12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: OTSpacing.md),

                // ── KARTU 3: SPESIFIKASI & KLASIFIKASI NASKAH ──
                _buildCard(
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                          Loc.tr('bookClassification'), textSecondary),
                      const SizedBox(height: 12),
                      if (widget.book.sectionArabic != null &&
                          widget.book.sectionArabic!.isNotEmpty) ...[
                        _buildMetaRow(
                          icon: Icons.category_outlined,
                          label: Loc.tr('bookScienceSection'),
                          value: CatalogSectionLabel.of(
                              widget.book.sectionArabic!),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                      ],
                      if (widget.book.reviewedTypeLabel != null &&
                          widget.book.reviewedTypeLabel!.isNotEmpty) ...[
                        _buildMetaRow(
                          icon: Icons.menu_book_outlined,
                          label: Loc.tr('bookTextType'),
                          value: _translateType(widget.book.reviewedTypeLabel),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                      ],
                      if (widget.book.reviewedEraLabel != null &&
                          widget.book.reviewedEraLabel!.isNotEmpty) ...[
                        _buildMetaRow(
                          icon: Icons.history_edu_rounded,
                          label: Loc.tr('bookAuthorEra'),
                          value: _translateEra(widget.book.reviewedEraLabel),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                      ],
                      _buildMetaRow(
                        icon: Icons.auto_stories_outlined,
                        label: Loc.tr('bookVolumes'),
                        value: _formatVolumes(),
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      if (widget.book.pagesDescription != null &&
                          widget.book.pagesDescription!.isNotEmpty &&
                          widget.book.pagesDescription != '-') ...[
                        const Divider(height: 16, thickness: 0.5),
                        _buildMetaRow(
                          icon: Icons.article_outlined,
                          label: Loc.tr('bookPages'),
                          value: Loc.tr(
                              'pageCount', [widget.book.pagesDescription!]),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: OTSpacing.md),

                // ── KARTU 4: DATA EDISI & TAHQIQ ──
                _buildCard(
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                          Loc.tr('bookEditionData'), textSecondary),
                      const SizedBox(height: 12),
                      _buildMetaRow(
                        icon: Icons.business_outlined,
                        label: Loc.tr('bookPublisher'),
                        value:
                            widget.book.publisher ?? Loc.tr('unknownMetadata'),
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      _buildMetaRow(
                        icon: Icons.edit_note_rounded,
                        label: Loc.tr('ui_ad39f1c3af'),
                        value:
                            widget.book.muhaqqiq ?? Loc.tr('unknownMetadata'),
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      if (widget.book.printYear != null &&
                          widget.book.printYear != '-') ...[
                        const Divider(height: 16, thickness: 0.5),
                        _buildMetaRow(
                          icon: Icons.calendar_today_outlined,
                          label: Loc.tr('bookPrintYear'),
                          value: widget.book.printYear!,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: OTSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required bool isDark,
    required Color surface,
    required Color border,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: OTSpacing.md, horizontal: OTSpacing.xs),
      decoration: BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: border.withValues(alpha: .75), width: .8)),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: ScholarlyFonts.outfit(color: color).copyWith(
        fontSize: OTFontSize.s14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 17, color: textSecondary),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
            label,
            style: ScholarlyFonts.outfit(color: textSecondary).copyWith(
              fontSize: OTFontSize.s12,
              fontWeight: FontWeight.w400,
            ),
          )),
        ]),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 24),
          child: Directionality(
            textDirection: RegExp(r'[\u0600-\u06FF]').hasMatch(value)
                ? TextDirection.rtl
                : Directionality.of(context),
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: (RegExp(r'[\u0600-\u06FF]').hasMatch(value)
                      ? OTTypography.arabicReading(color: textPrimary)
                      : ScholarlyFonts.outfit(color: textPrimary))
                  .copyWith(
                      fontSize: OTFontSize.s14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
