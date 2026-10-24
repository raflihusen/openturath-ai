import 'package:flutter/material.dart';

import 'ot_colors.dart';
import 'ot_spacing.dart';
import 'ot_typography.dart';

/// Varian tombol di luar bawaan tema. Bentuk (pil), tinggi, dan huruf tombol
/// diatur tema di `core/theme.dart`; berkas ini hanya memuat penyimpangan yang
/// punya arti, sehingga layar tidak perlu menulis `styleFrom` sendiri.
abstract final class OTButtons {
  /// Aksi permanen: hapus akun, hapus catatan, keluar.
  static ButtonStyle destructive(bool dark) => FilledButton.styleFrom(
        backgroundColor: OTColors.destructive(dark),
        foregroundColor: OTColors.onAccent(dark),
      );

  /// Tombol primer di atas permukaan yang selalu gelap (kartu pembuka).
  static ButtonStyle onInk() => FilledButton.styleFrom(
        backgroundColor: OTColors.textPrimaryDark,
        foregroundColor: OTColors.textPrimaryLight,
      );

  /// Tombol di atas kartu terbalik (hitam di mode terang, terang di mode gelap).
  static ButtonStyle onInverse(bool dark) => FilledButton.styleFrom(
        backgroundColor: OTColors.onInverted(dark),
        foregroundColor: OTColors.textPrimary(dark),
      );

  /// Aksi teks yang sengaja diredam (mis. "Gunakan voucher").
  static ButtonStyle quiet(bool dark) => TextButton.styleFrom(
        foregroundColor: OTColors.textSecondary(dark),
      );

  /// Aksi kecil di dalam kartu: garis tepi, tinggi 36.
  static ButtonStyle compactOutlined(bool dark) => OutlinedButton.styleFrom(
        foregroundColor: OTColors.textPrimary(dark),
        side: BorderSide(color: OTColors.borderStrong(dark)),
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: OTSpacing.md),
        textStyle: OTTypography.captionMedium(),
      );

  /// Aksi kecil di dalam kartu: isi tonal, tinggi 36.
  static ButtonStyle compactTonal(bool dark) => FilledButton.styleFrom(
        backgroundColor: OTColors.surfaceSubtle(dark),
        foregroundColor: OTColors.textPrimary(dark),
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: OTSpacing.md),
        textStyle: OTTypography.captionMedium(),
      );
}
