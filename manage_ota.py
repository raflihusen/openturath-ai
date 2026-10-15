#!/usr/bin/env python3
"""
manage_ota.py
=============
CLI Pengendali Over-The-Air (OTA) OpenTurath AI:
1. Dynamic Pricing Control (Ubah nominal Rp 1.000 untuk tes QRIS real Midtrans Production atau Rp 300.000 resmi tanpa update aplikasi).
2. Remote Agent Unlocking / Locking (Buka gembok AI spesialis baru secara bertahap langsung dari Firestore).

Penggunaan:
  python3 manage_ota.py status
  python3 manage_ota.py set-pricing --mode test         # Set Tholib 1 Bulan = Rp 1.000
  python3 manage_ota.py set-pricing --mode production   # Set Tholib 1 Bulan = Rp 300.000
  python3 manage_ota.py unlock-agent hadith_kutub_sittah
  python3 manage_ota.py lock-agent hadith_kutub_sittah
  python3 manage_ota.py seed                            # Inisialisasi dokumen app_config
"""

import sys
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

PRODUCTION_PRICES = {
    "tholib_1m": 300000,
    "mustawa_1y": 1500000,
    "bithaqah_lifetime": 5000000,
    "specialist_add_on": 300000,
}

TEST_PRICES = {
    "tholib_1m": 1000,  # Rp 1.000 (Minimum limit QRIS Nasional Midtrans Production)
    "mustawa_1y": 1500000,
    "bithaqah_lifetime": 5000000,
    "specialist_add_on": 300000,
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


def rest_patch(doc_name, fields_payload, token):
    url = f"{BASE_FIRESTORE_URL}/{doc_name}"
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
    t_1m = pricing_dict.get("tahawwulat_1m", 1000 if tholib_1m == 1000 else 300000)
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
        print(f"   • Tholib 1 Bulan     : Rp {p_data.get('tholib_1m', 0):,}")
        print(f"   • Mustawa 1 Tahun    : Rp {p_data.get('mustawa_1y', 0):,}")
        print(f"   • Bithāqah Lifetime  : Rp {p_data.get('bithaqah_lifetime', 0):,}")
        print(f"   • Specialist Add-On  : Rp {p_data.get('specialist_add_on', 0):,}")
        print(f"   • Revision ID        : {p_data.get('revision', '-')}")
        print(f"   • Terakhir Diubah    : {p_data.get('updated_at', '-')}")
        print(f"   • Catatan            : {p_data.get('note', '-')}")
        if p_data.get("tholib_1m") == 1000:
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
        print("🚀 Mengubah harga ke MODE PRODUKSI (Rp 300.000 untuk Tholib 1 Bulan)...")
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
        help="test (Rp 1.000 QRIS) atau production (Rp 300.000)",
    )

    # unlock-agent
    unlock_p = subparsers.add_parser("unlock-agent", help="Buka gembok AI spesialis")
    unlock_p.add_argument("agent_id", help="ID agen (misal: hadith_kutub_sittah)")

    # lock-agent
    lock_p = subparsers.add_parser("lock-agent", help="Kunci kembali AI spesialis")
    lock_p.add_argument("agent_id", help="ID agen")

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


if __name__ == "__main__":
    main()
