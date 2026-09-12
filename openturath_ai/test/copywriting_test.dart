import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_copy.dart';
import 'package:openturath_ai/models/agent_model.dart';

void main() {
  group('OpenTurath Copywriting Overhaul — Quiet Scholar Principles', () {
    test('Canonical navigation labels use concise, quiet terms', () {
      expect(AppCopy.navHome, equals('Beranda'));
      expect(AppCopy.navStudies, equals('Asisten AI'));
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
          equals('Akun ini belum mendapat akses ke Fikih Syafi\'i. Aktifkan langganan untuk melanjutkan.'));
      expect(AppCopy.planWithAgent('Fikih Syafi\'i', '1 Bulan'),
          equals('Fikih Syafi\'i — 1 Bulan'));
    });
  });
}
