import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/screens/labs_screen.dart';
import 'package:openturath_ai/services/labs_flags.dart';
import 'package:openturath_ai/services/voice_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LabsFlagsService.resetForTest();
  });

  group('LabsFlags', () {
    test('seluruh fitur eksperimen nonaktif secara bawaan', () {
      expect(LabsFlags.defaults.voiceDictation, isFalse);
      expect(LabsFlags.defaults.voiceConversation, isFalse);
      expect(LabsFlags.defaults.voiceReadAloud, isFalse);
      expect(LabsFlags.defaults.voiceSkipLongArabic, isFalse);
      expect(LabsFlags.defaults.anyVoiceEnabled, isFalse);
      expect(LabsFlags.defaults.voiceLocale, 'id_ID');
    });

    test('menyimpan dan membaca ulang preferensi Labs dari SharedPreferences',
        () async {
      await LabsFlagsService.update(const LabsFlags(
        voiceDictation: true,
        voiceConversation: true,
        voiceReadAloud: true,
        voiceSkipLongArabic: true,
        voiceLocale: 'ar_SA',
      ));
      expect(LabsFlagsService.current.anyVoiceEnabled, isTrue);
      expect(LabsFlagsService.current.voiceLocale, 'ar_SA');

      await LabsFlagsService.resetAll();
      expect(LabsFlagsService.current, LabsFlags.defaults);
      expect(LabsFlagsService.current.anyVoiceEnabled, isFalse);
    });
  });

  group('VoiceTextSegmenter', () {
    test('membersihkan Markdown, tautan, dan sitasi angka [1] untuk TTS', () {
      final clean = VoiceTextSegmenter.cleanForSpeech(
        '**Hukum shalat** [1, 2] lihat [al-Majmu](https://example.com) dan `catatan`.',
      );
      expect(clean, isNot(contains('**')));
      expect(clean, isNot(contains('[1, 2]')));
      expect(clean, isNot(contains('https://')));
      expect(clean, contains('Hukum shalat'));
      expect(clean, contains('al-Majmu'));
    });

    test('memisahkan segmen penjelasan Indonesia dan ibarah Arab secara berurutan',
        () {
      const sample =
          'Menurut Imam al-Nawawi: قال الإمام النووي رحمه الله إنما الأعمال بالنيات. Ini dalil utamanya.';
      final segments = VoiceTextSegmenter.segment(sample);
      expect(segments.length, 3);
      expect(segments[0].isArabic, isFalse);
      expect(segments[0].text, contains('Menurut Imam al-Nawawi'));
      expect(segments[1].isArabic, isTrue);
      expect(segments[1].text, contains('إنما الأعمال بالنيات'));
      expect(segments[2].isArabic, isFalse);
      expect(segments[2].text, contains('Ini dalil utamanya'));
    });

    test('skipLongArabic meringkas blok Arab panjang (>240 karakter)', () {
      final longArabic = List.filled(40, 'قال الإمام النووي رحمه الله').join(' ');
      final segments = VoiceTextSegmenter.segment(
        'Penjelasan awal. $longArabic Penjelasan akhir.',
        skipLongArabic: true,
      );
      expect(segments.any((s) => s.isArabic), isFalse);
      expect(
        segments.map((s) => s.text).join(' '),
        contains('Terdapat kutipan ibarah Arab di layar.'),
      );
    });
  });

  testWidgets('LabsScreen tampil bersih dan saklar berfungsi tanpa overflow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LabsScreen(),
      ),
    );
    await tester.pump();
    expect(find.text('Ruang Eksperimen'), findsOneWidget);
    expect(find.text('OPENTURATH LABS'), findsOneWidget);
    expect(find.text('Dikte Suara (Speech-to-Text)'), findsOneWidget);
    expect(find.text('Mode Percakapan Suara'), findsOneWidget);
    expect(find.text('Baca Jawaban Terakhir (TTS)'), findsOneWidget);

    await tester.tap(find.text('Dikte Suara (Speech-to-Text)'));
    await tester.pump();
    expect(LabsFlagsService.current.voiceDictation, isTrue);
    expect(tester.takeException(), isNull);
  });
}
