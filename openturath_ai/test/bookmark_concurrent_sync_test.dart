import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/services/bookmark_service.dart';

// Hold the remote read open while exercising real local persistence.
class _DelayedFirestore implements FirebaseFirestore {
  final requested = Completer<void>();
  final response = Completer<QuerySnapshot<Map<String, dynamic>>>();
  final pushed = <String, Map<String, dynamic>>{};

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _Collection(this, path);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Collection implements CollectionReference<Map<String, dynamic>> {
  _Collection(this.db, this.path);
  final _DelayedFirestore db;
  @override
  final String path;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      _Document(db, '${this.path}/$path');

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) {
    if (!db.requested.isCompleted) db.requested.complete();
    return db.response.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Document implements DocumentReference<Map<String, dynamic>> {
  _Document(this.db, this.path);
  final _DelayedFirestore db;
  @override
  final String path;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _Collection(db, '${this.path}/$path');

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    db.pushed[path] = data;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Snapshot implements QuerySnapshot<Map<String, dynamic>> {
  _Snapshot(List<BookmarkModel> items)
      : docs = items.map(_Row.new).toList();
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Row implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _Row(this.item);
  final BookmarkModel item;
  @override
  String get id => item.id;
  @override
  Map<String, dynamic> data() => item.toJson();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

BookmarkModel _note(String id, String body) => BookmarkModel(
      id: id, title: id, agentId: 'catatan_mandiri', agentTitle: '',
      fieldName: '', fieldId: 'general', arabicExcerpt: '', fullAnswer: body,
      bookReference: '', pageNumber: '', createdAt: DateTime(2026, 9, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final mutation in ['add', 'edit', 'delete']) {
    test('$mutation during remote fetch survives cloud reconciliation', () async {
      final db = _DelayedFirestore();
      final service = BookmarkService(firestore: db);
      final original = _note('existing', 'Versi lama');
      await service.addBookmark(original, userId: 'audit');
      final sync = service.syncWithCloud(userId: 'audit');
      await db.requested.future;

      switch (mutation) {
        case 'add':
          await service.addBookmark(_note('new', 'Baru'), userId: 'audit');
        case 'edit':
          await service.addBookmark(original.copyWith(
            fullAnswer: 'Versi terbaru', updatedAt: DateTime.now(),
          ), userId: 'audit');
        case 'delete':
          await service.deleteBookmark(original.id, userId: 'audit');
      }
      db.response.complete(_Snapshot([original]));
      await sync;

      final saved = await service.getBookmarks(userId: 'audit');
      switch (mutation) {
        case 'add':
          expect(saved.map((item) => item.id), containsAll(['existing', 'new']));
        case 'edit':
          expect(saved.single.fullAnswer, 'Versi terbaru');
        case 'delete':
          expect(saved, isEmpty);
      }
    });
  }
}
