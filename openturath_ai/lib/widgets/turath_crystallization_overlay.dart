import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TurathLoadingOverlay
/// Overlay transisi loading yang ringan, bersih, elegan, dan instan.
/// Menghindari komputasi berat agar aplikasi tetap responsif dan mulus.
class TurathCrystallizationOverlay extends StatefulWidget {
  final String agentTitle;
  final String? agentCategory;
  final bool isReady;
  final VoidCallback onTransitionComplete;

  const TurathCrystallizationOverlay({
    super.key,
    required this.agentTitle,
    this.agentCategory,
    required this.isReady,
    required this.onTransitionComplete,
  });

  @override
  State<TurathCrystallizationOverlay> createState() => _TurathCrystallizationOverlayState();
}

class _TurathCrystallizationOverlayState extends State<TurathCrystallizationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Jika sudah langsung siap saat pertama mount
    if (widget.isReady) {
      _finish();
    }
  }

  @override
  void didUpdateWidget(covariant TurathCrystallizationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReady && !oldWidget.isReady && !_hasCompleted) {
      _finish();
    }
  }

  void _finish() {
    if (_hasCompleted) return;
    _hasCompleted = true;
    // Delay minimal 200ms agar transisi terasa natural dan tidak berkedip kasar
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        widget.onTransitionComplete();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgVoid = Color(0xFF090D16);
    const accentEmerald = Color(0xFF10B981);
    const accentCyan = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: bgVoid,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Glowing Ambient Icon ──
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentCyan.withValues(alpha: 0.25),
                          accentEmerald.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: accentCyan.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentCyan.withValues(alpha: 0.15),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: Color(0xFFF8FAFC),
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Agent Title ──
                Text(
                  widget.agentTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF8FAFC),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Category Badge (if any) ──
                if (widget.agentCategory != null && widget.agentCategory!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      widget.agentCategory!,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ] else ...[
                  const SizedBox(height: 20),
                ],

                // ── Simple Elegant Status ──
                Text(
                  'Menyiapkan ruang telaah...',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Sleek Minimal Progress Line ──
                SizedBox(
                  width: 72,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: const LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Color(0x1FFFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(accentCyan),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
