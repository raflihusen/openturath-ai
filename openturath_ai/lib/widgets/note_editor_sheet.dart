import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart' show Bidi;
import '../core/localization.dart';
import 'native_theme.dart';
import '../core/design/native_design.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/design/ot_motion.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';

class NoteEditorSheet extends StatefulWidget {
  final BookmarkModel? item;
  final ValueChanged<BookmarkModel>? onSaved;
  final bool fullScreen;
  final BookmarkService? bookmarkService;

  const NoteEditorSheet({
    super.key,
    this.item,
    this.onSaved,
    this.fullScreen = false,
    this.bookmarkService,
  });

  static Future<BookmarkModel?> show(
    BuildContext context, {
    BookmarkModel? item,
    BookmarkService? bookmarkService,
  }) {
    return Navigator.of(context).push<BookmarkModel>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => NativeTheme(
            child: Scaffold(
          body: SafeArea(
              child: NoteEditorSheet(
            item: item,
            fullScreen: true,
            bookmarkService: bookmarkService,
          )),
        )),
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
  bool _draftFailed = false;
  bool _restoringDraft = false;
  bool _closing = false;
  bool _allowPop = false;
  bool _noteSaved = false;
  int _draftRevision = 0;
  Future<void> _pendingDraftWrite = Future<void>.value();
  Timer? _autoSaveDebounce;
  late final BookmarkService _bookmarkService;
  late final String? _draftOwnerId;

  String get _draftKey => _draftOwnerId == null
      ? 'openturath_draft_note_${widget.item?.id ?? 'new'}'
      : 'openturath_${_draftOwnerId}_draft_note_${widget.item?.id ?? 'new'}';

  @override
  void initState() {
    super.initState();
    _bookmarkService = widget.bookmarkService ?? BookmarkService();
    _draftOwnerId = _bookmarkService.currentUserId;
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _bodyController = TextEditingController(
      text: widget.item?.fullAnswer ?? widget.item?.arabicExcerpt ?? '',
    );
    _textDirection = Bidi.detectRtlDirectionality(_bodyController.text) ||
            (_bodyController.text.isEmpty && Loc.isArabic)
        ? TextDirection.rtl
        : TextDirection.ltr;

    _titleController.addListener(_scheduleAutoSave);
    _bodyController.addListener(_scheduleAutoSave);

    _loadDraft();
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted || _hasChanges || _submitting || _closing) return;
      final raw = prefs.getString(_draftKey);
      if (raw == null || raw.isEmpty) return;
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return;

      final draftTitle = map['title'] as String? ?? '';
      final draftBody = map['body'] as String? ?? '';
      final savedAt = DateTime.tryParse(map['savedAt'] as String? ?? '');
      if (widget.item != null &&
          savedAt != null &&
          !savedAt.isAfter(widget.item!.effectiveTime)) {
        return;
      }

      final initialTitle = widget.item?.title ?? '';
      final initialBody =
          widget.item?.fullAnswer ?? widget.item?.arabicExcerpt ?? '';

      // Only restore if draft has different/more recent content
      if ((draftTitle != initialTitle || draftBody != initialBody) &&
          (draftTitle.isNotEmpty || draftBody.isNotEmpty || savedAt != null)) {
        if (mounted) {
          setState(() {
            _restoringDraft = true;
            _titleController.text = draftTitle;
            _bodyController.text = draftBody;
            _restoringDraft = false;
            _textDirection = Bidi.detectRtlDirectionality(draftBody) ||
                    (draftBody.isEmpty && Loc.isArabic)
                ? TextDirection.rtl
                : TextDirection.ltr;
            _draftRestored = true;
            _hasChanges = true;
          });
        }
      }
    } catch (_) {}
  }

  void _scheduleAutoSave() {
    if (_restoringDraft || _submitting || _closing) return;
    setState(() {
      _hasChanges = true;
      _draftSaved = false;
      _draftRestored = false;
      _draftFailed = false;
      _draftRevision++;
    });
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = Timer(const Duration(milliseconds: 1500), () {
      unawaited(_saveDraft());
    });
  }

  Future<bool> _saveDraft({bool showStatus = true}) async {
    // Capture before awaiting: later edits queue behind this exact snapshot.
    final revision = _draftRevision;
    final snapshot = jsonEncode({
      'title': _titleController.text,
      'body': _bodyController.text,
      'savedAt': DateTime.now().toIso8601String(),
    });
    if (showStatus && mounted) setState(() => _isSavingDraft = true);
    final write = _pendingDraftWrite.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(_draftKey, snapshot)) {
        throw StateError('Draft could not be written');
      }
    });
    // Keep the queue usable after a failed write; report failure to its caller.
    _pendingDraftWrite = write.catchError((Object _) {});
    try {
      await write;
      if (showStatus && mounted && revision == _draftRevision) {
        setState(() {
          _isSavingDraft = false;
          _draftSaved = true;
          _draftFailed = false;
        });
      }
      return true;
    } catch (_) {
      if (showStatus && mounted && revision == _draftRevision) {
        setState(() {
          _isSavingDraft = false;
          _draftFailed = true;
        });
      }
      return false;
    }
  }

  Future<void> _close() async {
    if (_closing || _submitting) return;
    setState(() => _closing = true);
    _autoSaveDebounce?.cancel();
    final saved = !_hasChanges || await _saveDraft();
    if (!mounted) return;
    if (!saved) {
      setState(() => _closing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(NativeCopy.text('saveFailed'))),
      );
      return;
    }
    setState(() => _allowPop = true);
    Navigator.pop(context);
  }

  TextDirection _textDirection = TextDirection.ltr;

  @override
  void dispose() {
    _autoSaveDebounce?.cancel();
    // A parent can remove the route without invoking its normal back handler.
    if (!_noteSaved && !_closing && _hasChanges) {
      unawaited(_saveDraft(showStatus: false));
    }
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
    if (_bookmarkService.currentUserId != _draftOwnerId) {
      await _saveDraft();
      throw StateError('The note owner changed while editing');
    }
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Loc.tr('ui_4ccf3c2529'))),
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

    await _bookmarkService.addBookmark(updated, userId: _draftOwnerId);

    _noteSaved = true;
    _autoSaveDebounce?.cancel();
    // Drain all writes before removing the draft so autosave cannot recreate it.
    await _pendingDraftWrite;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}

    if (!mounted) return;
    widget.onSaved?.call(updated);
    OTMotion.success();
    setState(() => _allowPop = true);
    Navigator.pop(context, updated);
  }

  bool _submitting = false;
  Future<void> _submit() async {
    if (_submitting || _closing) return;
    _autoSaveDebounce?.cancel();
    setState(() => _submitting = true);
    try {
      await _saveNote();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(NativeCopy.text('saveFailed'))));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    return PopScope<BookmarkModel>(
        canPop: _allowPop,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) unawaited(_close());
        },
        child: Container(
          height: widget.fullScreen ? double.infinity : media.size.height * .92,
          color: NativeColors.canvas(dark),
          padding: EdgeInsets.only(
              bottom: widget.fullScreen ? 0 : media.viewInsets.bottom),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Row(children: [
                    IconButton(
                        tooltip: NativeCopy.text('back'),
                        onPressed: _submitting || _closing ? null : _close,
                        icon: const Icon(Icons.arrow_back_rounded)),
                    Expanded(
                        child: Text(
                            Loc.text(widget.item == null
                                ? 'Catatan baru'
                                : 'Edit catatan'),
                            style: NativeType.title(dark, size: 22))),
                    FilledButton(
                        onPressed: _submitting || _closing ? null : _submit,
                        child: Text(_submitting
                            ? NativeCopy.text('loading')
                            : Loc.tr('save'))),
                  ]),
                  Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ChoiceChip(
                            label: Text(Loc.text('Tulis')),
                            selected: !_isPreview,
                            onSelected: _submitting || _closing
                                ? null
                                : (_) => setState(() => _isPreview = false)),
                        ChoiceChip(
                            label: Text(Loc.text('Pratinjau')),
                            selected: _isPreview,
                            onSelected: _submitting || _closing
                                ? null
                                : (_) {
                                    FocusScope.of(context).unfocus();
                                    setState(() => _isPreview = true);
                                  }),
                        if (_isSavingDraft ||
                            _draftSaved ||
                            _draftRestored ||
                            _draftFailed)
                          Semantics(
                              liveRegion: true,
                              child: Text(
                                  _draftFailed
                                      ? NativeCopy.text('saveFailed')
                                      : Loc.text(_isSavingDraft
                                          ? 'Menyimpan draf...'
                                          : _draftRestored
                                              ? 'Draf dipulihkan'
                                              : 'Draf tersimpan'),
                                  style: NativeType.meta(dark))),
                      ]),
                ])),
            if (!_isPreview)
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    IconButton(
                        tooltip: Loc.text('Tebal'),
                        icon: const Icon(Icons.format_bold),
                        onPressed: _submitting || _closing
                            ? null
                            : () => _applyFormat('**', '**',
                                defaultText: Loc.text('teks tebal'))),
                    IconButton(
                        tooltip: Loc.text('Miring'),
                        icon: const Icon(Icons.format_italic),
                        onPressed: _submitting || _closing
                            ? null
                            : () => _applyFormat('*', '*',
                                defaultText: Loc.text('teks miring'))),
                    IconButton(
                        tooltip: Loc.text('Daftar Poin'),
                        icon: const Icon(Icons.format_list_bulleted),
                        onPressed: _submitting || _closing
                            ? null
                            : () => _applyFormat('\n- ', '',
                                defaultText: Loc.text('poin catatan'))),
                    IconButton(
                        tooltip: Loc.text('Kutipan'),
                        icon: const Icon(Icons.format_quote),
                        onPressed: _submitting || _closing
                            ? null
                            : () => _applyFormat('\n> ', '',
                                defaultText: Loc.text('kutipan ibarah'))),
                    IconButton(
                        tooltip: NativeCopy.text('arabicQuote'),
                        icon: const Icon(Icons.format_quote_rounded),
                        onPressed: _submitting || _closing
                            ? null
                            : () => _applyFormat('« ', ' »',
                                defaultText: Loc.text('kutipan ibarah'))),
                    IconButton(
                        tooltip: Loc.text('Judul Bab'),
                        icon: const Icon(Icons.title),
                        onPressed: _submitting || _closing
                            ? null
                            : () => _applyFormat('\n# ', '',
                                defaultText: Loc.text('Judul Bab'))),
                    IconButton(
                        tooltip: Loc.text('Orientasi Kiri ke Kanan (LTR)'),
                        icon: const Icon(Icons.format_textdirection_l_to_r),
                        onPressed: _submitting || _closing
                            ? null
                            : () => _applyDirection(TextDirection.ltr)),
                    IconButton(
                        tooltip:
                            Loc.text('Orientasi Kanan ke Kiri / Arab (RTL)'),
                        icon: const Icon(Icons.format_textdirection_r_to_l),
                        onPressed: _submitting || _closing
                            ? null
                            : () => _applyDirection(TextDirection.rtl)),
                  ])),
            Divider(color: NativeColors.border(dark)),
            Expanded(
                child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            if (_isPreview) ...[
                              Directionality(
                                textDirection: Bidi.detectRtlDirectionality(
                                        _titleController.text)
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: Text(
                                  _titleController.text,
                                  style: Bidi.detectRtlDirectionality(
                                          _titleController.text)
                                      ? NativeType.arabic(dark, size: 28)
                                      : NativeType.title(dark),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Directionality(
                                  textDirection: _textDirection,
                                  child: MarkdownBody(
                                      data: _bodyController.text,
                                      selectable: true,
                                      styleSheet: MarkdownStyleSheet(
                                        p: _textDirection == TextDirection.rtl
                                            ? NativeType.arabic(dark, size: 22)
                                            : NativeType.body(dark, size: 17),
                                        h1: NativeType.title(dark),
                                        h2: NativeType.title(dark, size: 24),
                                      ))),
                            ] else ...[
                              TextField(
                                  controller: _titleController,
                                  readOnly: _submitting || _closing,
                                  maxLines: null,
                                  textDirection: Bidi.detectRtlDirectionality(
                                              _titleController.text) ||
                                          (_titleController.text.isEmpty &&
                                              Loc.isArabic)
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  style: Bidi.detectRtlDirectionality(
                                              _titleController.text) ||
                                          (_titleController.text.isEmpty &&
                                              Loc.isArabic)
                                      ? NativeType.arabic(dark, size: 28)
                                      : NativeType.title(dark),
                                  decoration: InputDecoration(
                                      hintText: Loc.text('Judul catatan'),
                                      border: InputBorder.none,
                                      filled: false)),
                              const SizedBox(height: 16),
                              TextField(
                                  controller: _bodyController,
                                  readOnly: _submitting || _closing,
                                  maxLines: null,
                                  minLines: 8,
                                  textDirection: _textDirection,
                                  style: _textDirection == TextDirection.rtl
                                      ? NativeType.arabic(dark, size: 22)
                                      : NativeType.body(dark, size: 17),
                                  decoration: InputDecoration(
                                      hintText: Loc.text(
                                          'Tulis catatan atau tempel ibarah di sini…'),
                                      border: InputBorder.none,
                                      filled: false)),
                            ],
                          ]),
                    ))),
          ]),
        ));
  }
}
