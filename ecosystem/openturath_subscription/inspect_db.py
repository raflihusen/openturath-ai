import os
import json
from datetime import datetime, timezone
from google.cloud import firestore

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path) if os.path.exists(cred_path) else firestore.Client()

print("=== COLLECTIONS IN FIRESTORE ===")
for col in db.collections():
    print(f"Collection: {col.id}")

print("\n=== SCANNING ALL TRANSACTIONS ===")
trxs = list(db.collection("transactions").stream())
print(f"Total transactions: {len(trxs)}")

for t in trxs:
    d = t.to_dict()
    # Print everything interesting
    email = d.get("email") or d.get("user_email") or d.get("customer_email")
    status = d.get("status")
    plan = d.get("plan_id") or d.get("package_id") or d.get("plan")
    expiry = d.get("subscription_expires_at") or d.get("expires_at")
    created = d.get("created_at") or d.get("createdAt")
    amount = d.get("amount") or d.get("gross_amount") or d.get("total")
    notes = {k: v for k, v in d.items() if k not in ["email", "status", "plan_id", "subscription_expires_at", "created_at", "amount"]}
    print(f"TRX: {t.id} | Email: {email} | Status: {status} | Plan: {plan} | Amount: {amount} | Created: {created} | Expiry: {expiry} | Other: {notes}")

print("\n=== SCANNING ALL USERS ===")
users = list(db.collection("users").stream())
print(f"Total users: {len(users)}")
for u in users:
    d = u.to_dict()
    email = d.get("email")
    role = d.get("role")
    entitlements = d.get("entitlements", {})
    # Look for any custom/special fields
    custom = {k: v for k, v in d.items() if k not in ["displayName", "photoURL", "created_at", "updated_at", "last_login", "fcm_token", "fcmToken"]}
    print(f"USER: {u.id} | Email: {email} | Role: {role} | CustomFields: {custom}")
