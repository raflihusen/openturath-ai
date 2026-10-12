#!/usr/bin/env python3
"""
auto_post_goakal_bundles.py
============================
Menerbitkan 5 Paket Tematik + 1 Paket Sultan All-Access ke GoAkal.
Menghasilkan skema harga berdurasi 1 Bulan, 6 Bulan, dan 12 Bulan (1 Tahun)
lengkap dengan benefit akses akun otomatis (ID 2506).
"""

import os
import sys
import json
import logging
import requests
from typing import Dict, List, Any

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("GoAkalBundlePoster")

AKAL_BASE_URL = "https://goakal.com/service/api/v1"

# Ambil API KEY
API_KEY = os.getenv("AKAL_API_KEY", "")
if not API_KEY:
    env_paths = [
        "/Users/apple/Downloads/ramadhan/openturath_ai/functions/.env",
        "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/.env",
    ]
    for ep in env_paths:
        if os.path.exists(ep):
            with open(ep, "r") as f:
                for line in f:
                    if line.strip().startswith("AKAL_API_KEY="):
                        API_KEY = line.strip().split("=", 1)[1].strip().strip('"').strip("'")
                        break
        if API_KEY:
            break

if not API_KEY:
    logger.error("AKAL_API_KEY tidak ditemukan!")
    sys.exit(1)

HEADERS = {
    "X-Api-Key": API_KEY,
    "Content-Type": "application/json",
}

DEFAULT_BANNER = [
    {
        "type": "image",
        "mediaId": "YuWBTfja_MmzacMH9K6aF",
        "mediaUrl": "https://akalstorageaccount1.blob.core.windows.net/akalcontainer1/ngaji-tahawwulat/YuWBTfja_MmzacMH9K6aF"
    }
]

DEFAULT_BENEFIT_ID = 2506

