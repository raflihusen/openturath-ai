#!/usr/bin/env python3
"""
manage_ota.py
=============
CLI Pengendali Over-The-Air (OTA) OpenTurath AI:
1. Dynamic Pricing Control (Ubah nominal Rp 1.000 untuk tes QRIS real Midtrans Production atau Rp 299.000 (Fikih Tahawwulat) dan Rp 49.000 (AI per bidang) resmi tanpa update aplikasi).
2. Remote Agent Unlocking / Locking (Buka gembok AI spesialis baru secara bertahap langsung dari Firestore).

Penggunaan:
  python3 manage_ota.py status
  python3 manage_ota.py set-pricing --mode test         # Set Tholib 1 Bulan = Rp 1.000
  python3 manage_ota.py set-pricing --mode production   # Tahawwulat 1 Bulan = Rp 299.000, AI per bidang 1 Bulan = Rp 49.000
  python3 manage_ota.py unlock-agent hadith_kutub_sittah
  python3 manage_ota.py lock-agent hadith_kutub_sittah
  python3 manage_ota.py seed                            # Inisialisasi dokumen app_config

Saklar fitur (app_config/features), tanpa update aplikasi:
  python3 manage_ota.py features                        # Lihat status saklar fitur
  python3 manage_ota.py soon-sub-agent fiqh_tahawwulat_khatib   # Tandai "segera hadir"
  python3 manage_ota.py release-sub-agent fiqh_tahawwulat_khatib # Buka untuk semua pengguna
  python3 manage_ota.py intro on|off                    # Tombol "Mengenal Fikih Tahawwulat"
  (tambahkan --dry-run untuk melihat perubahan tanpa menulis ke Firestore)

Pemeriksaan rilis (baca-saja, tidak mengubah apa pun):
  python3 manage_ota.py verify-release
"""

import sys
import re
import json
import subprocess
import urllib.request
import urllib.error
import argparse
from datetime import datetime, timezone

PROJECT_ID = "open-turath"
BASE_FIRESTORE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/app_config"

ALL_KNOWN_AGENTS = [
    "fiqh_tahawwulat",
    "fiqh_syafii",
    "aqidah_al_asyairah",
    "hadith_kutub_sittah",
    "ushul_fiqh_syafii",
    "ulumul_quran_mufassir",
    "tasawwuf_tazkiyah",
    "sirah_nabawiyyah",
    "qawaid_fiqhiyyah",
    "nahwu_sharaf",
    "balaghah_adab",
    "mantiq_kalam",
    "tarikh_islam",
    "rijal_al_hadith",
    "faraidh_mawarits",
    "akhlaq_adab",
    "lughah_mujam",
    "musthalah_hadith",
    "fiqh_hanafi",
    "fiqh_maliki",
    "fiqh_hanbali",
]

DEFAULT_ACTIVE_AGENTS = ["fiqh_tahawwulat", "fiqh_syafii"]

# Saklar fitur (app_config/features). Nilai bawaan HARUS sama dengan
# FeatureFlags.defaults (Flutter) dan DEFAULT_SOON_SUB_AGENTS (Cloud Functions).
FEATURES_DOC = "features"
KNOWN_SUB_AGENTS = [
    "fiqh_tahawwulat_muhaqqiq",
    "fiqh_tahawwulat_bayan",
    "fiqh_tahawwulat_mukhtabir",
    "fiqh_tahawwulat_habib",
    "fiqh_tahawwulat_khatib",
]
DEFAULT_SOON_SUB_AGENTS = [
    "fiqh_tahawwulat_khatib",
    "fiqh_tahawwulat_habib",
    "fiqh_tahawwulat_mukhtabir",
]
DEFAULT_INTRODUCTION_ENABLED = False
MAX_SOON_IDS = 50
SUB_AGENT_ID_PATTERN = re.compile(r"^[a-z][a-z0-9_]{0,79}$")


class FeatureError(Exception):
    """Perintah fitur tidak valid; pesannya aman ditampilkan ke operator."""


