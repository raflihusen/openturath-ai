#!/usr/bin/env python3
"""
auto_post_goakal_disciplines.py
================================
Skrip otomatisasi untuk menerbitkan seluruh produk layanan AI Disiplin Turath
ke GoAkal (goakal.com) secara instan melalui External REST API.

Fitur:
1. Menerbitkan Service ke GoAkal (title, url_id/slug, deskripsi, cover banner).
2. Membuat 3 skema harga otomatis (1 Bulan: Rp299k, 6 Bulan: Rp1.499k, 12 Bulan: Rp1.999k).
3. Melampirkan benefit akses anggota secara otomatis.
4. Mendukung mode dry-run atau eksekusi live satu-per-satu atau batch.
5. Idempoten: Tidak akan membuat duplikat jika slug sudah ada di GoAkal.

Author: OpenTurath AI Team
"""

import os
import sys
import time
import json
import logging
import requests
from typing import Dict, List, Any

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("GoAkalAutoPoster")

AKAL_BASE_URL = "https://goakal.com/service/api/v1"

# Ambil AKAL_API_KEY dari env atau file .env
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
    logger.error("AKAL_API_KEY tidak ditemukan di env atau file .env!")
    sys.exit(1)

HEADERS = {
    "X-Api-Key": API_KEY,
    "Content-Type": "application/json",
}

# Banner default yang terdaftar di GoAkal Azure Blob Storage
DEFAULT_BANNER = [
    {
        "type": "image",
        "mediaId": "YuWBTfja_MmzacMH9K6aF",
        "mediaUrl": "https://akalstorageaccount1.blob.core.windows.net/akalcontainer1/ngaji-tahawwulat/YuWBTfja_MmzacMH9K6aF"
    }
]

# Benefit ID terdaftar di akun GoAkal
DEFAULT_BENEFIT_ID = 2506

