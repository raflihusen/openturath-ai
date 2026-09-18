// Generated automatically by OpenTurath AI GoAkal Sync.
// DO NOT EDIT MANUALLY.

class GoAkalTierLink {
  final String durationKey;
  final String title;
  final int amount;
  final String priceLabel;
  final String periodLabel;
  final String planId;
  final String applyUrl;

  const GoAkalTierLink({
    required this.durationKey,
    required this.title,
    required this.amount,
    required this.priceLabel,
    required this.periodLabel,
    required this.planId,
    required this.applyUrl,
  });

  bool get isLiveOnGoAkal => applyUrl.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'name': title,
      'price': amount,
      'label': priceLabel,
      'period': periodLabel,
      'planId': planId,
      'applyUrl': applyUrl,
    };
  }
}

class ThematicBundleMeta {
  final String slug;
  final String title;
  final String subtitle;
  final String badgeText;
  final String iconEmoji;
  final int originalPrice1m;
  final int launchPrice1m;
  final List<String> includedItems;

  const ThematicBundleMeta({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.iconEmoji,
    required this.originalPrice1m,
    required this.launchPrice1m,
    required this.includedItems,
  });

  List<GoAkalTierLink> get tiers => GoAkalCatalogRegistry.getTierLinksForSlug(slug);
}

class GoAkalCatalogRegistry {
  static const String storeUrl = 'https://goakal.com/openturath-ai';

  static const Map<String, String> agentIdToSlug = {
    'aqidah': 'aqidah-ushuluddin',
    'aqidah_kalam': 'aqidah-ushuluddin',
    'aqidah_ushuluddin': 'aqidah-ushuluddin',
    'bahasa_arab': 'ai-bahasa-arab',
    'bibliografi': 'bibliografi-faharis',
    'bibliografi_faharis': 'bibliografi-faharis',
    'fatawa': 'fatawa-masail',
    'fatawa_masail': 'fatawa-masail',
    'fiqh_hanafi': 'fikih-hanafi',
    'fiqh_hanbali': 'fikih-hanbali',
    'fiqh_maliki': 'fikih-maliki',
    'fiqh_muqaran': 'fikih-muqaran',
    'fiqh_syafii': 'fikih-syafii',
    'fiqh_syafii_muhaqqiq': 'fikih-syafii',
    'fiqh_tahawwulat': 'ai-fikih-tahawwulat',
    'fiqh_tahawwulat_bayan': 'ai-fikih-tahawwulat',
    'fiqh_tahawwulat_habib': 'ai-fikih-tahawwulat',
    'fiqh_tahawwulat_khatib': 'ai-fikih-tahawwulat',
    'fiqh_tahawwulat_muhaqqiq': 'ai-fikih-tahawwulat',
    'fiqh_tahawwulat_mukhtabir': 'ai-fikih-tahawwulat',
    'habib_umar': 'tasawwuf-adzkar',
    'hadits': 'hadits-nabawi',
    'hadits_ilal': 'musthalah-hadits',
    'hadits_muhaqqiq': 'hadits-nabawi',
    'hadits_syarah': 'syarah-hadits',
    'hadits_takhrij': 'hadits-nabawi',
    'lughah_balaghah': 'ai-bahasa-arab',
    'lughah_mujam': 'ai-bahasa-arab',
    'lughah_nahwu': 'ai-bahasa-arab',
    'lughah_sharaf': 'ai-bahasa-arab',
    'musthalah_hadits': 'musthalah-hadits',
    'nahwu': 'ai-bahasa-arab',
    'nahwu_sharaf': 'ai-bahasa-arab',
    'qawaid_fiqhiyyah': 'qawaid-fiqhiyyah',
    'syarah_hadits': 'syarah-hadits',
    'tafsir': 'tafsir-ulumul-quran',
    'tafsir_ahkam': 'tafsir-ulumul-quran',
    'tafsir_matsur': 'tafsir-ulumul-quran',
    'tafsir_muhaqqiq': 'tafsir-ulumul-quran',
    'tafsir_ulumul_quran': 'tafsir-ulumul-quran',
    'tajwid': 'tajwid-qiraat',
    'tajwid_qiraat': 'tajwid-qiraat',
    'tarikh': 'tarikh-sirah',
    'tarikh_khulafa': 'tarikh-sirah',
    'tarikh_sirah': 'tarikh-sirah',
    'tarikh_thabaqat': 'thabaqat-tarajim',
    'tasawwuf': 'tasawwuf-adzkar',
    'tasawwuf_adab': 'tasawwuf-adzkar',
    'tasawwuf_adzkar': 'tasawwuf-adzkar',
    'tasawwuf_ihya': 'tasawwuf-adzkar',
    'thabaqat': 'thabaqat-tarajim',
    'thabaqat_tarajim': 'thabaqat-tarajim',
    'ushul_fiqh': 'ushul-fikih',
    'ushul_muhaqqiq': 'ushul-fikih',
    'usul_istinbath': 'ushul-fikih',
    'usul_maqashid': 'ushul-fikih',
    'usul_qawaid': 'qawaid-fiqhiyyah',
  };

