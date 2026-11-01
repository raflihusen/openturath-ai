import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/widgets/vip_exclusive_dialog.dart';

UserModel _user({bool vip = false}) => UserModel(
    uid: 'u',
    name: 'N',
    email: 'n@example.com',
    photoUrl: '',
    plan: vip ? 'vip' : 'none',
    questionsUsed: 0,
    isVip: vip);

void main() {
  test('akun VIP eksklusif, akun biasa dan tanpa akun tidak', () {
    expect(isExclusiveAccount(_user(vip: true)), isTrue);
    expect(isExclusiveAccount(_user()), AppConfig.isGuruEdition);
    expect(isExclusiveAccount(null), AppConfig.isGuruEdition);
  });

  for (final code in ['id', 'en', 'ar']) {
    testWidgets('pesan eksklusif tampil dan bisa ditutup ($code)',
        (tester) async {
      AppConfig.localeNotifier.value = code;
      await tester.pumpWidget(MaterialApp(
          home: Builder(
              builder: (c) => TextButton(
                  onPressed: () => VipExclusiveDialog.show(c),
                  child: const Text('buka')))));
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
      expect(find.text(Loc.tr('vipExclusiveTitle')), findsOneWidget);
      expect(find.text(Loc.tr('vipExclusiveBody')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('vip-exclusive-ok')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('vip-exclusive-dialog')), findsNothing);
      AppConfig.localeNotifier.value = 'id';
    });
  }
}
