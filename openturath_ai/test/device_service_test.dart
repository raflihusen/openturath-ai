import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/device_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('DeviceService & Fingerprint Hashing', () {
    test('computeHash produces valid 64-char lowercase hex string', () {
      final hash = DeviceService.computeHash(
        rawId: '4a6b8c0d1e2f3a4b',
        brand: 'Samsung',
        model: 'SM-S918B',
      );

      expect(hash.length, equals(64));
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(hash), isTrue);
    });

    test('computeHash is case-insensitive for brand and model normalization', () {
      final hash1 = DeviceService.computeHash(
        rawId: 'android_id_123',
        brand: 'SAMSUNG',
        model: 'Galaxy-A54',
      );
      final hash2 = DeviceService.computeHash(
        rawId: 'android_id_123',
        brand: 'samsung',
        model: 'galaxy-a54',
      );

      expect(hash1, equals(hash2));
    });

    test('Different rawId produces distinct hashes (avalanche effect)', () {
      final hashA = DeviceService.computeHash(
        rawId: 'device_alpha',
        brand: 'xiaomi',
        model: 'redmi_12',
      );
      final hashB = DeviceService.computeHash(
        rawId: 'device_beta',
        brand: 'xiaomi',
        model: 'redmi_12',
      );

      expect(hashA, isNot(equals(hashB)));
    });

    test('getDeviceFingerprint returns a non-empty fingerprint safely in test environment', () async {
      final service = DeviceService();
      final fp = await service.getDeviceFingerprint();

      expect(fp.deviceId.length, equals(64));
      expect(fp.model.isNotEmpty, isTrue);
      expect(fp.brand.isNotEmpty, isTrue);
    });
  });
}
