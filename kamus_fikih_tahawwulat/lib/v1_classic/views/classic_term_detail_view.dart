import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/term_model.dart';
import '../../core/providers/kamus_providers.dart';
import '../../core/i18n/translations.dart';
import '../widgets/glass_panel.dart';

class ClassicTermDetailView extends ConsumerStatefulWidget {
  final Term term;
  final String langCode;
  final VoidCallback onBack;
  final void Function(Term term, Definition def) onShare;
  final VoidCallback onAiSummary;

  const ClassicTermDetailView({
    super.key,
    required this.term,
    required this.langCode,
    required this.onBack,
    required this.onShare,
    required this.onAiSummary,
  });

  @override
  ConsumerState<ClassicTermDetailView> createState() => _ClassicTermDetailViewState();
}

class _ClassicTermDetailViewState extends ConsumerState<ClassicTermDetailView> {
  bool _showIndonesian = true;
  bool _showEnglish = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: widget.onBack,
        ),
        actions: [
          if (widget.term.definitions.length > 1)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF38BDF8),
              ),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                KamusTranslations.tr('aiSummary', widget.langCode),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: widget.onAiSummary,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Term Title Header Card
            GlassPanel(
              isThick: true,
              borderRadius: 20,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.term.arabic,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'En: ${widget.term.english}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Id: ${widget.term.indonesian}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pill Translation Switches
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildPillToggle('ID', _showIndonesian, () {
                        setState(() => _showIndonesian = !_showIndonesian);
                      }),
                      const SizedBox(width: 8),
                      _buildPillToggle('EN', _showEnglish, () {
                        setState(() => _showEnglish = !_showEnglish);
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Definitions List
            ...widget.term.definitions.map((def) {
              final isFav = favorites.contains(def.uid);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: GlassPanel(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Arabic Matan Text
                      Text(
                        def.text.ar,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.65,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Indonesian translation block
                      if (_showIndonesian && def.text.id.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x22FFFFFF) : const Color(0x10000000),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'ID',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  def.text.id,
                                  style: const TextStyle(fontSize: 13, height: 1.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // English translation block
                      if (_showEnglish && def.text.en.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x22FFFFFF) : const Color(0x10000000),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'EN',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  def.text.en,
                                  style: const TextStyle(fontSize: 13, height: 1.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Definition Footer (Action Menu + Source Pill)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz, size: 22, color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (action) {
                              if (action == 'copy') {
                                final fullText = '${widget.term.arabic}\n\n${def.text.ar}\n\n[ID] ${def.text.id}\n[EN] ${def.text.en}\n\n— ${def.source}';
                                Clipboard.setData(ClipboardData(text: fullText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(KamusTranslations.tr('copy', widget.langCode)),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else if (action == 'share') {
                                widget.onShare(widget.term, def);
                              } else if (action == 'fav') {
                                ref.read(favoritesProvider.notifier).toggleFavorite(def.uid);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'copy',
                                child: Row(
                                  children: [
                                    const Icon(Icons.copy, size: 18),
                                    const SizedBox(width: 10),
                                    Text(KamusTranslations.tr('copy', widget.langCode)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    const Icon(Icons.share, size: 18),
                                    const SizedBox(width: 10),
                                    Text(KamusTranslations.tr('share', widget.langCode)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'fav',
                                child: Row(
                                  children: [
                                    Icon(isFav ? Icons.favorite : Icons.favorite_border,
                                        size: 18, color: isFav ? Colors.red : null),
                                    const SizedBox(width: 10),
                                    Text(KamusTranslations.tr('favorite', widget.langCode)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x30FFFFFF) : const Color(0x15000000),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              def.source,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPillToggle(String label, bool isActive, VoidCallback onToggle) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
