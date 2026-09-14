import 'package:flutter/material.dart';
import '../../core/models/term_model.dart';
import '../../core/i18n/translations.dart';
import '../widgets/glass_panel.dart';

class ClassicHistoryView extends StatelessWidget {
  final List<int> historyIds;
  final List<Term> allTerms;
  final ValueChanged<Term> onSelectTerm;
  final String langCode;

  const ClassicHistoryView({
    super.key,
    required this.historyIds,
    required this.allTerms,
    required this.onSelectTerm,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    final historyTerms = historyIds
        .map((id) => allTerms.where((t) => t.id == id).firstOrNull)
        .whereType<Term>()
        .toList();

    if (historyTerms.isEmpty) {
      return Center(
        child: GlassPanel(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          borderRadius: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                KamusTranslations.tr('noHistory', langCode),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                KamusTranslations.tr('noHistoryDesc', langCode),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: historyTerms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final term = historyTerms[index];
        return GlassPanel(
          borderRadius: 14,
          padding: const EdgeInsets.all(16),
          onTap: () => onSelectTerm(term),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  term.arabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}