# Daftar 17 Disiplin Ilmu Turath Tambahan yang siap dipublikasikan
DISCIPLINES_TO_POST = [
    {
        "url_id": "ushul-fikih",
        "title": "SUPER AI USHUL FIKIH",
        "description": "Asisten riset Ushul Fikih tingkat lanjut untuk membedah kaidah istinbath hukum, dalil syar'i, qiyas, dan metodologi ushuliyyah dari puluhan kitab induk muktamad.",
    },
    {
        "url_id": "hadits-nabawi",
        "title": "SUPER AI HADITS NABAWI",
        "description": "Asisten penelusuran Kutubut Tis'ah dan ratusan kitab hadis induk dengan pelacakan sanad, matan, dan derajat keotentikan hadis secara instan.",
    },
    {
        "url_id": "tafsir-ulumul-quran",
        "title": "SUPER AI TAFSIR & ULUMUL QUR'AN",
        "description": "Asisten eksegesis Al-Qur'an dan Ulumul Qur'an berbasis puluhan kitab tafsir bi al-ma'tsur dan bi ar-ra'yi terkemuka lintas generasi mufassir.",
    },
    {
        "url_id": "qawaid-fiqhiyyah",
        "title": "SUPER AI QAWAID FIQHIYYAH",
        "description": "Asisten kaidah-kaidah fikih asasiyyah dan far'iyyah untuk studi komparasi kasus kontemporer dan takhrij furu' 'alal ushul.",
    },
    {
        "url_id": "musthalah-hadits",
        "title": "SUPER AI MUSTHALAH & ULUMUL HADITS",
        "description": "Asisten kritik metodologi hadis, kaidah jarh wa ta'dil, ilal hadits, dan takhrij ilmiah berbasis kitab-kitab ushul hadits otoritatif.",
    },
    {
        "url_id": "aqidah-ushuluddin",
        "title": "SUPER AI AQIDAH & USHULUDDIN",
        "description": "Asisten kajian teologi Islam, ilmu kalam Ahlussunnah wal Jama'ah, dan pemurnian akidah berasaskan kitab-kitab ulama salaf dan khalaf.",
    },
    {
        "url_id": "fikih-hanafi",
        "title": "SUPER AI FIKIH HANAFI",
        "description": "Asisten riset fikih mazhab Imam Abu Hanifah lengkap dengan rujukan ibarah zhahir ar-riwayah dan fatwa muta'akhkhirin.",
    },
    {
        "url_id": "fikih-maliki",
        "title": "SUPER AI FIKIH MALIKI",
        "description": "Asisten penelusuran hukum mazhab Imam Malik bin Anas dengan pijakan 'amal ahl al-Madinah dan mudawwanah fiqhiyyah muktamadah.",
    },
    {
        "url_id": "fikih-hanbali",
        "title": "SUPER AI FIKIH HANBALI",
        "description": "Asisten telaah fikih mazhab Imam Ahmad bin Hanbal berbasis kitab-kitab mu'tamad riwayah dan masail Hanabilah.",
    },
    {
        "url_id": "fikih-muqaran",
        "title": "SUPER AI FIKIH MUQARAN & SIYASAH",
        "description": "Asisten komparasi fikih lintas 4 mazhab dan hukum tata negara Islam (siyasah syar'iyyah) untuk perumusan fatwa kontekstual.",
    },
    {
        "url_id": "fatawa-masail",
        "title": "SUPER AI FATAWA & MASAIL FIQHIYYAH",
        "description": "Asisten kompilasi fatwa ulama klasik dan kontemporer untuk menjawab problematika waqi'iyyah kekinian santri dan asatidz.",
    },
    {
        "url_id": "tasawwuf-adzkar",
        "title": "SUPER AI TASAWWUF & ADZKAR",
        "description": "Asisten spiritualitas Islam, tazkiyatun nufus, adab suluk, dan wirid/doa bersumber dari karya-karya sufi mu'tabar.",
    },
    {
        "url_id": "tajwid-qiraat",
        "title": "SUPER AI TAJWID & QIRAAT",
        "description": "Asisten ilmu kaidah bacaan Al-Qur'an, qiraat sab'ah/'asyarah, makhorijul huruf, dan rasm ushmani.",
    },
    {
        "url_id": "tarikh-sirah",
        "title": "SUPER AI TARIKH & SIRAH NABAWIYYAH",
        "description": "Asisten rekonstruksi sejarah peradaban Islam, kronik kenabian (Sirah Nabawiyyah), dan riwayat tarikh islamiyyah terlengkap.",
    },
    {
        "url_id": "syarah-hadits",
        "title": "SUPER AI SYARAH HADITS",
        "description": "Asisten eksplanasi komprehensif hadis nabawi merujuk Fathul Bari, Syarah Shahih Muslim Imam Nawawi, Umdatul Qari, dan syarah mu'tamad lainnya.",
    },
    {
        "url_id": "thabaqat-tarajim",
        "title": "SUPER AI THABAQAT & TARAJIM RIJAL",
        "description": "Asisten biografi ulama, silsilah thabaqat perawi hadis, dan mu'jam rijal al-hadits terlengkap lintas masa.",
    },
    {
        "url_id": "bibliografi-faharis",
        "title": "SUPER AI BIBLIOGRAFI & FAHARIS TURATH",
        "description": "Asisten pelacakan manuskrip, indeks katalog kitab turath, dan bibliografi keilmuan Islam lintas abad.",
    },
]

STANDARD_PRICE_TIERS = [
    {
        "title": "1 Bulan",
        "mainAmount": 299000,
        "type": "fixedAmount",
        "order": 0,
        "checklistDescription": [
            "Akses penuh Super AI Riset 24/7",
            "Akses korpus kitab induk digital",
            "Update sinkronisasi berkala"
        ],
        "benefits": [{"id": DEFAULT_BENEFIT_ID}]
    },
    {
        "title": "6 Bulan",
        "mainAmount": 1499000,
        "type": "fixedAmount",
        "order": 1,
        "checklistDescription": [
            "Hemat 16% paket 6 bulan",
            "Akses penuh Super AI Riset 24/7",
            "Prioritas komputasi & antrean cepat",
            "Akses korpus kitab induk digital"
        ],
        "benefits": [{"id": DEFAULT_BENEFIT_ID}]
    },
    {
        "title": "12 Bulan",
        "mainAmount": 1999000,
        "type": "fixedAmount",
        "order": 2,
        "checklistDescription": [
            "Paket Paling Hemat (Best Value)",
            "Akses 12 Bulan Penuh (1 Tahun)",
            "Prioritas utama riset ilmiah",
            "Dukungan teknis prioritas"
        ],
        "benefits": [{"id": DEFAULT_BENEFIT_ID}]
    }
]


def fetch_existing_services() -> Dict[str, Dict[str, Any]]:
    """Ambil seluruh service yang sudah ada di GoAkal."""
    res = requests.get(f"{AKAL_BASE_URL}/services?pageSize=50", headers=HEADERS)
    if res.status_code != 200:
        logger.error(f"Gagal mengambil daftar services: {res.text}")
        return {}
    data = res.json().get("data", [])
    mapping = {}
    for s in data:
        mapping[s["url_id"]] = s
    return mapping


