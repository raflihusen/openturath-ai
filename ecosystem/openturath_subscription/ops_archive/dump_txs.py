import os
import json
from google.cloud import firestore

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path) if os.path.exists(cred_path) else firestore.Client()

print("=== ALL TRANSACTIONS DUMP ===")
txs = list(db.collection("transactions").stream())
print(f"Total transactions: {len(txs)}")

for tx in txs:
    d = tx.to_dict()
    email = d.get('email') or d.get('customer_email') or d.get('user_email') or d.get('payer_email')
    plan = d.get('plan_id') or d.get('package_id') or d.get('plan') or d.get('item_name')
    entitlement = d.get('entitlement_key') or d.get('module')
    status = d.get('status')
    amount = d.get('amount') or d.get('gross_amount')
    created = d.get('created_at')
    expires = d.get('subscription_expires_at') or d.get('expires_at') or d.get('access_expires_at')
    print(f"TX {tx.id}: {email} | status: {status} | plan: {plan} | entitlement: {entitlement} | amount: {amount} | created: {created} | expires: {expires}")