def validate_sub_agent_id(agent_id):
    """Id harus berformat benar dan termasuk sub-AI yang dikenal."""
    agent_id = (agent_id or "").strip()
    if not SUB_AGENT_ID_PATTERN.match(agent_id):
        raise FeatureError(f"Id '{agent_id}' tidak valid (huruf kecil, angka, garis bawah).")
    if agent_id not in KNOWN_SUB_AGENTS:
        raise FeatureError(
            f"'{agent_id}' bukan sub-AI yang dikenal. Pilihan: {', '.join(KNOWN_SUB_AGENTS)}"
        )
    return agent_id


def read_features(fields):
    """Membaca dokumen features dengan aturan yang SAMA dengan klien dan server."""
    data = fields or {}
    raw = data.get("soon_sub_agent_ids")
    soon = list(DEFAULT_SOON_SUB_AGENTS)
    if isinstance(raw, list):
        ids = []
        for item in raw:
            if isinstance(item, str) and SUB_AGENT_ID_PATTERN.match(item.strip()):
                if item.strip() not in ids:
                    ids.append(item.strip())
        if len(ids) <= MAX_SOON_IDS:
            soon = ids
    intro = data.get("introduction_enabled")
    if not isinstance(intro, bool):
        intro = DEFAULT_INTRODUCTION_ENABLED
    return {"soon_sub_agent_ids": soon, "introduction_enabled": intro}


def apply_feature_change(current, *, soon=None, release=None, intro=None):
    """Mengembalikan keadaan baru. Tidak pernah mengubah `current` di tempat."""
    soon_ids = list(current["soon_sub_agent_ids"])
    intro_enabled = current["introduction_enabled"]
    if soon is not None:
        agent_id = validate_sub_agent_id(soon)
        if agent_id not in soon_ids:
            soon_ids.append(agent_id)
    if release is not None:
        agent_id = validate_sub_agent_id(release)
        soon_ids = [a for a in soon_ids if a != agent_id]
    if intro is not None:
        if intro not in ("on", "off"):
            raise FeatureError("Pilih: on atau off.")
        intro_enabled = intro == "on"
    return {"soon_sub_agent_ids": sorted(soon_ids), "introduction_enabled": intro_enabled}


def same_features(a, b):
    """Dua keadaan dianggap sama bila himpunan sub-AI dan saklar Mengenal sama (urutan tak berarti)."""
    return (
        set(a["soon_sub_agent_ids"]) == set(b["soon_sub_agent_ids"])
        and a["introduction_enabled"] == b["introduction_enabled"]
    )


def to_firestore_features_fields(state, note=""):
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    return {
        "soon_sub_agent_ids": {
            "arrayValue": {"values": [{"stringValue": a} for a in state["soon_sub_agent_ids"]]}
        },
        "introduction_enabled": {"booleanValue": bool(state["introduction_enabled"])},
        "updated_at": {"stringValue": now_iso},
        "note": {"stringValue": note},
    }

PRODUCTION_PRICES = {
    # Modul Spesialis Per Bidang Ilmu (Fikih Syafi'i, Hadis, dll.)
    "tholib_1m": 49000,
    "tholib_6m": 299000,
    "bahits_1y": 499000,
    # Modul Khusus Fikih Tahawwulat (5 Bilik AI Terpadu)
    "tahawwulat_1m": 299000,
    "tahawwulat_6m": 1499000,
    "tahawwulat_1y": 1999000,
    # Paket Kehormatan & Add-on
    "mustawa_1y": 1500000,
    "bithaqah_lifetime": 5000000,
    "specialist_add_on": 49000,
}

TEST_PRICES = {
    # Mode Pengujian QRIS Midtrans Production (Rp 1.000)
    "tholib_1m": 1000,
    "tholib_6m": 299000,
    "bahits_1y": 499000,
    "tahawwulat_1m": 1000,
    "tahawwulat_6m": 1499000,
    "tahawwulat_1y": 1999000,
    "mustawa_1y": 1500000,
    "bithaqah_lifetime": 5000000,
    "specialist_add_on": 1000,
}


