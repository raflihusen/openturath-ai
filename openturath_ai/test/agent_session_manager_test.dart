import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/services/agent_session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final agentSyafii = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_syafii');
  final agentHanafi = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_hanafi');
  final agentMaliki = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_maliki');

  setUp(() {
    AgentSessionManager.instance.closeAll();
  });

  tearDown(() {
    AgentSessionManager.instance.closeAll();
  });

  group('AgentSessionManager Multi-Tab Keep-Alive Suite', () {
    test('Starts empty and closed', () {
      final manager = AgentSessionManager.instance;
      expect(manager.tabs.isEmpty, isTrue);
      expect(manager.isOpen, isFalse);
      expect(manager.activeTab, isNull);
    });

    test('Opening an agent adds a tab and opens the room', () {
      final manager = AgentSessionManager.instance;
      manager.openAgent(agentSyafii);

      expect(manager.tabs.length, 1);
      expect(manager.isOpen, isTrue);
      expect(manager.activeIndex, 0);
      expect(manager.activeTab?.agent.id, 'fiqh_syafii');
    });

    test('Opening same agent twice switches to existing tab without reload or duplication', () {
      final manager = AgentSessionManager.instance;
      manager.openAgent(agentSyafii);
      manager.openAgent(agentHanafi);

      expect(manager.tabs.length, 2);
      expect(manager.activeIndex, 1);
      expect(manager.activeTab?.agent.id, 'fiqh_hanafi');

      // Open syafii again
      manager.openAgent(agentSyafii);

      // Should switch back to tab 0 without adding a 3rd tab
      expect(manager.tabs.length, 2);
      expect(manager.activeIndex, 0);
      expect(manager.activeTab?.agent.id, 'fiqh_syafii');
    });

    test('closeRoom() hides the room while preserving active tabs in background', () {
      final manager = AgentSessionManager.instance;
      manager.openAgent(agentSyafii);
      manager.openAgent(agentMaliki);

      expect(manager.isOpen, isTrue);
      expect(manager.tabs.length, 2);

      // User presses back to return to dashboard
      manager.closeRoom();

      // Room is hidden, but tabs and WebViews remain completely alive in memory
      expect(manager.isOpen, isFalse);
      expect(manager.tabs.length, 2);
      expect(manager.tabs[0].agent.id, 'fiqh_syafii');
      expect(manager.tabs[1].agent.id, 'fiqh_maliki');

      // User clicks Maliki again from dashboard: opens instantly with zero loading
      manager.openAgent(agentMaliki);
      expect(manager.isOpen, isTrue);
      expect(manager.activeIndex, 1);
    });

    test('Closing a tab via closeTab() adjusts activeIndex correctly', () {
      final manager = AgentSessionManager.instance;
      manager.openAgent(agentSyafii);
      manager.openAgent(agentHanafi);
      manager.openAgent(agentMaliki);

      expect(manager.tabs.length, 3);
      expect(manager.activeIndex, 2); // on Maliki

      // Close Hanafi (index 1)
      manager.closeTab(1);

      expect(manager.tabs.length, 2);
      expect(manager.tabs[0].agent.id, 'fiqh_syafii');
      expect(manager.tabs[1].agent.id, 'fiqh_maliki');
      expect(manager.activeIndex, 1);

      // Close remaining tabs
      manager.closeTab(1);
      expect(manager.tabs.length, 1);
      expect(manager.activeIndex, 0);

      manager.closeTab(0);
      expect(manager.tabs.isEmpty, isTrue);
      expect(manager.isOpen, isFalse);
    });

    test('closeAll() completely clears sessions and resets state on sign out', () {
      final manager = AgentSessionManager.instance;
      manager.openAgent(agentSyafii);
      manager.openAgent(agentHanafi);

      manager.closeAll();

      expect(manager.tabs.isEmpty, isTrue);
      expect(manager.isOpen, isFalse);
      expect(manager.activeIndex, 0);
    });
  });
}
