import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/scoped_json_store.dart';

class MemoryStrings implements StringStore {
  final values = <String, String>{};
  bool fail = false;
  Completer<void>? gate;
  int writes = 0;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<bool> write(String key, String value) async {
    writes++;
    await gate?.future;
    if (fail) return false;
    values[key] = value;
    return true;
  }
}

void main() {
  ScopedJsonListStore<String> store(MemoryStrings io) => ScopedJsonListStore(
        storage: io,
        decode: (map) => map['value'] as String,
        encode: (value) => {'value': value},
      );
  test('A07 values never cross account keys or caller mutation', () async {
    final io = MemoryStrings();
    final data = store(io);
    await data.replace('user-a', ['private']);
    expect(await data.read('user-b'), isEmpty);
    final a = await data.read('user-a');
    a.clear();
    expect(await data.read('user-a'), ['private']);
  });
  test('A08 parallel updates through separate instances preserve both records',
      () async {
    final io = MemoryStrings();
    final a = store(io);
    final b = store(io);
    await Future.wait([
      a.update('notes', (rows) => rows..add('A')),
      b.update('notes', (rows) => rows..add('B')),
    ]);
    expect(await a.read('notes'), ['A', 'B']);
  });
  testWidgets('A08 slow write does not release exclusion after five seconds',
      (tester) async {
    final io = MemoryStrings()..gate = Completer<void>();
    final data = store(io);
    final first = data.replace('slow', ['A']);
    final next = data.update('slow', (rows) => rows..add('B'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(io.writes, 1);
    io.gate!.complete();
    await tester.pump();
    await Future.wait([first, next]);
    expect(await data.read('slow'), ['A', 'B']);
  });
  test('A08 failed write surfaces error and releases queue', () async {
    final io = MemoryStrings()..fail = true;
    final data = store(io);
    await expectLater(data.replace('k', ['lost']), throwsStateError);
    io.fail = false;
    await data.replace('k', ['saved']);
    expect(await data.read('k'), ['saved']);
  });
  test('A07 corrupted payload is preserved before any replacement', () async {
    final io = MemoryStrings()..values['a'] = '[broken';
    final data = store(io);
    await data.update('a', (rows) => rows..add('new'));
    expect(
        io.values.entries
            .where((e) => e.key.startsWith('a_corrupt_'))
            .single
            .value,
        '[broken');
    expect(await data.read('b'), isEmpty);
  });
  test('A07 failed quarantine prevents overwriting corrupt original', () async {
    final io = MemoryStrings()
      ..values['a'] = '[broken'
      ..fail = true;
    await expectLater(store(io).replace('a', ['new']), throwsStateError);
    expect(io.values['a'], '[broken');
  });
}
