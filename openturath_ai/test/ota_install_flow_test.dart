import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:openturath_ai/services/update_package_store.dart';
import 'package:openturath_ai/services/update_service.dart';

// Exercise real HTTP/file I/O locally, while metadata still uses trusted HTTPS.
class FixtureStore extends UpdatePackageStore {
  FixtureStore(super.directory, this.origin) : super(minBytes: 1,
      maxBytes: 2048, allowUrl: (_) => true, idleTimeout: const Duration(seconds: 2));
  final Uri origin;
  @override
  Future<File> obtain({required Uri url, required int build, required String platform,
      required String edition, required String hash, void Function(double)? onProgress}) =>
      super.obtain(url: origin.resolve(url.path), build: build, platform: platform,
        edition: edition, hash: hash, onProgress: onProgress);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late HttpServer server;
  late FixtureStore store;
  var hits = 0;
  var responseCode = 200;
  final payload = List<int>.generate(1024, (i) => i % 256);
  final hash = sha256.convert(payload).toString();
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ota package test ');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    hits = 0; responseCode = 200;
    server.listen((request) async {
      hits++;
      request.response.statusCode = responseCode;
      if (request.uri.path == '/redirect.dmg') {
        request.response.statusCode = 302;
        request.response.headers.set('location', 'https://untrusted.example/bad.dmg');
      } else { request.response.add(payload); }
      await request.response.close();
    });
    store = FixtureStore(directory, Uri.parse('http://127.0.0.1:${server.port}'));
  });
  tearDown(() async {
    await server.close(force: true);
    await directory.delete(recursive: true);
  });

  Map<String, dynamic> manifest(TargetPlatform platform, {String? digest, int protocol = 1}) {
    final ext = platform == TargetPlatform.macOS ? 'dmg' : platform == TargetPlatform.windows ? 'exe' : 'apk';
    return {'platforms': {platform.name: {'build': 88, 'version': '1.0.87',
      'url': 'https://openturath.web.app/update.$ext', 'sha256': digest ?? hash,
      'installer_protocol': protocol}}};
  }
  UpdateService service(TargetPlatform platform, {Map<String, dynamic>? data,
      Future<void> Function(UpdateInfo)? install}) => UpdateService.test(platform: platform,
      buildLoader: () async => 87, manifestLoader: () async => data ?? manifest(platform),
      store: store, installer: install ?? (_) async {});

  for (final platform in [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.android]) {
    test('$platform downloads once, survives app recreation, installs local file', () async {
      var installed = 0;
      final first = service(platform);
      final statuses = <UpdateStatus>[];
      first.addListener(() => statuses.add(first.status));
      await first.checkForUpdatesSilently();
      expect(first.isUpdateReady, true);
      expect(statuses, contains(UpdateStatus.downloading));
      expect(await File(first.updateInfo!.localFilePath!).readAsBytes(), payload);
      expect(hits, 1);
      final reopened = service(platform, install: (info) async {
        expect(info.isDownloaded, true);
        expect(await UpdatePackageStore.digest(File(info.localFilePath!)), hash);
        installed++;
      });
      await reopened.checkForUpdatesSilently();
      expect(hits, 1, reason: 'Verified package must be reused after restart');
      expect(await reopened.installNow(), true);
      expect(installed, 1);
      expect(hits, 1, reason: 'Installation must never open a remote URL');
      first.dispose(); reopened.dispose();
    });
  }

  test('corrupt local package cannot be installed; retry downloads a clean copy', () async {
    var installed = 0;
    final updater = service(TargetPlatform.macOS, install: (_) async { installed++; });
    await updater.checkForUpdatesSilently();
    await File(updater.updateInfo!.localFilePath!).writeAsString('tampered');
    expect(await updater.installNow(), false);
    expect(installed, 0);
    expect(updater.isUpdateReady, false);
    await updater.retry();
    expect(hits, 2);
    expect(await updater.installNow(), true);
    expect(installed, 1);
    updater.dispose();
  });

  test('failed installer preserves package and can retry without downloading', () async {
    var attempts = 0;
    final updater = service(TargetPlatform.windows, install: (_) async {
      if (++attempts == 1) throw StateError('installer failed');
    });
    await updater.checkForUpdatesSilently();
    expect(await updater.installNow(), false);
    expect(updater.isUpdateReady, true);
    expect(updater.lastError, isNotNull);
    expect(await updater.installNow(), true);
    expect(hits, 1);
    updater.dispose();
  });

  test('double click cannot start two installers', () async {
    final completed = Completer<void>();
    final started = Completer<void>();
    final updater = service(TargetPlatform.android, install: (_) {
      started.complete(); return completed.future;
    });
    await updater.checkForUpdatesSilently();
    final first = updater.installNow();
    await started.future;
    expect(await updater.installNow(), false);
    completed.complete();
    expect(await first, true);
    updater.dispose();
  });

  test('incompatible Windows wrapper is never downloaded or offered as ready', () async {
    final updater = service(TargetPlatform.windows,
      data: manifest(TargetPlatform.windows, protocol: 0));
    await updater.checkForUpdatesSilently();
    expect(updater.status, UpdateStatus.error);
    expect(updater.isUpdateReady, false);
    expect(hits, 0);
    updater.dispose();
  });

  test('bad hash and HTTP failure leave no installable or partial package', () async {
    for (final code in [200, 503]) {
      responseCode = code;
      final updater = service(TargetPlatform.macOS,
          data: manifest(TargetPlatform.macOS, digest: 'a' * 64));
      await updater.checkForUpdatesSilently();
      expect(updater.status, UpdateStatus.error);
      expect(updater.isUpdateReady, false);
      expect(directory.listSync().whereType<File>().where((f) =>
        p.extension(f.path) == '.partial'), isEmpty);
      updater.dispose();
    }
  });

  test('redirect to an untrusted host is rejected before contacting it', () async {
    final guarded = UpdatePackageStore(directory, minBytes: 1,
      allowUrl: (u) => u.host == '127.0.0.1');
    await expectLater(guarded.obtain(url: store.origin.resolve('/redirect.dmg'),
      build: 88, platform: 'macos', edition: 'standard', hash: hash), throwsA(isA<HttpException>()));
    expect(hits, 1);
    expect(directory.listSync(), isEmpty);
  });

  test('an already installed build is not downloaded', () async {
    final updater = UpdateService.test(platform: TargetPlatform.macOS,
      buildLoader: () async => 88, manifestLoader: () async => manifest(TargetPlatform.macOS),
      store: store, installer: (_) async => fail('must not install'));
    await updater.checkForUpdatesSilently();
    expect(updater.status, UpdateStatus.idle);
    expect(hits, 0);
    updater.dispose();
  });
}