def get_token():
    try:
        token = subprocess.check_output(
            ["gcloud", "auth", "print-access-token"], text=True
        ).strip()
        if token:
            return token
    except Exception as e:
        print(f"❌ Gagal mengambil gcloud token: {e}")
        print("Pastikan Anda sudah login via: gcloud auth login")
        sys.exit(1)
    return None


def rest_get(doc_name, token):
    url = f"{BASE_FIRESTORE_URL}/{doc_name}"
    req = urllib.request.Request(
        url,
        headers={
            "Authorization": f"Bearer {token}",
            "X-Goog-User-Project": PROJECT_ID,
        },
    )
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return data
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise e


def rest_patch(doc_name, fields_payload, token, update_mask=None):
    url = f"{BASE_FIRESTORE_URL}/{doc_name}"
    if update_mask:
        # Hanya bidang yang disebut yang ditulis; bidang lain di dokumen dibiarkan.
        query = "&".join(f"updateMask.fieldPaths={k}" for k in update_mask)
        url = f"{url}?{query}"
    payload = {"fields": fields_payload}
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {token}",
            "X-Goog-User-Project": PROJECT_ID,
            "Content-Type": "application/json",
        },
        method="PATCH",
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))


# --- Konversi Helper Firestore REST Format ---
def parse_firestore_fields(fields_dict):
    out = {}
    for k, v in fields_dict.items():
        if "stringValue" in v:
            out[k] = v["stringValue"]
        elif "integerValue" in v:
            out[k] = int(v["integerValue"])
        elif "doubleValue" in v:
            out[k] = float(v["doubleValue"])
        elif "booleanValue" in v:
            out[k] = v["booleanValue"]
        elif "mapValue" in v:
            out[k] = parse_firestore_fields(v["mapValue"].get("fields", {}))
        elif "arrayValue" in v:
            arr = []
            for item in v["arrayValue"].get("values", []):
                if "stringValue" in item:
                    arr.append(item["stringValue"])
                elif "mapValue" in item:
                    arr.append(parse_firestore_fields(item["mapValue"].get("fields", {})))
            out[k] = arr
    return out


def to_firestore_pricing_fields(pricing_dict, revision, note=""):
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    tholib_1m = pricing_dict.get("tholib_1m", 49000)
    tholib_6m = pricing_dict.get("tholib_6m", 299000)
    bahits_1y = pricing_dict.get("bahits_1y", 499000)
    t_1m = pricing_dict.get("tahawwulat_1m", 1000 if tholib_1m == 1000 else 299000)
    t_6m = pricing_dict.get("tahawwulat_6m", 1499000)
    t_1y = pricing_dict.get("tahawwulat_1y", 1999000)

    return {
        "tholib_1m": {"integerValue": str(tholib_1m)},
        "mustawa_1y": {"integerValue": str(pricing_dict.get("mustawa_1y", 1500000))},
        "bithaqah_lifetime": {
            "integerValue": str(pricing_dict.get("bithaqah_lifetime", 5000000))
        },
        "specialist_add_on": {
            "integerValue": str(pricing_dict.get("specialist_add_on", 300000))
        },
        "revision": {"stringValue": revision},
        "updated_at": {"stringValue": now_iso},
        "note": {"stringValue": note},
        "plans": {
            "mapValue": {
                "fields": {
                    "fiqh_tahawwulat": {
                        "mapValue": {
                            "fields": {
                                "tholib_1m": {
                                    "mapValue": {
                                        "fields": {
                                            "amount": {"integerValue": str(t_1m)},
                                            "regularAmount": {"integerValue": "1000000"},
                                        }
                                    }
                                },
                                "tholib_6m": {
                                    "mapValue": {
                                        "fields": {
                                            "amount": {"integerValue": str(t_6m)},
                                            "regularAmount": {"integerValue": "2995000"},
                                        }
                                    }
                                },
                                "bahits_1y": {
                                    "mapValue": {
                                        "fields": {
                                            "amount": {"integerValue": str(t_1y)},
                                            "regularAmount": {"integerValue": "4995000"},
                                        }
                                    }
                                },
                            }
                        }
                    },
                    "specialists": {
                        "mapValue": {
                            "fields": {
                                "tholib_1m": {
                                    "mapValue": {
                                        "fields": {
                                            "amount": {"integerValue": str(tholib_1m)},
                                            "regularAmount": {"integerValue": "300000"},
                                        }
                                    }
                                },
                                "tholib_6m": {
                                    "mapValue": {
                                        "fields": {
                                            "amount": {"integerValue": str(tholib_6m)},
                                            "regularAmount": {"integerValue": "1200000"},
                                        }
                                    }
                                },
                                "bahits_1y": {
                                    "mapValue": {
                                        "fields": {
                                            "amount": {"integerValue": str(bahits_1y)},
                                            "regularAmount": {"integerValue": "2400000"},
                                        }
                                    }
                                },
                            }
                        }
                    },
                }
            }
        },
    }


