import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_layout.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../services/open_turath_catalog_repository.dart';
import '../widgets/app_loader.dart';
import '../widgets/ot_mobile_primitives.dart';
import 'book_library_editorial_screen.dart';

String _readerTitle(String value) => value
    .replaceFirst(RegExp(r'^(Super\s+)?AI\s+', caseSensitive: false), '')
    .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
    .trim();

class AiLibraryOverviewPage extends StatefulWidget {
  const AiLibraryOverviewPage({
    super.key,
    required this.metadata,
    this.onSearch,
  });

  final AiLibraryMetadata metadata;
  final VoidCallback? onSearch;

  static PageRoute<void> route({
    required AiLibraryMetadata metadata,
    VoidCallback? onSearch,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => AiLibraryOverviewPage(
        metadata: metadata,
        onSearch: onSearch,
      ),
    );
  }

  @override
  State<AiLibraryOverviewPage> createState() => _AiLibraryOverviewPageState();
}

class _AiLibraryOverviewPageState extends State<AiLibraryOverviewPage> {
  bool _isLoadingBooks = false;

  Future<void> _handleOpenCatalog() async {
    if (widget.onSearch != null) {
      widget.onSearch!();
      return;
    }

    setState(() => _isLoadingBooks = true);
    try {
      final books = await OpenTurathCatalogRepository.instance
          .loadBooksForModule(widget.metadata.keyName);
      if (!mounted) return;
      setState(() => _isLoadingBooks = false);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OpenTurathBookLibraryPage(
            books: books,
            collectionName: widget.metadata.nama,
          ),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _isLoadingBooks = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final metadata = widget.metadata;

    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      appBar: AppBar(
        title: const Text('Pustaka rujukan'),
        backgroundColor: OTColors.canvas(dark),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: OTConstrainedContent(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: OTSpacing.lg, bottom: 40),
            children: [
              Text(
                metadata.kategori.toUpperCase(),
                style: OTTypography.metadataTag(
                  color: OTColors.textSecondary(dark),
                ),
              ),
              const SizedBox(height: OTSpacing.md),
              Text(
                metadata.namaArab,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: OTTypography.arabicReading(
                  color: OTColors.textPrimary(dark),
                ).copyWith(fontSize: 30, height: 1.45),
              ),
              const SizedBox(height: OTSpacing.sm),
              Text(
                _readerTitle(metadata.nama),
                style: OTTypography.pageTitle(
                  color: OTColors.textPrimary(dark),
                ),
              ),
              const SizedBox(height: OTSpacing.sm),
              Text(
                metadata.headlineAplikasi.isNotEmpty
                    ? metadata.headlineAplikasi
                    : 'Kumpulan kitab rujukan untuk mendampingi kajian Anda.',
                style: OTTypography.body(
                  color: OTColors.textSecondary(dark),
                ),
              ),
              const SizedBox(height: OTSpacing.xl),
              _LibraryFacts(metadata: metadata),
              const SizedBox(height: OTSpacing.xl),
              FilledButton.icon(
                onPressed: _isLoadingBooks ? null : _handleOpenCatalog,
                icon: _isLoadingBooks
                    ? const SizedBox.square(
                        dimension: 18,
                        child: AppLoader(dotSize: 4, spacing: 1),
                      )
                    : const Icon(Icons.menu_book_outlined, size: 19),
                label: Text(
                  _isLoadingBooks
                      ? 'Membuka katalog…'
                      : 'Lihat ${metadata.totalKitab} kitab',
                ),
              ),
              const SizedBox(height: OTSpacing.xl),
              const OTSectionHeader(
                title: 'Tentang koleksi',
                description:
                    'Ringkasan cakupan pustaka sebelum Anda memilih kitab.',
              ),
              const SizedBox(height: OTSpacing.sm),
              _DetailLine(label: 'Rentang masa', value: metadata.rentangMasa),
              _DetailLine(
                label: 'Jenis koleksi',
                value: metadata.badgeOtoritas.isNotEmpty
                    ? metadata.badgeOtoritas
                    : 'Kitab rujukan pilihan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryFacts extends StatelessWidget {
  const _LibraryFacts({required this.metadata});

  final AiLibraryMetadata metadata;

  String _format(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final values = <(String, String)>[
      ('Kitab', _format(metadata.totalKitab)),
      ('Jilid', metadata.totalJilid),
      ('Halaman', _format(metadata.totalHalaman)),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: OTSpacing.md),
          Expanded(child: _Fact(label: values[i].$1, value: values[i].$2)),
        ],
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: OTColors.borderStrong(dark), width: 1.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: OTSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OTTypography.sectionTitle(
                color: OTColors.textPrimary(dark),
              ),
            ),
            const SizedBox(height: OTSpacing.xs),
            Text(
              label,
              style: OTTypography.caption(
                color: OTColors.textSecondary(dark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return OTEditorialRow(
      title: label,
      subtitle: value.trim().isEmpty ? 'Belum tercatat' : value,
    );
  }
}
