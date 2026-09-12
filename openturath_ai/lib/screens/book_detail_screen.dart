import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../services/research_notes_service.dart';

/// Halaman Detail Edisi Kitab Mandiri (Full-Screen Route).
/// Mengeliminasi pola anti-desain modal bertingkat (sheet-on-sheet) sesuai Apple HIG.
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
          AppSnackBar.show(context, message: 'Rujukan dihapus dari Catatan Riset.');
        }
      } else {
        final agent = _resolveTargetAgent();
        final deathYearStr = widget.book.verifiedDeathYearHijri != null
            ? ' (w. ${widget.book.verifiedDeathYearHijri} H)'
            : '';
        final publisherStr = widget.book.publisher != null
            ? ', Terbitan ${widget.book.publisher}'
            : '';
        final muhaqqiqStr = widget.book.muhaqqiq != null
            ? ', Tahqiq: ${widget.book.muhaqqiq}'
            : '';

        final newNote = ResearchNote(
          id: noteId,
          agentId: agent.id,
          agentTitle: agent.title,
          title: widget.book.titleArabic,
          excerpt:
              'Kitab ${widget.book.titleArabic}, karya ${widget.book.authorArabic}$deathYearStr$publisherStr$muhaqqiqStr.',
          bookTitle: widget.book.titleArabic,
          bookVolume: widget.book.volumesCount?.toString(),
          tags: [
            'Rujukan Kitab',
            if (widget.book.reviewedTypeLabel != null) widget.book.reviewedTypeLabel!,
            if (widget.book.reviewedEraLabel != null) widget.book.reviewedEraLabel!,
          ],
          createdAt: DateTime.now(),
        );

        final newBookmark = BookmarkModel(
          id: noteId,
          title: widget.book.titleArabic,
          agentId: agent.id,
          agentTitle: agent.title,
          fieldName: 'Rujukan Kitab',
          fieldId: 'fiqh',
          arabicExcerpt: widget.book.titleArabic,
          fullAnswer:
              'Kitab ${widget.book.titleArabic}, karya ${widget.book.authorArabic}$deathYearStr$publisherStr$muhaqqiqStr.',
          bookReference: widget.book.titleArabic,
          pageNumber: '',
          author: widget.book.authorArabic,
          createdAt: DateTime.now(),
        );

        await _notesService.saveNote(newNote);
        await BookmarkService().addBookmark(newBookmark);
        if (mounted) {
          setState(() {
            _isSaved = true;
            _isSaving = false;
          });
          HapticFeedback.mediumImpact();
          AppSnackBar.success(context, 'Kitab disimpan ke Catatan Riset.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.error(context, 'Gagal memperbarui catatan riset.');
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
        ? ' (w. ${widget.book.verifiedDeathYearHijri} H)'
        : '';
    final publisherStr = widget.book.publisher != null
        ? ', ${widget.book.publisher}'
        : '';
    final muhaqqiqStr = widget.book.muhaqqiq != null
        ? ', Tahqiq: ${widget.book.muhaqqiq}'
        : '';
    final volStr = widget.book.volumesCount != null
        ? ', ${widget.book.volumesCount} Jilid'
        : '';

    final citation =
        '${widget.book.authorArabic}$deathYearStr. ${widget.book.titleArabic}$volStr$publisherStr$muhaqqiqStr. OpenTurath AI Canonical Corpus.';

    Clipboard.setData(ClipboardData(text: citation));
    HapticFeedback.selectionClick();
    AppSnackBar.success(context, 'Sitasi standar ilmiah tersalin ke papan klip.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final background = OTColors.canvas(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final primaryAccent = OTColors.accent(isDark);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppCopy.bookDetails,
          style: OTTypography.screenTitle(color: textPrimary).copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isSaved ? primaryAccent : textSecondary,
            ),
            tooltip: _isSaved ? 'Hapus Rujukan' : 'Simpan Rujukan',
            onPressed: _toggleSaveBook,
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: textSecondary),
            tooltip: 'Salin Sitasi Standar',
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
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Naskah Kanonikal · Syafi\'i',
                            style: OTTypography.caption(color: primaryAccent).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.book.editionId,
                          style: OTTypography.caption(color: textSecondary).copyWith(
                            fontFamily: 'Courier',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OTSpacing.md),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        widget.book.titleArabic,
                        textAlign: TextAlign.right,
                        style: OTTypography.arabicDisplay(color: textPrimary).copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                      ),
                    ),
                    if (widget.book.titleLatin != null &&
                        widget.book.titleLatin!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.book.titleLatin!,
                        style: OTTypography.body(color: textSecondary).copyWith(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
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
                    _buildSectionHeader('MUALLIF / PENGARANG', textSecondary),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: primaryAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.authorArabic,
                                style: OTTypography.bodyMedium(color: textPrimary).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.book.authorLatin != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.book.authorLatin!,
                                  style: OTTypography.caption(color: textSecondary),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.book.verifiedDeathYearHijri != null
                                      ? 'Wafat: ${widget.book.verifiedDeathYearHijri} Hijriyah'
                                      : 'Wafat: Dalam verifikasi sanad',
                                  style: OTTypography.caption(color: textSecondary).copyWith(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
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

              // ── KARTU 3: KLASIFIKASI ILMIAH & THABAQAT ──
              _buildCard(
                isDark: isDark,
                surface: surface,
                border: border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('KLASIFIKASI ILMIAH', textSecondary),
                    const SizedBox(height: 12),
                    _buildMetaRow(
                      icon: Icons.category_outlined,
                      label: 'Tipe Naskah',
                      value: widget.book.reviewedTypeLabel ?? 'Kitab Referensi Mazhab',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _buildMetaRow(
                      icon: Icons.history_edu_rounded,
                      label: 'Era Keilmuan',
                      value: widget.book.reviewedEraLabel ?? 'Ulama Mazhab Syafi\'i',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _buildMetaRow(
                      icon: Icons.auto_stories_outlined,
                      label: 'Jumlah Jilid',
                      value: widget.book.volumesCount != null
                          ? '${widget.book.volumesCount} Jilid'
                          : '1 Jilid / Naskah Tunggal',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    if (widget.book.canShowAuthority) ...[
                      const Divider(height: 16, thickness: 0.5),
                      _buildMetaRow(
                        icon: Icons.verified_outlined,
                        label: 'Derajat Mu\'tabar',
                        value: widget.book.reviewedAuthorityLabel!,
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
                    _buildSectionHeader('DATA EDISI & TAHQIQ', textSecondary),
                    const SizedBox(height: 12),
                    _buildMetaRow(
                      icon: Icons.business_outlined,
                      label: 'Penerbit Rujukan',
                      value: widget.book.publisher ?? 'Informasi penerbit belum tersedia',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _buildMetaRow(
                      icon: Icons.edit_note_rounded,
                      label: 'Pentahqiq / Muhaqqiq',
                      value: widget.book.muhaqqiq ?? 'Cetakan klasik / belum tercatat',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OTSpacing.md),



              const SizedBox(height: OTSpacing.xl),
            ],
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
      padding: const EdgeInsets.all(OTSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: border, width: 0.8),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: OTTypography.sectionHeading(color: color),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: OTTypography.caption(color: textSecondary),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: OTTypography.bodyMedium(color: textPrimary).copyWith(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
