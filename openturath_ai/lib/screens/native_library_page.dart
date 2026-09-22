import 'package:flutter/material.dart';
import '../core/design/native_design.dart';
import '../core/localization.dart';
import '../models/agent_model.dart';
import '../models/open_turath_book.dart';
import '../services/open_turath_catalog_repository.dart';
import '../widgets/native_components.dart';
import '../widgets/native_theme.dart';
import 'book_library_editorial_screen.dart';
import 'book_catalog_screen.dart';
import 'library_metadata_overview_screen.dart';

Future<void> openNativeLibrary(BuildContext context, {required AgentModel agent}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NativeTheme(child: NativeLibraryPage(agent: agent))));

class NativeLibraryPage extends StatefulWidget {
  const NativeLibraryPage({super.key, required this.agent});
  final AgentModel agent;
  @override
  State<NativeLibraryPage> createState() => _NativeLibraryPageState();
}
class _NativeLibraryPageState extends State<NativeLibraryPage> {
  late Future<({AiLibraryMetadata? metadata, List<OpenTurathBook> books})> _data;
  @override
  void initState() { super.initState(); _load(); }
  void _load() {
    _data = () async {
      final repo = OpenTurathCatalogRepository.instance;
      final metadata = await repo.getMetadataForModule(widget.agent.id);
      final books = metadata == null ? <OpenTurathBook>[] : await repo.loadBooksForModule(widget.agent.id);
      return (metadata: metadata, books: books);
    }();
  }
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    return FutureBuilder(future: _data, builder: (context, snapshot) {
      if (snapshot.hasData) {
        final data = snapshot.data!;
        if (data.metadata == null) return BookCatalogScreen(agent: widget.agent);
        return OpenTurathBookLibraryPage(books: data.books, collectionName: Loc.isArabic ? widget.agent.titleArabic : widget.agent.title,
          onAbout: () => Navigator.of(context).push(AiLibraryOverviewPage.route(metadata: data.metadata!)));
      }
      return Scaffold(appBar: AppBar(title: Text(NativeCopy.text('sources'))), body: Center(
        child: snapshot.hasError
          ? NativeEmpty(title: NativeCopy.text('error'), onAction: () => setState(_load))
          : NativeLoading(label: NativeCopy.text('loadingBooks')),
      ));
    });
  }
}