def create_service(item: Dict[str, str]) -> Dict[str, Any]:
    """Buat service baru di GoAkal."""
    payload = {
        "title": item["title"],
        "url_id": item["url_id"],
        "type": "digital_product",
        "description": item["description"],
        "media_gallery": DEFAULT_BANNER,
    }
    res = requests.post(f"{AKAL_BASE_URL}/services", json=payload, headers=HEADERS)
    data = res.json()
    if not data.get("success"):
        logger.error(f"Gagal membuat service '{item['title']}': {data}")
        return {}
    
    svc = data.get("data", {})
    cuid = svc.get("cuid")
    # Pastikan description dan media_gallery terisi via PATCH jika belum tersimpan
    if cuid and (not svc.get("description") or not svc.get("media_gallery")):
        patch_payload = {
            "title": item["title"],
            "description": item["description"],
            "media_gallery": DEFAULT_BANNER,
        }
        res_patch = requests.patch(f"{AKAL_BASE_URL}/services/{cuid}", json=patch_payload, headers=HEADERS)
        if res_patch.status_code == 200 and res_patch.json().get("success"):
            svc = res_patch.json().get("data", svc)
    return svc


def create_price_scheme(service_cuid: str, scheme: Dict[str, Any]) -> Dict[str, Any]:
    """Buat skema harga untuk service tertentu."""
    url = f"{AKAL_BASE_URL}/services/{service_cuid}/price-schemes"
    res = requests.post(url, json=scheme, headers=HEADERS)
    data = res.json()
    if not data.get("success"):
        logger.error(f"Gagal membuat skema harga '{scheme['title']}': {data}")
        return {}
    return data.get("data", {})


def post_all_disciplines(dry_run: bool = False):
    """Proses posting batch untuk seluruh disiplin ilmu."""
    logger.info("Memeriksa katalog yang sudah aktif di GoAkal...")
    existing = fetch_existing_services()
    logger.info(f"Ditemukan {len(existing)} service aktif di GoAkal: {list(existing.keys())}")

    results = []

    for item in DISCIPLINES_TO_POST:
        slug = item["url_id"]
        title = item["title"]

        if slug in existing:
            logger.info(f"⏩ Service '{title}' ({slug}) SUDAH ADA. Melewati pembuatan service.")
            service_data = existing[slug]
            service_cuid = service_data["cuid"]
        else:
            logger.info(f"🚀 [BARU] Membuat Service: {title} ({slug})...")
            if dry_run:
                logger.info(f"[DRY-RUN] Simulasi pembuatan {title}")
                continue
            service_data = create_service(item)
            if not service_data:
                logger.error(f"Lewati tier untuk {slug} karena service gagal dibuat.")
                continue
            service_cuid = service_data["cuid"]
            logger.info(f"✅ Service berhasil dibuat! CUID: {service_cuid}")
            time.sleep(1)

        # Cek apakah skema harga sudah ada
        res_schemes = requests.get(f"{AKAL_BASE_URL}/services/{service_cuid}/price-schemes", headers=HEADERS)
        current_schemes = res_schemes.json().get("data", []) if res_schemes.status_code == 200 else []
        existing_titles = [cs.get("title") for cs in current_schemes]

        created_schemes = []
        for tier in STANDARD_PRICE_TIERS:
            if tier["title"] in existing_titles:
                logger.info(f"   ⏩ Skema harga '{tier['title']}' sudah ada untuk {slug}.")
            else:
                logger.info(f"   ➕ Menambahkan skema harga '{tier['title']}' (Rp{tier['mainAmount']:,})...")
                if dry_run:
                    continue
                scheme_data = create_price_scheme(service_cuid, tier)
                if scheme_data:
                    created_schemes.append(scheme_data)
                    logger.info(f"   ✅ Skema '{tier['title']}' aktif! Direct Apply URL: {scheme_data.get('url_link')}")
                time.sleep(1)

        results.append({
            "slug": slug,
            "title": title,
            "cuid": service_cuid,
            "schemes_count": len(current_schemes) + len(created_schemes)
        })

    logger.info(f"🎉 Selesai! Berhasil memproses {len(results)} disiplin ilmu.")
    return results


if __name__ == "__main__":
    is_dry = "--dry-run" in sys.argv
    if is_dry:
        logger.info("Menjalankan dalam MODE DRY-RUN (tidak ada perubahan riil ke GoAkal)...")
    post_all_disciplines(dry_run=is_dry)
