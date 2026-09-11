import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_model.dart';

class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  static const String _legacyKey = 'openturath_saved_bookmarks';
  List<BookmarkModel> _cachedBookmarks = [];
  Future<void>? _activeLock;

  Future<T> _synchronized<T>(Future<T> Function() action) async {
    final previousLock = _activeLock;
    final completer = Completer<void>();
    _activeLock = completer.future;
    try {
      if (previousLock != null) {
        await previousLock.timeout(const Duration(seconds: 5), onTimeout: () {});
      }
      return await action();
    } finally {
      completer.complete();
    }
  }

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
      return _cachedBookmarks.isNotEmpty && key == _getKey() ? _cachedBookmarks : [];
    }

    try {
      final list = jsonDecode(raw) as List;
      _cachedBookmarks = list
          .map((e) => BookmarkModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return List.from(_cachedBookmarks);
    } catch (e) {
      // Karantina data korup agar tidak hilang selamanya (F27)
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        await prefs.setString('openturath_bookmarks_corrupted_$timestamp', raw);
      } catch (_) {}
      return List.from(_cachedBookmarks);
    }
  }

  Future<void> saveAll(List<BookmarkModel> bookmarks, {String? userId}) async {
    await _synchronized(() async {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(userId);
      final raw = jsonEncode(bookmarks.map((e) => e.toJson()).toList());
      await prefs.setString(key, raw);
      _cachedBookmarks = List.from(bookmarks);
      notifyListeners();
    });
  }

  Future<void> addBookmark(BookmarkModel bookmark, {String? userId}) async {
    await _synchronized(() async {
      final list = await getBookmarks(userId: userId);
      list.removeWhere((b) => b.id == bookmark.id);
      list.insert(0, bookmark);
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(userId);
      final raw = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(key, raw);
      _cachedBookmarks = List.from(list);
      notifyListeners();
    });
  }

  Future<void> deleteBookmark(String id, {String? userId}) async {
    await _synchronized(() async {
      final list = await getBookmarks(userId: userId);
      list.removeWhere((b) => b.id == id);
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(userId);
      final raw = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(key, raw);
      _cachedBookmarks = List.from(list);
      notifyListeners();
    });
  }

  Future<bool> isBookmarked(String id, {String? userId}) async {
    final list = await getBookmarks(userId: userId);
    return list.any((b) => b.id == id);
  }
}
