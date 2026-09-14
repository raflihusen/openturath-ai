import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/services/bookmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  BookmarkModel createSampleBookmark({
    required String id,
    required String title,
    String fieldName = 'Fiqih',
    String arabicExcerpt = '',
    String fullAnswer = 'Isi catatan',
  }) {
    return BookmarkModel(
      id: id,
      title: title,
      agentId: 'fiqh',
      agentTitle: 'Fikih & Ushul',
      fieldName: fieldName,
      fieldId: 'fiqh',
      arabicExcerpt: arabicExcerpt,
      fullAnswer: fullAnswer,
      bookReference: 'Fath al-Qarib',
      pageNumber: '12',
      createdAt: DateTime.now(),
    );
  }

  group('BookmarkService Offline-First & Cloud Sync Tests', () {
    test('addBookmark stores item locally and notifies listeners', () async {
      final service = BookmarkService();
      var notificationCount = 0;
      service.addListener(() => notificationCount++);

      final bookmark = createSampleBookmark(
        id: 'note_1',
        title: 'Catatan Fiqh',
        arabicExcerpt: 'كتاب الصلاة',
        fullAnswer: 'Penjelasan rukun shalat.',
      );

      await service.addBookmark(bookmark, userId: 'user_a');
      final list = await service.getBookmarks(userId: 'user_a');

      expect(list.length, 1);
      expect(list.first.title, 'Catatan Fiqh');
      expect(list.first.arabicExcerpt, 'كتاب الصلاة');
      expect(notificationCount, greaterThan(0));
    });

    test('deleteBookmark removes item locally and notifies listeners', () async {
      final service = BookmarkService();
      var notificationCount = 0;
      service.addListener(() => notificationCount++);

      final bookmark = createSampleBookmark(
        id: 'note_to_delete',
        title: 'Catatan Hapus',
        fieldName: 'Tafsir',
        fullAnswer: 'Uraian ayat.',
      );

      await service.addBookmark(bookmark, userId: 'user_a');
      expect((await service.getBookmarks(userId: 'user_a')).length, 1);

      await service.deleteBookmark('note_to_delete', userId: 'user_a');
      expect((await service.getBookmarks(userId: 'user_a')).length, 0);
      expect(notificationCount, greaterThanOrEqualTo(2));
    });

    test('syncWithCloud seamlessly migrates legacy anonymous bookmarks to logged-in user', () async {
      final legacyBookmark = createSampleBookmark(
        id: 'legacy_1',
        title: 'Catatan Warisan Versi Lama',
        fieldName: 'Hadis',
        arabicExcerpt: 'إنما الأعمال بالنيات',
        fullAnswer: 'Hadis pertama Bukhari tentang niat.',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'openturath_saved_bookmarks',
        [jsonEncode(legacyBookmark.toJson())],
      );

      final service = BookmarkService();
      // Initially, user_logged_in has no bookmarks
      final initialUserList = await service.getBookmarks(userId: 'user_logged_in');
      expect(initialUserList, isEmpty);

      // Trigger cloud sync for user_logged_in
      await service.syncWithCloud(userId: 'user_logged_in');

      // Now user_logged_in should have the migrated bookmark
      final updatedUserList = await service.getBookmarks(userId: 'user_logged_in');
      expect(updatedUserList.length, 1);
      expect(updatedUserList.first.id, 'legacy_1');
      expect(updatedUserList.first.title, 'Catatan Warisan Versi Lama');
      expect(updatedUserList.first.arabicExcerpt, 'إنما الأعمال بالنيات');
    });

    test('isBookmarked accurately checks existence per user', () async {
      final service = BookmarkService();
      final bookmark = createSampleBookmark(
        id: 'item_check',
        title: 'Cek Ada',
      );

      expect(await service.isBookmarked('item_check', userId: 'user_x'), isFalse);
      await service.addBookmark(bookmark, userId: 'user_x');
      expect(await service.isBookmarked('item_check', userId: 'user_x'), isTrue);
      expect(await service.isBookmarked('item_check', userId: 'user_y'), isFalse);
    });
  });
}
