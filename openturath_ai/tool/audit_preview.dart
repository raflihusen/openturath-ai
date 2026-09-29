// Local QA entry point: actual product screens with bundled catalog data.
// Firebase, authentication, payment and telemetry are intentionally uninitialized.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/screens/book_catalog_screen.dart';
import 'package:openturath_ai/screens/book_library_editorial_screen.dart';
import 'package:openturath_ai/services/open_turath_catalog_repository.dart';
import 'package:openturath_ai/widgets/note_editor_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _AuditPreview());
}

class _AuditPreview extends StatefulWidget {
  const _AuditPreview();
  @override
  State<_AuditPreview> createState() => _AuditPreviewState();
}

class _AuditPreviewState extends State<_AuditPreview> {
  String _language = 'id';
  bool _dark = false;
  double _width = 390;
  double _textScale = 1;

  @override
  Widget build(BuildContext context) {
    AppConfig.localeNotifier.value = _language;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(_language),
      supportedLocales: Loc.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => LocaleScope(
          child: Scaffold(
        body: Column(children: [
          const Text('LOCAL QA · bundled catalog · isolated browser notes'),
          Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<String>(
                    value: _language,
                    items: [
                      for (final language in Loc.supportedCodes)
                        DropdownMenuItem(
                            value: language, child: Text(language)),
                    ],
                    onChanged: (value) => setState(() => _language = value!)),
                DropdownButton<double>(
                    value: _width,
                    items: [
                      for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0])
                        DropdownMenuItem(
                            value: width, child: Text('${width.toInt()} px')),
                    ],
                    onChanged: (value) => setState(() => _width = value!)),
                TextButton(
                    onPressed: () => setState(() => _dark = !_dark),
                    child: Text(_dark ? 'Light' : 'Dark')),
                TextButton(
                    onPressed: () =>
                        setState(() => _textScale = _textScale == 1 ? 2 : 1),
                    child: Text('Text ${_textScale.toInt()}×')),
              ]),
          Expanded(
              child: Center(
                  child: SizedBox(
            width: _width,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: Size(_width, MediaQuery.sizeOf(context).height - 72),
                textScaler: TextScaler.linear(_textScale),
              ),
              child: child!,
            ),
          ))),
        ]),
      )),
      home: Builder(
          builder: (context) => Scaffold(
                  body: Center(
                      child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  FilledButton(
                      onPressed: () async {
                        final books = await OpenTurathCatalogRepository.instance
                            .loadBooksForModule('hadits');
                        if (!context.mounted) return;
                        Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (_) => OpenTurathBookLibraryPage(
                                books: books,
                                collectionName: 'الحديث الشريف')));
                      },
                      child: const Text('Editorial catalog')),
                  FilledButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) => const BookCatalogScreen())),
                      child: const Text('Canonical catalog')),
                  FilledButton(
                      onPressed: () => NoteEditorSheet.show(context),
                      child: const Text('Notes')),
                ],
              )))),
    );
  }
}
