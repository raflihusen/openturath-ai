import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/widgets/note_editor_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppConfig.localeNotifier.value = 'id';
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openEditor(WidgetTester tester, {BookmarkModel? item}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (context) {
        return TextButton(
          onPressed: () => NoteEditorSheet.show(context, item: item),
          child: const Text('Buka editor'),
        );
      })),
    ));
    await tester.tap(find.text('Buka editor'));
    await tester.pumpAndSettle();
  }

  testWidgets('back immediately preserves the latest draft and restores it',
      (tester) async {
    await openEditor(tester);
    await tester.enterText(find.byType(TextField).first, 'Catatan terbaru');
    await tester.enterText(find.byType(TextField).last, 'Teks belum autosave');
    await tester.pageBack();
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('openturath_draft_note_new');
    expect(raw, isNotNull);
    expect(jsonDecode(raw!)['body'], 'Teks belum autosave');

    await tester.tap(find.text('Buka editor'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'Teks belum autosave');
    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('saving cancels autosave and leaves no resurrected draft',
      (tester) async {
    await openEditor(tester);
    await tester.enterText(find.byType(TextField).last, 'Catatan tersimpan');
    await tester.tap(find.text('Simpan'));
    // Cross the original debounce while the successful route is closing.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('openturath_draft_note_new'), isNull);
    final saved = jsonDecode(prefs.getString('openturath_saved_bookmarks')!) as List;
    expect(saved.single['fullAnswer'], 'Catatan tersimpan');
    expect(tester.takeException(), isNull);
  });

  testWidgets('clearing the editor replaces old draft content with empty text',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'openturath_draft_note_new': jsonEncode({
        'title': 'Draf lama', 'body': 'Isi lama',
      }),
    });
    await openEditor(tester);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.enterText(find.byType(TextField).last, '');
    await tester.pageBack();
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    final draft = jsonDecode(prefs.getString('openturath_draft_note_new')!);
    expect(draft['title'], isEmpty);
    expect(draft['body'], isEmpty);
  });

  testWidgets('restored Arabic draft uses RTL even with Indonesian UI',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'openturath_draft_note_new': jsonEncode({
        'title': 'نص عربي', 'body': 'إنما الأعمال بالنيات',
      }),
    });
    await openEditor(tester);
    expect(tester.widget<TextField>(find.byType(TextField).last).textDirection,
        TextDirection.rtl);
    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('an older draft cannot replace a newer saved note', (tester) async {
    final updated = DateTime(2026, 9, 29, 12);
    final item = BookmarkModel(
      id: 'newer-note', title: 'Versi terbaru', agentId: 'catatan_mandiri',
      agentTitle: '', fieldName: '', fieldId: 'general', arabicExcerpt: '',
      fullAnswer: 'Isi terbaru', bookReference: '', pageNumber: '',
      createdAt: updated.subtract(const Duration(days: 1)), updatedAt: updated,
    );
    SharedPreferences.setMockInitialValues({
      'openturath_draft_note_newer-note': jsonEncode({
        'title': 'Versi lama', 'body': 'Isi lama',
        'savedAt': updated.subtract(const Duration(hours: 1)).toIso8601String(),
      }),
    });
    await openEditor(tester, item: item);
    expect(tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'Isi terbaru');
    await tester.pageBack();
    await tester.pumpAndSettle();
  });
}
