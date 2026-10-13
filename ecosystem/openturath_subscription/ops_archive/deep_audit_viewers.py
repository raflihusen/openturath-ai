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

storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path) if os.path.exists(cred_path) else firestore.Client()
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

async def check():
    # 1. Fetch Akal paid members
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
        print("Akal API Error:", e)

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

    # 4. Check Viewers in each notebook
    all_expired_viewers = []
    all_untracked_viewers = []
    all_active_viewers = []

    async with NotebookLMClient.from_storage(path=storage_path) as client:
        for nb in MASTER_NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            nb_key = nb["key"]
            try:
                status = await client.sharing.get_status(nb_id)
            except Exception as e:
                print(f"Error getting status for {nb_name}: {e}")
                continue

            viewers = [u.email.lower() for u in status.shared_users if u.permission.name != "OWNER"]
            
            for v in viewers:
                if v in STATIC_WHITELIST:
                    continue
                
                is_active = False
                reason = ""
                latest_exp = None

                # Check Akal
                if v in akal_active:
                    is_active = True
                    reason = f"Active in Akal: {akal_active[v]}"

                # Check Firestore User Entitlements
                u_data = firestore_users.get(v)
                if u_data:
                    entitlements = u_data.get("entitlements", {})
                    # Check all_access
                    all_acc = entitlements.get("all_access") or {}
                    all_exp_dt = parse_dt(all_acc.get("expiry"))
                    if all_exp_dt and all_exp_dt > now:
                        is_active = True
                        reason = f"Active all_access until {all_exp_dt}"

                    # Check specific module key
                    mod_ent = entitlements.get(nb_key) or {}
                    mod_exp_dt = parse_dt(mod_ent.get("expiry"))
                    if mod_exp_dt:
                        latest_exp = mod_exp_dt
                        if mod_exp_dt > now:
                            is_active = True
                            reason = f"Active {nb_key} until {mod_exp_dt}"
                        elif not is_active:
                            reason = f"Expired {nb_key} on {mod_exp_dt}"

                # Check Transactions if not active
                if not is_active and v in firestore_txs:
                    for tx in firestore_txs[v]:
                        st = (tx.get("status") or "").upper()
                        t_key = tx.get("entitlement_key")
                        t_exp_dt = parse_dt(tx.get("subscription_expires_at") or tx.get("access_expires_at") or tx.get("expires_at"))
                        if t_exp_dt:
                            if st in ["SUCCESS", "PAID", "SETTLED"]:
                                if (t_key == nb_key or t_key in ["all_access", "all_ai"]) and t_exp_dt > now:
                                    is_active = True
                                    reason = f"Active Tx ({t_key}) until {t_exp_dt}"
                                    break
                                elif t_exp_dt <= now:
                                    if not latest_exp or t_exp_dt > latest_exp:
                                        latest_exp = t_exp_dt
                                    if not reason:
                                        reason = f"Expired Tx on {t_exp_dt}"

                if is_active:
                    all_active_viewers.append({"email": v, "notebook": nb_name, "reason": reason})
                else:
                    if reason:
                        all_expired_viewers.append({"email": v, "notebook": nb_name, "key": nb_key, "reason": reason, "exp": latest_exp})
                    else:
                        all_untracked_viewers.append({"email": v, "notebook": nb_name, "key": nb_key})

    print(f"\n=================================================================")
    print(f"📊 REKAPITULASI STATUS VIEWER GOOGLE NOTEBOOKLM (Waktu: {now.strftime('%Y-%m-%d %H:%M:%S UTC')})")
    print(f"=================================================================")
    print(f"✅ Viewer Aktif & Sah           : {len(all_active_viewers)}")
    print(f"🚨 Viewer TERBUKTI EXPIRED      : {len(all_expired_viewers)}")
    print(f"❓ Viewer Tanpa Data (Untracked) : {len(all_untracked_viewers)}")
    print(f"=================================================================\n")

    print(f"🚨 [DAFTAR 1: VIEWER DENGAN MASA AKTIF SUDAH HABIS / EXPIRED]")
    for x in all_expired_viewers:
        print(f"• 👤 {x['email']} | Modul: {x['notebook']} | Alasan: {x['reason']}")

    print(f"\n❓ [DAFTAR 2: VIEWER DI GOOGLE NOTEBOOKLM TANPA RIWAYAT BAYAR / TRIAL KADALUARSA]")
    # Group untracked by email
    grouped_untracked = {}
    for x in all_untracked_viewers:
        em = x["email"]
        if em not in grouped_untracked:
            grouped_untracked[em] = []
        grouped_untracked[em].append(x["notebook"])
    for em, nbs in grouped_untracked.items():
        print(f"• 👤 {em} | Terdaftar di {len(nbs)} notebook: {', '.join(nbs)}")

if __name__ == "__main__":
    asyncio.run(check())
