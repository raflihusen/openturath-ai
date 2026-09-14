import 'package:flutter/material.dart';
import '../../core/models/term_model.dart';
import '../../core/i18n/translations.dart';
import '../widgets/glass_panel.dart';

class ClassicAllTermsView extends StatelessWidget {
  final List<Term> terms;
  final ValueChanged<Term> onSelectTerm;
  final String langCode;

  const ClassicAllTermsView({
    super.key,
    required this.terms,
    required this.onSelectTerm,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: terms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final term = terms[index];
        return GlassPanel(
          borderRadius: 14,
          padding: const EdgeInsets.all(16),
          onTap: () => onSelectTerm(term),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x22FFFFFF) : const Color(0x15000000),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 14),
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
                      langCode == 'en' ? term.english : term.indonesian,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
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
