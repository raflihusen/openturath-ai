import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import 'adaptive_sheet.dart';

/// Bahasa jawaban yang ditawarkan. [aliases] adalah nama yang mungkin dipakai
/// pemilih bahasa di halaman (huruf kecil); yang paling spesifik didahulukan.
class OutputLanguage {
  const OutputLanguage(this.code, this.label, this.aliases);
  final String code;
  final String label;
  final List<String> aliases;
}

const outputLanguages = [
  OutputLanguage('id', 'Bahasa Indonesia', [
    'indonesia',
    'bahasa indonesia',
    'indonesian',
  ]),
  OutputLanguage('en', 'English', [
    'english (united states)',
    'english (us)',
    'english',
  ]),
  OutputLanguage('ar', 'العربية', [
    'العربية',
    'arabic',
    'arabic (العربية)',
  ]),
];

/// Lembar pilihan bahasa jawaban. [onSelect] mengganti bahasa di halaman dan
/// mengembalikan true bila berhasil. Lembar selalu menutup setelahnya, supaya
/// jendela cadangan di belakangnya terlihat bila penggantian gagal.
Future<void> showOutputLanguageSheet(
  BuildContext context, {
  required String? current,
  required Future<bool> Function(OutputLanguage language) onSelect,
}) {
  return showAdaptiveSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => _OutputLanguageSheet(current: current, onSelect: onSelect),
  );
}

class _OutputLanguageSheet extends StatefulWidget {
  const _OutputLanguageSheet({required this.current, required this.onSelect});
  final String? current;
  final Future<bool> Function(OutputLanguage language) onSelect;

  @override
  State<_OutputLanguageSheet> createState() => _OutputLanguageSheetState();
}

class _OutputLanguageSheetState extends State<_OutputLanguageSheet> {
  String? _busy;
  late final String? _selected = widget.current;

  Future<void> _choose(OutputLanguage language) async {
    if (_busy != null) return;
    setState(() => _busy = language.code);
    await widget.onSelect(language);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);
    return Container(
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.xl, OTSpacing.lg, OTSpacing.xl, OTSpacing.xxl),
      decoration: BoxDecoration(
        color: OTColors.surface(isDark),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(OTRadius.dialog)),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: SheetGrabber()),
          const SizedBox(height: OTSpacing.base),
          Text(Loc.tr('outputLanguage'),
              style: OTTypography.cardTitle(color: textPrimary)),
          const SizedBox(height: OTSpacing.xs),
          Text(Loc.tr('outputLanguageHint'),
              style: OTTypography.caption(color: textSecondary)),
          const SizedBox(height: OTSpacing.base),
          for (final language in outputLanguages)
            _LanguageRow(
              language: language,
              selected: _selected == language.code,
              busy: _busy == language.code,
              enabled: _busy == null,
              onTap: () => _choose(language),
            ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.language,
    required this.selected,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });
  final OutputLanguage language;
  final bool selected;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final isArabic = language.code == 'ar';
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(OTRadius.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(language.label,
                  textDirection: isArabic ? TextDirection.rtl : null,
                  style: OTTypography.body(color: textPrimary)),
            ),
            if (busy)
              const SizedBox(
                  width: OTSpacing.lg,
                  height: OTSpacing.lg,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else if (selected)
              Icon(Icons.check_rounded, color: textPrimary, size: OTSpacing.lg),
          ],
        ),
      ),
    );
  }
}
