import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/hijri_date_utils.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/services/agent_session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Milestone 3: 3-Mode Theme & Dashboard Restructuring', () {
    test(
        'AppConfig supports ThemeMode.system, ThemeMode.light, and ThemeMode.dark',
        () async {
      await AppConfig.setThemeMode(ThemeMode.light);
      expect(AppConfig.themeNotifier.value, ThemeMode.light);

      await AppConfig.setThemeMode(ThemeMode.dark);
      expect(AppConfig.themeNotifier.value, ThemeMode.dark);

      await AppConfig.setThemeMode(ThemeMode.system);
      expect(AppConfig.themeNotifier.value, ThemeMode.system);
    });

    test(
        'HijriDateUtils formatDualDate produces elegant scholarly date with H and M',
        () {
      final now = DateTime(2026, 9, 12);
      final dual = HijriDateUtils.formatDualDate(now);
      expect(dual.contains('H'), isTrue);
      expect(dual.contains('M'), isTrue);
      expect(dual.contains('•'), isTrue);
      expect(dual.contains('September'), isTrue);
      expect(dual.contains('2026'), isTrue);
    });

    test('HijriDateUtils formatHijriOnly produces valid Hijri format', () {
      final now = DateTime(2026, 9, 12);
      final hijriOnly = HijriDateUtils.formatHijriOnly(now);
      expect(hijriOnly.contains('H'), isTrue);
      expect(hijriOnly.isNotEmpty, isTrue);
    });

    test(
        'Dashboard resume session selects matching active agent when last opened exists',
        () {
      final agents = AgentModel.defaultAgents;
      final target = agents.firstWhere((a) => a.id == 'fiqh_syafii');
      final lastOpenedId = target.id;

      final matched =
          agents.where((a) => a.id == lastOpenedId && a.isActive).firstOrNull;
      expect(matched, isNotNull);
      expect(matched!.id, 'fiqh_syafii');
    });

    test(
        'Recent notes can store and format canonical book and ibarah citations',
        () {
      final note1 = BookmarkModel(
        id: 'book_minhaj_al_talibin',
        title: 'منهاج الطالبين وعمدة المفتين',
        agentId: 'fiqh_syafii',
        agentTitle: 'Spesialis Fiqh Syafi\'i',
        fieldName: 'Fikih',
        fieldId: 'fiqh',
        arabicExcerpt: 'كتاب الطهارة: يرفع الحدث وينجس الخbث بالماء المطلق',
        fullAnswer: 'Teks asal bab Thaharah',
        bookReference: 'Minhaj al-Talibin',
        pageNumber: '12',
        author: 'Imam an-Nawawi',
        createdAt: DateTime.now(),
      );

      expect(note1.id.startsWith('book_'), isTrue);
      expect(note1.author, 'Imam an-Nawawi');
      expect(note1.bookReference, 'Minhaj al-Talibin');
    });

    test(
        'AgentSessionManager maxTabs is limited to 3 to prevent Android WebView memory bloat',
        () {
      expect(AgentSessionManager.maxTabs, 3);
    });
  });
}
