import os
import sys
import json
import asyncio
from datetime import datetime, timezone
from google.cloud import firestore

NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

import socket
_orig_getaddrinfo = socket.getaddrinfo
def _resilient_getaddrinfo(host, port, *args, **kwargs):
    h_str = host.decode("utf-8", "ignore") if isinstance(host, (bytes, bytearray)) else str(host)
    if h_str == "notebooklm.google.com":
        return _orig_getaddrinfo("142.250.74.78", port, *args, **kwargs)
    return _orig_getaddrinfo(host, port, *args, **kwargs)
socket.getaddrinfo = _resilient_getaddrinfo

from notebooklm import NotebookLMClient

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path)

MASTER_NOTEBOOKS = [
    {"name": "01 - FIKIH SYAFII (MASTER)", "id": "c89d09ca-4b48-4000-a98d-59e532607fb6", "key": "fiqh_syafii"},
    {"name": "AI Fikih Syafi'i (Legacy)", "id": "334e7b83-0e76-4787-a1d6-314642a35862", "key": "fiqh_syafii"},
    {"name": "Al-Muhaqqiq (Tahawwulat)", "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4", "key": "fiqh_tahawwulat"},
    {"name": "Al-Bayan (Fikih Tahawwulat)", "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd", "key": "fiqh_tahawwulat"},
    {"name": "Al-Mukhtabir (Fikih Tahawwulat)", "id": "ac61a7a0-87e7-42a5-a30f-980ff74a78d8", "key": "fiqh_tahawwulat"},
    {"name": "Al-Habib (Fikih Tahawwulat)", "id": "6673e79a-7156-42e1-b116-bc1653a32094", "key": "fiqh_tahawwulat"}
]

async def run_audit():
    now = datetime.now(timezone.utc)
    print("=" * 100)
    print(f"🔍 FORENSIK AUDIT MENDALAM: PENCABUTAN AKSES & KORBAN REAPER")
    print(f"Timestamp Audit: {now.isoformat()}")
    print("=" * 100)

    # 1. Kumpulkan SELURUH Riwayat Pencabutan di sharing_log
    sharing_logs = db.collection("sharing_log").stream()
    removals = []
    for doc in sharing_logs:
        d = doc.to_dict()
        if d.get("action") == "remove":
            removals.append(d)

    removals.sort(key=lambda x: str(x.get("created_at") or ""), reverse=True)
    print(f"\n1. TOTAL PERISTIWA PENCABUTAN DI SHARING_LOG: {len(removals)} kali")
    
    # Kelompokkan per user yang pernah dicabut
    removed_users = {} # email -> list of removal events
    for r in removals:
        em = (r.get("email") or "").strip().lower()
        if not em:
            continue
        if em not in removed_users:
            removed_users[em] = []
        removed_users[em].append(r)

    print(f"Total User Unik Yang Pernah Dicabut: {len(removed_users)}")

    # 2. Investigasi Mendalam Setiap User yang Pernah Dicabut
    print("\n" + "=" * 100)
    print("2. DETAIL KORBAN PENCABUTAN & STATUS BERLANGGANAN MEREKA:")
    print("=" * 100)

    # Preload all transactions
    all_txs_by_email = {}
    tx_stream = db.collection("transactions").stream()
    for doc in tx_stream:
        d = doc.to_dict()
        em = (d.get("customer_email") or d.get("payer_email") or d.get("email") or "").strip().lower()
        if not em:
            continue
        if em not in all_txs_by_email:
            all_txs_by_email[em] = []
        all_txs_by_email[em].append((doc.id, d))

    for em, evts in sorted(removed_users.items()):
        print(f"\n--------------------------------------------------------------------------------")
        print(f"👤 USER: {em}")
        print(f"--------------------------------------------------------------------------------")
        print(f"📌 Riwayat Pencabutan ({len(evts)}x):")
        for ev in evts:
            print(f"   • Waktu: {ev.get('created_at')} | Notebook: {ev.get('notebook_name')} | Source: {ev.get('source')}")

        # Cek Firestore Users
        u_doc = db.collection("users").document(em).get()
        if u_doc.exists:
            u_data = u_doc.to_dict()
            print(f"   📄 Firestore User Doc: Status={u_data.get('status')} | Role={u_data.get('role')} | SubExp={u_data.get('subscription_expiry')}")
            ents = u_data.get("entitlements", {})
            if ents:
                for k, v in ents.items():
                    print(f"      - Entitlement [{k}]: plan={v.get('plan')}, exp={v.get('expiry')}")
        else:
            print("   📄 Firestore User Doc: TIDAK ADA (Flat Transaction Only)")

        # Cek Transaksi
        txs = all_txs_by_email.get(em, [])
        print(f"   💳 Total Transaksi di Database: {len(txs)}")
        is_yearly_subscriber = False
        active_sub_found = False
        for tid, td in txs:
            st = str(td.get("status") or "").upper()
            pl = str(td.get("plan") or td.get("plan_id") or "").lower()
            amt = td.get("amount")
            exp = td.get("subscription_expires_at") or td.get("access_expires_at") or td.get("expires_at")
            ek = td.get("entitlement_key")
            
            is_1y = "1y" in pl or "year" in pl or "annual" in pl or "bahits_1y" in pl or (exp and "2027" in str(exp)) or (amt and float(amt) >= 900000.0)
            if is_1y and st in ["SUCCESS", "PAID", "SETTLED", "TRANSFERRED"]:
                is_yearly_subscriber = True
            
            print(f"      - TX [{tid}]: Status={st} | Plan={pl} | Amount={amt} | Exp={exp} | Key={ek}")

        if is_yearly_subscriber:
            print(f"   🚨 STATUS: KORBAN SALAH CABUT! USER ADALAH PELANGGAN 1 TAHUN AKTIF!")
        else:
            print(f"   ℹ️ STATUS: Pelanggan 1 Bulan / Kadaluwarsa Normal.")

    # 3. Audit Status NotebookLM Saat Ini
    print("\n" + "=" * 100)
    print("3. STATUS SAAT INI DI NOTEBOOKLM (APAKAH AKSES MASIH HILANG ATAU SUDAH AMAN):")
    print("=" * 100)
    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        for nb in MASTER_NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            try:
                st = await nlm.sharing.get_status(nb_id)
                users_map = {u.email.lower(): u.permission.name for u in st.shared_users}
                print(f"\n📘 {nb_name}: Total {len(users_map)} Shared Users")
                # Cek korban penting
                for victim in ["basithmuhammad612@gmail.com", "ndsfraaaaaaa@gmail.com", "riefbois33@gmail.com", "fikrilzabidi@gmail.com", "beyzabeem@gmail.com"]:
                    if victim in users_map:
                        print(f"   ✅ {victim}: AKTIF ({users_map[victim]})")
                    else:
                        print(f"   ❌ {victim}: TIDAK ADA / HILANG")
            except Exception as e:
                print(f"   ⚠️ Error cek {nb_name}: {e}")

if __name__ == "__main__":
    asyncio.run(run_audit())
