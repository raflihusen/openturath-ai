import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/desktop_webview_runtime.dart';

class DesktopWebViewGate extends StatefulWidget {
  const DesktopWebViewGate({super.key, required this.builder});
  final WidgetBuilder builder;
  @override State<DesktopWebViewGate> createState() => _DesktopWebViewGateState();
}

class _DesktopWebViewGateState extends State<DesktopWebViewGate> {
  bool _busy = false;
  @override Widget build(BuildContext context) {
    final problem = DesktopWebViewRuntime.problem;
    if (problem == null) return widget.builder(context);
    return Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(problem, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: () async {
            try {
              final opened = await launchUrl(
                Uri.parse('https://developer.microsoft.com/microsoft-edge/webview2/'),
                mode: LaunchMode.externalApplication,
              );
              if (!opened) throw StateError('Browser unavailable');
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Browser belum dapat dibuka.')),
                );
              }
            }
          }, child: const Text('Unduh WebView2')),
          TextButton(onPressed: _busy ? null : () async {
            setState(() => _busy = true);
            await DesktopWebViewRuntime.prepare();
            if (mounted) setState(() => _busy = false);
          }, child: Text(_busy ? 'Memeriksa…' : 'Coba kembali setelah pemasangan')),
        ],
      )),
    ));
  }
}
