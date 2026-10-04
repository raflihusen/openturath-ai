import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/product_pricing.dart';

class PromoPrice extends StatelessWidget {
  const PromoPrice({super.key, required this.amount, required this.regularAmount,
    this.period = '', this.compact = false, this.foregroundColor,
    this.secondaryColor});
  final int amount;
  final int regularAmount;
  final String period;
  final bool compact;
  final Color? foregroundColor;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final saving = regularAmount > 0
        ? ((regularAmount - amount) * 100 / regularAmount).round()
        : 0;
    final foreground = foregroundColor ?? OTColors.textPrimary(dark);
    final secondary = secondaryColor ?? OTColors.textSecondary(dark);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (regularAmount > amount) Text(ProductPricing.rupiah(regularAmount),
        semanticsLabel: Loc.tr('normalPrice', [ProductPricing.rupiah(regularAmount)]),
        style: OTTypography.caption(color: secondary)
          .copyWith(decoration: TextDecoration.lineThrough)),
      Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, children: [
        Directionality(textDirection: TextDirection.ltr, child: Text(ProductPricing.rupiah(amount),
          style: OTTypography.price(color: foreground).copyWith(fontSize: compact ? OTFontSize.s18 : OTFontSize.s26))),
        Text(period, style: OTTypography.caption(color: secondary)),
      ]),
      if (regularAmount > amount && !compact) Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text('${Loc.tr('launchOffer')} · ${Loc.tr('saving', ['$saving'])}',
          style: OTTypography.captionMedium(color: secondary))),
    ]);
  }
}
