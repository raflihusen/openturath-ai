import 'package:flutter/material.dart';
import '../core/app_copy.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../services/open_turath_catalog_repository.dart';
import 'book_library_editorial_screen.dart';

class AiLibraryOverviewPage extends StatefulWidget {
  const AiLibraryOverviewPage({super.key, required this.metadata, this.onSearch});
  final AiLibraryMetadata metadata;
  final VoidCallback? onSearch;
  static PageRoute<void> route({required AiLibraryMetadata metadata, VoidCallback? onSearch}) =>
    MaterialPageRoute<void>(builder: (_) => AiLibraryOverviewPage(metadata: metadata, onSearch: onSearch));
  @override
  State<AiLibraryOverviewPage> createState() => _AiLibraryOverviewPageState();
}

class _AiLibraryOverviewPageState extends State<AiLibraryOverviewPage> {
  bool _loading = false;
  bool _failed = false;
  Future<void> _open() async {
    if (_loading) return;
    if (widget.onSearch != null) {
      widget.onSearch!();
      return;
    }
    setState(() { _loading = true; _failed = false; });
    try {
      final books = await OpenTurathCatalogRepository.instance.loadBooksForModule(widget.metadata.keyName);
      if (!mounted) return;
      if (books.isEmpty) {
        setState(() => _failed = true);
        return;
      }
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OpenTurathBookLibraryPage(
        books: books, collectionName: Loc.cleanTitle(widget.metadata.nama))));
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final metadata = widget.metadata;
    return Scaffold(backgroundColor: OTColors.canvas(dark),
      appBar: AppBar(title: Text(AppCopy.referenceBooks), backgroundColor: OTColors.canvas(dark)),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (metadata.namaArab.isNotEmpty) Text(metadata.namaArab, textDirection: TextDirection.rtl,
              style: OTTypography.arabicDisplay(color: ink).copyWith(fontSize: 32, height: 1.85)),
            const SizedBox(height: 12),
            Text(Loc.text(Loc.cleanTitle(metadata.nama)), style: OTTypography.pageTitle(color: ink)),
            const SizedBox(height: 12),
            Text(Loc.tr('catalogIntro'), style: OTTypography.body(color: muted)),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: OTColors.surface(dark), borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OTColors.border(dark))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${metadata.totalKitab}', style: OTTypography.displayLarge(color: ink)),
                Text(Loc.tr('collection'), style: OTTypography.caption(color: muted)),
                const SizedBox(height: 16),
                Text(Loc.tr('classificationNotice'), style: OTTypography.body(color: muted)),
                const SizedBox(height: 20),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final key in ['matan', 'sharh', 'hashiyah']) Chip(label: Text(Loc.tr(key))),
                ]),
                const SizedBox(height: 20),
                Text(Loc.tr('verificationNotice'), style: OTTypography.caption(color: muted)),
              ])),
            const SizedBox(height: 24),
            if (_failed) Padding(padding: const EdgeInsets.only(bottom: 16),
              child: Text(Loc.tr('catalogError'), style: OTTypography.body(color: muted))),
            FilledButton.icon(onPressed: _loading ? null : _open,
              icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.menu_book_outlined),
              label: Text(Loc.tr(_failed ? 'tryAgain' : 'openCatalog'))),
          ]),
        )),
      )),
    );
  }
}