  static const Map<String, Map<String, GoAkalTierLink>> directLinks = {
    'ai-bahasa-arab': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'ai-bahasa-arab_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/ai-bahasa-arab/kbp4j/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'ai-bahasa-arab_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/ai-bahasa-arab/ydvfs/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'ai-bahasa-arab_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/ai-bahasa-arab/yfi9q/apply',
      ),
    },
    'ai-fikih-tahawwulat': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 1000000,
        priceLabel: 'Rp 1.000.000',
        periodLabel: '/ bulan',
        planId: 'ai-fikih-tahawwulat_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/ai-fikih-tahawwulat/1js2e/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 2995000,
        priceLabel: 'Rp 2.995.000',
        periodLabel: '/ 6 bulan',
        planId: 'ai-fikih-tahawwulat_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/ai-fikih-tahawwulat/sp6zh/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 4995000,
        priceLabel: 'Rp 4.995.000',
        periodLabel: '/ tahun',
        planId: 'ai-fikih-tahawwulat_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/ai-fikih-tahawwulat/8yt9m/apply',
      ),
    },
    'aqidah-ushuluddin': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'aqidah-ushuluddin_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/aqidah-ushuluddin/an70o/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'aqidah-ushuluddin_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/aqidah-ushuluddin/7n761/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'aqidah-ushuluddin_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/aqidah-ushuluddin/fvnxh/apply',
      ),
    },
    'bibliografi-faharis': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'bibliografi-faharis_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/bibliografi-faharis/fvf9n/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'bibliografi-faharis_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/bibliografi-faharis/idjz2/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'bibliografi-faharis_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/bibliografi-faharis/4rqws/apply',
      ),
    },
    'fatawa-masail': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'fatawa-masail_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/fatawa-masail/nv0m0/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'fatawa-masail_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/fatawa-masail/dzs0p/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'fatawa-masail_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/fatawa-masail/x53hd/apply',
      ),
    },
    'fikih-hanafi': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'fikih-hanafi_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-hanafi/5ofbj/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'fikih-hanafi_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-hanafi/uhkca/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'fikih-hanafi_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-hanafi/kwpa6/apply',
      ),
    },
    'fikih-hanbali': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'fikih-hanbali_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-hanbali/p814h/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'fikih-hanbali_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-hanbali/w2mep/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'fikih-hanbali_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-hanbali/w7y99/apply',
      ),
    },
    'fikih-maliki': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'fikih-maliki_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-maliki/r7fit/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'fikih-maliki_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-maliki/s8cnz/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'fikih-maliki_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-maliki/1nnz8/apply',
      ),
    },
    'fikih-muqaran': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'fikih-muqaran_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-muqaran/ci0s6/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'fikih-muqaran_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-muqaran/e6cgt/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'fikih-muqaran_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-muqaran/5i6um/apply',
      ),
    },
    'fikih-syafii': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'fikih-syafii_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-syafii/tjvxw/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'fikih-syafii_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-syafii/16oun/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'fikih-syafii_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/fikih-syafii/ianjf/apply',
      ),
    },
    'hadits-nabawi': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'hadits-nabawi_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/hadits-nabawi/rqlei/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'hadits-nabawi_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/hadits-nabawi/jpes8/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'hadits-nabawi_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/hadits-nabawi/bp6zx/apply',
      ),
    },
    'musthalah-hadits': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'musthalah-hadits_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/musthalah-hadits/7349m/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'musthalah-hadits_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/musthalah-hadits/2ikma/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'musthalah-hadits_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/musthalah-hadits/8nfa7/apply',
      ),
    },
    'paket-fikih-pesantren': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 149000,
        priceLabel: 'Rp 149.000',
        periodLabel: '/ bulan',
        planId: 'paket-fikih-pesantren_1_month',
        applyUrl: '',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan (1 Semester)',
        amount: 749000,
        priceLabel: 'Rp 749.000',
        periodLabel: '/ 6 bulan',
        planId: 'paket-fikih-pesantren_6_months',
        applyUrl: '',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan (1 Tahun)',
        amount: 1349000,
        priceLabel: 'Rp 1.349.000',
        periodLabel: '/ tahun',
        planId: 'paket-fikih-pesantren_1_year',
        applyUrl: '',
      ),
    },
    'paket-fikih-tahawwulat': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 149000,
        priceLabel: 'Rp 149.000',
        periodLabel: '/ bulan',
        planId: 'paket-fikih-tahawwulat_1_month',
        applyUrl: '',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan (1 Semester)',
        amount: 749000,
        priceLabel: 'Rp 749.000',
        periodLabel: '/ 6 bulan',
        planId: 'paket-fikih-tahawwulat_6_months',
        applyUrl: '',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan (1 Tahun)',
        amount: 1349000,
        priceLabel: 'Rp 1.349.000',
        periodLabel: '/ tahun',
        planId: 'paket-fikih-tahawwulat_1_year',
        applyUrl: '',
      ),
    },
    'paket-mazhab-akbar': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 179000,
        priceLabel: 'Rp 179.000',
        periodLabel: '/ bulan',
        planId: 'paket-mazhab-akbar_1_month',
        applyUrl: '',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan (1 Semester)',
        amount: 899000,
        priceLabel: 'Rp 899.000',
        periodLabel: '/ 6 bulan',
        planId: 'paket-mazhab-akbar_6_months',
        applyUrl: '',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan (1 Tahun)',
        amount: 1590000,
        priceLabel: 'Rp 1.590.000',
        periodLabel: '/ tahun',
        planId: 'paket-mazhab-akbar_1_year',
        applyUrl: '',
      ),
    },
    'paket-samudra-hadits': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 149000,
        priceLabel: 'Rp 149.000',
        periodLabel: '/ bulan',
        planId: 'paket-samudra-hadits_1_month',
        applyUrl: '',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan (1 Semester)',
        amount: 749000,
        priceLabel: 'Rp 749.000',
        periodLabel: '/ 6 bulan',
        planId: 'paket-samudra-hadits_6_months',
        applyUrl: '',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan (1 Tahun)',
        amount: 1349000,
        priceLabel: 'Rp 1.349.000',
        periodLabel: '/ tahun',
        planId: 'paket-samudra-hadits_1_year',
        applyUrl: '',
      ),
    },
    'paket-sultan-all-access': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan (All-Access 24 AI)',
        amount: 499000,
        priceLabel: 'Rp 499.000',
        periodLabel: '/ bulan',
        planId: 'paket-sultan-all-access_1_month',
        applyUrl: '',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan (1 Semester)',
        amount: 2490000,
        priceLabel: 'Rp 2.490.000',
        periodLabel: '/ 6 bulan',
        planId: 'paket-sultan-all-access_6_months',
        applyUrl: '',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan (1 Tahun Penuh)',
        amount: 4490000,
        priceLabel: 'Rp 4.490.000',
        periodLabel: '/ tahun',
        planId: 'paket-sultan-all-access_1_year',
        applyUrl: '',
      ),
    },
    'paket-tafsir-bahasa-arab': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 129000,
        priceLabel: 'Rp 129.000',
        periodLabel: '/ bulan',
        planId: 'paket-tafsir-bahasa-arab_1_month',
        applyUrl: '',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan (1 Semester)',
        amount: 649000,
        priceLabel: 'Rp 649.000',
        periodLabel: '/ 6 bulan',
        planId: 'paket-tafsir-bahasa-arab_6_months',
        applyUrl: '',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan (1 Tahun)',
        amount: 1190000,
        priceLabel: 'Rp 1.190.000',
        periodLabel: '/ tahun',
        planId: 'paket-tafsir-bahasa-arab_1_year',
        applyUrl: '',
      ),
    },
    'qawaid-fiqhiyyah': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'qawaid-fiqhiyyah_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/qawaid-fiqhiyyah/9n3df/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'qawaid-fiqhiyyah_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/qawaid-fiqhiyyah/0a4bb/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'qawaid-fiqhiyyah_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/qawaid-fiqhiyyah/1fnnl/apply',
      ),
    },
    'syarah-hadits': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'syarah-hadits_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/syarah-hadits/befmz/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'syarah-hadits_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/syarah-hadits/g8iy5/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'syarah-hadits_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/syarah-hadits/uhg5y/apply',
      ),
    },
    'tafsir-ulumul-quran': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'tafsir-ulumul-quran_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/tafsir-ulumul-quran/v00h9/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'tafsir-ulumul-quran_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/tafsir-ulumul-quran/hpisf/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'tafsir-ulumul-quran_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/tafsir-ulumul-quran/sfpsx/apply',
      ),
    },
    'tajwid-qiraat': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'tajwid-qiraat_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/tajwid-qiraat/u7ful/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'tajwid-qiraat_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/tajwid-qiraat/nrcif/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'tajwid-qiraat_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/tajwid-qiraat/r15pd/apply',
      ),
    },
    'tarikh-sirah': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'tarikh-sirah_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/tarikh-sirah/8sl8w/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'tarikh-sirah_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/tarikh-sirah/dvpom/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'tarikh-sirah_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/tarikh-sirah/w6qh3/apply',
      ),
    },
    'tasawwuf-adzkar': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'tasawwuf-adzkar_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/tasawwuf-adzkar/9745y/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'tasawwuf-adzkar_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/tasawwuf-adzkar/8a3lo/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'tasawwuf-adzkar_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/tasawwuf-adzkar/tqlj2/apply',
      ),
    },
    'thabaqat-tarajim': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'thabaqat-tarajim_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/thabaqat-tarajim/bapyj/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'thabaqat-tarajim_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/thabaqat-tarajim/slria/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'thabaqat-tarajim_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/thabaqat-tarajim/d7yc4/apply',
      ),
    },
    'ushul-fikih': {
      '1_month': GoAkalTierLink(
        durationKey: '1_month',
        title: '1 Bulan',
        amount: 299000,
        priceLabel: 'Rp 299.000',
        periodLabel: '/ bulan',
        planId: 'ushul-fikih_1_month',
        applyUrl: 'https://goakal.com/openturath-ai/ushul-fikih/172b6/apply',
      ),
      '6_months': GoAkalTierLink(
        durationKey: '6_months',
        title: '6 Bulan',
        amount: 1499000,
        priceLabel: 'Rp 1.499.000',
        periodLabel: '/ 6 bulan',
        planId: 'ushul-fikih_6_months',
        applyUrl: 'https://goakal.com/openturath-ai/ushul-fikih/mcgfs/apply',
      ),
      '1_year': GoAkalTierLink(
        durationKey: '1_year',
        title: '12 Bulan',
        amount: 1999000,
        priceLabel: 'Rp 1.999.000',
        periodLabel: '/ tahun',
        planId: 'ushul-fikih_1_year',
        applyUrl: 'https://goakal.com/openturath-ai/ushul-fikih/0s0yp/apply',
      ),
    },
  };

  /// Metadata 6 Paket Tematik Khusus Launching
  static const List<ThematicBundleMeta> thematicBundles = [
    ThematicBundleMeta(
      slug: "paket-fikih-pesantren",
      title: "Paket Fikih Pesantren & Santri Salaf",
      subtitle: "The Syafi'i & Bahtsul Masail Suite",
      badgeText: "\u2605 BEST SELLER NO. 1",
      iconEmoji: "\ud83d\udfe2",
      originalPrice1m: 245000,
      launchPrice1m: 149000,
      includedItems: [
        "Super AI Fikih Syafi'i (Al-Umm, Minhaj, Fathul Mu'in)",
        "Super AI Ushul Fikih (Kaidah Dalil & Metodologi Istinbath)",
        "Super AI Qawaid Fiqhiyyah (Kaidah Asasiyyah & Furu')",
        "Super AI Fatawa & Masail (Fatwa Nawawi, Ibnu Hajar, Ba'alawi)",
        "Super AI Tasawwuf & Adzkar (Pembersih Hati & Adab Syar'i)",
      ],
    ),
    ThematicBundleMeta(
      slug: "paket-samudra-hadits",
      title: "Paket Samudra Hadits & Sirah Nabawiyyah",
      subtitle: "The Hadith Master Suite",
      badgeText: "\u2605 PILIHAN PENGKAJI HADIS",
      iconEmoji: "\ud83d\udcdc",
      originalPrice1m: 245000,
      launchPrice1m: 149000,
      includedItems: [
        "Super AI Hadits Nabawi (Kutubus Sittah & Kutubut Tis'ah)",
        "Super AI Syarah Hadits (Fathul Bari, Syarah Nawawi, Umdah)",
        "Super AI Musthalah & Ulumul Hadits (Takhrij & 'Ilal Hadits)",
        "Super AI Thabaqat & Tarajim Rijal (20.000+ Biografi Rawi)",
        "Super AI Tarikh & Sirah Nabawiyyah (Konteks Asbabul Wurud)",
      ],
    ),
    ThematicBundleMeta(
      slug: "paket-tafsir-bahasa-arab",
      title: "Paket Mufassir & Khazanah Bahasa Arab",
      subtitle: "The Qur'an & Arabic Suite",
      badgeText: "\u2605 FAVORIT ILMU ALAT & TAFSIR",
      iconEmoji: "\ud83d\udcd6",
      originalPrice1m: 196000,
      launchPrice1m: 129000,
      includedItems: [
        "Super AI Tafsir & Ulumul Qur'an (Thabari, Ibnu Katsir, Razi)",
        "Super AI Tajwid & Qira'at (Kaidah Bacaan 10 Imam Mutawatir)",
        "Super AI Bahasa, Balaghah & Kamus (Lisanul Arab, Alfiyyah)",
        "Super AI Bibliografi & Faharis (Peta Manuskrip & Penulis Kitab)",
      ],
    ),
    ThematicBundleMeta(
      slug: "paket-mazhab-akbar",
      title: "Paket Mufti, Mazhab Akbar & Pemikiran",
      subtitle: "The Grand Comparative Suite",
      badgeText: "\u2605 RISET AKADEMIK & MAZHAB",
      iconEmoji: "\u2696\ufe0f",
      originalPrice1m: 294000,
      launchPrice1m: 179000,
      includedItems: [
        "Super AI Fikih Hanafi (Kutubul Mu'tamadah Mazhab Hanafi)",
        "Super AI Fikih Maliki (Mudawwanah, Mukhtashar Khalil)",
        "Super AI Fikih Hanbali (Al-Mughni, Zadul Mustaqni')",
        "Super AI Fikih Muqaran & Siyasah (Tata Negara & Politik Islam)",
        "Super AI Aqidah & Ushuluddin (Kalam, Asy'ariyah-Maturidiyah)",
        "Super AI Fatawa Akbar Lintas Mazhab",
      ],
    ),
    ThematicBundleMeta(
      slug: "paket-fikih-tahawwulat",
      title: "Paket Khusus Fikih Tahawwulat",
      subtitle: "The Eschatology & Prophetic Sign Suite",
      badgeText: "\u2605 KORPUS MASTER KHUSUS",
      iconEmoji: "\ud83c\udf1f",
      originalPrice1m: 245000,
      launchPrice1m: 149000,
      includedItems: [
        "Persona Al-Muhaqqiq (Bedah Konsep & Dalil Ushul)",
        "Persona Al-Bayan (Panduan Sikap Dakwah & Solusi Zaman)",
        "Persona Al-Mukhtabir (Uji Komparasi Realitas & Tanda Zaman)",
        "Persona Al-Habib (Bimbingan Jiwa & Keselamatan Iman)",
        "Persona Al-Khatib (Penyusun Teks Khutbah & Retorika Da'i)",
      ],
    ),
    ThematicBundleMeta(
      slug: "paket-sultan-all-access",
      title: "Paket Sultan All-Access (Semua 24 AI)",
      subtitle: "Total VIP Ecosystem Access",
      badgeText: "\ud83d\udc51 SULTAN VIP (HEMAT MAKSIMAL)",
      iconEmoji: "\ud83d\udc51",
      originalPrice1m: 1176000,
      launchPrice1m: 499000,
      includedItems: [
        "Akses Tanpa Batas Seluruh 20 Modul Turath Lokal",
        "Akses Seluruh 5 Persona Fikih Tahawwulat",
        "Prioritas Pemrosesan AI Tingkat Tertinggi (Super Cepat)",
        "Update Korpus Digital Baru Secara Otomatis & Terus Menerus",
        "Dukungan VIP Langsung dari Tim Peneliti OpenTurath AI",
      ],
    ),
  ];

  /// Ambil daftar GoAkalTierLink berdasarkan slug
  static List<GoAkalTierLink> getTierLinksForSlug(String slug) {
    final tiersMap = directLinks[slug];
    if (tiersMap != null && tiersMap.isNotEmpty) {
      final list = <GoAkalTierLink>[];
      for (final key in ['1_month', '6_months', '1_year']) {
        if (tiersMap.containsKey(key)) {
          list.add(tiersMap[key]!);
        }
      }
      return list;
    }
    return const [];
  }

  /// Mendapatkan daftar tier terstruktur untuk Agent tertentu
  static List<Map<String, dynamic>> getTiersForAgent(String? agentId) {
    final slug = resolveSlug(agentId);
    final tiersMap = directLinks[slug];
    if (tiersMap != null && tiersMap.isNotEmpty) {
      final list = <Map<String, dynamic>>[];
      for (final key in ['1_month', '6_months', '1_year']) {
        if (tiersMap.containsKey(key)) {
          list.add(tiersMap[key]!.toMap());
        }
      }
      if (list.isNotEmpty) return list;
    }

    // Default regular tier fallback
    return const [
      {
        'name': '1 Bulan (Harga Khusus Launch)',
        'price': 99000,
        'label': 'Rp 99.000',
        'period': '/ bulan',
        'planId': 'regular_1m',
        'applyUrl': storeUrl,
      },
      {
        'name': '6 Bulan',
        'price': 499000,
        'label': 'Rp 499.000',
        'period': '/ 6 bulan',
        'planId': 'regular_6m',
        'applyUrl': storeUrl,
      },
      {
        'name': '1 Tahun',
        'price': 890000,
        'label': 'Rp 890.000',
        'period': '/ tahun',
        'planId': 'regular_1y',
        'applyUrl': storeUrl,
      },
    ];
  }

  /// Resolve agentId to GoAkal slug
  static String resolveSlug(String? agentId) {
    if (agentId == null || agentId.isEmpty) return 'ai-fikih-tahawwulat';
    if (directLinks.containsKey(agentId)) return agentId;
    return agentIdToSlug[agentId] ?? agentId.replaceAll('_', '-');
  }

  /// Mendapatkan direct link apply berdasarkan slug / agentId dan durasi.
  static String? getApplyUrl(String? agentRef, String durationKey) {
    final slug = resolveSlug(agentRef);
    return directLinks[slug]?[durationKey]?.applyUrl;
  }
}
