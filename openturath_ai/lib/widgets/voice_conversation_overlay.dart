import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../services/labs_flags.dart';
import '../services/voice_service.dart';

enum _ConversationPhase { idle, listening, thinking, speaking }

/// Mode Percakapan Suara (Hands-Free Turn-Based) untuk OpenTurath Labs.
///
/// Siklus: Mendengarkan (STT) → Mengirim ke AI aktif via `window.otSendPrompt`
/// → Menunggu jawaban stabil via `window.otGetLastAnswerState` → Membacakan
/// jawaban dengan TTS dwibahasa (Indonesia/Inggris & Arab terpisah) → Kembali
/// mendengarkan otomatis. Ketuk lingkaran tengah kapan saja untuk menyela.
class VoiceConversationOverlay extends StatefulWidget {
  const VoiceConversationOverlay({
    super.key,
    required this.agentTitle,
    required this.controller,
    required this.onClose,
  });

  final String agentTitle;
  final InAppWebViewController controller;
  final VoidCallback onClose;

  @override
  State<VoiceConversationOverlay> createState() =>
      _VoiceConversationOverlayState();
}

class _VoiceConversationOverlayState extends State<VoiceConversationOverlay>
    with SingleTickerProviderStateMixin {
  final _voice = VoiceService.instance;
  late final AnimationController _pulseController;
  late String _localeId;

  _ConversationPhase _phase = _ConversationPhase.idle;
  String _userTranscript = '';
  String _spokenCaption = '';
  bool _spokenCaptionIsArabic = false;
  String? _errorNote;
  bool _closed = false;
  Timer? _pollTimer;
  int _turnEpoch = 0;

  static const _locales = [
    ('id_ID', 'ID'),
    ('ar_SA', 'AR'),
    ('en_US', 'EN'),
  ];

  @override
  void initState() {
    super.initState();
    _localeId = LabsFlagsService.current.voiceLocale;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _beginListening();
  }

  @override
  void dispose() {
    _closed = true;
    _turnEpoch++;
    _pollTimer?.cancel();
    _pulseController.dispose();
    _voice.stopAll();
    super.dispose();
  }

  void _syncPulse() {
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced || _phase == _ConversationPhase.idle) {
      if (_pulseController.isAnimating) _pulseController.stop();
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  Future<Map<String, dynamic>> _readAnswerState() async {
    try {
      final raw = await widget.controller
          .evaluateJavascript(
              source:
                  'window.otGetLastAnswerState ? window.otGetLastAnswerState() : "{}"')
          .timeout(const Duration(seconds: 3));
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (_) {}
    return const {'count': 0, 'lastAnswer': '', 'isLoading': false};
  }

  Future<void> _beginListening() async {
    if (_closed || !mounted) return;
    _pollTimer?.cancel();
    final epoch = ++_turnEpoch;
    setState(() {
      _phase = _ConversationPhase.listening;
      _userTranscript = '';
      _errorNote = null;
    });
    _syncPulse();

    final ok = await _voice.startListening(
      localeId: _localeId,
      pauseFor: const Duration(seconds: 2),
      onResult: (words, isFinal) {
        if (_closed || !mounted || epoch != _turnEpoch) return;
        setState(() => _userTranscript = words);
        if (isFinal) {
          final clean = words.trim();
          if (clean.isNotEmpty) {
            _sendAndAwaitAnswer(clean, epoch);
          } else {
            setState(() => _phase = _ConversationPhase.idle);
            _syncPulse();
          }
        }
      },
    );

    if (!mounted || _closed || epoch != _turnEpoch) return;
    if (!ok) {
      setState(() {
        _phase = _ConversationPhase.idle;
        _errorNote = Loc.isArabic
            ? 'تعذّر تشغيل الميكروفون على هذا الجهاز.'
            : (Loc.language == 'en'
                ? 'Microphone or speech recognition is unavailable.'
                : 'Mikrofon atau pengenalan suara tidak tersedia di perangkat ini.');
      });
      _syncPulse();
    }
  }

  Future<void> _sendAndAwaitAnswer(String question, int epoch) async {
    if (_closed || !mounted || epoch != _turnEpoch) return;
    await _voice.stopListening();
    if (_closed || !mounted || epoch != _turnEpoch) return;

    setState(() {
      _phase = _ConversationPhase.thinking;
      _spokenCaption = '';
      _errorNote = null;
    });
    _syncPulse();

    final baseline = await _readAnswerState();
    final baselineCount = (baseline['count'] as num?)?.toInt() ?? 0;
    final baselineText = (baseline['lastAnswer'] as String?) ?? '';

    final encoded = jsonEncode(question);
    try {
      final sent = await widget.controller
          .evaluateJavascript(
              source:
                  'window.otSendPrompt ? window.otSendPrompt($encoded) : false')
          .timeout(const Duration(seconds: 3));
      if (sent != true) {
        if (!mounted || _closed || epoch != _turnEpoch) return;
        setState(() {
          _phase = _ConversationPhase.idle;
          _errorNote = Loc.isArabic
              ? 'تعذّر إرسال السؤال إلى المساعد.'
              : (Loc.language == 'en'
                  ? 'Could not send question to the active AI tab.'
                  : 'Belum dapat mengirim pertanyaan ke ruang AI.');
        });
        _syncPulse();
        return;
      }
    } catch (_) {
      if (!mounted || _closed || epoch != _turnEpoch) return;
      setState(() => _phase = _ConversationPhase.idle);
      _syncPulse();
      return;
    }

    var lastObserved = '';
    var stableTicks = 0;
    var elapsedTicks = 0;

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) async {
      if (_closed || !mounted || epoch != _turnEpoch) {
        timer.cancel();
        return;
      }
      elapsedTicks++;
      // Batas sabar 70 detik (100 * 700ms) untuk koneksi lambat.
      if (elapsedTicks > 100) {
        timer.cancel();
        if (mounted && epoch == _turnEpoch) {
          setState(() {
            _phase = _ConversationPhase.idle;
            _errorNote = Loc.isArabic
                ? 'استغرق الرد وقتًا أطول من المعتاد.'
                : (Loc.language == 'en'
                    ? 'The response took longer than expected.'
                    : 'Jawaban memakan waktu lebih lama dari biasanya.');
          });
          _syncPulse();
        }
        return;
      }

      final snap = await _readAnswerState();
      if (_closed || !mounted || epoch != _turnEpoch) {
        timer.cancel();
        return;
      }
      final count = (snap['count'] as num?)?.toInt() ?? 0;
      final answer = (snap['lastAnswer'] as String?) ?? '';
      final isLoading = snap['isLoading'] == true;

      final isNewAnswer = (count > baselineCount && answer.isNotEmpty) ||
          (answer.isNotEmpty && answer != baselineText);

      if (isNewAnswer && !isLoading) {
        if (answer == lastObserved) {
          stableTicks++;
        } else {
          lastObserved = answer;
          stableTicks = 0;
        }
        // Jawaban dianggap selesai setelah 2 siklus (~1.4s) tidak berubah & tidak loading.
        if (stableTicks >= 2) {
          timer.cancel();
          _speakAnswer(answer, epoch);
        }
      }
    });
  }

  Future<void> _speakAnswer(String answer, int epoch) async {
    if (_closed || !mounted || epoch != _turnEpoch) return;
    setState(() => _phase = _ConversationPhase.speaking);
    _syncPulse();

    final primaryLocale =
        _localeId.startsWith('en') ? 'en-US' : 'id-ID';
    final skipLongArabic = LabsFlagsService.current.voiceSkipLongArabic;

    await _voice.speakBilingual(
      answer,
      primaryLocale: primaryLocale,
      skipLongArabic: skipLongArabic,
      onSegmentStart: (seg) {
        if (_closed || !mounted || epoch != _turnEpoch) return;
        setState(() {
          _spokenCaption = seg.text;
          _spokenCaptionIsArabic = seg.isArabic;
        });
      },
      onComplete: () {
        if (_closed || !mounted || epoch != _turnEpoch) return;
        // Lanjut mendengarkan secara otomatis untuk percakapan berkesinambungan.
        _beginListening();
      },
    );
  }

  Future<void> _handleOrbTap() async {
    switch (_phase) {
      case _ConversationPhase.speaking:
        // Barge-in: potong suara AI dan langsung dengarkan pertanyaan baru.
        await _voice.stopSpeaking();
        await _beginListening();
        break;
      case _ConversationPhase.listening:
        final clean = _userTranscript.trim();
        if (clean.isNotEmpty) {
          await _sendAndAwaitAnswer(clean, _turnEpoch);
        } else {
          await _voice.stopListening();
          if (mounted) {
            setState(() => _phase = _ConversationPhase.idle);
            _syncPulse();
          }
        }
        break;
      case _ConversationPhase.thinking:
        _pollTimer?.cancel();
        _turnEpoch++;
        await _beginListening();
        break;
      case _ConversationPhase.idle:
        await _beginListening();
        break;
    }
  }

  Future<void> _selectLocale(String localeId) async {
    if (localeId == _localeId) return;
    await _voice.stopAll();
    setState(() => _localeId = localeId);
    await LabsFlagsService.update(
      LabsFlagsService.current.copyWith(voiceLocale: localeId),
    );
    if (mounted) await _beginListening();
  }

  String _phaseLabel() {
    final isAr = Loc.isArabic;
    final isEn = Loc.language == 'en';
    switch (_phase) {
      case _ConversationPhase.listening:
        return isAr
            ? 'جارٍ الاستماع…'
            : (isEn ? 'Listening…' : 'Mendengarkan…');
      case _ConversationPhase.thinking:
        return isAr
            ? 'جارٍ البحث في الكتب…'
            : (isEn ? 'Searching references…' : 'Menelaah kitab rujukan…');
      case _ConversationPhase.speaking:
        return isAr
            ? 'يتحدث الآن · اضغط للمقاطعة'
            : (isEn
                ? 'Speaking · tap to interrupt'
                : 'Membacakan · ketuk untuk menyela');
      case _ConversationPhase.idle:
        return isAr
            ? 'اضغط للتحدث'
            : (isEn ? 'Tap to speak' : 'Ketuk untuk berbicara');
    }
  }

  IconData _phaseIcon() {
    switch (_phase) {
      case _ConversationPhase.listening:
        return Icons.mic_rounded;
      case _ConversationPhase.thinking:
        return Icons.more_horiz_rounded;
      case _ConversationPhase.speaking:
        return Icons.graphic_eq_rounded;
      case _ConversationPhase.idle:
        return Icons.mic_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(dark);
    final surface = OTColors.surface(dark);
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);
    final subtle = OTColors.surfaceSubtle(dark);

    final activeCaption = _phase == _ConversationPhase.speaking &&
            _spokenCaption.isNotEmpty
        ? _spokenCaption
        : _userTranscript;

    return Material(
      color: canvas,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OTSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LABS · MODE PERCAKAPAN',
                          style: OTTypography.metadataTag(color: muted),
                        ),
                        const SizedBox(height: OTSpacing.xs),
                        Text(
                          widget.agentTitle,
                          style: OTTypography.cardTitle(color: ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: Loc.tr('close'),
                    onPressed: () {
                      _voice.stopAll();
                      widget.onClose();
                    },
                    icon: Icon(Icons.close_rounded, color: ink),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: _handleOrbTap,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final active = _phase != _ConversationPhase.idle;
                      final ringScale =
                          active ? 1.0 + (_pulseController.value * 0.14) : 1.0;
                      return SizedBox(
                        width: 176,
                        height: 176,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: ringScale,
                              child: Container(
                                width: 156,
                                height: 156,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ink.withValues(
                                      alpha: active ? 0.06 : 0.03),
                                  border: Border.all(
                                    color: ink.withValues(
                                        alpha: active ? 0.18 : 0.10),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _phase == _ConversationPhase.listening ||
                                        _phase == _ConversationPhase.speaking
                                    ? ink
                                    : surface,
                                border: Border.all(color: ink, width: 1.5),
                              ),
                              child: Icon(
                                _phaseIcon(),
                                size: 36,
                                color: _phase == _ConversationPhase.listening ||
                                        _phase == _ConversationPhase.speaking
                                    ? OTColors.onInverted(dark)
                                    : ink,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: OTSpacing.lg),
              Text(
                _phaseLabel(),
                textAlign: TextAlign.center,
                style: OTTypography.bodyMedium(color: ink),
              ),
              const SizedBox(height: OTSpacing.base),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 72, maxHeight: 160),
                child: SingleChildScrollView(
                  child: Text(
                    _errorNote ?? activeCaption,
                    textAlign: TextAlign.center,
                    textDirection: _spokenCaptionIsArabic &&
                            _phase == _ConversationPhase.speaking
                        ? TextDirection.rtl
                        : null,
                    style: _errorNote != null
                        ? OTTypography.caption(color: OTColors.destructive(dark))
                        : OTTypography.body(color: muted).copyWith(height: 1.55),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(OTSpacing.xs),
                    decoration: BoxDecoration(
                      color: subtle,
                      borderRadius: BorderRadius.circular(OTRadius.xs),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final (code, shortLabel) in _locales)
                          InkWell(
                            onTap: () => _selectLocale(code),
                            borderRadius: BorderRadius.circular(OTRadius.xs),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: OTSpacing.sm,
                                vertical: OTSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: _localeId == code ? ink : null,
                                borderRadius:
                                    BorderRadius.circular(OTRadius.xs),
                              ),
                              child: Text(
                                shortLabel,
                                style: OTTypography.metadataTag(
                                  color: _localeId == code
                                      ? OTColors.onInverted(dark)
                                      : muted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _voice.stopAll();
                      widget.onClose();
                    },
                    child: Text(Loc.tr('close')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
