import 'dart:async';

import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import 'tahawwulat_hero.dart' show reviewCopy;

/// Penahan setelah akses diberikan (pembayaran atau voucher). Pemberian akses
/// di server perlu beberapa detik, jadi pengguna ditahan [seconds] detik
/// dengan petunjuk pemakaian alih-alih langsung membuka AI yang belum siap.
/// [builder] menerima status selesai, sisa detik, dan panel progres + petunjuk.
class AccessPrepareGate extends StatefulWidget {
  const AccessPrepareGate(
      {super.key, required this.builder, this.seconds = 30});

  final Widget Function(BuildContext context, bool done, int left, Widget panel)
      builder;
  final int seconds;

  static const int defaultSeconds = 30;

  @override
  State<AccessPrepareGate> createState() => _AccessPrepareGateState();
}

class _AccessPrepareGateState extends State<AccessPrepareGate> {
  late int _left = widget.seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _left = (_left - 1).clamp(0, widget.seconds));
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
          Icons.chat_bubble_outline_rounded,
          reviewCopy(
              'Contoh pertanyaan', 'مثال على سؤال', 'An example question'),
          reviewCopy(
              '“Apa bedanya waktu Kiamat dan tanda-tandanya?” Tulis dengan bahasa sehari-hari, OpenTurath menjawab lalu menunjukkan teks aslinya.',
              '«ما الفرق بين وقت الساعة وعلاماتها؟» اكتب بلغتك اليومية، فيجيبك OpenTurath ثم يعرض لك النص الأصلي.',
              '“What is the difference between the time of the Hour and its signs?” Write in everyday language; OpenTurath answers, then shows the original text.')
        ),
        (
          Icons.menu_book_outlined,
          reviewCopy(
              'Periksa sumbernya', 'تحقّق من المصدر', 'Check the source'),
          reviewCopy(
              'Setiap jawaban disertai ibarah asli dan rujukan kitab, jilid, dan halaman bila tersedia.',
              'كل جواب مصحوب بالعبارة الأصلية ومرجعها من الكتاب والجزء والصفحة عند توفرها.',
              'Every answer comes with the original passage and a reference to book, volume and page where available.')
        ),
        (
          Icons.translate_rounded,
          reviewCopy('Bahasa jawaban', 'لغة الجواب', 'Answer language'),
          reviewCopy(
              'Ubah bahasa jawaban lewat menu titik tiga di pojok kanan atas ruang percakapan.',
              'غيّر لغة الجواب من قائمة النقاط الثلاث في أعلى غرفة المحادثة.',
              'Change the answer language from the three-dot menu at the top right of the chat.')
        ),
        (
          Icons.library_books_outlined,
          reviewCopy('Daftar kitab rujukan', 'قائمة الكتب المرجعية',
              'The reference books'),
          reviewCopy(
              'Ketuk ikon buku di bagian atas untuk melihat kitab-kitab yang menjadi sumber AI ini.',
              'اضغط أيقونة الكتاب في الأعلى لترى الكتب التي يستند إليها هذا المساعد.',
              'Tap the book icon at the top to see the books this AI draws from.')
        ),
        (
          Icons.school_outlined,
          reviewCopy('Bahan belajar, bukan fatwa', 'مادة للدراسة وليست فتوى',
              'A study aid, not a fatwa'),
          reviewCopy(
              'Untuk urusan amalan, tetap tanyakan kepada guru Anda yang bersanad.',
              'وفي أمور العمل اسأل معلّمك صاحب السند.',
              'For matters of practice, always ask your teacher with a chain of transmission.')
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
  Widget build(BuildContext context) =>
      widget.builder(context, _left == 0, _left, _panel(context));
}
