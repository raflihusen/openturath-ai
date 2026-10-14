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
  static Future<void> show(BuildContext context,
          {required String plan,
          required String invoice,
          required int amount,
          AgentModel? agent}) =>
      showDialog<void>(
          context: context,
          builder: (_) => PaymentSuccessDialog(
              plan: plan, invoice: invoice, amount: amount, agent: agent));
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TweenAnimationBuilder<double>(
            tween: Tween(begin: .8, end: 1),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 360),
            curve: Curves.easeOutBack,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                    color: ink, borderRadius: OTRadius.cardBorder),
                child: Icon(Icons.check_rounded,
                    size: 40, color: OTColors.canvas(dark)))),
        const SizedBox(height: 20),
        Text(reviewCopy('Pembayaran berhasil', 'تم الدفع بنجاح', 'Payment successful'),
            textAlign: TextAlign.center,
            style: OTTypography.screenTitle(color: ink)),
        const SizedBox(height: 12),
        Text(plan,
            textAlign: TextAlign.center,
            style: OTTypography.body(color: muted)),
        const SizedBox(height: 24),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: OTColors.surfaceSubtle(dark),
                borderRadius: OTRadius.cardBorder),
            child: Column(children: [
              Text(ProductPricing.rupiah(amount),
                  textDirection: TextDirection.ltr,
                  style: OTTypography.screenTitle(color: ink)),
              const SizedBox(height: 8),
              Text(invoice,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: OTTypography.caption(color: muted)),
            ])),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () {
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
                },
                child: Text(agent != null
                    ? reviewCopy('Mulai Telaah Sekarang', 'ابدأ الدراسة الآن', 'Start Study Now')
                    : reviewCopy('Selesai', 'تم', 'Done')))),
      ]),
    );
  }
}
