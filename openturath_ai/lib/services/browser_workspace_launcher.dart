import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
          'open-turath.firebaseapp.com',
          'open-turath.web.app',
        }.contains(uri.host) ||
        RegExp(r'^open-turath--[a-z0-9-]+\.web\.app$').hasMatch(uri.host);
    if (uri.scheme != 'https' || !trustedHost || uri.hasPort ||
        uri.userInfo.isNotEmpty || uri.path != '/workspace/' ||
        uri.hasQuery || uri.hasFragment) {
      throw const WorkspaceLaunchException('Alamat ruang kajian tidak valid.');
    }
    if (agentId == null) return uri;
    if (!RegExp(r'^[a-z0-9_-]{1,80}$').hasMatch(agentId)) {
      throw const WorkspaceLaunchException('Bidang kajian tidak valid.');
    }
    return uri.replace(queryParameters: {'agent': agentId});
  }

  Future<void> open({String? agentId}) async {
    final uri = workspaceUri(agentId: agentId);
    if (!kIsWeb) {
      final client = http.Client();
      try {
        final page = await client.get(workspaceUri())
            .timeout(const Duration(seconds: 15));
        if (page.statusCode != 200 ||
            !page.body.contains('openturath-browser-workspace-v1')) {
          throw const WorkspaceLaunchException(
            'Ruang browser belum tersedia. Pengelola perlu menerbitkan versi ruang kajian yang baru.',
          );
        }
      } on WorkspaceLaunchException {
        rethrow;
      } catch (_) {
        throw const WorkspaceLaunchException(
          'Ruang kajian belum dapat dihubungi. Periksa internet lalu coba lagi.',
        );
      } finally {
        client.close();
      }
    }
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
