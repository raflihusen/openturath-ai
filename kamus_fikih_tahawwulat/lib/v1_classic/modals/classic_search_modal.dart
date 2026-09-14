import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/term_model.dart';
import '../../core/providers/kamus_providers.dart';
import '../../core/i18n/translations.dart';
import '../widgets/glass_panel.dart';

class ClassicSearchModal extends ConsumerStatefulWidget {
  final String langCode;
  final ValueChanged<Term> onSelectTerm;
  final VoidCallback onClose;

  const ClassicSearchModal({
    super.key,
    required this.langCode,
    required this.onSelectTerm,
    required this.onClose,
  });

  @override
  ConsumerState<ClassicSearchModal> createState() => _ClassicSearchModalState();
}

class _ClassicSearchModalState extends ConsumerState<ClassicSearchModal> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.65),
      body: SafeArea(
        child: Column(
          children: [
            // Top Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GlassPanel(
                      isThick: true,
                      borderRadius: 999,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                hintText: KamusTranslations.tr('searchPlaceholder', widget.langCode),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                ref.read(searchQueryProvider.notifier).state = val;
                              },
                            ),
                          ),
                          if (query.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _controller.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: widget.onClose,
                    child: Text(
                      KamusTranslations.tr('close', widget.langCode),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: query.isEmpty
                  ? Center(
                      child: Text(
                        KamusTranslations.tr('searchPlaceholder', widget.langCode),
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    )
                  : searchResults.isEmpty
                      ? Center(
                          child: GlassPanel(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(24),
                            borderRadius: 16,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  KamusTranslations.tr('noResultsFound', widget.langCode),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  KamusTranslations.tr('noResultsDesc', widget.langCode),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: searchResults.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final term = searchResults[index];
                            return GlassPanel(
                              borderRadius: 14,
                              onTap: () {
                                widget.onClose();
                                widget.onSelectTerm(term);
                              },
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          term.arabic,
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${term.english} / ${term.indonesian}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? Colors.white70 : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
