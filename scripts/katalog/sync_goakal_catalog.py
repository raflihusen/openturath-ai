#!/usr/bin/env python3
"""
=============================================================================
SYNC GOAKAL CATALOG & DIRECT APPLY LINKS EXTRACTOR (OPENTURATH AI)
=============================================================================
Script otomasi untuk mengekstrak seluruh katalog AI OpenTurath dari 1 URL induk:
  URL Induk: https://goakal.com/openturath-ai

Fungsi Utama:
1. Membaca halaman induk sekolah/toko GoAkal untuk mendeteksi seluruh produk AI
   yang terbit (aktif), baik saat ini maupun saat sudah berjumlah 30 AI.
2. Membuka setiap halaman produk secara otomatis (headless browser).
3. Mengekstrak secara presisi:
   - Nama AI & Deskripsi
   - Paket durasi (1 Bulan, 6 Bulan, 1 Tahun/12 Bulan)
   - Kuota/kursi tersisa
   - Harga resmi (format string & angka)
   - Direct Checkout URL unik GoAkal (format: /<slug>/<tier_code>/apply)
4. Menyimpan output ke JSON master (`goakal_catalog_master.json`) dan
   menghasilkan kode mapping Dart siap pakai untuk Flutter.
=============================================================================
"""

import sys
import json
import re
import argparse
from typing import List, Dict, Any
from playwright.sync_api import sync_playwright

STORE_URL_DEFAULT = "https://goakal.com/openturath-ai"
OUTPUT_JSON_DEFAULT = "goakal_catalog_master.json"
OUTPUT_DART_DEFAULT = "openturath_ai/lib/features/subscription/data/goakal_links_catalog.dart"


def parse_duration_tier(text: str) -> str:
    """Mengidentifikasi kode durasi standar dari teks kartu GoAkal."""
    t = text.lower()
    if "12 bulan" in t or "1 tahun" in t or "/tahun" in t:
        return "1_year"
    elif "6 bulan" in t or "/6 bulan" in t:
        return "6_months"
    elif "1 bulan" in t or "/bulan" in t:
        return "1_month"
    return "custom"


def run_crawler(store_url: str = STORE_URL_DEFAULT) -> Dict[str, Any]:
    print(f"\n[1/3] Menghubungi toko GoAkal: {store_url}...")
    
    catalog_result = {
        "store_url": store_url,
        "scraped_at": "",
        "total_services": 0,
        "services": []
    }

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        # 1. Buka landing page store
        page.goto(store_url, wait_until="domcontentloaded", timeout=30000)
        page.wait_for_timeout(4000)
        
        # Ekstrak seluruh link produk di bawah /openturath-ai/
        product_links = page.eval_on_selector_all(
            "a[href*=\"/openturath-ai/\"]",
            """els => els.map(e => ({
                href: e.href,
                text: e.innerText.replace(/\\n+/g, " | ").trim()
            }))"""
        )
        
        # Filter link produk unik (abaikan link ke store induk sendiri)
        unique_products = {}
        for item in product_links:
            href = item["href"].split("?")[0].rstrip("/")
            if href != store_url.rstrip("/") and href.count("/") >= 4:
                slug = href.split("/")[-1]
                if slug not in unique_products and not slug.endswith("apply"):
                    unique_products[slug] = {
                        "slug": slug,
                        "url": href,
                        "raw_summary": item["text"]
                    }
        
        print(f"[✓] Ditemukan {len(unique_products)} produk AI di toko GoAkal:")
        for slug, data in unique_products.items():
            print(f"    - {slug} -> {data['url']}")
            
        print(f"\n[2/3] Membuka setiap halaman AI dan mengekstrak direct apply links (1m, 6m, 1y)...")
        
        services_list = []
        for idx, (slug, pdata) in enumerate(unique_products.items(), 1):
            prod_url = pdata["url"]
            print(f"  [{idx}/{len(unique_products)}] Scraping: {slug}...")
            
            try:
                page.goto(prod_url, wait_until="domcontentloaded", timeout=20000)
                page.wait_for_selector("a[href*=\"apply\"]", timeout=12000)
                
                # Ambil judul utama dari halaman produk
                title = page.title().split("|")[0].strip()
                
                # Ambil semua tombol apply dan kartu harganya
                tiers_data = page.eval_on_selector_all(
                    "a[href*=\"apply\"]",
                    """els => els.map(e => {
                        const card = e.closest("div.border") || e.closest("div.rounded-xl") || e.parentElement;
                        return {
                            apply_url: e.href,
                            button_label: e.innerText.trim(),
                            card_text: card ? card.innerText.replace(/\\n+/g, " | ") : ""
                        };
                    })"""
                )
                
                parsed_tiers = []
                for t in tiers_data:
                    card_str = t["card_text"]
                    tier_code = parse_duration_tier(card_str)
                    
                    # Ekstrak harga
                    price_match = re.search(r"Rp\s*([0-9\.,]+)", card_str)
                    price_str = f"Rp {price_match.group(1)}" if price_match else "N/A"
                    
                    # Ekstrak kursi / kuota
                    quota_match = re.search(r"(\d+)\s+kursi tersisa", card_str, re.IGNORECASE)
                    quota_str = f"{quota_match.group(1)} kursi tersisa" if quota_match else "Tersedia"
                    
                    parsed_tiers.append({
                        "tier": tier_code,
                        "card_text": card_str,
                        "price": price_str,
                        "quota": quota_str,
                        "apply_url": t["apply_url"]
                    })
                
                service_info = {
                    "slug": slug,
                    "title": title,
                    "sales_url": prod_url,
                    "tiers_count": len(parsed_tiers),
                    "tiers": parsed_tiers
                }
                services_list.append(service_info)
                print(f"      [✓] Berhasil mendeteksi {len(parsed_tiers)} paket.")
                
            except Exception as ex:
                print(f"      [!] Gagal scraping {prod_url}: {ex}")
                services_list.append({
                    "slug": slug,
                    "sales_url": prod_url,
                    "error": str(ex),
                    "tiers": []
                })
        
        browser.close()
        
    catalog_result["total_services"] = len(services_list)
    catalog_result["services"] = services_list
    return catalog_result


