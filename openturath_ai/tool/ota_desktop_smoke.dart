// Isolated desktop smoke fixture: local files/HTTP only, no Firebase or login.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:openturath_ai/services/desktop_update_installer.dart';
import 'package:openturath_ai/services/update_package_store.dart';
import 'package:openturath_ai/services/update_service.dart';

const manifestPath = String.fromEnvironment('OT_OTA_LOCAL_MANIFEST');
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(DesktopUpdateInstaller.confirmStartup());
  });
  runApp(const MaterialApp(home: DesktopSmoke()));
}

class LocalStore extends UpdatePackageStore {
  LocalStore(super.directory, this.localUrl)
      : super(allowUrl: (u) => u.host == '127.0.0.1', minBytes: 1);
  final Uri localUrl;
  @override
  Future<File> obtain(
          {required Uri url,
          required int build,
          required String platform,
          required String edition,
          required String hash,
          void Function(double)? onProgress}) =>
      super.obtain(
          url: localUrl,
          build: build,
          platform: platform,
          edition: edition,
          hash: hash,
          onProgress: onProgress);
}

class DesktopSmoke extends StatefulWidget {
  const DesktopSmoke({super.key});
  @override
  State<DesktopSmoke> createState() => _DesktopSmokeState();
}

class _DesktopSmokeState extends State<DesktopSmoke> {
  UpdateService? updater;
  HttpServer? server;
  String text = 'Preparing local fixture';
  @override
  void initState() {
    super.initState();
    unawaited(prepare());
  }

  Future<void> prepare() async {
    try {
      final info = await PackageInfo.fromPlatform();
      text = 'Running build ${info.buildNumber}';
      if (manifestPath.isEmpty || !File(manifestPath).existsSync()) {
        if (mounted) setState(() {});
        return;
      }
      final manifest = jsonDecode(await File(manifestPath).readAsString())
          as Map<String, dynamic>;
      final package = File(manifest['package'] as String);
      final ext = p.extension(package.path);
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server!.listen((request) async {
        if (request.uri.path != '/candidate$ext') {
          request.response.statusCode = 404;
          await request.response.close();
          return;
        }
        request.response.contentLength = await package.length();
        await request.response.addStream(package.openRead());
        await request.response.close();
      });
      final directory = Directory(p.join(
          (await getApplicationSupportDirectory()).path, 'ota-smoke-cache'));
      // ignore: invalid_use_of_visible_for_testing_member
      updater = UpdateService.test(
          platform:
              Platform.isMacOS ? TargetPlatform.macOS : TargetPlatform.windows,
          buildLoader: () async => int.parse(info.buildNumber),
          manifestLoader: () async => {
                'platforms': {
                  Platform.isMacOS ? 'macos' : 'windows': {
                    'version': manifest['version'],
                    'build': manifest['build'],
                    'sha256': manifest['sha256'],
                    'installer_protocol': 1,
                    'url': 'https://openturath.web.app/candidate$ext'
                  }
                }
              },
          store: LocalStore(directory,
              Uri.parse('http://127.0.0.1:${server!.port}/candidate$ext')));
      updater!.addListener(changed);
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => text = 'Fixture error: $error');
    }
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    updater?.removeListener(changed);
    updater?.dispose();
    server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(text),
        Text('State: ${updater?.status.name ?? 'idle'}'),
        if (updater?.lastError != null) Text(updater!.lastError!),
        FilledButton(
            onPressed: updater?.checkForUpdatesSilently,
            child: const Text('Check local update')),
        FilledButton(
            onPressed:
                updater?.isUpdateReady == true ? updater!.installNow : null,
            child: const Text('Install and restart fixture')),
      ])));
}
