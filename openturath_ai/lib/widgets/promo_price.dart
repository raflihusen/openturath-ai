import 'package:flutter/material.dart';
import '../core/design/native_design.dart';
import '../core/design/native_typography.dart';
import '../core/localization.dart';
import '../core/product_pricing.dart';

class PromoPrice extends StatelessWidget {
  const PromoPrice(
      {super.key,
      required this.amount,
      required this.regularAmount,
      this.period = '',
      this.compact = false});
  final int amount;
  final int regularAmount;
  final String period;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final saving = ((regularAmount - amount) * 100 / regularAmount).round();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (regularAmount > amount)
        Text(ProductPricing.rupiah(regularAmount),
            semanticsLabel:
                Loc.tr('normalPrice', [ProductPricing.rupiah(regularAmount)]),
            style: NativeTypography.caption(
                    color: NativeColors.textSecondary(dark))
                .copyWith(decoration: TextDecoration.lineThrough)),
      Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: Text(ProductPricing.rupiah(amount),
                    style: NativeTypography.price(
                            color: NativeColors.textPrimary(dark))
                        .copyWith(fontSize: compact ? 18 : 28))),
            Text(period,
                style: NativeTypography.caption(
                    color: NativeColors.textSecondary(dark))),
          ]),
      if (regularAmount > amount && !compact)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
                '${Loc.tr('launchOffer')} · ${Loc.tr('saving', ['$saving'])}',
                style: NativeTypography.captionMedium(
                    color: NativeColors.textSecondary(dark)))),
    ]);
  }
}
