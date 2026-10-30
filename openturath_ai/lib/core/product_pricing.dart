import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'localization.dart';

/// Harga perdana resmi. Nilai Rupiah berupa integer, tanpa perhitungan float.
class SubscriptionOffer {
  const SubscriptionOffer(
      {required this.plan,
      required this.months,
      required this.regularAmount,
      required this.amount});
  final String plan;
  final int months;
  final int regularAmount;
  final int amount;
  int get savingsPercent =>
      ((regularAmount - amount) * 100 / regularAmount).round();
  String get title => Loc.tr(months == 1
      ? 'oneMonth'
      : months == 6
          ? 'sixMonths'
          : 'oneYear');
  String get period => Loc.tr(months == 1
      ? 'perMonth'
      : months == 6
          ? 'perSixMonths'
          : 'perYear');
  String get priceLabel => ProductPricing.rupiah(amount);
  Map<String, dynamic> toMap() => {
        'name': title, 'price': amount, 'regularPrice': regularAmount,
        'label': priceLabel, 'period': period, 'planId': plan,
        // Harga toko eksternal harus disinkronkan oleh pengelola sebelum dipakai.
        'applyUrl': '',
      };
}

abstract final class ProductPricing {
  static const defaultRevision = 'harga-v92-2026-10-14';
  static String _currentRevision = defaultRevision;
  static String get revision => _currentRevision;
  static set revision(String value) {
    if (value.isNotEmpty) _currentRevision = value;
  }

  static const defaultSpecialist = SubscriptionOffer(
      plan: 'tholib_1m', months: 1, regularAmount: 300000, amount: 49000);
  static const defaultSpecialists = [
    defaultSpecialist,
    SubscriptionOffer(
        plan: 'tholib_6m', months: 6, regularAmount: 1200000, amount: 299000),
    SubscriptionOffer(
        plan: 'bahits_1y', months: 12, regularAmount: 2400000, amount: 499000),
  ];
  static const defaultTahawwulat = [
    SubscriptionOffer(
        plan: 'tholib_1m', months: 1, regularAmount: 1000000, amount: 299000),
    SubscriptionOffer(
        plan: 'tholib_6m', months: 6, regularAmount: 2995000, amount: 1499000),
    SubscriptionOffer(
        plan: 'bahits_1y', months: 12, regularAmount: 4995000, amount: 1999000),
  ];

  static List<SubscriptionOffer> _specialists = List.of(defaultSpecialists);
  static List<SubscriptionOffer> _tahawwulat = List.of(defaultTahawwulat);

  static SubscriptionOffer get specialist => _specialists.first;
  static List<SubscriptionOffer> get specialists => _specialists;
  static List<SubscriptionOffer> get tahawwulat => _tahawwulat;

  static void updateOffers({
    String? revision,
    Map<String, dynamic>? tahawwulatMap,
    Map<String, dynamic>? specialistsMap,
  }) {
    if (revision != null && revision.isNotEmpty) {
      _currentRevision = revision;
    }
    if (tahawwulatMap != null) {
      _tahawwulat = [
        _buildOffer('tholib_1m', 1, 1000000, 299000, tahawwulatMap),
        _buildOffer('tholib_6m', 6, 2995000, 1499000, tahawwulatMap),
        _buildOffer('bahits_1y', 12, 4995000, 1999000, tahawwulatMap),
      ];
    }
    if (specialistsMap != null) {
      _specialists = [
        _buildOffer('tholib_1m', 1, 300000, 49000, specialistsMap),
        _buildOffer('tholib_6m', 6, 1200000, 299000, specialistsMap),
        _buildOffer('bahits_1y', 12, 2400000, 499000, specialistsMap),
      ];
    }
  }

  static SubscriptionOffer _buildOffer(
    String plan,
    int months,
    int defaultRegular,
    int defaultAmount,
    Map<String, dynamic> planMap,
  ) {
    final entry = planMap[plan];
    int amount = defaultAmount;
    int regular = defaultRegular;
    if (entry is Map) {
      if (entry['amount'] is int && (entry['amount'] as int) > 0) {
        amount = entry['amount'] as int;
      }
      if (entry['regularAmount'] is int &&
          (entry['regularAmount'] as int) > 0) {
        regular = entry['regularAmount'] as int;
      }
    } else if (entry is int && entry > 0) {
      amount = entry;
    }
    return SubscriptionOffer(
      plan: plan,
      months: months,
      regularAmount: regular,
      amount: amount,
    );
  }

