import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_model.dart';

class BookmarkService {
  static const String _legacyKey = 'openturath_saved_bookmarks';

  String _getKey([String? userId]) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      return 'openturath_${uid}_saved_bookmarks';
    }
    return _legacyKey;
  }

  Future<List<BookmarkModel>> getBookmarks({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(userId);
    var raw = prefs.getString(key);

    // Auto-migrasi data legacy jika ada
    if ((raw == null || raw.isEmpty) && key != _legacyKey) {
      final legacyRaw = prefs.getString(_legacyKey);
      if (legacyRaw != null && legacyRaw.isNotEmpty) {
        raw = legacyRaw;
        await prefs.setString(key, legacyRaw);
        await prefs.remove(_legacyKey);
      }
    }

    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => BookmarkModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<BookmarkModel> bookmarks, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(userId);
    final raw = jsonEncode(bookmarks.map((e) => e.toJson()).toList());
    await prefs.setString(key, raw);
  }

  Future<void> addBookmark(BookmarkModel bookmark, {String? userId}) async {
    final list = await getBookmarks(userId: userId);
    list.removeWhere((b) => b.id == bookmark.id);
    list.insert(0, bookmark);
    await saveAll(list, userId: userId);
  }

  Future<void> deleteBookmark(String id, {String? userId}) async {
    final list = await getBookmarks(userId: userId);
    list.removeWhere((b) => b.id == id);
    await saveAll(list, userId: userId);
  }

  Future<bool> isBookmarked(String id, {String? userId}) async {
    final list = await getBookmarks(userId: userId);
    return list.any((b) => b.id == id);
  }
}
