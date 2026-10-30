import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/services/bookmark_service.dart';

BookmarkModel note() => BookmarkModel(
      id: 'undo-note',
      title: 'Catatan penting',
      agentId: 'catatan_mandiri',
      agentTitle: '',
      fieldName: '',
      fieldId: 'general',
      arabicExcerpt: '',
      fullAnswer: 'Isi catatan tetap utuh',
      bookReference: '',
      pageNumber: '',
      createdAt: DateTime(2026, 9, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Undo survives synchronization with the deletion from another device',
      () async {
    final original = note();
    final tombstone = original.copyWith(
      updatedAt: DateTime.now().add(const Duration(days: 1)),
      deletedAt: DateTime.now().add(const Duration(days: 1)),
    );
    final service = BookmarkService.forTesting(
      readCloud: (_) async => [tombstone],
    );
    await service.addBookmark(original, userId: 'owner');
    await service.deleteBookmark(original.id, userId: 'owner');
    expect(await service.getBookmarks(userId: 'owner'), isEmpty);

    // First receive the newer tombstone, including a device clock ahead of ours.
    await service.syncWithCloud(userId: 'owner');
    await service.restoreBookmark(original, userId: 'owner');
    await service.syncWithCloud(userId: 'owner');

    final restored = (await service.getBookmarks(userId: 'owner')).single;
    expect(restored.fullAnswer, original.fullAnswer);
    expect(restored.deletedAt, isNull);
    expect(restored.toJson()['deletedAt'], isNull);
    expect(restored.syncTime.isAfter(tombstone.syncTime), isTrue);
    expect(await service.getBookmarks(userId: 'other'), isEmpty);
    service.dispose();
  });

  test('clearing a tombstone is explicit and ordinary edits keep it', () {
    final deleted = note().copyWith(deletedAt: DateTime(2026, 10, 30));
    expect(deleted.copyWith(title: 'Edit').isDeleted, isTrue);
    expect(deleted.copyWith(clearDeletedAt: true).isDeleted, isFalse);
  });
}
