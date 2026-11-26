import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openturath_ai/core/firestore_public_doc.dart';
import 'package:openturath_ai/core/platform_release.dart';
import 'package:openturath_ai/services/feature_flags.dart';

void main() {
  group('FirestorePublicDoc REST decoder', () {
    test('decodes app_config/version nested maps, ints, strings for PlatformRelease', () {
      final restPayload = <String, dynamic>{
        'name': 'projects/open-turath/databases/(default)/documents/app_config/version',
        'fields': {
          'latest_version': {'stringValue': '2.0.0'},
          'latest_version_code': {'integerValue': '91'},
          'platforms': {
            'mapValue': {
              'fields': {
                'windows': {
                  'mapValue': {
                    'fields': {
                      'version': {'stringValue': '2.0.0'},
                      'build': {'integerValue': '91'},
                      'installer_protocol': {'integerValue': '1'},
                      'url': {
                        'stringValue':
                            'https://openturath.id/OpenTurath_AI_Windows_Setup.exe'
                      },
                      'sha256': {
                        'stringValue':
                            '36394705ee06648219753b35bc9f53a6f682d10ebd78dece96a859396168a8aa'
                      },
                      'notes': {'stringValue': 'Pembaruan Windows 2.0.0'},
                    },
                  },
                },
              },
            },
          },
        },
      };

      final decoded = FirestorePublicDoc.decodeDocument(restPayload);
      expect(decoded, isNotNull);
      expect(decoded!['latest_version_code'], 91);

      final release = PlatformRelease.parse(decoded, TargetPlatform.windows);
      expect(release, isNotNull);
      expect(release!.version, '2.0.0');
      expect(release.build, 91);
      expect(release.installerProtocol, 1);
      expect(
        release.url.toString(),
        'https://openturath.id/OpenTurath_AI_Windows_Setup.exe',
      );
    });

    test('decodes app_config/features empty and populated arrays for FeatureFlags', () {
      final restPayload = <String, dynamic>{
        'fields': {
          'introduction_enabled': {'booleanValue': true},
          'soon_sub_agent_ids': {
            'arrayValue': {
              'values': [
                {'stringValue': 'fiqh_tahawwulat_khatib'},
              ],
            },
          },
        },
      };

      final decoded = FirestorePublicDoc.decodeDocument(restPayload);
      final flags = FeatureFlags.parse(decoded);
      expect(flags.introductionEnabled, isTrue);
      expect(flags.soonSubAgentIds, contains('fiqh_tahawwulat_khatib'));

      final emptyArray = FirestorePublicDoc.decodeDocument({
        'fields': {
          'introduction_enabled': {'booleanValue': true},
          'soon_sub_agent_ids': {'arrayValue': <String, dynamic>{}},
        },
      });
      final emptyFlags = FeatureFlags.parse(emptyArray);
      expect(emptyFlags.soonSubAgentIds, isEmpty);
    });

    test('fetch handles 200 OK, 404, and malformed JSON safely', () async {
      final okClient = MockClient((req) async {
        expect(req.url.host, 'firestore.googleapis.com');
        expect(req.url.path,
            '/v1/projects/open-turath/databases/(default)/documents/app_config/features');
        return http.Response(
          jsonEncode({
            'fields': {
              'introduction_enabled': {'booleanValue': false},
            },
          }),
          200,
        );
      });
      final ok = await FirestorePublicDoc.fetch('app_config', 'features',
          client: okClient);
      expect(ok, isNotNull);
      expect(ok!['introduction_enabled'], isFalse);

      final notFoundClient = MockClient((_) async => http.Response('{}', 404));
      expect(
        await FirestorePublicDoc.fetch('app_config', 'missing',
            client: notFoundClient),
        isNull,
      );

      final brokenClient =
          MockClient((_) async => http.Response('not-json', 200));
      expect(
        await FirestorePublicDoc.fetch('app_config', 'broken',
            client: brokenClient),
        isNull,
      );
    });
  });
}
