import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../core/design/ot_colors.dart';
import '../core/app_snackbar.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../services/open_turath_catalog_repository.dart';
import 'book_library_editorial_screen.dart';

String _readerTitle(String value) {
  return value
      .replaceFirst(RegExp(r'^(Super\s+)?AI\s+', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
      .trim();
}

String _collectionTitle(AiLibraryMetadata metadata) {
  if (Loc.isArabic) return metadata.namaArab;
  if (Loc.language == 'id') return _readerTitle(metadata.nama);
  return switch (metadata.keyName) {
    'fiqh_syafii' => 'Shafi‘i jurisprudence',
    'hadits' => 'Hadith and Prophetic tradition',
    'ushul_fiqh' => 'Principles of jurisprudence',
    'bahasa_arab' => 'Arabic language and literature',
    'tafsir' => 'Qur’anic exegesis',
    'fiqh_tahawwulat' => 'Jurisprudence of transformations',
    'tarikh_sirah' => 'History and Prophetic biography',
    'fiqh_muqaran' => 'Comparative jurisprudence',
    'fatawa_masail' => 'Legal opinions and questions',
    'syarah_hadits' => 'Hadith commentaries',
    'fiqh_hanafi' => 'Hanafi jurisprudence',
    'fiqh_maliki' => 'Maliki jurisprudence',
    'fiqh_hanbali' => 'Hanbali jurisprudence',
    'tasawwuf' => 'Spiritual ethics',
    'tajwid_qiraat' => 'Qur’anic recitation',
    'qawaid_fiqhiyyah' => 'Legal maxims',
    'musthalah_hadits' => 'Hadith methodology',
    'aqidah' => 'Theology',
    'thabaqat_tarajim' => 'Scholarly biographies',
    'bibliografi_faharis' => 'Bibliography and indexes',
    _ => metadata.namaArab,
  };
}

/// Halaman Ringkasan Pustaka & Pelatihan AI (Monochrome Editorial)
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
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AiLibraryOverviewPage(
          metadata: metadata,
          onSearch: onSearch,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
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

      if (mounted) {
        setState(() => _isLoadingBooks = false);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OpenTurathBookLibraryPage(
              books: books,
              collectionName: _collectionTitle(widget.metadata),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingBooks = false);
        AppSnackBar.error(context, Loc.tr('catalogError'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 44.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                36,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    children: [
                      _TopBar(metadata: widget.metadata),
                      const SizedBox(height: 16),
                      _ResponsiveMetadataLayout(
                        metadata: widget.metadata,
                        isLoadingBooks: _isLoadingBooks,
                        onOpenCatalog: _handleOpenCatalog,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.metadata});

  final AiLibraryMetadata metadata;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: ink, size: 22),
          tooltip: Loc.tr('back'),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: Text(
            Loc.tr('libraryOverview'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ScholarlyFonts.newsreader(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveMetadataLayout extends StatelessWidget {
  const _ResponsiveMetadataLayout({
    required this.metadata,
    required this.isLoadingBooks,
    required this.onOpenCatalog,
  });

  final AiLibraryMetadata metadata;
  final bool isLoadingBooks;
  final VoidCallback onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroLibraryCard(
          metadata: metadata,
          isLoadingBooks: isLoadingBooks,
          onOpenCatalog: onOpenCatalog,
        ),
        const SizedBox(height: 12),
        _StatsGrid(metadata: metadata),
      ],
    );
  }
}

class _HeroLibraryCard extends StatelessWidget {
  const _HeroLibraryCard({
    required this.metadata,
    required this.isLoadingBooks,
    required this.onOpenCatalog,
  });

  final AiLibraryMetadata metadata;
  final bool isLoadingBooks;
  final VoidCallback onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: OTColors.primaryContainer(isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Loc.tr('libraryOverview'),
                  style: ScholarlyFonts.outfit(
                    color: OTColors.onPrimaryContainer(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                Loc.tr('bookCount', [metadata.totalKitab.toString()]),
                style: ScholarlyFonts.outfit(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                metadata.namaArab,
                textAlign: TextAlign.right,
                style: ScholarlyFonts.scheherazadeNew(
                  color: ink,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.85,
                ),
              ),
            ),
          ),
          if (!Loc.isArabic) ...[
            const SizedBox(height: 8),
            Text(
              _collectionTitle(metadata),
              style: ScholarlyFonts.newsreader(
                color: ink,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            Loc.tr('librarySummary'),
            style: ScholarlyFonts.outfit(
              color: textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoadingBooks ? null : onOpenCatalog,
              icon: isLoadingBooks
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.menu_book_outlined, size: 18),
              label: Text(
                isLoadingBooks
                    ? Loc.tr('libraryOpening')
                    : Loc.tr('openCatalog'),
                style: ScholarlyFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: OTColors.accent(isDark),
                foregroundColor: OTColors.onAccent(isDark),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.metadata});

  final AiLibraryMetadata metadata;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final number = NumberFormat.decimalPattern(Loc.language);
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget tile(IconData icon, String value, String label) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OTColors.surface(dark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: OTColors.border(dark), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: OTColors.textSecondary(dark)),
                const SizedBox(height: 16),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ScholarlyFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    color: OTColors.textPrimary(dark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: ScholarlyFonts.outfit(
                    fontSize: 13,
                    color: OTColors.textSecondary(dark),
                  ),
                ),
              ],
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tile(Icons.menu_book_outlined,
                  number.format(metadata.totalKitab), Loc.tr('libraryWorks')),
              const SizedBox(width: 12),
              tile(
                  Icons.notes_rounded,
                  NumberFormat.compact(locale: Loc.language)
                      .format(metadata.totalKata),
                  Loc.tr('libraryWords')),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          Loc.tr('libraryDataNote'),
          style: ScholarlyFonts.outfit(
            fontSize: 11,
            color: OTColors.textSecondary(dark),
          ),
        ),
      ],
    );
  }
}
