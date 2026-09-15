import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'apple_interactive_wrapper.dart';

/// Kartu Flagship Eksklusif Fikih Tahawwulat (Korpus Mahkota OpenTurath AI).
/// Menggunakan palet Deep Emerald Twilight dengan hairline border sovereignAmber,
/// kisi 4 bilik asisten ilmiah, dan tanpa emblem logo sesuai arahan desain.
class TahawwulatFlagshipCard extends StatelessWidget {
  final AgentModel agent;
  final bool isSubscribed;
  final VoidCallback onOpenMain;
  final void Function(SubAgentModel subAgent) onOpenSubAgent;
  final VoidCallback? onOpenLibrary;

  const TahawwulatFlagshipCard({
    super.key,
    required this.agent,
    required this.isSubscribed,
    required this.onOpenMain,
    required this.onOpenSubAgent,
    this.onOpenLibrary,
  });

  static const _deepEmeraldStart = Color(0xFF0D201A);
  static const _deepEmeraldEnd = Color(0xFF050D0A);
  static const _sovereignAmber = Color(0xFFD97706);
  static const _chamberSurface = Color(0xFF12241D);
  static const _chamberBorder = Color(0xFF1E3A2F);

  IconData _iconForSubAgent(String id) {
    if (id.contains('muhaqqiq')) return Icons.menu_book_rounded;
    if (id.contains('bayan')) return Icons.auto_stories_outlined;
    if (id.contains('mukhtabir')) return Icons.school_outlined;
    if (id.contains('habib')) return Icons.graphic_eq_rounded;
    return Icons.auto_awesome_rounded;
  }

  String _numberForIndex(int index) {
    return '0${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final subAgents = agent.subAgents ?? const [];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepEmeraldStart, _deepEmeraldEnd],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: _sovereignAmber.withValues(alpha: 0.38),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Stack(
          children: [
            // Watermark Geometri Kubah Mihrab Klasik (opasitas 4.5% sangat halus)
            Positioned(
              right: -30,
              top: -20,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.045,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _MihrabWatermarkPainter(),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Eyebrow Pill (Rukun Keempat Agama - Tanpa Emblem di sudut kanan)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _sovereignAmber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: _sovereignAmber.withValues(alpha: 0.32),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'RUKUN KEEMPAT AGAMA',
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Status Berlangganan / Riset
                      if (isSubscribed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 11, color: Color(0xFF34D399)),
                              const SizedBox(width: 4),
                              Text(
                                'Akses Aktif',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF34D399),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Judul Utama & Kaligrafi Arab
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          agent.title,
                          style: GoogleFonts.newsreader(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFAFAFA),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'فقه التحولات',
                        style: GoogleFonts.amiri(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6EE7B7).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 3. Deskripsi Singkat Resmi
                  Text(
                    agent.description,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFCBD5E1),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Kisi 4 Bilik Asisten (The 4 Scholar Chambers)
                  Column(
                    children: List.generate(subAgents.length, (index) {
                      final sub = subAgents[index];
                      final icon = _iconForSubAgent(sub.id);
                      final number = _numberForIndex(index);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppleInteractiveWrapper(
                          onTap: () => onOpenSubAgent(sub),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: _chamberSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _chamberBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Nomor bilik
                                Text(
                                  number,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6EE7B7).withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Ikon bilik
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(icon, size: 14, color: const Color(0xFFFCD34D)),
                                ),
                                const SizedBox(width: 10),
                                // Judul dan Gelar
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sub.name,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFF8FAFC),
                                        ),
                                      ),
                                      Text(
                                        sub.description,
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),

                  // 5. Tombol Aksi Bawah
                  Row(
                    children: [
                      // Tombol Utama (Buka Majelis)
                      Expanded(
                        child: AppleInteractiveWrapper(
                          onTap: onOpenMain,
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSubscribed
                                    ? const [Color(0xFF059669), Color(0xFF047857)]
                                    : const [Color(0xFFD97706), Color(0xFFB45309)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: (isSubscribed
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFD97706))
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isSubscribed
                                      ? 'Buka Majelis 4 Asisten'
                                      : 'Masuk Majelis Telaah',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 15, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Tombol Pustaka Maraji'
                      if (onOpenLibrary != null) ...[
                        const SizedBox(width: 8),
                        AppleInteractiveWrapper(
                          onTap: onOpenLibrary,
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book_outlined,
                                    size: 15, color: Color(0xFFCBD5E1)),
                                const SizedBox(width: 6),
                                Text(
                                  'Pustaka',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MihrabWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    // Siluet kubah mihrab melengkung
    path.moveTo(size.width * 0.1, size.height);
    path.lineTo(size.width * 0.1, size.height * 0.45);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.5,
      0,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.1,
      size.width * 0.9,
      size.height * 0.45,
    );
    path.lineTo(size.width * 0.9, size.height);

    canvas.drawPath(path, paint);

    // Garis kubah konsentris kedua
    final innerPath = Path();
    innerPath.moveTo(size.width * 0.25, size.height);
    innerPath.lineTo(size.width * 0.25, size.height * 0.5);
    innerPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.22,
      size.width * 0.5,
      size.height * 0.12,
    );
    innerPath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.22,
      size.width * 0.75,
      size.height * 0.5,
    );
    innerPath.lineTo(size.width * 0.75, size.height);

    canvas.drawPath(innerPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
