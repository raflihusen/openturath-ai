#!/usr/bin/env python3
"""
generate_dart_registry.py
=========================
Menghasilkan lib/core/goakal_catalog_registry.dart dari goakal_catalog_master.json
Menyediakan mapping untuk Single Disciplines maupun 6 Thematic Bundles.
"""

import json
import os

with open("goakal_catalog_master.json", "r", encoding="utf-8") as f:
    catalog = json.load(f)

AGENT_TO_SLUG = {
    "fiqh_tahawwulat": "ai-fikih-tahawwulat",
    "fiqh_tahawwulat_muhaqqiq": "ai-fikih-tahawwulat",
    "fiqh_tahawwulat_bayan": "ai-fikih-tahawwulat",
    "fiqh_tahawwulat_mukhtabir": "ai-fikih-tahawwulat",
    "fiqh_tahawwulat_habib": "ai-fikih-tahawwulat",
    "fiqh_tahawwulat_khatib": "ai-fikih-tahawwulat",
    
    "fiqh_syafii": "fikih-syafii",
    "fiqh_syafii_muhaqqiq": "fikih-syafii",
    
    "nahwu_sharaf": "ai-bahasa-arab",
    "nahwu": "ai-bahasa-arab",
    "bahasa_arab": "ai-bahasa-arab",
    "lughah_nahwu": "ai-bahasa-arab",
    "lughah_sharaf": "ai-bahasa-arab",
    "lughah_balaghah": "ai-bahasa-arab",
    "lughah_mujam": "ai-bahasa-arab",
    
    "ushul_fiqh": "ushul-fikih",
    "ushul_muhaqqiq": "ushul-fikih",
    "usul_maqashid": "ushul-fikih",
    "usul_istinbath": "ushul-fikih",
    "qawaid_fiqhiyyah": "qawaid-fiqhiyyah",
    "usul_qawaid": "qawaid-fiqhiyyah",
    
    "hadits": "hadits-nabawi",
    "hadits_muhaqqiq": "hadits-nabawi",
    "hadits_takhrij": "hadits-nabawi",
    "hadits_syarah": "syarah-hadits",
    "syarah_hadits": "syarah-hadits",
    "hadits_ilal": "musthalah-hadits",
    "musthalah_hadits": "musthalah-hadits",
    
    "tafsir": "tafsir-ulumul-quran",
    "tafsir_muhaqqiq": "tafsir-ulumul-quran",
    "tafsir_ahkam": "tafsir-ulumul-quran",
    "tafsir_matsur": "tafsir-ulumul-quran",
    "tafsir_ulumul_quran": "tafsir-ulumul-quran",
    
    "aqidah": "aqidah-ushuluddin",
    "aqidah_kalam": "aqidah-ushuluddin",
    "aqidah_ushuluddin": "aqidah-ushuluddin",
    
    "fiqh_hanafi": "fikih-hanafi",
    "fiqh_maliki": "fikih-maliki",
    "fiqh_hanbali": "fikih-hanbali",
    "fiqh_muqaran": "fikih-muqaran",
    "fatawa": "fatawa-masail",
    "fatawa_masail": "fatawa-masail",
    
    "tasawwuf": "tasawwuf-adzkar",
    "tasawwuf_adzkar": "tasawwuf-adzkar",
    "habib_umar": "tasawwuf-adzkar",
    "tasawwuf_ihya": "tasawwuf-adzkar",
    "tasawwuf_adab": "tasawwuf-adzkar",
    
    "tajwid": "tajwid-qiraat",
    "tajwid_qiraat": "tajwid-qiraat",
    
    "tarikh": "tarikh-sirah",
    "tarikh_sirah": "tarikh-sirah",
    "tarikh_khulafa": "tarikh-sirah",
    "tarikh_thabaqat": "thabaqat-tarajim",
    "thabaqat": "thabaqat-tarajim",
    "thabaqat_tarajim": "thabaqat-tarajim",
    
    "bibliografi": "bibliografi-faharis",
    "bibliografi_faharis": "bibliografi-faharis",
}

