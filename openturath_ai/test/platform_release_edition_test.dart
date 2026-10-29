import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/platform_release.dart';

void main() {
  final sha = 'a' * 64;
  final doc = <String, dynamic>{
    // Dokumen produksi: bidang datar milik edisi standar.
    'latest_version_code': 85,
    'latest_version': '1.0.84',
    'apk_url': 'https://openturath.web.app/OpenTurath_v85.apk',
    'sha256': sha,
  };

  PlatformRelease? parse(Map<String, dynamic> d, String edition) =>
      PlatformRelease.parse(d, TargetPlatform.android, edition: edition);

  test('edisi standar membaca bidang datar dan mengabaikan editions', () {
    final withGuru = {
      ...doc,
      'editions': {
        'guru': {
          'build': 99,
          'version': '9.9',
          'url': 'https://openturath.web.app/OpenTurath_Guru_v99.apk',
          'sha256': sha,
        }
      }
    };
    expect(parse(withGuru, 'standard')?.build, 85);
  });

  test('edisi Guru tidak pernah jatuh ke rilis standar', () {
    // Sebelum ada editions.guru, Guru TIDAK menerima update apa pun; kalau
    // jatuh ke bidang datar, APK standar akan menimpa edisi Guru.
    expect(parse(doc, 'guru'), isNull);
    expect(parse({...doc, 'editions': <String, dynamic>{}}, 'guru'), isNull);
    expect(parse({...doc, 'editions': 'rusak'}, 'guru'), isNull);
    expect(
        parse({
          ...doc,
          'editions': {'guru': 'rusak'}
        }, 'guru'),
        isNull);
  });

  test('edisi Guru membaca editions.guru', () {
    final d = {
      ...doc,
      'editions': {
        'guru': {
          'build': 90,
          'version': '1.0.90',
          'url': 'https://openturath.web.app/OpenTurath_Guru_v90.apk',
          'sha256': sha,
          'notes': 'Catatan Guru',
        }
      }
    };
    final r = parse(d, 'guru');
    expect(r?.build, 90);
    expect(r?.version, '1.0.90');
    expect(r?.sha256, sha);
    expect(r?.notes, 'Catatan Guru');
  });

  test('rilis Guru tetap tunduk pada aturan host dan ekstensi', () {
    for (final url in [
      'http://openturath.web.app/OpenTurath_Guru_v90.apk',
      'https://attacker.example/OpenTurath_Guru_v90.apk',
      'https://openturath.web.app/OpenTurath_Guru_v90.exe',
    ]) {
      expect(
          parse({
            'editions': {
              'guru': {'build': 90, 'version': '1', 'url': url, 'sha256': sha}
            }
          }, 'guru'),
          isNull,
          reason: url);
    }
  });

  test('desktop tidak terpengaruh edisi', () {
    expect(PlatformRelease.parse(doc, TargetPlatform.windows, edition: 'guru'),
        isNull);
  });
}
