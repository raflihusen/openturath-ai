import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/agent_session_manager.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:openturath_ai/widgets/agent_multi_tab_room.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    AppConfig.localeNotifier.value = 'id';
    SharedPreferences.setMockInitialValues({});
    AuthService.previewUser = UserModel(
      uid: 'room-result-fixture',
      name: 'Room Reader',
      email: 'reader@example.invalid',
      photoUrl: '',
      plan: 'trial',
      questionsUsed: 0,
    );
    AgentSessionManager.instance.closeAll();
  });
  tearDown(() {
    AuthService.previewUser = null;
    AgentSessionManager.instance.closeAll();
  });
  for (final permission in [false, true]) {
    for (final result in [false, null]) {
      testWidgets('Google connection $result preserves ${permission ? 'permission' : 'login'} recovery', (tester) async {
        final manager = AgentSessionManager.instance;
        manager.openAgent(AgentModel.defaultAgents.first);
        final session = manager.activeTab!;
        session.resolvedUrl = 'https://notebooklm.google.com/notebook/fixture';
        session.isUrlLoading = false;
        session.isWebLoading = false;
        session.isSessionReady = false;
        session.errorMessage = 'fixture requires connection';
        session.isGoogleAuthPage = !permission;
        session.isGooglePermissionError = permission;
        await tester.pumpWidget(MaterialApp(
          home: const AgentMultiTabRoom(),
          routes: {
            AppRoutes.googleSessionAuth: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.pop(context, result),
                child: const Text('Postpone connection'),
              ),
            ),
          },
        ));
        final retry = permission ? Loc.tr('ui_f9d6eb247c') : Loc.tr('roomLoginNow');
        await tester.tap(find.text(retry));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Postpone connection'));
        await tester.pumpAndSettle();
        expect(session.errorMessage, 'fixture requires connection');
        expect(session.isGoogleAuthPage, !permission);
        expect(session.isGooglePermissionError, permission);
        expect(session.isWebLoading, isFalse);
        expect(session.isSessionReady, isFalse);
        expect(find.text(retry), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