BUNDLES_META = [
    {
        "slug": "paket-fikih-pesantren",
        "title": "Paket Fikih Pesantren & Santri Salaf",
        "subtitle": "The Syafi'i & Bahtsul Masail Suite",
        "badgeText": "★ BEST SELLER NO. 1",
        "iconEmoji": "🟢",
        "originalPrice1m": 199000,
        "launchPrice1m": 99000,
        "includedItems": [
            "Super AI Fikih Syafi'i (Al-Umm, Minhaj, Fathul Mu'in)",
            "Super AI Ushul Fikih (Kaidah Dalil & Metodologi Istinbath)",
            "Super AI Qawaid Fiqhiyyah (Kaidah Asasiyyah & Furu')",
            "Super AI Fatawa & Masail (Fatwa Nawawi, Ibnu Hajar, Ba'alawi)",
            "Super AI Tasawwuf & Adzkar (Pembersih Hati & Adab Syar'i)"
        ]
    },
    {
        "slug": "paket-samudra-hadits",
        "title": "Paket Samudra Hadits & Sirah Nabawiyyah",
        "subtitle": "The Hadith Master Suite",
        "badgeText": "★ PILIHAN PENGKAJI HADIS",
        "iconEmoji": "📜",
        "originalPrice1m": 249000,
        "launchPrice1m": 129000,
        "includedItems": [
            "Super AI Hadits Nabawi (Kutubus Sittah & Kutubut Tis'ah)",
            "Super AI Syarah Hadits (Fathul Bari, Syarah Nawawi, Umdah)",
            "Super AI Musthalah & Ulumul Hadits (Takhrij & 'Ilal Hadits)",
            "Super AI Thabaqat & Tarajim Rijal (20.000+ Biografi Rawi)",
            "Super AI Tarikh & Sirah Nabawiyyah (Konteks Asbabul Wurud)"
        ]
    },
    {
        "slug": "paket-tafsir-bahasa-arab",
        "title": "Paket Mufassir & Khazanah Bahasa Arab",
        "subtitle": "The Qur'an & Arabic Suite",
        "badgeText": "★ FAVORIT ILMU ALAT & TAFSIR",
        "iconEmoji": "📖",
        "originalPrice1m": 199000,
        "launchPrice1m": 99000,
        "includedItems": [
            "Super AI Tafsir & Ulumul Qur'an (Thabari, Ibnu Katsir, Razi)",
            "Super AI Tajwid & Qira'at (Kaidah Bacaan 10 Imam Mutawatir)",
            "Super AI Bahasa, Balaghah & Kamus (Lisanul Arab, Alfiyyah)",
            "Super AI Bibliografi & Faharis (Peta Manuskrip & Penulis Kitab)"
        ]
    },
    {
        "slug": "paket-mazhab-akbar",
        "title": "Paket Mufti, Mazhab Akbar & Pemikiran",
        "subtitle": "The Grand Comparative Suite",
        "badgeText": "★ RISET AKADEMIK & MAZHAB",
        "iconEmoji": "⚖️",
        "originalPrice1m": 299000,
        "launchPrice1m": 149000,
        "includedItems": [
            "Super AI Fikih Hanafi (Kutubul Mu'tamadah Mazhab Hanafi)",
            "Super AI Fikih Maliki (Mudawwanah, Mukhtashar Khalil)",
            "Super AI Fikih Hanbali (Al-Mughni, Zadul Mustaqni')",
            "Super AI Fikih Muqaran & Siyasah (Tata Negara & Politik Islam)",
            "Super AI Aqidah & Ushuluddin (Kalam, Asy'ariyah-Maturidiyah)",
            "Super AI Fatawa Akbar Lintas Mazhab"
        ]
    },
    {
        "slug": "paket-fikih-tahawwulat",
        "title": "Paket Khusus Fikih Tahawwulat",
        "subtitle": "The Eschatology & Prophetic Sign Suite",
        "badgeText": "★ KORPUS MASTER KHUSUS",
        "iconEmoji": "🌟",
        "originalPrice1m": 199000,
        "launchPrice1m": 99000,
        "includedItems": [
            "Persona Al-Muhaqqiq (Bedah Konsep & Dalil Ushul)",
            "Persona Al-Bayan (Panduan Sikap Dakwah & Solusi Zaman)",
            "Persona Al-Mukhtabir (Uji Komparasi Realitas & Tanda Zaman)",
            "Persona Al-Habib (Bimbingan Jiwa & Keselamatan Iman)",
            "Persona Al-Khatib (Penyusun Teks Khutbah & Retorika Da'i)"
        ]
    },
    {
        "slug": "paket-sultan-all-access",
        "title": "Paket Sultan All-Access (Semua 24 AI)",
        "subtitle": "Total VIP Ecosystem Access",
        "badgeText": "👑 SULTAN VIP (HEMAT MAKSIMAL)",
        "iconEmoji": "👑",
        "originalPrice1m": 499000,
        "launchPrice1m": 249000,
        "includedItems": [
            "Akses Tanpa Batas Seluruh 20 Modul Turath Lokal",
            "Akses Seluruh 5 Persona Fikih Tahawwulat",
            "Prioritas Pemrosesan AI Tingkat Tertinggi (Super Cepat)",
            "Update Korpus Digital Baru Secara Otomatis & Terus Menerus",
            "Dukungan VIP Langsung dari Tim Peneliti OpenTurath AI"
        ]
    }
]

