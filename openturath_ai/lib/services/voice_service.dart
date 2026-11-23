import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Satu segmen teks yang sudah dipisahkan bahasanya agar TTS dapat mengganti
/// suara Indonesia/Inggris dan suara Arab secara otomatis.
@immutable
class VoiceSegment {
  const VoiceSegment({
    required this.text,
    required this.isArabic,
  });

  final String text;
  final bool isArabic;

  @override
  bool operator ==(Object other) =>
      other is VoiceSegment &&
      other.text == text &&
      other.isArabic == isArabic;

  @override
  int get hashCode => Object.hash(text, isArabic);

  @override
  String toString() => 'VoiceSegment(ar=$isArabic, "${text.length}ch")';
}

/// Pembersih Markdown & pemisah segmen dwibahasa (Latin vs Arab) untuk TTS.
class VoiceTextSegmenter {
  VoiceTextSegmenter._();

  static final RegExp _arabicChar = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );
  static final RegExp _latinChar = RegExp(r'[A-Za-z0-9]');
  static final RegExp _urlPattern = RegExp(r'https?://\S+');
  static final RegExp _citationPattern = RegExp(r'\[\s*\d+(?:\s*[,–-]\s*\d+)*\s*\]');
  static final RegExp _markdownLinks = RegExp(r'\[([^\]]+)\]\([^)]+\)');
  static final RegExp _markdownTokens = RegExp(r'[*_`#~>|]+');
  static final RegExp _arabicRun = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s\u060C\u061B\u061F\u0640«»"().,:;!?؟،؛-]*'
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  /// Membersihkan format Markdown, sitasi angka `[1]`, dan URL agar nyaman didengar.
  static String cleanForSpeech(String raw) {
    var text = raw;
    text = text.replaceAllMapped(_markdownLinks, (m) => m.group(1) ?? '');
    text = text.replaceAll(_urlPattern, '');
    text = text.replaceAll(_citationPattern, '');
    text = text.replaceAll(_markdownTokens, ' ');
    text = text.replaceAll(RegExp(r'\r\n?'), '\n');
    text = text.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    text = text.replaceAll(RegExp(r'\n{2,}'), '. ');
    text = text.replaceAll('\n', ' ');
    return text.trim();
  }

  /// Memecah teks campuran menjadi urutan [VoiceSegment] Latin dan Arab.
  ///
  /// Bila [skipLongArabic] aktif, blok ibarah Arab panjang (> 240 karakter)
  /// diringkas menjadi isyarat singkat agar mode percakapan tetap lincah.
  static List<VoiceSegment> segment(
    String raw, {
    bool skipLongArabic = false,
    String skippedArabicCue = 'Terdapat kutipan ibarah Arab di layar.',
  }) {
    final cleaned = cleanForSpeech(raw);
    if (cleaned.isEmpty) return const [];

    final rawSegments = <VoiceSegment>[];
    var cursor = 0;

    for (final match in _arabicRun.allMatches(cleaned)) {
      if (match.start > cursor) {
        final before = cleaned.substring(cursor, match.start).trim();
        if (_hasSpeakableChars(before)) {
          rawSegments.add(VoiceSegment(text: before, isArabic: false));
        }
      }
      final arChunk = match.group(0)!.trim();
      if (_hasSpeakableChars(arChunk)) {
        if (skipLongArabic && arChunk.length > 240) {
          rawSegments.add(
            VoiceSegment(text: skippedArabicCue, isArabic: false),
          );
        } else {
          rawSegments.add(VoiceSegment(text: arChunk, isArabic: true));
        }
      }
      cursor = match.end;
    }

    if (cursor < cleaned.length) {
      final tail = cleaned.substring(cursor).trim();
      if (_hasSpeakableChars(tail)) {
        rawSegments.add(VoiceSegment(text: tail, isArabic: false));
      }
    }

    if (rawSegments.isEmpty) {
      return [
        VoiceSegment(
          text: cleaned,
          isArabic: _arabicChar.hasMatch(cleaned) && !_latinChar.hasMatch(cleaned),
        ),
      ];
    }

    // Gabungkan segmen berurutan dengan bahasa sama agar tidak tersendat.
    final merged = <VoiceSegment>[];
    for (final seg in rawSegments) {
      if (merged.isNotEmpty && merged.last.isArabic == seg.isArabic) {
        final prev = merged.removeLast();
        merged.add(VoiceSegment(
          text: '${prev.text} ${seg.text}'.trim(),
          isArabic: prev.isArabic,
        ));
      } else {
        merged.add(seg);
      }
    }
    return merged;
  }

  static bool _hasSpeakableChars(String s) =>
      _arabicChar.hasMatch(s) || _latinChar.hasMatch(s);
}

