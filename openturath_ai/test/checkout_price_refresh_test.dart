import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/product_pricing.dart';
import 'package:openturath_ai/services/subscription_service.dart';

void main() {
  setUp(() => ProductPricing.updateOffers(
        revision: ProductPricing.defaultRevision,
        specialistsMap: {},
        tahawwulatMap: {},
      ));
  tearDown(() => ProductPricing.updateOffers(
        revision: ProductPricing.defaultRevision,
        specialistsMap: {},
        tahawwulatMap: {},
      ));

  test('fresh server quote replaces stale price despite config reload failure',
      () async {
    var reloads = 0;
    final oldYear = ProductPricing.specialists.last.amount;
    final oldTahawwulat = ProductPricing.tahawwulat.first.amount;
    final refreshed = await ProductPricingService.refreshCheckoutOffer(
      agentId: 'fiqh_syafii',
      plan: 'tholib_1m',
      details: {
        'reason': 'price_changed',
        'agentId': 'fiqh_syafii',
        'plan': 'tholib_1m',
        'amount': 59000,
        'pricingRevision': 'fresh-revision'
      },
      reload: () async {
        reloads++;
        throw StateError('config unavailable');
      },
    );
    expect(refreshed, isTrue);
    expect(reloads, 1);
    expect(ProductPricing.specialists.first.amount, 59000);
    expect(ProductPricing.specialists.first.priceLabel, 'Rp 59.000');
    expect(ProductPricing.revision, 'fresh-revision');
    expect(ProductPricing.specialists.last.amount, oldYear);
    expect(ProductPricing.tahawwulat.first.amount, oldTahawwulat);
  });

  test(
      'mismatched product plan malformed amount and missing revision are ignored',
      () async {
    final valid = <String, dynamic>{
      'reason': 'price_changed',
      'agentId': 'fiqh_syafii',
      'plan': 'tholib_1m',
      'amount': 59000,
      'pricingRevision': 'fresh'
    };
    for (final invalid in [
      {...valid, 'agentId': 'fiqh_tahawwulat'},
      {...valid, 'plan': 'bahits_1y'},
      {...valid, 'amount': -1},
      {...valid, 'amount': 59000.5},
      {...valid, 'pricingRevision': ''},
      {...valid, 'reason': 'unavailable'},
    ]) {
      final refreshed = await ProductPricingService.refreshCheckoutOffer(
        agentId: 'fiqh_syafii',
        plan: 'tholib_1m',
        details: invalid,
        reload: () async => false,
      );
      expect(refreshed, isFalse);
      expect(ProductPricing.specialists.first.amount, 49000);
      expect(ProductPricing.revision, ProductPricing.defaultRevision);
    }
  });

  test('only the exact legacy stale-price code and message trigger recovery',
      () {
    const message = 'Harga penawaran telah berubah. Muat ulang aplikasi.';
    bool stale(String code, String text, [Object? details]) =>
        SubscriptionService.isCheckoutPriceChange(
            code: code, message: text, details: details);
    expect(stale('failed-precondition', message), isTrue);
    expect(stale('unavailable', message), isFalse);
    expect(stale('failed-precondition', 'Paket tidak tersedia.'), isFalse);
    expect(stale('failed-precondition', '$message Extra'), isFalse);
    expect(stale('failed-precondition', message, {'reason': 'not_available'}),
        isFalse);
    expect(
        stale('failed-precondition', 'translated message',
            {'reason': 'price_changed'}),
        isTrue);
  });

  test(
      'legacy server without quote can refresh configuration without checkout retry',
      () async {
    var reloads = 0;
    final refreshed = await ProductPricingService.refreshCheckoutOffer(
      agentId: 'fiqh_syafii',
      plan: 'tholib_1m',
      details: null,
      reload: () async {
        reloads++;
        ProductPricing.updateOffers(
            revision: 'legacy-refreshed',
            specialistsMap: {
              'tholib_1m': {'amount': 59000, 'regularAmount': 300000},
            });
        return true;
      },
    );
    expect(refreshed, isTrue);
    expect(reloads, 1);
    expect(ProductPricing.specialists.first.priceLabel, 'Rp 59.000');
    expect(ProductPricing.revision, 'legacy-refreshed');
  });

  test(
      'legacy quote refresh failure is reported without claiming price changed',
      () async {
    for (final reload in <Future<bool> Function()>[
      () async => false,
      () async => throw StateError('offline'),
    ]) {
      final refreshed = await ProductPricingService.refreshCheckoutOffer(
        agentId: 'fiqh_syafii',
        plan: 'tholib_1m',
        details: null,
        reload: reload,
      );
      expect(refreshed, isFalse);
      expect(ProductPricing.specialists.first.amount, 49000);
      expect(ProductPricing.revision, ProductPricing.defaultRevision);
    }
  });
}
