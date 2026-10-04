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
import '../core/design/ot_buttons.dart';

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
    Navigator.of(context).pop();

    // Jika ada agent spesifik yang diaktifkan, buka langsung tab studinya
    if (agentId != null && agentId!.isNotEmpty) {
      final matched =
          AgentModel.defaultAgents.where((a) => a.id == agentId).firstOrNull;
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
    // Mengikuti tema aplikasi; sebelumnya dialog ini selalu gelap.
    final dark = Theme.of(context).brightness == Brightness.dark;
    final effectiveExpiry =
        expiryDate ?? DateTime.now().add(Duration(days: durationDays));
    final expiryFormatted =
        HijriDateUtils.formatMasehiOnly(effectiveExpiry.toLocal());

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
            color: OTColors.surface(dark),
            borderRadius: BorderRadius.circular(OTRadius.card),
            border: Border.all(color: OTColors.border(dark)),
            boxShadow: [
              BoxShadow(
                color: OTColors.shadow.withValues(alpha: 0.12),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(OTRadius.card),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 1. Glowing Seal of Honor ──
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          OTColors.surfaceSubtle(dark),
                          OTColors.borderStrong(dark),
                          OTColors.textSecondary(dark),
                        ],
                        radius: 0.85,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: OTColors.borderStrong(dark)
                              .withValues(alpha: 0.45),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: 42,
                        color: OTColors.surface(dark),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── 2. Verified Exclusive Chip ──
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          OTColors.borderStrong(dark).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(OTRadius.card),
                      border: Border.all(
                        color:
                            OTColors.borderStrong(dark).withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: OTColors.textSecondary(dark),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AKSES PERDANA TERVERIFIKASI',
                          style: TextStyle(
                            color: OTColors.textSecondary(dark),
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
                      color: OTColors.textPrimary(dark),
                    ).copyWith(
                      fontSize: OTFontSize.s26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hak istimewa telaah kitab turath berbasis AI telah aktif penuh pada akun Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OTColors.textSecondary(dark),
                      fontSize: OTFontSize.s14,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── 4. Exclusive Digital Scholar Pass Card ──
                  Container(
                    decoration: BoxDecoration(
                      color: OTColors.surfaceSubtle(dark),
                      borderRadius: BorderRadius.circular(OTRadius.input),
                      border: Border.all(
                        color: OTColors.border(dark),
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
                                color: OTColors.borderStrong(dark)
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(OTRadius.input),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: OTColors.textSecondary(dark),
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
                                    style: TextStyle(
                                      color: OTColors.textPrimary(dark),
                                      fontSize: OTFontSize.s16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Hak Istimewa Perdana',
                                    style: TextStyle(
                                      color: OTColors.textSecondary(dark),
                                      fontSize: OTFontSize.s12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: OTColors.surfaceSubtle(dark),
                                borderRadius:
                                    BorderRadius.circular(OTRadius.xs),
                                border: Border.all(
                                  color: OTColors.border(dark),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'Aktif • $durationDays Hari',
                                style: TextStyle(
                                  color: OTColors.textSecondary(dark),
                                  fontSize: OTFontSize.s12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                              color: OTColors.borderSubtle(dark), height: 1),
                        ),

                        // Privileges checklist
                        _buildPrivilegeRow(
                          dark: dark,
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Tanya-Jawab Ilmiah Tanpa Batas',
                          subtitle:
                              'Diskusi telaah mendalam kitab mu\'tabarah bebas kuota selama masa aktif.',
                        ),
                        const SizedBox(height: 12),
                        _buildPrivilegeRow(
                          dark: dark,
                          icon: Icons.auto_stories_rounded,
                          title: 'Ibarah & Rujukan Kitab Asli',
                          subtitle:
                              'Penelusuran langsung matan, syarah, dan hasyiyah ulama mu\'tamad.',
                        ),
                        const SizedBox(height: 12),
                        _buildPrivilegeRow(
                          dark: dark,
                          icon: Icons.bookmark_added_rounded,
                          title: 'Simpan Catatan & Faedah',
                          subtitle:
                              'Arsipkan mutiara kajian dan bahan telaah ke koleksi pribadi.',
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                              color: OTColors.borderSubtle(dark), height: 1),
                        ),

                        // Expiry validity note
                        Row(
                          children: [
                            Icon(
                              Icons.event_available_rounded,
                              size: 15,
                              color: OTColors.textSecondary(dark),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Berlaku hingga $expiryFormatted',
                              style: TextStyle(
                                color: OTColors.textSecondary(dark),
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
                    style: OTButtons.quiet(dark),
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
    required bool dark,
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
            color: OTColors.surfaceSubtle(dark),
            borderRadius: BorderRadius.circular(OTRadius.xs),
          ),
          child: Icon(icon, size: 14, color: OTColors.textSecondary(dark)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: OTColors.textPrimary(dark),
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: OTColors.textSecondary(dark),
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
