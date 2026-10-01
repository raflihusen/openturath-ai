import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

final _nonce = RegExp(r'^[0-9a-f]{32}$');
final _uuid = RegExp(r'^[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$');
final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Firebase's Google subject binds the native owner. The browser independently
/// verifies its observed account email; it does not prove a Google subject.
class CompanionIdentity {
  CompanionIdentity({
    required this.uid,
    required this.googleSub,
    required this.email,
  }) {
    if (uid.isEmpty ||
        uid.length > 128 ||
        !RegExp(r'^\d{1,64}$').hasMatch(googleSub) ||
        email.length > 320 ||
        email != email.toLowerCase() ||
        !_email.hasMatch(email)) {
      throw ArgumentError('Identitas Google tidak valid.');
    }
  }

  final String uid;
  final String googleSub;
  final String email;

  @override
  bool operator ==(Object other) =>
      other is CompanionIdentity &&
      uid == other.uid &&
      googleSub == other.googleSub &&
      email == other.email;
  @override
  int get hashCode => Object.hash(uid, googleSub, email);
}

class _PendingCompanionJob {
  _PendingCompanionJob(this.job, this.record) {
    // Owner revocation can occur while durable queueing is still awaiting IO.
    completer.future.ignore();
  }
  final Map<String, dynamic> job;
  final Map<String, dynamic> record;
  final completer = Completer<Map<String, dynamic>>();
  Timer? timer;
  bool dispatched = false;
}

/// Private, desktop-only IPC. Chrome never calls this server: the registered
/// native messaging host reads runtime.json and authenticates each request.
class BrowserCompanionRuntime extends ChangeNotifier {
  static final _claimedDirectories = <String>{};
  BrowserCompanionRuntime({
    required CompanionIdentity? Function() identity,
    Directory? runtimeDirectory,
    this.responseTimeout = const Duration(seconds: 130),
    this.heartbeatTimeout = const Duration(seconds: 30),
  }) : _identity = identity,
       _directory = runtimeDirectory ?? _defaultDirectory();

  final CompanionIdentity? Function() _identity;
  final Directory _directory;
  final Duration responseTimeout;
  final Duration heartbeatTimeout;
  final _pending = <String, _PendingCompanionJob>{};
  final _ledger = <String, Map<String, dynamic>>{};
  Future<void> _operations = Future<void>.value();
  HttpServer? _server;
  RandomAccessFile? _lock;
  bool _holdsLock = false;
  String? _claimedDirectory;
  CompanionIdentity? _owner;
  String? _bearer;
  String? _epoch;
  String? _clientId;
  DateTime? _lastSeen;
  Timer? _heartbeat;
  String _status = 'stopped';
  bool _disposed = false;

  String get status => _status;
  bool get connected =>
      _server != null &&
      _clientId != null &&
      _ownerMatches &&
      _lastSeen != null &&
      DateTime.now().difference(_lastSeen!) < heartbeatTimeout;
  File get _metadata => File(p.join(_directory.path, 'runtime.json'));
  File get _ledgerFile => File(p.join(_directory.path, 'ledger.json'));

  static Directory _defaultDirectory() {
    final home = Platform.environment['HOME'];
    if (Platform.isMacOS && home != null) {
      return Directory(
        p.join(
          home,
          'Library',
          'Application Support',
          'OpenTurath',
          'Companion',
        ),
      );
    }
    if (Platform.isWindows) {
      return Directory(
        p.join(
          Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path,
          'OpenTurath',
          'Companion',
        ),
      );
    }
    return Directory(
      p.join(
        home ?? Directory.systemTemp.path,
        '.local',
        'share',
        'OpenTurath',
        'Companion',
      ),
    );
  }

  FirebaseFunctionsException _error(String code) => FirebaseFunctionsException(
    code: code,
    message: code == 'uncertain'
        ? 'Permintaan mungkin sudah diproses. Tidak dikirim ulang secara otomatis.'
        : 'Koneksi asisten belum dapat digunakan. Hubungkan kembali akun yang sesuai.',
  );

  CompanionIdentity? get _current {
    try {
      return _identity();
    } catch (_) {
      return null;
    }
  }

