import 'package:flutter/foundation.dart';

/// Desktop releases never inherit Android version numbers or APK URLs.
class PlatformRelease {
  const PlatformRelease(
      {required this.build,
      required this.version,
      required this.url,
      required this.notes,
      this.sha256});
  final int build;
  final String version;
  final Uri url;
  final String notes;
  final String? sha256;

  static const allowedHosts = {
    'openturath.id',
    'www.openturath.id',
    'openturath.ai',
    'www.openturath.ai',
    'openturath.web.app',
    'open-turath.web.app',
    'openturath-ai.web.app',
    'openturath.firebaseapp.com',
    'open-turath.firebaseapp.com',
    'openturath-ai.firebaseapp.com',
  };

  static PlatformRelease? parse(
      Map<String, dynamic> data, TargetPlatform platform) {
    final key = switch (platform) {
      TargetPlatform.android => 'android',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      _ => null,
    };
    if (key == null) return null;
    final platforms = data['platforms'];
    final value = platforms is Map ? platforms[key] : data[key];
    final Map release;
    if (value is Map) {
      release = value;
    } else if (platform == TargetPlatform.android) {
      release = data; // Preserve the production Android document contract.
    } else {
      return null;
    }
    final build =
        int.tryParse('${release['build'] ?? release['latest_version_code']}');
    final urlValue = release['url'] ?? release['apk_url'];
    final version = release['version'] ?? release['latest_version'];
    if (build == null ||
        build <= 0 ||
        urlValue is! String ||
        version is! String ||
        version.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(urlValue);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.port != 443 ||
        !allowedHosts.contains(uri.host)) {
      return null;
    }
    final path = uri.path.toLowerCase();
    final extensions = switch (platform) {
      TargetPlatform.android => ['.apk'],
      TargetPlatform.macOS => ['.dmg', '.pkg', '.zip'],
      TargetPlatform.windows => [
          '.exe',
          '.msi',
          '.msix',
          '.msixbundle',
          '.zip'
        ],
      _ => <String>[],
    };
    if (!extensions.any(path.endsWith)) return null;
    final hash = release['sha256'];
    return PlatformRelease(
      build: build,
      version: version,
      url: uri,
      notes: (release['notes'] ?? release['release_notes']) is String
          ? (release['notes'] ?? release['release_notes']) as String
          : 'Pembaruan OpenTurath AI',
      sha256: hash is String && RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(hash)
          ? hash
          : null,
    );
  }
}
