import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import '../core/firestore_public_doc.dart';
import '../models/bookmark_model.dart';
import 'auth_service.dart';
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
  })  : _readCloudOverride = readCloud,
        _currentUserIdOverride = currentUserId;

  final Future<List<BookmarkModel>> Function(String uid)? _readCloudOverride;
  final String? _currentUserIdOverride;

  String? _resolveCurrentUserId() {
    if (_readCloudOverride != null) return _currentUserIdOverride;
    final fbUid = _activeAuth?.currentUser?.uid;
    if (fbUid != null && fbUid.isNotEmpty) return fbUid;
    try {
      final cachedUid = AuthService().cachedCurrentUser?.uid;
      if (cachedUid != null && cachedUid.isNotEmpty) return cachedUid;
    } catch (_) {}
    final webEmail = AuthService.activeWebUserEmail?.trim().toLowerCase();
    if (webEmail != null && webEmail.isNotEmpty) return 'web_$webEmail';
    return null;
  }

  bool _canSyncToFirestore(String? uid) {
    if (uid == null || uid.isEmpty) return false;
    if (_readCloudOverride != null) return true;
    // Windows C++ Firestore SDK rentan abort native (0xC0000409); catatan tetap
    // tersimpan lokal dengan aman tanpa membuka koneksi Firestore C++.
    if (_firestore == null && FirestorePublicDoc.preferRestOnCurrentPlatform) {
      return false;
    }
    final fbUid = _activeAuth?.currentUser?.uid;
    return fbUid != null && fbUid.isNotEmpty && !uid.startsWith('web_');
  }

  String? get currentUserId => _resolveCurrentUserId();

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  bool _isSyncing = false;
  bool _resyncRequested = false;
  Future<bool>? _inFlightSync;

  /// Catatan yang sudah tersimpan di perangkat tetapi belum sampai ke cloud.
  final Set<String> _pendingPushIds = <String>{};
  int get pendingSyncCount => _pendingPushIds.length;
  bool get hasPendingSync => _pendingPushIds.isNotEmpty;

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
    if (FirestorePublicDoc.preferRestOnCurrentPlatform) return null;
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
          notifyListeners();
          unawaited(syncWithCloud(userId: user.uid));
        } else {
          _pendingPushIds.clear();
          notifyListeners();
        }
      });
    } catch (_) {}
    // Dengarkan juga perubahan sesi web/VPS (Windows/macOS tanpa Firebase Auth)
    try {
      AuthService().userStream.listen((user) {
        if (user != null) {
          notifyListeners();
          unawaited(syncWithCloud(userId: user.uid));
        } else {
          _pendingPushIds.clear();
          notifyListeners();
        }
      }, onError: (_) {});
    } catch (_) {}
    // Push yang gagal saat offline dicoba lagi ketika aplikasi kembali aktif.
    try {
      AppLifecycleListener(onResume: () => unawaited(syncWithCloud()));
    } catch (_) {
      // Binding belum tersedia (mis. unit test murni); sinkronisasi login tetap berjalan.
    }
  }

  final _store = ScopedJsonListStore<BookmarkModel>(
    storage: PreferencesStringStore(),
    decode: BookmarkModel.fromJson,
    encode: (bookmark) => bookmark.toJson(),
  );

  static const String _legacyKey = 'openturath_saved_bookmarks';

  String _key(String? userId) {
    final uid = userId ?? _resolveCurrentUserId();
    return uid == null || uid.isEmpty
        ? _legacyKey
        : 'openturath_${uid}_saved_bookmarks';
  }

  Future<List<BookmarkModel>> getBookmarks({String? userId}) async =>
      (await _store.read(_key(userId)))
          .where((bookmark) => !bookmark.isDeleted)
          .toList();

  Future<void> addBookmark(BookmarkModel bookmark, {String? userId}) async {
    final effectiveUid = userId ?? _resolveCurrentUserId();
    final key = _key(effectiveUid);

    // 1. Instant local offline-first update
    await _store.update(key, (items) {
      items.removeWhere((item) => item.id == bookmark.id);
      items.insert(0, bookmark);
      return items;
    });
    notifyListeners();

    // 2. Asynchronous cloud push if logged in with Firebase Auth
    if (_canSyncToFirestore(effectiveUid)) {
      unawaited(_pushToCloud(bookmark, effectiveUid!));
    }
  }

  Future<void> deleteBookmark(String id, {String? userId}) async {
    final effectiveUid = userId ?? _resolveCurrentUserId();
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
    if (_canSyncToFirestore(effectiveUid) && deleted != null) {
      unawaited(_pushToCloud(deleted!, effectiveUid!));
    }
  }

  /// Undo is a new edit, newer than the deletion already queued for sync.
  Future<void> restoreBookmark(BookmarkModel bookmark, {String? userId}) async {
    final effectiveUid = userId ?? _resolveCurrentUserId();
    BookmarkModel? restored;
    await _store.update(_key(effectiveUid), (items) {
      final index = items.indexWhere((item) => item.id == bookmark.id);
      final latest = index == -1 ? bookmark : items[index];
      var restoredAt = DateTime.now();
      for (final knownTime in [bookmark.syncTime, latest.syncTime]) {
        if (!restoredAt.isAfter(knownTime)) {
          restoredAt = knownTime.add(const Duration(microseconds: 1));
        }
      }
      restored = latest.copyWith(
        updatedAt: restoredAt,
        clearDeletedAt: true,
      );
      items.removeWhere((item) => item.id == bookmark.id);
      items.insert(0, restored!);
      return items;
    });
    notifyListeners();
    if (_canSyncToFirestore(effectiveUid)) {
      unawaited(_pushToCloud(restored!, effectiveUid!));
    }
  }

  Future<bool> isBookmarked(String id, {String? userId}) async =>
      (await getBookmarks(userId: userId)).any((item) => item.id == id);

  Future<void> _pushToCloud(BookmarkModel bookmark, String uid) async {
    if (!_canSyncToFirestore(uid)) return;
    final db = _db;
    if (db == null) return;
    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(bookmark.id)
          .set(bookmark.toJson(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 8));
      if (_pendingPushIds.remove(bookmark.id)) notifyListeners();
    } catch (e) {
      // Offline or network glitch; retried on resume, login, or manual sync.
      debugPrint('[BookmarkService] Cloud push skipped/failed: $e');
      if (_pendingPushIds.add(bookmark.id)) notifyListeners();
    }
  }

  bool get isSyncing => _isSyncing;

  Future<void> _migrateLegacyNotes(String userKey) async {
    final legacyNotes = await _store.read(_legacyKey);
    if (legacyNotes.isEmpty) return;
    await _store.update(userKey, (current) {
      final mergedLocal = <String, BookmarkModel>{
        for (final b in current) b.id: b,
      };
      for (final b in legacyNotes) {
        mergedLocal.putIfAbsent(b.id, () => b);
      }
      return mergedLocal.values.toList();
    });
    await _store.replace(_legacyKey, <BookmarkModel>[]);
    notifyListeners();
  }

  /// Bidirectional smart synchronization between local storage and Firestore.
  /// Reconciles differences, migrates legacy offline notes, and ensures zero data loss.
  Future<bool> syncWithCloud({String? userId}) async {
    final effectiveUid = userId ?? _resolveCurrentUserId();
    if (effectiveUid == null || effectiveUid.isEmpty) return false;
    if (!_canSyncToFirestore(effectiveUid)) {
      // Tetap migrasikan catatan anonim lama ke namespace sesi web agar tidak hilang.
      try {
        await _migrateLegacyNotes(_key(effectiveUid));
        return true;
      } catch (e) {
        debugPrint('[BookmarkService] Local legacy migration failed: $e');
        return false;
      }
    }

    if (_isSyncing && _inFlightSync != null) {
      // Jangan buang permintaan atau lapor sukses palsu: tunggu sinkronisasi
      // berjalan selesai lalu jadwalkan satu kali ulangan.
      _resyncRequested = true;
      return _inFlightSync!;
    }

    final future = _performCloudSync(effectiveUid);
    _inFlightSync = future;
    return future;
  }

  Future<bool> _performCloudSync(String effectiveUid) async {
    _isSyncing = true;

    try {
      final userKey = _key(effectiveUid);

      // Step 1: Migrate legacy anonymous notes if any exist
      await _migrateLegacyNotes(userKey);

      final db = _db;
      if (db == null && _readCloudOverride == null) {
        return false;
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
            .get()
            .timeout(const Duration(seconds: 8));
        for (final doc in snapshot.docs) {
          try {
            final data = Map<String, dynamic>.from(doc.data());
            final rawId = data['id']?.toString().trim() ?? '';
            if (rawId.isEmpty) {
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
      await Future.wait(
          toPush.map((bookmark) => _pushToCloud(bookmark, effectiveUid)));
      notifyListeners();
      return _pendingPushIds.isEmpty;
    } catch (e) {
      debugPrint('[BookmarkService] syncWithCloud failed: $e');
      return false;
    } finally {
      _isSyncing = false;
      _inFlightSync = null;
      if (_resyncRequested) {
        _resyncRequested = false;
        unawaited(syncWithCloud());
      }
    }
  }
}
