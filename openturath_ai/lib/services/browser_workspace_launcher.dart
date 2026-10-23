import 'package:url_launcher/url_launcher.dart';

class WorkspaceLaunchException implements Exception {
  const WorkspaceLaunchException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Opens the same browser workspace on every platform. Credentials stay with
/// Firebase in that browser; they are never sent back to the native launcher.
class BrowserWorkspaceLauncher {
  static const configuredUrl = String.fromEnvironment(
    'OPENTURATH_WORKSPACE_URL',
    defaultValue: 'https://open-turath.firebaseapp.com/workspace/',
  );

  static Uri workspaceUri({String? agentId, String base = configuredUrl}) {
    final uri = Uri.parse(base);
    final trustedHost = const {
          'openturath.id',
          'www.openturath.id',
          'open-turath.firebaseapp.com',
          'open-turath.web.app',
        }.contains(uri.host) ||
        RegExp(r'^open-turath--[a-z0-9-]+\.web\.app$').hasMatch(uri.host);
    if (uri.scheme != 'https' ||
        !trustedHost ||
        uri.hasPort ||
        uri.userInfo.isNotEmpty ||
        uri.path != '/workspace/' ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const WorkspaceLaunchException('Alamat sesi AI tidak valid.');
    }
    if (agentId == null) return uri;
    if (!RegExp(r'^[a-z0-9_-]{1,80}$').hasMatch(agentId)) {
      throw const WorkspaceLaunchException('Bidang tidak valid.');
    }
    return uri.replace(queryParameters: {'agent': agentId});
  }

  Future<void> open({String? agentId}) async {
    final uri = workspaceUri(agentId: agentId);
    // A native HTTP preflight can fail while the system browser can connect
    // (for example, through its own proxy). Open the validated public HTTPS
    // destination directly; the browser owns connectivity and authentication.
    try {
      if (await launchUrl(uri,
          mode: LaunchMode.externalApplication, webOnlyWindowName: '_self')) {
        return;
      }
    } catch (_) {}
    throw const WorkspaceLaunchException(
      'Browser belum dapat dibuka. Pastikan perangkat memiliki browser utama.',
    );
  }
}
