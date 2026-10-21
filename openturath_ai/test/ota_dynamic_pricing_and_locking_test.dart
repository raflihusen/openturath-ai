import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/product_pricing.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/services/agent_service.dart';

void main() {
  group('OTA Dynamic Locking & Pricing Tests', () {
    test('AgentModel copyWith preserves fields and updates status', () {
      final syafii =
          AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_syafii');
      expect(syafii.isActive, isTrue);

      final lockedCopy = syafii.copyWith(status: 'coming_soon');
      expect(lockedCopy.id, equals('fiqh_syafii'));
      expect(lockedCopy.title, equals(syafii.title));
      expect(lockedCopy.isComingSoon, isTrue);
      expect(lockedCopy.isLocked, isTrue);
      expect(lockedCopy.isActive, isFalse);

      final activeCopy = lockedCopy.copyWith(status: 'active');
      expect(activeCopy.isActive, isTrue);
      expect(activeCopy.isLocked, isFalse);
    });

    test('AgentService getAgents applies default launch whitelist', () async {
      final service = AgentService();
      final agents = await service.getAgents();

      // Memastikan hanya Fikih Tahawwulat & Fikih Syafi'i yang berstatus aktif secara default
      final activeAgents = agents.where((a) => a.isActive).toList();
      final lockedAgents = agents.where((a) => a.isComingSoon).toList();

      expect(activeAgents.map((a) => a.id), contains('fiqh_tahawwulat'));
      expect(activeAgents.map((a) => a.id), contains('fiqh_syafii'));
      expect(activeAgents.map((a) => a.id), isNot(contains('fiqh_hanafi')));
      expect(activeAgents.map((a) => a.id), isNot(contains('hadits')));

      // 16 disiplin spesialis lainnya berstatus coming_soon / locked
      expect(lockedAgents.map((a) => a.id), contains('fiqh_hanafi'));
      expect(lockedAgents.map((a) => a.id), contains('fiqh_maliki'));
      expect(lockedAgents.map((a) => a.id), contains('fiqh_hanbali'));
      expect(lockedAgents.map((a) => a.id), contains('hadits'));
      expect(lockedAgents.map((a) => a.id), contains('tafsir'));
      expect(lockedAgents.map((a) => a.id), contains('tasawwuf'));
    });

    test('AgentService getActiveAgentsSync matches active whitelist and isolates unreleased agents', () {
      final agents = AgentService.getActiveAgentsSync();
      final active = agents.where((a) => a.isActive && !a.isComingSoon).toList();
      final unreleased = agents.where((a) => a.isComingSoon).toList();

      expect(active.map((a) => a.id), contains('fiqh_tahawwulat'));
      expect(active.map((a) => a.id), contains('fiqh_syafii'));

      // 16 disiplin unreleased harus berstatus coming_soon / locked
      expect(unreleased.map((a) => a.id), contains('fiqh_hanafi'));
      expect(unreleased.map((a) => a.id), contains('hadits'));
      expect(unreleased.map((a) => a.id), contains('tafsir'));

      // Filter spesialis untuk langganan hanya menyertakan yang aktif/rilis (bukan coming_soon dan bukan flagship)
      final specialistsForSubscription = agents
          .where((a) =>
              a.kind == CorpusKind.discipline &&
              a.isActive &&
              !a.isComingSoon &&
              a.id != 'fiqh_tahawwulat')
          .toList();

      expect(specialistsForSubscription.map((a) => a.id), contains('fiqh_syafii'));
      expect(specialistsForSubscription.map((a) => a.id), isNot(contains('fiqh_hanafi')));
      expect(specialistsForSubscription.map((a) => a.id), isNot(contains('hadits')));
      expect(specialistsForSubscription.map((a) => a.id), isNot(contains('tafsir')));
    });

    test(
        'ProductPricing updateOffers dynamically overrides nominal and revision',
        () {
      // Default revision
      expect(ProductPricing.revision, isNotEmpty);
      final initialTahawwulat1m = ProductPricing.tahawwulat.first.amount;
      expect(initialTahawwulat1m, equals(300000));

      // Simulate OTA Firestore update with Rp 1.000 test pricing
      ProductPricing.updateOffers(
        revision: 'harga-ota-test-1k',
        tahawwulatMap: {
          'tholib_1m': {'amount': 1000, 'regularAmount': 1000000},
        },
      );

      expect(ProductPricing.revision, equals('harga-ota-test-1k'));
      final updatedOffer = ProductPricing.tahawwulat.first;
      expect(updatedOffer.amount, equals(1000));
      expect(updatedOffer.priceLabel, equals('Rp 1.000'));
      expect(updatedOffer.savingsPercent,
          equals(100)); // 1.000 vs 1.000.000 = ~100%

      // Restore to default official price
      ProductPricing.updateOffers(
        revision: ProductPricing.defaultRevision,
        tahawwulatMap: {
          'tholib_1m': {'amount': 300000, 'regularAmount': 1000000},
        },
      );
      expect(ProductPricing.tahawwulat.first.amount, equals(300000));
      expect(ProductPricing.revision, equals(ProductPricing.defaultRevision));
    });
  });
}
