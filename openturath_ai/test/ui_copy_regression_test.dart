import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/subscription_service.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/core/app_copy.dart';

void main() {
  test('Voucher errors remain natural even for uppercase transport codes', () {
    expect(SubscriptionService.redeemErrorMessage('NOT_FOUND'),
        contains('tidak ditemukan'));
    expect(SubscriptionService.redeemErrorMessage('INTERNAL'),
        isNot(contains('INTERNAL')));
    expect(SubscriptionService.redeemErrorMessage('already-exists'),
        contains('sudah pernah'));
    expect(SubscriptionService.redeemErrorMessage('unauthenticated'),
        contains('Masuk'));
  });
  test(
      'All science AI titles have the requested prefix without changing entitlement IDs',
      () {
    for (final agent in AgentModel.defaultAgents) {
      expect(agent.title.isNotEmpty, isTrue);
      expect(agent.title, startsWith('AI '));
      expect(agent.id, isNot(startsWith('AI ')));
    }
  });
  test('Conversation loading and menu describe their actions', () {
    expect(AppCopy.loadingReferences, 'Menyiapkan AI…');
    expect(AppCopy.studyOptions, 'Tampilan bacaan');
  });
}
