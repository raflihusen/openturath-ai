import 'dart:async';

Stream<T?> sessionUserStream<T>({
  required Stream<String?> auth,
  required Future<T?> Function(String) cached,
  required Stream<T?> Function(String) watch,
}) {
  final listeners = <MultiStreamController<T?>>{};
  StreamSubscription<String?>? authSub;
  StreamSubscription<T?>? documentSub;
  var generation = 0;
  var hasValue = false;
  T? last;

  bool current(int token) => token == generation && listeners.isNotEmpty;
  void emit(int token, T? value) {
    if (!current(token)) return;
    hasValue = true;
    last = value;
    for (final listener in listeners.toList()) { listener.add(value); }
  }
  void error(int token, Object value, StackTrace stack) {
    if (!current(token)) return;
    for (final listener in listeners.toList()) { listener.addError(value, stack); }
  }
  Future<void> cancel(StreamSubscription<dynamic>? sub) async {
    try { await sub?.cancel(); } catch (_) { /* Generation already invalidates events. */ }
  }
  Future<void> switchUser(String? uid) async {
    final token = ++generation;
    final previous = documentSub;
    documentSub = null;
    emit(token, null); // Clear prior identity before asynchronous cache lookup.
    await cancel(previous);
    if (!current(token) || uid == null) return;
    try {
      final value = await cached(uid).timeout(const Duration(seconds: 5));
      if (!current(token)) return;
      if (value != null) emit(token, value);
    } catch (_) { /* Continue with the authoritative snapshot stream. */ }
    if (!current(token)) return;
    try {
      documentSub = watch(uid).listen(
        (value) => emit(token, value),
        onError: (Object e, StackTrace stack) => error(token, e, stack),
      );
    } catch (e, stack) { error(token, e, stack); }
  }

  return Stream<T?>.multi((listener) {
    listeners.add(listener);
    if (hasValue) listener.add(last);
    if (listeners.length == 1) {
      authSub = auth.listen((uid) { unawaited(switchUser(uid)); },
        onError: (Object e, StackTrace stack) => error(generation, e, stack));
    }
    listener.onCancel = () async {
      listeners.remove(listener);
      if (listeners.isNotEmpty) return;
      generation++;
      hasValue = false;
      last = null;
      final oldAuth = authSub;
      final oldDocument = documentSub;
      authSub = null;
      documentSub = null;
      await Future.wait([cancel(oldAuth), cancel(oldDocument)]);
    };
  }, isBroadcast: true);
}
