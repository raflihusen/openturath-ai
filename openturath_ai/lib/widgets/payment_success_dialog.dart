import 'dart:async';

import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/product_pricing.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import 'tahawwulat_hero.dart';

/// Shown only after the checkout confirms the paid invoice, never on redirect alone.
class PaymentSuccessDialog extends StatefulWidget {
  const PaymentSuccessDialog(
      {super.key,
      required this.plan,
      required this.invoice,
      required this.amount,
      this.agent});
  final String plan, invoice;
  final int amount;
  final AgentModel? agent;
  static Future<void> show(BuildContext context,
          {required String plan,
          required String invoice,
          required int amount,
          AgentModel? agent}) =>
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PaymentSuccessDialog(
              plan: plan, invoice: invoice, amount: amount, agent: agent));

  /// Lama menunggu sebelum tombol aktif: pemberian akses di server perlu
  /// waktu setelah pembayaran terkonfirmasi, jadi layar ini menahan pengguna
  /// dengan petunjuk pemakaian alih-alih langsung membuka AI yang belum siap.
  static const int prepareSeconds = 30;

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog> {
  int _left = PaymentSuccessDialog.prepareSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() =>
          _left = (_left - 1).clamp(0, PaymentSuccessDialog.prepareSeconds));
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

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    final done = _left == 0;
    final elapsed = PaymentSuccessDialog.prepareSeconds - _left;
    final tips = _tips;
    final tip = tips[(elapsed ~/ 6) % tips.length];
    final agent = widget.agent;
    return PopScope(
      canPop: done,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
                tween: Tween(begin: .8, end: 1),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 360),
                curve: Curves.easeOutBack,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        color: ink, borderRadius: OTRadius.cardBorder),
                    child: Icon(Icons.check_rounded,
                        size: 36, color: OTColors.canvas(dark)))),
            const SizedBox(height: 16),
            Text(
                reviewCopy('Pembayaran berhasil', 'تم الدفع بنجاح',
                    'Payment successful'),
                textAlign: TextAlign.center,
                style: OTTypography.screenTitle(color: ink)),
            const SizedBox(height: 8),
            Text(widget.plan,
                textAlign: TextAlign.center,
                style: OTTypography.body(color: muted)),
            const SizedBox(height: 20),
            Text(
                done
                    ? reviewCopy('Akses Anda sudah siap.', 'أصبح وصولك جاهزًا.',
                        'Your access is ready.')
                    : reviewCopy(
                        'Akses sedang disiapkan. Mohon tunggu sebentar dan tidak perlu membayar lagi.',
                        'يجري تجهيز وصولك. يُرجى الانتظار قليلًا ولا حاجة للدفع مرة أخرى.',
                        'Your access is being prepared. Please wait a moment; there is no need to pay again.'),
                textAlign: TextAlign.center,
                style: OTTypography.bodyMedium(color: ink)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: OTRadius.chipBorder,
              child: LinearProgressIndicator(
                value: elapsed / PaymentSuccessDialog.prepareSeconds,
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
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(tip.$1, size: 22, color: ink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tip.$2,
                                  style: OTTypography.cardTitle(color: ink)),
                              const SizedBox(height: 4),
                              Text(tip.$3,
                                  style: OTTypography.caption(color: muted)
                                      .copyWith(height: 1.5)),
                            ]),
                      ),
                    ]),
              ),
            ),
            const SizedBox(height: 12),
            Text(ProductPricing.rupiah(widget.amount),
                textDirection: TextDirection.ltr,
                style: OTTypography.bodyMedium(color: ink)),
            const SizedBox(height: 4),
            Text(widget.invoice,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: OTTypography.caption(color: muted)),
            const SizedBox(height: 16),
            SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: done
                        ? () {
                            final nav = Navigator.of(context);
                            nav.popUntil((route) =>
                                route.settings.name == AppRoutes.dashboard ||
                                route.isFirst);
                            if (agent != null) {
                              AgentSessionManager.instance.openAgent(
                                agent,
                                user: AuthService().cachedCurrentUser,
                              );
                            }
                          }
                        : null,
                    child: Text(done
                        ? (agent != null
                            ? reviewCopy('Mulai Bertanya Sekarang',
                                'ابدأ السؤال الآن', 'Start Asking Now')
                            : reviewCopy('Selesai', 'تم', 'Done'))
                        : reviewCopy(
                            'Menyiapkan akses… $_left',
                            'جارٍ التجهيز… $_left',
                            'Preparing access… $_left')))),
          ]),
        ),
      ),
    );
  }
}
