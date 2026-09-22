import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/design/native_design.dart';
import '../services/open_turath_catalog_repository.dart';
import '../widgets/native_components.dart';
import '../widgets/native_theme.dart';
import 'book_library_editorial_screen.dart';

class AiLibraryOverviewPage extends StatefulWidget {
  const AiLibraryOverviewPage(
      {super.key, required this.metadata, this.onSearch});
  final AiLibraryMetadata metadata;
  final VoidCallback? onSearch;
  static PageRoute<void> route(
          {required AiLibraryMetadata metadata, VoidCallback? onSearch}) =>
      MaterialPageRoute<void>(
          builder: (_) => NativeTheme(
              child: AiLibraryOverviewPage(
                  metadata: metadata, onSearch: onSearch)));
  @override
  State<AiLibraryOverviewPage> createState() => _AiLibraryOverviewPageState();
}

class _AiLibraryOverviewPageState extends State<AiLibraryOverviewPage> {
  bool _busy = false;
  String? _error;
  Future<void> _open() async {
    if (_busy) return;
    if (widget.onSearch != null) {
      widget.onSearch!();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final books = await OpenTurathCatalogRepository.instance
          .loadBooksForModule(widget.metadata.keyName);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => NativeTheme(
              child: OpenTurathBookLibraryPage(
                  books: books,
                  collectionName: Loc.isArabic
                      ? widget.metadata.namaArab
                      : Loc.cleanTitle(widget.metadata.nama)))));
    } catch (_) {
      if (mounted) setState(() => _error = NativeCopy.text('error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final meta = widget.metadata;
    final collection = meta.keyName.startsWith('fiqh_tahawwulat');
    return Scaffold(
        backgroundColor: NativeColors.canvas(dark),
        appBar: AppBar(title: Text(NativeCopy.text('aboutCollection'))),
        body: SafeArea(
            child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView(padding: const EdgeInsets.all(20), children: [
                    NativeSection(
                        collection: collection,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meta.namaArab,
                                  textDirection: TextDirection.rtl,
                                  style: NativeType.arabic(dark, size: 34)),
                              if (!Loc.isArabic) ...[
                                const SizedBox(height: 8),
                                Text(Loc.cleanTitle(meta.nama),
                                    style: NativeType.title(dark))
                              ],
                              const SizedBox(height: 24),
                              Text(Loc.tr('bookCount', ['${meta.totalKitab}']),
                                  style: NativeType.body(dark)),
                              const SizedBox(height: 8),
                              Text(Loc.tr('volumeCount', [meta.totalJilid]),
                                  style: NativeType.body(dark)),
                              const SizedBox(height: 8),
                              Text(
                                  Loc.tr('pageCount', ['${meta.totalHalaman}']),
                                  style: NativeType.body(dark)),
                              if (meta.rentangMasa.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Text(meta.rentangMasa,
                                    style: NativeType.meta(dark))
                              ],
                            ])),
                    const SizedBox(height: 24),
                    if (_error != null)
                      NativeEmpty(title: _error!, onAction: _open),
                    FilledButton.icon(
                        onPressed: _busy ? null : _open,
                        icon: const Icon(Icons.menu_book_outlined),
                        label: Text(_busy
                            ? NativeCopy.text('loadingBooks')
                            : NativeCopy.text('catalog'))),
                    const SizedBox(height: 16),
                    Text(NativeCopy.text('studyReminder'),
                        style: NativeType.meta(dark)),
                  ]),
                ))));
  }
}
