import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

/// AppErrorState: Komponen visual baku penanganan galat dan koneksi terputus.
/// Menghindarkan aplikasi dari layar kosong atau error bisu tanpa pemulihan.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onBack;
  final String backLabel;

  const AppErrorState({
    super.key,
    this.title = 'Koneksi terputus',
    this.message = 'Tidak dapat memuat data saat ini. Periksa koneksi internet lalu coba lagi.',
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
    this.retryLabel = 'Coba lagi',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  const AppErrorState.network({
    super.key,
    this.title = 'Koneksi Terputus',
    this.message = 'Tidak dapat memuat data naskah saat ini. Periksa koneksi internet lalu coba lagi.',
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
    this.retryLabel = 'Coba lagi',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  const AppErrorState.unauthorized({
    super.key,
    this.title = 'Akses Dibatasi',
    this.message = 'Sesi akun kedaluwarsa atau modul riset membutuhkan peningkatan hak akses.',
    this.icon = Icons.lock_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Buka Langganan',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  const AppErrorState.empty({
    super.key,
    this.title = 'Naskah Tidak Ditemukan',
    this.message = 'Tidak ada naskah atau catatan yang sesuai dengan kata kunci atau filter.',
    this.icon = Icons.find_in_page_outlined,
    this.onRetry,
    this.retryLabel = 'Reset Pencarian',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  const AppErrorState.generic({
    super.key,
    this.title = 'Terjadi Kendala Teknis',
    this.message = 'Sistem mengalami kendala saat memproses telaah naskah. Silakan coba kembali sesaat lagi.',
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Muat Ulang',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 1.2),
                ),
                child: Icon(icon, size: 32, color: accent),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  height: 1.45,
                  color: textSecondary,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      retryLabel,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                    ),
                  ),
                ),
              ],
              if (onBack != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: onBack,
                    child: Text(
                      backLabel,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
