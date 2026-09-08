import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_model.dart';

class BookmarkService {
  static const String _storageKey = 'openturath_saved_bookmarks';


  Future<List<BookmarkModel>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
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

  Future<void> saveAll(List<BookmarkModel> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(bookmarks.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> addBookmark(BookmarkModel bookmark) async {
    final list = await getBookmarks();
    list.removeWhere((b) => b.id == bookmark.id);
    list.insert(0, bookmark);
    await saveAll(list);
  }

  Future<void> deleteBookmark(String id) async {
    final list = await getBookmarks();
    list.removeWhere((b) => b.id == id);
    await saveAll(list);
  }

  Future<bool> isBookmarked(String id) async {
    final list = await getBookmarks();
    return list.any((b) => b.id == id);
  }
}