  bool get _ownerMatches => _owner != null && _current == _owner;

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _operations = _operations.then((_) async {
      try {
        result.complete(await action());
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  void _maintenance(Future<void> Function() action) {
    unawaited(
      _serial(action).catchError((Object _) {
        _clientId = null;
        _lastSeen = null;
        for (final pending in _pending.values) {
          pending.timer?.cancel();
          pending.record['state'] = 'uncertain';
          if (!pending.completer.isCompleted) {
            pending.completer.completeError(_error('uncertain'));
          }
        }
        _pending.clear();
        _setStatus('unavailable');
      }),
    );
  }

  void _setStatus(String value) {
    if (_status == value) return;
    _status = value;
    if (!_disposed) notifyListeners();
  }

  String _randomHex(int bytes) {
    final random = Random.secure();
    return List.generate(
      bytes,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Future<void> _privateMode(String path, int mode) async {
    if (Platform.isWindows) throw _error('failed-precondition');
    final result = await Process.run('/bin/chmod', [
      mode.toRadixString(8),
      path,
    ]);
    if (result.exitCode != 0 ||
        ((await FileStat.stat(path)).mode & 0x1ff) != mode) {
      throw _error('failed-precondition');
    }
  }

  Future<void> _regularFile(File file, {bool optional = false}) async {
    final type = await FileSystemEntity.type(file.path, followLinks: false);
    if (optional && type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.file ||
        ((await file.stat()).mode & 0x1ff) != 0x180) {
      throw _error('failed-precondition');
    }
  }

  Future<void> _writePrivate(File file, Object value) async {
    await _regularFile(file, optional: true);
    final temporary = File('${file.path}.${_randomHex(16)}.tmp');
    try {
      // Set permissions while empty, before any secret or private record is written.
      await temporary.create();
      await _privateMode(temporary.path, 0x180);
      final handle = await temporary.open(mode: FileMode.write);
      try {
        await handle.writeFrom(utf8.encode(jsonEncode(value)));
        await handle.flush();
      } finally {
        await handle.close();
      }
      await temporary.rename(file.path);
      await _regularFile(file);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<void> _saveLedger() => _writePrivate(_ledgerFile, {
    'version': 1,
    'records': _ledger.values.toList(growable: false),
  });

  Future<void> _loadLedger() async {
    _ledger.clear();
    await _regularFile(_ledgerFile, optional: true);
    if (!await _ledgerFile.exists()) return;
    if (await _ledgerFile.length() > 4 * 1024 * 1024)
      throw _error('failed-precondition');
    final decoded = jsonDecode(await _ledgerFile.readAsString());
    if (decoded is! Map ||
        decoded['version'] != 1 ||
        decoded['records'] is! List ||
        (decoded['records'] as List).length > 4096)
      throw _error('failed-precondition');
    const keys = {
      'requestId',
      'epoch',
      'uid',
      'googleSub',
      'email',
      'notebookId',
      'digest',
      'state',
      'createdAt',
      'updatedAt',
    };
    const states = {
      'queued',
      'dispatched',
      'completed',
      'failed',
      'uncertain',
      'cancelled',
    };
    for (final raw in decoded['records'] as List) {
      if (raw is! Map ||
          raw.keys.toSet().difference(keys).isNotEmpty ||
          raw.length != keys.length ||
          raw['requestId'] is! String ||
          !_nonce.hasMatch(raw['requestId'] as String) ||
          raw['epoch'] is! String ||
          !_nonce.hasMatch(raw['epoch'] as String) ||
          raw['uid'] is! String ||
          raw['googleSub'] is! String ||
          raw['email'] is! String ||
          raw['notebookId'] is! String ||
          !_uuid.hasMatch(raw['notebookId'] as String) ||
          raw['digest'] is! String ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(raw['digest'] as String) ||
          !states.contains(raw['state']) ||
          raw['createdAt'] is! int ||
          raw['updatedAt'] is! int ||
          _ledger.containsKey(raw['requestId']))
        throw _error('failed-precondition');
      CompanionIdentity(
        uid: raw['uid'] as String,
        googleSub: raw['googleSub'] as String,
        email: raw['email'] as String,
      );
      final record = Map<String, dynamic>.from(raw);
      if (record['state'] == 'queued' || record['state'] == 'dispatched') {
        record['state'] = 'uncertain';
        record['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
      }
      _ledger[record['requestId'] as String] = record;
    }
    // Recovery preserves used IDs; it never reconstructs or requeues a question.
    await _saveLedger();
  }

  Future<void> start() => _serial(() async {
    if (_disposed) throw _error('failed-precondition');
    if (!(Platform.isMacOS || Platform.isLinux || Platform.isWindows) ||
        Platform.isWindows) {
      throw _error('failed-precondition');
    }
    if (_server != null) {
      await _checkOwner();
      return;
    }
    final owner = _current;
    if (owner == null) throw _error('unauthenticated');
    _owner = owner;
    _epoch = _randomHex(16);
    _bearer = _randomHex(32);
    try {
      final type = await FileSystemEntity.type(
        _directory.path,
        followLinks: false,
      );
      if (type != FileSystemEntityType.notFound &&
          type != FileSystemEntityType.directory) {
        throw _error('failed-precondition');
      }
      await _directory.create(recursive: true);
      await _privateMode(_directory.path, 0x1c0);
      final canonical = await _directory.resolveSymbolicLinks();
      if (_claimedDirectories.contains(canonical))
        throw _error('failed-precondition');
      _claimedDirectories.add(canonical);
      _claimedDirectory = canonical;
      final lockFile = File(p.join(_directory.path, 'runtime.lock'));
      await _regularFile(lockFile, optional: true);
      await lockFile.create();
      await _privateMode(lockFile.path, 0x180);
      _lock = await lockFile.open(mode: FileMode.append);
      await _lock!.lock(FileLock.exclusive);
      _holdsLock = true;
      await _loadLedger();
      if (!_ownerMatches) throw _error('unauthenticated');
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      if (!_ownerMatches) throw _error('unauthenticated');
      await _writePrivate(_metadata, {
        'version': 1,
        'port': _server!.port,
        'bearer': _bearer,
        'epoch': _epoch,
        'pid': pid,
      });
      if (!_ownerMatches) throw _error('unauthenticated');
      _server!.listen((request) {
        unawaited(_route(request));
      });
      _heartbeat = Timer.periodic(const Duration(seconds: 1), (_) {
        _maintenance(() async {
          if (_server == null) return;
          if (!_ownerMatches) {
            await _invalidate('unauthenticated');
            return;
          }
          if (_clientId != null && !connected) await _invalidate('unavailable');
        });
      });
      _setStatus('waiting');
    } catch (error) {
      await _stopInternal();
      if (error is FirebaseFunctionsException) rethrow;
      throw _error('failed-precondition');
    }
  });

  Future<void> _checkOwner() async {
    if (_ownerMatches) return;
    await _invalidate('unauthenticated');
    throw _error('unauthenticated');
  }

  Future<void> _invalidate(String code) async {
    _clientId = null;
    _lastSeen = null;
    for (final pending in _pending.values.toList(growable: false)) {
      pending.timer?.cancel();
      pending.record['state'] = pending.dispatched ? 'uncertain' : 'cancelled';
      pending.record['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
      if (!pending.completer.isCompleted)
        pending.completer.completeError(
          _error(pending.dispatched ? 'uncertain' : code),
        );
    }
    _pending.clear();
    if (_holdsLock && _ledger.isNotEmpty) await _saveLedger();
    _setStatus(code == 'unauthenticated' ? 'signed-out' : 'waiting');
  }

  Future<Map<String, dynamic>> ask({
    required String expectedUid,
    required String notebookId,
    required String question,
    required String requestId,
    List<List<Object?>>? history,
    String? conversationId,
  }) async {
    final pending = await _serial(() async {
      if (_server == null) throw _error('unavailable');
      await _checkOwner();
      if (_owner!.uid != expectedUid) throw _error('unauthenticated');
      if (!_nonce.hasMatch(requestId) ||
          !_uuid.hasMatch(notebookId) ||
          question.trim().isEmpty ||
          question.length > 8000 ||
          (conversationId != null && !_uuid.hasMatch(conversationId)) ||
          !_validHistory(history))
        throw _error('invalid-argument');
      if (_ledger.containsKey(requestId)) throw _error('failed-precondition');
      if (!connected) throw _error('unavailable');
      if (_ledger.length >= 4096 || _pending.length >= 16)
        throw _error('resource-exhausted');
      if (_pending.values.any((item) => item.job['notebookId'] == notebookId)) {
        throw _error('busy');
      }
      final owner = _owner!;
      final job = <String, dynamic>{
        'requestId': requestId,
        'epoch': _epoch,
        'uid': owner.uid,
        'googleSub': owner.googleSub,
        'email': owner.email,
        'notebookId': notebookId,
        'question': question.trim(),
        'history': history == null ? null : jsonDecode(jsonEncode(history)),
        'conversationId': conversationId,
      };
      final now = DateTime.now().millisecondsSinceEpoch;
      final record = <String, dynamic>{
        'requestId': requestId,
        'epoch': _epoch,
        'uid': owner.uid,
        'googleSub': owner.googleSub,
        'email': owner.email,
        'notebookId': notebookId,
        'digest': sha256.convert(utf8.encode(jsonEncode(job))).toString(),
        'state': 'queued',
        'createdAt': now,
        'updatedAt': now,
      };
      final pending = _PendingCompanionJob(job, record);
      _ledger[requestId] = record;
      _pending[requestId] = pending;
      try {
        await _saveLedger();
        await _checkOwner();
      } catch (error) {
        _pending.remove(requestId);
        pending.record['state'] = 'uncertain';
        if (!pending.completer.isCompleted)
          pending.completer.completeError(_error('uncertain'));
        if (error is FirebaseFunctionsException) rethrow;
        throw _error('uncertain');
      }
      pending.timer = Timer(responseTimeout, () {
        _maintenance(() async {
          if (_pending[requestId] != pending) return;
          pending.record['state'] = 'uncertain';
          pending.record['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
          await _saveLedger();
          _pending.remove(requestId);
          if (!pending.completer.isCompleted)
            pending.completer.completeError(_error('uncertain'));
        });
      });
      return pending;
    });
    final reply = await pending.completer.future;
    if (!_ownerMatches || _owner!.uid != expectedUid)
      throw _error('unauthenticated');
    return reply;
  }

  bool _validHistory(List<dynamic>? history) =>
      history == null ||
      (history.length <= 80 &&
          history.every(
            (turn) =>
                turn is List &&
                turn.length == 3 &&
                turn[0] is String &&
                (turn[0] as String).length <= 128000 &&
                turn[1] == null &&
                (turn[2] == 1 || turn[2] == 2),
          ) &&
          jsonEncode(history).length <= 120000);

  bool _tokenMatches(String? candidate) {
    final expected = 'Bearer $_bearer';
    if (candidate == null || candidate.length != expected.length) return false;
    var different = 0;
    for (var index = 0; index < expected.length; index++) {
      different |= candidate.codeUnitAt(index) ^ expected.codeUnitAt(index);
    }
    return different == 0;
  }

  Future<Map<String, dynamic>> _body(HttpRequest request) async {
    if (request.contentLength > 1024 * 1024) throw _error('invalid-argument');
    final bytes = <int>[];
    final result = Completer<Map<String, dynamic>>();
    late StreamSubscription<List<int>> subscription;
    final timer = Timer(const Duration(seconds: 5), () {
      unawaited(subscription.cancel());
      if (!result.isCompleted)
        result.completeError(_error('deadline-exceeded'));
    });
    subscription = request.listen(
      (chunk) {
        if (result.isCompleted) return;
        if (bytes.length + chunk.length > 1024 * 1024) {
          unawaited(subscription.cancel());
          result.completeError(_error('invalid-argument'));
        } else {
          bytes.addAll(chunk);
        }
      },
      onError: (Object _) {
        if (!result.isCompleted)
          result.completeError(_error('invalid-argument'));
      },
      onDone: () {
        if (result.isCompleted) return;
        try {
          final decoded = jsonDecode(utf8.decode(bytes));
          if (decoded is! Map<String, dynamic>) throw const FormatException();
          result.complete(decoded);
        } catch (_) {
          result.completeError(_error('invalid-argument'));
        }
      },
    );
    try {
      return await result.future;
    } finally {
      timer.cancel();
    }
  }

  Future<void> _respond(
    HttpRequest request,
    int status,
    Map<String, dynamic> body,
  ) async {
    try {
      request.response.statusCode = status;
      request.response.headers.contentType = ContentType.json;
      request.response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
      request.response.write(jsonEncode(body));
      await request.response.close();
    } catch (_) {
      /* A lost acknowledgement never permits replay. */
    }
  }

  Future<void> _route(HttpRequest request) async {
    if (_server == null ||
        request.connectionInfo?.remoteAddress.address != '127.0.0.1' ||
        request.headers.value(HttpHeaders.hostHeader) !=
            '127.0.0.1:${_server!.port}' ||
        request.headers['origin'] != null ||
        !_tokenMatches(
          request.headers.value(HttpHeaders.authorizationHeader),
        )) {
      await _respond(request, 403, {'ok': false, 'code': 'permission-denied'});
      return;
    }
    if (request.method != 'POST' ||
        request.uri.hasQuery ||
        !{
          '/attach',
          '/poll',
          '/result',
          '/disconnect',
        }.contains(request.uri.path)) {
      await _respond(request, 404, {'ok': false, 'code': 'invalid-argument'});
      return;
    }
    try {
      if (!_ownerMatches) {
        await _serial(() => _checkOwner());
      }
      final body = await _body(request);
      final response = await _serial(() async {
        await _checkOwner();
        final allowed = request.uri.path == '/attach'
            ? {'clientId', 'protocol', 'epoch'}
            : request.uri.path == '/result'
            ? {'clientId', 'epoch', 'result'}
            : {'clientId', 'epoch'};
        if (body.keys.toSet().difference(allowed).isNotEmpty ||
            body.length != allowed.length ||
            body['clientId'] is! String ||
            !_nonce.hasMatch(body['clientId'] as String) ||
            body['epoch'] != _epoch)
          throw _error('invalid-argument');
        final clientId = body['clientId'] as String;
        if (request.uri.path == '/attach') {
          if (body['protocol'] is! int || body['protocol'] != 1)
            throw _error('failed-precondition');
          if (_clientId != null && _clientId != clientId && connected)
            throw _error('busy');
          if (_clientId != null && !connected) await _invalidate('unavailable');
          _clientId = clientId;
          _lastSeen = DateTime.now();
          _setStatus('connected');
          return <String, dynamic>{'ok': true};
        }
        if (_clientId != clientId || !connected) throw _error('unavailable');
        _lastSeen = DateTime.now();
        if (request.uri.path == '/disconnect') {
          await _invalidate('unavailable');
          return <String, dynamic>{'ok': true};
        }
        if (request.uri.path == '/poll') {
          final queued = _pending.values.where(
            (pending) => !pending.dispatched,
          );
          if (queued.isEmpty) return <String, dynamic>{'job': null};
          final pending = queued.first;
          pending.dispatched = true;
          pending.record['state'] = 'dispatched';
          pending.record['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
          // This flush precedes exposure to Chrome. A lost response is uncertain.
          await _saveLedger();
          await _checkOwner();
          return <String, dynamic>{'job': pending.job};
        }
        await _acceptResult(body['result']);
        return <String, dynamic>{'ok': true};
      });
      if (!_ownerMatches) {
        await _serial(() => _checkOwner());
      }
      await _respond(request, 200, response);
    } on FirebaseFunctionsException catch (error) {
      await _respond(request, error.code == 'busy' ? 409 : 400, {
        'ok': false,
        'code': error.code,
      });
    } catch (_) {
      await _respond(request, 400, {
        'ok': false,
        'code': 'failed-precondition',
      });
    }
  }

  Future<void> _acceptResult(dynamic raw) async {
    if (raw is! Map || raw['requestId'] is! String)
      throw _error('invalid-argument');
    final pending = _pending[raw['requestId']];
    if (pending == null || !pending.dispatched)
      throw _error('failed-precondition');
    const tupleKeys = [
      'requestId',
      'epoch',
      'uid',
      'googleSub',
      'email',
      'notebookId',
    ];
    if (tupleKeys.any((key) => raw[key] != pending.job[key]))
      throw _error('account-mismatch');
    const codes = {
      'invalid-argument',
      'unavailable',
      'unauthenticated',
      'account-mismatch',
      'failed-precondition',
      'deadline-exceeded',
      'uncertain',
      'busy',
      'resource-exhausted',
    };
    final code = raw['code'];
    Map<String, dynamic>? reply;
    String? failureCode;
    if (code != null) {
      failureCode = codes.contains(code)
          ? code as String
          : 'failed-precondition';
    } else if (raw['accountEmail'] != _owner!.email ||
        raw['answer'] is! String ||
        (raw['answer'] as String).trim().isEmpty ||
        (raw['answer'] as String).length > 128000 ||
        raw['conversationId'] is! String ||
        !_uuid.hasMatch(raw['conversationId'] as String) ||
        raw['citations'] is! List ||
        (raw['citations'] as List).length > 100) {
      failureCode = raw['accountEmail'] != _owner!.email
          ? 'account-mismatch'
          : 'failed-precondition';
    } else {
      final citations = <Map<String, dynamic>>[];
      for (final item in raw['citations'] as List) {
        if (item is! Map ||
            item['sourceId'] is! String ||
            !_uuid.hasMatch(item['sourceId'] as String) ||
            item['citationNumber'] is! int ||
            (item['citationNumber'] as int) < 1 ||
            (item['citationNumber'] as int) > 1000 ||
            (item['excerpt'] != null &&
                (item['excerpt'] is! String ||
                    (item['excerpt'] as String).length > 4000))) {
          failureCode = 'failed-precondition';
          break;
        }
        citations.add({
          'sourceId': item['sourceId'],
          'citationNumber': item['citationNumber'],
          'excerpt': item['excerpt'],
        });
      }
      if (failureCode == null)
        reply = {
          for (final key in tupleKeys) key: raw[key],
          'answer': raw['answer'],
          'citations': citations,
          'conversationId': raw['conversationId'],
          'accountEmail': raw['accountEmail'],
        };
    }
    pending.record['state'] = failureCode == 'uncertain'
        ? 'uncertain'
        : failureCode == null
        ? 'completed'
        : 'failed';
    pending.record['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    await _saveLedger();
    await _checkOwner();
    _pending.remove(raw['requestId']);
    pending.timer?.cancel();
    if (failureCode != null)
      pending.completer.completeError(_error(failureCode));
    else
      pending.completer.complete(Map<String, dynamic>.unmodifiable(reply!));
  }

  Future<void> stop() => _serial(_stopInternal);

  Future<void> _stopInternal() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    try {
      await _invalidate('unauthenticated');
    } catch (_) {
      /* Still revoke below. */
    }
    final server = _server;
    _server = null;
    await server?.close(force: true);
    try {
      await _regularFile(_metadata, optional: true);
      if (_holdsLock && _epoch != null && await _metadata.exists()) {
        final raw = jsonDecode(await _metadata.readAsString());
        if (raw is Map && raw['epoch'] == _epoch) await _metadata.delete();
      }
    } catch (_) {
      /* Never remove a replaced file or another process's epoch. */
    }
    try {
      if (_holdsLock) await _lock?.unlock();
    } catch (_) {
      /* A failed start may have no lock. */
    }
    await _lock?.close();
    _lock = null;
    _holdsLock = false;
    if (_claimedDirectory != null)
      _claimedDirectories.remove(_claimedDirectory);
    _claimedDirectory = null;
    _owner = null;
    _bearer = null;
    _epoch = null;
    _setStatus('stopped');
  }

  @override
  void dispose() {
    _disposed = true;
    _heartbeat?.cancel();
    unawaited(stop());
    super.dispose();
  }
}
