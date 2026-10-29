import 'package:flutter/animation.dart';

/// Monochrome Editorial, sama dengan situs dan aplikasi OpenTurath.
abstract final class OT {
  static const bg = Color(0xFF09090B);
  static const card = Color(0xFF18181B);
  static const line = Color(0xFF27272A);
  static const lineStrong = Color(0xFF3F3F46);
  static const ink = Color(0xFFFAFAFA);
  static const sub = Color(0xFFA1A1AA);
  static const serif = 'Newsreader';
  static const sans = 'Outfit';
  static const arabic = 'OTArabic';

  /// Kurva gerak seragam: keluar cepat, berhenti lembut.
  static const ease = Cubic(0.16, 1, 0.3, 1);
}
