import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/membership_pass_state.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/agent_service.dart';

void main() {
  group('Guru Edition Integration Test', () {
    test('AppConfig.isGuruEdition reflects compile-time define', () {
      const isGuru = AppConfig.isGuruEdition;
      if (isGuru) {
        // All agents must be active
        final activeAgents = AgentService.getActiveAgentsSync();
        expect(activeAgents.every((a) => a.isActive), isTrue);
        expect(activeAgents.any((a) => a.isComingSoon), isFalse);

        // Membership pass summary must be GURU permanent
        final pass = resolveMembershipPass(null);
        expect(pass.badge, 'GURU');
        expect(pass.isOpen, isTrue);
        expect(pass.state, MembershipPassState.permanent);

        // User model access must be true for any agent
        final dummyUser = UserModel(
          uid: 'dummy_guru',
          name: 'Guru',
          email: 'guru@turath.id',
          photoUrl: '',
          plan: 'none',
          questionsUsed: 0,
        );
        expect(dummyUser.hasAccessToAgent('fiqh_hanbali'), isTrue);
        expect(dummyUser.hasAccessToAgent('tafsir'), isTrue);
        expect(dummyUser.isSubscriptionActive, isTrue);
      } else {
        // Standard edition preserves normal behavior
        final activeAgents = AgentService.getActiveAgentsSync();
        final tahawwulat = activeAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
        expect(tahawwulat.isActive, isTrue);
      }
    });
  });
}
