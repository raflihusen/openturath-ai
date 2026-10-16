import asyncio
import os
import sys
import types
import unittest
from datetime import datetime, timedelta, timezone

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)


class Snapshot:
    def __init__(self, ref, data):
        self.reference, self._data, self.exists, self.id = ref, data, data is not None, ref.id

    def to_dict(self):
        return dict(self._data) if self._data is not None else None


class Document:
    def __init__(self, db, path):
        self.db, self.path, self.id = db, path, path.split("/")[-1]

    def get(self):
        return Snapshot(self, self.db.docs.get(self.path))

    def set(self, data, merge=False):
        self.db.docs[self.path] = {**(self.db.docs.get(self.path, {}) if merge else {}), **data}

    def create(self, data):
        if self.path in self.db.docs:
            raise RuntimeError("AlreadyExists")
        self.db.docs[self.path] = dict(data)

    def update(self, data):
        doc = self.db.docs[self.path]
        for key, value in data.items():
            target, parts = doc, key.split(".")
            for part in parts[:-1]:
                target = target.setdefault(part, {})
            target[parts[-1]] = value


class Query:
    def __init__(self, db, name, filters=()):
        self.db, self.name, self.filters = db, name, tuple(filters)

    def document(self, doc_id):
        return Document(self.db, f"{self.name}/{doc_id}")

    def where(self, field, op, value):
        return Query(self.db, self.name, self.filters + ((field, op, value),))

    def limit(self, _):
        return self

    def stream(self):
        for path, data in list(self.db.docs.items()):
            if path.startswith(self.name + "/") and all(data.get(f) == v for f, _, v in self.filters):
                yield Snapshot(Document(self.db, path), data)


class FakeDB:
    def __init__(self):
        self.docs = {}

    def collection(self, name):
        return Query(self, name)


class FakeNotebooks:
    def __init__(self):
        self.added, self.removed, self.ok = [], [], True

    async def add_viewer(self, notebook, email, name=""):
        self.added.append((notebook, email))
        return {"success": self.ok}

    async def remove_viewer(self, notebook, email):
        self.removed.append((notebook, email))
        return {"success": self.ok}


# The server imports the Google SDKs at module load; tests replace them.
google = types.ModuleType("google"); cloud = types.ModuleType("google.cloud")
firestore = types.ModuleType("google.cloud.firestore")
firestore.SERVER_TIMESTAMP = "ts"; firestore.Client = lambda *a, **k: None
api_core = types.ModuleType("google.api_core"); exceptions = types.ModuleType("google.api_core.exceptions")
exceptions.AlreadyExists = RuntimeError
cloud.firestore = firestore; google.cloud = cloud; google.api_core = api_core; api_core.exceptions = exceptions
sys.modules.update({"google": google, "google.cloud": cloud, "google.cloud.firestore": firestore,
                    "google.api_core": api_core, "google.api_core.exceptions": exceptions,
                    "notebooklm_manager": types.ModuleType("notebooklm_manager")})
os.environ.setdefault("AKAL_WEBHOOK_SECRET", "s" * 40)

import shared_registry as registry  # noqa: E402
import webhook_server as server  # noqa: E402

PAID_AT = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
SYAFII_MASTER = "c89d09ca-4b48-4000-a98d-59e532607fb6"


def akal(service="Super AI Fikih Hanafi", **data):
    return {"event": "transaction.paid", "token": "s" * 40, "data": {
        "id": "pay_1", "status": "PAID", "amount": 50000, "paidAt": PAID_AT,
        "payer": {"email": "Buyer@Example.test", "name": "<b>Buyer</b>"},
        "service": {"name": service}, "priceScheme": {"name": "1 Bulan"}, **data}}


def internal(status, key="fiqh_syafii", email="buyer@example.test"):
    return {"event": "subscription", "data": {"status": status, "payer": {"email": email, "name": "Buyer"},
                                              "service": {"name": "AI Fikih Syafi'i", "key": key}}}