def to_firestore_agents_fields(active_agents, note=""):
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    array_values = [{"stringValue": aid} for aid in active_agents]
    return {
        "active_agent_ids": {"arrayValue": {"values": array_values}},
        "updated_at": {"stringValue": now_iso},
        "note": {"stringValue": note},
    }


# --- Command Handlers ---
def cmd_status(token):
    print("=" * 65)
    print("📡 STATUS OVER-THE-AIR (OTA) OPENTURATH AI")
    print("=" * 65)

    # 1. Pricing Status
    print("\n💰 1. KONFIGURASI HARGA (app_config/pricing):")
    pricing_doc = rest_get("pricing", token)
    if pricing_doc and "fields" in pricing_doc:
        p_data = parse_firestore_fields(pricing_doc["fields"])
        spec_1m = p_data.get("plans", {}).get("specialists", {}).get("tholib_1m", {}).get("amount", p_data.get("tholib_1m", 0))
        tahawwulat_1m = p_data.get("plans", {}).get("fiqh_tahawwulat", {}).get("tholib_1m", {}).get("amount", 299000)
        print(f"   • Spesialis 1 Bulan  : Rp {spec_1m:,}")
        print(f"   • Tahawwulat 1 Bulan : Rp {tahawwulat_1m:,}")
        print(f"   • Mustawa 1 Tahun    : Rp {p_data.get('mustawa_1y', 0):,}")
        print(f"   • Bithāqah Lifetime  : Rp {p_data.get('bithaqah_lifetime', 0):,}")
        print(f"   • Revision ID        : {p_data.get('revision', '-')}")
        print(f"   • Terakhir Diubah    : {p_data.get('updated_at', '-')}")
        print(f"   • Catatan            : {p_data.get('note', '-')}")
        if spec_1m == 1000 or p_data.get("tholib_1m") == 1000:
            print("   ⚠️ MODE AKTIF: [TESTING MIDTRANS PRODUCTION - Rp 1.000 QRIS]")
        else:
            print("   ✅ MODE AKTIF: [HARGA PRODUKSI RESMI]")
    else:
        print("   ℹ️ Dokumen Firestore belum dibuat. Aplikasi & Functions memakai DEFAULT:")
        for k, v in PRODUCTION_PRICES.items():
            print(f"   • {k:<18}: Rp {v:,}")

    # 2. Agents Status
    print("\n🔒 2. STATUS GEMBOK AGENT (app_config/agents):")
    agents_doc = rest_get("agents", token)
    if agents_doc and "fields" in agents_doc:
        a_data = parse_firestore_fields(agents_doc["fields"])
        active_list = a_data.get("active_agent_ids", [])
        updated_at = a_data.get("updated_at", "-")
    else:
        print("   ℹ️ Dokumen Firestore belum dibuat. Memakai DEFAULT peluncuran:")
        active_list = DEFAULT_ACTIVE_AGENTS
        updated_at = "Default lokal"

    print(f"   • Total Agen Terdaftar  : {len(ALL_KNOWN_AGENTS)}")
    print(f"   • Agen Aktif (Terbuka)  : {len(active_list)}")
    print(f"   • Agen Terkunci (Gembok): {len(ALL_KNOWN_AGENTS) - len(active_list)}")
    print(f"   • Terakhir Diperbarui   : {updated_at}")
    print("\n   Daftar Rincian:")
    for aid in ALL_KNOWN_AGENTS:
        status_label = "🟢 TERBUKA" if aid in active_list else "🔒 TERKUNCI (Tahqiq Khazanah)"
        print(f"     - {aid:<26} : {status_label}")
    print("=" * 65)


