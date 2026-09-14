import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/term_model.dart';
import '../../core/i18n/translations.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_spacing.dart';
import '../theme/ot_radius.dart';

/// OpenTurath Share Sheet — Share kartu definisi sebagai teks terformat
class OTShareSheet extends StatelessWidget {
  final Term term;
  final Definition definition;
  final String langCode;
  final VoidCallback onClose;

  const OTShareSheet({
    super.key,
    required this.term,
    required this.definition,
    required this.langCode,
    required this.onClose,
  });

  String get _shareText {
    final lines = <String>[];
    lines.add('┌─ ${term.arabic} ─┐');
    if (definition.text.ar.isNotEmpty) lines.add(definition.text.ar);
    if (definition.text.id.isNotEmpty) lines.add('\n${definition.text.id}');
    if (definition.text.en.isNotEmpty) lines.add('\n${definition.text.en}');
    lines.add('\n— ${definition.source}');
    lines.add('└─ Kamus Fikih Tahawwulat ─┘');
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              decoration: BoxDecoration(
                color: OTColors.canvas(isDark),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(OTRadius.sheet),
                ),
                border: Border(
                  top: BorderSide(
                    color: OTColors.border(isDark),
                    width: 0.8,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: OTColors.textTertiary(isDark).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.lg),

                      // Title
                      Text(
                        KamusTranslations.tr('share', langCode),
                        style: OTTypography.screenTitle(
                          color: OTColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.lg),

                      // Preview card
                      Container(
                        padding: const EdgeInsets.all(OTSpacing.base),
                        decoration: BoxDecoration(
                          color: OTColors.surfaceSubtle(isDark),
                          borderRadius: BorderRadius.circular(OTRadius.card),
                          border: Border.all(
                            color: OTColors.border(isDark),
                            width: 0.8,
                          ),
                        ),
                        child: SelectableText(
                          _shareText,
                          style: OTTypography.body(
                            color: OTColors.textPrimary(isDark),
                          ).copyWith(height: 1.55),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.lg),

                      // Copy action
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _shareText));
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(KamusTranslations.tr('copy', langCode)),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          onClose();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
                          decoration: BoxDecoration(
                            color: OTColors.accent(isDark),
                            borderRadius: BorderRadius.circular(OTRadius.pill),
                          ),
                          child: Center(
                            child: Text(
                              KamusTranslations.tr('copy', langCode),
                              style: OTTypography.button(
                                color: isDark ? OTColors.textPrimaryLight : OTColors.textPrimaryDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
