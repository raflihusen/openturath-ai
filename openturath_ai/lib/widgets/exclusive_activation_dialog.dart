import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_typography.dart';
import '../core/entitlement_keys.dart';
import '../core/hijri_date_utils.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';

import 'package:openturath_ai/core/design/ot_radius.dart';
import 'package:openturath_ai/core/design/ot_colors.dart';
import '../core/localization.dart';
import 'tahawwulat_hero.dart';

/// Dialog aktivasi eksklusif berlayar penuh / luas untuk penukaran kode perdana atau voucher santri.
/// Menampilkan piagam digital berestetika tinta monokrom dengan kontras tinggi.
class ExclusiveActivationDialog extends StatelessWidget {
  final String serviceTitle;
  final int durationDays;
  final DateTime? expiryDate;
  final String? agentId;

  const ExclusiveActivationDialog({
    super.key,
    required this.serviceTitle,
    required this.durationDays,
    this.expiryDate,
    this.agentId,
  });

  static Future<void> show(
    BuildContext context, {
    required String serviceTitle,
    required int durationDays,
    DateTime? expiryDate,
    String? agentId,
  }) {
    OTMotion.success();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'ExclusiveActivation',
      barrierColor: OTColors.shadow.withValues(alpha: 0.78),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => ExclusiveActivationDialog(
        serviceTitle: serviceTitle,
        durationDays: durationDays,
        expiryDate: expiryDate,
        agentId: agentId,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curve =
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14 * curve.value,
            sigmaY: 14 * curve.value,
          ),
          child: FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(curve),
              child: child,
            ),
          ),
        );
      },
    );
  }

  void _handleStartStudy(BuildContext context) {
    HapticFeedback.mediumImpact();
    final nav = Navigator.of(context);
    nav.popUntil((route) =>
        route.settings.name == AppRoutes.dashboard || route.isFirst);

    AgentModel? matched;
    if (agentId != null && agentId!.isNotEmpty && agentId != 'all_access') {
      matched = AgentModel.defaultAgents
          .where((a) =>
              a.id == agentId ||
              (entitlementKeys[a.id] ?? a.id) == agentId)
          .firstOrNull;
    }
    final targetAgent = matched ??
        AgentModel.defaultAgents.firstWhere(
          (a) => a.id == 'fiqh_tahawwulat' || a.id == 'fiqh_syafii',
          orElse: () => AgentModel.defaultAgents.first,
        );
    AgentSessionManager.instance.openAgent(
      targetAgent,
      user: AuthService().cachedCurrentUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    final expiry = expiryDate ??
        (durationDays > 0
            ? DateTime.now().add(Duration(days: durationDays))
            : null);
    return AlertDialog(
      backgroundColor: OTColors.surface(dark),
      shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
      title: Row(children: [
        Icon(Icons.check_circle_outline_rounded, color: ink),
        const SizedBox(width: 12),
        Expanded(
            child: Text(
                reviewCopy(
                    'Akses telah aktif', 'تم تفعيل الوصول', 'Access is active'),
                style: OTTypography.screenTitle(color: ink))),
      ]),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                serviceTitle.startsWith('AI ')
                    ? serviceTitle
                    : 'AI $serviceTitle',
                style: OTTypography.bodyMedium(color: ink)),
            const SizedBox(height: 12),
            Text(
                expiry == null
                    ? reviewCopy(
                        'Tanpa batas waktu', 'دون حد زمني', 'No time limit')
                    : '${reviewCopy('Berlaku hingga', 'صالح حتى', 'Valid until')} ${HijriDateUtils.formatMasehiOnly(expiry.toLocal())}',
                style: OTTypography.body(color: muted)),
            const SizedBox(height: 16),
            Text(
                reviewCopy(
                    'Anda dapat membuka AI dan menyimpan hasil telaah ke Catatan.',
                    'يمكنك فتح الذكاء الاصطناعي وحفظ نتائج الدراسة في الملاحظات.',
                    'You can open the AI and save study results to Notes.'),
                style: OTTypography.body(color: muted)),
          ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel)),
        FilledButton(
            onPressed: () => _handleStartStudy(context),
            child: Text(Loc.tr('openAssistant'))),
      ],
    );
  }
}