def cmd_set_pricing(mode, token):
    now_ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    if mode == "test":
        revision = f"rev-test-qris-1000-{now_ts}"
        note = "Testing Midtrans Production Rp 1.000 via QRIS"
        payload = to_firestore_pricing_fields(TEST_PRICES, revision, note)
        print("🚀 Mengubah harga ke MODE TEST (Rp 1.000 untuk Tholib 1 Bulan)...")
    elif mode == "production":
        revision = f"rev-prod-300k-{now_ts}"
        note = "Harga Resmi Peluncuran OpenTurath AI"
        payload = to_firestore_pricing_fields(PRODUCTION_PRICES, revision, note)
        print("🚀 Mengubah harga ke MODE PRODUKSI (Tahawwulat Rp 299.000, per bidang Rp 49.000, 1 Bulan)...")
    else:
        print(f"❌ Mode '{mode}' tidak dikenal. Pilih: test atau production.")
        return

    rest_patch("pricing", payload, token)
    print("✅ Firestore 'app_config/pricing' BERHASIL DIPERBARUI!")
    print(f"   Revision: {revision}")
    print("   Dampak  : Tanpa perlu update aplikasi, semua pengguna yang membuka dialog")
    print("             pembayaran sekarang akan langsung menerima harga baru ini.")


def cmd_unlock_agent(agent_id, token):
    if agent_id not in ALL_KNOWN_AGENTS:
        print(f"⚠️ Peringatan: '{agent_id}' tidak ada di daftar agen standar OpenTurath.")
        confirm = input("Tetap lanjutkan membuka gembok agen ini? (y/N): ").strip().lower()
        if confirm != "y":
            return

    agents_doc = rest_get("agents", token)
    current_active = set(DEFAULT_ACTIVE_AGENTS)
    if agents_doc and "fields" in agents_doc:
        current_active = set(parse_firestore_fields(agents_doc["fields"]).get("active_agent_ids", []))

    if agent_id in current_active:
        print(f"ℹ️ Agen '{agent_id}' memang sudah aktif dan terbuka.")
        return

    current_active.add(agent_id)
    payload = to_firestore_agents_fields(
        sorted(list(current_active)),
        f"Membuka gembok agen {agent_id} via OTA",
    )
    rest_patch("agents", payload, token)
    print(f"🎉 SUKSES! Gembok agen '{agent_id}' BERHASIL DIBUKA OVER-THE-AIR!")
    print(f"   Pengguna aplikasi kini langsung dapat mengakses modul '{agent_id}' tanpa update app.")


def cmd_lock_agent(agent_id, token):
    if agent_id in ("fiqh_tahawwulat", "fiqh_syafii"):
        print(f"❌ DILARANG: '{agent_id}' adalah modul master sakral dan tidak boleh dikunci!")
        return

    agents_doc = rest_get("agents", token)
    current_active = set(DEFAULT_ACTIVE_AGENTS)
    if agents_doc and "fields" in agents_doc:
        current_active = set(parse_firestore_fields(agents_doc["fields"]).get("active_agent_ids", []))

    if agent_id not in current_active:
        print(f"ℹ️ Agen '{agent_id}' sudah dalam kondisi terkunci.")
        return

    current_active.remove(agent_id)
    payload = to_firestore_agents_fields(
        sorted(list(current_active)),
        f"Mengunci kembali agen {agent_id} via OTA",
    )
    rest_patch("agents", payload, token)
    print(f"🔒 Agen '{agent_id}' BERHASIL DIKUNCI KEMBALI!")
    print(f"   Kartu modul akan menampilkan ikon gembok dan dialog Tahqiq Khazanah.")


