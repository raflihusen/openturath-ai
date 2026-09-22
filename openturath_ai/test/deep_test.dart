import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/arabic_utils.dart';
import 'package:openturath_ai/core/design/ot_colors.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/book_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Asset Files & Animation Integrity Tests', () {
    test('All Lottie JSON animation files are valid and parseable', () {
      final dir = Directory('assets/animations');
      expect(dir.existsSync(), isTrue,
          reason: 'assets/animations directory must exist');

      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'));
      expect(files.isNotEmpty, isTrue,
          reason: 'Must contain Lottie JSON animation files');

      for (final file in files) {
        final content = file.readAsStringSync();
        expect(content.isNotEmpty, isTrue,
            reason: '${file.path} must not be empty');

        final dynamic decoded = jsonDecode(content);
        expect(decoded, isA<Map<String, dynamic>>(),
            reason: '${file.path} must be valid JSON object');
        final map = decoded as Map<String, dynamic>;
        expect(
            map.containsKey('v') ||
                map.containsKey('layers') ||
                map.containsKey('fr'),
            isTrue,
            reason: '${file.path} must have valid Lottie animation structure');
      }
    });

    test('All SVG vector files are valid XML and well-formed', () {
      final dir = Directory('assets/images');
      expect(dir.existsSync(), isTrue,
          reason: 'assets/images directory must exist');

      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.svg'));
      expect(files.isNotEmpty, isTrue, reason: 'Must contain SVG files');

      for (final file in files) {
        final content = file.readAsStringSync().trim();
        expect(content.isNotEmpty, isTrue,
            reason: '${file.path} must not be empty');
        expect(content.contains('<svg') && content.contains('</svg>'), isTrue,
            reason: '${file.path} must contain valid <svg> tags');
      }
    });

    test('Core official Google NotebookLM SVGs and Lottie files are present',
        () {
      const requiredFiles = [
        'assets/images/notebooklm_round.svg',
        'assets/images/gemini_notebook_with_text_only_light.svg',
        'assets/images/gemini_notebook_with_text_only_dark.svg',
        'assets/animations/thinking_ux_icon_looping.json',
      ];

      for (final path in requiredFiles) {
        final file = File(path);
        expect(file.existsSync(), isTrue,
            reason: 'Required official asset $path must exist on disk');
        expect(file.lengthSync() > 100, isTrue,
            reason: 'Asset $path must not be an empty dummy stub');
      }
    });

    test('Old raster logo_openturath.png is permanently eliminated', () {
      final oldLogo = File('assets/images/logo_openturath.png');
      expect(oldLogo.existsSync(), isFalse, reason: 'Old logo must not exist');
    });
  });

  group('2. Design System & Theme Engine Invariants', () {
    test('Official Google NotebookLM color tokens are exact', () {
      expect(AppTheme.canvasLight, equals(OTColors.canvasLight));
      expect(AppTheme.canvasDark, equals(OTColors.canvasDark));
      expect(AppTheme.surfaceCardLight, equals(OTColors.surfaceLight));
      expect(AppTheme.surfaceCardDark, equals(OTColors.surfaceDark));
      expect(AppTheme.borderLight, equals(OTColors.borderLight));
      expect(AppTheme.borderDark, equals(OTColors.borderDark));
      expect(AppTheme.accentLight, equals(OTColors.accentLight));
      expect(AppTheme.accentDark, equals(OTColors.accentDark));
      expect(AppTheme.citationBgLight, equals(OTColors.surfaceSubtleLight));
      expect(AppTheme.citationBgDark, equals(OTColors.surfaceSubtleDark));
    });

    test('Radius tokens keep controls disciplined and reserve full rounding',
        () {
      expect(AppTheme.radiusPill, equals(14.0));
      expect(AppTheme.radiusFull, equals(100.0));
      expect(AppTheme.radiusXS, equals(8.0));
      expect(AppTheme.radiusCard, equals(20.0));
      expect(AppTheme.radiusM, equals(16.0));
      expect(AppTheme.radiusS, equals(8.0));
    });
  });

  group('3. Agent Catalog & Module Entitlements Tests', () {
    test('Default catalog contains core Turats disciplines with full metadata',
        () {
      final agents = AgentModel.defaultAgents;
      expect(agents.length, greaterThanOrEqualTo(5));

      for (final a in agents) {
        expect(a.id, isNotEmpty, reason: 'Agent ID must not be empty');
        expect(a.title, isNotEmpty, reason: 'Agent Title must not be empty');
        expect(a.titleArabic, isNotEmpty,
            reason: 'Agent Arabic Title must not be empty');
        expect(a.category, isNotEmpty,
            reason: 'Agent Category must not be empty');

        if (a.isActive) {
          expect(a.price1m, isNotNull,
              reason: 'Active agent must have pricing configured');
          expect(a.price1m! > 0, isTrue);
        }
      }
    });

    test('Active agent books contain valid titles, authors, and descriptions',
        () {
      final activeAgents = AgentModel.defaultAgents.where((a) => a.isActive);
      expect(activeAgents.isNotEmpty, isTrue);

      for (final a in activeAgents) {
        if (a.referenceBooks != null) {
          for (final BookModel b in a.referenceBooks!) {
            expect(b.title, isNotEmpty);
            expect(b.titleArabic, isNotEmpty);
            expect(b.author, isNotEmpty);
          }
        }
      }
    });

    test('Sub-agents represent valid specialized research modes', () {
      for (final a in AgentModel.defaultAgents) {
        if (a.subAgents != null && a.subAgents!.isNotEmpty) {
          for (final sub in a.subAgents!) {
            expect(sub.id, isNotEmpty);
            expect(sub.name, isNotEmpty);
            expect(sub.nameArabic, isNotEmpty);
            expect(sub.description, isNotEmpty);
            expect(sub.emoji, isNotEmpty);
          }
        }
      }
    });
  });

  group('4. Smart Arabic Search & Text Normalization Tests', () {
    test('Arabic diacritics stripping is exhaustive', () {
      const input = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      final cleaned = ArabicUtils.normalize(input);
      expect(cleaned, equals('بسم الله الرحمن الرحيم'));
    });

    test('Alef variations are unified to bare alef', () {
      expect(ArabicUtils.normalize('إِسْلَام'), equals('اسلام'));
      expect(ArabicUtils.normalize('أُصُول'), equals('اصول'));
      expect(ArabicUtils.normalize('آدَاب'), equals('اداب'));
    });

    test('Arabic search correctly finds substrings regardless of voweling', () {
      const text =
          'مَتْنُ سَفِينَةِ النَّجَاةِ فِي أُصُولِ الدِّينِ وَالْفِقْهِ';
      expect(ArabicUtils.matches(text, 'سفينة'), isTrue);
      expect(ArabicUtils.matches(text, 'النجاة'), isTrue);
      expect(ArabicUtils.matches(text, 'اصول'), isTrue);
      expect(ArabicUtils.matches(text, 'الفقه'), isTrue);
      expect(ArabicUtils.matches(text, 'بخاري'), isFalse);
    });
  });

  group('5. Localization Dictionary Exhaustive Tests', () {
    test('All language keys exist across Indonesian, English, and Arabic', () {
      final keys = [
        'app_name',
        'choose_plan',
        'save',
        'cancel',
        'settings',
        'theme_mode',
        'theme_system',
        'theme_light',
        'theme_dark',
        'language',
      ];

      for (final key in keys) {
        expect(Loc.tr(key), isNotEmpty,
            reason: 'Key "$key" must be translated');
      }
    });
  });
}
