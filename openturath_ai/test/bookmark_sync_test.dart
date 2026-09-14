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

    test('BookmarkModel serialization supports updatedAt and effectiveTime correctly', () {
      final t1 = DateTime(2026, 9, 10, 10, 0);
      final t2 = DateTime(2026, 9, 14, 12, 30);

      final modelWithoutUpdate = BookmarkModel(
        id: 'm1',
        title: 'Title 1',
        agentId: 'fiqh',
        agentTitle: 'Fikih',
        fieldName: 'Fiqih',
        fieldId: 'fiqh',
        arabicExcerpt: 'نص',
        fullAnswer: 'Isi',
        bookReference: 'Kitab',
        pageNumber: '1',
        createdAt: t1,
      );

      expect(modelWithoutUpdate.effectiveTime, t1);

      final modelWithUpdate = modelWithoutUpdate.copyWith(
        fullAnswer: 'Catatan tambahan yang diperbarui',
        updatedAt: t2,
      );

      expect(modelWithUpdate.effectiveTime, t2);
      expect(modelWithUpdate.fullAnswer, 'Catatan tambahan yang diperbarui');

      final json = modelWithUpdate.toJson();
      expect(json['updatedAt'], t2.toIso8601String());

      final restored = BookmarkModel.fromJson(json);
      expect(restored.updatedAt, t2);
      expect(restored.effectiveTime, t2);
      expect(restored.fullAnswer, 'Catatan tambahan yang diperbarui');
    });

    test('BookmarkService sorts items by effectiveTime descending', () async {
      final service = BookmarkService();
      final tOld = DateTime(2026, 9, 1, 10, 0);
      final tMid = DateTime(2026, 9, 5, 10, 0);
      final tNew = DateTime(2026, 9, 14, 10, 0);

      final oldNote = BookmarkModel(
        id: 'note_old',
        title: 'Catatan Lama',
        agentId: 'fiqh',
        agentTitle: 'Fikih',
        fieldName: 'Fiqih',
        fieldId: 'fiqh',
        arabicExcerpt: '',
        fullAnswer: 'Lama',
        bookReference: 'Kitab',
        pageNumber: '1',
        createdAt: tOld,
      );

      final newNote = BookmarkModel(
        id: 'note_new',
        title: 'Catatan Baru',
        agentId: 'fiqh',
        agentTitle: 'Fikih',
        fieldName: 'Fiqih',
        fieldId: 'fiqh',
        arabicExcerpt: '',
        fullAnswer: 'Baru',
        bookReference: 'Kitab',
        pageNumber: '2',
        createdAt: tMid,
        updatedAt: tNew, // effectiveTime paling baru
      );

      await service.addBookmark(oldNote, userId: 'user_sort');
      await service.addBookmark(newNote, userId: 'user_sort');

      final results = await service.getBookmarks(userId: 'user_sort');
      expect(results.length, 2);
      expect(results[0].id, 'note_new'); // Paling baru harus di atas
      expect(results[1].id, 'note_old');
    });
  });
}
