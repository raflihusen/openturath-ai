import '../core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../core/notebook_navigation.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../widgets/editorial.dart';
import 'main_shell_screen.dart';

/// Compatibility entry point. All notebook rendering is owned by the main shell.
class AgentWebviewScreen extends StatefulWidget {
  final AgentModel? agent;
  const AgentWebviewScreen({super.key, this.agent});

  static bool isAllowedNotebookUrl(Uri uri) => NotebookNavigation.allowed(uri);

  @override
  State<AgentWebviewScreen> createState() => _AgentWebviewScreenState();
}

class _AgentWebviewScreenState extends State<AgentWebviewScreen> {
  bool _started = false;
  String? _error;
  bool _needsMembership = false;
  AgentModel? _agent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    _agent = widget.agent ?? (args is AgentModel ? args : args is Map ? args['agent'] as AgentModel? : null);
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _open(); });
  }

  Future<void> _open() async {
    setState(() { _error = null; _needsMembership = false; });
    final agent = _agent;
    if (agent == null) {
      setState(() => _error = 'Pilih asisten dari daftar untuk memulai telaah.');
      return;
    }
    try {
      final auth = AuthService();
      final owner = auth.currentUser?.uid;
      if (owner == null) {
        setState(() => _error = 'Masuk ke akun untuk menghubungkan ruang telaah.');
        return;
      }
      final user = await auth.getFreshCurrentUserModel();
      if (!mounted || auth.currentUser?.uid != owner) return;
      if (user == null || !user.hasAccessToAgent(agent.id)) {
        setState(() { _needsMembership = true; _error = 'Akses untuk asisten ini belum aktif.'; });
        return;
      }
      await AgentSessionManager.instance.openAgent(agent, user: user);
      if (!mounted || auth.currentUser?.uid != owner) return;
      final shell = MainShellController.of(context);
      final navigator = Navigator.of(context);
      if (shell != null) shell.switchTab(1);
      if (navigator.canPop()) {
        // Reuse the existing shell; never mount a second kept-alive WebView tree.
        navigator.popUntil((route) => route.settings.name == AppRoutes.dashboard || route.isFirst);
      } else {
        navigator.pushReplacementNamed(AppRoutes.dashboard);
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Akses belum dapat diperiksa. Periksa jaringan lalu coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) => EditorialPage(
    title: _agent == null ? context.tr('Ruang telaah') : context.agentTitle(_agent!), showBack: true, maxWidth: 720,
    children: [
      if (_error == null)
        const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
      else
        EditorialEmptyState(
          title: context.tr('Ruang telaah belum terbuka'), description: context.tr(_error!),
          action: EditorialButton(label: _needsMembership ? context.tr('Lihat keanggotaan') : context.tr('Coba lagi'),
            onPressed: () async {
              if (_needsMembership) {
                await Navigator.of(context).pushNamed(AppRoutes.subscription,
                  arguments: {'agent': _agent, 'user': AuthService().cachedCurrentUser});
                if (!mounted) return;
              }
              await _open();
            }),
        ),
    ],
  );
}