BUNDLES = [
    {
        "url_id": "paket-fikih-pesantren",
        "title": "PAKET FIKIH PESANTREN & SANTRI SALAF",
        "description": "Suite riset Fikih Syafi'i & Bahtsul Masail terlengkap. Mencakup Super AI Fikih Syafi'i, Ushul Fikih, Qawaid Fiqhiyyah, Fatawa & Masail, serta Tasawwuf & Adzkar.",
        "tiers": [
            {
                "title": "1 Bulan (Harga Khusus Launch)",
                "mainAmount": 99000,
                "type": "fixedAmount",
                "order": 0,
                "checklistDescription": [
                    "Harga Promo Peluncuran Perdana",
                    "Akses 5 AI Fikih & Bahtsul Masail 24/7",
                    "Kitab Al-Umm, Minhaj, Fathul Mu'in, Tuhfah",
                    "Akses Kaidah Ushul, Qawaid, & Fatwa Akbar"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "6 Bulan (1 Semester)",
                "mainAmount": 499000,
                "type": "fixedAmount",
                "order": 1,
                "checklistDescription": [
                    "Hemat 16% paket satu semester",
                    "Akses 5 AI Fikih & Bahtsul Masail 24/7",
                    "Prioritas komputasi & antrean cepat",
                    "Update korpus kitab secara berkala"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "12 Bulan (1 Tahun)",
                "mainAmount": 890000,
                "type": "fixedAmount",
                "order": 2,
                "checklistDescription": [
                    "Paket Paling Populer & Super Hemat",
                    "Akses 12 Bulan Penuh (1 Tahun)",
                    "Dukungan riset akademik & bahtsul masail",
                    "Dukungan teknis prioritas"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
        ]
    },
    {
        "url_id": "paket-samudra-hadits",
        "title": "PAKET SAMUDRA HADITS & SIRAH NABAWIYYAH",
        "description": "Suite riset Hadits & Sirah komprehensif. Mencakup Super AI Hadits Nabawi, Syarah Hadits, Musthalah & Ulumul Hadits, Thabaqat & Tarajim Rijal, serta Tarikh & Sirah Nabawiyyah.",
        "tiers": [
            {
                "title": "1 Bulan (Harga Khusus Launch)",
                "mainAmount": 129000,
                "type": "fixedAmount",
                "order": 0,
                "checklistDescription": [
                    "Harga Promo Peluncuran Perdana",
                    "Akses 5 AI Hadits & Sirah 24/7",
                    "Kutubus Sittah, Fathul Bari, Syarah Nawawi",
                    "Kamus 20.000+ Biografi Rawi & Rijalul Hadits"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "6 Bulan (1 Semester)",
                "mainAmount": 649000,
                "type": "fixedAmount",
                "order": 1,
                "checklistDescription": [
                    "Hemat 16% paket riset hadis semesteran",
                    "Akses 5 AI Hadits & Sirah 24/7",
                    "Metodologi Takhrij & 'Ilal Hadits",
                    "Prioritas komputasi & respons kilat"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "12 Bulan (1 Tahun)",
                "mainAmount": 1190000,
                "type": "fixedAmount",
                "order": 2,
                "checklistDescription": [
                    "Paket Riset Tahunan Hadits & Sanad",
                    "Akses 12 Bulan Penuh (1 Tahun)",
                    "Pelacakan Asbabul Wurud & Sirah Nabawiyyah",
                    "Dukungan teknis prioritas"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
        ]
    },
    {
        "url_id": "paket-tafsir-bahasa-arab",
        "title": "PAKET MUFASSIR & KHAZANAH BAHASA ARAB",
        "description": "Suite eksegesis Al-Qur'an dan ilmu alat Arabiyyah. Mencakup Super AI Tafsir & Ulumul Qur'an, Tajwid & Qira'at, Bahasa Arab & Balaghah & Kamus Klasik, serta Bibliografi & Faharis.",
        "tiers": [
            {
                "title": "1 Bulan (Harga Khusus Launch)",
                "mainAmount": 99000,
                "type": "fixedAmount",
                "order": 0,
                "checklistDescription": [
                    "Harga Promo Peluncuran Perdana",
                    "Akses 4 AI Tafsir & Bahasa Arab 24/7",
                    "Tafsir Thabari, Ibnu Katsir, Razi, Qurthubi",
                    "Lisanul Arab, Alfiyyah, Dalailul I'jaz"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "6 Bulan (1 Semester)",
                "mainAmount": 499000,
                "type": "fixedAmount",
                "order": 1,
                "checklistDescription": [
                    "Hemat 16% paket semesteran",
                    "Akses 4 AI Tafsir & Bahasa Arab 24/7",
                    "Kaidah Bacaan 10 Imam Mutawatir",
                    "Peta Manuskrip & Bibliografi Kitab"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "12 Bulan (1 Tahun)",
                "mainAmount": 890000,
                "type": "fixedAmount",
                "order": 2,
                "checklistDescription": [
                    "Paket Paling Hemat Mufassir & Peneliti",
                    "Akses 12 Bulan Penuh (1 Tahun)",
                    "Eksplorasi leksikografi & balaghah Al-Qur'an",
                    "Dukungan teknis prioritas"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
        ]
    },
    {
        "url_id": "paket-mazhab-akbar",
        "title": "PAKET MUFTI, MAZHAB AKBAR & PEMIKIRAN",
        "description": "Suite komparasi hukum lintas mazhab dan teologi. Mencakup Super AI Fikih Hanafi, Fikih Maliki, Fikih Hanbali, Fikih Muqaran & Siyasah, Aqidah & Ushuluddin, serta Fatawa Akbar.",
        "tiers": [
            {
                "title": "1 Bulan (Harga Khusus Launch)",
                "mainAmount": 149000,
                "type": "fixedAmount",
                "order": 0,
                "checklistDescription": [
                    "Harga Promo Peluncuran Perdana",
                    "Akses 6 AI Mazhab & Teologi Islam 24/7",
                    "Fikih Hanafi, Maliki, Syafi'i, Hanbali komparatif",
                    "Kajian Kalam, Asy'ariyah-Maturidiyah & Sekte"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "6 Bulan (1 Semester)",
                "mainAmount": 749000,
                "type": "fixedAmount",
                "order": 1,
                "checklistDescription": [
                    "Hemat 16% paket riset perbandingan mazhab",
                    "Akses 6 AI Mazhab & Teologi Islam 24/7",
                    "Studi Siyasah Syar'iyyah & Tata Negara",
                    "Prioritas komputasi tingkat tinggi"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "12 Bulan (1 Tahun)",
                "mainAmount": 1390000,
                "type": "fixedAmount",
                "order": 2,
                "checklistDescription": [
                    "Paket Tahunan Peneliti & Dosen Syariah",
                    "Akses 12 Bulan Penuh (1 Tahun)",
                    "Koleksi fatwa akbar lintas mazhab",
                    "Dukungan teknis prioritas"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
        ]
    },
    {
        "url_id": "paket-fikih-tahawwulat",
        "title": "PAKET KHUSUS FIKIH TAHAWWULAT",
        "description": "Suite komprehensif kajian Fikih Tahawwulat karya Al-Allamah Habib Abu Bakar Al-Adni Al-Masyhur. Mencakup 5 Persona AI: Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, dan Al-Khatib.",
        "tiers": [
            {
                "title": "1 Bulan (Harga Khusus Launch)",
                "mainAmount": 99000,
                "type": "fixedAmount",
                "order": 0,
                "checklistDescription": [
                    "Harga Promo Peluncuran Perdana",
                    "Akses 5 Persona AI Tahawwulat 24/7",
                    "Al-Muhaqqiq (Bedah Konsep & Dalil Ushul)",
                    "Al-Bayan (Panduan Sikap Dakwah & Solusi)",
                    "Al-Mukhtabir, Al-Habib, & Al-Khatib"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "6 Bulan (1 Semester)",
                "mainAmount": 499000,
                "type": "fixedAmount",
                "order": 1,
                "checklistDescription": [
                    "Hemat 16% paket satu semester",
                    "Akses 5 Persona AI Tahawwulat 24/7",
                    "Panduan pembacaan tanda-tanda akhir zaman",
                    "Penyusun teks khutbah & retorika da'i"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "12 Bulan (1 Tahun)",
                "mainAmount": 890000,
                "type": "fixedAmount",
                "order": 2,
                "checklistDescription": [
                    "Paket Tahunan Santri & Pengkaji Tahawwulat",
                    "Akses 12 Bulan Penuh (1 Tahun)",
                    "Prioritas komputasi & update berkala",
                    "Dukungan teknis prioritas"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
        ]
    },
    {
        "url_id": "paket-sultan-all-access",
        "title": "PAKET SULTAN ALL-ACCESS (SEMUA 24 AI)",
        "description": "Akses tanpa batas ke seluruh ekosistem OpenTurath AI: 20 Modul Turath Klasik + 5 Persona Fikih Tahawwulat. Termasuk prioritas riset dan update korpus otomatis.",
        "tiers": [
            {
                "title": "1 Bulan (Harga Khusus Launch)",
                "mainAmount": 249000,
                "type": "fixedAmount",
                "order": 0,
                "checklistDescription": [
                    "Harga Promo Peluncuran Perdana VIP",
                    "Akses TANPA BATAS Seluruh 24 AI Turath",
                    "Akses Fikih Syafi'i, Hadits, Tafsir, Bahasa Arab, Mazhab, & Tahawwulat",
                    "Prioritas antrean super cepat"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "6 Bulan (1 Semester)",
                "mainAmount": 1249000,
                "type": "fixedAmount",
                "order": 1,
                "checklistDescription": [
                    "Hemat 16% paket all-access semesteran",
                    "Akses TANPA BATAS Seluruh 24 AI Turath",
                    "Ideal untuk peneliti, dosen, & lembaga dakwah",
                    "Dukungan teknis langsung"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
            {
                "title": "12 Bulan (1 Tahun)",
                "mainAmount": 1990000,
                "type": "fixedAmount",
                "order": 2,
                "checklistDescription": [
                    "Nilai Terbaik & Rekomendasi Pesantren/Kampus",
                    "Akses Penuh 12 Bulan untuk Seluruh 24 AI",
                    "Termasuk seluruh rilis modul baru di masa depan",
                    "Dukungan VIP & asistensi riset prioritas"
                ],
                "benefits": [{"id": DEFAULT_BENEFIT_ID}]
            },
        ]
    }
]


def fetch_existing_services() -> Dict[str, Dict[str, Any]]:
    res = requests.get(f"{AKAL_BASE_URL}/services?pageSize=50", headers=HEADERS)
    if res.status_code != 200:
        logger.error(f"Gagal mengambil daftar services: {res.text}")
        return {}
    data = res.json().get("data", [])
    mapping = {}
    for s in data:
        mapping[s["url_id"]] = s
    return mapping


def create_service(bundle: Dict[str, Any]) -> Dict[str, Any]:
    payload = {
        "title": bundle["title"],
        "url_id": bundle["url_id"],
        "type": "digital_product",
        "description": bundle["description"],
        "media_gallery": DEFAULT_BANNER,
    }
    res = requests.post(f"{AKAL_BASE_URL}/services", json=payload, headers=HEADERS)
    data = res.json()
    if not data.get("success"):
        logger.error(f"Gagal membuat service '{bundle['title']}': {data}")
        return {}
    
    svc = data.get("data", {})
    cuid = svc.get("cuid")
    if cuid and (not svc.get("description") or not svc.get("media_gallery")):
        patch_payload = {
            "title": bundle["title"],
            "description": bundle["description"],
            "media_gallery": DEFAULT_BANNER,
        }
        res_patch = requests.patch(f"{AKAL_BASE_URL}/services/{cuid}", json=patch_payload, headers=HEADERS)
        if res_patch.status_code == 200 and res_patch.json().get("success"):
            svc = res_patch.json().get("data", svc)
    return svc


def create_price_scheme(service_cuid: str, scheme: Dict[str, Any]) -> Dict[str, Any]:
    url = f"{AKAL_BASE_URL}/services/{service_cuid}/price-schemes"
    res = requests.post(url, json=scheme, headers=HEADERS)
    data = res.json()
    if not data.get("success"):
        logger.error(f"Gagal membuat skema harga '{scheme['title']}': {data}")
        return {}
    return data.get("data", {})


def main():
    logger.info("Mengecek katalog existing di GoAkal...")
    existing = fetch_existing_services()
    logger.info(f"Ditemukan {len(existing)} service aktif di akun GoAkal.")

    # Load master catalog jika sudah ada
    master_catalog_path = "goakal_catalog_master.json"
    if os.path.exists(master_catalog_path):
        with open(master_catalog_path, "r", encoding="utf-8") as f:
            master_catalog = json.load(f)
    else:
        master_catalog = {}

    for bundle in BUNDLES:
        url_id = bundle["url_id"]
        logger.info(f"\n========================================\nMemproses Bundle: {bundle['title']} ({url_id})")

        if url_id in existing:
            logger.info(f"Service '{url_id}' sudah ada di GoAkal.")
            svc = existing[url_id]
        else:
            logger.info(f"Menerbitkan service baru: '{bundle['title']}'...")
            svc = create_service(bundle)
            if not svc:
                logger.error(f"Gagal membuat service '{bundle['title']}', lanjut ke paket berikutnya.")
                continue

        cuid = svc.get("cuid")
        existing_schemes = svc.get("price_schemes", [])
        logger.info(f"Service CUID: {cuid}, Skema harga existing: {len(existing_schemes)}")

        bundle_master_entry = {
            "title": svc.get("title", bundle["title"]),
            "cuid": cuid,
            "url_id": url_id,
            "page_url": f"https://goakal.com/openturath-ai/{url_id}",
            "tiers": master_catalog.get(url_id, {}).get("tiers", {})
        }

        # Petakan skema harga existing
        scheme_map = {}
        for s in existing_schemes:
            amt = s.get("mainAmount")
            scheme_map[amt] = s

        tier_keys = ["1_month", "6_months", "1_year"]
        for idx, t_spec in enumerate(bundle["tiers"]):
            amt = t_spec["mainAmount"]
            t_key = tier_keys[idx]

            if amt in scheme_map:
                existing_s = scheme_map[amt]
                p_cuid = existing_s.get("cuid")
                logger.info(f"  - Skema harga {t_spec['title']} (Rp {amt:,}) sudah ada: cuid={p_cuid}")
                bundle_master_entry["tiers"][t_key] = {
                    "title": t_spec["title"],
                    "amount": amt,
                    "cuid": p_cuid,
                    "apply_url": f"https://goakal.com/openturath-ai/{url_id}/{p_cuid}/apply"
                }
            else:
                logger.info(f"  + Menambahkan skema harga {t_spec['title']} (Rp {amt:,})...")
                created_s = create_price_scheme(cuid, t_spec)
                if created_s:
                    p_cuid = created_s.get("cuid")
                    logger.info(f"    -> Berhasil dibuat! CUID: {p_cuid}")
                    bundle_master_entry["tiers"][t_key] = {
                        "title": t_spec["title"],
                        "amount": amt,
                        "cuid": p_cuid,
                        "apply_url": f"https://goakal.com/openturath-ai/{url_id}/{p_cuid}/apply"
                    }

        master_catalog[url_id] = bundle_master_entry

    # Simpan kembali ke master catalog
    with open(master_catalog_path, "w", encoding="utf-8") as f:
        json.dump(master_catalog, f, indent=2, ensure_ascii=False)
    logger.info(f"\nMaster catalog berhasil diperbarui di {master_catalog_path}")


if __name__ == "__main__":
    main()
