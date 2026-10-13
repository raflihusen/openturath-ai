import os
import sys
import json
from google.cloud import firestore

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path) if os.path.exists(cred_path) else firestore.Client()

print("ALL FIRESTORE COLLECTIONS:")
cols = [c.id for c in db.collections()]
print(cols)

for c_name in cols:
    count = len(list(db.collection(c_name).limit(100).stream()))
    print(f"Collection '{c_name}': at least {count} docs")
