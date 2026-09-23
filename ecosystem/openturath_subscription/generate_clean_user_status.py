import os
import sys
import asyncio
from datetime import datetime, timezone, timedelta
from google.cloud import firestore

# Load environment
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
    if isinstance(val, datetime):
        return val if val.tzinfo else val.replace(tzinfo=timezone.utc)
    if isinstance(val, str):
        try:
            dt = datetime.fromisoformat(val.replace("Z", "+00:00"))
            return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)
        except Exception:
            return None
    return None

def get_duration_months(plan_name):
    p = str(plan_name).lower()
    if "1y" in p or "year" in p or "annual" in p or "12m" in p:
        return 12
    if "6m" in p or "6_month" in p or "6-month" in p:
        return 6
    return 1

async def main():
    print(f"Audit Time: {now.strftime('%Y-%m-%d %H:%M:%S UTC')}")

    # 1. Fetch live viewers in all notebooks
    viewers_map = {} # email -> list of notebook names
    async with NotebookLMClient.from_storage(path=storage_path) as client:
        for nb in MASTER_NOTEBOOKS:
            try:
                st = await client.sharing.get_status(nb["id"])
                for u in st.shared_users:
                    if u.permission.name == "OWNER":
                        continue
                    em = u.email.strip().lower()
                    if em not in viewers_map:
                        viewers_map[em] = []
                    viewers_map[em].append(nb["name"])
            except Exception as e:
                print(f"Error fetching {nb['name']}: {e}")

    # 2. Fetch all users from Firestore
    firestore_users = {}
    for u in db.collection("users").stream():
        d = u.to_dict()
        em = (d.get("email") or "").strip().lower()
        if em:
            firestore_users[em] = d

    # 3. Fetch all transactions
    firestore_txs = {}
    for tx in db.collection("transactions").stream():
        d = tx.to_dict()
        em = (d.get("customer_email") or d.get("payer_email") or d.get("email") or "").strip().lower()
        if em:
            if em not in firestore_txs:
                firestore_txs[em] = []
            firestore_txs[em].append({"id": tx.id, "data": d})

    # 4. Fetch Akal
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
        print(f"Akal warning: {e}")

    # Group all unique emails across NotebookLM viewers + Firestore transactions + users
    all_emails = set(viewers_map.keys()) | set(firestore_txs.keys()) | set(firestore_users.keys())

    vip_group = {}      # email -> info
    active_group = {}   # email -> info
    expired_group = {}  # email -> info

    for email in sorted(all_emails):
        # A. Check Whitelist
        if email in STATIC_WHITELIST:
            vip_group[email] = {
                "name": "Owner / Whitelist",
                "plan": "SUPER_ADMIN",
                "exp": "Permanen",
                "notebooks": viewers_map.get(email, []),
                "source": "Static Whitelist"
            }
            continue

        # B. Check VIP / Guru / Manual Permanen
        is_vip = False
        vip_info = None

        # Check transactions for VIP
        if email in firestore_txs:
            for t in firestore_txs[email]:
                d = t["data"]
                plan = str(d.get("plan") or d.get("plan_id") or "")
                exp = parse_dt(d.get("subscription_expires_at") or d.get("expires_at"))
                if d.get("is_vip") or "VIP" in plan.upper() or (exp and exp.year >= 2030):
                    is_vip = True
                    vip_info = {
                        "name": d.get("customer_name") or d.get("payer_name") or "VIP / Ulama / Guru",
                        "plan": plan or "VIP_PERMANENT",
                        "exp": exp.strftime("%Y-%m-%d") if exp else "2036-08-19",
                        "notebooks": viewers_map.get(email, []),
                        "source": "Firestore VIP Record"
                    }
                    break

        if is_vip:
            vip_group[email] = vip_info
            continue

        # C. Check Active Subscription (1 Year, 6 Months, 1 Month, Akal, Entitlements)
        is_active = False
        active_info = None
        latest_exp = None
        active_plan = ""
        user_name = ""

        # Check Akal
        if email in akal_active:
            is_active = True
            active_info = {
                "name": "Akal Subscriber",
                "plan": ", ".join(akal_active[email]),
                "exp": "Aktif di GoAkal",
                "notebooks": viewers_map.get(email, []),
                "source": "Akal API Live"
            }

        # Check User Profile Entitlements
        u_doc = firestore_users.get(email)
        if u_doc:
            user_name = u_doc.get("displayName") or u_doc.get("name") or ""
            u_sub_exp = parse_dt(u_doc.get("subscription_expiry"))
            if u_sub_exp and u_sub_exp > now:
                is_active = True
                latest_exp = u_sub_exp
                active_plan = u_doc.get("plan") or "All Access"
            
            entitlements = u_doc.get("entitlements", {})
            for k, v in entitlements.items():
                if isinstance(v, dict):
                    e_dt = parse_dt(v.get("expiry") or v.get("expires_at"))
                    if e_dt and e_dt > now:
                        if not latest_exp or e_dt > latest_exp:
                            latest_exp = e_dt
                            active_plan = f"Modul {k} ({v.get('plan', 'Active')})"
                        is_active = True

        # Check Transactions
        if email in firestore_txs:
            for t in firestore_txs[email]:
                d = t["data"]
                st = str(d.get("status") or "").upper()
                if st in ["SUCCESS", "PAID", "SETTLED"]:
                    nm = d.get("customer_name") or d.get("payer_name") or ""
                    if nm and not user_name:
                        user_name = nm
                    pl = d.get("plan") or d.get("plan_id") or d.get("price_scheme_title") or "tholib_1m"
                    
                    t_exp = parse_dt(d.get("subscription_expires_at") or d.get("expires_at"))
                    if not t_exp:
                        paid_at = parse_dt(d.get("created_at") or d.get("paid_at"))
                        if paid_at:
                            dur = get_duration_months(pl)
                            ey = paid_at.year + ((paid_at.month + dur - 1) // 12)
                            em_m = (paid_at.month + dur - 1) % 12 + 1
                            try:
                                t_exp = paid_at.replace(year=ey, month=em_m)
                            except ValueError:
                                t_exp = paid_at.replace(year=ey, month=em_m, day=28)
                    
                    if t_exp and t_exp > now:
                        is_active = True
                        if not latest_exp or t_exp > latest_exp:
                            latest_exp = t_exp
                            active_plan = pl

        if is_active:
            active_group[email] = {
                "name": user_name or "Subscriber",
                "plan": active_plan or "Active Subscription",
                "exp": latest_exp.strftime("%Y-%m-%d") if latest_exp else (active_info["exp"] if active_info else "Aktif"),
                "notebooks": viewers_map.get(email, []),
                "source": "Firestore Active / User Entitlement"
            }
            continue

        # D. Expired Group
        # Find latest expired date from transactions or entitlements
        exp_dt = None
        exp_plan = ""
        u_name = user_name

        if email in firestore_txs:
            for t in firestore_txs[email]:
                d = t["data"]
                t_exp = parse_dt(d.get("subscription_expires_at") or d.get("expires_at"))
                pl = d.get("plan") or d.get("plan_id") or "tholib_1m"
                nm = d.get("customer_name") or d.get("payer_name") or ""
                if nm and not u_name:
                    u_name = nm
                if t_exp and (not exp_dt or t_exp > exp_dt):
                    exp_dt = t_exp
                    exp_plan = pl

        if u_doc:
            u_sub_exp = parse_dt(u_doc.get("subscription_expiry"))
            if u_sub_exp and (not exp_dt or u_sub_exp > exp_dt):
                exp_dt = u_sub_exp
                exp_plan = u_doc.get("plan") or "Subscription"

        expired_group[email] = {
            "name": u_name or "Pengguna",
            "plan": exp_plan or "Tidak tercatat",
            "exp": exp_dt.strftime("%Y-%m-%d") if exp_dt else "Tanggal tidak ditemukan",
            "notebooks": viewers_map.get(email, []),
            "in_notebooklm": len(viewers_map.get(email, [])) > 0
        }

    # Output JSON and formatted text
    print("\n" + "=" * 90)
    print("1. DAFTAR PENGGUNA VIP / AKSES SPESIAL PERMANEN (TOTAL: %d)" % len(vip_group))
    print("=" * 90)
    for i, (em, info) in enumerate(sorted(vip_group.items()), 1):
        nbs = ", ".join(info["notebooks"]) if info["notebooks"] else "Belum di-invite ke notebook"
        print(f"{i:2d}. {info['name']:<25} | {em:<35} | Exp: {info['exp']} | Notebooks: {nbs}")

    print("\n" + "=" * 90)
    print("2. DAFTAR PENGGUNA MASIH AKTIF (TOTAL: %d)" % len(active_group))
    print("=" * 90)
    for i, (em, info) in enumerate(sorted(active_group.items(), key=lambda x: x[1]['exp']), 1):
        nbs = ", ".join(info["notebooks"]) if info["notebooks"] else "Belum di-invite ke notebook"
        print(f"{i:2d}. {info['name']:<25} | {em:<35} | Paket: {info['plan']:<18} | Exp: {info['exp']} | NB: {nbs}")

    print("\n" + "=" * 90)
    print("3. DAFTAR PENGGUNA SUDAH KADALUARSA / EXPIRED (TOTAL: %d)" % len(expired_group))
    print("=" * 90)
    # Split into: Still in NotebookLM vs Not in NotebookLM
    in_nb_expired = {k: v for k, v in expired_group.items() if v["in_notebooklm"]}
    not_in_nb_expired = {k: v for k, v in expired_group.items() if not v["in_notebooklm"]}

    print(f"\n🚨 A. KADALUARSA TAPI MASIH ADA DI NOTEBOOKLM (HARUS DICABUT): {len(in_nb_expired)} Orang")
    print("-" * 90)
    for i, (em, info) in enumerate(sorted(in_nb_expired.items()), 1):
        nbs = ", ".join(info["notebooks"])
        print(f"{i:2d}. {info['name']:<25} | {em:<35} | Paket: {info['plan']:<15} | Habis: {info['exp']} | di: {nbs}")

    print(f"\n⚪ B. KADALUARSA LAMA & SUDAH TIDAK DI NOTEBOOKLM (AMAN/SUDAH DICABUT SEBELUMNYA): {len(not_in_nb_expired)} Orang")
    print("-" * 90)
    for i, (em, info) in enumerate(sorted(not_in_nb_expired.items()), 1):
        print(f"{i:2d}. {info['name']:<25} | {em:<35} | Paket: {info['plan']:<15} | Habis: {info['exp']}")

if __name__ == "__main__":
    asyncio.run(main())
