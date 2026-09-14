import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/term_model.dart';
import '../../core/providers/kamus_providers.dart';
import '../../core/i18n/translations.dart';
import '../widgets/glass_panel.dart';

class ClassicAiSummaryModal extends ConsumerStatefulWidget {
  final Term term;
  final String langCode;
  final VoidCallback onClose;

  const ClassicAiSummaryModal({
    super.key,
    required this.term,
    required this.langCode,
    required this.onClose,
  });

  @override
  ConsumerState<ClassicAiSummaryModal> createState() => _ClassicAiSummaryModalState();
}

class _ClassicAiSummaryModalState extends ConsumerState<ClassicAiSummaryModal> {
  String _detent = 'medium'; // 'medium' | 'large'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiSummaryProvider.notifier).generateSummary(
            term: widget.term,
            languageCode: widget.langCode,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final maxHeight = _detent == 'large'
        ? MediaQuery.of(context).size.height * 0.82
        : MediaQuery.of(context).size.height * 0.55;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassPanel(
        isThick: true,
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        KamusTranslations.tr('aiSummary', widget.langCode),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Detent Selector (Medium / Large)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDetentButton('medium', 'Medium'),
                  const SizedBox(width: 8),
                  _buildDetentButton('large', 'Large'),
                ],
              ),
              const SizedBox(height: 16),

              // Content or Loader
              Expanded(
                child: aiState.isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Menelaah sintesis ibarah...',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.term.arabic,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.term.english} / ${widget.term.indonesian}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const Divider(height: 24),
                            Text(
                              aiState.summary ?? KamusTranslations.tr('aiError', widget.langCode),
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetentButton(String detent, String label) {
    final selected = _detent == detent;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFF2563EB).withOpacity(0.2) : Colors.transparent,
        side: BorderSide(color: selected ? const Color(0xFF2563EB) : Colors.grey.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      onPressed: () => setState(() => _detent = detent),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
