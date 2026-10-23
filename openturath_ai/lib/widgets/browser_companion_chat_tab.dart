import '../core/localization.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/agent_session_manager.dart';
import '../services/browser_companion_chat_service.dart';
import '../services/notebook_chat_controller.dart';
import 'notebook_backend_chat_tab.dart';

class BrowserCompanionChatTab extends StatefulWidget {
  const BrowserCompanionChatTab({super.key, required this.session});
  final AgentSessionTab session;
  @override
  State<BrowserCompanionChatTab> createState() =>
      _BrowserCompanionChatTabState();
}

class _BrowserCompanionChatTabState extends State<BrowserCompanionChatTab> {
  late final NotebookChatController _chat;
  String? _error;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _chat = NotebookChatController(
        agentId: widget.session.agent.id,
        currentUid: () => FirebaseAuth.instance.currentUser?.uid,
        service: BrowserCompanionChatService());
    BrowserCompanionChatService.runtime.addListener(_changed);
    unawaited(_start());
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _start() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      await BrowserCompanionChatService.start();
    } catch (_) {
      _error =
          'Fitur ini memerlukan akun Google, aplikasi desktop, dan Google Chrome.';
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  void dispose() {
    BrowserCompanionChatService.runtime.removeListener(_changed);
    // The child owns and disposes its supplied chat controller.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        ListTile(
            dense: true,
            leading: Icon(
                BrowserCompanionChatService.runtime.connected
                    ? Icons.check_circle_outline
                    : Icons.link_outlined,
                size: 20),
            title: Text(_error ??
                (BrowserCompanionChatService.runtime.connected
                    ? 'Penghubung Chrome tersambung'
                    : 'Menunggu penghubung Google Chrome')),
            subtitle: BrowserCompanionChatService.runtime.connected
                ? Text(Loc.tr('companionSameAccountHint'))
                : null,
            trailing: BrowserCompanionChatService.runtime.connected
                ? null
                : TextButton(
                    onPressed: _starting ? null : _start,
                    child: Text(_starting ? 'Menghubungkan…' : 'Coba lagi'))),
        Expanded(
            child: NotebookBackendChatTab(
                session: widget.session, controller: _chat)),
      ]);
}
