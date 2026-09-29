import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/services/bookmark_service.dart';

BookmarkModel _note(String id, String body) => BookmarkModel(
      id: id,
      title: id,
      agentId: 'catatan_mandiri',
      agentTitle: '',
      fieldName: '',
      fieldId: 'general',
      arabicExcerpt: '',
      fullAnswer: body,
      bookReference: '',
      pageNumber: '',
      createdAt: DateTime(2026, 9, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final mutation in ['add', 'edit', 'delete']) {
    test('$mutation during remote fetch survives cloud reconciliation',
        () async {
      final requested = Completer<void>();
      final response = Completer<List<BookmarkModel>>();
      final service = BookmarkService.forTesting(readCloud: (uid) {
        expect(uid, 'audit');
        requested.complete();
        return response.future;
      });
      final original = _note('existing', 'Versi lama');
      await service.addBookmark(original, userId: 'audit');
      final sync = service.syncWithCloud(userId: 'audit');
      await requested.future;

      switch (mutation) {
        case 'add':
          await service.addBookmark(_note('new', 'Baru'), userId: 'audit');
        case 'edit':
          await service.addBookmark(
              original.copyWith(
                fullAnswer: 'Versi terbaru',
                updatedAt: DateTime.now(),
              ),
              userId: 'audit');
        case 'delete':
          await service.deleteBookmark(original.id, userId: 'audit');
      }
      response.complete([original]);
      await sync;

      final saved = await service.getBookmarks(userId: 'audit');
      switch (mutation) {
        case 'add':
          expect(
              saved.map((item) => item.id), containsAll(['existing', 'new']));
        case 'edit':
          expect(saved.single.fullAnswer, 'Versi terbaru');
        case 'delete':
          expect(saved, isEmpty);
      }
    });
  }
}
