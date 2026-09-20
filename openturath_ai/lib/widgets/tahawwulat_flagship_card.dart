import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'apple_interactive_wrapper.dart';
import 'tahawwulat_introduction_sheet.dart';

/// Kartu monokrom untuk paket utama OpenTurath.
///
/// Kemewahan dibangun melalui ruang, tipografi, dan detail hairline. Seluruh
/// asisten berada dalam satu daftar editorial agar kartu tetap tenang dan tidak
/// berubah menjadi kumpulan kartu kecil yang ramai.
class TahawwulatFlagshipCard extends StatelessWidget {
  final AgentModel agent;
  final bool isSubscribed;
  final VoidCallback onOpenMain;
  final void Function(SubAgentModel subAgent) onOpenSubAgent;
  final VoidCallback? onOpenLibrary;
  final VoidCallback? onOpenIntroduction;

  const TahawwulatFlagshipCard({
    super.key,
    required this.agent,
    required this.isSubscribed,
    required this.onOpenMain,
    required this.onOpenSubAgent,
    this.onOpenLibrary,
    this.onOpenIntroduction,
  });

  static const _obsidian = Color(0xFF09090A);
  static const _graphite = Color(0xFF141416);
  static const _pearl = Color(0xFFF5F5F3);
  static const _silver = Color(0xFFB5B5BC);
  static const _muted = Color(0xFF8C8C94);
  static const _hairline = Color(0xFF303034);

  String _numberForIndex(int index) {
    return (index + 1).toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final subAgents = agent.subAgents ?? const <SubAgentModel>[];

    return Semantics(
      container: true,
      label: '${agent.title}, paket utama OpenTurath, '
          '${subAgents.length} asisten khusus',
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_graphite, _obsidian],
            stops: [0, 0.72],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _ObsidianDetailPainter()),
                ),
              ),
              Positioned(
                right: 18,
                top: 62,
                child: IgnorePointer(
                  child: Text(
                    subAgents.length.toString().padLeft(2, '0'),
                    style: GoogleFonts.newsreader(
                      fontSize: 78,
                      fontWeight: FontWeight.w500,
                      height: 0.9,
                      color: Colors.white.withValues(alpha: 0.035),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'KOLEKSI UTAMA',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.8,
                            color: _silver,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 18,
                          height: 0.8,
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${subAgents.length} ASISTEN',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.25,
                            color: _muted,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSubscribed
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusPill),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.17),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _pearl,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSubscribed ? 'AKTIF' : 'PREMIUM',
                                style: GoogleFonts.outfit(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                  color: _pearl,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text(
                      agent.title,
                      style: GoogleFonts.newsreader(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.55,
                        height: 1.05,
                        color: _pearl,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      agent.titleArabic,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: _silver,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      agent.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: _silver,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(height: 0.8, color: _hairline),
                    Column(
                      children: List.generate(subAgents.length, (index) {
                        final sub = subAgents[index];
                        final number = _numberForIndex(index);

                        return AppleInteractiveWrapper(
                          onTap: () => onOpenSubAgent(sub),
                          pressedScale: 0.99,
                          semanticLabel: 'Buka ${sub.name}, ${sub.description}',
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 66),
                            decoration: BoxDecoration(
                              border: index < subAgents.length - 1
                                  ? const Border(
                                      bottom: BorderSide(
                                        color: _hairline,
                                        width: 0.8,
                                      ),
                                    )
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 34,
                                  child: Text(
                                    number,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.35,
                                      color: _muted,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 26,
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        sub.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.1,
                                          color: _pearl,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        sub.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w400,
                                          color: _muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.north_east_rounded,
                                  size: 16,
                                  color: _silver,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    Container(height: 0.8, color: _hairline),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: AppleInteractiveWrapper(
                            onTap: onOpenIntroduction ??
                                () => TahawwulatIntroductionSheet.show(
                                      context,
                                      agent: agent,
                                      onSelectSubAgent: onOpenSubAgent,
                                      onOpenMain: onOpenMain,
                                    ),
                            pressedScale: 0.985,
                            borderRadius: BorderRadius.circular(10),
                            semanticLabel: 'Mengenal Fikih Tahawwulat',
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: _pearl,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.auto_stories_rounded,
                                    size: 18,
                                    color: _obsidian,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Mengenal Fikih Tahawwulat',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.15,
                                        color: _obsidian,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 17,
                                    color: _obsidian,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (onOpenLibrary != null) ...[
                          const SizedBox(width: 10),
                          AppleInteractiveWrapper(
                            onTap: onOpenLibrary,
                            pressedScale: 0.96,
                            borderRadius: BorderRadius.circular(10),
                            semanticLabel: 'Buka pustaka ${agent.title}',
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _graphite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  width: 0.8,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.auto_stories_outlined,
                                size: 19,
                                color: _pearl,
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
      ),
    );
  }
}

/// Kilau diagonal yang sangat tipis menjadi satu-satunya ornamen dekoratif.
class _ObsidianDetailPainter extends CustomPainter {
  const _ObsidianDetailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawLine(
      Offset(size.width * 0.72, 0),
      Offset(size.width, size.height * 0.20),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.82, 0),
      Offset(size.width, size.height * 0.12),
      linePaint,
    );

    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.045),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(size.width * 0.48, 0, size.width * 0.52, size.height),
      );

    final sheen = Path()
      ..moveTo(size.width * 0.68, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.44)
      ..close();
    canvas.drawPath(sheen, sheenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
