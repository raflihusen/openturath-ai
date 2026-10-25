import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/product_pricing.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import 'access_prepare_gate.dart';
import 'tahawwulat_hero.dart';

/// Shown only after the checkout confirms the paid invoice, never on redirect alone.
/// Menahan pengguna 30 detik (lihat [AccessPrepareGate]) sampai akses siap.
class PaymentSuccessDialog extends StatelessWidget {
  const PaymentSuccessDialog(
      {super.key,
      required this.plan,
      required this.invoice,
      required this.amount,
      this.agent});
  final String plan, invoice;
  final int amount;
  final AgentModel? agent;

  /// Lama menunggu sebelum tombol aktif.
  static const int prepareSeconds = AccessPrepareGate.defaultSeconds;

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

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    return AccessPrepareGate(
      seconds: prepareSeconds,
      builder: (context, done, left, panel) => PopScope(
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
              Text(plan,
                  textAlign: TextAlign.center,
                  style: OTTypography.body(color: muted)),
              const SizedBox(height: 20),
              Text(
                  done
                      ? reviewCopy('Akses Anda sudah siap.',
                          'أصبح وصولك جاهزًا.', 'Your access is ready.')
                      : reviewCopy(
                          'Akses sedang disiapkan. Mohon tunggu sebentar dan tidak perlu membayar lagi.',
                          'يجري تجهيز وصولك. يُرجى الانتظار قليلًا ولا حاجة للدفع مرة أخرى.',
                          'Your access is being prepared. Please wait a moment; there is no need to pay again.'),
                  textAlign: TextAlign.center,
                  style: OTTypography.bodyMedium(color: ink)),
              const SizedBox(height: 12),
              panel,
              const SizedBox(height: 12),
              Text(ProductPricing.rupiah(amount),
                  textDirection: TextDirection.ltr,
                  style: OTTypography.bodyMedium(color: ink)),
              const SizedBox(height: 4),
              Text(invoice,
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
                                  agent!,
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
                              'Menyiapkan akses… $left',
                              'جارٍ التجهيز… $left',
                              'Preparing access… $left')))),
            ]),
          ),
        ),
      ),
    );
  }
}
