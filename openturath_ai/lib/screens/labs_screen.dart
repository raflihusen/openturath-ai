import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../services/labs_flags.dart';
import '../services/voice_service.dart';

/// Ruang Eksperimen (OpenTurath Labs): tempat menguji fitur baru seperti
/// Speech-to-Text, Baca Jawaban Dwibahasa, dan Mode Percakapan Suara tanpa
/// memengaruhi perilaku bawaan aplikasi stabil.
class LabsScreen extends StatefulWidget {
  const LabsScreen({super.key});

  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  final _voice = VoiceService.instance;
  String _sandboxTranscript = '';
  bool _sandboxListening = false;
  bool _sandboxSpeaking = false;
  String? _sandboxStatus;

  static const _sampleBilingualText =
      'Menurut Imam al-Nawawi dalam al-Majmu\', niat adalah syarat sah ibadah. '
      'قال الإمام النووي رحمه الله: إنما الأعمال بالنيات، ولكل امرئ ما نوى. '
      'Penjelasan ini menjadi kaidah dasar dalam fikih ibadah.';

  static const _locales = [
    ('id_ID', 'Indonesia'),
    ('ar_SA', 'العربية'),
    ('en_US', 'English'),
  ];

  @override
  void initState() {
    super.initState();
    LabsFlagsService.load();
  }

  @override
  void dispose() {
    _voice.stopAll();
    super.dispose();
  }

