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
  BookmarkService._internal()
      : _readCloudOverride = null,
        _currentUserIdOverride = null {
    _initAuthListener();
  }

  @visibleForTesting
  BookmarkService.forTesting({
    required Future<List<BookmarkModel>> Function(String uid) readCloud,
    String? currentUserId,
  }) : _readCloudOverride = readCloud,
       _currentUserIdOverride = currentUserId;

  final Future<List<BookmarkModel>> Function(String uid)? _readCloudOverride;
  final String? _currentUserIdOverride;
  String? get currentUserId => _readCloudOverride != null
      ? _currentUserIdOverride
      : _activeAuth?.currentUser?.uid;

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

  Future<List<BookmarkModel>> getBookmarks({String? userId}) async =>
      (await _store.read(_key(userId)))
          .where((bookmark) => !bookmark.isDeleted)
          .toList();

  Future<void> saveAll(List<BookmarkModel> bookmarks, {String? userId}) async {
    final key = _key(userId);
    final existing = await _store.read(key);
    final tombstones = existing.where((bookmark) => bookmark.isDeleted);
    await _store.replace(key, [...bookmarks, ...tombstones]);
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
    BookmarkModel? deleted;
    await _store.update(key, (items) {
      final index = items.indexWhere((item) => item.id == id);
      if (index == -1) return items;
      deleted = items[index].copyWith(
        deletedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      items[index] = deleted!;
      return items;
    });
    notifyListeners();

    // 2. Sync a tombstone instead of deleting remotely. An offline older
    // device will then receive the deletion rather than restoring stale data.
    if (effectiveUid != null && effectiveUid.isNotEmpty && deleted != null) {
      unawaited(_pushToCloud(deleted!, effectiveUid));
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
      if (db == null && _readCloudOverride == null) {
        return;
      }

      // Fetch remotely before acquiring the local write lock.
      final cloudMap = <String, BookmarkModel>{};
      final readCloud = _readCloudOverride;
      if (readCloud != null) {
        for (final bookmark in await readCloud(effectiveUid)) {
          cloudMap[bookmark.id] = bookmark;
        }
      } else {
        final snapshot = await db!
            .collection('users')
            .doc(effectiveUid)
            .collection('bookmarks')
            .get();
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
      }

      // Read and merge inside one locked update. A snapshot captured before
      // the network await can erase edits or resurrect deleted notes.
      final toPush = <BookmarkModel>[];
      await _store.update(userKey, (localItems) {
        final merged = <String, BookmarkModel>{
          for (final bookmark in localItems) bookmark.id: bookmark,
        };
        for (final bookmark in localItems) {
          final cloudItem = cloudMap[bookmark.id];
          if (cloudItem == null ||
              bookmark.syncTime.isAfter(cloudItem.syncTime)) {
            toPush.add(bookmark);
          }
        }
        for (final entry in cloudMap.entries) {
          final existing = merged[entry.key];
          if (existing == null ||
              entry.value.syncTime.isAfter(existing.syncTime)) {
            merged[entry.key] = entry.value;
          }
        }
        return merged.values.toList()
          ..sort((a, b) => b.effectiveTime.compareTo(a.effectiveTime));
      });
      for (final bookmark in toPush) {
        unawaited(_pushToCloud(bookmark, effectiveUid));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[BookmarkService] syncWithCloud failed: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
