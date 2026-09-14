import 'package:flutter/material.dart';
import '../../core/models/term_model.dart';
import '../../core/i18n/translations.dart';
import '../widgets/glass_panel.dart';

class ClassicHomeView extends StatelessWidget {
  final List<Term> terms;
  final ValueChanged<Term> onSelectTerm;
  final String langCode;

  const ClassicHomeView({
    super.key,
    required this.terms,
    required this.onSelectTerm,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Pick first or pseudo-random term
    final featuredTerm = terms.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title
          Text(
            KamusTranslations.tr('newTerm', langCode),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Featured Term Glass Card
          GlassPanel(
            isThick: true,
            borderRadius: 20,
            padding: const EdgeInsets.all(24),
            onTap: () => onSelectTerm(featuredTerm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '#${featuredTerm.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    featuredTerm.arabic,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${featuredTerm.english} / ${featuredTerm.indonesian}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (featuredTerm.definitions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    featuredTerm.definitions.first.text.ar,
                    textDirection: TextDirection.rtl,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white60 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x33FFFFFF) : const Color(0x15000000),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        featuredTerm.definitions.first.source,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Total terms stats card
          GlassPanel(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('261', KamusTranslations.tr('allTerms', langCode)),
                Container(width: 1, height: 32, color: Colors.grey.withOpacity(0.3)),
                _buildStatItem('365', 'Definisi & Ibarah'),
                Container(width: 1, height: 32, color: Colors.grey.withOpacity(0.3)),
                _buildStatItem('18', 'Kitab Rujukan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
