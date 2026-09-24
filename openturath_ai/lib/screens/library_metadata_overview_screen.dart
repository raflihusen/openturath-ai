import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
        Text(
          Loc.tr('libraryOverview'),
          style: ScholarlyFonts.newsreader(
            color: ink,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF222220)
                      : const Color(0xFFEEEEEB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  Loc.tr('libraryOverview'),
                  style: GoogleFonts.outfit(
                    color: textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                Loc.tr('bookCount', [metadata.totalKitab.toString()]),
                style: GoogleFonts.outfit(
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
                style: GoogleFonts.scheherazadeNew(
                  color: ink,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
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
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ink,
                foregroundColor: OTColors.canvas(isDark),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: Loc.tr('libraryWorks'),
                value: number.format(metadata.totalKitab),
                icon: Icons.auto_stories_outlined,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                label: Loc.tr('libraryWords'),
                value: NumberFormat.compact(locale: Loc.language)
                    .format(metadata.totalKata),
                icon: Icons.text_fields_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          Loc.tr('libraryDataNote'),
          style: ScholarlyFonts.outfit(
            fontSize: 11,
            color: OTColors.textSecondary(
                Theme.of(context).brightness == Brightness.dark),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: textSecondary),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.newsreader(
              color: ink,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
