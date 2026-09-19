import '../core/l10n/app_dictionary.dart';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import 'editorial.dart';
import 'scholarly_markdown.dart';

class NoteEditorSheet extends StatefulWidget {
  const NoteEditorSheet({super.key, this.item, this.onSaved, this.fullScreen = false});
  final BookmarkModel? item;
  final ValueChanged<BookmarkModel>? onSaved;
  final bool fullScreen;

  static Future<BookmarkModel?> show(BuildContext context, {BookmarkModel? item}) =>
      Navigator.of(context).push<BookmarkModel>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(body: SafeArea(
            child: NoteEditorSheet(item: item, fullScreen: true))),
      ));

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final String? _owner;
  late final String _draftKey;
  late final String _noteId;
  StreamSubscription<User?>? _authSubscription;
  Timer? _debounce;
  Future<void> _draftWrite = Future.value();
  bool _preview = false;
  bool _dirty = false;
  bool _saving = false;
  bool _invalidSession = false;
  bool _allowPop = false;
  bool _restoring = false;
  bool _draftFailed = false;
  bool _closing = false;
  String? _status;
  TextDirection _direction = TextDirection.ltr;

  bool get _ownerValid => !_invalidSession &&
      FirebaseAuth.instance.currentUser?.uid == _owner;

  @override
  void initState() {
    super.initState();
    _owner = FirebaseAuth.instance.currentUser?.uid;
    _noteId = widget.item?.id ?? 'note_${DateTime.now().microsecondsSinceEpoch}';
    _draftKey = 'openturath_note_draft_${Uri.encodeComponent(_owner ?? 'guest_local')}_${widget.item?.id ?? 'new'}';
    _title = TextEditingController(text: widget.item?.title ?? '');
    _body = TextEditingController(text: widget.item?.fullAnswer.trim().isNotEmpty == true
        ? widget.item!.fullAnswer : widget.item?.arabicExcerpt ?? '');
    _direction = ScholarlyMarkdown.directionOf(_body.text);
    _title.addListener(_changed);
    _body.addListener(_changed);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user?.uid == _owner || !mounted) return;
      _debounce?.cancel();
      setState(() {
        _invalidSession = true;
        _title.clear();
        _body.clear();
        _status = 'notes.accountChanged';
      });
    });
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (!mounted || !_ownerValid || _dirty || raw == null) return;
      final parsed = jsonDecode(raw);
      if (parsed is! Map<String, dynamic>) return;
      final title = parsed['title'];
      final body = parsed['body'];
      if (title is! String || body is! String) return;
      final savedAt = DateTime.tryParse(parsed['savedAt'] as String? ?? '');
      if (widget.item != null && (savedAt == null ||
          savedAt.isBefore(widget.item!.effectiveTime))) return;
      _restoring = true;
      _title.text = title;
      _body.text = body;
      _direction = ScholarlyMarkdown.directionOf(body);
      _restoring = false;
      setState(() { _dirty = true; _status = 'notes.draftRestored'; });
    } catch (_) {
      // A malformed local draft must not block opening the saved note.
    }
  }

  void _changed() {
    if (_restoring || !_ownerValid || !mounted) return;
    setState(() { _dirty = true; _status = 'notes.unsaved'; });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 900), _saveDraft);
  }

  Future<void> _saveDraft() {
    if (!_ownerValid) return Future.value();
    final title = _title.text;
    final body = _body.text;
    final key = _draftKey;
    _draftWrite = _draftWrite.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (!_ownerValid) return;
      final saved = await prefs.setString(key, jsonEncode({
        'title': title, 'body': body,
        'savedAt': DateTime.now().toIso8601String(),
      }));
      if (!saved) throw StateError('Draft write failed');
      _draftFailed = false;
      if (mounted && _ownerValid && title == _title.text && body == _body.text) {
        setState(() => _status = 'notes.draftSaved');
      }
    }).catchError((Object error) {
      _draftFailed = true;
      if (mounted) setState(() => _status = 'notes.draftFailed');
    });
    return _draftWrite;
  }

  Future<void> _close() async {
    if (_saving || _closing) return;
    _closing = true;
    _debounce?.cancel();
    if (_dirty && _ownerValid) await _saveDraft();
    if (!mounted) return;
    if (_draftFailed && _ownerValid) {
      final discard = await showDialog<bool>(context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(dialogContext.tr('notes.draftTitle')),
          content: Text(dialogContext.tr('notes.draftBody')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(dialogContext.tr('notes.stay'))),
            TextButton(onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(dialogContext.tr('notes.discard'))),
          ],
        ));
      if (discard != true || !mounted) { _closing = false; return; }
    }
    setState(() => _allowPop = true);
    Navigator.of(context).pop();
  }

  void _format(String prefix, String suffix) {
    final value = _body.value;
    final valid = value.selection.isValid;
    final start = valid ? value.selection.start : value.text.length;
    final end = valid ? value.selection.end : start;
    final selected = value.text.substring(start, end);
    _body.value = TextEditingValue(
      text: value.text.replaceRange(start, end, '$prefix$selected$suffix'),
      selection: TextSelection(baseOffset: start + prefix.length,
          extentOffset: start + prefix.length + selected.length),
    );
  }

  Future<void> _save() async {
    if (_saving || !_ownerValid) return;
    final body = _body.text.trim();
    final title = _title.text.trim();
    if (body.isEmpty && title.isEmpty) {
      setState(() => _status = 'notes.writeFirst');
      return;
    }
    setState(() => _saving = true);
    _debounce?.cancel();
    final now = DateTime.now();
    // Keep an absent title absent; the reader supplies a live localized label.
    final effectiveTitle = title;
    // Editing a source invalidates the original verification stamp.
    final item = widget.item?.copyWith(
      title: effectiveTitle, fullAnswer: body, updatedAt: now,
      verificationStatus: widget.item!.documentKind == BookmarkDocumentKind.personalNote
          ? BookmarkVerificationStatus.notApplicable
          : BookmarkVerificationStatus.needsReview,
    ) ?? BookmarkModel(
      id: _noteId, title: effectiveTitle,
      agentId: 'catatan_mandiri', agentTitle: context.tr('notes.personal'),
      fieldName: context.tr('notes.personal'), fieldId: 'general',
      arabicExcerpt: '', fullAnswer: body, bookReference: '', pageNumber: '',
      createdAt: now, updatedAt: now,
      documentKind: BookmarkDocumentKind.personalNote,
      verificationStatus: BookmarkVerificationStatus.notApplicable,
    );
    try {
      await _draftWrite;
      if (!_ownerValid) return;
      await BookmarkService().addBookmark(item, userId: _owner ?? 'guest_local');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
      if (!mounted || !_ownerValid) return;
      widget.onSaved?.call(item);
      setState(() { _dirty = false; _allowPop = true; });
      Navigator.pop(context, item);
    } catch (_) {
      if (mounted) setState(() => _status = 'notes.saveFailed');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _authSubscription?.cancel();
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = OTColors.textSecondary(dark);
    final arabic = _direction == TextDirection.rtl;
    return PopScope(
      canPop: _allowPop || (!_dirty && !_saving),
      onPopInvokedWithResult: (didPop, result) { if (!didPop) _close(); },
      child: Container(
        color: OTColors.canvas(dark),
        height: widget.fullScreen ? double.infinity : MediaQuery.sizeOf(context).height * .9,
        child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxWidth < 380 ||
                  MediaQuery.textScalerOf(context).scale(14) > 20;
              final title = Text(widget.item == null ? context.tr('notes.new') : context.tr('notes.editNote'),
                  style: OTTypography.screenTitle());
              final close = IconButton(tooltip: context.tr('notes.close'),
                  onPressed: _saving ? null : _close,
                  icon: const Icon(Icons.close_rounded, size: 22));
              final actions = Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(tooltip: _preview ? context.tr('notes.resume') : context.tr('notes.preview'),
                    onPressed: _invalidSession || _saving ? null : () {
                      FocusScope.of(context).unfocus();
                      setState(() => _preview = !_preview);
                    }, icon: Icon(_preview ? Icons.edit_outlined : Icons.visibility_outlined, size: 22)),
                EditorialButton(label: context.tr('notes.save'), busy: _saving,
                    onPressed: _invalidSession ? null : _save),
              ]);
              if (compact) {
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [close, Expanded(child: title)]),
                  const SizedBox(height: 4),
                  Align(alignment: AlignmentDirectional.centerEnd, child: actions),
                ]);
              }
              return Row(children: [close, Expanded(child: title), actions]);
            })),
          const Divider(height: 1),
          if (!_preview && !_invalidSession)
            SingleChildScrollView(scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                _tool(context.tr('notes.bold'), Icons.format_bold, () => _format('**', '**')),
                _tool(context.tr('notes.heading'), Icons.title, () => _format('\n## ', '\n')),
                _tool(context.tr('notes.list'), Icons.format_list_bulleted, () => _format('\n- ', '')),
                _tool(context.tr('notes.quote'), Icons.format_quote, () => _format('\n> ', '')),
                const SizedBox(width: 12),
                _tool(context.tr('notes.latin'), Icons.format_textdirection_l_to_r,
                    () => setState(() => _direction = TextDirection.ltr), selected: !arabic),
                _tool(context.tr('notes.arabic'), Icons.format_textdirection_r_to_l,
                    () => setState(() => _direction = TextDirection.rtl), selected: arabic),
              ])),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 40),
            child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720),
              child: _invalidSession
                  ? EditorialEmptyState(title: context.tr('notes.session'), description: _status == null ? null : context.tr(_status!))
                  : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      if (_preview) ...[
                        Text(_title.text.isEmpty ? context.tr('notes.untitled') : _title.text,
                          textDirection: _title.text.isEmpty ? Directionality.of(context)
                              : ScholarlyMarkdown.directionOf(_title.text),
                          style: (ScholarlyMarkdown.containsArabic(_title.text) ||
                              (_title.text.isEmpty && context.languageCode == 'ar'))
                              ? OTTypography.arabicReading(height: 1.95).copyWith(fontSize: 30)
                              : OTTypography.pageTitle().copyWith(fontSize: 30)),
                        const SizedBox(height: 24),
                        ScholarlyMarkdown(data: _body.text),
                      ] else ...[
                        TextField(controller: _title, maxLines: null, enabled: !_saving,
                          textDirection: ScholarlyMarkdown.directionOf(_title.text),
                          style: (ScholarlyMarkdown.containsArabic(_title.text) ||
                              (_title.text.isEmpty && context.languageCode == 'ar'))
                              ? OTTypography.arabicReading(height: 1.95).copyWith(fontSize: 30)
                              : OTTypography.pageTitle().copyWith(fontSize: 30, height: 1.3),
                          decoration: InputDecoration(hintText: context.tr('notes.noteTitle'),
                            border: InputBorder.none, filled: false)),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        TextField(controller: _body, minLines: 10, maxLines: null, enabled: !_saving,
                          keyboardType: TextInputType.multiline, textDirection: _direction,
                          style: arabic
                              ? OTTypography.arabicReading(height: 1.95).copyWith(fontSize: 24)
                              : OTTypography.body().copyWith(fontSize: 16, height: 1.85,
                                  fontFamilyFallback: const ['Scheherazade New']),
                          decoration: InputDecoration(
                            hintText: context.tr('notes.bodyHint'),
                            border: InputBorder.none, filled: false)),
                      ],
                    ]))),
          )),
          if (_status != null && !_invalidSession)
            Padding(padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 12),
              child: Semantics(liveRegion: true, child: Text(context.tr(_status!),
                  style: OTTypography.caption(color: secondary)))),
        ]),
      ),
    );
  }

  Widget _tool(String label, IconData icon, VoidCallback action, {bool selected = false}) =>
      IconButton(tooltip: label, onPressed: _saving ? null : action, isSelected: selected,
          icon: Icon(icon, size: 20), constraints: const BoxConstraints(minWidth: 48, minHeight: 48));
}
