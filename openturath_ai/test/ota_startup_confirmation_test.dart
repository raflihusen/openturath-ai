import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:openturath_ai/services/desktop_update_installer.dart';

void main() {
  late Directory root;
  late Directory target;
  late Directory stage;
  late File receipt;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('ota startup ');
    target = await Directory(p.join(root.path, 'Application.app')).create();
    stage = await Directory(p.join(root.path, '.ot-update-fixture')).create();
    receipt = File(p.join(root.path, 'pending_install.json'));
    await receipt.writeAsString(
        jsonEncode({'target': target.path, 'stage': stage.path, 'build': 88}));
    await File(p.join(stage.path, 'status')).writeAsString('installed');
  });
  tearDown(() async => root.delete(recursive: true));

  Future<void> confirm({int build = 88, String? executable}) =>
      DesktopUpdateInstaller.confirmReceipt(
          receipt: receipt,
          executable:
              executable ?? p.join(target.path, 'Contents/MacOS/OpenTurath'),
          build: build);

  test('new installed build confirms startup and consumes the receipt',
      () async {
    await confirm();
    expect(await File(p.join(stage.path, 'confirmed')).readAsString(), '88');
    expect(await receipt.exists(), false);
  });
  test('predecessor cannot confirm an update', () async {
    await confirm(build: 87);
    expect(await File(p.join(stage.path, 'confirmed')).exists(), false);
    expect(await receipt.exists(), true);
  });
  test('another installed copy cannot confirm the update', () async {
    await confirm(
        executable: p.join(root.path, 'Other.app/Contents/MacOS/OpenTurath'));
    expect(await File(p.join(stage.path, 'confirmed')).exists(), false);
  });
  test('rollback and waiting states cannot be acknowledged', () async {
    for (final status in ['waiting', 'rolled_back', 'confirmed']) {
      await File(p.join(stage.path, 'status')).writeAsString(status);
      await confirm();
      expect(await File(p.join(stage.path, 'confirmed')).exists(), false);
    }
  });
  test('foreign staging directories are rejected', () async {
    await receipt.writeAsString(
        jsonEncode({'target': target.path, 'stage': root.path, 'build': 88}));
    await confirm();
    expect(await receipt.exists(), true);
  });
}
