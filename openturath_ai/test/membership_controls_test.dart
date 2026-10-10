import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_copy.dart';
import 'package:openturath_ai/core/membership_pass_state.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/widgets/membership_controls.dart';

void main() {
  for (final vip in [false, true]) {
    testWidgets(
        'visible subscription action and ${vip ? 'VIP' : 'PRO'} fit narrow large text',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var opened = false;
      final member = UserModel(
          uid: 'u',
          name: 'User',
          email: 'u@example.com',
          photoUrl: '',
          plan: 'premium',
          questionsUsed: 0,
          isVip: vip,
          subscriptionExpiry: DateTime(2030));
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: MembershipControls(
                summary: resolveMembershipPass(member),
                onSubscribe: () => opened = true)),
      ))));
      expect(find.text(vip ? 'VIP' : 'PRO'), findsOneWidget);
      expect(find.text(AppCopy.subscription), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester
          .tap(find.byKey(const ValueKey('visible-subscription-button')));
      expect(opened, isTrue);
    });
  }
  testWidgets('free users see subscription action without a PRO claim',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: MembershipControls(
                summary: resolveMembershipPass(null), onSubscribe: () {}))));
    expect(find.text(AppCopy.subscription), findsOneWidget);
    expect(find.text('PRO'), findsNothing);
    expect(find.text('VIP'), findsNothing);
  });
}
