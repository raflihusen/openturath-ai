import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_typography.dart';
import '../core/entitlement_keys.dart';
import '../core/hijri_date_utils.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../screens/main_shell_screen.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';

import 'package:openturath_ai/core/design/ot_radius.dart';
import 'package:openturath_ai/core/design/ot_colors.dart';
import '../core/localization.dart';
import 'access_prepare_gate.dart';
import 'tahawwulat_hero.dart';

/// Dialog aktivasi eksklusif berlayar penuh / luas untuk penukaran kode perdana atau voucher santri.
/// Menampilkan piagam digital berestetika tinta monokrom dengan kontras tinggi.
class ExclusiveActivationDialog extends StatelessWidget {
  final String serviceTitle;
  final int durationDays;
  final DateTime? expiryDate;
  final String? agentId;

  /// Tampilkan baris masa berlaku. False bila server tidak mengirim tanggal.
  final bool showValidity;

  /// Kode yang baru ditukar; dipakai untuk menanyakan kesiapan akses.
  final String? code;

  const ExclusiveActivationDialog({
    super.key,
    required this.serviceTitle,
    required this.durationDays,
    this.expiryDate,
    this.agentId,
    this.showValidity = true,
    this.code,
  });

  static Future<void> show(
    BuildContext context, {
    required String serviceTitle,
    required int durationDays,
    DateTime? expiryDate,
    String? agentId,
    bool showValidity = true,
    String? code,
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
        showValidity: showValidity,
        code: code,
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

  static String _localizedTitle(String raw) {
    if (Loc.isArabic) {
      if (raw.contains('7 Menit') || raw.contains('7M') || raw.contains('7 دقائق')) {
        return 'وصول تجريبي لكافة المساعدات (٧ دقائق)';
      }
      if (raw.contains('5 Menit') || raw.contains('5M') || raw.contains('5 دقائق')) {
        return 'وصول تجريبي لكافة المساعدات (٥ دقائق)';
      }
      if (raw.contains('10 Menit') || raw.contains('10M') || raw.contains('10 دقائق')) {
        return 'وصول تجريبي لكافة المساعدات (١٠ دقائق)';
      }
      if (raw.contains('Semua AI') || raw.contains('all_access') || raw.contains('all_specialists')) {
        return 'باقة جميع العلوم والمساعدات';
      }
      if (raw.contains('Syafi') || raw.contains('syafii')) {
        return 'الفقه الشافعي';
      }
      if (raw.contains('Tahawwulat') || raw.contains('tahawwulat')) {
        return 'فقه التحولات';
      }
      final cleaned = Loc.cleanTitle(raw);
      return Loc.text(cleaned);
    }
    if (Loc.language == 'en') {
      if (raw.contains('7 Menit') || raw.contains('7M')) {
        return 'All AI Assistants Trial Access (7 Minutes)';
      }
      if (raw.contains('5 Menit') || raw.contains('5M')) {
        return 'All AI Assistants Trial Access (5 Minutes)';
      }
      if (raw.contains('10 Menit') || raw.contains('10M')) {
        return 'All AI Assistants Trial Access (10 Minutes)';
      }
      if (raw.contains('Semua AI') ||
          raw.contains('all_access') ||
          raw.contains('all_specialists') ||
          raw.contains('all_disciplines')) {
        return 'All AIs';
      }
      if (raw.contains('Syafi')) {
        return "AI Shafi'i Fiqh";
      }
      return raw.startsWith('AI ') ? raw : 'AI $raw';
    }
    if (raw.contains('Semua AI') ||
        raw.contains('all_access') ||
        raw.contains('all_specialists')) {
      return 'Semua AI';
    }
    return raw.startsWith('AI ') ? raw : (raw.startsWith('Akses ') ? raw : 'AI $raw');
  }

  void _handleStartStudy(BuildContext context) {
    HapticFeedback.mediumImpact();
    final nav = Navigator.of(context);
    nav.popUntil(
        (route) => route.settings.name == AppRoutes.dashboard || route.isFirst);

    // Jika aktivasi untuk 1 AI spesifik (bukan bundel virtual), buka AI tersebut langsung
    final normalizedAgentId = (agentId ?? '').trim().toLowerCase();
    if (normalizedAgentId.isNotEmpty &&
        !virtualBundleAgentIds.contains(normalizedAgentId)) {
      final matched = AgentModel.defaultAgents
          .where((a) =>
              a.id == agentId || (entitlementKeys[a.id] ?? a.id) == agentId)
          .firstOrNull;
      if (matched != null) {
        AgentSessionManager.instance.openAgent(
          matched,
          user: AuthService().cachedCurrentUser,
          replaceOldest: true,
        );
        return;
      }
    }

    // Jika akses semua AI (all_access / voucher paket), arahkan langsung ke Tab Daftar AI
    try {
      final shell = MainShellController.of(nav.context);
      shell?.switchTab(1);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark),
        muted = OTColors.textSecondary(dark);
    final expiry = expiryDate ??
        (durationDays > 0
            ? DateTime.now().add(Duration(days: durationDays))
            : null);
    return AccessPrepareGate(
      isReady: code == null
          ? null
          : () => SubscriptionService().isAccessReady(code: code),
      builder: (context, done, left, panel, ready) => PopScope(
        canPop: done,
        child: AlertDialog(
          backgroundColor: OTColors.surface(dark),
          shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
          title: Row(children: [
            Icon(Icons.check_circle_outline_rounded, color: ink),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    reviewCopy('Akses telah aktif', 'تم تفعيل الوصول',
                        'Access is active'),
                    style: OTTypography.screenTitle(color: ink))),
          ]),
          content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _localizedTitle(serviceTitle),
                      style: OTTypography.bodyMedium(color: ink)),
                  if (showValidity) ...[
                    const SizedBox(height: 12),
                    Text(
                        expiry == null
                            ? reviewCopy('Tanpa batas waktu', 'دون حد زمني',
                                'No time limit')
                            : '${reviewCopy('Berlaku hingga', 'صالح حتى', 'Valid until')} ${HijriDateUtils.formatMasehiOnly(expiry.toLocal())}',
                        style: OTTypography.body(color: muted)),
                  ],
                  const SizedBox(height: 16),
                  Text(
                      ready
                          ? reviewCopy(
                              'Anda dapat membuka AI dan menyimpan jawaban ke Catatan.',
                              'يمكنك فتح الذكاء الاصطناعي وحفظ نتائج الدراسة في الملاحظات.',
                              'You can open the AI and save study results to Notes.')
                          : done
                              ? reviewCopy(
                                  'Kode diterima, tetapi akses masih diproses. Buka kembali AI dari dashboard sebentar lagi.',
                                  'تم قبول الرمز لكن الوصول ما زال قيد المعالجة. افتح المساعد من لوحة التحكم بعد قليل.',
                                  'Code accepted, but access is still being processed. Open the AI from the dashboard shortly.')
                              : reviewCopy(
                                  'Kode diterima. Akses sedang disiapkan, mohon tunggu sebentar.',
                                  'تم قبول الرمز. يجري تجهيز الوصول، يُرجى الانتظار قليلًا.',
                                  'Code accepted. Your access is being prepared; please wait a moment.'),
                      style: OTTypography.body(color: muted)),
                  const SizedBox(height: 16),
                  panel,
                ]),
          ),
          actions: [
            TextButton(
                onPressed: done ? () => Navigator.of(context).pop() : null,
                child:
                    Text(MaterialLocalizations.of(context).closeButtonLabel)),
            if (!done || ready)
              FilledButton(
                  onPressed: ready ? () => _handleStartStudy(context) : null,
                  child: Text(ready
                      ? Loc.tr('openAssistant')
                      : reviewCopy('Menyiapkan akses… $left',
                          'جارٍ التجهيز… $left', 'Preparing access… $left'))),
          ],
        ),
      ),
    );
  }
}
