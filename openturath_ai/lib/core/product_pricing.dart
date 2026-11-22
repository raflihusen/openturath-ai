import 'dart:convert';
import 'package:http/http.dart' as http;
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
  String get priceLabel => ProductPricing.formatLocalPrice(amount);
  Map<String, dynamic> toMap() => {
        'name': title, 'price': amount, 'regularPrice': regularAmount,
        'label': priceLabel, 'period': period, 'planId': plan,
        // Harga toko eksternal harus disinkronkan oleh pengelola sebelum dipakai.
        'applyUrl': '',
      };
}

/// Konfigurasi pembayaran transfer bank + WhatsApp khusus mode Bahasa Arab
/// yang dapat diaktifkan dan diubah secara OTA dari VPS / Firestore tanpa update app.
class ArabicPaymentConfig {
  const ArabicPaymentConfig({
    this.enabled = false,
    this.bankName = '',
    this.accountName = '',
    this.accountNumber = '',
    this.iban = '',
    this.whatsappNumber = '',
    this.note = '',
  });

  final bool enabled;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String iban;
  final String whatsappNumber;
  final String note;

  String get cleanWhatsapp => whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');

  bool get isAvailable =>
      enabled &&
      cleanWhatsapp.isNotEmpty &&
      (accountNumber.trim().isNotEmpty || iban.trim().isNotEmpty);

  static ArabicPaymentConfig? fromMap(Object? raw) {
    if (raw is! Map) return null;
    String str(String a, [String? b]) =>
        (raw[a] ?? (b != null ? raw[b] : null) ?? '').toString().trim();
    return ArabicPaymentConfig(
      enabled: raw['enabled'] == true,
      bankName: str('bankName', 'bank_name'),
      accountName: str('accountName', 'account_name'),
      accountNumber: str('accountNumber', 'account_number'),
      iban: str('iban', 'IBAN'),
      whatsappNumber: str('whatsappNumber', 'whatsapp_number'),
      note: str('note', 'trustNote'),
    );
  }
}

