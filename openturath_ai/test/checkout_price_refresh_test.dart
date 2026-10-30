import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/product_pricing.dart';

void main() {
  setUp(() => ProductPricing.updateOffers(
    revision: ProductPricing.defaultRevision,
    specialistsMap: {}, tahawwulatMap: {},
  ));
  tearDown(() => ProductPricing.updateOffers(
    revision: ProductPricing.defaultRevision,
    specialistsMap: {}, tahawwulatMap: {},
  ));

  test('fresh server quote replaces stale price despite config reload failure', () async {
    var reloads = 0;
    final oldYear = ProductPricing.specialists.last.amount;
    final oldTahawwulat = ProductPricing.tahawwulat.first.amount;
    await ProductPricingService.refreshCheckoutOffer(
      agentId: 'fiqh_syafii', plan: 'tholib_1m',
      details: {'reason': 'price_changed', 'agentId': 'fiqh_syafii', 'plan': 'tholib_1m',
        'amount': 59000, 'pricingRevision': 'fresh-revision'},
      reload: () async { reloads++; throw StateError('config unavailable'); },
    );
    expect(reloads, 1);
    expect(ProductPricing.specialists.first.amount, 59000);
    expect(ProductPricing.specialists.first.priceLabel, 'Rp 59.000');
    expect(ProductPricing.revision, 'fresh-revision');
    expect(ProductPricing.specialists.last.amount, oldYear);
    expect(ProductPricing.tahawwulat.first.amount, oldTahawwulat);
  });

  test('mismatched product plan malformed amount and missing revision are ignored', () async {
    final valid = <String, dynamic>{'reason': 'price_changed', 'agentId': 'fiqh_syafii',
      'plan': 'tholib_1m', 'amount': 59000, 'pricingRevision': 'fresh'};
    for (final invalid in [
      {...valid, 'agentId': 'fiqh_tahawwulat'}, {...valid, 'plan': 'bahits_1y'},
      {...valid, 'amount': -1}, {...valid, 'amount': 59000.5},
      {...valid, 'pricingRevision': ''}, {...valid, 'reason': 'unavailable'},
    ]) {
      await ProductPricingService.refreshCheckoutOffer(
        agentId: 'fiqh_syafii', plan: 'tholib_1m', details: invalid, reload: () async {},
      );
      expect(ProductPricing.specialists.first.amount, 49000);
      expect(ProductPricing.revision, ProductPricing.defaultRevision);
    }
  });
}
