import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/agent_session_manager.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:openturath_ai/widgets/agent_multi_tab_room.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _HistoryController extends PlatformInAppWebViewController {
  _HistoryController()
      : super.implementation(
            const PlatformInAppWebViewControllerCreationParams(id: 'history'));
  final completion = Completer<CallAsyncJavaScriptResult?>();
  int deletes = 0;
  @override
  Future<dynamic> evaluateJavascript(
          {required String source, ContentWorld? contentWorld}) async =>
      null;
  @override
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({
    required String functionBody,
    Map<String, dynamic> arguments = const {},
    ContentWorld? contentWorld,
  }) {
    expect(functionBody, contains('await window.otClearChat()'));
    deletes++;
    return completion.future;
  }

  @override
  Future<void> loadUrl({
    required URLRequest urlRequest,
    Uri? iosAllowingReadAccessTo,
    WebUri? allowingReadAccessTo,
  }) async {}
  @override
  Future<void> stopLoading() async {}
}

void main() {
  setUp(() {
    AppConfig.localeNotifier.value = 'id';
    SharedPreferences.setMockInitialValues({});
    AuthService.previewUser = UserModel(
      uid: 'room-history-fixture',
      name: 'Reader',
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
  for (final result in [true, false, null, 'error']) {
    testWidgets('history result $result controls the actual completion message',
        (tester) async {
      final manager = AgentSessionManager.instance;
      manager.openAgent(AgentModel.defaultAgents.first);
      final session = manager.activeTab!;
      final controller = _HistoryController();
      session.webController =
          InAppWebViewController.fromPlatform(platform: controller);
      session.resolvedUrl = 'https://notebooklm.google.com/notebook/fixture';
      session.isUrlLoading = false;
      session.isWebLoading = false;
      session.errorMessage = 'fixture keeps platform view closed';
      session.isGoogleAuthPage = true;
      await tester.pumpWidget(const MaterialApp(home: AgentMultiTabRoom()));
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Loc.tr('clearChatHistory')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Loc.tr('delete')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.deletes, 1);
      expect(find.text(Loc.tr('chatHistoryCleared')), findsNothing);
      expect(find.text(Loc.tr('chatHistoryClearFailed')), findsNothing);
      if (result == 'error') {
        controller.completion.completeError(StateError('provider unavailable'));
      } else {
        controller.completion
            .complete(CallAsyncJavaScriptResult(value: result));
      }
      await tester.pumpAndSettle();
      expect(
          find.text(Loc.tr(result == true
              ? 'chatHistoryCleared'
              : 'chatHistoryClearFailed')),
          findsOneWidget);
      expect(
          find.text(Loc.tr(result == true
              ? 'chatHistoryClearFailed'
              : 'chatHistoryCleared')),
          findsNothing);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
}
