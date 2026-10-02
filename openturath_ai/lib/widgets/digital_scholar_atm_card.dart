import 'package:flutter/material.dart';

import '../core/localization.dart';
import '../core/membership_pass_state.dart';
import '../core/scholarly_fonts.dart';
import '../models/user_model.dart';
import 'apple_interactive_wrapper.dart';

/// Kartu Santri Digital / Scholar ATM Black Card Luxury
/// Desain monokrom noir berstandar kartu kredit/debit fisik premium:
/// - Gradasi obsidian matte dengan pantulan cahaya radial
/// - EMV Chip kuningan/emas dengan sirkuit mikro
/// - Simbol contactless wave NFC
/// - Nomor kartu bertitik monospaced berjarak
/// - Identitas pemegang kartu & masa berlaku
class DigitalScholarAtmCard extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onTap;
  final String? tierLabel;
  final String? cardNumber;
  final String? expiryText;

  const DigitalScholarAtmCard({
    super.key,
    this.user,
    this.onTap,
    this.tierLabel,
    this.cardNumber,
    this.expiryText,
  });

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final summary = resolveMembershipPass(user);

    final rawName = user?.name.trim() ?? '';
    final name = rawName.isNotEmpty ? rawName.toUpperCase() : 'M. FULAN (SANTRI)';

    final tier = tierLabel ??
        (summary.state == MembershipPassState.permanent
            ? 'SCHOLAR PASS · PERMANEN'
            : (summary.isOpen
                ? 'SCHOLAR PASS · ${summary.badge}'
                : 'TALIB AL-ILM · TIER I'));

    final displayCardNumber = cardNumber ?? '••••  ••••  ••••  1448';
    
    final expiry = expiryText ??
        (summary.state == MembershipPassState.permanent
            ? Loc.tr('permanent')
            : (summary.expiresAt != null
                ? '${summary.expiresAt!.month.toString().padLeft(2, '0')}/${summary.expiresAt!.year.toString().substring(2)}'
                : '1448 H'));

    return Semantics(
      label: 'Kartu Santri Digital OpenTurath $tier untuk $name',
      button: onTap != null,
      child: AppleInteractiveWrapper(
        onTap: onTap,
        pressedScale: 0.98,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF222226),
                Color(0xFF141417),
                Color(0xFF09090B),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: dark ? 0.22 : 0.16),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.45 : 0.16),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Radial highlight ambient light di sudut kanan atas
              Positioned(
                top: -60,
                right: -60,
                width: 220,
                height: 220,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Row: Brand & NFC Wave
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  width: 1.8,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'OpenTurath',
                              textDirection: TextDirection.ltr,
                              style: ScholarlyFonts.newsreader(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),

                        // NFC Contactless Wave
                        _NfcContactlessIcon(),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Middle Row: EMV Metal Chip & Tier Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _EmvChip(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            tier,
                            style: ScholarlyFonts.outfit(
                              color: const Color(0xFFE4E4E7),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Card Number (Atm embossed monospace)
                    Text(
                      displayCardNumber,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.2,
                        color: Color(0xFFF4F4F5),
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1.5),
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Bottom Row: Card Holder & Valid Thru
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CARD HOLDER',
                                style: ScholarlyFonts.outfit(
                                  color: const Color(0xFFA1A1AA),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ScholarlyFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'VALID THRU',
                              style: ScholarlyFonts.outfit(
                                color: const Color(0xFFA1A1AA),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              expiry,
                              style: ScholarlyFonts.outfit(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
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

/// EMV Metal Chip realistis dengan gradasi emas satin dan ukiran kontak
class _EmvChip extends StatelessWidget {
  const _EmvChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4AF37),
            Color(0xFFF3E5AB),
            Color(0xFFAA820A),
          ],
        ),
        border: Border.all(color: const Color(0xFF8C6D13), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 1.5),
            blurRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner circuit border
          Positioned(
            top: 5,
            bottom: 5,
            left: 7,
            right: 7,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
            ),
          ),
          // Horizontal divider
          Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),
          // Vertical divider
          Positioned(
            top: 5,
            bottom: 5,
            left: 19,
            child: Container(
              width: 1,
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

/// NFC Contactless Wave icon
class _NfcContactlessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 20),
      painter: _NfcPainter(),
    );
  }
}

class _NfcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;

    // Arc 1 (inner)
    final rect1 = Rect.fromCircle(center: Offset(4, centerY), radius: 6);
    canvas.drawArc(rect1, -0.85, 1.7, false, paint);

    // Arc 2 (middle)
    final rect2 = Rect.fromCircle(center: Offset(4, centerY), radius: 10.5);
    canvas.drawArc(rect2, -0.85, 1.7, false, paint);

    // Arc 3 (outer)
    final rect3 = Rect.fromCircle(center: Offset(4, centerY), radius: 15);
    canvas.drawArc(rect3, -0.85, 1.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
