import 'package:flutter/material.dart';
import '../../core/models/term_model.dart';
import '../../core/utils/quote_card_exporter.dart';
import '../../core/i18n/translations.dart';
import '../widgets/glass_panel.dart';

class ClassicShareModal extends StatefulWidget {
  final Term term;
  final Definition definition;
  final String langCode;
  final VoidCallback onClose;

  const ClassicShareModal({
    super.key,
    required this.term,
    required this.definition,
    required this.langCode,
    required this.onClose,
  });

  @override
  State<ClassicShareModal> createState() => _ClassicShareModalState();
}

class _ClassicShareModalState extends State<ClassicShareModal> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassPanel(
        isThick: true,
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    KamusTranslations.tr('share', widget.langCode),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // The Visual Card to be captured & shared
              RepaintBoundary(
                key: _cardKey,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                          : const [Color(0xFFFFFFFF), Color(0xFFE2E8F0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0x33FFFFFF) : const Color(0x22000000),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card Top Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              KamusTranslations.tr('appName', widget.langCode),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          const Icon(Icons.qr_code_2, size: 24, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Arabic Term Title
                      Text(
                        widget.term.arabic,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.term.english} / ${widget.term.indonesian}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Divider(height: 24),

                      // Definition Text Arabic
                      Text(
                        widget.definition.text.ar,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),

                      // Indonesian translation
                      if (widget.definition.text.id.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x22FFFFFF) : const Color(0x10000000),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.definition.text.id,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Book Source Pill
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x40334155) : const Color(0x30CBD5E1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.definition.source,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: widget.onClose,
                      child: Text(KamusTranslations.tr('close', widget.langCode)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: _isSharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.share, size: 18),
                      label: Text(
                        KamusTranslations.tr('share', widget.langCode),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isSharing ? null : _handleShare,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);
    await QuoteCardExporter.captureAndShare(
      _cardKey,
      title: widget.term.arabic,
      text: '${widget.term.arabic}\n\n${widget.definition.text.ar}\n\n— ${widget.definition.source}',
    );
    if (mounted) {
      setState(() => _isSharing = false);
      widget.onClose();
    }
  }
}
