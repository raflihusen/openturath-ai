import 'package:flutter/material.dart';
import '../core/scholarly_fonts.dart';
import '../services/browser_workspace_launcher.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
class BrowserWorkspaceScreen extends StatefulWidget {
  const BrowserWorkspaceScreen({super.key});
  @override
  State<BrowserWorkspaceScreen> createState() => _BrowserWorkspaceScreenState();
}

class _BrowserWorkspaceScreenState extends State<BrowserWorkspaceScreen> {
  bool _opening = false;
  bool _opened = false;
  String? _message;

  Future<void> _open() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _message = null;
    });
    try {
      await BrowserWorkspaceLauncher().open();
      if (mounted) setState(() => _opened = true);
    } on WorkspaceLaunchException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OpenTurath',
                      style: ScholarlyFonts.newsreader(
                          fontSize: OTFontSize.s36, color: colors.onSurface)),
                  const SizedBox(height: 24),
                  Text('Satu ruang untuk kajian Anda.',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const Text(
                      'Masuk dengan Google dari ruang browser, lalu buka NotebookLM di browser dan profil yang sama. Tidak ada login Google di WebView aplikasi.'),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _opening ? null : _open,
                    icon: _opening
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.open_in_browser_rounded),
                    label: Text(_opening
                        ? 'Membuka ruang…'
                        : _opened
                            ? 'Buka ruang kembali'
                            : 'Buka ruang kajian'),
                  ),
                  if (_opened) ...[
                    const SizedBox(height: 16),
                    const Text(
                        'Ruang kajian telah dibuka di browser. Anda dapat menambahkan pintasannya ke layar utama.'),
                  ],
                  if (_message != null) ...[
                    const SizedBox(height: 16),
                    Text(_message!, style: TextStyle(color: colors.error)),
                  ],
                  const SizedBox(height: 24),
                  Text(
                      'Sesi dipakai kembali per perangkat dan profil browser. Google tetap dapat meminta persetujuan atau verifikasi keamanan.',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
