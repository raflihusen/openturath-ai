import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saklar fitur eksperimental (OpenTurath Labs).
///
/// Seluruh fitur di sini MATI secara bawaan agar tidak memengaruhi jalur
/// aplikasi stabil. Pengguna dapat mengaktifkannya secara sukarela dari
/// Pengaturan → Ruang Eksperimen (Labs).
@immutable
class LabsFlags {
  const LabsFlags({
    this.voiceDictation = false,
    this.voiceConversation = false,
    this.voiceReadAloud = false,
    this.voiceSkipLongArabic = false,
    this.voiceLocale = 'id_ID',
  });

  final bool voiceDictation;
  final bool voiceConversation;
  final bool voiceReadAloud;
  final bool voiceSkipLongArabic;
  final String voiceLocale;

  static const defaults = LabsFlags();

  bool get anyVoiceEnabled =>
      voiceDictation || voiceConversation || voiceReadAloud;

  LabsFlags copyWith({
    bool? voiceDictation,
    bool? voiceConversation,
    bool? voiceReadAloud,
    bool? voiceSkipLongArabic,
    String? voiceLocale,
  }) {
    return LabsFlags(
      voiceDictation: voiceDictation ?? this.voiceDictation,
      voiceConversation: voiceConversation ?? this.voiceConversation,
      voiceReadAloud: voiceReadAloud ?? this.voiceReadAloud,
      voiceSkipLongArabic: voiceSkipLongArabic ?? this.voiceSkipLongArabic,
      voiceLocale: voiceLocale ?? this.voiceLocale,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LabsFlags &&
      other.voiceDictation == voiceDictation &&
      other.voiceConversation == voiceConversation &&
      other.voiceReadAloud == voiceReadAloud &&
      other.voiceSkipLongArabic == voiceSkipLongArabic &&
      other.voiceLocale == voiceLocale;

  @override
  int get hashCode => Object.hash(
        voiceDictation,
        voiceConversation,
        voiceReadAloud,
        voiceSkipLongArabic,
        voiceLocale,
      );
}

class LabsFlagsService {
  LabsFlagsService._();

  static const _kDictation = 'ot_labs_voice_dictation_v1';
  static const _kConversation = 'ot_labs_voice_conversation_v1';
  static const _kReadAloud = 'ot_labs_voice_read_aloud_v1';
  static const _kSkipLongArabic = 'ot_labs_voice_skip_long_arabic_v1';
  static const _kLocale = 'ot_labs_voice_locale_v1';

  static LabsFlags _current = LabsFlags.defaults;
  static bool _loaded = false;

  static final ValueNotifier<LabsFlags> notifier =
      ValueNotifier<LabsFlags>(LabsFlags.defaults);

  static LabsFlags get current => _current;

  static Future<LabsFlags> load() async {
    if (_loaded) return _current;
    try {
      final prefs = await SharedPreferences.getInstance();
      final next = LabsFlags(
        voiceDictation: prefs.getBool(_kDictation) ?? false,
        voiceConversation: prefs.getBool(_kConversation) ?? false,
        voiceReadAloud: prefs.getBool(_kReadAloud) ?? false,
        voiceSkipLongArabic: prefs.getBool(_kSkipLongArabic) ?? false,
        voiceLocale: prefs.getString(_kLocale) ?? 'id_ID',
      );
      _loaded = true;
      _apply(next);
    } catch (_) {
      _loaded = true;
    }
    return _current;
  }

  static Future<void> update(LabsFlags next) async {
    _loaded = true;
    _apply(next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDictation, next.voiceDictation);
      await prefs.setBool(_kConversation, next.voiceConversation);
      await prefs.setBool(_kReadAloud, next.voiceReadAloud);
      await prefs.setBool(_kSkipLongArabic, next.voiceSkipLongArabic);
      await prefs.setString(_kLocale, next.voiceLocale);
    } catch (_) {}
  }

  static Future<void> resetAll() => update(LabsFlags.defaults);

  @visibleForTesting
  static void resetForTest([LabsFlags? value]) {
    _loaded = true;
    _current = value ?? LabsFlags.defaults;
    notifier.value = _current;
  }

  static void _apply(LabsFlags next) {
    if (next == _current) return;
    _current = next;
    notifier.value = next;
  }
}
