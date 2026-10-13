"""Registries shared with the Cloud Functions / VPS worker.

`shared/vip_emails.json` and `shared/product_catalog.json` are generated from
the TypeScript source of truth (`npm run export-shared` in
openturath_ai/functions). Python never keeps its own copy of either list.
"""
from __future__ import annotations

import json
import os
import re
from functools import lru_cache

_SHARED = os.path.join(os.path.dirname(os.path.abspath(__file__)), "shared")
VIP_ROLES = {"vip", "admin", "guru", "special"}


def _load(name: str):
    with open(os.path.join(_SHARED, name), "r", encoding="utf-8") as handle:
        return json.load(handle)


def normal_email(value) -> str:
    return value.strip().lower() if isinstance(value, str) else ""


@lru_cache(maxsize=1)
def vip_emails() -> frozenset:
    emails = frozenset(normal_email(e) for e in _load("vip_emails.json"))
    if not emails:
        # An empty registry would silently remove every protection.
        raise RuntimeError("VIP registry is empty")
    return emails


@lru_cache(maxsize=1)
def catalog() -> dict:
    data = _load("product_catalog.json")
    if not data.get("scopes") or not data.get("akal_services"):
        raise RuntimeError("Product catalog is incomplete")
    return data


def is_vip_profile(profile) -> bool:
    """Same rule as `isVip` in access_control.ts (minus ledger grants)."""
    if not isinstance(profile, dict):
        return False
    return (normal_email(profile.get("email")) in vip_emails()
            or profile.get("is_vip") is True
            or str(profile.get("role") or "").lower() in VIP_ROLES)


def all_scopes() -> list:
    return sorted(catalog()["scopes"].keys())


def scope_label(scope: str) -> str:
    return catalog()["scopes"].get(scope, {}).get("label", scope)


def notebooks_for_scope(scope: str) -> list:
    """Master first, then legacy notebooks, for every entity of the scope."""
    if scope in ("all_access", "all_ai"):
        ids = []
        for each in catalog()["all_access_scopes"]:
            ids.extend(notebooks_for_scope(each))
        return list(dict.fromkeys(ids))
    ids = []
    for notebook in catalog()["scopes"].get(scope, {}).get("notebooks", []):
        ids.append(notebook["master"])
        ids.extend(notebook.get("legacy", []))
    return list(dict.fromkeys(ids))


def masters_for_scope(scope: str) -> list:
    """Notebooks a new viewer is added to: the master of every entity of the scope."""
    if scope in ("all_access", "all_ai"):
        ids = []
        for each in catalog()["all_access_scopes"]:
            ids.extend(masters_for_scope(each))
        return list(dict.fromkeys(ids))
    return list(dict.fromkeys(nb["master"] for nb in catalog()["scopes"].get(scope, {}).get("notebooks", [])))


def vip_registry_key(email: str) -> str:
    """Document ID in access_vip_registry; identical to keyOf(email) in TypeScript."""
    import hashlib
    return hashlib.sha256(json.dumps([normal_email(email)], separators=(",", ":"), ensure_ascii=False).encode("utf-8")).hexdigest()


def resolve_scopes(service_title) -> list:
    """Mirror of `resolveAkalScopes`: an unknown title resolves to nothing."""
    title = service_title.strip().lower() if isinstance(service_title, str) else ""
    if not title:
        return []
    data = catalog()
    for service in data["akal_services"]:
        if service["name"].lower() == title:
            return list(service["scopes"])
    for scope, info in data["scopes"].items():
        if info["label"].lower() == title:
            return [scope]
    if title == "paket semua ai":
        return ["all_access"] + list(data["all_access_scopes"])
    for pattern, scopes in data["keywords"]:
        if re.search(pattern, title):
            return list(scopes)
    return []


def scopes_for_cuid(cuid: str) -> list:
    for service in catalog()["akal_services"]:
        if cuid == service["cuid"] or cuid in service.get("fallbacks", []):
            return list(service["scopes"])
    return []
