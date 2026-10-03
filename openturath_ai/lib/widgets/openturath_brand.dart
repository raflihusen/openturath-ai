import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_copy.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';

class OpenTurathMark extends StatelessWidget {
  const OpenTurathMark({super.key, this.size = 36, this.color});
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(label: Loc.tr('appName'), image: true,
      // Koreksi optis: titik berat logo lebih rendah dari pusat kotaknya.
      child: Transform.translate(
        offset: Offset(0, -size * 0.02),
        child: SvgPicture.asset('assets/images/OpenTurath_logo_transparent.svg',
          width: size, height: size, fit: BoxFit.contain,
          excludeFromSemantics: true,
          colorFilter: ColorFilter.mode(color ?? OTColors.textPrimary(dark), BlendMode.srcIn))));
  }
}

class OpenTurathBrand extends StatelessWidget {
  const OpenTurathBrand({super.key, this.compact = false, this.onDark = false, this.showSlogan = false});
  final bool compact;
  final bool onDark;
  final bool showSlogan;
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = onDark || Theme.of(context).brightness == Brightness.dark;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      OpenTurathMark(size: compact ? 28 : 36, color: OTColors.textPrimary(dark)),
      const SizedBox(width: 10),
      Flexible(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Latin wordmark is a brand asset, independent of interface direction.
        Text('OpenTurath', textDirection: TextDirection.ltr,
          style: OTTypography.brandLogo(color: OTColors.textPrimary(dark)).copyWith(fontSize: compact ? 18 : 21)),
        if (showSlogan) Text(AppCopy.appTagline,
          style: OTTypography.caption(color: OTColors.textSecondary(dark))),
      ])),
    ]);
  }
}
