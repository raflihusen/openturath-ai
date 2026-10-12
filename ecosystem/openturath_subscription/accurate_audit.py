import os
import sys
import asyncio
from datetime import datetime, timezone
from google.cloud import firestore

# Load .env
env_file = os.path.join(os.path.dirname(__file__), ".env")
if os.path.exists(env_file):
    with open(env_file) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
                    v = v[1:-1]
                os.environ[k] = v

NOTEBOOKLM_PY_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "notebooklm-py", "src"))
sys.path.insert(0, NOTEBOOKLM_PY_PATH)

from notebooklm import NotebookLMClient
from akal_client import AkalClient

MASTER_NOTEBOOKS = [
    {"name": "AI Fikih Syafi'i", "id": "334e7b83-0e76-4787-a1d6-314642a35862", "key": "fiqh_syafii"},
    {"name": "Al-Muhaqqiq (Tahawwulat)", "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4", "key": "fiqh_tahawwulat"},
    {"name": "Al-Bayan (Fikih Tahawwulat)", "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd", "key": "fiqh_tahawwulat"},
    {"name": "Al-Mukhtabir (Fikih Tahawwulat)", "id": "ac61a7a0-87e7-42a5-a30f-980ff74a78d8", "key": "fiqh_tahawwulat"},
    {"name": "Al-Habib (Fikih Tahawwulat)", "id": "6673e79a-7156-42e1-b116-bc1653a32094", "key": "fiqh_tahawwulat"},
    {"name": "Al-Khatib (Fikih Tahawwulat)", "id": "1288e413-9569-47a3-892f-64008e53c1e8", "key": "fiqh_tahawwulat"},
    {"name": "AI Bahasa Arab", "id": "15bc4cef-4b94-4241-b05a-d50a586bde06", "key": "nahwu"},
    {"name": "AI Hadits", "id": "b9626501-538c-4358-a44f-6731eaec50b6", "key": "hadits"},
    {"name": "AI Tafsir", "id": "df92cc50-1106-4221-8748-1663f00fa7fe", "key": "tafsir"},
    {"name": "AI Ushul Fiqih", "id": "6ab6dae8-0067-435a-85ca-b6bd4e17dd12", "key": "ushul_fiqh"},
]

STATIC_WHITELIST = {"openturath@gmail.com", "ramah@ptct.net", "raflimaulan@gmail.com"}

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path) if os.path.exists(cred_path) else firestore.Client()
storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
now = datetime.now(timezone.utc)

def parse_dt(val):
    if not val:
        return None
    if hasattr(val, "toDate"):
        dt = val.toDate()
    elif isinstance(val, datetime):
        dt = val
    elif isinstance(val, str):
        try:
            dt = datetime.fromisoformat(val.replace("Z", "+00:00"))
        except Exception:
            return None
    else:
        return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt

