import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/product_pricing.dart';

class PromoPrice extends StatelessWidget {
  const PromoPrice(
      {super.key,
      required this.amount,
      required this.regularAmount,
      this.period = '',
      this.compact = false,
      this.display = false,
      this.inlineSaving = false,
      this.foregroundColor,
      this.secondaryColor});
  final int amount;
  final int regularAmount;
  final String period;
  final bool compact;

  /// Harga utama layar: satu kali per layar, untuk paket unggulan.
  final bool display;

  /// Label "Harga perdana" ditulis di samping harga coret, tanpa baris
  /// persen hemat terhadap harga normal.
  final bool inlineSaving;
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
      if (regularAmount > amount)
        Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(ProductPricing.rupiah(regularAmount),
                  semanticsLabel: Loc.tr(
                      'normalPrice', [ProductPricing.rupiah(regularAmount)]),
                  style: OTTypography.caption(color: secondary)
                      .copyWith(decoration: TextDecoration.lineThrough)),
              if (inlineSaving)
                Text(Loc.tr('launchOffer'),
                    style: OTTypography.captionMedium(color: foreground)),
            ]),
      Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                // Harga tidak pernah terbelah antar baris: mengecil bila sempit.
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(ProductPricing.rupiah(amount),
                        maxLines: 1,
                        style: OTTypography.price(color: foreground).copyWith(
                            fontSize: compact
                                ? OTFontSize.s18
                                : display
                                    ? OTFontSize.s36
                                    : OTFontSize.s26)))),
            Text(period, style: OTTypography.caption(color: secondary)),
          ]),
      if (regularAmount > amount && !compact && !inlineSaving)
        Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
                '${Loc.tr('launchOffer')} · ${Loc.tr('saving', ['$saving'])}',
                style: OTTypography.captionMedium(color: secondary))),
    ]);
  }
}
