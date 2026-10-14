import 'localization.dart';

/// Harga perdana resmi. Nilai Rupiah berupa integer, tanpa perhitungan float.
class SubscriptionOffer {
  const SubscriptionOffer({required this.plan, required this.months,
    required this.regularAmount, required this.amount});
  final String plan;
  final int months;
  final int regularAmount;
  final int amount;
  int get savingsPercent => ((regularAmount - amount) * 100 / regularAmount).round();
  String get title => Loc.tr(months == 1 ? 'oneMonth' : months == 6 ? 'sixMonths' : 'oneYear');
  String get period => Loc.tr(months == 1 ? 'perMonth' : months == 6 ? 'perSixMonths' : 'perYear');
  String get priceLabel => ProductPricing.rupiah(amount);
  Map<String, dynamic> toMap() => {
    'name': title, 'price': amount, 'regularPrice': regularAmount,
    'label': priceLabel, 'period': period, 'planId': plan,
    // Harga toko eksternal harus disinkronkan oleh pengelola sebelum dipakai.
    'applyUrl': '',
  };
}

abstract final class ProductPricing {
  static const revision = 'harga-v92-2026-10-14';
  static const specialist = SubscriptionOffer(
    plan: 'tholib_1m', months: 1, regularAmount: 300000, amount: 49000);
  static const specialists = [
    specialist,
    SubscriptionOffer(plan: 'tholib_6m', months: 6, regularAmount: 1200000, amount: 299000),
    SubscriptionOffer(plan: 'bahits_1y', months: 12, regularAmount: 2400000, amount: 499000),
  ];
  static const tahawwulat = [
    SubscriptionOffer(plan: 'tholib_1m', months: 1, regularAmount: 1000000, amount: 300000),
    SubscriptionOffer(plan: 'tholib_6m', months: 6, regularAmount: 2995000, amount: 1499000),
    SubscriptionOffer(plan: 'bahits_1y', months: 12, regularAmount: 4995000, amount: 1999000),
  ];
  static List<SubscriptionOffer> forAgent(String agentId) =>
      agentId.startsWith('fiqh_tahawwulat') ? tahawwulat : specialists;
  static String rupiah(int amount) => 'Rp ${amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
}
