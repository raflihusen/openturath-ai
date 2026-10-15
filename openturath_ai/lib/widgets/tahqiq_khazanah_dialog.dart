import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import 'apple_interactive_wrapper.dart';
import 'tahawwulat_hero.dart';

/// Modal dialog ilmiah berestetika Monochrome Obsidian murni (Rule 9)
/// untuk menginformasikan bahwa modul AI spesialis sedang dalam tahap tahqiq & verifikasi sanad.
class TahqiqKhazanahDialog extends StatelessWidget {
  const TahqiqKhazanahDialog({
    super.key,
    required this.agent,
  });

  final AgentModel agent;

  static Future<void> show(BuildContext context, {required AgentModel agent}) {
    OTMotion.light();
    return showDialog<void>(
      context: context,
      barrierColor: OTColors.shadow.withValues(alpha: 0.75),
      builder: (_) => TahqiqKhazanahDialog(agent: agent),
    );
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);
    final surface = OTColors.surface(isDark);

    final displayTitle = Loc.isArabic && agent.titleArabic.isNotEmpty
        ? agent.titleArabic
        : Loc.text(agent.title);

    return AlertDialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OTRadius.dialog),
        side: BorderSide(color: border),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ikon Obsidian Gembok Khazanah
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: OTColors.surfaceSubtle(isDark),
              borderRadius: BorderRadius.circular(OTRadius.card),
              border: Border.all(color: border),
            ),
            child: Icon(
              Icons.lock_clock_outlined,
              size: 32,
              color: ink,
            ),
          ),
          const SizedBox(height: 20),

          // Judul AI
          Text(
            displayTitle,
            textAlign: TextAlign.center,
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s20,
              fontWeight: FontWeight.w700,
              color: ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          // Subjudul
          Text(
            reviewCopy(
              'Tahqiq Rujukan & Digitalisasi Sanad',
              'تحقيق المراجع ورقمنة الأسانيد',
              'Reference Verification & Isnad Digitization',
            ),
            textAlign: TextAlign.center,
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s12,
              fontWeight: FontWeight.w600,
              color: muted,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),

          // Deskripsi Ilmiah
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OTColors.canvas(isDark),
              borderRadius: BorderRadius.circular(OTRadius.button),
              border: Border.all(color: border.withValues(alpha: 0.5)),
            ),
            child: Text(
              reviewCopy(
                'Khazanah kitab mu\'tabarah untuk disiplin ini sedang dalam tahap tahqiq dan digitalisasi komprehensif oleh tim peneliti OpenTurath. Akses akan dibuka secara bertahap tanpa memerlukan pembaruan aplikasi.',
                'كتب هذا الفن التراثية المعتمدة قيد التحقيق والرقمنة الشاملة من قبل باحثي التراث. سيتم إتاحة الوصول تدريجيًا دون الحاجة لتحديث التطبيق.',
                'The authoritative turath texts for this discipline are undergoing scholarly verification and digitization by the OpenTurath team. Access will be unlocked phased without requiring app updates.',
              ),
              textAlign: TextAlign.center,
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s14,
                height: 1.5,
                color: ink.withValues(alpha: 0.85),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Tutup (Monochrome Obsidian Murni)
          SizedBox(
            width: double.infinity,
            height: 46,
            child: AppleInteractiveWrapper(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(OTRadius.button),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: ink,
                  foregroundColor: OTColors.onAccent(isDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(OTRadius.button),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  reviewCopy('Tutup', 'إغلاق', 'Close'),
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