enum VoiceEngineState { idle, listening, speaking }

/// Layanan terpadu STT (Speech-to-Text) dan TTS dwibahasa (ID/EN + AR)
/// untuk Ruang Eksperimen (OpenTurath Labs).
class VoiceService {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _sttInitialized = false;
  bool _sttAvailable = false;
  bool _ttsConfigured = false;
  int _speakEpoch = 0;

  final ValueNotifier<VoiceEngineState> state =
      ValueNotifier<VoiceEngineState>(VoiceEngineState.idle);

  bool get isListening => state.value == VoiceEngineState.listening;
  bool get isSpeaking => state.value == VoiceEngineState.speaking;

  Future<bool> ensureSttReady() async {
    if (_sttInitialized) return _sttAvailable;
    try {
      _sttAvailable = await _stt.initialize(
        onStatus: (status) {
          if ((status == 'done' || status == 'notListening') &&
              state.value == VoiceEngineState.listening) {
            state.value = VoiceEngineState.idle;
          }
        },
        onError: (_) {
          if (state.value == VoiceEngineState.listening) {
            state.value = VoiceEngineState.idle;
          }
        },
      );
      _sttInitialized = true;
    } catch (_) {
      _sttInitialized = true;
      _sttAvailable = false;
    }
    return _sttAvailable;
  }

  Future<bool> startListening({
    required String localeId,
    required void Function(String recognizedText, bool isFinal) onResult,
    void Function(double level)? onSoundLevel,
    Duration pauseFor = const Duration(seconds: 2),
  }) async {
    await stopSpeaking();
    final ready = await ensureSttReady();
    if (!ready) return false;

    try {
      state.value = VoiceEngineState.listening;
      await _stt.listen(
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          pauseFor: pauseFor,
          listenFor: const Duration(seconds: 45),
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
        onSoundLevelChange: onSoundLevel,
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
          if (result.finalResult && state.value == VoiceEngineState.listening) {
            state.value = VoiceEngineState.idle;
          }
        },
      );
      return true;
    } catch (_) {
      state.value = VoiceEngineState.idle;
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      if (_stt.isListening) {
        await _stt.stop();
      }
    } catch (_) {}
    if (state.value == VoiceEngineState.listening) {
      state.value = VoiceEngineState.idle;
    }
  }

  Future<void> _ensureTtsConfigured() async {
    if (_ttsConfigured) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.50);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ttsConfigured = true;
    } catch (_) {}
  }

  /// Membacakan [rawText] secara berurutan dengan pergantian otomatis antara
  /// suara [primaryLocale] (`id-ID` / `en-US`) dan suara Arab (`ar-SA`).
  Future<void> speakBilingual(
    String rawText, {
    String primaryLocale = 'id-ID',
    bool skipLongArabic = false,
    String skippedArabicCue = 'Terdapat kutipan ibarah Arab di layar.',
    void Function(VoiceSegment segment)? onSegmentStart,
    VoidCallback? onComplete,
  }) async {
    await stopListening();
    await stopSpeaking();

    final segments = VoiceTextSegmenter.segment(
      rawText,
      skipLongArabic: skipLongArabic,
      skippedArabicCue: skippedArabicCue,
    );
    if (segments.isEmpty) {
      onComplete?.call();
      return;
    }

    await _ensureTtsConfigured();
    final epoch = ++_speakEpoch;
    state.value = VoiceEngineState.speaking;

    try {
      for (final seg in segments) {
        if (epoch != _speakEpoch) return;
        onSegmentStart?.call(seg);
        final lang = seg.isArabic ? 'ar-SA' : primaryLocale;
        try {
          await _tts.setLanguage(lang);
        } catch (_) {}
        if (epoch != _speakEpoch) return;
        await _tts.speak(seg.text);
      }
    } catch (_) {
      // Tetap pulih bersih bila mesin TTS platform gagal sementara.
    } finally {
      if (epoch == _speakEpoch) {
        state.value = VoiceEngineState.idle;
        onComplete?.call();
      }
    }
  }

  Future<void> stopSpeaking() async {
    _speakEpoch++;
    try {
      await _tts.stop();
    } catch (_) {}
    if (state.value == VoiceEngineState.speaking) {
      state.value = VoiceEngineState.idle;
    }
  }

  Future<void> stopAll() async {
    await stopListening();
    await stopSpeaking();
  }
}
