import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../core/copied_answer.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import '../models/answer_citation.dart';
import '../models/turath_chat_message.dart';
import '../services/bookmark_service.dart';

/// Antarmuka obrolan 100% native Flutter dengan estetika "The Quiet Islamic Scholar".
class NativeTurathChatView extends StatefulWidget {
  final AgentModel agent;
  final List<TurathChatMessage> messages;
  final bool isGenerating;
  final ValueChanged<String> onSend;
  final VoidCallback? onSwitchToWeb;

  const NativeTurathChatView({
    super.key,
    required this.agent,
    required this.messages,
    required this.isGenerating,
    required this.onSend,
    this.onSwitchToWeb,
  });

  @override
  State<NativeTurathChatView> createState() => _NativeTurathChatViewState();
}

class _NativeTurathChatViewState extends State<NativeTurathChatView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final BookmarkService _bookmarkService = BookmarkService();

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.35, end: 0.90).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final canSend =
        _textController.text.trim().isNotEmpty && !widget.isGenerating;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  @override
  void didUpdateWidget(NativeTurathChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _canSend = _textController.text.trim().isNotEmpty && !widget.isGenerating;
    if (widget.messages.length != oldWidget.messages.length ||
        (widget.messages.isNotEmpty &&
            oldWidget.messages.isNotEmpty &&
            widget.messages.last.text != oldWidget.messages.last.text)) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty || widget.isGenerating) return;
    _textController.clear();
    setState(() => _canSend = false);
    widget.onSend(text);
    _scrollToBottom();
  }

  Future<void> _copyMessage(String text) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text.trim()));
    if (mounted) {
      OTMotion.light();
      AppSnackBar.success(context, 'Teks berhasil disalin ke papan klip');
    }
  }

  Future<void> _bookmarkMessage(
    String answer, {
    List<AnswerCitation> citations = const [],
  }) async {
    if (answer.trim().isEmpty) return;
    try {
      final bookmark = copiedAnswerBookmark(answer.trim(), widget.agent,
          citations: citations);
      await _bookmarkService.addBookmark(bookmark);
      if (mounted) {
        OTMotion.light();
        AppSnackBar.success(context, 'Tersimpan ke Koleksi Risalah Anda');
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.warning(context, 'Gagal menyimpan bookmark');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    return Container(
      color: canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
        children: [
          // ── 1. Timeline Obrolan ──
          Expanded(
            child: widget.messages.isEmpty
                ? _buildEmptyState(
                    textPrimary, textSecondary, surfaceSubtle, border)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    itemCount:
                        widget.messages.length + (widget.isGenerating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == widget.messages.length) {
                        return _buildBreathingIndicator(textSecondary);
                      }
                      final msg = widget.messages[index];
                      return msg.isUser
                          ? _buildUserBubble(
                              msg, surfaceSubtle, border, textPrimary)
                          : _buildAssistantMessage(
                              msg, textPrimary, textSecondary, border, isDark);
                    },
                  ),
          ),

          // ── 2. Floating Pill Input Bar ──
          _buildInputBar(
            canvas,
            surface,
            border,
            textPrimary,
            textSecondary,
            accent,
            isDark,
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    Color textPrimary,
    Color textSecondary,
    Color surfaceSubtle,
    Color border,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.agent.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ruang telaah naskah & kajian komparatif berbasis turats.',
              textAlign: TextAlign.center,
              style: OTTypography.caption(color: textSecondary),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildPromptChip(
                    'Syarah & Istinbath', surfaceSubtle, border, textPrimary),
                _buildPromptChip('Takhrij & Kedudukan Hadits', surfaceSubtle,
                    border, textPrimary),
                _buildPromptChip('Tinjauan Mazhab Syafi\'i', surfaceSubtle,
                    border, textPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(
    String label,
    Color bg,
    Color border,
    Color textPrimary,
  ) {
    return InkWell(
      onTap: () {
        _textController.text = label;
        _handleSend();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildUserBubble(
    TurathChatMessage msg,
    Color bg,
    Color border,
    Color textPrimary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(context).width < 800
                ? MediaQuery.sizeOf(context).width
                : 800) * 0.82,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
              border: Border.all(color: border, width: 0.8),
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.outfit(
                fontSize: 14.5,
                height: 1.5,
                color: textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(
    TurathChatMessage msg,
    Color textPrimary,
    Color textSecondary,
    Color border,
    bool isDark,
  ) {
    final containsArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(msg.text);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Konten Teks Jawaban (Aliran Naskah Terbuka)
            containsArabic
                ? _buildScholarlyRichText(msg.text, textPrimary, textSecondary)
                : MarkdownBody(
                    data: msg.text,
                    // Answers are untrusted display text. Do not fetch embedded image URLs.
                    sizedImageBuilder: (config) => Text(config.alt ?? ''),
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.outfit(
                        fontSize: 14.5,
                        height: 1.65,
                        color: textPrimary,
                      ),
                      strong: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      blockquote: GoogleFonts.outfit(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                        color: textSecondary,
                      ),
                    ),
                  ),

            if (msg.citations.isNotEmpty)
              ExpansionTile(
                title: const Text('Rujukan sumber'),
                tilePadding: EdgeInsets.zero,
                children: [
                  for (final citation in msg.citations)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(citation))),
                ],
              ),

            const SizedBox(height: 10),

            // Action Bar Bawah (Salin, Bookmark)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.content_copy_rounded,
                      size: 16, color: textSecondary),
                  tooltip: 'Salin jawaban',
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      _copyMessage([msg.text, ...msg.citations].join('\n\n')),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border_rounded,
                      size: 17, color: textSecondary),
                  tooltip: 'Simpan ke risalah',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _bookmarkMessage(
                      [msg.text, ...msg.citations].join('\n\n'),
                      citations: msg.references),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarlyRichText(
    String raw,
    Color textPrimary,
    Color textSecondary,
  ) {
    final lines = raw.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) return const SizedBox(height: 8);

        final isArabicLine = RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed);

        if (isArabicLine) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              trimmed,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 19,
                height: 2.2,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              trimmed,
              style: GoogleFonts.outfit(
                fontSize: 14.5,
                height: 1.6,
                color: textPrimary,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildBreathingIndicator(Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: FadeTransition(
        opacity: _breathingAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Menelaah rujukan & menyusun penjelasan ilmiah...',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: textSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(
    Color canvas,
    Color surface,
    Color border,
    Color textPrimary,
    Color textSecondary,
    Color accent,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: canvas,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _focusNode.hasFocus ? accent.withAlpha(160) : border,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 50 : 12),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: 4,
                  minLines: 1,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ajukan pertanyaan atau masalah...',
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 13.5,
                      color: textSecondary.withAlpha(160),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Kirim telaah',
                child: Material(
                  color: _canSend ? textPrimary : textSecondary.withAlpha(60),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _canSend ? _handleSend : null,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        size: 18,
                        color: _canSend ? canvas : textSecondary.withAlpha(120),
                      ),
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
