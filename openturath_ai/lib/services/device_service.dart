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
      'DeviceFingerprint(model: $model, physical: $isPhysicalDevice)';
}

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static const String _salt = 'OT_AI_HW_SALT_2026_980031db';

  /// Legacy normalization helper retained for compatibility. A hash is not
  /// proof of hardware identity or protection against trial abuse.
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

  static const installationIdKey = 'openturath_installation_id_v1';
  Future<String>? _installationIdFuture;

  /// Installation-scoped, resettable identity. Reinstallation/cleared app data
  /// changes it; the server must not treat this as hardware attestation.
  static String createInstallationId() {
    final random = Random.secure();
    return List.generate(32, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  Future<String> _installationId() async {
    try {
      return await (_installationIdFuture ??= _loadInstallationId());
    } catch (_) {
      _installationIdFuture = null;
      rethrow; // No shared fallback identity when persistence is unavailable.
    }
  }

  Future<String> _loadInstallationId() async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(installationIdKey);
    if (existing != null && RegExp(r'^[a-f0-9]{64}$').hasMatch(existing)) return existing;
    final generated = createInstallationId();
    if (!await preferences.setString(installationIdKey, generated)) {
      throw StateError('Identitas instalasi belum dapat disimpan.');
    }
    return generated;
  }

  Future<DeviceFingerprint> getDeviceFingerprint() async {
    final installationId = await _installationId();
    var brand = 'unknown';
    var model = 'unknown';
    // false includes unknown. Never infer physical-device status on failure.
    var physical = false;
    try {
      if (kIsWeb) {
        final info = await _deviceInfo.webBrowserInfo;
        brand = info.vendor ?? 'browser';
        model = info.browserName.name;
      } else if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        brand = info.brand;
        model = info.model;
        physical = info.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        brand = 'apple';
        model = info.utsname.machine;
        physical = info.isPhysicalDevice;
      } else if (Platform.isMacOS) {
        final info = await _deviceInfo.macOsInfo;
        brand = 'apple';
        model = info.model;
      }
    } catch (_) {
      // Device inspection is optional; the persisted installation ID is not.
    }
    return DeviceFingerprint(deviceId: installationId, brand: brand,
      model: model, isPhysicalDevice: physical);
  }
}