  static List<SubscriptionOffer> forAgent(String agentId) =>
      agentId.startsWith('fiqh_tahawwulat') ? tahawwulat : specialists;
  static String rupiah(int amount) =>
      'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
}

class ProductPricingService {
  static DateTime? _lastFetch;

  /// Segarkan penawaran setelah server menolak harga lama. Detail harga dari
  /// callable terautentikasi tetap dapat dipakai bila pembacaan konfigurasi gagal.
  /// Ini hanya memperbarui tampilan; checkout tetap memerlukan ketukan baru.
  static Future<void> refreshCheckoutOffer({
    required String agentId,
    required String plan,
    required dynamic details,
    Future<void> Function()? reload,
  }) async {
    try {
      await (reload ?? () => syncPricing(forceRefresh: true))();
    } catch (_) {
      // Detail harga server tetap tersedia meski konfigurasi gagal dibaca.
    }
    if (details is! Map ||
        details['reason'] != 'price_changed' ||
        details['agentId'] != agentId ||
        details['plan'] != plan) return;
    final amount = details['amount'];
    final revision = details['pricingRevision'];
    if (amount is! int ||
        amount <= 0 ||
        revision is! String ||
        revision.isEmpty) return;
    final offers = ProductPricing.forAgent(agentId);
    if (!offers.any((offer) => offer.plan == plan)) return;
    final updated = <String, dynamic>{
      for (final offer in offers)
        offer.plan: {
          'amount': offer.plan == plan ? amount : offer.amount,
          'regularAmount': offer.regularAmount,
        },
    };
    ProductPricing.updateOffers(
      revision: revision,
      tahawwulatMap: agentId.startsWith('fiqh_tahawwulat') ? updated : null,
      specialistsMap: agentId.startsWith('fiqh_tahawwulat') ? null : updated,
    );
  }

  static Future<void> syncPricing(
      {bool forceRefresh = false, FirebaseFirestore? firestore}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _lastFetch != null &&
        now.difference(_lastFetch!).inSeconds < 60) {
      return;
    }
    try {
      final db = firestore ??
          (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);
      if (db == null) return;

      final doc = await db
          .collection('app_config')
          .doc('pricing')
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 3));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final revision = data['revision'] as String?;
        final plans = data['plans'];
        Map<String, dynamic>? tahawwulat;
        Map<String, dynamic>? specialists;
        if (plans is Map) {
          if (plans['fiqh_tahawwulat'] is Map) {
            tahawwulat =
                Map<String, dynamic>.from(plans['fiqh_tahawwulat'] as Map);
          }
          if (plans['specialists'] is Map) {
            specialists =
                Map<String, dynamic>.from(plans['specialists'] as Map);
          }
        }
        // Fallback jika dokumen Firestore menggunakan format datar (flat keys)
        if (specialists == null && data['tholib_1m'] != null) {
          final p1m = data['tholib_1m'] is int
              ? data['tholib_1m'] as int
              : int.tryParse(data['tholib_1m'].toString()) ?? 49000;
          specialists = {
            'tholib_1m': {'amount': p1m, 'regularAmount': 300000},
          };
        }
        if (tahawwulat == null &&
            (data['tahawwulat_1m'] != null || data['tholib_1m'] != null)) {
          final t1m = (data['tahawwulat_1m'] ?? data['tholib_1m']) is int
              ? (data['tahawwulat_1m'] ?? data['tholib_1m']) as int
              : int.tryParse((data['tahawwulat_1m'] ?? data['tholib_1m'])
                      .toString()) ??
                  299000;
          tahawwulat = {
            'tholib_1m': {'amount': t1m, 'regularAmount': 1000000},
          };
        }
        ProductPricing.updateOffers(
          revision: revision,
          tahawwulatMap: tahawwulat,
          specialistsMap: specialists,
        );
        _lastFetch = now;
      }
    } catch (_) {
      // Graceful fallback to default constants
    }
  }
}
