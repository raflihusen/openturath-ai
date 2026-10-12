import os
import json
from google.cloud import firestore

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path) if os.path.exists(cred_path) else firestore.Client()

print("=== APP_CONFIG ===")
for doc in db.collection("app_config").stream():
    print(f"[{doc.id}] -> {doc.to_dict()}")

print("\n=== REDEEM_CODES ===")
for doc in db.collection("redeem_codes").stream():
    print(f"[{doc.id}] -> {doc.to_dict()}")

print("\n=== SHARING_LOG ===")
for doc in db.collection("sharing_log").order_by("created_at", direction=firestore.Query.DESCENDING).limit(30).stream():
    d = doc.to_dict()
    print(f"[{doc.id}] -> {d.get('email')} | action: {d.get('action')} | nb: {d.get('notebook_id')} | res: {d.get('status')} | {d.get('created_at')}")

print("\n=== SHARING_QUEUE ===")
for doc in db.collection("sharing_queue").stream():
    print(f"[{doc.id}] -> {doc.to_dict()}")
