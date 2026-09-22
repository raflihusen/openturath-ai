import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_snackbar.dart';
import '../core/localization.dart';
import '../core/design/native_design.dart';
import '../core/design/native_typography.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../services/research_notes_service.dart';

/// Halaman Detail Edisi Kitab Mandiri (Full-Screen Route).
/// Dirancang sepenuhnya dalam Bahasa Arab Turats dan Tata Letak RTL murni.
/// Menggunakan font Naskh Scheherazade New tanpa font Amiri sama sekali.
class BookDetailScreen extends StatefulWidget {
  final CanonicalBookPresentation book;
  final AgentModel? agent;
  final bool localizedControls;

  const BookDetailScreen({
    super.key,
    required this.book,
    this.agent,
    this.localizedControls = false,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final ResearchNotesService _notesService = ResearchNotesService();
  String _label(String key, String legacy) =>
      widget.localizedControls ? NativeCopy.text(key) : legacy;
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
          AppSnackBar.show(context,
              message:
                  _label('removedReference', 'تمت إزالة الكتاب من الملاحظات'));
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
          AppSnackBar.success(
              context, _label('saved', 'تم حفظ بيانات الكتاب في الملاحظات'));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.error(
            context, _label('saveFailed', 'تعذر تحديث الملاحظات'));
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
    AppSnackBar.success(context, _label('copied', 'تم نسخ بطاقة الكتاب بنجاح'));
  }

  String _translateType(String? type) {
    if (widget.localizedControls && type != null) {
      final lower = type.toLowerCase();
      for (final entry in {
        'matn': 'workMatn',
        'matan': 'workMatn',
        'syarah': 'workSharh',
        'sharh': 'workSharh',
        'hasyiyah': 'workHashiya',
        'hashiyah': 'workHashiya',
        'mukhtasar': 'workSummary',
        'ringkasan': 'workSummary',
        'ensiklopedi': 'workEncyclopedia',
        'nazham': 'workPoem'
      }.entries) {
        if (lower.contains(entry.key)) return NativeCopy.text(entry.value);
      }
      return Loc.text(type);
    }
    if (type == null || type.isEmpty) return 'مصنف علمي';
    final l = type.toLowerCase();
    if (l.contains('matn') || l.contains('matan')) return 'متن معتمد';
    if (l.contains('syarah') || l.contains('sharh')) return 'شرح';
    if (l.contains('hasyiyah') || l.contains('hashiyah')) return 'حاشية';
    if (l.contains('mukhtasar') || l.contains('ringkasan')) return 'مختصر';
    if (l.contains('ensiklopedia') || l.contains('mausuah')) {
      return 'موسوعة فقهية';
    }
    if (l.contains('manzhumah') || l.contains('nazham')) {
      return 'منظومة علمية';
    }
    return type;
  }

  String _translateEra(String? era) {
    if (widget.localizedControls && era != null) {
      final lower = era.toLowerCase();
      for (final entry in {
        'mutaqaddim': 'eraEarly',
        'awal': 'eraEarly',
        'mutawassith': 'eraMiddle',
        'pertengahan': 'eraMiddle',
        "muta'akhkhir": 'eraLate',
        'mutaakhir': 'eraLate',
        'lanjut': 'eraLate',
        "mu'ashir": 'eraModern',
        'modern': 'eraModern',
        'kontemporer': 'eraModern'
      }.entries) {
        if (lower.contains(entry.key)) return NativeCopy.text(entry.value);
      }
      return Loc.text(era);
    }
    if (era == null || era.isEmpty) return 'التراث الإسلامي';
    final l = era.toLowerCase();
    if (l.contains('mutaqaddim') || l.contains('awal')) {
      return 'عصر المتقدمين (حتى ٤٠٠ هـ)';
    }
    if (l.contains('mutawassith') || l.contains('pertengahan')) {
      return 'عصر المتوسطين (٤٠٠ - ٨٠٠ هـ)';
    }
    if (l.contains('muta\'akhkhir') ||
        l.contains('mutaakhir') ||
        l.contains('lanjut')) {
      return 'عصر المتأخرين (٨٠٠ - ١٢٠٠ هـ)';
    }
    if (l.contains('mu\'ashir') ||
        l.contains('kontemporer') ||
        l.contains('modern')) {
      return 'العصر المعاصر (بعد ١٢٠٠ هـ)';
    }
    return era;
  }

  String _formatVolumes() {
    if (widget.localizedControls) {
      final volumes = widget.book.volumesDescription ??
          widget.book.volumesCount?.toString();
      return volumes == null
          ? Loc.tr('unknownMetadata')
          : Loc.tr('volumeCount', [volumes]);
    }
    final vd = widget.book.volumesDescription;
    if (vd != null && vd.isNotEmpty) {
      return (vd.contains('جزء') || vd.contains('مجلد')) ? vd : '$vd أجزاء';
    }
    final count = widget.book.volumesCount;
    if (count != null && count > 1) return '$count أجزاء';
    return 'جزء واحد (مجلد مفرد)';
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = NativeColors.surface(isDark);
    final background = NativeColors.canvas(isDark);
    final border = NativeColors.border(isDark);
    final textPrimary = NativeColors.textPrimary(isDark);
    final textSecondary = NativeColors.textSecondary(isDark);
    final surfaceSubtle = NativeColors.surfaceSubtle(isDark);

    return Directionality(
      textDirection: widget.localizedControls
          ? Directionality.of(context)
          : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
            tooltip: _label('back', 'رجوع'),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _label('sources', 'بطاقة الكتاب'),
            style: NativeTypography.arabicReading(color: textPrimary).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: _isSaved
                    ? (isDark ? Colors.white : Colors.black)
                    : textSecondary,
              ),
              tooltip: _isSaved
                  ? _label('removeReference', 'إزالة من الملاحظات')
                  : _label('saveReference', 'حفظ في الملاحظات'),
              onPressed: _isSaving ? null : _toggleSaveBook,
            ),
            IconButton(
              icon: Icon(Icons.share_outlined, color: textSecondary),
              tooltip: _label('copyReference', 'نسخ بطاقة الكتاب'),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: surfaceSubtle,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: border.withValues(alpha: 0.7),
                                  width: 0.6),
                            ),
                            child: Text(
                              widget.book.sectionArabic ??
                                  _label('classificationMissing', 'نص محقق معتمد'),
                              style:
                                  NativeTypography.caption(color: textSecondary)
                                      .copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (!widget.localizedControls)
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                widget.book.editionId,
                                style: NativeTypography.caption(
                                        color: textSecondary)
                                    .copyWith(
                                  fontFamily: 'Courier',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: OTSpacing.md),
                      Text(
                        widget.book.titleArabic,
                        textAlign: TextAlign.right,
                        style:
                            NativeTypography.arabicDisplay(color: textPrimary)
                                .copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.9,
                        ),
                      ),
                      if (widget.book.shortTitleArabic != null &&
                          widget.book.shortTitleArabic!.isNotEmpty &&
                          widget.book.shortTitleArabic !=
                              widget.book.titleArabic) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${_label('shortTitle', 'المختصر')}: ${widget.book.shortTitleArabic!}',
                          textAlign: TextAlign.right,
                          style: NativeTypography.arabicReading(
                                  color: textSecondary)
                              .copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                            textAlign: TextAlign.right,
                            style: NativeTypography.body(color: textSecondary)
                                .copyWith(
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
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
                          _label('authorPeriod', 'المؤلف والوفاة'),
                          textSecondary),
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
                                Text(
                                  widget.book.authorArabic,
                                  style: NativeTypography.arabicReading(
                                          color: textPrimary)
                                      .copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (widget.book.authorLatin != null) ...[
                                  const SizedBox(height: 2),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      widget.book.authorLatin!,
                                      style: NativeTypography.caption(
                                          color: textSecondary),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.black.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.localizedControls
                                        ? (widget.book.verifiedDeathYearHijri ==
                                                null
                                            ? Loc.tr('unknownMetadata')
                                            : Loc.tr('deathYear', [
                                                '${widget.book.verifiedDeathYearHijri}'
                                              ]))
                                        : widget.book.verifiedDeathYearHijri !=
                                                null
                                            ? 'سنة الوفاة: ${widget.book.verifiedDeathYearHijri} هـ'
                                            : 'سنة الوفاة: غير مدونة',
                                    style: NativeTypography.arabicReading(
                                            color: textSecondary)
                                        .copyWith(
                                      fontSize: 12.5,
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
                          _label('classification', 'التصنيف والمصنف'),
                          textSecondary),
                      const SizedBox(height: 12),
                      if (widget.book.sectionArabic != null &&
                          widget.book.sectionArabic!.isNotEmpty) ...[
                        _buildMetaRow(
                          icon: Icons.category_outlined,
                          label: _label('disciplines', 'القسم العلمي'),
                          value: widget.book.sectionArabic!,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                      ],
                      if (widget.book.reviewedTypeLabel != null &&
                          widget.book.reviewedTypeLabel!.isNotEmpty) ...[
                        _buildMetaRow(
                          icon: Icons.menu_book_outlined,
                          label: _label('workType', 'نوع المصنف'),
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
                          label: _label('authorEra', 'عصر المؤلف'),
                          value: _translateEra(widget.book.reviewedEraLabel),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                      ],
                      _buildMetaRow(
                        icon: Icons.auto_stories_outlined,
                        label: _label('volumes', 'عدد الأجزاء'),
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
                          label: _label('pages', 'عدد الصفحات'),
                          value: widget.localizedControls
                              ? Loc.tr(
                                  'pageCount', [widget.book.pagesDescription!])
                              : '${widget.book.pagesDescription} صفحة',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                      if (widget.book.canShowAuthority) ...[
                        const Divider(height: 16, thickness: 0.5),
                        _buildMetaRow(
                          icon: Icons.verified_outlined,
                          label: _label('authority', 'رتبة الاعتماد'),
                          value: _label('authorityRecognized', 'معتمد في المذهب والفتوى'),
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
                          _label('edition', 'بيانات الطبع والتحقيق'),
                          textSecondary),
                      const SizedBox(height: 12),
                      _buildMetaRow(
                        icon: Icons.business_outlined,
                        label: _label('publisher', 'دار النشر'),
                        value:
                            widget.book.publisher ?? Loc.tr('unknownMetadata'),
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      _buildMetaRow(
                        icon: Icons.edit_note_rounded,
                        label: _label('editor', 'المحقق'),
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
                          label: _label('year', 'سنة الطبع'),
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
      style: (widget.localizedControls
              ? NativeTypography.bodyMedium(color: color)
              : NativeTypography.arabicReading(color: color))
          .copyWith(
        fontSize: 13,
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: NativeTypography.body(color: textSecondary))),
      ]),
      const SizedBox(height: 6),
      Text(value,
          style: NativeTypography.arabicReading(color: textPrimary)
              .copyWith(fontSize: 18, height: 1.9)),
    ]);
  }
}
