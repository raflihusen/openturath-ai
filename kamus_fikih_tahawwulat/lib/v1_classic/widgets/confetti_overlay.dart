import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'glass_panel.dart';

class ConfettiCelebrationOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const ConfettiCelebrationOverlay({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  State<ConfettiCelebrationOverlay> createState() => _ConfettiCelebrationOverlayState();
}

class _ConfettiCelebrationOverlayState extends State<ConfettiCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward().then((_) {
        if (mounted) widget.onDismiss();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.55),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti particles exploding outward
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = _controller.value;
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(32, (i) {
                    final angle = (i / 32) * 2 * math.pi;
                    final distance = progress * 190.0 + (i % 4) * 16.0;
                    final dx = math.cos(angle) * distance;
                    final dy = math.sin(angle) * distance + (progress * progress * 80.0);
                    final opacity = (1.0 - progress).clamp(0.0, 1.0);
                    final color = HSVColor.fromAHSV(1.0, (i * 12.0) % 360, 0.85, 0.95).toColor();

                    return Transform.translate(
                      offset: Offset(dx, dy),
                      child: Transform.rotate(
                        angle: angle + (progress * 4 * math.pi),
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 9,
                            height: 14,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            // Center glass celebration message card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GlassPanel(
                isThick: true,
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎉',
                      style: TextStyle(fontSize: 44),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: widget.onDismiss,
                      child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