def _load_features(token):
    doc = rest_get(FEATURES_DOC, token)
    exists = bool(doc and "fields" in doc)
    fields = parse_firestore_fields(doc["fields"]) if exists else {}
    return read_features(fields), exists, fields


def _print_features(state, exists):
    print(f"   • Dokumen app_config/features : {'ada' if exists else 'BELUM ADA (memakai bawaan aplikasi)'}")
    print(f"   • Mengenal Fikih Tahawwulat   : {'🟢 TAMPIL' if state['introduction_enabled'] else '⚪ DISEMBUNYIKAN'}")
    print("   • Sub-AI Fikih Tahawwulat:")
    for aid in KNOWN_SUB_AGENTS:
        label = "⏳ SEGERA HADIR (tidak bisa dibuka)" if aid in state["soon_sub_agent_ids"] else "🟢 TERBUKA"
        print(f"       - {aid:<28} : {label}")


def cmd_features(token):
    print("=" * 65)
    print("🎛️  SAKLAR FITUR JARAK JAUH (app_config/features)")
    print("=" * 65)
    state, exists, _ = _load_features(token)
    _print_features(state, exists)
    print("\n   Catatan: aplikasi membaca saklar ini maksimal tiap 60 detik.")
    print("   Versi aplikasi lama (sebelum saklar ini ada) tidak membacanya.")
    print("=" * 65)


def _write_features(new_state, current, exists, note, dry_run, token):
    if exists and same_features(new_state, current):
        print("ℹ️ Tidak ada perubahan; dokumen sudah dalam keadaan itu.")
        return
    print("Sesudah perubahan:")
    _print_features(new_state, True)
    if dry_run:
        print("\n🧪 DRY-RUN: tidak ada yang ditulis ke Firestore.")
        return
    payload = to_firestore_features_fields(new_state, note)
    # Hanya empat bidang milik saklar ini yang ditulis.
    rest_patch(
        FEATURES_DOC,
        payload,
        token,
        update_mask=["soon_sub_agent_ids", "introduction_enabled", "updated_at", "note"],
    )
    print("\n✅ app_config/features DIPERBARUI. Pengguna melihatnya dalam maksimal 60 detik")
    print("   (pengguna dengan aplikasi versi lama tidak terpengaruh).")


def cmd_soon_sub_agent(agent_id, dry_run, token):
    current, exists, _ = _load_features(token)
    new_state = apply_feature_change(current, soon=agent_id)
    if exists and same_features(new_state, current):
        print(f"ℹ️ '{agent_id}' sudah berstatus segera hadir.")
        return
    _write_features(new_state, current, exists, f"Sub-AI {agent_id} ditandai segera hadir via OTA", dry_run, token)


def cmd_release_sub_agent(agent_id, dry_run, token):
    current, exists, _ = _load_features(token)
    new_state = apply_feature_change(current, release=agent_id)
    if exists and same_features(new_state, current):
        print(f"ℹ️ '{agent_id}' sudah terbuka.")
        return
    _write_features(new_state, current, exists, f"Sub-AI {agent_id} dibuka untuk semua pengguna via OTA", dry_run, token)


def cmd_intro(mode, dry_run, token):
    current, exists, _ = _load_features(token)
    new_state = apply_feature_change(current, intro=mode)
    if exists and same_features(new_state, current):
        print(f"ℹ️ Mengenal Fikih Tahawwulat sudah dalam keadaan '{mode}'.")
        return
    _write_features(new_state, current, exists, f"Mengenal Fikih Tahawwulat {mode} via OTA", dry_run, token)