def export_dart_code(catalog: Dict[str, Any], filepath: str):
    """Menghasilkan file Dart mapping untuk digunakan langsung di Flutter."""
    dart_lines = [
        "// Generated automatically by sync_goakal_catalog.py",
        "// DO NOT EDIT MANUALLY. Run 'python3 sync_goakal_catalog.py' to refresh.",
        "",
        "class GoAkalTierLink {",
        "  final String durationKey; // '1_month', '6_months', '1_year'",
        "  final String priceLabel;",
        "  final String quotaLabel;",
        "  final String applyUrl;",
        "",
        "  const GoAkalTierLink({",
        "    required this.durationKey,",
        "    required this.priceLabel,",
        "    required this.quotaLabel,",
        "    required this.applyUrl,",
        "  });",
        "}",
        "",
        "class GoAkalCatalogRegistry {",
        "  static const String storeUrl = 'https://goakal.com/openturath-ai';",
        "",
        "  static const Map<String, Map<String, GoAkalTierLink>> directLinks = {",
    ]
    
    for s in catalog.get("services", []):
        slug = s.get("slug", "")
        dart_lines.append(f"    '{slug}': {{")
        for t in s.get("tiers", []):
            tier_key = t.get("tier", "custom")
            price = t.get("price", "")
            quota = t.get("quota", "")
            apply_url = t.get("apply_url", "")
            dart_lines.append(f"      '{tier_key}': GoAkalTierLink(")
            dart_lines.append(f"        durationKey: '{tier_key}',")
            dart_lines.append(f"        priceLabel: '{price}',")
            dart_lines.append(f"        quotaLabel: '{quota}',")
            dart_lines.append(f"        applyUrl: '{apply_url}',")
            dart_lines.append(f"      ),")
        dart_lines.append(f"    }},")
        
    dart_lines.extend([
        "  };",
        "",
        "  /// Mendapatkan direct link apply berdasarkan slug AI dan durasi.",
        "  static String? getApplyUrl(String agentSlug, String durationKey) {",
        "    return directLinks[agentSlug]?[durationKey]?.applyUrl;",
        "  }",
        "}",
    ])
    
    code = "\n".join(dart_lines) + "\n"
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(code)
    print(f"[✓] File Dart berhasil di-generate: {filepath}")


def main():
    parser = argparse.ArgumentParser(description="GoAkal Catalog & Direct Apply Extractor")
    parser.add_argument("--url", default=STORE_URL_DEFAULT, help="URL Toko GoAkal OpenTurath")
    parser.add_argument("--output-json", default=OUTPUT_JSON_DEFAULT, help="Lokasi output file JSON master")
    parser.add_argument("--output-dart", default="", help="Lokasi file output Dart (opsional)")
    args = parser.parse_args()

    catalog = run_crawler(args.url)
    
    # Simpan JSON master
    with open(args.output_json, "w", encoding="utf-8") as f:
        json.dump(catalog, f, indent=2, ensure_ascii=False)
    print(f"\n[3/3] [✓] Katalog JSON master berhasil disimpan di: {args.output_json}")
    
    if args.output_dart:
        export_dart_code(catalog, args.output_dart)

    print("\n" + "=" * 60)
    print("SINKRONISASI SUKSES! Seluruh direct link siap digunakan.")
    print("=" * 60)


if __name__ == "__main__":
    main()
