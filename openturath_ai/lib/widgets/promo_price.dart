import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
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
    final normalLabel = ProductPricing.formatLocalPrice(regularAmount);
    final promoLabel = ProductPricing.formatLocalPrice(amount);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (regularAmount > amount)
        Wrap(
            spacing: OTSpacing.sm,
            runSpacing: OTSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(normalLabel,
                  semanticsLabel: Loc.tr('normalPrice', [normalLabel]),
                  style: OTTypography.caption(color: secondary)
                      .copyWith(decoration: TextDecoration.lineThrough)),
              if (inlineSaving && !compact && saving >= 5)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: OTSpacing.sm, vertical: OTSpacing.xxs),
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.12),
                    borderRadius: OTRadius.chipBorder,
                    border:
                        Border.all(color: foreground.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    Loc.isArabic
                        ? 'خصم $saving٪'
                        : (Loc.language == 'en'
                            ? '$saving% Off'
                            : 'Diskon $saving%'),
                    style: OTTypography.metadataTag(color: foreground),
                  ),
                ),
            ]),
      Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Directionality(
                textDirection:
                    Loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
                // Harga tidak pernah terbelah antar baris: mengecil bila sempit.
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(promoLabel,
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
                Loc.tr('saving', ['$saving']),
                style: OTTypography.captionMedium(color: secondary))),
    ]);
  }
}
