import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/platform_release.dart';

void main() {
  final android = {'latest_version_code': 100, 'latest_version': '2.0',
    'apk_url': 'https://open-turath.web.app/app.apk'};
  test('Desktop never inherits the production Android update', () {
    expect(PlatformRelease.parse(android, TargetPlatform.windows), isNull);
    expect(PlatformRelease.parse(android, TargetPlatform.macOS), isNull);
    expect(PlatformRelease.parse(android, TargetPlatform.android)?.build, 100);
  });
  test('Desktop releases use independent version streams', () {
    final data = {...android, 'platforms': {
      'windows': {'build': 2, 'version': '1.0.1', 'url': 'https://open-turath.web.app/app.zip'},
      'macos': {'build': 3, 'version': '1.0.2', 'url': 'https://open-turath.web.app/app.dmg'},
    }};
    expect(PlatformRelease.parse(data, TargetPlatform.windows)?.build, 2);
    expect(PlatformRelease.parse(data, TargetPlatform.macOS)?.build, 3);
    expect(PlatformRelease.parse(data, TargetPlatform.android)?.build, 100);
  });
  for (final url in ['https://open-turath.web.app/app.apk', 'http://open-turath.web.app/app.exe',
    'https://open-turath.web.app.attacker.example/app.exe', 'https://user@open-turath.web.app/app.exe',
    'https://open-turath.web.app:444/app.exe']) {
    test('Windows rejects wrong platform or untrusted destination: $url', () {
      expect(PlatformRelease.parse({'windows': {'build': 2, 'version': '1.0.1', 'url': url}}, TargetPlatform.windows), isNull);
    });
  }
}