class WebhookTest(unittest.TestCase):
    def setUp(self):
        self.db, self.nlm, self.sent = FakeDB(), FakeNotebooks(), []
        self.db.docs["users/u"] = {"email": "buyer@example.test", "plan": "trial", "entitlements": {}}
        server.db_client = self.db
        server.nlm = self.nlm
        server.send_telegram_message = self.sent.append
        self._sleep = asyncio.sleep
        server.asyncio.sleep = lambda *_: self._sleep(0)

    def tearDown(self):
        server.asyncio.sleep = self._sleep

    def run_hook(self, payload, internal_call=False):
        return asyncio.run(server.process_webhook(payload, internal=internal_call))

    def events(self):
        return [d for p, d in self.db.docs.items() if p.startswith("access_legacy_events/")]

    def test_purchase_unlocks_only_its_own_module_and_master_notebook(self):
        result = self.run_hook(akal())
        self.assertTrue(result["success"])
        user = self.db.docs["users/u"]
        self.assertEqual(list(user["entitlements"]), ["fiqh_hanafi"])
        self.assertEqual(user["plan"], "trial")
        self.assertNotIn("subscription_expiry", user)
        self.assertEqual([n for n, _ in self.nlm.added], registry.masters_for_scope("fiqh_hanafi"))
        self.assertNotIn(SYAFII_MASTER, [n for n, _ in self.nlm.added])
        self.assertEqual(self.db.docs["transactions/pay_1"]["entitlement_keys"], ["fiqh_hanafi"])
        self.assertIn("&lt;b&gt;Buyer", self.sent[0])

    def test_unknown_product_and_zero_amount_are_quarantined(self):
        for payload, reason in ((akal("Kelas Memasak"), "unknown_service"), (akal(amount=0), "invalid_billing_identity_or_amount")):
            self.assertEqual(self.run_hook(payload)["action"], "durable_vps_handoff")
        self.assertEqual(sorted(e["reason"] for e in self.events()), ["invalid_billing_identity_or_amount", "unknown_service"])
        self.assertEqual(self.db.docs["users/u"]["entitlements"], {})
        self.assertEqual(self.nlm.added, [])

    def test_replay_does_not_extend_the_period(self):
        self.run_hook(akal("AI Fikih Syafi'i"))
        first = self.db.docs["users/u"]["entitlements"]["fiqh_syafii"]["expiry"]
        self.run_hook(akal("AI Fikih Syafi'i"))
        self.assertEqual(self.db.docs["users/u"]["entitlements"]["fiqh_syafii"]["expiry"], first)

    def test_a_longer_existing_entitlement_is_kept(self):
        later = datetime.now(timezone.utc) + timedelta(days=400)
        self.db.docs["users/u"]["entitlements"] = {"fiqh_syafii": {"plan": "x", "status": "revoked", "expiry": later}}
        self.run_hook(akal("AI Fikih Syafi'i"))
        self.assertEqual(self.db.docs["users/u"]["entitlements"]["fiqh_syafii"]["status"], "active")
        self.db.docs["users/u"]["entitlements"]["fiqh_syafii"] = {"plan": "voucher", "status": "active", "expiry": later}
        self.run_hook(akal("AI Fikih Syafi'i", id="pay_2", paidAt=(datetime.now(timezone.utc) - timedelta(days=45)).isoformat()))
        self.assertGreaterEqual(self.db.docs["users/u"]["entitlements"]["fiqh_syafii"]["expiry"], later)

    def test_negative_events_are_never_revoked_directly(self):
        self.assertEqual(self.run_hook(akal(status="EXPIRED"))["action"], "durable_vps_handoff")
        self.assertEqual(self.nlm.removed, [])

    def test_internal_add_shares_the_master_without_touching_billing(self):
        result = self.run_hook(internal("PAID"), internal_call=True)
        self.assertEqual(result, {"success": True, "action": "provisioned"})
        self.assertEqual(self.nlm.added, [(SYAFII_MASTER, "buyer@example.test")])
        self.assertFalse(any(p.startswith("transactions/") for p in self.db.docs))
        self.assertEqual(self.events(), [])

    def test_internal_failure_is_reported_so_the_outbox_retries(self):
        self.nlm.ok = False
        self.assertFalse(self.run_hook(internal("PAID"), internal_call=True)["success"])
        self.assertFalse(self.run_hook(internal("PAID", key="tidak_ada"), internal_call=True)["success"])

    def test_internal_remove_spares_every_kind_of_vip(self):
        listed = next(iter(registry.vip_emails()))
        self.db.docs["users/flag"] = {"email": "flag@example.test", "is_vip": True}
        self.db.docs["users/role"] = {"email": "role@example.test", "role": "guru"}
        self.db.docs["access_vip_registry/" + registry.vip_registry_key("reg@example.test")] = {"email": "reg@example.test"}
        for email in (listed, "flag@example.test", "role@example.test", "reg@example.test"):
            self.assertEqual(self.run_hook(internal("EXPIRED", email=email), internal_call=True)["action"], "ignored_permanent_vip")
        self.assertEqual(self.nlm.removed, [])

    def test_internal_remove_clears_master_and_legacy_notebooks(self):
        self.assertEqual(self.run_hook(internal("EXPIRED"), internal_call=True)["action"], "deprovisioned")
        self.assertEqual([n for n, _ in self.nlm.removed], registry.notebooks_for_scope("fiqh_syafii"))

    def test_vip_check_fails_closed_without_firestore(self):
        server.db_client = None
        server.firestore.Client = lambda *a, **k: (_ for _ in ()).throw(RuntimeError("down"))
        with self.assertRaises(RuntimeError):
            server.is_protected_owner("someone@example.test")

    def test_after_cutover_internal_and_negative_events_defer_to_vps_but_purchases_are_provisioned(self):
        self.db.docs["access_control/runtime"] = {"writer": "vps-v2"}
        self.assertEqual(self.run_hook(internal("PAID"), internal_call=True)["action"], "vps_writer_active")
        self.assertEqual(self.run_hook(akal(status="EXPIRED"))["action"], "durable_vps_handoff")
        # Real purchases must NEVER be dropped or delayed; they are immediately provisioned
        result = self.run_hook(akal())
        self.assertEqual(result["action"], "provisioned")
        self.assertTrue(result["success"])
        self.assertEqual(self.nlm.added, [])
        self.assertTrue(any(k.startswith("access_legacy_events/") for k in self.db.docs))


class BillingPeriodTest(unittest.TestCase):
    def test_period_matches_the_cloud_function_rule(self):
        import access_policy
        start = datetime(2026, 1, 31, tzinfo=timezone.utc)
        self.assertEqual(access_policy.billing_expiry(start, 1), start + timedelta(days=30))
        self.assertEqual(access_policy.billing_expiry(start, 12), datetime(2027, 1, 31, tzinfo=timezone.utc))
        self.assertEqual(access_policy.billing_expiry(datetime(2026, 8, 31, tzinfo=timezone.utc), 6), datetime(2027, 2, 28, tzinfo=timezone.utc))
        with self.assertRaises(ValueError):
            access_policy.billing_expiry(start, 0)


if __name__ == "__main__":
    unittest.main()
