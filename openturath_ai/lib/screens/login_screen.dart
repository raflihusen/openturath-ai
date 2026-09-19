import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/l10n/app_dictionary.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/routes.dart';
import '../services/auth_service.dart';
import '../widgets/editorial.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _guestLoading = false;
  String? _error;

  Future<void> _openLegalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      var opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!opened && mounted) AppSnackBar.error(context, context.tr('shell.link_error'));
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.tr('shell.link_error'));
    }
  }

  Future<void> _signIn({bool guest = false}) async {
    if (_isLoading) return;
    setState(() { _isLoading = true; _guestLoading = guest; _error = null; });
    try {
      final user = guest ? await _authService.signInAnonymously() : await _authService.signInWithGoogle();
      if (!mounted || user == null) return;
      final route = guest || (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS)
        ? AppRoutes.dashboard : AppRoutes.googleSessionAuth;
      Navigator.pushReplacementNamed(context, route);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().contains('network') || error.toString().contains('SocketException')
        ? AppCopy.networkError : guest ? 'shell.guest_signin_error' : AppCopy.googleSignInFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420),
        child: EditorialReveal(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.menu_book_outlined, size: 36),
          const SizedBox(height: 28),
          Text('OpenTurath', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 20),
          Text(context.tr('shell.login_title'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(context.tr('shell.login_description'),
            style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 40),
          EditorialButton(label: context.tr(AppCopy.continueWithGoogle), expanded: true,
            icon: Icons.login_rounded, busy: _isLoading && !_guestLoading,
            onPressed: _isLoading ? null : () => _signIn()),
          const SizedBox(height: 12),
          EditorialButton(label: context.tr('shell.explore_guest'), expanded: true, secondary: true,
            busy: _isLoading && _guestLoading, onPressed: _isLoading ? null : () => _signIn(guest: true)),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 20),
            child: Semantics(liveRegion: true, child: Text(context.tr(_error!)))),
          const SizedBox(height: 32),
          Text(context.tr('shell.legal_consent'),
            style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            TextButton(onPressed: () => _openLegalUrl('https://openturath.ai/terms'),
              child: Text(context.tr('shell.terms'))),
            TextButton(onPressed: () => _openLegalUrl('https://openturath.ai/privacy'),
              child: Text(context.tr('shell.privacy'))),
          ]),
        ])),
      ),
    ))),
  );
}
