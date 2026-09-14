import 'package:flutter/material.dart';
import '../../core/models/term_model.dart';
import '../../core/i18n/translations.dart';
import '../widgets/glass_panel.dart';

class ClassicFavoritesView extends StatelessWidget {
  final List<String> favoriteUids;
  final List<Term> allTerms;
  final ValueChanged<Term> onSelectTerm;
  final String langCode;

  const ClassicFavoritesView({
    super.key,
    required this.favoriteUids,
    required this.allTerms,
    required this.onSelectTerm,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    // Extract favorite definitions
    final favItems = <MapEntry<Term, Definition>>[];
    for (final uid in favoriteUids) {
      final termId = int.tryParse(uid.split('-').first) ?? 0;
      final term = allTerms.where((t) => t.id == termId).firstOrNull;
      if (term != null) {
        final def = term.definitions.where((d) => d.uid == uid).firstOrNull;
        if (def != null) {
          favItems.add(MapEntry(term, def));
        }
      }
    }

    if (favItems.isEmpty) {
      return Center(
        child: GlassPanel(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          borderRadius: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                KamusTranslations.tr('noFavorites', langCode),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                KamusTranslations.tr('noFavoritesDesc', langCode),
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
      itemCount: favItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = favItems[index];
        final term = entry.key;
        final def = entry.value;

        return GlassPanel(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          onTap: () => onSelectTerm(term),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    term.arabic,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.favorite, size: 18, color: Colors.red),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                def.text.ar,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  def.source,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
