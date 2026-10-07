import 'package:flutter/material.dart';
import '../core/design/ot_expressive.dart';

/// Generated illustration; textual controls supply the accessible equivalent.
class TahawwulatArtwork extends StatelessWidget {
  const TahawwulatArtwork({super.key, this.blendEdges = true});
  final bool blendEdges;
  static const asset = 'assets/images/tahawwulat-sculpture-v2.png';
  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        filterQuality: FilterQuality.medium);
    return AspectRatio(
        aspectRatio: 1,
        child: blendEdges
            ? ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          OTExpressive.transparent,
                          OTExpressive.white,
                          OTExpressive.white,
                          OTExpressive.transparent
                        ],
                        stops: [
                          0,
                          .14,
                          .86,
                          1
                        ]).createShader(rect),
                child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              OTExpressive.transparent,
                              OTExpressive.white,
                              OTExpressive.white,
                              OTExpressive.transparent
                            ],
                            stops: [
                              0,
                              .14,
                              .86,
                              1
                            ]).createShader(rect),
                    child: image))
            : ClipRRect(borderRadius: BorderRadius.circular(OTExpressive.compactHeroRadius), child: image));
  }
}

/// Low-contrast architectural curves keep the reading area calm.
class TahawwulatHeroSurface extends StatelessWidget {
  const TahawwulatHeroSurface(
      {super.key,
      required this.child,
      required this.padding,
      required this.radius});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
          color: OTExpressive.hero,
          child: Stack(children: [
            const Positioned.fill(
                child: ExcludeSemantics(
                    child: CustomPaint(painter: _QuietFoldsPainter()))),
            Padding(padding: padding, child: child),
          ])));
}

class _QuietFoldsPainter extends CustomPainter {
  const _QuietFoldsPainter();
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final path = Path()
        ..moveTo(size.width * (.32 + i * .13), -40)
        ..cubicTo(
            size.width * .92,
            size.height * .10,
            size.width * .18,
            size.height * .74,
            size.width * (1.02 + i * .08),
            size.height * 1.15);
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 30 + i * 20
            ..color = OTExpressive.white.withValues(alpha: .014 + i * .006));
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = OTExpressive.white.withValues(alpha: .03));
    }
  }

  @override
  bool shouldRepaint(covariant _QuietFoldsPainter oldDelegate) => false;
}
