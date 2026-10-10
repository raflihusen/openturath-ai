import os
import json
import asyncio
from datetime import datetime, timezone
from google.cloud import firestore

NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
import sys
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

import socket
_orig_getaddrinfo = socket.getaddrinfo
def _resilient_getaddrinfo(host, port, *args, **kwargs):
    h_str = host.decode("utf-8", "ignore") if isinstance(host, (bytes, bytearray)) else str(host)
    if h_str == "notebooklm.google.com":
        return _orig_getaddrinfo("142.250.74.78", port, *args, **kwargs)
    return _orig_getaddrinfo(host, port, *args, **kwargs)
socket.getaddrinfo = _resilient_getaddrinfo

from akal_client import AkalClient
from notebooklm import NotebookLMClient
from notebooklm.rpc.types import SharePermission

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path)

MASTER_NOTEBOOKS = [
    {
        "name": "01 - FIKIH SYAFII (MASTER)",
        "id": "c89d09ca-4b48-4000-a98d-59e532607fb6",
        "key": "fiqh_syafii"
    },
    {
        "name": "AI Fikih Syafi'i (Legacy)",
        "id": "334e7b83-0e76-4787-a1d6-314642a35862",
        "key": "fiqh_syafii"
    },
    {
        "name": "Al-Muhaqqiq (Tahawwulat)",
        "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "Al-Bayan (Fikih Tahawwulat)",
        "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "Al-Mukhtabir (Fikih Tahawwulat)",
        "id": "ac61a7a0-87e7-42a5-a30f-980ff74a78d8",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "Al-Habib (Fikih Tahawwulat)",
        "id": "6673e79a-7156-42e1-b116-bc1653a32094",
        "key": "fiqh_tahawwulat"
    }
]

async def check_all():
    now = datetime.now(timezone.utc)
    print("=" * 80)
    print(f"AUDIT SEMUA USER 1 TAHUN & KELAYAKAN AKSES: {now.isoformat()}")
    print("=" * 80)

    # 1. Cari semua transaksi yang merupakan langganan 1 tahun (bahits_1y, yearly, 1y, annual, tahun)
    #    atau memiliki exp > 2027
    yearly_users = {} # email -> {details}
    
    tx_stream = db.collection("transactions").stream()
    for doc in tx_stream:
        d = doc.to_dict()
        email = (d.get("customer_email") or d.get("payer_email") or d.get("email") or "").strip().lower()
        if not email:
            continue
        
        plan = str(d.get("plan") or d.get("plan_id") or "").lower()
        status = str(d.get("status") or "").upper()
        amount = float(d.get("amount") or 0.0)
        exp_raw = d.get("subscription_expires_at") or d.get("access_expires_at") or d.get("expires_at")
        
        is_1y = (
            "1y" in plan or "year" in plan or "tahun" in plan or "annual" in plan or "bahits" in plan or
            amount >= 1000000.0 or
            "AKL-" in doc.id or
            (exp_raw and ("2027" in str(exp_raw) or "2028" in str(exp_raw)))
        )
        
        if is_1y:
            if email not in yearly_users:
                yearly_users[email] = []
            yearly_users[email].append({
                "tx_id": doc.id,
                "plan": plan,
                "status": status,
                "amount": amount,
                "expires_at": str(exp_raw),
                "entitlement_key": d.get("entitlement_key")
            })

    # Also check users collection
    user_stream = db.collection("users").stream()
    for doc in user_stream:
        d = doc.to_dict()
        email = (d.get("email") or doc.id or "").strip().lower()
        entitlements = d.get("entitlements", {})
        sub_exp = d.get("subscription_expiry")
        role = d.get("role")
        
        # Check if user has 1y entitlement
        has_1y_ent = False
        if isinstance(entitlements, dict):
            for mod, ent in entitlements.items():
                if isinstance(ent, dict):
                    e_plan = str(ent.get("plan") or "").lower()
                    e_exp = str(ent.get("expiry") or "")
                    if "1y" in e_plan or "bahits" in e_plan or "2027" in e_exp:
                        has_1y_ent = True
        
        if has_1y_ent or (sub_exp and "2027" in str(sub_exp)):
            if email not in yearly_users:
                yearly_users[email] = []
            yearly_users[email].append({
                "source": "users_collection",
                "role": role,
                "subscription_expiry": sub_exp,
                "entitlements": entitlements
            })

    print(f"Total User Terdeteksi Memiliki Jejak 1 Tahun: {len(yearly_users)}")
    for em, records in sorted(yearly_users.items()):
        print(f"\n>> {em}:")
        for r in records:
            print("   ", r)

    # 2. Periksa status akses aktual di NotebookLM untuk master notebooks
    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    print("\n" + "=" * 80)
    print("STATUS AKSES RIIL DI NOTEBOOKLM:")
    print("=" * 80)
    
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        for nb in MASTER_NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            status = await nlm.sharing.get_status(nb_id)
            shared_emails = {u.email.lower(): u.permission.name for u in status.shared_users}
            print(f"\n📘 Notebook: {nb_name} ({nb_id})")
            print(f"   Total Shared Users: {len(shared_emails)}")
            
            # Cek siapa dari yearly_users yang ada atau HILANG
            missing_yearly = []
            present_yearly = []
            for y_em in sorted(yearly_users.keys()):
                if y_em in shared_emails:
                    present_yearly.append(f"{y_em} ({shared_emails[y_em]})")
                else:
                    missing_yearly.append(y_em)
            
            print(f"   ✅ Hadir ({len(present_yearly)}): {present_yearly}")
            print(f"   ❌ HILANG / TIDAK ADA ({len(missing_yearly)}): {missing_yearly}")

if __name__ == "__main__":
    asyncio.run(check_all())