lines = [
    "// Generated automatically by OpenTurath AI GoAkal Sync.",
    "// DO NOT EDIT MANUALLY.",
    "",
    "class GoAkalTierLink {",
    "  final String durationKey;",
    "  final String title;",
    "  final int amount;",
    "  final String priceLabel;",
    "  final String periodLabel;",
    "  final String planId;",
    "  final String applyUrl;",
    "",
    "  const GoAkalTierLink({",
    "    required this.durationKey,",
    "    required this.title,",
    "    required this.amount,",
    "    required this.priceLabel,",
    "    required this.periodLabel,",
    "    required this.planId,",
    "    required this.applyUrl,",
    "  });",
    "",
    "  Map<String, dynamic> toMap() {",
    "    return {",
    "      'name': title,",
    "      'price': amount,",
    "      'label': priceLabel,",
    "      'period': periodLabel,",
    "      'planId': planId,",
    "      'applyUrl': applyUrl,",
    "    };",
    "  }",
    "}",
    "",
    "class ThematicBundleMeta {",
    "  final String slug;",
    "  final String title;",
    "  final String subtitle;",
    "  final String badgeText;",
    "  final String iconEmoji;",
    "  final int originalPrice1m;",
    "  final int launchPrice1m;",
    "  final List<String> includedItems;",
    "",
    "  const ThematicBundleMeta({",
    "    required this.slug,",
    "    required this.title,",
    "    required this.subtitle,",
    "    required this.badgeText,",
    "    required this.iconEmoji,",
    "    required this.originalPrice1m,",
    "    required this.launchPrice1m,",
    "    required this.includedItems,",
    "  });",
    "",
    "  List<GoAkalTierLink> get tiers => GoAkalCatalogRegistry.getTierLinksForSlug(slug);",
    "}",
    "",
    "class GoAkalCatalogRegistry {",
    "  static const String storeUrl = 'https://goakal.com/openturath-ai';",
    "",
    "  static const Map<String, String> agentIdToSlug = {",
]

for aid, slug in sorted(AGENT_TO_SLUG.items()):
    lines.append(f"    '{aid}': '{slug}',")

lines.extend([
    "  };",
    "",
    "  static const Map<String, Map<String, GoAkalTierLink>> directLinks = {",
])

for slug, data in sorted(catalog.items()):
    tiers = data.get("tiers", {})
    if not tiers:
        continue
    lines.append(f"    '{slug}': {{")
    for t_key in ["1_month", "6_months", "1_year"]:
        if t_key not in tiers:
            continue
        t_info = tiers[t_key]
        amount = t_info.get("amount", 0)
        formatted_rp = f"Rp {amount:,}".replace(",", ".")
        period = "/ bulan" if t_key == "1_month" else ("/ 6 bulan" if t_key == "6_months" else "/ tahun")
        plan_id = f"{slug}_{t_key}"
        lines.append(f"      '{t_key}': GoAkalTierLink(")
        lines.append(f"        durationKey: '{t_key}',")
        lines.append(f"        title: '{t_info.get('title')}',")
        lines.append(f"        amount: {amount},")
        lines.append(f"        priceLabel: '{formatted_rp}',")
        lines.append(f"        periodLabel: '{period}',")
        lines.append(f"        planId: '{plan_id}',")
        lines.append(f"        applyUrl: '{t_info.get('apply_url')}',")
        lines.append("      ),")
    lines.append("    },")

