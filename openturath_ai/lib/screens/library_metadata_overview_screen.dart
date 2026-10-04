import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../widgets/ot_motion_widgets.dart';
import '../core/design/ot_colors.dart';
import '../core/app_snackbar.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../services/open_turath_catalog_repository.dart';
import '../widgets/assistant_grid_card.dart';
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
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);
    final metadata = widget.metadata;
    final stats = [
      ...LibraryStat.from(metadata),
      if (metadata.totalKata > 0)
        LibraryStat(
          NumberFormat.compact(locale: Loc.language)
              .format(metadata.totalKata),
          Loc.tr('libraryWords').toLowerCase(),
        ),
    ];

    return Scaffold(
      backgroundColor: OTColors.canvas(isDark),
      appBar: AppBar(
        titleSpacing: otTitleSpacing(context),
        title: Text(Loc.tr('libraryOverview')),
        backgroundColor: OTColors.canvas(isDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: OTColors.surface(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _collectionTitle(metadata),
                          style: Loc.isArabic
                              ? ScholarlyFonts.scheherazadeNew(
                                  color: ink,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  height: 1.6,
                                )
                              : ScholarlyFonts.newsreader(
                                  color: ink,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                        ),
                        if (!Loc.isArabic && metadata.namaArab.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            metadata.namaArab,
                            textDirection: TextDirection.rtl,
                            style: ScholarlyFonts.scheherazadeNew(
                              color: muted,
                              fontSize: 20,
                              height: 1.6,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          Loc.tr('librarySummary'),
                          style: ScholarlyFonts.outfit(
                              color: muted, fontSize: 14, height: 1.55),
                        ),
                        if (stats.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Divider(height: 1, color: border),
                          const SizedBox(height: 20),
                          // Angka pustaka yang benar-benar tercatat.
                          Wrap(
                            spacing: 36,
                            runSpacing: 16,
                            children: [
                              for (final stat in stats)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stat.value,
                                      style: ScholarlyFonts.outfit(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.5,
                                        color: ink,
                                      ).copyWith(fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ]),
                                    ),
                                    Text(
                                      stat.unit,
                                      style: ScholarlyFonts.outfit(
                                          fontSize: 13, color: muted),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _isLoadingBooks ? null : _handleOpenCatalog,
                          iconAlignment: IconAlignment.end,
                          icon: _isLoadingBooks
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.arrow_forward_rounded,
                                  size: 18),
                          label: Text(_isLoadingBooks
                              ? Loc.tr('libraryOpening')
                              : Loc.tr('openCatalog')),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            textStyle: ScholarlyFonts.outfit(
                                fontSize: 14, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: Text(
                      Loc.tr('libraryDataNote'),
                      style: ScholarlyFonts.outfit(fontSize: 12, color: muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
