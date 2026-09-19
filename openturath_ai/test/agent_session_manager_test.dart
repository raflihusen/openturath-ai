import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/agent_session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AgentSessionManager manager;
  late String? currentUid;
  late List<AgentSessionTab> disposed;
  late int browserClears;
  final agents = AgentModel.defaultAgents;

  setUp(() {
    currentUid = 'alice';
    disposed = [];
    browserClears = 0;
    manager = AgentSessionManager.testing(
      currentUid: () => currentUid,
      disposeTab: (tab) async { tab.isDisposed = true; disposed.add(tab); },
      clearBrowserData: () async { browserClears++; },
    );
  });
  tearDown(() async { await manager.closeAll(); manager.dispose(); });

  test('opens and reuses a notebook only within the same owner', () async {
    await manager.openAgent(agents[0]);
    final first = manager.activeTab;
    expect(first?.ownerUid, 'alice');
    await manager.openAgent(agents[1]);
    await manager.openAgent(agents[0]);
    expect(manager.tabs.length, 2);
    expect(identical(manager.activeTab, first), isTrue);
  });

  test('account switch destroys old notebook instead of reusing its agent ID', () async {
    await manager.openAgent(agents[0]);
    final old = manager.activeTab!;
    currentUid = 'bob';
    await manager.openAgent(agents[0]);
    expect(manager.tabs.length, 1);
    expect(manager.activeTab?.ownerUid, 'bob');
    expect(identical(manager.activeTab, old), isFalse);
    expect(old.isRetired, isTrue);
    expect(disposed, contains(old));
    expect(browserClears, 1);
  });

  test('an absent identity or stale caller model cannot open a notebook', () async {
    final stale = UserModel(uid: 'bob', name: '', email: '', photoUrl: '', plan: 'free', questionsUsed: 0);
    await manager.openAgent(agents.first, user: stale);
    expect(manager.tabs, isEmpty);
    currentUid = null;
    await manager.openAgent(agents.first);
    expect(manager.tabs, isEmpty);
  });

  test('hiding room keeps tabs; closing a tab preserves active selection', () async {
    for (final agent in agents.take(3)) { await manager.openAgent(agent); }
    manager.closeRoom();
    expect(manager.tabs.length, 3);
    expect(manager.isOpen, isFalse);
    await manager.closeTab(0);
    expect(manager.activeTab?.agent.id, agents[2].id);
    expect(manager.activeIndex, 1);
    await manager.openAgent(agents[1]);
    expect(manager.isOpen, isTrue);
  });

  test('concurrent opens remain serialized within the three-tab memory cap', () async {
    await Future.wait(agents.take(6).map(manager.openAgent));
    expect(manager.tabs.length, AgentSessionManager.maxTabs);
    expect(manager.activeTab?.agent.id, agents[5].id);
    expect(disposed.length, 3);
  });

  test('closeAll invalidates a queued open before it can create a native view', () async {
    final pending = manager.openAgent(agents.first);
    await manager.closeAll();
    await pending;
    expect(manager.tabs, isEmpty);
  });

  test('closeAll retires UI immediately and waits for resource cleanup', () async {
    await manager.closeAll();
    manager.dispose();
    final cleanup = Completer<void>();
    manager = AgentSessionManager.testing(
      currentUid: () => currentUid,
      disposeTab: (_) => cleanup.future,
      clearBrowserData: () async { browserClears++; },
    );
    await manager.openAgent(agents.first);
    final old = manager.activeTab!;
    var finished = false;
    final closing = manager.closeAll(clearBrowserData: true).then((_) => finished = true);
    expect(manager.tabs, isEmpty);
    expect(old.isRetired, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(finished, isFalse);
    cleanup.complete();
    await closing;
    expect(finished, isTrue);
    expect(browserClears, 1);
  });
}
