import 'dart:async';

import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import 'tahawwulat_hero.dart' show reviewCopy;

/// Penahan setelah akses diberikan (pembayaran atau voucher). Pemberian akses
/// di server perlu beberapa detik, jadi pengguna ditahan [seconds] detik
/// dengan petunjuk pemakaian alih-alih langsung membuka AI yang belum siap.
/// [builder] menerima status selesai menunggu (`done`), sisa detik, panel
/// progres + petunjuk, dan `ready`.
///
/// `done` hanya berarti waktu tunggu habis (dialog boleh ditutup). Akses baru
/// boleh dinyatakan siap bila `ready` true: server mengonfirmasinya lewat
/// [isReady]. Tanpa pemeriksaan, habisnya waktu hanya mengizinkan dialog ditutup.
class AccessPrepareGate extends StatefulWidget {
  const AccessPrepareGate(
      {super.key,
      required this.builder,
      this.seconds = 30,
      this.isReady,
      this.minSeconds = 8});

  final Widget Function(
          BuildContext context, bool done, int left, Widget panel, bool ready)
      builder;
  final int seconds;

  /// Bila diberikan, dipanggil tiap 3 detik; begitu mengembalikan true dan
  /// [minSeconds] sudah lewat, penahan dilepas lebih awal. Galat atau false
  /// berarti terus menunggu sampai [seconds] habis, lalu `done` true tetapi
  /// `ready` tetap false.
  final Future<bool> Function()? isReady;
  final int minSeconds;

  static const int defaultSeconds = 30;

  @override
  State<AccessPrepareGate> createState() => _AccessPrepareGateState();
}

class _AccessPrepareGateState extends State<AccessPrepareGate> {
  late int _left = widget.seconds;
  Timer? _timer;
  bool _ready = false, _polling = false;

  Future<void> _poll() async {
    final check = widget.isReady;
    if (check == null || _polling || _ready) return;
    _polling = true;
    try {
      final ready = await check();
      if (!mounted) return;
      setState(() {
        _ready = ready;
        if (_ready && widget.seconds - _left >= widget.minSeconds) {
          _left = 0;
          _timer?.cancel();
        }
      });
    } catch (_) {
      // Pemeriksaan gagal tidak mengubah status yang telah dikonfirmasi.
    } finally {
      _polling = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      final elapsed = widget.seconds - _left + 1;
      if (elapsed % 3 == 0) _poll();
      setState(() {
        _left = (_left - 1).clamp(0, widget.seconds);
        if (_ready && elapsed >= widget.minSeconds) _left = 0;
      });
      if (_left == 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<(IconData, String, String)> get _tips => [
        (
          Icons.auto_awesome_outlined,
          reviewCopy(
              'Adab Menggunakan AI · Luruskan Niat',
              'آداب استخدام الذكاء الاصطناعي · إخلاص النية',
              'AI Etiquette · Sincere Intention'),
          reviewCopy(
              'Mulailah dengan basmalah dan niatkan mencari ilmu karena Allah. Jadikan AI sebagai alat bantu belajar, bukan tujuan.',
              'ابدأ بالبسملة وانوِ طلب العلم لله تعالى، واجعل الذكاء الاصطناعي وسيلة مساعدة في البحث والتعلم.',
              'Begin with Bismillah and seek knowledge sincerely. Treat AI as a study companion, not an end in itself.')
        ),
        (
          Icons.forum_outlined,
          reviewCopy(
              'Adab Menggunakan AI · Bertanya dengan Jelas',
              'آداب استخدام الذكاء الاصطناعي · وضوح السؤال',
              'AI Etiquette · Ask Clearly'),
          reviewCopy(
              'Sampaikan pertanyaan secara ringkas, sopan, dan fokus pada pokok masalah agar jawaban tepat sasaran dan tidak membuang waktu.',
              'اطرح سؤالك بوضوح وأدب وتركيز على محل البحث، لتحصل على جواب دقيق وتوفّر وقتك.',
              'Ask concise, respectful, and focused questions so answers stay accurate and save your time.')
        ),
        (
          Icons.menu_book_outlined,
          reviewCopy(
              'Adab Menggunakan AI · Periksa Kitab Asli',
              'آداب استخدام الذكاء الاصطناعي · التحقق من المصدر',
              'AI Etiquette · Verify the Primary Text'),
          reviewCopy(
              'Selalu verifikasi ibarah Arab, nama kitab, jilid, dan halaman rujukan yang ditampilkan sebelum mengutip atau menyebarkan.',
              'تحقّق دائمًا من العبارة العربية واسم الكتاب والجزء والصفحة قبل النقل أو النشر.',
              'Always verify the Arabic passage, book title, volume, and page reference before quoting or sharing.')
        ),
        (
          Icons.school_outlined,
          reviewCopy(
              'Adab Menggunakan AI · Bukan Pengganti Guru',
              'آداب استخدام الذكاء الاصطناعي · ليس بديلاً عن العالم',
              'AI Etiquette · Not a Replacement for Teachers'),
          reviewCopy(
              'AI adalah bahan telaah awal, bukan mufti atau fatwa. Untuk urusan amalan dan hukum praktis, tetap tanyakan kepada guru yang bersanad.',
              'الذكاء الاصطناعي أداة مساعدة للدرس وليس مفتيًا؛ وفي أمور العمل والفتوى ارجع إلى أهل العلم المسنَدين.',
              'AI is a study aid, not a fatwa. For matters of practice and rulings, consult qualified teachers.')
        ),
        (
          Icons.verified_user_outlined,
          reviewCopy(
              'Adab Menggunakan AI · Jaga Amanah Ilmiah',
              'آداب استخدام الذكاء الاصطناعي · الأمانة العلمية',
              'AI Etiquette · Scholarly Integrity'),
          reviewCopy(
              'Gunakan hasil telaah untuk memperdalam pemahaman dan beramal, bukan untuk berdebat kusir atau menisbatkan kutipan tanpa tabayyun.',
              'استفد من الإجابات لتعميق الفهم والعمل، لا للجدال أو نسبة الأقوال دون تثبّت.',
              'Use findings to deepen understanding and practice, never for idle debate or unverified attribution.')
        ),
      ];

  Widget _panel(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    final elapsed = widget.seconds - _left;
    final tips = _tips;
    final tip = tips[(elapsed ~/ 6) % tips.length];
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ClipRRect(
        borderRadius: OTRadius.chipBorder,
        child: LinearProgressIndicator(
          value: elapsed / widget.seconds,
          minHeight: 6,
          color: ink,
          backgroundColor: OTColors.border(dark),
        ),
      ),
      const SizedBox(height: 16),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: Container(
          key: ValueKey(tip.$2),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: OTColors.surfaceSubtle(dark),
              borderRadius: OTRadius.cardBorder),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(tip.$1, size: 22, color: ink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.$2, style: OTTypography.cardTitle(color: ink)),
                    const SizedBox(height: 4),
                    Text(tip.$3,
                        style: OTTypography.caption(color: muted)
                            .copyWith(height: 1.5)),
                  ]),
            ),
          ]),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) => widget.builder(
      context, _left == 0, _left, _panel(context), _left == 0 && _ready);
}