def cmd_seed(token):
    print("🌱 Menginisialisasi dokumen Firestore app_config/pricing dan app_config/agents...")
    now_ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    p_payload = to_firestore_pricing_fields(
        PRODUCTION_PRICES,
        f"rev-prod-init-{now_ts}",
        "Inisialisasi resmi produksi",
    )
    rest_patch("pricing", p_payload, token)
    print("   [OK] app_config/pricing berhasil di-seed!")

    a_payload = to_firestore_agents_fields(
        DEFAULT_ACTIVE_AGENTS,
        "Inisialisasi rilis peluncuran: Fikih Tahawwulat & Syafi'i aktif",
    )
    rest_patch("agents", a_payload, token)
    print("   [OK] app_config/agents berhasil di-seed!")
    print("✅ Selesai! Jalankan 'python3 manage_ota.py status' untuk memeriksa.")


def main():
    parser = argparse.ArgumentParser(description="Pengendali OTA OpenTurath AI")
    subparsers = parser.add_subparsers(dest="command", help="Perintah:")

    # status
    subparsers.add_parser("status", help="Cek status pricing dan gembok agen saat ini")

    # seed
    subparsers.add_parser("seed", help="Inisialisasi dokumen pricing & agents di Firestore")

    # set-pricing
    pricing_p = subparsers.add_parser("set-pricing", help="Ubah mode harga")
    pricing_p.add_argument(
        "--mode",
        choices=["test", "production"],
        required=True,
        help="test (Rp 1.000 QRIS) atau production (Rp 299.000 / Rp 49.000)",
    )

    # unlock-agent
    unlock_p = subparsers.add_parser("unlock-agent", help="Buka gembok AI spesialis")
    unlock_p.add_argument("agent_id", help="ID agen (misal: hadith_kutub_sittah)")

    # lock-agent
    lock_p = subparsers.add_parser("lock-agent", help="Kunci kembali AI spesialis")
    lock_p.add_argument("agent_id", help="ID agen")

    # features
    subparsers.add_parser("features", help="Lihat saklar fitur jarak jauh (sub-AI, Mengenal)")

    # soon-sub-agent / release-sub-agent / intro
    for name, helptext in (
        ("soon-sub-agent", "Tandai sub-AI Tahawwulat sebagai 'segera hadir'"),
        ("release-sub-agent", "Buka sub-AI Tahawwulat untuk semua pengguna"),
    ):
        sp = subparsers.add_parser(name, help=helptext)
        sp.add_argument("agent_id", help="ID sub-AI (misal: fiqh_tahawwulat_khatib)")
        sp.add_argument("--dry-run", action="store_true", help="Tampilkan hasil tanpa menulis")
    intro_p = subparsers.add_parser("intro", help="Tampilkan/sembunyikan tombol Mengenal Fikih Tahawwulat")
    intro_p.add_argument("mode", choices=["on", "off"])
    intro_p.add_argument("--dry-run", action="store_true", help="Tampilkan hasil tanpa menulis")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    token = get_token()

    if args.command == "status":
        cmd_status(token)
    elif args.command == "seed":
        cmd_seed(token)
    elif args.command == "set-pricing":
        cmd_set_pricing(args.mode, token)
    elif args.command == "unlock-agent":
        cmd_unlock_agent(args.agent_id, token)
    elif args.command == "lock-agent":
        cmd_lock_agent(args.agent_id, token)
    elif args.command == "features":
        cmd_features(token)
    elif args.command in ("soon-sub-agent", "release-sub-agent", "intro"):
        try:
            if args.command == "soon-sub-agent":
                cmd_soon_sub_agent(args.agent_id, args.dry_run, token)
            elif args.command == "release-sub-agent":
                cmd_release_sub_agent(args.agent_id, args.dry_run, token)
            else:
                cmd_intro(args.mode, args.dry_run, token)
        except FeatureError as exc:
            print(f"❌ {exc}")
            sys.exit(2)


if __name__ == "__main__":
    main()
