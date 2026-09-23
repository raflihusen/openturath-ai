import 'package:flutter/material.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import 'desktop_shortcuts.dart';

class DesktopReferencePanel extends StatefulWidget {
  const DesktopReferencePanel({super.key, required this.agent});
  final AgentModel agent;
  @override
  State<DesktopReferencePanel> createState() => _DesktopReferencePanelState();
}

class _DesktopReferencePanelState extends State<DesktopReferencePanel> {
  final _service = CanonicalLibraryService.instance;
  final _search = TextEditingController();
  final _focus = FocusNode();
  late Future<List<CanonicalBookPresentation>> _books;
  @override
  void initState() {
    super.initState();
    _books = _service.loadCatalogForAgent(widget.agent);
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DesktopShortcuts(
        onFind: _focus.requestFocus,
        onEscape: () {
          setState(_search.clear);
          _focus.unfocus();
        },
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text('Marja’ kitab',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _search,
                      focusNode: _focus,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                          labelText: 'Cari kitab atau pengarang',
                          prefixIcon: Icon(Icons.search),
                          isDense: true)),
                ])),
            Expanded(
                child: FutureBuilder<List<CanonicalBookPresentation>>(
              future: _books,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: TextButton(
                          onPressed: () => setState(() {
                                _books =
                                    _service.loadCatalogForAgent(widget.agent);
                              }),
                          child: const Text('Muat ulang daftar kitab')));
                }
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final books =
                    _service.filterBooks(snapshot.data!, _search.text);
                if (books.isEmpty)
                  return const Center(child: Text('Kitab tidak ditemukan.'));
                return ListView.separated(
                  primary: false,
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ListTile(
                      title: Text(book.titleArabic,
                          textDirection: TextDirection.rtl),
                      subtitle: Text(book.authorArabic,
                          textDirection: TextDirection.rtl),
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.bookDetail, arguments: book),
                    );
                  },
                );
              },
            )),
          ]),
        ),
      );
}
