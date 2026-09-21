import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_motion.dart';
import '../core/scholarly_fonts.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';

class NoteEditorSheet extends StatefulWidget {
  final BookmarkModel? item;
  final ValueChanged<BookmarkModel>? onSaved;
  final bool fullScreen;

  const NoteEditorSheet({
    super.key,
    this.item,
    this.onSaved,
    this.fullScreen = false,
  });

  static Future<BookmarkModel?> show(
    BuildContext context, {
    BookmarkModel? item,
  }) {
    return Navigator.of(context).push<BookmarkModel>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          body: SafeArea(child: NoteEditorSheet(item: item, fullScreen: true)),
        ),
      ),
    );
  }

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _isPreview = false;
  bool _hasChanges = false;
  bool _isSavingDraft = false;
  bool _draftSaved = false;
  bool _draftRestored = false;
  Timer? _autoSaveDebounce;

  String get _draftKey => 'openturath_draft_note_${widget.item?.id ?? 'new'}';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _bodyController = TextEditingController(
      text: widget.item?.fullAnswer ?? widget.item?.arabicExcerpt ?? '',
    );

    _titleController.addListener(_scheduleAutoSave);
    _bodyController.addListener(_scheduleAutoSave);

    _loadDraft();
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null || raw.isEmpty) return;
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return;

      final draftTitle = map['title'] as String? ?? '';
      final draftBody = map['body'] as String? ?? '';

      final initialTitle = widget.item?.title ?? '';
      final initialBody =
          widget.item?.fullAnswer ?? widget.item?.arabicExcerpt ?? '';

      // Only restore if draft has different/more recent content
      if ((draftTitle != initialTitle || draftBody != initialBody) &&
          (draftTitle.isNotEmpty || draftBody.isNotEmpty)) {
        if (mounted) {
          setState(() {
            _titleController.text = draftTitle;
            _bodyController.text = draftBody;
            _draftRestored = true;
            _hasChanges = true;
          });
        }
      }
    } catch (_) {}
  }

  void _scheduleAutoSave() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = Timer(const Duration(milliseconds: 1500), _saveDraft);
  }

  Future<void> _saveDraft() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty && body.isEmpty) return;

    if (mounted) setState(() => _isSavingDraft = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _draftKey,
        jsonEncode({
          'title': title,
          'body': body,
          'savedAt': DateTime.now().toIso8601String(),
        }),
      );
      if (mounted) {
        setState(() {
          _isSavingDraft = false;
          _draftSaved = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSavingDraft = false);
    }
  }

  TextDirection _textDirection = TextDirection.ltr;

  @override
  void dispose() {
    _autoSaveDebounce?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _applyDirection(TextDirection dir) {
    final selection = _bodyController.selection;
    final text = _bodyController.text;

    if (selection.isValid && !selection.isCollapsed) {
      final selectedText = text.substring(selection.start, selection.end);
      final marker = dir == TextDirection.rtl ? '\u200F' : '\u200E';
      final replaced = text.replaceRange(
        selection.start,
        selection.end,
        '$marker$selectedText',
      );
      _bodyController.text = replaced;
      _bodyController.selection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.start + marker.length + selectedText.length,
      );
    }
    setState(() => _textDirection = dir);
    OTMotion.selection();
    _scheduleAutoSave();
  }

  void _applyFormat(String prefix, String suffix,
      {String defaultText = 'teks'}) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;

    if (text.isEmpty) {
      _bodyController.text = '$prefix$defaultText$suffix';
      _bodyController.selection = TextSelection(
        baseOffset: prefix.length,
        extentOffset: prefix.length + defaultText.length,
      );
      OTMotion.selection();
      _scheduleAutoSave();
      return;
    }

    if (selection.start < 0 || selection.end < 0) {
      final newText = '$text$prefix$defaultText$suffix';
      _bodyController.text = newText;
      _bodyController.selection = TextSelection(
        baseOffset: text.length + prefix.length,
        extentOffset: text.length + prefix.length + defaultText.length,
      );
      OTMotion.selection();
      _scheduleAutoSave();
      return;
    }

    final selectedText = text.substring(selection.start, selection.end);
    final insertText = selectedText.isEmpty ? defaultText : selectedText;
    final replaced = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$insertText$suffix',
    );

    _bodyController.text = replaced;
    _bodyController.selection = TextSelection(
      baseOffset: selection.start + prefix.length,
      extentOffset: selection.start + prefix.length + insertText.length,
    );
    OTMotion.selection();
    _scheduleAutoSave();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Isi judul atau tulis catatan terlebih dahulu.')),
      );
      return;
    }

    final effectiveTitle = title.isNotEmpty
        ? title
        : (body.length > 50 ? '${body.substring(0, 50)}...' : body);

    final item = widget.item;
    final BookmarkModel updated;
    final now = DateTime.now();
    if (item != null) {
      updated = item.copyWith(
        title: effectiveTitle,
        fullAnswer: body,
        updatedAt: now,
      );
    } else {
      updated = BookmarkModel(
        id: 'note_${now.millisecondsSinceEpoch}',
        title: effectiveTitle,
        agentId: 'catatan_mandiri',
        agentTitle: 'Catatan Pribadi',
        fieldName: 'Catatan Pribadi',
        fieldId: 'general',
        arabicExcerpt: '',
        fullAnswer: body,
        bookReference: '',
        pageNumber: '',
        createdAt: now,
        updatedAt: now,
        documentKind: BookmarkDocumentKind.personalNote,
        verificationStatus: BookmarkVerificationStatus.notApplicable,
      );
    }

    await BookmarkService().addBookmark(updated);

    // Clear draft after successful persistent save
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}

    widget.onSaved?.call(updated);
    if (!mounted) return;
    OTMotion.success();
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final mediaQuery = MediaQuery.of(context);

    return Container(
      height:
          widget.fullScreen ? double.infinity : mediaQuery.size.height * 0.88,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: border, width: 0.8),
      ),
      child: Column(
        children: [
          if (!widget.fullScreen)
            Center(
              child: Container(
                width: 36,
                height: 3,
                margin: const EdgeInsets.only(top: 8, bottom: 6),
                color: textSecondary.withValues(alpha: 0.25),
              ),
            ),

          // Appbar Row: Mode Toggle, Close, Save
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.lg, vertical: 4),
            child: Row(
              children: [
                if (widget.fullScreen)
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.pop(context),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.item != null ? 'Edit catatan' : 'Catatan baru',
                      style:
                          OTTypography.screenTitle(color: textPrimary).copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_isSavingDraft || _draftSaved || _draftRestored)
                      Text(
                        _isSavingDraft
                            ? 'Menyimpan draf...'
                            : (_draftRestored
                                ? 'Draf dipulihkan'
                                : 'Draf tersimpan'),
                        style:
                            OTTypography.caption(color: textSecondary).copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                // Toggle Edit / Preview
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: surfaceSubtle,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: border, width: 0.6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isPreview = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                !_isPreview ? textPrimary : Colors.transparent,
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(
                            'Tulis',
                            style: OTTypography.captionMedium(
                              color: !_isPreview
                                  ? (isDark
                                      ? const Color(0xFF18181B)
                                      : Colors.white)
                                  : textSecondary,
                            ).copyWith(fontSize: 11.5),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _isPreview = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _isPreview ? textPrimary : Colors.transparent,
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(
                            'Pratinjau',
                            style: OTTypography.captionMedium(
                              color: _isPreview
                                  ? (isDark
                                      ? const Color(0xFF18181B)
                                      : Colors.white)
                                  : textSecondary,
                            ).copyWith(fontSize: 11.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: _saveNote,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    backgroundColor: textPrimary,
                    foregroundColor:
                        isDark ? const Color(0xFF18181B) : Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    'Simpan',
                    style: OTTypography.captionMedium(
                      color: isDark ? const Color(0xFF18181B) : Colors.white,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Formatting Toolbar (Full width row, centered and evenly distributed)
          if (!_isPreview)
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: surfaceSubtle,
                border: Border(bottom: BorderSide(color: border, width: 0.6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ToolbarBtn(
                    label: 'B',
                    tooltip: 'Tebal',
                    isBold: true,
                    onTap: () =>
                        _applyFormat('**', '**', defaultText: 'teks tebal'),
                  ),
                  _ToolbarBtn(
                    label: 'I',
                    tooltip: 'Miring',
                    isItalic: true,
                    onTap: () =>
                        _applyFormat('*', '*', defaultText: 'teks miring'),
                  ),
                  _ToolbarBtn(
                    icon: Icons.format_list_bulleted_rounded,
                    tooltip: 'Daftar Poin',
                    onTap: () =>
                        _applyFormat('\n- ', '', defaultText: 'poin catatan'),
                  ),
                  _ToolbarBtn(
                    icon: Icons.format_quote_rounded,
                    tooltip: 'Kutipan',
                    onTap: () =>
                        _applyFormat('\n> ', '', defaultText: 'kutipan ibarah'),
                  ),
                  _ToolbarBtn(
                    label: '« »',
                    tooltip: 'Kutipan Arab',
                    onTap: () => _applyFormat('«', '»', defaultText: 'عبارة'),
                  ),
                  _ToolbarBtn(
                    label: 'H1',
                    tooltip: 'Judul Bab',
                    onTap: () =>
                        _applyFormat('\n# ', '\n', defaultText: 'Judul Bab'),
                  ),
                  _ToolbarBtn(
                    icon: Icons.format_textdirection_l_to_r_rounded,
                    tooltip: 'Orientasi Kiri ke Kanan (LTR)',
                    isActive: _textDirection == TextDirection.ltr,
                    onTap: () => _applyDirection(TextDirection.ltr),
                  ),
                  _ToolbarBtn(
                    icon: Icons.format_textdirection_r_to_l_rounded,
                    tooltip: 'Orientasi Kanan ke Kiri / Arab (RTL)',
                    isActive: _textDirection == TextDirection.rtl,
                    onTap: () => _applyDirection(TextDirection.rtl),
                  ),
                ],
              ),
            ),

          // Content Area
          Expanded(
            child: _isPreview
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(OTSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_titleController.text.trim().isNotEmpty) ...[
                          Text(
                            _titleController.text.trim(),
                            style: ScholarlyFonts.newsreader(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(
                              color: border.withValues(alpha: 0.6), height: 1),
                          const SizedBox(height: 16),
                        ],
                        _bodyController.text.trim().isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Text(
                                    'Belum ada isi catatan.',
                                    style:
                                        OTTypography.body(color: textSecondary),
                                  ),
                                ),
                              )
                            : Directionality(
                                textDirection: _textDirection,
                                child: MarkdownBody(
                                  data: _bodyController.text,
                                  selectable: true,
                                  styleSheet: MarkdownStyleSheet(
                                    p: ScholarlyFonts.outfit(
                                      fontSize: 14.5,
                                      height: 1.6,
                                      color: textPrimary,
                                    ),
                                    h1: ScholarlyFonts.newsreader(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                    h2: ScholarlyFonts.newsreader(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                    blockquote: ScholarlyFonts.outfit(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: textSecondary,
                                    ),
                                    blockquoteDecoration: BoxDecoration(
                                      color: surfaceSubtle,
                                      borderRadius: BorderRadius.zero,
                                      border: Border(
                                        left: BorderSide(
                                          color: textPrimary.withValues(
                                              alpha: 0.6),
                                          width: 3.5,
                                        ),
                                      ),
                                    ),
                                    code: ScholarlyFonts.sourceCodePro(
                                      fontSize: 13,
                                      backgroundColor: surfaceSubtle,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(OTSpacing.lg),
                    children: [
                      // Title TextField
                      TextField(
                        controller: _titleController,
                        style: ScholarlyFonts.newsreader(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Judul catatan',
                          hintStyle: ScholarlyFonts.newsreader(
                            fontSize: 20,
                            color: textSecondary.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: border.withValues(alpha: 0.5), height: 1),
                      const SizedBox(height: 14),

                      // Body TextField
                      TextField(
                        controller: _bodyController,
                        maxLines: null,
                        minLines: 12,
                        keyboardType: TextInputType.multiline,
                        textDirection: _textDirection,
                        textAlign: _textDirection == TextDirection.rtl
                            ? TextAlign.right
                            : TextAlign.left,
                        style: ScholarlyFonts.outfit(
                          fontSize: 14.5,
                          height: 1.55,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tulis catatan atau tempel ibarah di sini…',
                          hintTextDirection: _textDirection,
                          hintStyle: ScholarlyFonts.outfit(
                            fontSize: 14,
                            color: textSecondary.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isBold;
  final bool isItalic;
  final bool isActive;

  const _ToolbarBtn({
    this.label,
    this.icon,
    required this.tooltip,
    required this.onTap,
    this.isBold = false,
    this.isItalic = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = OTColors.textSecondary(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final accent = OTColors.marja(isDark);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 36, maxWidth: 44),
          height: 32,
          decoration: BoxDecoration(
            color:
                isActive ? accent.withValues(alpha: 0.14) : Colors.transparent,
            border: isActive
                ? Border.all(color: accent.withValues(alpha: 0.45), width: 0.9)
                : null,
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, size: 17, color: isActive ? accent : textSecondary)
              : Text(
                  label!,
                  style: ScholarlyFonts.outfit(
                    fontSize: 13,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    color: isActive ? accent : textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
