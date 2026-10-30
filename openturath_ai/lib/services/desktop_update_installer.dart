import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A detached installer outlives the application. Readiness is acknowledged
/// before the running app exits; startup confirmation enables rollback.
class DesktopUpdateInstaller {
  const DesktopUpdateInstaller(
      {this.allowAdhocForTesting = const bool.fromEnvironment(
          'OT_OTA_ALLOW_ADHOC_TEST',
          defaultValue: false)});
  final bool allowAdhocForTesting;

  static Future<Directory> updateDirectory() async => Directory(
      p.join((await getApplicationSupportDirectory()).path, 'updates'));

  static Future<void> confirmStartup() async {
    if (!Platform.isMacOS && !Platform.isWindows) return;
    try {
      final receipt =
          File(p.join((await updateDirectory()).path, 'pending_install.json'));
      if (!await receipt.exists()) return;
      final info = await PackageInfo.fromPlatform();
      await confirmReceipt(receipt: receipt, executable: Platform.resolvedExecutable,
          build: int.tryParse(info.buildNumber) ?? 0);
    } catch (error) {
      debugPrint(
          '[Updater] Startup confirmation unavailable: ${error.runtimeType}');
    }
  }

  @visibleForTesting
  static Future<void> confirmReceipt({required File receipt,
      required String executable, required int build}) async {
    final plan = jsonDecode(await receipt.readAsString()) as Map<String, dynamic>;
    final target = plan['target'] as String;
    if (!p.isWithin(target, File(executable).absolute.path)) return;
    final stage = Directory(plan['stage'] as String);
    if (!p.equals(p.dirname(stage.path), p.dirname(target)) ||
        !p.basename(stage.path).startsWith('.ot-update')) {
      return;
    }
    final status = File(p.join(stage.path, 'status'));
    if (!await status.exists() ||
        (await status.readAsString()).trim() != 'installed' || build != plan['build']) {
      return;
    }
    await File(p.join(stage.path, 'confirmed')).writeAsString('$build', flush: true);
    await receipt.delete();
  }

  Future<String> handoff(
      {required File package,
      required String hash,
      required int build,
      required int installerProtocol}) async {
    final windows = Platform.isWindows;
    if (!windows && !Platform.isMacOS) {
      throw UnsupportedError('Desktop updater');
    }
    if (kReleaseMode && allowAdhocForTesting) {
      throw StateError('Test signing bypass is forbidden in release builds');
    }
    if (windows && installerProtocol != 1) {
      throw const FormatException(
          'This Windows installer does not support automatic updating');
    }
    final target = windows
        ? p.dirname(Platform.resolvedExecutable)
        : p.dirname(p.dirname(p.dirname(Platform.resolvedExecutable)));
    if (target.contains('\n') ||
        target.contains('\r') ||
        (Platform.isMacOS &&
            (!target.endsWith('.app') || target.startsWith('/Volumes/')))) {
      throw const FormatException(
          'Run the installed application before updating');
    }
    final dir = await updateDirectory();
    await dir.create(recursive: true);
    final asset = windows ? 'windows_update.ps1' : 'macos_update.sh';
    final helper = File(p.join(dir.path, asset));
    await helper.writeAsString(
        await rootBundle.loadString('assets/updater/$asset'),
        flush: true);
    String stage;
    if (windows) {
      stage =
          (await Directory(p.dirname(target)).createTemp('.ot-update-')).path;
    } else {
      final result = await Process.run('/bin/sh', [
        helper.path,
        'prepare',
        package.path,
        target,
        '$build',
        hash,
        allowAdhocForTesting ? '1' : '0'
      ]).timeout(const Duration(minutes: 3));
      if (result.exitCode != 0) {
        debugPrint('[Updater] Preparation rejected: ${result.stderr}');
        throw const FileSystemException('Update package could not be prepared');
      }
      stage = (result.stdout as String).trim();
      if (!p.equals(p.dirname(stage), p.dirname(target)) ||
          !p.basename(stage).startsWith('.ot-update.')) {
        throw const FormatException('Invalid update staging result');
      }
    }
    final plan = {
      'target': target,
      'stage': stage,
      'build': build,
      'package': package.path,
      'sha256': hash,
      'parentPid': pid,
      'allowAdhocTest': allowAdhocForTesting
    };
    final receipt = File(p.join(dir.path, 'pending_install.json'));
    final temporary = File('${receipt.path}.tmp');
    await temporary.writeAsString(jsonEncode(plan), flush: true);
    if (await receipt.exists()) await receipt.delete();
    await temporary.rename(receipt.path);
    if (windows) {
      final planFile = File(p.join(stage, 'plan.json'));
      await planFile.writeAsString(jsonEncode(plan), flush: true);
      await Process.start(
          'powershell.exe',
          [
            '-NoProfile',
            '-NonInteractive',
            '-ExecutionPolicy',
            'Bypass',
            '-File',
            helper.path,
            '-Plan',
            planFile.path
          ],
          mode: ProcessStartMode.detached);
    } else {
      await Process.start(
          '/bin/sh', [helper.path, 'install', stage, target, '$pid', '$build'],
          mode: ProcessStartMode.detached);
    }
    final ready = File(p.join(stage, 'ready'));
    final deadline = DateTime.now().add(const Duration(minutes: 2));
    while (!await ready.exists()) {
      if (await File(p.join(stage, 'handoff_failed')).exists()) {
        throw const FileSystemException('Installer preparation failed');
      }
      if (DateTime.now().isAfter(deadline)) {
        await File(p.join(stage, 'cancelled')).writeAsString('cancelled');
        throw TimeoutException('Installer did not become ready');
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return stage;
  }
}
