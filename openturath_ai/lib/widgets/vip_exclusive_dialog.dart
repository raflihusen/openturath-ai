import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/user_model.dart';

/// Akun VIP (dan edisi Guru) tidak memakai langganan: akses mereka permanen
/// dan khusus bagi tim OpenTurath. Layar langganan tidak boleh terbuka.
bool isExclusiveAccount(UserModel? user) =>
    AppConfig.isGuruEdition || user?.isVip == true;

/// Pesan yang tampil saat akun eksklusif mengetuk bagian langganan.
class VipExclusiveDialog extends StatelessWidget {
  const VipExclusiveDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
      context: context, builder: (_) => const VipExclusiveDialog());

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    return Dialog(
      key: const ValueKey('vip-exclusive-dialog'),
      backgroundColor: OTColors.surface(isDark),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OTRadius.card),
          side: BorderSide(color: OTColors.border(isDark))),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: OTColors.surfaceSubtle(isDark)),
                child: Icon(Icons.verified_outlined, size: 26, color: ink),
              ),
              const SizedBox(height: 18),
              Text(Loc.tr('vipExclusiveTitle'),
                  textAlign: TextAlign.center,
                  style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s18,
                      fontWeight: FontWeight.w600,
                      color: ink)),
              const SizedBox(height: 10),
              Text(Loc.tr('vipExclusiveBody'),
                  textAlign: TextAlign.center,
                  style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s14, height: 1.6, color: muted)),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('vip-exclusive-ok'),
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44)),
                child: Text(Loc.tr('vipExclusiveOk')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
