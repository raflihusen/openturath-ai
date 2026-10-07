import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../services/open_turath_catalog_repository.dart';
import '../models/open_turath_book.dart';
import '../widgets/app_loader.dart';
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
  late Future<List<OpenTurathBook>> _books = OpenTurathCatalogRepository.instance
      .loadBooksForModule(widget.metadata.keyName);
  @override
  Widget build(BuildContext context) => FutureBuilder<List<OpenTurathBook>>(
    future: _books,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return OpenTurathBookLibraryPage(
          books: snapshot.data!, metadata: widget.metadata,
          collectionName: _collectionTitle(widget.metadata));
      }
      return Scaffold(appBar: AppBar(title: Text(Loc.tr('libraryOverview'))),
        body: snapshot.hasError ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(Loc.tr('catalogFailure')),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => setState(() {
            _books = OpenTurathCatalogRepository.instance.loadBooksForModule(widget.metadata.keyName);
          }), child: Text(Loc.tr('retryCatalog'))),
        ])) : AppLoader.fullscreen(subtitle: Loc.tr('loadingReferences')));
    });
}
