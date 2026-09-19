import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design/ot_colors.dart';
import '../services/open_turath_catalog_repository.dart';
import 'book_library_editorial_screen.dart';

String _readerTitle(String value) {
  return value
      .replaceFirst(RegExp(r'^AI\\s+', caseSensitive: false), '')
      .replaceAll(RegExp(r'\\s*\\([^)]*\\)'), '')
      .trim();
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
              collectionName: widget.metadata.nama,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingBooks = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pustaka adalah ruang baca obsidian yang disengaja pada kedua mode.
    // Ini menjaga karakter koleksi tetap konsisten, seperti referensi visual.
    const isDark = true;
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
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    children: [
                      _TopBar(metadata: widget.metadata),
                      const SizedBox(height: 24),
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
    const isDark = true;
    final ink = OTColors.textPrimary(isDark);

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: ink, size: 22),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        Text(
          'Pustaka rujukan',
          style: GoogleFonts.newsreader(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final hero = _HeroLibraryCard(
          metadata: metadata,
          isLoadingBooks: isLoadingBooks,
          onOpenCatalog: onOpenCatalog,
        );

        final stats = _StatsGrid(metadata: metadata);

        if (!isWide) {
          return Column(
            children: [
              hero,
              const SizedBox(height: 18),
              stats,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: hero,
            ),
            const SizedBox(width: 22),
            Expanded(
              flex: 6,
              child: stats,
            ),
          ],
        );
      },
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
    const isDark = true;
    final surface = OTColors.surface(isDark);
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
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
                  color: OTColors.surfaceSubtleDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  metadata.kategori.toUpperCase(),
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
                '${metadata.totalKitab} kitab',
                style: GoogleFonts.outfit(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 12),
          Text(
            _readerTitle(metadata.nama),
            style: GoogleFonts.newsreader(
              color: ink,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            metadata.headlineAplikasi.isNotEmpty
                ? metadata.headlineAplikasi
                : 'Khazanah naskah rujukan mu\'tamad berstempel tahqiq ilmiah untuk rujukan santri dan peneliti turats.',
            style: GoogleFonts.outfit(
              color: textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: border, height: 1, thickness: 0.8),
          const SizedBox(height: 20),
          _MetaRow(
            label: 'Rentang Masa',
            value: metadata.rentangMasa,
          ),
          const SizedBox(height: 10),
          _MetaRow(
            label: 'Standar Otoritas',
            value: metadata.badgeOtoritas.isNotEmpty
                ? metadata.badgeOtoritas
                : '100% Kitab Mu\'tamad',
          ),
          const SizedBox(height: 28),
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
                    ? 'Membuka katalog…'
                    : 'Telusuri ${metadata.totalKitab} kitab',
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    const isDark = true;
    final textSecondary = OTColors.textSecondary(isDark);
    final ink = OTColors.textPrimary(isDark);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.metadata});

  final AiLibraryMetadata metadata;

  String _formatNumber(int number) {
    final s = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'KITAB RUJUKAN',
                value: _formatNumber(metadata.totalKitab),
                unit: 'Karya pilihan',
                icon: Icons.auto_stories_outlined,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                label: 'JILID',
                value: metadata.totalJilid,
                unit: 'Naskah cetak',
                icon: Icons.library_books_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'HALAMAN',
                value: _formatNumber(metadata.totalHalaman),
                unit: 'Edisi katalog',
                icon: Icons.article_outlined,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                label: 'KATA',
                value:
                    '${(metadata.totalKata / 1000000).toStringAsFixed(1)} Jt',
                unit: 'Teks rujukan',
                icon: Icons.text_fields_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const isDark = true;
    final surface = OTColors.surface(isDark);
    final ink = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.newsreader(
              color: ink,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: GoogleFonts.outfit(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
