import 'package:flutter/material.dart';
import 'browser_workspace_screen.dart';

/// Compatibility route: Google authentication belongs to the shared browser,
/// never an embedded WebView or a manually detected cookie.
class GoogleSessionAuthScreen extends StatelessWidget {
  const GoogleSessionAuthScreen({super.key});
  @override
  Widget build(BuildContext context) => const BrowserWorkspaceScreen();
}
