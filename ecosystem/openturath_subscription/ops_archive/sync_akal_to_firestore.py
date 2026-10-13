import os
import sys
import asyncio
import datetime
from google.cloud import firestore

# Add notebooklm-py to path
NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

# Load .env file manually
def load_dotenv():
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, val = line.split("=", 1)
                    if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                        val = val[1:-1]
                    os.environ[key] = val

load_dotenv()

from akal_client import AkalClient

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/Users/apple/.config/gcloud/application_default_credentials.json"

def determine_plan_and_expiry(price_scheme_name: str, service_name: str) -> tuple[str, int]:
    plan = "tholib_1m"
    duration_months = 1
    price_scheme_lower = price_scheme_name.lower()
    service_name_lower = service_name.lower()
    
    if "tahun" in price_scheme_lower or "1y" in price_scheme_lower or "year" in price_scheme_lower or "annual" in price_scheme_lower:
        plan = "bahits_1y"
        duration_months = 12
    elif "6 bulan" in price_scheme_lower or "6m" in price_scheme_lower:
        plan = "tholib_6m"
        duration_months = 6
    elif "bulan" in price_scheme_lower or "1m" in price_scheme_lower or "month" in price_scheme_lower:
        plan = "tholib_1m"
        duration_months = 1
    else:
        if "bahits" in price_scheme_lower or "bahits" in service_name_lower:
            plan = "bahits_1y"
            duration_months = 12
        else:
            plan = "tholib_1m"
            duration_months = 1
            
    return plan, duration_months

async def main():
    db = firestore.Client(project="open-turath")
    service_cuid = os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p")
    
    print(f"Connecting to Akal API... Service CUID: {service_cuid}")
    
    async with AkalClient() as akal:
        # Get PAID and SETTLED transactions
        print("Fetching transactions from Akal...")
        paid_txns = await akal.get_transactions(service_cuid, status="PAID")
        settled_txns = await akal.get_transactions(service_cuid, status="SETTLED")
        all_txns = paid_txns + settled_txns
        
        print(f"Found {len(all_txns)} paid/settled transactions on Akal.")
        
        for txn in all_txns:
            email = txn.get("payerEmail", "").strip().lower()
            name = txn.get("payerName", "").strip()
            price_scheme = txn.get("priceSchemeTitle", "")
            service_title = txn.get("serviceTitle", "AI Fikih Tahawwulat")
            transaction_id = txn.get("id", "")
            amount = float(txn.get("amount", 0))
            
            if not email:
                continue
                
            plan, duration_months = determine_plan_and_expiry(price_scheme, service_title)
            
            # Hitung masa aktif sebenarnya (tanggal bayar/dibuat + durasi paket)
            base_date_str = txn.get("paidAt") or txn.get("createdAt")
            if base_date_str:
                try:
                    base_date = datetime.datetime.fromisoformat(base_date_str.replace("Z", "+00:00"))
                except Exception:
                    base_date = datetime.datetime.now(datetime.timezone.utc)
            else:
                base_date = datetime.datetime.now(datetime.timezone.utc)
                
            expiry_date = base_date + datetime.timedelta(days=30 * duration_months)
                
            now = datetime.datetime.now(datetime.timezone.utc)
            
            print(f"Processing: {email} | Plan: {plan} | Expires: {expiry_date}")
            
            # 1. Update/Write transaction record
            tx_id = transaction_id or txn.get("cuid") or f"akal_{email.replace('@', '_').replace('.', '_')}_{plan}"
            trx_ref = db.collection("transactions").document(tx_id)
            trx_ref.set({
                "customer_email": email,
                "customer_name": name,
                "plan": plan,
                "amount": amount,
                "duration_months": duration_months,
                "status": "success",
                "source": "akal",
                "created_at": now,
                "completed_at": now,
                "subscription_expires_at": expiry_date
            })
            
            # 2. Update user if user already exists
            users_ref = db.collection("users")
            query = users_ref.where("email", "==", email).limit(1).stream()
            user_doc = None
            for doc in query:
                user_doc = doc
                break
                
            if user_doc:
                user_doc.reference.update({
                    "plan": plan,
                    "subscription_expiry": expiry_date,
                    "questions_used": 0
                })
                print(f"  -> Updated user UID: {user_doc.id}")
            else:
                print(f"  -> User {email} not found in Firestore yet (will sync upon signup)")

if __name__ == "__main__":
    asyncio.run(main())
