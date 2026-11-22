import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/models/sub_agent_model.dart';
import 'package:openturath_ai/services/feature_flags.dart';
import 'package:openturath_ai/widgets/tahawwulat_ai_picker.dart';
import 'package:openturath_ai/widgets/tahawwulat_hero.dart';

const soonThree = {
  'fiqh_tahawwulat_khatib',
  'fiqh_tahawwulat_habib',
  'fiqh_tahawwulat_mukhtabir',
};

void main() {
  setUp(() {
    AppConfig.localeNotifier.value = 'id';
    FeatureFlagsService.resetForTest();
    TahawwulatHero.introductionReadyOverride = null;
  });
  tearDown(() => TahawwulatHero.introductionReadyOverride = null);

  group('FeatureFlags.parse', () {
    test('bawaan: seluruh 5 sub-AI Tahawwulat dan Mengenal terbuka penuh', () {
      expect(FeatureFlags.defaults.soonSubAgentIds, isEmpty);
      expect(FeatureFlags.defaults.introductionEnabled, isTrue);
      for (final id in [
        'fiqh_tahawwulat_muhaqqiq',
        'fiqh_tahawwulat_bayan',
        ...soonThree,
      ]) {
        expect(FeatureFlags.defaults.isSubAgentSoon(id), isFalse, reason: id);
      }
    });

    test('dokumen kosong atau null memakai bawaan', () {
      expect(FeatureFlags.parse(null), FeatureFlags.defaults);
      expect(FeatureFlags.parse(const {}), FeatureFlags.defaults);
    });

    test('daftar kosong berarti semua sub-AI terbuka (rilis penuh)', () {
      final f = FeatureFlags.parse(const {
        'soon_sub_agent_ids': <String>[],
        'introduction_enabled': true,
      });
      expect(f.soonSubAgentIds, isEmpty);
      expect(f.introductionEnabled, isTrue);
    });

    test('mengubah isi daftar dan mematikan Mengenal lewat remote flag', () {
      final f = FeatureFlags.parse(const {
        'soon_sub_agent_ids': ['fiqh_tahawwulat_khatib'],
        'introduction_enabled': false,
      });
      expect(f.soonSubAgentIds, {'fiqh_tahawwulat_khatib'});
      expect(f.isSubAgentSoon('fiqh_tahawwulat_habib'), isFalse);
      expect(f.introductionEnabled, isFalse);
    });

    test('nilai bertipe salah diabaikan, bukan dipercaya', () {
      // introduction_enabled bukan bool -> jatuh ke fallback (bawaan true), bukan string/angka.
      final a = FeatureFlags.parse(const {'introduction_enabled': 'false'});
      expect(a.introductionEnabled, isTrue);
      final b = FeatureFlags.parse(const {'introduction_enabled': 0});
      expect(b.introductionEnabled, isTrue);
      // soon_sub_agent_ids bukan list -> bawaan (kosong).
      final c = FeatureFlags.parse(const {'soon_sub_agent_ids': 'fiqh_x'});
      expect(c.soonSubAgentIds, FeatureFlags.defaults.soonSubAgentIds);
      final d = FeatureFlags.parse(const {'soon_sub_agent_ids': 7});
      expect(d.soonSubAgentIds, FeatureFlags.defaults.soonSubAgentIds);
    });

    test('elemen daftar yang tidak valid dibuang, yang valid dipertahankan',
        () {
      final f = FeatureFlags.parse(const {
        'soon_sub_agent_ids': [
          'fiqh_tahawwulat_khatib',
          '  fiqh_tahawwulat_habib  ',
          42,
          null,
          '',
          'Fiqh Salah',
          'ALLCAPS',
          '9mulai_angka',
          'a/b',
        ],
      });
      expect(f.soonSubAgentIds,
          {'fiqh_tahawwulat_khatib', 'fiqh_tahawwulat_habib'});
    });

    test('daftar yang melewati batas dianggap salah ketik dan ditolak', () {
      final many = [for (var i = 0; i < 80; i++) 'agent_$i'];
      final f = FeatureFlags.parse({'soon_sub_agent_ids': many});
      expect(f.soonSubAgentIds, FeatureFlags.defaults.soonSubAgentIds);
    });

    test('fallback dipakai untuk kunci yang hilang', () {
      const fb =
          FeatureFlags(soonSubAgentIds: {'x_agent'}, introductionEnabled: true);
      final f = FeatureFlags.parse(const {}, fallback: fb);
      expect(f, fb);
    });

    test('kesetaraan tidak peduli urutan', () {
      const a = FeatureFlags(
          soonSubAgentIds: {'a_b', 'c_d'}, introductionEnabled: false);
      const b = FeatureFlags(
          soonSubAgentIds: {'c_d', 'a_b'}, introductionEnabled: false);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('gateSubAgent', () {
    test('bawaan membuka seluruh 5 sub-AI Tahawwulat', () {
      const f = FeatureFlags.defaults;
      for (final id in [
        'fiqh_tahawwulat_muhaqqiq',
        'fiqh_tahawwulat_bayan',
        ...soonThree,
      ]) {
        expect(gateSubAgent(id, f), SubAgentGate.open, reason: id);
      }
    });

    test('sub-AI yang ditandai segera hadir oleh remote flag ditolak', () {
      const f = FeatureFlags(
          soonSubAgentIds: soonThree, introductionEnabled: false);
      for (final id in soonThree) {
        expect(gateSubAgent(id, f), SubAgentGate.comingSoon, reason: id);
      }
      expect(gateSubAgent('fiqh_tahawwulat_muhaqqiq', f), SubAgentGate.open);
      expect(gateSubAgent('fiqh_tahawwulat_bayan', f), SubAgentGate.open);
    });

    test('induk Tahawwulat dan AI lain tidak pernah terkena gerbang ini', () {
      const f = FeatureFlags.defaults;
      for (final id in ['fiqh_tahawwulat', 'fiqh_syafii', 'hadits', '']) {
        expect(gateSubAgent(id, f), SubAgentGate.open, reason: id);
      }
    });

    test('daftar kosong membuka semuanya', () {
      const f = FeatureFlags(soonSubAgentIds: {}, introductionEnabled: true);
      for (final id in soonThree) {
        expect(gateSubAgent(id, f), SubAgentGate.open, reason: id);
      }
    });

    test('mengikuti perubahan daftar secara langsung', () {
      FeatureFlagsService.resetForTest(const FeatureFlags(
          soonSubAgentIds: {'fiqh_tahawwulat_bayan'},
          introductionEnabled: false));
      expect(gateSubAgent('fiqh_tahawwulat_bayan', FeatureFlagsService.current),
          SubAgentGate.comingSoon);
      expect(
          gateSubAgent('fiqh_tahawwulat_khatib', FeatureFlagsService.current),
          SubAgentGate.open);
    });
  });

  group('FeatureFlagsService', () {
    test('tanpa Firebase: sync mempertahankan nilai terakhir, tidak melempar',
        () async {
      FeatureFlagsService.resetForTest(const FeatureFlags(
          soonSubAgentIds: {'fiqh_tahawwulat_khatib'},
          introductionEnabled: true));
      final result = await FeatureFlagsService.sync(forceRefresh: true);
      expect(result.introductionEnabled, isTrue);
      expect(result.soonSubAgentIds, {'fiqh_tahawwulat_khatib'});
    });

    test('notifier hanya berbunyi saat nilai benar-benar berubah', () {
      var calls = 0;
      void listener() => calls++;
      FeatureFlagsService.notifier.addListener(listener);
      addTearDown(() => FeatureFlagsService.notifier.removeListener(listener));
      // Nilai sama dengan yang sekarang: tidak ada pemberitahuan.
      FeatureFlagsService.resetForTest(FeatureFlags.defaults);
      expect(calls, 0);
      // Nilai berbeda: tepat satu pemberitahuan.
      const closed =
          FeatureFlags(soonSubAgentIds: {}, introductionEnabled: false);
      FeatureFlagsService.resetForTest(closed);
      expect(calls, 1);
      // Nilai setara (isi sama) tidak memberi tahu lagi.
      FeatureFlagsService.resetForTest(
          const FeatureFlags(soonSubAgentIds: {}, introductionEnabled: false));
      expect(calls, 1);
      // Kembali ke bawaan: satu pemberitahuan lagi.
      FeatureFlagsService.resetForTest(FeatureFlags.defaults);
      expect(calls, 2);
    });
  });

  group('Tombol Mengenal Fikih Tahawwulat', () {
    test('kesiapan terbuka secara default dan mengikuti saklar jarak jauh', () {
      expect(TahawwulatHero.introductionReady, isTrue);
      FeatureFlagsService.resetForTest(
          const FeatureFlags(soonSubAgentIds: {}, introductionEnabled: false));
      expect(TahawwulatHero.introductionReady, isFalse);
    });

    test('penimpaan manual mengalahkan saklar jarak jauh', () {
      FeatureFlagsService.resetForTest(
          const FeatureFlags(soonSubAgentIds: {}, introductionEnabled: true));
      TahawwulatHero.introductionReadyOverride = false;
      expect(TahawwulatHero.introductionReady, isFalse);
      TahawwulatHero.introductionReadyOverride = null;
      expect(TahawwulatHero.introductionReady, isTrue);
    });

    Widget frame({VoidCallback? onIntroduction}) => MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => LocaleScope(child: child!),
        home: Scaffold(
            body: SingleChildScrollView(
                child: TahawwulatHero(
                    onOpen: () {}, onIntroduction: onIntroduction ?? () {}))));

    testWidgets('terbuka secara default tanpa penanda Segera hadir; remote false mengunci',
        (tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(frame());
      expect(find.text('Mengenal Fikih Tahawwulat'), findsOneWidget);
      expect(find.text('Segera hadir'), findsNothing);

      FeatureFlagsService.resetForTest(
          const FeatureFlags(soonSubAgentIds: {}, introductionEnabled: false));
      await tester.pumpWidget(frame());
      expect(find.text('Mengenal Fikih Tahawwulat'), findsOneWidget);
      expect(find.text('Segera hadir'), findsOneWidget);
    });

    testWidgets('penanda berganti ke Inggris dan Arab saat remote false',
        (tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      FeatureFlagsService.resetForTest(
          const FeatureFlags(soonSubAgentIds: {}, introductionEnabled: false));
      AppConfig.localeNotifier.value = 'en';
      await tester.pumpWidget(frame());
      expect(find.text('Getting to know Fiqh al-Tahawwulat'), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      AppConfig.localeNotifier.value = 'ar';
      await tester.pumpWidget(frame());
      expect(find.text('التعرّف على فقه التحولات'), findsOneWidget);
      expect(find.text('قريبًا'), findsOneWidget);
    });

    testWidgets('layar sempit dan teks besar tidak meluap', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      FeatureFlagsService.resetForTest(
          const FeatureFlags(soonSubAgentIds: {}, introductionEnabled: false));
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: LocaleScope(child: child!)),
          home: Scaffold(
              body: SingleChildScrollView(
                  child:
                      TahawwulatHero(onOpen: () {}, onIntroduction: () {})))));
      expect(tester.takeException(), isNull);
      expect(find.text('Segera hadir'), findsOneWidget);
    });

    testWidgets('mengetuk tombol memanggil aksi pemanggil', (tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var taps = 0;
      await tester.pumpWidget(frame(onIntroduction: () => taps++));
      await tester.tap(find.text('Mengenal Fikih Tahawwulat'));
      expect(taps, 1);
    });
  });

  group('Pemilih AI: sub-AI segera hadir', () {
    final subs = [
      for (final entry in const {
        'fiqh_tahawwulat_muhaqqiq': 'Al-Muhaqqiq',
        'fiqh_tahawwulat_bayan': 'Al-Bayan',
        'fiqh_tahawwulat_mukhtabir': 'Al-Mukhtabir',
        'fiqh_tahawwulat_habib': 'Al-Habib',
        'fiqh_tahawwulat_khatib': 'Al-Khatib',
      }.entries)
        SubAgentModel(
            id: entry.key,
            name: entry.value,
            nameArabic: entry.value,
            description: entry.value,
            descriptionArabic: entry.value,
            emoji: '',
            badge: ''),
    ];

    Future<void> open(WidgetTester tester, List<String> picked,
        {Set<String> soon = soonThree}) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => LocaleScope(child: child!),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => TahawwulatAiPicker.show(context,
                agents: subs,
                onSelect: (s) => picked.add(s.id),
                isSoon: (s) => soon.contains(s.id)),
            child: const Text('buka'),
          ),
        ),
      ));
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
    }

    testWidgets('tiga sub-AI berpenanda, dua lainnya tetap berpanah',
        (tester) async {
      await open(tester, []);
      expect(find.text('Segera hadir'), findsNWidgets(3));
      expect(find.byIcon(Icons.arrow_forward_rounded), findsNWidgets(2));
    });

    testWidgets('semua terbuka saat daftar kosong', (tester) async {
      await open(tester, [], soon: const {});
      expect(find.text('Segera hadir'), findsNothing);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsNWidgets(5));
    });

    testWidgets('penanda ikut berganti ke Inggris dan Arab', (tester) async {
      AppConfig.localeNotifier.value = 'en';
      await open(tester, []);
      expect(find.text('Coming soon'), findsNWidgets(3));
      await tester.pumpWidget(const SizedBox());
      AppConfig.localeNotifier.value = 'ar';
      await open(tester, []);
      expect(find.text('قريبًا'), findsNWidgets(3));
    });

    testWidgets('mengetuk kartu tetap meneruskan pilihan ke pemanggil',
        (tester) async {
      final picked = <String>[];
      await open(tester, picked);
      await tester.tap(find.text('Al-Khatib'));
      await tester.pumpAndSettle();
      // Keputusan menolak ada di pemanggil (layar daftar), bukan di pemilih.
      expect(picked, ['fiqh_tahawwulat_khatib']);
    });
  });
}
