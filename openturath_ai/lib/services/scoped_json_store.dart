import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StringStore {
  Future<String?> read(String key);
  Future<bool> write(String key, String value);
}

class PreferencesStringStore implements StringStore {
  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(key);
    if (value is String) return value;
    if (value is List) {
      // Backward compatibility for legacy SharedPreferences stored as List<String>
      final items = <dynamic>[];
      for (final item in value) {
        if (item is String) {
          try {
            items.add(jsonDecode(item));
          } catch (_) {
            items.add(item);
          }
        } else {
          items.add(item);
        }
      }
      return jsonEncode(items);
    }
    return null;
  }

  @override
  Future<bool> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key) && prefs.get(key) is! String) {
      await prefs.remove(key);
    }
    return prefs.setString(key, value);
  }
}

class ScopedJsonListStore<T> {
  final StringStore storage;
  final T Function(Map<String, dynamic>) decode;
  final Map<String, dynamic> Function(T) encode;
  static final Map<String, Future<void>> _tails = {};

  ScopedJsonListStore(
      {required this.storage, required this.decode, required this.encode});

  Future<R> _locked<R>(String key, Future<R> Function() action) async {
    final previous = _tails[key];
    final done = Completer<void>();
    _tails[key] = done.future;
    try {
      if (previous != null) await previous;
      return await action();
    } finally {
      done.complete();
      if (identical(_tails[key], done.future)) _tails.remove(key);
    }
  }

  Future<List<T>> _read(String key) async {
    final raw = await storage.read(key);
    if (raw == null || raw.isEmpty) return <T>[];
    try {
      final data = jsonDecode(raw);
      if (data is! List) throw const FormatException('Expected a list');
      return data.map((row) {
        if (row is! Map) throw const FormatException('Expected an object');
        return decode(Map<String, dynamic>.from(row));
      }).toList();
    } on Object {
      final digest = sha256.convert(utf8.encode(raw));
      final quarantine = '${key}_corrupt_$digest';
      if (await storage.read(quarantine) != raw &&
          !await storage.write(quarantine, raw)) {
        throw StateError('Cannot preserve damaged saved data');
      }
      return <T>[];
    }
  }

  Future<List<T>> read(String key) => _locked(key, () => _read(key));

  Future<void> replace(String key, List<T> items) {
    final snapshot = List<T>.of(items);
    return _locked(key, () async {
      await _read(key); // Preserve corrupt old bytes before replacing them.
      await _write(key, snapshot);
    });
  }

  Future<void> update(String key, List<T> Function(List<T>) edit) =>
      _locked(key, () async {
        final current = await _read(key);
        await _write(key, edit(current));
      });

  Future<void> _write(String key, List<T> items) async {
    final raw = jsonEncode(items.map(encode).toList());
    if (!await storage.write(key, raw))
      throw StateError('Saved data could not be written');
  }
}
