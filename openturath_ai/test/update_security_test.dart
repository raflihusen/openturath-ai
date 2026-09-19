import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/update_service.dart';

void main() {
  final digest = List.filled(64, 'a').join();
  final policy = UpdateDownloadPolicy(allowedHosts: {'updates.example.com'});

  test('update transport fails closed unless exact HTTPS host and checksum match', () {
    expect(policy.permits('https://updates.example.com/release.apk', digest), isTrue);
    for (final url in [
      'http://updates.example.com/release.apk',
      'https://updates.example.com.evil.test/release.apk',
      'https://evil.test/updates.example.com/release.apk',
      'https://user:secret@updates.example.com/release.apk',
      'https://updates.example.com:8443/release.apk',
      'https://updates.example.com/release.apk#fragment',
      'file:///tmp/release.apk',
    ]) {
      expect(policy.permits(url, digest), isFalse, reason: url);
    }
    expect(UpdateDownloadPolicy(allowedHosts: {}).permits('https://updates.example.com/release.apk', digest), isFalse);
    for (final checksum in [null, '', 'abc', '${digest}0', '${digest.substring(1)}z']) {
      expect(policy.permits('https://updates.example.com/release.apk', checksum), isFalse);
    }
  });

  test('install-time integrity check detects file tampering and rejects missing hash', () async {
    final directory = await Directory.systemTemp.createTemp('ot_update_test_');
    try {
      final file = File('${directory.path}/release.apk');
      final data = Uint8List(UpdateDownloadPolicy.minimumBytes);
      data[0] = 1;
      await file.writeAsBytes(data, flush: true);
      final checksum = sha256.convert(data).toString();
      expect(await UpdateService.verifyPackage(file, checksum), isTrue);
      expect(await UpdateService.verifyPackage(file, null), isFalse);
      final handle = await file.open(mode: FileMode.writeOnlyAppend);
      await handle.writeByte(2);
      await handle.close();
      expect(await UpdateService.verifyPackage(file, checksum), isFalse);
      await file.writeAsBytes([1, 2, 3], flush: true);
      expect(await UpdateService.verifyPackage(file, sha256.convert([1, 2, 3]).toString()), isFalse);
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
