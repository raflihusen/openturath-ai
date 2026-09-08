import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/update_service.dart';

class UpdateReadyBanner extends StatelessWidget {
  const UpdateReadyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final updateService = UpdateService();

    return AnimatedBuilder(
      animation: updateService,
      builder: (context, _) {
        if (!updateService.isUpdateReady) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final info = updateService.updateInfo;
        final version = info?.latestVersion ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF132A1C), const Color(0xFF0F1E2E)]
                  : [const Color(0xFFE8F5E9), const Color(0xFFE3F2FD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E7D32) : const Color(0xFF81C784),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.green).withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B5E20) : const Color(0xFFC8E6C9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pembaruan v$version Siap Dipasang',
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Telah selesai diunduh di latar belakang. Ketuk untuk memasang seketika.',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF388E3C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => updateService.installNow(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF2E7D32) : const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Pasang',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
