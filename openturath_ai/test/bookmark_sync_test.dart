import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/services/bookmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  BookmarkModel note(String id, {String title = 'Catatan', DateTime? updatedAt}) => BookmarkModel(
    id: id, title: title, agentId: 'fiqh', agentTitle: 'Fikih', fieldName: 'Fikih',
    fieldId: 'fiqh', arabicExcerpt: 'النص', fullAnswer: 'Isi pribadi',
    bookReference: '', pageNumber: '', createdAt: DateTime(2026, 1, 1), updatedAt: updatedAt,
  );

  test('guest notes are isolated by explicit scope', () async {
    final service = BookmarkService();
    await service.addBookmark(note('a'), userId: 'guest_a');
    expect((await service.getBookmarks(userId: 'guest_a')).single.id, 'a');
    expect(await service.getBookmarks(userId: 'guest_b'), isEmpty);
  });

  test('a stale signed-in owner cannot write or read after sign-out', () async {
    final service = BookmarkService();
    await expectLater(service.addBookmark(note('private'), userId: 'previous_account'), throwsStateError);
    await expectLater(service.getBookmarks(userId: 'previous_account'), throwsStateError);
  });

  test('concurrent local updates preserve both notes', () async {
    final service = BookmarkService();
    await Future.wait([
      service.addBookmark(note('a'), userId: 'guest_local'),
      service.addBookmark(note('b'), userId: 'guest_local'),
    ]);
    expect((await service.getBookmarks(userId: 'guest_local')).map((item) => item.id).toSet(), {'a', 'b'});
  });

  test('an old import cannot overwrite a newer edit', () async {
    final service = BookmarkService();
    await service.addBookmark(note('a', title: 'Edited', updatedAt: DateTime(2026, 2, 1)));
    await service.saveAll([note('a', title: 'Old', updatedAt: DateTime(2026, 1, 1)), note('b')]);
    final items = await service.getBookmarks();
    expect(items.firstWhere((item) => item.id == 'a').title, 'Edited');
    expect(items.length, 2);
  });

  test('deletion removes content and old imports do not resurrect it', () async {
    final service = BookmarkService();
    final original = note('a');
    await service.addBookmark(original);
    await service.deleteBookmark('a');
    await service.saveAll([original]);
    expect(await service.getBookmarks(), isEmpty);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('openturath_guest_local_saved_bookmarks')!;
    expect(raw, isNot(contains('Isi pribadi')));
    final tombstone = (jsonDecode(raw) as List).single as Map;
    expect(tombstone['deletedAt'], isNotNull);
  });

  test('unowned legacy notes are not silently imported into a guest or account', () async {
    final legacy = jsonEncode([note('legacy').toJson()]);
    SharedPreferences.setMockInitialValues({'openturath_saved_bookmarks': legacy});
    final service = BookmarkService();
    await service.syncWithCloud(userId: 'signed_account');
    expect(await service.getBookmarks(), isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('openturath_saved_bookmarks'), legacy);
  });
}