async def accurate_audit():
    # 1. Fetch Akal
    akal_active = {}
    try:
        async with AkalClient() as akal:
            services_resp = await akal.list_services()
            for s in services_resp.get("data", []):
                cuid = s.get("cuid")
                s_name = s.get("title") or s.get("name") or cuid
                emails = await akal.get_all_paid_emails(cuid)
                for e in emails:
                    em = e.strip().lower()
                    if em not in akal_active:
                        akal_active[em] = []
                    akal_active[em].append(s_name)
    except Exception as e:
        print("Akal API warning:", e)

    # 2. Fetch Firestore Users
    firestore_users = {}
    for u in db.collection("users").stream():
        d = u.to_dict()
        em = (d.get("email") or "").strip().lower()
        if em:
            firestore_users[em] = d

    # 3. Fetch Firestore Transactions
    firestore_txs = {}
    for tx in db.collection("transactions").stream():
        d = tx.to_dict()
        em = (d.get("customer_email") or d.get("payer_email") or d.get("email") or "").strip().lower()
        if em:
            if em not in firestore_txs:
                firestore_txs[em] = []
            firestore_txs[em].append(d)

    # 4. Check Viewers across Notebooks
    results = [] # list of {email, notebook, status, category, reason}

    async with NotebookLMClient.from_storage(path=storage_path) as client:
        for nb in MASTER_NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            nb_key = nb["key"]
            try:
                status = await client.sharing.get_status(nb_id)
            except Exception as e:
                print(f"Error fetching status for {nb_name}: {e}")
                continue

            viewers = [u.email.lower() for u in status.shared_users if u.permission.name != "OWNER"]

            for v in viewers:
                if v in STATIC_WHITELIST:
                    results.append({"email": v, "notebook": nb_name, "status": "ACTIVE", "category": "WHITELIST", "detail": "Admin/Owner Whitelist"})
                    continue

                # Check Akal
                if v in akal_active:
                    results.append({"email": v, "notebook": nb_name, "status": "ACTIVE", "category": "AKAL", "detail": f"Akal active: {akal_active[v]}"})
                    continue

                # Check Firestore Transactions
                is_active = False
                active_reason = ""
                expired_reasons = []

                if v in firestore_txs:
                    for tx in firestore_txs[v]:
                        st = (tx.get("status") or "").upper()
                        plan = (tx.get("plan_id") or tx.get("package_id") or tx.get("plan") or "").upper()
                        t_key = tx.get("entitlement_key")
                        t_exp = parse_dt(tx.get("subscription_expires_at") or tx.get("access_expires_at") or tx.get("expires_at"))

                        # Is it VIP?
                        if "VIP" in plan or (t_exp and t_exp.year >= 2030):
                            if st in ["SUCCESS", "PAID", "SETTLED", "ACTIVE", ""]:
                                is_active = True
                                active_reason = f"Akses Spesial VIP Permanent (Exp: {t_exp})"
                                break

                        # Is it 1-Year plan? (bahits_1y gives all notebooks or specialist)
                        if any(k in plan.lower() for k in ["1y", "year", "tahun", "annual", "bahits_1y"]):
                            if st in ["SUCCESS", "PAID", "SETTLED"]:
                                if t_exp and t_exp > now:
                                    is_active = True
                                    active_reason = f"Langganan 1 Tahun ({plan}) Aktif s/d {t_exp.strftime('%Y-%m-%d')}"
                                    break

                        # Regular transaction check
                        if st in ["SUCCESS", "PAID", "SETTLED"]:
                            # Match module or all_access or None
                            if t_key in [nb_key, "all_access", "all_ai", None]:
                                if t_exp and t_exp > now:
                                    is_active = True
                                    active_reason = f"Transaksi Aktif ({plan or t_key}) s/d {t_exp.strftime('%Y-%m-%d')}"
                                    break
                                elif t_exp and t_exp <= now:
                                    expired_reasons.append(f"Tx Expired ({plan or t_key}) on {t_exp.strftime('%Y-%m-%d')}")

                if is_active:
                    results.append({"email": v, "notebook": nb_name, "status": "ACTIVE", "category": "TRANSACTION_ACTIVE", "detail": active_reason})
                    continue

                # Check Firestore User Document
                u_data = firestore_users.get(v)
                if u_data:
                    u_role = u_data.get("role")
                    if u_role and str(u_role).lower() in ["admin", "vip", "guru", "special"]:
                        results.append({"email": v, "notebook": nb_name, "status": "ACTIVE", "category": "USER_ROLE_SPECIAL", "detail": f"User Role: {u_role}"})
                        continue

                    # Check overall subscription_expiry
                    u_sub_exp = parse_dt(u_data.get("subscription_expiry"))
                    if u_sub_exp and u_sub_exp > now:
                        results.append({"email": v, "notebook": nb_name, "status": "ACTIVE", "category": "USER_SUB_ACTIVE", "detail": f"Subscription Expiry s/d {u_sub_exp.strftime('%Y-%m-%d')}"})
                        continue

                    # Check specific entitlement
                    entitlements = u_data.get("entitlements", {})
                    all_acc = entitlements.get("all_access") or {}
                    all_exp = parse_dt(all_acc.get("expiry") or all_acc.get("expires_at"))
                    if all_exp and all_exp > now:
                        results.append({"email": v, "notebook": nb_name, "status": "ACTIVE", "category": "ENTITLEMENT_ALL_ACTIVE", "detail": f"All Access s/d {all_exp.strftime('%Y-%m-%d')}"})
                        continue

                    mod_ent = entitlements.get(nb_key) or {}
                    mod_exp = parse_dt(mod_ent.get("expiry") or mod_ent.get("expires_at"))
                    if mod_exp and mod_exp > now:
                        results.append({"email": v, "notebook": nb_name, "status": "ACTIVE", "category": "ENTITLEMENT_MODULE_ACTIVE", "detail": f"Modul {nb_key} s/d {mod_exp.strftime('%Y-%m-%d')}"})
                        continue
                    elif mod_exp and mod_exp <= now:
                        expired_reasons.append(f"Entitlement {nb_key} Expired on {mod_exp.strftime('%Y-%m-%d')}")

                # If reached here, they are truly either EXPIRED or NO RECORD
                if expired_reasons:
                    results.append({"email": v, "notebook": nb_name, "status": "EXPIRED", "category": "EXPIRED", "detail": "; ".join(expired_reasons)})
                else:
                    results.append({"email": v, "notebook": nb_name, "status": "NO_RECORD", "category": "NO_RECORD", "detail": "Tidak ditemukan transaksi/entitlement valid"})

    print("\n=================================================================")
    print(f"📊 REKAPITULASI AUDIT PRESISI SEMUA VIEWER NOTEBOOKLM")
    print(f"=================================================================")
    
    active_list = [r for r in results if r["status"] == "ACTIVE"]
    expired_list = [r for r in results if r["status"] == "EXPIRED"]
    no_record_list = [r for r in results if r["status"] == "NO_RECORD"]

    print(f"Total Viewer Instances: {len(results)}")
    print(f"✅ AKTIF (Sah/VIP/1 Tahun/Sub Aktif): {len(active_list)}")
    print(f"🚨 BENAR-BENAR EXPIRED             : {len(expired_list)}")
    print(f"❓ TANPA CATATAN SAMA SEKALI       : {len(no_record_list)}")

    print("\n--- DETAIL USER AKTIF (SAMPEL/RINGKASAN) ---")
    active_by_cat = {}
    for r in active_list:
        c = r["category"]
        active_by_cat[c] = active_by_cat.get(c, 0) + 1
    for c, cnt in active_by_cat.items():
        print(f"  • {c}: {cnt} instances")

    print("\n🚨 --- DAFTAR VIEWER YANG BENAR-BENAR EXPIRED ---")
    for r in expired_list:
        print(f"❌ {r['email']} | Modul: {r['notebook']} | {r['detail']}")

    print("\n❓ --- DAFTAR VIEWER TANPA CATATAN TRANSAKSI SAMA SEKALI ---")
    grouped_no_rec = {}
    for r in no_record_list:
        em = r["email"]
        if em not in grouped_no_rec:
            grouped_no_rec[em] = []
        grouped_no_rec[em].append(r["notebook"])
    for em, nbs in grouped_no_rec.items():
        print(f"❓ {em} | di {len(nbs)} notebook: {', '.join(nbs)}")

if __name__ == "__main__":
    asyncio.run(accurate_audit())
