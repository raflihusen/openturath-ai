import json
from datetime import datetime, timezone
from google.cloud import firestore

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path)

revoked = [
    "alghazalirozi2@gmail.com",
    "basithmuhammad612@gmail.com",
    "fauzannurgisekolah@gmail.com",
    "lamikfarza@gmail.com",
    "ndsfraaaaaaa@gmail.com",
    "paisalkaff@gmail.com",
    "rafiaqsal17@gmail.com"
]

print("=== CHECKING 7 REVOKED USERS ===")
for email in revoked:
    print(f"\n==========================================")
    print(f"USER: {email}")
    print(f"==========================================")
    u_doc = db.collection("users").document(email).get()
    if u_doc.exists:
        u_data = u_doc.to_dict()
        print("User Doc Role:", u_data.get("role"))
        print("User Doc Status:", u_data.get("status"))
        print("User Doc Subscription Expiry:", u_data.get("subscription_expiry"))
        print("User Doc Entitlements:", json.dumps(u_data.get("entitlements", {}), indent=2, default=str))
    else:
        print("User Doc: NOT FOUND")

    # Search in all transactions
    tx_stream = db.collection("transactions").stream()
    user_txs = []
    for tx in tx_stream:
        d = tx.to_dict()
        em = (d.get("customer_email") or d.get("payer_email") or d.get("email") or "").strip().lower()
        if em == email:
            user_txs.append((tx.id, d))

    print(f"Total Transactions Found: {len(user_txs)}")
    for tx_id, d in user_txs:
        st = d.get("status")
        plan = d.get("plan") or d.get("plan_id")
        exp = d.get("subscription_expires_at") or d.get("access_expires_at") or d.get("expires_at")
        amt = d.get("amount")
        ek = d.get("entitlement_key")
        print(f" - TX [{tx_id}]: status={st}, plan={plan}, key={ek}, exp={exp}, amount={amt}")
