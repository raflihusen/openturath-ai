import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../services/labs_flags.dart';
import '../services/voice_service.dart';
import 'adaptive_sheet.dart';

enum VoiceDictationAction { insertDraft, sendNow }

@immutable
class VoiceDictationResult {
  const VoiceDictationResult({
    required this.text,
    required this.action,
  });

  final String text;
  final VoiceDictationAction action;
}

/// Lembar Dikte Suara (Speech-to-Text) bergaya Monochrome Editorial untuk
/// OpenTurath Labs. Pengguna dapat berbicara dalam Indonesia, Arab, atau Inggris,
/// meninjau transkrip, lalu memasukkan ke kolom pertanyaan atau mengirim langsung.
class VoiceDictationSheet extends StatefulWidget {
  const VoiceDictationSheet({super.key});

  static Future<VoiceDictationResult?> show(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return showAdaptiveSheet<VoiceDictationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OTColors.surface(dark),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(OTRadius.sheet)),
      ),
      builder: (_) => const VoiceDictationSheet(),
    );
  }

  @override
  State<VoiceDictationSheet> createState() => _VoiceDictationSheetState();
}

class _VoiceDictationSheetState extends State<VoiceDictationSheet> {
  final TextEditingController _controller = TextEditingController();
  final _voice = VoiceService.instance;
  late String _localeId;
  bool _listening = false;
  String? _statusNote;

  static const _locales = [
    ('id_ID', 'ID'),
    ('ar_SA', 'AR'),
    ('en_US', 'EN'),
  ];

  @override
  void initState() {
    super.initState();
    _localeId = LabsFlagsService.current.voiceLocale;
    _startDictation();
  }

  @override
  void dispose() {
    _voice.stopListening();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startDictation() async {
    setState(() {
      _listening = true;
      _statusNote = null;
    });
    final ok = await _voice.startListening(
      localeId: _localeId,
      pauseFor: const Duration(seconds: 3),
      onResult: (words, isFinal) {
        if (!mounted) return;
        setState(() {
          _controller.text = words;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
          if (isFinal) _listening = false;
        });
      },
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _listening = false;
        _statusNote = Loc.isArabic
            ? 'تعذّر تفعيل الميكروفون أو خدمة التعرف على الصوت على هذا الجهاز.'
            : (Loc.language == 'en'
                ? 'Microphone or speech recognition is unavailable on this device.'
                : 'Mikrofon atau layanan pengenalan suara belum tersedia di perangkat ini.');
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _voice.stopListening();
      if (mounted) setState(() => _listening = false);
    } else {
      await _startDictation();
    }
  }

  Future<void> _selectLocale(String localeId) async {
    if (localeId == _localeId) return;
    await _voice.stopListening();
    setState(() {
      _localeId = localeId;
      _listening = false;
    });
    await LabsFlagsService.update(
      LabsFlagsService.current.copyWith(voiceLocale: localeId),
    );
    if (mounted) await _startDictation();
  }

  void _finish(VoiceDictationAction action) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _voice.stopListening();
    Navigator.of(context).pop(VoiceDictationResult(text: text, action: action));
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);
    final subtle = OTColors.surfaceSubtle(dark);
    final hasText = _controller.text.trim().isNotEmpty;
    final isAr = Loc.isArabic;
    final isEn = Loc.language == 'en';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          OTSpacing.xl,
          OTSpacing.base,
          OTSpacing.xl,
          MediaQuery.viewInsetsOf(context).bottom + OTSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetGrabber(top: 0, bottom: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr
                            ? 'الإملاء الصوتي'
                            : (isEn ? 'Voice dictation' : 'Dikte suara'),
                        style: OTTypography.cardTitle(color: ink),
                      ),
                      const SizedBox(height: OTSpacing.xs),
                      Text(
                        _listening
                            ? (isAr
                                ? 'جارٍ الاستماع… تحدث بوضوح'
                                : (isEn
                                    ? 'Listening… speak clearly'
                                    : 'Mendengarkan… silakan berbicara'))
                            : (isAr
                                ? 'راجع النص أو اضغط الميكروفون للمتابعة'
                                : (isEn
                                    ? 'Review text or tap microphone to continue'
                                    : 'Tinjau teks atau ketuk mikrofon untuk lanjut')),
                        style: OTTypography.caption(color: muted),
                      ),
                    ],
                  ),
                ),
                // Pilihan bahasa dikte (ID / AR / EN)
                Container(
                  padding: const EdgeInsets.all(OTSpacing.xs),
                  decoration: BoxDecoration(
                    color: subtle,
                    borderRadius: BorderRadius.circular(OTRadius.xs),
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
                              borderRadius: BorderRadius.circular(OTRadius.xs),
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
              ],
            ),
            const SizedBox(height: OTSpacing.base),
            TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 2,
              textDirection:
                  _localeId.startsWith('ar') ? TextDirection.rtl : null,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: isAr
                    ? 'سيظهر كلامك هنا…'
                    : (isEn
                        ? 'Your spoken question appears here…'
                        : 'Hasil ucapan Anda akan muncul di sini…'),
              ),
            ),
            if (_statusNote != null) ...[
              const SizedBox(height: OTSpacing.sm),
              Text(
                _statusNote!,
                style: OTTypography.caption(color: OTColors.destructive(dark)),
              ),
            ],
            const SizedBox(height: OTSpacing.lg),
            Center(
              child: Semantics(
                button: true,
                label: _listening ? 'Hentikan rekaman' : 'Mulai dikte suara',
                child: InkWell(
                  onTap: _toggleListening,
                  borderRadius: OTRadius.chipBorder,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _listening ? ink : subtle,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _listening ? ink : border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _listening ? Icons.stop_rounded : Icons.mic_none_rounded,
                      size: 28,
                      color: _listening ? OTColors.onInverted(dark) : ink,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: OTSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: hasText
                        ? () => _finish(VoiceDictationAction.insertDraft)
                        : null,
                    child: Text(
                      isAr
                          ? 'إدراج في الحقل'
                          : (isEn ? 'Insert draft' : 'Isi ke kolom'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: OTSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: hasText
                        ? () => _finish(VoiceDictationAction.sendNow)
                        : null,
                    child: Text(
                      isAr
                          ? 'إرسال الآن'
                          : (isEn ? 'Send now' : 'Kirim sekarang'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
