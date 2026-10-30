import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A detached installer outlives the application. Readiness is acknowledged
/// before the running app exits; startup confirmation enables rollback.
class DesktopUpdateInstaller {
  const DesktopUpdateInstaller({this.allowAdhocForTesting =
      const bool.fromEnvironment('OT_OTA_ALLOW_ADHOC_TEST', defaultValue: false)});
  final bool allowAdhocForTesting;

  static Future<Directory> updateDirectory() async =>
      Directory(p.join((await getApplicationSupportDirectory()).path, 'updates'));

  static Future<void> confirmStartup() async {
    if (!Platform.isMacOS && !Platform.isWindows) return;
    try {
      final receipt = File(p.join((await updateDirectory()).path, 'pending_install.json'));
      if (!await receipt.exists()) return;
      final plan = jsonDecode(await receipt.readAsString()) as Map<String, dynamic>;
      final executable = File(Platform.resolvedExecutable).absolute.path;
      final target = plan['target'] as String;
      // Confirmation belongs to this installed location, not another app copy.
      if (!p.isWithin(target, executable)) return;
      final stage = Directory(plan['stage'] as String);
      if (!p.equals(p.dirname(stage.path), p.dirname(target))) return;
      // Do not acknowledge a restart of the predecessor or a rolled-back app.
      final status = File(p.join(stage.path, 'status'));
      if (!await status.exists() || (await status.readAsString()).trim() != 'installed') return;
      final info = await const MethodChannel('plugins.flutter.io/package_info').invokeMapMethod<String, dynamic>('getAll');
      final build = int.tryParse('${info?['buildNumber']}') ?? 0;
      if (build != plan['build']) return;
      await File(p.join(stage.path, 'confirmed')).writeAsString('$build', flush: true);
      await receipt.delete();
    } catch (error) {
      debugPrint('[Updater] Startup confirmation unavailable: ${error.runtimeType}');
    }
  }

  Future<void> handoff({required File package, required String hash,
      required int build, required int installerProtocol}) async {
    final windows = Platform.isWindows;
    if (!windows && !Platform.isMacOS) throw UnsupportedError('Desktop updater');
    if (windows && installerProtocol != 1) {
      throw const FormatException('This Windows installer does not support automatic updating');
    }
    final target = windows ? p.dirname(Platform.resolvedExecutable) :
        p.dirname(p.dirname(p.dirname(Platform.resolvedExecutable)));
    if (target.contains('\n') || target.contains('\r') ||
        (Platform.isMacOS && (!target.endsWith('.app') || target.startsWith('/Volumes/')))) {
      throw const FormatException('Run the installed application before updating');
    }
    final dir = await updateDirectory();
    await dir.create(recursive: true);
    final asset = windows ? 'windows_update.ps1' : 'macos_update.sh';
    final helper = File(p.join(dir.path, asset));
    await helper.writeAsString(await rootBundle.loadString('assets/updater/$asset'), flush: true);
    String stage;
    if (windows) {
      stage = (await Directory(p.join(p.dirname(target), '.ot-update-')).createTemp()).path;
    } else {
      final result = await Process.run('/bin/sh', [helper.path, 'prepare', package.path,
        target, '$build', hash, allowAdhocForTesting ? '1' : '0']).timeout(const Duration(minutes: 3));
      if (result.exitCode != 0) throw const FileSystemException('Update package could not be prepared');
      stage = (result.stdout as String).trim();
      if (!p.equals(p.dirname(stage), p.dirname(target)) || !p.basename(stage).startsWith('.ot-update.')) {
        throw const FormatException('Invalid update staging result');
      }
    }
    final plan = {'target': target, 'stage': stage, 'build': build,
      'package': package.path, 'sha256': hash, 'parentPid': pid,
      'allowAdhocTest': allowAdhocForTesting};
    final receipt = File(p.join(dir.path, 'pending_install.json'));
    final temporary = File('${receipt.path}.tmp');
    await temporary.writeAsString(jsonEncode(plan), flush: true);
    if (await receipt.exists()) await receipt.delete();
    await temporary.rename(receipt.path);
    if (windows) {
      final planFile = File(p.join(stage, 'plan.json'));
      await planFile.writeAsString(jsonEncode(plan), flush: true);
      await Process.start('powershell.exe', ['-NoProfile', '-NonInteractive', '-ExecutionPolicy',
        'Bypass', '-File', helper.path, '-Plan', planFile.path], mode: ProcessStartMode.detached);
    } else {
      await Process.start('/bin/sh', [helper.path, 'install', stage, target, '$pid', '$build'],
          mode: ProcessStartMode.detached);
    }
    final ready = File(p.join(stage, 'ready'));
    final deadline = DateTime.now().add(const Duration(minutes: 2));
    while (!await ready.exists()) {
      if (DateTime.now().isAfter(deadline)) throw TimeoutException('Installer did not become ready');
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}
