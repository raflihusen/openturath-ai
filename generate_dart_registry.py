#!/usr/bin/env python3
"""
generate_dart_registry.py
=========================
Menghasilkan lib/core/goakal_catalog_registry.dart dari goakal_catalog_master.json
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
    "        'name': '1 Bulan',",
    "        'price': 299000,",
    "        'label': 'Rp 299.000',",
    "        'period': '/ bulan',",
    "        'planId': 'regular_1m',",
    "        'applyUrl': storeUrl,",
    "      },",
    "      {",
    "        'name': '6 Bulan',",
    "        'price': 1499000,",
    "        'label': 'Rp 1.499.000',",
    "        'period': '/ 6 bulan',",
    "        'planId': 'regular_6m',",
    "        'applyUrl': storeUrl,",
    "      },",
    "      {",
    "        'name': '1 Tahun',",
    "        'price': 1999000,",
    "        'label': 'Rp 1.999.000',",
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
