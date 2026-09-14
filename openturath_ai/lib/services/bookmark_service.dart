import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/bookmark_model.dart';
import 'scoped_json_store.dart';

class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService({FirebaseFirestore? firestore, FirebaseAuth? auth}) {
    if (firestore != null) _instance._firestore = firestore;
    if (auth != null) _instance._auth = auth;
    return _instance;
  }
  BookmarkService._internal() {
    _initAuthListener();
  }

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  FirebaseAuth? get _activeAuth {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  void _initAuthListener() {
    try {
      _activeAuth?.authStateChanges().listen((user) {
        if (user != null && user.uid.isNotEmpty) {
          syncWithCloud(userId: user.uid);
        }
      });
    } catch (_) {}
  }

  final _store = ScopedJsonListStore<BookmarkModel>(
    storage: PreferencesStringStore(),
    decode: BookmarkModel.fromJson,
    encode: (bookmark) => bookmark.toJson(),
  );

  static const String _legacyKey = 'openturath_saved_bookmarks';

  String _key(String? userId) {
    final uid = userId ?? _activeAuth?.currentUser?.uid;
    return uid == null || uid.isEmpty ? _legacyKey : 'openturath_${uid}_saved_bookmarks';
  }

  Future<List<BookmarkModel>> getBookmarks({String? userId}) => _store.read(_key(userId));

  Future<void> saveAll(List<BookmarkModel> bookmarks, {String? userId}) async {
    final key = _key(userId);
    await _store.replace(key, bookmarks);
    notifyListeners();
  }

  Future<void> addBookmark(BookmarkModel bookmark, {String? userId}) async {
    final effectiveUid = userId ?? _activeAuth?.currentUser?.uid;
    final key = _key(effectiveUid);

    // 1. Instant local offline-first update
    await _store.update(key, (items) {
      items.removeWhere((item) => item.id == bookmark.id);
      items.insert(0, bookmark);
      return items;
    });
    notifyListeners();

    // 2. Asynchronous cloud push if logged in
    if (effectiveUid != null && effectiveUid.isNotEmpty) {
      unawaited(_pushToCloud(bookmark, effectiveUid));
    }
  }

  Future<void> deleteBookmark(String id, {String? userId}) async {
    final effectiveUid = userId ?? _activeAuth?.currentUser?.uid;
    final key = _key(effectiveUid);

    // 1. Instant local update
    await _store.update(key, (items) => items..removeWhere((item) => item.id == id));
    notifyListeners();

    // 2. Asynchronous cloud deletion
    if (effectiveUid != null && effectiveUid.isNotEmpty) {
      unawaited(_deleteFromCloud(id, effectiveUid));
    }
  }

  Future<bool> isBookmarked(String id, {String? userId}) async =>
      (await getBookmarks(userId: userId)).any((item) => item.id == id);

  Future<void> _pushToCloud(BookmarkModel bookmark, String uid) async {
    final db = _db;
    if (db == null) return;
    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(bookmark.id)
          .set(bookmark.toJson(), SetOptions(merge: true));
    } catch (e) {
      // Offline or network glitch; will be reconciled during next sync
      debugPrint('[BookmarkService] Cloud push skipped/failed: $e');
    }
  }

  Future<void> _deleteFromCloud(String id, String uid) async {
    final db = _db;
    if (db == null) return;
    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('[BookmarkService] Cloud delete skipped/failed: $e');
    }
  }

  /// Bidirectional smart synchronization between local storage and Firestore.
  /// Reconciles differences, migrates legacy offline notes, and ensures zero data loss.
  Future<void> syncWithCloud({String? userId}) async {
    final effectiveUid = userId ?? _activeAuth?.currentUser?.uid;
    if (effectiveUid == null || effectiveUid.isEmpty) return;

    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final userKey = _key(effectiveUid);

      // Step 1: Migrate legacy anonymous notes if any exist
      final legacyNotes = await _store.read(_legacyKey);
      if (legacyNotes.isNotEmpty) {
        final current = await _store.read(userKey);
        final mergedLocal = <String, BookmarkModel>{
          for (final b in current) b.id: b,
        };
        for (final b in legacyNotes) {
          mergedLocal.putIfAbsent(b.id, () => b);
        }
        await _store.replace(userKey, mergedLocal.values.toList());
        await _store.replace(_legacyKey, <BookmarkModel>[]);
        notifyListeners();
      }

      final db = _db;
      if (db == null) {
        return;
      }

      // Step 2: Read current local items
      final localItems = await _store.read(userKey);
      final localMap = <String, BookmarkModel>{
        for (final b in localItems) b.id: b,
      };

      // Step 3: Fetch cloud bookmarks
      final snapshot = await db
          .collection('users')
          .doc(effectiveUid)
          .collection('bookmarks')
          .get();

      final cloudMap = <String, BookmarkModel>{};
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          if (!data.containsKey('id') || (data['id'] as String).isEmpty) {
            data['id'] = doc.id;
          }
          final model = BookmarkModel.fromJson(data);
          cloudMap[model.id] = model;
        } catch (_) {}
      }

      // Step 4: Two-way reconciliation
      // - Push any local notes not yet on cloud
      for (final entry in localMap.entries) {
        if (!cloudMap.containsKey(entry.key)) {
          unawaited(_pushToCloud(entry.value, effectiveUid));
        }
      }

      // - Merge cloud into local
      final merged = <String, BookmarkModel>{...localMap};
      for (final entry in cloudMap.entries) {
        final existing = merged[entry.key];
        if (existing == null || entry.value.createdAt.isAfter(existing.createdAt)) {
          merged[entry.key] = entry.value;
        }
      }

      final finalList = merged.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      await _store.replace(userKey, finalList);
      notifyListeners();
    } catch (e) {
      debugPrint('[BookmarkService] syncWithCloud failed: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
