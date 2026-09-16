import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_copy.dart';
import 'package:openturath_ai/models/agent_model.dart';

void main() {
  group('OpenTurath Copywriting Overhaul — Quiet Scholar Principles v2', () {
    test('Canonical navigation labels use concise, quiet terms', () {
      expect(AppCopy.navHome, equals('Beranda'));
      expect(AppCopy.navStudies, equals('Asisten'));
      expect(AppCopy.navSaved, equals('Catatan'));
      expect(AppCopy.navSettings, equals('Pengaturan'));
    });

    test('Canonical app name and tagline are concise and avoid superlatives', () {
      expect(AppCopy.appName, equals('OpenTurath'));
      expect(AppCopy.appTagline, equals('Membaca kitab, menelusuri ibarah.'));
    });

    test('Success toasts never use exclamation marks (!)', () {
      expect(AppCopy.savedSuccess.contains('!'), isFalse,
          reason: 'Success messages should be calm and not use exclamation marks');
      expect(AppCopy.answerCopied.contains('!'), isFalse,
          reason: 'Copy action should be quiet and not use exclamation marks');
      expect(AppCopy.deleteAccountSuccess.contains('!'), isFalse);
    });

    test('Public strings do not contain prohibited marketing or academic jargon', () {
      final prohibitedWords = [
        'korpus',
        'ruang riset',
        'ai spesialis',
        'naskah primer',
        'kurasi kebahasaan',
        'penelaahan',
        'fasilitas',
        'komprehensif',
        'secara menyeluruh',
        'berbasis',
        'terintegrasi',
        'optimal',
        'presisi',
        'solusi',
      ];

      final samplePublicStrings = [
        AppCopy.aboutDescription,
        AppCopy.aboutScholarlyPrinciple,
        AppCopy.adabHeading1,
        AppCopy.adabBody1,
        AppCopy.adabHeading2,
        AppCopy.adabBody2,
        AppCopy.deviceNotSupportedTitle,
        AppCopy.deviceNotSupportedMessage,
        AppCopy.cannotConnectTitle,
        AppCopy.cannotConnectMessage,
        AppCopy.noSavedTitle,
        AppCopy.noSavedDescription,
        AppCopy.catalogLoadFailed,
        AppCopy.activeSubscription,
        AppCopy.inactiveSubscription,
        AppCopy.googleSessionConnectTitle,
        AppCopy.googleSessionConnectSubtitle,
        AppCopy.googleSessionConnectDesc,
        AppCopy.googleSessionSignInHint,
        AppCopy.packagePerField,
        AppCopy.packageAllFields,
        AppCopy.packageAllFieldsPreparing,
        AppCopy.sessionExpiredOrNoAccess,
        AppCopy.agentLoadFailed,
      ];

      for (final text in samplePublicStrings) {
        final lower = text.toLowerCase();
        for (final word in prohibitedWords) {
          expect(lower.contains(word), isFalse,
              reason: 'String "$text" should not contain prohibited word "$word"');
        }
      }
    });

    test('AgentModel defaultAgents descriptions and titles avoid banned jargon', () {
      final prohibitedInAgents = [
        'korpus',
        'fasilitas',
        'komprehensif',
        'secara menyeluruh',
        'solusi',
        'optimal',
        'ai spesialis',
      ];

      for (final agent in AgentModel.defaultAgents) {
        final refTitles = (agent.referenceBooks ?? []).map((b) => '${b.title} ${b.description}').join(' ');
        final combined = '${agent.title} ${agent.description} $refTitles'.toLowerCase();
        for (final word in prohibitedInAgents) {
          expect(combined.contains(word), isFalse,
              reason: 'Agent ${agent.id} contains prohibited word "$word": $combined');
        }
      }
    });

    test('Dynamic interpolation helpers produce serene, well-formed phrases', () {
      expect(AppCopy.preparingModule('Fikih Syafi\'i'),
          equals('Fikih Syafi\'i sedang disiapkan.'));
      expect(AppCopy.subscriptionRequiredFor('Fikih Syafi\'i'),
          equals('Berlangganan untuk membuka Fikih Syafi\'i.'));
      expect(AppCopy.accessUnavailableFor('Fikih Syafi\'i'),
          equals('Akses ke Fikih Syafi\'i belum aktif. Pilih paket atau gunakan voucher untuk melanjutkan.'));
      expect(AppCopy.planWithAgent('Fikih Syafi\'i', '1 Bulan'),
          equals('Fikih Syafi\'i — 1 Bulan'));
    });

    test('UI screens and widgets do not leak prohibited terms into user-facing code', () {
      // Subscription screen uses commercial SaaS conversion copy as requested by product owner
      final filesToScan = [
        'lib/screens/google_session_auth_screen.dart',
        'lib/screens/profile_screen.dart',
        'lib/screens/dashboard_screen.dart',
        'lib/screens/library_screen.dart',
        'lib/screens/book_catalog_screen.dart',
        'lib/screens/bookmark_screen.dart',
        'lib/widgets/app_error_state.dart',
        'lib/widgets/evidence_bottom_sheet.dart',
        'lib/widgets/openturath_brand.dart',
      ];

      final bannedPatterns = [
        RegExp(r"['\x22][^'\x22]*ruang\s+riset[^'\x22]*['\x22]", caseSensitive: false),
        RegExp(r"['\x22][^'\x22]*ai\s+spesialis[^'\x22]*['\x22]", caseSensitive: false),
        RegExp(r"['\x22][^'\x22]*naskah\s+primer[^'\x22]*['\x22]", caseSensitive: false),
        RegExp(r"['\x22][^'\x22]*kurasi\s+kebahasaan[^'\x22]*['\x22]", caseSensitive: false),
        RegExp(r"['\x22][^'\x22]*autentikasi\s+sesi[^'\x22]*['\x22]", caseSensitive: false),
        RegExp(r"['\x22][^'\x22]*modul\s+telaah[^'\x22]*['\x22]", caseSensitive: false),
        RegExp(r"['\x22][^'\x22]*memproses\s+telaah[^'\x22]*['\x22]", caseSensitive: false),
      ];

      for (final path in filesToScan) {
        final file = File(path);
        if (!file.existsSync()) continue;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trim();
          if (trimmed.startsWith('//') && !trimmed.contains("Text(")) continue;
          for (final pattern in bannedPatterns) {
            expect(
              pattern.hasMatch(line),
              isFalse,
              reason: 'Banned user-facing term matched ${pattern.pattern} in $path at line ${i + 1}:\n$line',
            );
          }
        }
      }
    });
  });
}
