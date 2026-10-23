import 'package:flutter/material.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/turath_chat_message.dart';
import 'package:openturath_ai/services/agent_session_manager.dart';
import 'package:openturath_ai/widgets/native_turath_chat_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final agentSyafii =
      AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_syafii');

  group('TurathChatMessage Model Suite', () {
    test('TurathChatMessage properties and copyWith', () {
      final now = DateTime.now();
      final msg = TurathChatMessage(
        id: 'msg_1',
        text: 'Bagaimana hukum shalat jamak qashar?',
        isUser: true,
        timestamp: now,
      );

      expect(msg.id, 'msg_1');
      expect(msg.text, 'Bagaimana hukum shalat jamak qashar?');
      expect(msg.isUser, isTrue);
      expect(msg.isThinking, isFalse);
      expect(msg.timestamp, now);

      final updated = msg.copyWith(
        text: 'Penjelasan baru',
        isThinking: true,
      );

      expect(updated.id, 'msg_1');
      expect(updated.text, 'Penjelasan baru');
      expect(updated.isUser, isTrue);
      expect(updated.isThinking, isTrue);
    });

    test('AgentSessionTab initializes with Jalur B native defaults', () {
      final tab = AgentSessionTab(
        agent: agentSyafii,
      );

      expect(tab.isNativeView, isFalse);
      expect(tab.chatMessages.isEmpty, isTrue);
      expect(tab.isGenerating, isFalse);
    });
  });

  group('NativeTurathChatView Widget Suite', () {
    testWidgets('Renders empty scholarly state when no messages',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: NativeTurathChatView(
              agent: agentSyafii,
              messages: const [],
              isGenerating: false,
              onSend: (_) {},
            ),
          ),
        ),
      );

      expect(find.text(agentSyafii.title), findsOneWidget);
      expect(find.textContaining(Loc.tr('chatPurpose')), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Renders user and assistant messages with scholarly layout',
        (tester) async {
      final messages = [
        TurathChatMessage(
          id: 'u1',
          text: 'Apa syarat sah shalat Jumat?',
          isUser: true,
          timestamp: DateTime.now(),
        ),
        TurathChatMessage(
          id: 'a1',
          text:
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nSyarat sah shalat Jumat menurut madzhab Syafi\'i adalah terlaksana dalam batas waktu Dzuhur dan dihadiri minimal 40 orang jamaah mustauthin.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: NativeTurathChatView(
              agent: agentSyafii,
              messages: messages,
              isGenerating: false,
              onSend: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Apa syarat sah shalat Jumat?'), findsOneWidget);
      expect(find.textContaining('Syarat sah shalat Jumat'), findsOneWidget);
      // Action buttons (Copy and Bookmark)
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    });

    testWidgets('Displays universal breathing text indicator during generation',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: NativeTurathChatView(
              agent: agentSyafii,
              messages: [
                TurathChatMessage(
                  id: 'u1',
                  text: 'Jelaskan rukun wudhu',
                  isUser: true,
                  timestamp: DateTime.now(),
                ),
              ],
              isGenerating: true,
              onSend: (_) {},
            ),
          ),
        ),
      );

      expect(find.text(Loc.tr('preparingAnswer')), findsOneWidget);
      // Ensure NO tacky spinners or circular progress indicators are rendered
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Triggers onSend callback when user submits a question',
        (tester) async {
      String? sentPrompt;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: NativeTurathChatView(
              agent: agentSyafii,
              messages: const [],
              isGenerating: false,
              onSend: (val) => sentPrompt = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField),
          'Bagaimana kaidah fiqih al-yaqinu la yuzalu bisy-syakk?');
      await tester.pump();

      final sendBtn = find.byTooltip(Loc.tr('sendQuestion'));
      expect(sendBtn, findsOneWidget);

      await tester.tap(sendBtn);
      await tester.pump();

      expect(
          sentPrompt, 'Bagaimana kaidah fiqih al-yaqinu la yuzalu bisy-syakk?');
    });
  });
}
