import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/scholarly_fonts.dart';

/// AppErrorState: Komponen visual baku penanganan galat dan koneksi terputus.
/// Menghindarkan aplikasi dari layar kosong atau error bisu tanpa pemulihan.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData retryIcon;
  final VoidCallback? onBack;
  final String backLabel;

  const AppErrorState({
    super.key,
    this.title = 'Koneksi terputus',
    this.message = 'Tidak dapat memuat data saat ini. Periksa koneksi internet lalu coba lagi.',
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
    this.retryLabel = 'Coba lagi',
    this.retryIcon = Icons.refresh_rounded,
    this.onBack,
    this.backLabel = 'Kembali',
  });

  const AppErrorState.network({
    super.key,
    this.title = 'Koneksi terputus',
    this.message = 'Tidak dapat memuat data rujukan saat ini. Periksa koneksi internet lalu coba lagi.',
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
    this.retryLabel = 'Coba lagi',
    this.onBack,
    this.backLabel = 'Kembali',
  }) : retryIcon = Icons.refresh_rounded;

  const AppErrorState.unauthorized({
    super.key,
    this.title = 'Langganan diperlukan',
    this.message = 'Sesi Anda telah berakhir atau akses ke asisten ini belum aktif.',
    this.icon = Icons.lock_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Lihat langganan',
    this.onBack,
    this.backLabel = 'Kembali',
  }) : retryIcon = Icons.refresh_rounded;

  const AppErrorState.empty({
    super.key,
    this.title = 'Rujukan tidak ditemukan',
    this.message = 'Tidak ada kitab atau catatan yang sesuai dengan kata kunci atau saringan.',
    this.icon = Icons.find_in_page_outlined,
    this.onRetry,
    this.retryLabel = 'Atur ulang pencarian',
    this.onBack,
    this.backLabel = 'Kembali',
  }) : retryIcon = Icons.refresh_rounded;

  const AppErrorState.generic({
    super.key,
    this.title = 'Terjadi kendala teknis',
    this.message = 'Asisten belum dapat dimuat. Coba lagi sebentar.',
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Muat ulang',
    this.onBack,
    this.backLabel = 'Kembali',
  }) : retryIcon = Icons.refresh_rounded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: OTColors.surfaceSubtle(isDark),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: ink),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: ScholarlyFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: ScholarlyFonts.outfit(
                  fontSize: 14,
                  height: 1.55,
                  color: muted,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: Icon(retryIcon, size: 18),
                  label: Text(retryLabel),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    textStyle: ScholarlyFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              if (onBack != null) ...[
                SizedBox(height: onRetry != null ? 6 : 20),
                TextButton(
                  onPressed: onBack,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(120, 44),
                    foregroundColor: muted,
                    textStyle: ScholarlyFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  child: Text(backLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