  Future<void> _toggleSandboxStt(LabsFlags flags) async {
    if (_sandboxListening) {
      await _voice.stopListening();
      if (mounted) setState(() => _sandboxListening = false);
      return;
    }
    setState(() {
      _sandboxListening = true;
      _sandboxStatus = null;
      _sandboxTranscript = '';
    });
    final ok = await _voice.startListening(
      localeId: flags.voiceLocale,
      pauseFor: const Duration(seconds: 3),
      onResult: (words, isFinal) {
        if (!mounted) return;
        setState(() {
          _sandboxTranscript = words;
          if (isFinal) _sandboxListening = false;
        });
      },
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _sandboxListening = false;
        _sandboxStatus =
            'Pengenalan suara tidak tersedia atau izin mikrofon ditolak.';
      });
    }
  }

  Future<void> _toggleSandboxTts(LabsFlags flags) async {
    if (_sandboxSpeaking) {
      await _voice.stopSpeaking();
      if (mounted) setState(() => _sandboxSpeaking = false);
      return;
    }
    setState(() {
      _sandboxSpeaking = true;
      _sandboxStatus = null;
    });
    await _voice.speakBilingual(
      _sampleBilingualText,
      primaryLocale: flags.voiceLocale.startsWith('en') ? 'en-US' : 'id-ID',
      skipLongArabic: flags.voiceSkipLongArabic,
      onComplete: () {
        if (mounted) setState(() => _sandboxSpeaking = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(dark);
    final surface = OTColors.surface(dark);
    final subtle = OTColors.surfaceSubtle(dark);
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: const Text('Ruang Eksperimen'),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<LabsFlags>(
          valueListenable: LabsFlagsService.notifier,
          builder: (context, flags, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                OTSpacing.lg,
                OTSpacing.sm,
                OTSpacing.lg,
                OTSpacing.xxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(OTSpacing.base),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(OTRadius.card),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: OTSpacing.sm,
                                vertical: OTSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: OTColors.inverted(dark),
                                borderRadius:
                                    BorderRadius.circular(OTRadius.xs),
                              ),
                              child: Text(
                                'OPENTURATH LABS',
                                style: OTTypography.metadataTag(
                                  color: OTColors.onInverted(dark),
                                ),
                              ),
                            ),
                            const SizedBox(height: OTSpacing.md),
                            Text(
                              'Area uji coba terisolasi untuk fitur baru sebelum masuk ke rilis utama. Semua saklar di bawah nonaktif secara bawaan.',
                              style: OTTypography.body(color: muted)
                                  .copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: OTSpacing.lg),
                      Text(
                        'FITUR SUARA & PERCAKAPAN',
                        style: OTTypography.metadataTag(color: muted),
                      ),
                      const SizedBox(height: OTSpacing.sm),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(OTRadius.card),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: flags.voiceDictation,
                              onChanged: (v) => LabsFlagsService.update(
                                flags.copyWith(voiceDictation: v),
                              ),
                              title: Text(
                                'Dikte Suara (Speech-to-Text)',
                                style: OTTypography.bodyMedium(color: ink),
                              ),
                              subtitle: Text(
                                'Tampilkan tombol mikrofon di Ruang AI untuk mendikte pertanyaan ke kolom teks.',
                                style: OTTypography.caption(color: muted),
                              ),
                            ),
                            Divider(height: 1, color: border),
                            SwitchListTile(
                              value: flags.voiceConversation,
                              onChanged: (v) => LabsFlagsService.update(
                                flags.copyWith(voiceConversation: v),
                              ),
                              title: Text(
                                'Mode Percakapan Suara',
                                style: OTTypography.bodyMedium(color: ink),
                              ),
                              subtitle: Text(
                                'Percakapan hands-free: bicara, kirim ke AI, dengarkan jawaban dwibahasa, dan ketuk untuk menyela.',
                                style: OTTypography.caption(color: muted),
                              ),
                            ),
                            Divider(height: 1, color: border),
                            SwitchListTile(
                              value: flags.voiceReadAloud,
                              onChanged: (v) => LabsFlagsService.update(
                                flags.copyWith(voiceReadAloud: v),
                              ),
                              title: Text(
                                'Baca Jawaban Terakhir (TTS)',
                                style: OTTypography.bodyMedium(color: ink),
                              ),
                              subtitle: Text(
                                'Tombol speaker di Ruang AI untuk membacakan jawaban terakhir dengan pemisah bahasa Indonesia & Arab.',
                                style: OTTypography.caption(color: muted),
                              ),
                            ),
                            Divider(height: 1, color: border),
                            SwitchListTile(
                              value: flags.voiceSkipLongArabic,
                              onChanged: (v) => LabsFlagsService.update(
                                flags.copyWith(voiceSkipLongArabic: v),
                              ),
                              title: Text(
                                'Ringkas Ibarah Arab Panjang',
                                style: OTTypography.bodyMedium(color: ink),
                              ),
                              subtitle: Text(
                                'Lewati pembacaan kutipan Arab di atas 240 karakter agar percakapan suara tetap cepat.',
                                style: OTTypography.caption(color: muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: OTSpacing.lg),
                      Text(
                        'PENGUJI LANGSUNG (SANDBOX)',
                        style: OTTypography.metadataTag(color: muted),
                      ),
                      const SizedBox(height: OTSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(OTSpacing.base),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(OTRadius.card),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              spacing: OTSpacing.sm,
                              runSpacing: OTSpacing.sm,
                              children: [
                                for (final (code, label) in _locales)
                                  ChoiceChip(
                                    label: Text(label),
                                    selected: flags.voiceLocale == code,
                                    onSelected: (_) => LabsFlagsService.update(
                                      flags.copyWith(voiceLocale: code),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: OTSpacing.base),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => _toggleSandboxStt(flags),
                                    icon: Icon(
                                      _sandboxListening
                                          ? Icons.stop_rounded
                                          : Icons.mic_none_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      _sandboxListening
                                          ? 'Berhenti'
                                          : 'Uji Dikte',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: OTSpacing.md),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _toggleSandboxTts(flags),
                                    icon: Icon(
                                      _sandboxSpeaking
                                          ? Icons.stop_rounded
                                          : Icons.volume_up_outlined,
                                      size: 18,
                                    ),
                                    label: Text(
                                      _sandboxSpeaking
                                          ? 'Hentikan'
                                          : 'Uji Suara ID+AR',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_sandboxTranscript.isNotEmpty) ...[
                              const SizedBox(height: OTSpacing.base),
                              Container(
                                padding: const EdgeInsets.all(OTSpacing.md),
                                decoration: BoxDecoration(
                                  color: subtle,
                                  borderRadius:
                                      BorderRadius.circular(OTRadius.xs),
                                ),
                                child: Text(
                                  _sandboxTranscript,
                                  style: OTTypography.body(color: ink),
                                ),
                              ),
                            ],
                            if (_sandboxStatus != null) ...[
                              const SizedBox(height: OTSpacing.sm),
                              Text(
                                _sandboxStatus!,
                                style: OTTypography.caption(
                                  color: OTColors.destructive(dark),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (flags.anyVoiceEnabled) ...[
                        const SizedBox(height: OTSpacing.base),
                        const Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: LabsFlagsService.resetAll,
                            child: Text('Matikan semua eksperimen'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