lines.extend([
    "  };",
    "",
    "  /// Metadata 6 Paket Tematik Khusus Launching",
    "  static const List<ThematicBundleMeta> thematicBundles = [",
])

for b in BUNDLES_META:
    lines.append("    ThematicBundleMeta(")
    lines.append(f"      slug: {json.dumps(b['slug'])},")
    lines.append(f"      title: {json.dumps(b['title'])},")
    lines.append(f"      subtitle: {json.dumps(b['subtitle'])},")
    lines.append(f"      badgeText: {json.dumps(b['badgeText'])},")
    lines.append(f"      iconEmoji: {json.dumps(b['iconEmoji'])},")
    lines.append(f"      originalPrice1m: {b['originalPrice1m']},")
    lines.append(f"      launchPrice1m: {b['launchPrice1m']},")
    lines.append("      includedItems: [")
    for item in b["includedItems"]:
        lines.append(f"        {json.dumps(item)},")
    lines.append("      ],")
    lines.append("    ),")

lines.extend([
    "  ];",
    "",
    "  /// Ambil daftar GoAkalTierLink berdasarkan slug",
    "  static List<GoAkalTierLink> getTierLinksForSlug(String slug) {",
    "    final tiersMap = directLinks[slug];",
    "    if (tiersMap != null && tiersMap.isNotEmpty) {",
    "      final list = <GoAkalTierLink>[];",
    "      for (final key in ['1_month', '6_months', '1_year']) {",
    "        if (tiersMap.containsKey(key)) {",
    "          list.add(tiersMap[key]!);",
    "        }",
    "      }",
    "      return list;",
    "    }",
    "    return const [];",
    "  }",
    "",
    "  /// Mendapatkan daftar tier terstruktur untuk Agent tertentu",
    "  static List<Map<String, dynamic>> getTiersForAgent(String? agentId) {",
    "    final slug = resolveSlug(agentId);",
    "    final tiersMap = directLinks[slug];",
    "    if (tiersMap != null && tiersMap.isNotEmpty) {",
    "      final list = <Map<String, dynamic>>[];",
    "      for (final key in ['1_month', '6_months', '1_year']) {",
    "        if (tiersMap.containsKey(key)) {",
    "          list.add(tiersMap[key]!.toMap());",
    "        }",
    "      }",
    "      if (list.isNotEmpty) return list;",
    "    }",
    "",
    "    // Default regular tier fallback",
    "    return const [",
    "      {",
    "        'name': '1 Bulan (Harga Khusus Launch)',",
    "        'price': 99000,",
    "        'label': 'Rp 99.000',",
    "        'period': '/ bulan',",
    "        'planId': 'regular_1m',",
    "        'applyUrl': storeUrl,",
    "      },",
    "      {",
    "        'name': '6 Bulan',",
    "        'price': 499000,",
    "        'label': 'Rp 499.000',",
    "        'period': '/ 6 bulan',",
    "        'planId': 'regular_6m',",
    "        'applyUrl': storeUrl,",
    "      },",
    "      {",
    "        'name': '1 Tahun',",
    "        'price': 890000,",
    "        'label': 'Rp 890.000',",
    "        'period': '/ tahun',",
    "        'planId': 'regular_1y',",
    "        'applyUrl': storeUrl,",
    "      },",
    "    ];",
    "  }",
    "",
    "  /// Resolve agentId to GoAkal slug",
    "  static String resolveSlug(String? agentId) {",
    "    if (agentId == null || agentId.isEmpty) return 'ai-fikih-tahawwulat';",
    "    if (directLinks.containsKey(agentId)) return agentId;",
    "    return agentIdToSlug[agentId] ?? agentId.replaceAll('_', '-');",
    "  }",
    "",
    "  /// Mendapatkan direct link apply berdasarkan slug / agentId dan durasi.",
    "  static String? getApplyUrl(String? agentRef, String durationKey) {",
    "    final slug = resolveSlug(agentRef);",
    "    return directLinks[slug]?[durationKey]?.applyUrl;",
    "  }",
    "}",
    "",
])

output_path = "openturath_ai/lib/core/goakal_catalog_registry.dart"
with open(output_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print(f"Generated {output_path} successfully!")
