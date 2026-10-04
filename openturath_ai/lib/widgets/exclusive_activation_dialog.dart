import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_typography.dart';
import '../core/hijri_date_utils.dart';
import '../models/agent_model.dart';
import '../services/agent_session_manager.dart';

import 'package:openturath_ai/core/design/ot_radius.dart';
import 'package:openturath_ai/core/design/ot_colors.dart';
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
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
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
    Navigator.of(context).pop();

    // Jika ada agent spesifik yang diaktifkan, buka langsung tab studinya
    if (agentId != null && agentId!.isNotEmpty) {
      final matched = AgentModel.defaultAgents.where((a) => a.id == agentId).firstOrNull;
      if (matched != null) {
        AgentSessionManager.instance.openAgent(matched);
      }
    } else {
      // Default: buka Fikih Syafi'i atau agen pertama
      final defaultAgent = AgentModel.defaultAgents.firstWhere(
        (a) => a.id == 'fiqh_syafii' || a.id == 'fiqh_tahawwulat',
        orElse: () => AgentModel.defaultAgents.first,
      );
      AgentSessionManager.instance.openAgent(defaultAgent);
    }

    // Jika dialog dipanggil dari dalam layar Langganan, tutup layar langganan agar langsung ke ruang telaah
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveExpiry = expiryDate ?? DateTime.now().add(Duration(days: durationDays));
    final expiryFormatted = HijriDateUtils.formatMasehiOnly(effectiveExpiry.toLocal());

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 580,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          constraints: BoxConstraints(
            maxHeight: math.min(760.0, MediaQuery.of(context).size.height - 32),
          ),
          decoration: BoxDecoration(
            color: OTColors.surfaceDark,
            borderRadius: BorderRadius.circular(OTRadius.card),
            border: Border.all(
              color: OTColors.borderStrongDark.withValues(alpha: 0.42),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: OTColors.shadow.withValues(alpha: 0.65),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: OTColors.borderStrongDark.withValues(alpha: 0.12),
                blurRadius: 50,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(OTRadius.card),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 1. Glowing Seal of Honor ──
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          OTColors.borderLight,
                          OTColors.borderStrongDark,
                          OTColors.textSecondaryLight,
                        ],
                        radius: 0.85,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: OTColors.borderStrongDark.withValues(alpha: 0.45),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: 42,
                        color: OTColors.surfaceDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── 2. Verified Exclusive Chip ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: OTColors.borderStrongDark.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(OTRadius.card),
                      border: Border.all(
                        color: OTColors.borderStrongDark.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: OTColors.textSecondaryDark,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'AKSES PERDANA TERVERIFIKASI',
                          style: TextStyle(
                            color: OTColors.borderLight,
                            fontSize: OTFontSize.s11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 3. Headings ──
                  Text(
                    'Akses Eksklusif Terbuka',
                    textAlign: TextAlign.center,
                    style: OTTypography.corpusTitle(
                      color: OTColors.canvasLight,
                    ).copyWith(
                      fontSize: OTFontSize.s26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selamat! Hak istimewa telaah kitab turath berbasis AI telah aktif penuh pada akun Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OTColors.textSecondaryDark,
                      fontSize: OTFontSize.s14,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── 4. Exclusive Digital Scholar Pass Card ──
                  Container(
                    decoration: BoxDecoration(
                      color: OTColors.surfaceSubtleDark,
                      borderRadius: BorderRadius.circular(OTRadius.input),
                      border: Border.all(
                        color: OTColors.borderDark,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: OTColors.borderStrongDark.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(OTRadius.input),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: OTColors.textSecondaryDark,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceTitle.isNotEmpty
                                        ? serviceTitle
                                        : "Kajian Fikih Syafi'i: Al-Muhaqqiq",
                                    style: const TextStyle(
                                      color: OTColors.canvasLight,
                                      fontSize: OTFontSize.s16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Hak Istimewa Perdana',
                                    style: TextStyle(
                                      color: OTColors.textSecondaryDark,
                                      fontSize: OTFontSize.s12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: OTColors.surfaceSubtleDark,
                                borderRadius: BorderRadius.circular(OTRadius.xs),
                                border: Border.all(
                                  color: OTColors.borderDark,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'Aktif • $durationDays Hari',
                                style: const TextStyle(
                                  color: OTColors.textSecondaryDark,
                                  fontSize: OTFontSize.s12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(color: OTColors.borderSubtleDark, height: 1),
                        ),

                        // Privileges checklist
                        _buildPrivilegeRow(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Tanya-Jawab Ilmiah Tanpa Batas',
                          subtitle: 'Diskusi telaah mendalam kitab mu\'tabarah bebas kuota selama masa aktif.',
                        ),
                        const SizedBox(height: 12),
                        _buildPrivilegeRow(
                          icon: Icons.auto_stories_rounded,
                          title: 'Ibarah & Rujukan Kitab Asli',
                          subtitle: 'Penelusuran langsung matan, syarah, dan hasyiyah ulama mu\'tamad.',
                        ),
                        const SizedBox(height: 12),
                        _buildPrivilegeRow(
                          icon: Icons.bookmark_added_rounded,
                          title: 'Simpan Catatan & Faedah',
                          subtitle: 'Arsipkan mutiara kajian dan bahan telaah ke koleksi pribadi.',
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(color: OTColors.borderSubtleDark, height: 1),
                        ),

                        // Expiry validity note
                        Row(
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              size: 15,
                              color: OTColors.textSecondaryDark,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Berlaku hingga $expiryFormatted',
                              style: const TextStyle(
                                color: OTColors.textSecondaryDark,
                                fontSize: OTFontSize.s12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── 5. Primary Action Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _handleStartStudy(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OTColors.borderStrongDark,
                        foregroundColor: OTColors.surfaceDark,
                        elevation: 6,
                        shadowColor: OTColors.borderStrongDark.withValues(alpha: 0.35),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mulai Telaah Sekarang',
                            style: TextStyle(
                              fontSize: OTFontSize.s16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── 6. Secondary Dismiss Button ──
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: OTColors.textSecondaryDark,
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontSize: OTFontSize.s14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivilegeRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: OTColors.surfaceSubtleDark,
            borderRadius: BorderRadius.circular(OTRadius.xs),
          ),
          child: Icon(icon, size: 14, color: OTColors.textSecondaryDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: OTColors.textPrimaryDark,
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: OTColors.textSecondaryDark,
                  fontSize: OTFontSize.s12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
