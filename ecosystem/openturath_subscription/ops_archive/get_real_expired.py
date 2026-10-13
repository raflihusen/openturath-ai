import asyncio
import datetime
from google.cloud import firestore

def get_duration_months(plan_name):
    p = str(plan_name).lower()
    if "1y" in p or "year" in p or "annual" in p or "12m" in p:
        return 12
    if "6m" in p or "6_month" in p or "6-month" in p:
        return 6
    return 1

def parse_dt(val):
    if not val:
        return None
    if isinstance(val, datetime.datetime):
        return val if val.tzinfo else val.replace(tzinfo=datetime.timezone.utc)
    if isinstance(val, str):
        try:
            dt = datetime.datetime.fromisoformat(val.replace("Z", "+00:00"))
            return dt if dt.tzinfo else dt.replace(tzinfo=datetime.timezone.utc)
        except Exception:
            return None
    return None

async def main():
    db = firestore.Client.from_service_account_json("/Users/apple/Downloads/ramadhan/service-account.json")
    now = datetime.datetime.now(datetime.timezone.utc)
    query = db.collection("transactions").where(filter=firestore.FieldFilter("status", "in", ["success", "PAID", "SETTLED"])).stream()
    
    expired_users = {}
    for doc in query:
        data = doc.to_dict()
        email = (data.get("customer_email") or data.get("payer_email") or data.get("email") or "").strip().lower()
        if not email:
            continue
        name = data.get("customer_name") or data.get("payer_name") or "Tanpa Nama"
        plan = data.get("plan") or data.get("plan_id") or data.get("price_scheme_title") or "tholib_1m"
        
        # Check direct expires_at first
        direct_exp = parse_dt(data.get("subscription_expires_at") or data.get("expires_at"))
        if direct_exp:
            expiry_date = direct_exp
        else:
            paid_at = parse_dt(data.get("created_at") or data.get("paid_at"))
            if not paid_at:
                continue
            duration_months = get_duration_months(plan)
            expiry_year = paid_at.year + ((paid_at.month + duration_months - 1) // 12)
            expiry_month = (paid_at.month + duration_months - 1) % 12 + 1
            try:
                expiry_date = paid_at.replace(year=expiry_year, month=expiry_month)
            except ValueError:
                expiry_date = paid_at.replace(year=expiry_year, month=expiry_month, day=28)
        
        if expiry_date <= now:
            if email not in expired_users or expiry_date > expired_users[email]["exp"]:
                expired_users[email] = {"name": name, "exp": expiry_date, "plan": plan, "tx_id": doc.id}

    print(f"Total Unique Expired Emails from Transactions: {len(expired_users)}")
    for e, info in sorted(expired_users.items()):
        exp_str = info["exp"].strftime("%Y-%m-%d")
        nm = info["name"]
        pl = info["plan"]
        print(f"• {e:<35} | {nm:<25} | Exp: {exp_str} | {pl}")

if __name__ == "__main__":
    asyncio.run(main())