abstract final class ProductPricing {
  static const defaultRevision = 'harga-v92-2026-10-14';
  static String _currentRevision = defaultRevision;
  static ArabicPaymentConfig _arabicPayment = const ArabicPaymentConfig();
  static ArabicPaymentConfig get arabicPayment => _arabicPayment;
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
  static const defaultAllSpecialists = [
    SubscriptionOffer(
        plan: 'tholib_1m', months: 1, regularAmount: 1000000, amount: 299000),
    SubscriptionOffer(
        plan: 'tholib_6m', months: 6, regularAmount: 2995000, amount: 1299000),
    SubscriptionOffer(
        plan: 'bahits_1y', months: 12, regularAmount: 4995000, amount: 1799000),
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
  static List<SubscriptionOffer> _allSpecialists =
      List.of(defaultAllSpecialists);
  static List<SubscriptionOffer> _tahawwulat = List.of(defaultTahawwulat);
  static final Map<String, List<SubscriptionOffer>> _agentOffers = {};

  static SubscriptionOffer get specialist => _specialists.first;
  static List<SubscriptionOffer> get specialists => _specialists;
  static List<SubscriptionOffer> get allSpecialists => _allSpecialists;
  static List<SubscriptionOffer> get tahawwulat => _tahawwulat;

  static void updateOffers({
    String? revision,
    Map<String, dynamic>? tahawwulatMap,
    Map<String, dynamic>? specialistsMap,
    Map<String, List<SubscriptionOffer>>? agentOffersMap,
    ArabicPaymentConfig? arabicPaymentConfig,
  }) {
    if (revision != null && revision.isNotEmpty) {
      _currentRevision = revision;
    }
    if (arabicPaymentConfig != null) {
      _arabicPayment = arabicPaymentConfig;
    }
    if (agentOffersMap != null && agentOffersMap.isNotEmpty) {
      _agentOffers.clear();
      _agentOffers.addAll(agentOffersMap);
      if (_agentOffers.containsKey('fiqh_tahawwulat')) {
        _tahawwulat = List.of(_agentOffers['fiqh_tahawwulat']!);
      }
      if (_agentOffers.containsKey('all_specialists')) {
        _allSpecialists = List.of(_agentOffers['all_specialists']!);
      }
      if (_agentOffers.containsKey('fiqh_syafii')) {
        _specialists = List.of(_agentOffers['fiqh_syafii']!);
      }
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

  static bool hasOffersForAgent(String agentId) {
    if (_agentOffers.isNotEmpty) {
      return _agentOffers.containsKey(agentId);
    }
    return true;
  }

  static List<SubscriptionOffer> forAgent(String agentId) {
    if (_agentOffers.containsKey(agentId)) {
      return _agentOffers[agentId]!;
    }
    if (agentId == 'all_specialists' || agentId == 'all_disciplines') {
      return allSpecialists;
    }
    return agentId.startsWith('fiqh_tahawwulat') ? tahawwulat : specialists;
  }
  static const double sarPerIdrRate = 4868.0;

  /// Konversi nominal IDR ke Riyal Saudi (SAR) dengan pembulatan bersih:
  /// kelipatan 1 untuk < 50 SAR dan kelipatan 5 untuk >= 50 SAR.
  static int toSar(int idrAmount) {
    if (idrAmount <= 0) return 0;
    final raw = idrAmount / sarPerIdrRate;
    if (raw < 50) {
      final rounded = raw.round();
      return rounded < 1 ? 1 : rounded;
    }
    return ((raw / 5).round() * 5);
  }

  static String sar(int sarAmount) {
    final formatted = sarAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '$formatted ر.س';
  }

  static String sarDecimal(double sarAmount) {
    if (sarAmount >= 5) {
      return sar(sarAmount.round());
    }
    final fixed = sarAmount < 0.1 ? '0.1' : sarAmount.toStringAsFixed(1);
    return '${fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed} ر.س';
  }

  static String formatLocalPrice(int idrAmount) =>
      Loc.isArabic ? sar(toSar(idrAmount)) : rupiah(idrAmount);

  static String rupiah(int amount) =>
      'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
}

class ProductPricingService {
  static DateTime? _lastFetch;

  /// Segarkan penawaran setelah server menolak harga lama. Detail harga dari
  /// callable terautentikasi tetap dapat dipakai bila pembacaan konfigurasi gagal.
  /// Ini hanya memperbarui tampilan; checkout tetap memerlukan ketukan baru.
  static Future<bool> refreshCheckoutOffer({
    required String agentId,
    required String plan,
    required dynamic details,
    Future<bool> Function()? reload,
  }) async {
    var configurationLoaded = false;
    try {
      configurationLoaded =
          await (reload ?? () => syncPricing(forceRefresh: true))();
    } catch (_) {
      // Detail harga server tetap tersedia meski konfigurasi gagal dibaca.
    }
    if (details is! Map ||
        details['reason'] != 'price_changed' ||
        details['agentId'] != agentId ||
        details['plan'] != plan) {
      return configurationLoaded;
    }
    final amount = details['amount'];
    final revision = details['pricingRevision'];
    if (amount is! int ||
        amount <= 0 ||
        revision is! String ||
        revision.isEmpty) {
      return configurationLoaded;
    }
    final offers = ProductPricing.forAgent(agentId);
    if (!offers.any((offer) => offer.plan == plan)) return false;
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
    return true;
  }

  static Future<bool> syncPricing(
      {bool forceRefresh = false,
      FirebaseFirestore? firestore,
      http.Client? client}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _lastFetch != null &&
        now.difference(_lastFetch!).inSeconds < 60) {
      return true;
    }

    // 1. Prioritas Utama: OTA Dynamic Pricing langsung dari VPS API resmi
    final httpClient = client ?? http.Client();
    try {
      final res = await httpClient.get(
        Uri.parse('https://maktabah.openturath.id/api/v1/catalog/offers'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'OpenTurathApp/1.0',
        },
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map) {
          final revision = data['revision']?.toString();
          final arabicCfg = ArabicPaymentConfig.fromMap(
              data['arabicPayment'] ?? data['arabic_payment']);
          final agentOffersMap = <String, List<SubscriptionOffer>>{};

          if (data['offers'] is List) {
            final rawOffers = data['offers'] as List;
            for (final item in rawOffers) {
              if (item is Map &&
                  item['agentId'] is String &&
                  item['plans'] is List) {
                final agentId = item['agentId'] as String;
                final plans = item['plans'] as List;
                final offers = <SubscriptionOffer>[];

                for (final p in plans) {
                  if (p is Map) {
                    final planStr = p['plan']?.toString() ?? '';
                    final months = p['months'] is int
                        ? p['months'] as int
                        : int.tryParse(p['months']?.toString() ?? '1') ?? 1;
                    final amount = p['amount'] is int
                        ? p['amount'] as int
                        : int.tryParse(p['amount']?.toString() ?? '0') ?? 0;

                    // Hitung harga normal (regularAmount) coret jika tidak disediakan
                    int regular = 0;
                    if (p['regularAmount'] is int) {
                      regular = p['regularAmount'] as int;
                    } else if (p['regular_amount'] is int) {
                      regular = p['regular_amount'] as int;
                    } else {
                      if (months == 1) {
                        regular = amount >= 400000
                            ? 1000000
                            : (amount >= 200000 ? 1000000 : 300000);
                      } else if (months == 6) {
                        regular = amount >= 2000000
                            ? 4995000
                            : (amount >= 1000000 ? 2995000 : 1200000);
                      } else {
                        regular = amount >= 3000000
                            ? 7995000
                            : (amount >= 1500000 ? 4995000 : 2400000);
                      }
                    }

                    if (planStr.isNotEmpty && amount > 0) {
                      offers.add(SubscriptionOffer(
                        plan: planStr,
                        months: months,
                        regularAmount: regular,
                        amount: amount,
                      ));
                    }
                  }
                }

                if (offers.isNotEmpty) {
                  agentOffersMap[agentId] = offers;
                }
              }
            }
          }

          if (agentOffersMap.isNotEmpty || arabicCfg != null) {
            ProductPricing.updateOffers(
              revision: revision,
              agentOffersMap: agentOffersMap.isNotEmpty ? agentOffersMap : null,
              arabicPaymentConfig: arabicCfg,
            );
          }

          if (agentOffersMap.isNotEmpty) {
            // Jika VPS belum menyertakan arabicPayment, cek Firestore app_config/pricing
            // agar tombol pembayaran Arab tetap bisa diaktifkan OTA dari salah satu sumber.
            if (arabicCfg == null) {
              try {
                final db = firestore ??
                    (Firebase.apps.isNotEmpty
                        ? FirebaseFirestore.instance
                        : null);
                if (db != null) {
                  final doc = await db
                      .collection('app_config')
                      .doc('pricing')
                      .get(GetOptions(
                          source: forceRefresh
                              ? Source.server
                              : Source.serverAndCache))
                      .timeout(const Duration(seconds: 2));
                  if (doc.exists && doc.data() != null) {
                    final fsData = doc.data()!;
                    final fsArabicCfg = ArabicPaymentConfig.fromMap(
                        fsData['arabicPayment'] ?? fsData['arabic_payment']);
                    if (fsArabicCfg != null) {
                      ProductPricing.updateOffers(
                        arabicPaymentConfig: fsArabicCfg,
                      );
                    }
                  }
                }
              } catch (_) {}
            }
            _lastFetch = now;
            return true;
          }
        }
      }
    } catch (_) {
      // Fallback ke Firestore bila jaringan VPS terkendala
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }

    // 2. Fallback Sekunder: Firestore app_config/pricing
    try {
      final db = firestore ??
          (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);
      if (db == null) return false;

      final doc = await db
          .collection('app_config')
          .doc('pricing')
          .get(GetOptions(
              source: forceRefresh ? Source.server : Source.serverAndCache))
          .timeout(const Duration(seconds: 3));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final revision = data['revision'] as String?;
        final arabicCfg = ArabicPaymentConfig.fromMap(
            data['arabicPayment'] ?? data['arabic_payment']);
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
          arabicPaymentConfig: arabicCfg,
        );
        _lastFetch = now;
        return tahawwulat != null || specialists != null || arabicCfg != null;
      }
    } catch (_) {
      // Graceful fallback to default constants
    }
    return false;
  }
}
