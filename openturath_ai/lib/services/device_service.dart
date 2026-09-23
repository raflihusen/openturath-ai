import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceFingerprint {
  final String deviceId;
  final String brand;
  final String model;
  final bool isPhysicalDevice;

  const DeviceFingerprint({
    required this.deviceId,
    required this.brand,
    required this.model,
    required this.isPhysicalDevice,
  });

  Map<String, dynamic> toMap() => {
        'deviceId': deviceId,
        'brand': brand,
        'model': model,
        'isPhysicalDevice': isPhysicalDevice,
      };

  @override
  String toString() =>
      'DeviceFingerprint(deviceId: ${deviceId.substring(0, 8)}..., model: $model, physical: $isPhysicalDevice)';
}

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static Future<String>? _installationId;

  static Future<String> _persistentId() => _installationId ??= (() async {
        final prefs = await SharedPreferences.getInstance();
        final existing = prefs.getString('ot_installation_identity_v1');
        if (existing != null && existing.isNotEmpty) return existing;
        final random = Random.secure();
        final id =
            base64UrlEncode(List.generate(32, (_) => random.nextInt(256)));
        if (!await prefs.setString('ot_installation_identity_v1', id)) {
          throw StateError('Identitas perangkat belum dapat disimpan.');
        }
        return id;
      })()
          .catchError((Object error) {
        _installationId = null;
        throw error;
      });

  static const String _salt = 'OT_AI_HW_SALT_2026_980031db';

  /// Menghitung hash SHA-256 salted dari identitas hardware perangkat.
  /// Bersifat deterministik dan aman untuk privasi pengguna.
  static String computeHash({
    required String rawId,
    required String brand,
    required String model,
  }) {
    final cleanId = rawId.trim();
    final cleanBrand = brand.trim().toLowerCase();
    final cleanModel = model.trim().toLowerCase();
    final payload = '$_salt::$cleanId::$cleanBrand::$cleanModel';
    return sha256.convert(utf8.encode(payload)).toString();
  }

  /// Mengambil sidik jari perangkat saat ini (Device Fingerprint).
  Future<DeviceFingerprint> getDeviceFingerprint() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        final rawId = webInfo.userAgent ?? 'web_browser';
        final brand = webInfo.vendor ?? 'browser';
        final model = webInfo.browserName.name;
        final hash = computeHash(rawId: rawId, brand: brand, model: model);
        return DeviceFingerprint(
          deviceId: hash,
          brand: brand,
          model: model,
          isPhysicalDevice: true,
        );
      }

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final rawId = androidInfo.id; // Settings.Secure.ANDROID_ID
        final brand = androidInfo.brand;
        final model = androidInfo.model;
        final isPhysical = androidInfo.isPhysicalDevice;
        final hash = computeHash(rawId: rawId, brand: brand, model: model);

        return DeviceFingerprint(
          deviceId: hash,
          brand: brand,
          model: model,
          isPhysicalDevice: isPhysical,
        );
      }

      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final rawId = iosInfo.identifierForVendor ?? 'ios_device';
        const brand = 'apple';
        final model = iosInfo.utsname.machine;
        final isPhysical = iosInfo.isPhysicalDevice;
        final hash = computeHash(rawId: rawId, brand: brand, model: model);

        return DeviceFingerprint(
          deviceId: hash,
          brand: brand,
          model: model,
          isPhysicalDevice: isPhysical,
        );
      }

      if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        final rawId = macInfo.systemGUID ?? await _persistentId();
        const brand = 'apple';
        final model = macInfo.model;
        final hash = computeHash(rawId: rawId, brand: brand, model: model);

        return DeviceFingerprint(
          deviceId: hash,
          brand: brand,
          model: model,
          isPhysicalDevice: true,
        );
      }
      if (Platform.isWindows) {
        final info = await _deviceInfo.windowsInfo;
        final rawId = info.deviceId.trim().isEmpty
            ? await _persistentId()
            : info.deviceId;
        return DeviceFingerprint(
          deviceId:
              computeHash(rawId: rawId, brand: 'windows', model: 'windows-pc'),
          brand: 'windows',
          model: info.productName,
          isPhysicalDevice: true,
        );
      }
    } catch (e) {
      debugPrint('[DeviceService] Warning failed to inspect device info: $e');
    }

    // Fallback darurat (misalnya unit test harness lokal tanpa platform channel)
    final fallbackId = await _persistentId();
    final fallbackHash = computeHash(
      rawId: fallbackId,
      brand: 'generic',
      model: 'generic_device',
    );
    return DeviceFingerprint(
      deviceId: fallbackHash,
      brand: 'generic',
      model: 'generic_device',
      isPhysicalDevice: true,
    );
  }
}
