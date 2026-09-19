import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/bookmark_model.dart';
import 'scoped_json_store.dart';

/// Account-scoped offline data. Legacy unowned notes are deliberately not imported.
class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService({FirebaseFirestore? firestore, FirebaseAuth? auth}) {
    if (firestore != null) _instance._firestore = firestore;
    if (auth != null && !identical(auth, _instance._auth)) {
      _instance._auth = auth;
      _instance._listenToAuth();
    } else if (_instance._authListener == null) {
      _instance._listenToAuth();
    }
    return _instance;
  }
  BookmarkService._internal();

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  StreamSubscription<User?>? _authListener;
  final Map<String, Future<void>> _syncs = {};
  int _generation = 0;
  String? _observedUid;
  bool get isSyncing => _syncs.containsKey(_activeAuth?.currentUser?.uid);

  FirebaseAuth? get _activeAuth {
    try { return _auth ?? FirebaseAuth.instance; } catch (_) { return null; }
  }
  FirebaseFirestore? get _db {
    try { return _firestore ?? FirebaseFirestore.instance; } catch (_) { return null; }
  }

  void _listenToAuth() {
    _authListener?.cancel();
    _observedUid = _activeAuth?.currentUser?.uid;
    _authListener = _activeAuth?.authStateChanges().listen((user) {
      if (_observedUid != user?.uid) { _generation++; _observedUid = user?.uid; }
      notifyListeners();
      if (user != null) unawaited(syncWithCloud(userId: user.uid));
    });
  }

  final _store = ScopedJsonListStore<BookmarkModel>(
    storage: PreferencesStringStore(),
    decode: BookmarkModel.fromJson,
    encode: (bookmark) => bookmark.toJson(),
  );

  String _scope(String? requested) => requested ?? _activeAuth?.currentUser?.uid ?? 'guest_local';
  String _key(String scope) => 'openturath_${scope}_saved_bookmarks';
  bool _owns(String scope) {
    final uid = _activeAuth?.currentUser?.uid;
    return uid == null ? scope.startsWith('guest_') : uid == scope;
  }
  void _requireOwner(String scope) {
    if (!_owns(scope)) throw StateError('Sesi berubah. Buka kembali catatan dari akun aktif.');
  }

  Future<List<BookmarkModel>> getBookmarks({String? userId}) async {
    final scope = _scope(userId);
    _requireOwner(scope);
    final items = await _store.read(_key(scope));
    _requireOwner(scope);
    return items.where((bookmark) => !bookmark.isDeleted).toList();
  }

  /// Merge export/import snapshots atomically; never erase concurrent edits.
  Future<void> saveAll(List<BookmarkModel> bookmarks, {String? userId}) async {
    final scope = _scope(userId);
    _requireOwner(scope);
    await _store.update(_key(scope), (items) {
      _requireOwner(scope);
      return _merge(items, bookmarks);
    });
    notifyListeners();
    if (_activeAuth?.currentUser?.uid == scope) unawaited(syncWithCloud(userId: scope));
  }

  Future<void> addBookmark(BookmarkModel bookmark, {String? userId}) async {
    final scope = _scope(userId);
    _requireOwner(scope);
    await _store.update(_key(scope), (items) {
      _requireOwner(scope);
      return _merge(items, [bookmark]);
    });
    if (!_owns(scope)) return;
    notifyListeners();
    if (_activeAuth?.currentUser?.uid == scope) unawaited(_pushToCloud(bookmark, scope));
  }

  Future<void> deleteBookmark(String id, {String? userId}) async {
    final scope = _scope(userId);
    _requireOwner(scope);
    BookmarkModel? tombstone;
    await _store.update(_key(scope), (items) {
      _requireOwner(scope);
      final index = items.indexWhere((item) => item.id == id);
      if (index < 0) return items;
      final now = DateTime.now();
      // Keep only synchronization metadata; erase the deleted note's content.
      tombstone = BookmarkModel(
        id: id, title: '', agentId: '', agentTitle: '', fieldName: '', fieldId: '',
        arabicExcerpt: '', fullAnswer: '', bookReference: '', pageNumber: '',
        createdAt: items[index].createdAt, updatedAt: now, deletedAt: now,
      );
      items[index] = tombstone!;
      return items;
    });
    if (!_owns(scope)) return;
    notifyListeners();
    if (_activeAuth?.currentUser?.uid == scope && tombstone != null) {
      unawaited(_pushToCloud(tombstone!, scope));
    }
  }

  Future<bool> isBookmarked(String id, {String? userId}) async =>
      (await getBookmarks(userId: userId)).any((item) => item.id == id);

  static bool _wins(BookmarkModel incoming, BookmarkModel existing) =>
      incoming.syncTime.isAfter(existing.syncTime) ||
      (incoming.syncTime == existing.syncTime && incoming.isDeleted && !existing.isDeleted);

  static List<BookmarkModel> _merge(List<BookmarkModel> current, Iterable<BookmarkModel> incoming) {
    final merged = {for (final item in current) item.id: item};
    for (final item in incoming) {
      final previous = merged[item.id];
      if (previous == null || _wins(item, previous)) merged[item.id] = item;
    }
    return merged.values.toList()..sort((a, b) => b.effectiveTime.compareTo(a.effectiveTime));
  }

  Future<void> _pushToCloud(BookmarkModel bookmark, String uid) async {
    final db = _db;
    if (db == null || _activeAuth?.currentUser?.uid != uid) return;
    try {
      final ref = db.collection('users').doc(uid).collection('bookmarks').doc(bookmark.id);
      await db.runTransaction((transaction) async {
        if (_activeAuth?.currentUser?.uid != uid) throw StateError('Session changed');
        final existing = await transaction.get(ref);
        if (_activeAuth?.currentUser?.uid != uid) throw StateError('Session changed');
        if (existing.exists) {
          final remote = BookmarkModel.fromJson(existing.data()!);
          if (!_wins(bookmark, remote)) return;
        }
        // Replace to ensure tombstones also remove historical content fields.
        transaction.set(ref, bookmark.toJson());
      });
    } catch (_) {
      // Retained locally for the next explicit sync; never log private note data.
    }
  }

  Future<void> syncWithCloud({String? userId}) {
    final uid = userId ?? _activeAuth?.currentUser?.uid;
    if (uid == null || _activeAuth?.currentUser?.uid != uid) return Future<void>.value();
    final running = _syncs[uid];
    if (running != null) return running;
    final operation = _sync(uid, _generation);
    _syncs[uid] = operation;
    notifyListeners();
    return operation.whenComplete(() {
      if (identical(_syncs[uid], operation)) _syncs.remove(uid);
      notifyListeners();
    });
  }

  Future<void> _sync(String uid, int generation) async {
    bool valid() => _activeAuth?.currentUser?.uid == uid && _generation == generation;
    final db = _db;
    if (db == null || !valid()) return;
    try {
      final snapshot = await db.collection('users').doc(uid).collection('bookmarks').get();
      if (!valid()) return;
      final remote = <BookmarkModel>[];
      for (final doc in snapshot.docs) {
        try {
          remote.add(BookmarkModel.fromJson({...doc.data(), 'id': doc.id}));
        } catch (_) { /* A malformed document cannot hide the remaining notes. */ }
      }
      // Read local data under the same lock as the final merge: edits made while
      // the network request was in flight survive reconciliation.
      List<BookmarkModel> merged = [];
      await _store.update(_key(uid), (current) {
        if (!valid()) return current;
        merged = _merge(current, remote);
        return merged;
      });
      if (!valid()) return;
      notifyListeners();
      for (final item in merged) {
        if (!valid()) return;
        await _pushToCloud(item, uid);
      }
    } catch (_) { /* Offline: preserve all local changes for retry. */ }
  }

  @override
  void dispose() {
    _generation++;
    _authListener?.cancel();
    _authListener = null;
    super.dispose();
  }
}
