import os
import json
from datetime import datetime, timezone
from google.cloud import firestore

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

print("=================================================================")
print(f"ANALISIS LENGKAP SEMUA TRANSAKSI DI FIRESTORE (WAKTU SEKARANG: {now})")
print("=================================================================")

all_txs = list(db.collection("transactions").stream())
vip_txs = []
yearly_txs = []
active_txs = []
expired_txs = []
other_txs = []

user_permissions = {} # email -> list of grants

for t in all_txs:
    d = t.to_dict()
    email = (d.get("email") or d.get("customer_email") or d.get("user_email") or d.get("payer_email") or "").strip().lower()
    if not email:
        continue
    
    plan = str(d.get("plan_id") or d.get("package_id") or d.get("plan") or "")
    ent_key = d.get("entitlement_key")
    status = str(d.get("status") or "").upper()
    exp_dt = parse_dt(d.get("subscription_expires_at") or d.get("expires_at") or d.get("access_expires_at"))
    
    grant_info = {
        "tx_id": t.id,
        "plan": plan,
        "entitlement_key": ent_key,
        "status": status,
        "expires_at": exp_dt,
        "created_at": parse_dt(d.get("created_at"))
    }
    
    if email not in user_permissions:
        user_permissions[email] = []
    user_permissions[email].append(grant_info)

print(f"Total Unique Emails in Transactions: {len(user_permissions)}")

print("\n--- 1. DAFTAR USER DENGAN STATUS VIP / AKSES SPESIAL (2036) ---")
for email, grants in sorted(user_permissions.items()):
    vips = [g for g in grants if "VIP" in g["plan"] or (g["expires_at"] and g["expires_at"].year >= 2030)]
    if vips:
        for v in vips:
            print(f"⭐ VIP: {email} | Plan: {v['plan']} | Status: {v['status']} | Exp: {v['expires_at']}")

print("\n--- 2. DAFTAR USER DENGAN PAKET 1 TAHUN (1 YEAR / TAHUNAN) ---")
for email, grants in sorted(user_permissions.items()):
    yearlys = [g for g in grants if any(k in g["plan"].lower() for k in ["1y", "year", "tahun", "annual", "bahits_1y"])]
    if yearlys:
        for y in yearlys:
            print(f"📅 1 TAHUN: {email} | Plan: {y['plan']} | Status: {y['status']} | Exp: {y['expires_at']}")

print("\n--- 3. PERIKSA USERS COLLECTION UNTUK USER PROFILE / SPECIAL ACCESS ---")
all_users = list(db.collection("users").stream())
for u in all_users:
    d = u.to_dict()
    em = (d.get("email") or "").strip().lower()
    role = d.get("role")
    sub_exp = parse_dt(d.get("subscription_expiry"))
    entitlements = d.get("entitlements", {})
    
    # check if user has special roles or 2027/2030+ dates
    is_special = False
    reasons = []
    if role and role.lower() in ["admin", "vip", "teacher", "guru", "special"]:
        is_special = True
        reasons.append(f"role={role}")
    if sub_exp and sub_exp > now:
        reasons.append(f"sub_exp={sub_exp}")
    for k, v in entitlements.items():
        if isinstance(v, dict):
            k_exp = parse_dt(v.get("expiry") or v.get("expires_at"))
            if k_exp and k_exp > now:
                reasons.append(f"{k}_exp={k_exp}")
    if reasons:
        print(f"👤 USER DOC: {em} | {', '.join(reasons)}")
