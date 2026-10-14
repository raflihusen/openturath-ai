"""Pure access evaluation for the legacy reaper. No network, no SDK imports.

Rules (AGENTS.md rule 5):
  * a VIP is never a removal candidate, whatever any record says;
  * every module is evaluated on its own evidence;
  * a real transaction outranks a profile field: an expired or corrupt
    profile entry can never cancel access proven by an active transaction;
  * a viewer with no expiry evidence for the module is never removed.
"""
from __future__ import annotations

import calendar
from datetime import datetime, timedelta, timezone

ACTIVE_TX = {"SUCCESS", "PAID", "SETTLED", "TRANSFERRED", "COMPLETED", "ACTIVE"}
ENDED_TX = {"EXPIRED", "FAILED", "CANCELLED"}
ALL_ACCESS = {"all_access", "all_ai"}
VIP_ROLES = {"vip", "admin", "guru", "special"}
ALL_ACCESS_PLAN_HINTS = ("all_ai", "all_access", "all-access", "full", "sultan")


def billing_expiry(start: datetime, months: int) -> datetime:
    """Same period rule as `billingExpiry` in access_control.ts."""
    if not isinstance(months, int) or months < 1 or months > 120:
        raise ValueError("Invalid product duration")
    if months == 1:
        return start + timedelta(days=30)
    start = start.astimezone(timezone.utc)
    index = start.year * 12 + (start.month - 1) + months
    year, month = divmod(index, 12)
    return start.replace(year=year, month=month + 1, day=min(start.day, calendar.monthrange(year, month + 1)[1]))


def parse_dt(value):
    if not value:
        return None
    if isinstance(value, datetime):
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    if isinstance(value, str):
        try:
            parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
        except ValueError:
            return None
        return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)
    return None


def _email(record, *fields) -> str:
    for field in fields:
        value = record.get(field)
        if isinstance(value, str) and value.strip():
            return value.strip().lower()
    return ""


def _tx_scopes(tx) -> list:
    keys = tx.get("entitlement_keys")
    if isinstance(keys, list) and keys:
        return [k for k in keys if isinstance(k, str) and k]
    key = tx.get("entitlement_key")
    return [key] if isinstance(key, str) and key else []


def classify(transactions, users, akal_active, vip, modules, now):
    """Return (protected, active_by_module, expired_by_module).

    `akal_active` maps a scope (or "*" for an unmapped service) to emails with
    an unexpired GoAkal period.
    """
    modules = list(modules)
    protected = set(vip)
    active = {m: set() for m in modules}
    expired = {m: set() for m in modules}

    def mark(target, scopes, email):
        if any(s in ALL_ACCESS for s in scopes):
            scopes = modules
        for scope in scopes:
            if scope in target:
                target[scope].add(email)

    for tx in transactions:
        email = _email(tx, "customer_email", "payer_email", "email")
        if not email:
            continue
        plan = str(tx.get("plan") or tx.get("plan_id") or "")
        ends = parse_dt(tx.get("subscription_expires_at") or tx.get("access_expires_at") or tx.get("expires_at"))
        if tx.get("is_vip") is True or "VIP" in plan.upper() or (ends and ends.year >= 2030):
            protected.add(email)
            continue
        status = str(tx.get("status") or "").upper()
        scopes = _tx_scopes(tx)
        is_all_access = any(s in ALL_ACCESS for s in scopes) or any(hint in plan.lower() for hint in ALL_ACCESS_PLAN_HINTS)
        if status in ACTIVE_TX and ends and ends > now:
            # An unexpired all-access or unscoped purchase covers every module; scoped purchases cover only their modules.
            mark(active, modules if (is_all_access or not scopes) else scopes, email)
        elif (status in ACTIVE_TX and ends and ends <= now) or status in ENDED_TX:
            if is_all_access or not scopes:
                mark(expired, modules, email)
            elif scopes:
                mark(expired, scopes, email)
            elif "tholib" in plan.lower():
                mark(expired, ["fiqh_tahawwulat", "fiqh_syafii"], email)
            else:
                mark(expired, modules, email)

    for user in users:
        email = _email(user, "email")
        if not email:
            continue
        if user.get("is_vip") is True or str(user.get("role") or "").lower() in VIP_ROLES:
            protected.add(email)
            continue
        entitlements = user.get("entitlements")
        if isinstance(entitlements, dict) and entitlements:
            for scope, entry in entitlements.items():
                if not isinstance(entry, dict):
                    continue
                ends = parse_dt(entry.get("expiry") or entry.get("expires_at"))
                ended = str(entry.get("status") or "").lower() in ("revoked", "expired")
                if ends and ends > now and not ended:
                    mark(active, [scope], email)
                elif ends and ends <= now:
                    # Evidence of expiry only; it never cancels an active transaction.
                    mark(expired, [scope], email)
        else:
            ends = parse_dt(user.get("subscription_expiry"))
            if ends and ends > now:
                mark(active, modules, email)
            elif ends and ends <= now:
                mark(expired, modules, email)

    for scope, emails in (akal_active or {}).items():
        for email in emails:
            mark(active, modules if scope == "*" else [scope], email.strip().lower())

    for module in modules:
        expired[module] -= active[module]
        expired[module] -= protected
    return protected, active, expired


def removal_candidates(viewers, module, protected, active, expired) -> set:
    """Viewers of one notebook that are proven expired for its module."""
    viewers = {v.strip().lower() for v in viewers}
    return (viewers & expired.get(module, set())) - active.get(module, set()) - set(protected)
