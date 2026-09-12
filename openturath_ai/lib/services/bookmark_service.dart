import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/bookmark_model.dart';
import 'scoped_json_store.dart';

class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  final _store = ScopedJsonListStore<BookmarkModel>(
    storage: PreferencesStringStore(), decode: BookmarkModel.fromJson,
    encode: (bookmark) => bookmark.toJson(),
  );

  String _key(String? userId) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    return uid == null || uid.isEmpty ? 'openturath_saved_bookmarks' : 'openturath_${uid}_saved_bookmarks';
  }

  Future<List<BookmarkModel>> getBookmarks({String? userId}) => _store.read(_key(userId));

  Future<void> saveAll(List<BookmarkModel> bookmarks, {String? userId}) async {
    final key = _key(userId);
    await _store.replace(key, bookmarks);
    notifyListeners();
  }

  Future<void> addBookmark(BookmarkModel bookmark, {String? userId}) async {
    final key = _key(userId);
    await _store.update(key, (items) {
      items.removeWhere((item) => item.id == bookmark.id);
      items.insert(0, bookmark);
      return items;
    });
    notifyListeners();
  }

  Future<void> deleteBookmark(String id, {String? userId}) async {
    final key = _key(userId);
    await _store.update(key, (items) => items..removeWhere((item) => item.id == id));
    notifyListeners();
  }

  Future<bool> isBookmarked(String id, {String? userId}) async =>
    (await getBookmarks(userId: userId)).any((item) => item.id == id);
}
