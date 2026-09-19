import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/l10n/app_dictionary.dart';
import '../core/routes.dart';
import '../services/auth_service.dart';
import '../widgets/editorial.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await FirebaseAuth.instance.authStateChanges().first
        .timeout(const Duration(seconds: 12));
      String route = AppRoutes.login;
      if (user != null) {
        final isDesktop = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
        final ready = user.isAnonymous || isDesktop ||
          await AuthService().isGoogleSessionReady().timeout(const Duration(seconds: 5));
        route = ready ? AppRoutes.dashboard : AppRoutes.googleSessionAuth;
      }
      if (!mounted) return;
      // Authentication may change while local session state is being read.
      if (FirebaseAuth.instance.currentUser?.uid != user?.uid) {
        await _bootstrap();
        return;
      }
      Navigator.pushReplacementNamed(context, route);
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'shell.bootstrap_error'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360),
        child: EditorialReveal(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.menu_book_outlined, size: 38),
          const SizedBox(height: 24),
          Text('OpenTurath', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 28),
          if (_loading) ...[
            if (!reduceMotion) const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 1.5)),
            const SizedBox(height: 16),
            Semantics(liveRegion: true, child: Text(context.tr('shell.preparing_study'),
              style: Theme.of(context).textTheme.bodySmall)),
          ],
          if (_error != null) ...[
            Semantics(liveRegion: true, child: Text(context.tr(_error!), textAlign: TextAlign.center)),
            const SizedBox(height: 20),
            EditorialButton(label: context.tr('shell.retry'), onPressed: _bootstrap),
          ],
        ])),
      ),
    ))));
  }
}
