import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import 'adaptive_sheet.dart';

/// Satu bahasa jawaban. [name] persis seperti tertulis di pemilih bahasa halaman,
/// dan itulah yang dicocokkan saat memilih.
class OutputLanguage {
  const OutputLanguage(this.code, this.label, this.aliases);

  /// Kode sederhana untuk bahasa utama (id/en/ar); untuk bahasa lain sama dengan nama.
  final String code;
  final String label;
  final List<String> aliases;

  /// Bahasa yang dibaca dari halaman: nama dipakai apa adanya.
  factory OutputLanguage.fromPage(String name) =>
      OutputLanguage(name, name, [name.toLowerCase()]);

  @override
  bool operator ==(Object other) =>
      other is OutputLanguage && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// Tiga bahasa utama OpenTurath: selalu di atas daftar.
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

bool _isRtlName(String text) =>
    RegExp(r'[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]').hasMatch(text);

String _fold(String text) => text.toLowerCase().trim();

/// Gabungkan tiga bahasa utama dengan seluruh bahasa dari halaman. Bahasa dari
/// halaman yang sudah diwakili tiga bahasa utama tidak diulang.
List<OutputLanguage> mergeOutputLanguages(List<String> pageNames) {
  bool covered(String name) {
    final n = _fold(name);
    return outputLanguages.any((l) => l.aliases.contains(n));
  }

  final seen = <String>{};
  final rest = <OutputLanguage>[];
  for (final name in pageNames) {
    final key = _fold(name);
    if (key.isEmpty || covered(name) || !seen.add(key)) continue;
    rest.add(OutputLanguage.fromPage(name));
  }
  return [...outputLanguages, ...rest];
}

/// Saring daftar dengan kata kunci (tanpa membedakan huruf besar/kecil).
List<OutputLanguage> filterOutputLanguages(
    List<OutputLanguage> all, String query) {
  final q = _fold(query);
  if (q.isEmpty) return all;
  return all
      .where((l) =>
          _fold(l.label).contains(q) || l.aliases.any((a) => a.contains(q)))
      .toList();
}

/// Lembar pilihan bahasa jawaban.
///
/// [loadPageLanguages] membaca semua bahasa dari halaman (boleh lama); sementara
/// menunggu, tiga bahasa utama sudah bisa dipilih. [onSelect] mengganti bahasa di
/// halaman dan mengembalikan true bila berhasil. Lembar selalu menutup setelahnya.
Future<void> showOutputLanguageSheet(
  BuildContext context, {
  required String? current,
  required Future<bool> Function(OutputLanguage language) onSelect,
  Future<List<String>> Function()? loadPageLanguages,
}) {
  return showAdaptiveSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) => _OutputLanguageSheet(
      current: current,
      onSelect: onSelect,
      loadPageLanguages: loadPageLanguages,
    ),
  );
}

class _OutputLanguageSheet extends StatefulWidget {
  const _OutputLanguageSheet({
    required this.current,
    required this.onSelect,
    required this.loadPageLanguages,
  });
  final String? current;
  final Future<bool> Function(OutputLanguage language) onSelect;
  final Future<List<String>> Function()? loadPageLanguages;

  @override
  State<_OutputLanguageSheet> createState() => _OutputLanguageSheetState();
}

class _OutputLanguageSheetState extends State<_OutputLanguageSheet> {
  String? _busy;
  String _query = '';
  bool _loading = false;
  List<OutputLanguage> _all = outputLanguages;
  late final String? _selected = widget.current;

  @override
  void initState() {
    super.initState();
    final load = widget.loadPageLanguages;
    if (load != null) {
      _loading = true;
      load().then((names) {
        if (!mounted) return;
        setState(() {
          _all = mergeOutputLanguages(names);
          _loading = false;
        });
      }).catchError((_) {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

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
    final items = filterOutputLanguages(_all, _query);
    final maxHeight = MediaQuery.of(context).size.height * 0.72;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            OTSpacing.xl, OTSpacing.lg, OTSpacing.xl, OTSpacing.lg),
        decoration: BoxDecoration(
          color: OTColors.surface(isDark),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(OTRadius.dialog)),
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
            TextField(
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              style: OTTypography.body(color: textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: Loc.tr('outputLanguageSearch'),
                hintStyle: OTTypography.body(color: textSecondary),
                prefixIcon:
                    Icon(Icons.search_rounded, size: 20, color: textSecondary),
                filled: true,
                fillColor: OTColors.surfaceSubtle(isDark),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OTRadius.chip),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: OTSpacing.sm),
            Flexible(
              child: items.isEmpty
                  ? Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: OTSpacing.xl),
                      child: Center(
                        child: Text(Loc.tr('outputLanguageEmpty'),
                            style: OTTypography.body(color: textSecondary)),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length + (_loading ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == items.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: OTSpacing.md),
                            child: Row(children: [
                              const SizedBox(
                                  width: OTSpacing.lg,
                                  height: OTSpacing.lg,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              const SizedBox(width: OTSpacing.md),
                              Text(Loc.tr('outputLanguageLoading'),
                                  style: OTTypography.caption(
                                      color: textSecondary)),
                            ]),
                          );
                        }
                        final language = items[i];
                        return _LanguageRow(
                          language: language,
                          selected: _selected == language.code,
                          busy: _busy == language.code,
                          enabled: _busy == null,
                          onTap: () => _choose(language),
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
    final rtl = _isRtlName(language.label);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(OTRadius.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(language.label,
                  textDirection: rtl ? TextDirection.rtl : null,
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
