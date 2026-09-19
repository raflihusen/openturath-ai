import '../core/l10n/app_dictionary.dart';
import '../core/l10n/library_dictionary.dart';
import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../services/open_turath_catalog_repository.dart';
import '../widgets/book_row_item.dart';
import '../widgets/editorial.dart';
import 'book_library_editorial_screen.dart';


class AiLibraryOverviewPage extends StatefulWidget {
  const AiLibraryOverviewPage({super.key, required this.metadata, this.onSearch});
  final AiLibraryMetadata metadata;
  final VoidCallback? onSearch;

  static PageRoute<void> route({required AiLibraryMetadata metadata, VoidCallback? onSearch}) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (_, __, ___) => AiLibraryOverviewPage(metadata: metadata, onSearch: onSearch),
      transitionsBuilder: (context, animation, _, child) =>
        MediaQuery.of(context).disableAnimations ? child : FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  State<AiLibraryOverviewPage> createState() => _AiLibraryOverviewPageState();
}

class _AiLibraryOverviewPageState extends State<AiLibraryOverviewPage> {
  bool _loading = false;
  String? _error;

  Future<void> _openCatalog() async {
    if (_loading) return;
    if (widget.onSearch != null) { widget.onSearch!(); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final books = await OpenTurathCatalogRepository.instance.loadBooksForModule(widget.metadata.keyName);
      if (!mounted) return;
      if (books.isEmpty) {
        setState(() => _error = 'library.no_list_retry');
      } else {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OpenTurathBookLibraryPage(
          books: books, collectionName: widget.metadata.nama, collectionKey: widget.metadata.keyName)));
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'library.load_retry');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _number(int value) => context.uiNumber(value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}${context.languageCode == 'id' ? '.' : ','}'));

  @override
  Widget build(BuildContext context) {
    final metadata = widget.metadata;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = OTColors.textSecondary(dark);
    final title = libraryCollectionTitle(metadata.keyName, metadata.nama, context.languageCode);
    final stats = <String>[
      if (metadata.totalKitab > 0) context.tr('library.books_count', args: {'count': libraryBidi(_number(metadata.totalKitab), context.languageCode)}),
      if (metadata.totalJilid.isNotEmpty && metadata.totalJilid != '-') context.uiNumber(libraryDataLabel(metadata.totalJilid, context.languageCode)),
      if (metadata.totalHalaman > 0) context.tr('library.pages_count', args: {'count': libraryBidi(_number(metadata.totalHalaman), context.languageCode)}),
    ];
    return EditorialPage(maxWidth: 720, showBack: true,
      title: title.isEmpty ? context.tr('library.reference_library') : title,
      eyebrow: context.tr('library.overview_eyebrow'), children: [
        if (metadata.namaArab.trim().isNotEmpty) ...[
          EditorialArabicText(metadata.namaArab, fontSize: 28),
          const SizedBox(height: 24),
        ],
        Text(context.tr('library.intro'),
          style: OTTypography.body(color: OTColors.textPrimary(dark))),
        const SizedBox(height: 24),
        Text(stats.isEmpty ? context.tr('library.no_summary') : stats.join('  ·  '),
          style: OTTypography.bodyMedium(color: OTColors.textPrimary(dark))),
        const SizedBox(height: 8),
        Text(context.tr('library.count_notice'),
          style: OTTypography.caption(color: secondary)),
        const SizedBox(height: 24),
        Align(alignment: AlignmentDirectional.centerStart, child: EditorialButton(
          label: context.tr('library.browse'), icon: Icons.search,
          busy: _loading, onPressed: _loading ? null : _openCatalog)),
        if (_error != null) ...[
          const SizedBox(height: 20),
          EditorialEmptyState(title: context.tr('library.unavailable'), description: context.tr(_error!),
            action: EditorialButton(label: context.tr('library.retry'), secondary: true,
              onPressed: _loading ? null : _openCatalog)),
        ],
        const SizedBox(height: 48),
        EditorialSection(title: context.tr('library.about'), child: Column(children: [
          BibliographicField(label: context.tr('library.study_field'), value: metadata.kategori),
          BibliographicField(label: context.tr('library.date_range'), value: metadata.rentangMasa),
          if (metadata.totalDars != null)
            BibliographicField(label: context.tr('library.lessons'), value: _number(metadata.totalDars!)),
          if (metadata.totalMuhadharah != null)
            BibliographicField(label: context.tr('library.lectures'), value: _number(metadata.totalMuhadharah!)),
        ])),
        const SizedBox(height: 32),
        EditorialSection(title: context.tr('library.reading'), child: Text(
          context.tr('library.reading_notice'),
          style: OTTypography.body(color: secondary))),
      ]);
  }
}
