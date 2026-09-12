import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/session_user_stream.dart';

Future<void> tick() => Future<void>.delayed(Duration.zero);
void main() {
  test('A09 delayed old cache cannot emit or subscribe after logout', () async {
    final auth = StreamController<String?>.broadcast(sync: true);
    final oldCache = Completer<String?>();
    final watched = <String>[];
    final stream = sessionUserStream<String>(
      auth: auth.stream,
      cached: (uid) => oldCache.future,
      watch: (uid) { watched.add(uid); return const Stream<String?>.empty(); },
    );
    final values = <String?>[];
    final sub = stream.listen(values.add);
    auth.add('A');
    await tick();
    auth.add(null);
    await tick();
    oldCache.complete('A cached');
    await tick();
    expect(values.last, isNull);
    expect(values, isNot(contains('A cached')));
    expect(watched, isEmpty);
    await sub.cancel();
    await auth.close();
  });
  test('A09 final cancellation invalidates pending cache and later listeners restart', () async {
    final auth = StreamController<String?>.broadcast(sync: true);
    final cache = Completer<String?>();
    var watches = 0;
    final stream = sessionUserStream<String>(auth: auth.stream, cached: (_) => cache.future,
      watch: (_) { watches++; return const Stream<String?>.empty(); });
    final sub = stream.listen((_) {});
    auth.add('A');
    await tick();
    await sub.cancel();
    cache.complete('A');
    await tick();
    expect(watches, 0);
    final values = <String?>[];
    final next = stream.listen(values.add);
    auth.add(null);
    await tick();
    expect(values.last, isNull);
    await next.cancel();
    await auth.close();
  });
}
