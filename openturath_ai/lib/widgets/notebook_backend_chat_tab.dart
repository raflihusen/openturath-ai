import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/agent_session_manager.dart';
import '../services/notebook_chat_controller.dart';
import 'native_turath_chat_view.dart';

/// Prototype chat surface: no NotebookLM WebView, browser launch or Google login.
class NotebookBackendChatTab extends StatefulWidget {
  const NotebookBackendChatTab({super.key, required this.session});
  final AgentSessionTab session;

  @override
  State<NotebookBackendChatTab> createState() => _NotebookBackendChatTabState();
}

class _NotebookBackendChatTabState extends State<NotebookBackendChatTab> {
  late final NotebookChatController _chat;
  StreamSubscription<User?>? _auth;

  @override
  void initState() {
    super.initState();
    _chat = NotebookChatController(agentId: widget.session.agent.id,
      currentUid: () => FirebaseAuth.instance.currentUser?.uid);
    _chat.synchronizeOwner();
    _chat.addListener(_changed);
    _auth = FirebaseAuth.instance.authStateChanges().listen((_) => _chat.synchronizeOwner());
  }

  void _changed() {
    if (!mounted) return;
    widget.session.chatMessages
      ..clear()
      ..addAll(_chat.messages);
    widget.session.isGenerating = _chat.isGenerating;
    setState(() {});
  }

  @override
  void dispose() {
    _auth?.cancel();
    _chat.removeListener(_changed);
    _chat.dispose();
    widget.session.chatMessages.clear();
    widget.session.isGenerating = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (_chat.error != null)
      Padding(padding: const EdgeInsets.all(16), child: Text(
        _chat.error!, key: const ValueKey('native-chat-error'),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      )),
    Expanded(child: NativeTurathChatView(
      agent: widget.session.agent,
      messages: _chat.messages,
      isGenerating: _chat.isGenerating,
      onSend: _chat.send,
    )),
  ]);
}
