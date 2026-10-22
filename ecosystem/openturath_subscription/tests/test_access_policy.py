import os
import sys
import unittest
from datetime import datetime, timedelta, timezone

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import access_policy as policy  # noqa: E402
import shared_registry as registry  # noqa: E402

NOW = datetime(2026, 10, 13, tzinfo=timezone.utc)
PAST, FUTURE = NOW - timedelta(days=5), NOW + timedelta(days=40)
MODULES = ["fiqh_syafii", "fiqh_tahawwulat", "hadits"]


def tx(email, ends, key="fiqh_syafii", **extra):
    return {"customer_email": email, "status": "success", "plan": "tholib_1m", "amount": 50000,
            "entitlement_key": key, "subscription_expires_at": ends, **extra}


def run(transactions=(), users=(), akal=None, vip=()):
    return policy.classify(list(transactions), list(users), akal or {}, set(vip), MODULES, NOW)


class ClassifyTest(unittest.TestCase):
    def test_one_month_plan_past_expiry_is_detected(self):
        protected, active, expired = run([tx("a@x.test", PAST)])
        self.assertEqual(expired["fiqh_syafii"], {"a@x.test"})
        self.assertEqual(policy.removal_candidates({"A@x.test"}, "fiqh_syafii", protected, active, expired), {"a@x.test"})

    def test_modules_are_independent(self):
        # A 1-year subscription to fiqh_tahawwulat does NOT grant fiqh_syafii,
        # but protects the user from being removed from fiqh_tahawwulat (Rule 5 AGENTS.md).
        protected, active, expired = run([tx("a@x.test", PAST), tx("a@x.test", FUTURE, key="fiqh_tahawwulat", plan="bahits_1y")])
        self.assertEqual(expired["fiqh_syafii"], {"a@x.test"})
        self.assertIn("a@x.test", active["fiqh_tahawwulat"])
        self.assertEqual(policy.removal_candidates({"a@x.test"}, "fiqh_tahawwulat", protected, active, expired), set())
        self.assertEqual(policy.removal_candidates({"a@x.test"}, "fiqh_syafii", protected, active, expired), {"a@x.test"})

        # Only true all-access plans cover all modules
        protected, active, expired = run([tx("a@x.test", PAST), tx("a@x.test", FUTURE, plan="all_access")])
        self.assertEqual(expired["fiqh_syafii"], set())
        self.assertIn("a@x.test", active["fiqh_syafii"])

    def test_expired_profile_field_never_cancels_an_active_transaction(self):
        user = {"email": "a@x.test", "entitlements": {"fiqh_syafii": {"expiry": PAST, "status": "active"}}}
        _, active, expired = run([tx("a@x.test", FUTURE)], [user])
        self.assertIn("a@x.test", active["fiqh_syafii"])
        self.assertEqual(expired["fiqh_syafii"], set())

    def test_voucher_entitlement_keeps_module_after_old_transaction_expires(self):
        user = {"email": "a@x.test", "entitlements": {"fiqh_syafii": {"expiry": FUTURE, "status": "active"}}}
        _, _, expired = run([tx("a@x.test", PAST)], [user])
        self.assertEqual(expired["fiqh_syafii"], set())

    def test_vip_sources_are_all_protected(self):
        users = [{"email": "flag@x.test", "is_vip": True}, {"email": "role@x.test", "role": "Guru"}]
        transactions = [tx(e, PAST) for e in ("flag@x.test", "role@x.test", "list@x.test", "txvip@x.test")]
        transactions[3]["is_vip"] = True
        protected, active, expired = run(transactions, users, vip={"list@x.test"})
        self.assertEqual(expired["fiqh_syafii"], set())
        self.assertTrue({"flag@x.test", "role@x.test", "list@x.test", "txvip@x.test"} <= protected)

    def test_unknown_viewer_without_expiry_evidence_is_never_removed(self):
        protected, active, expired = run([tx("a@x.test", PAST)])
        self.assertEqual(policy.removal_candidates({"stranger@x.test"}, "fiqh_syafii", protected, active, expired), set())

    def test_akal_period_is_scoped_to_its_own_module(self):
        _, active, expired = run([tx("a@x.test", PAST), tx("a@x.test", PAST, key="hadits")], akal={"hadits": {"A@x.test"}})
        self.assertEqual(expired["hadits"], set())
        self.assertEqual(expired["fiqh_syafii"], {"a@x.test"})

    def test_expired_annual_plan_is_expired(self):
        _, _, expired = run([tx("a@x.test", PAST, plan="bahits_1y", amount=1999000)])
        self.assertEqual(expired["fiqh_syafii"], {"a@x.test"})

    def test_bundle_scopes_and_all_access(self):
        _, active, _ = run([tx("a@x.test", FUTURE, key="hadits", entitlement_keys=["hadits", "fiqh_syafii"]),
                            tx("b@x.test", FUTURE, key="all_access")])
        self.assertIn("a@x.test", active["fiqh_syafii"])
        self.assertNotIn("a@x.test", active["fiqh_tahawwulat"])
        self.assertTrue(all("b@x.test" in active[m] for m in MODULES))


class RegistryTest(unittest.TestCase):
    def test_registry_is_loaded_and_normalised(self):
        emails = registry.vip_emails()
        self.assertGreaterEqual(len(emails), 17)
        self.assertTrue(all(e == e.strip().lower() and "@" in e for e in emails))
        self.assertTrue(registry.is_vip_profile({"email": next(iter(emails)).upper()}))
        self.assertTrue(registry.is_vip_profile({"email": "x@x.test", "role": "VIP"}))
        self.assertFalse(registry.is_vip_profile({"email": "x@x.test"}))

    def test_products_resolve_to_their_own_module_and_unknown_is_empty(self):
        self.assertEqual(registry.resolve_scopes("Super AI Fikih Hanafi"), ["fiqh_hanafi"])
        self.assertEqual(registry.resolve_scopes("AI Fikih Syafi'i"), ["fiqh_syafii"])
        self.assertEqual(registry.resolve_scopes("Super AI Aqidah & Ushuluddin"), ["aqidah"])
        self.assertEqual(registry.resolve_scopes("Super AI Fatawa & Masail"), ["fiqh"])
        self.assertEqual(registry.resolve_scopes("Kelas Memasak"), [])
        self.assertEqual(registry.resolve_scopes(None), [])
        for service in registry.catalog()["akal_services"]:
            self.assertEqual(registry.resolve_scopes(service["name"]), service["scopes"])

    def test_each_module_shares_its_own_master_notebook(self):
        syafii = registry.notebooks_for_scope("fiqh_syafii")
        self.assertEqual(syafii[0], "c89d09ca-4b48-4000-a98d-59e532607fb6")
        hanafi = registry.notebooks_for_scope("fiqh_hanafi")
        self.assertTrue(hanafi)
        self.assertFalse(set(hanafi) & set(syafii))
        self.assertTrue(set(syafii) <= set(registry.notebooks_for_scope("all_access")))


    def test_a_long_purchase_ending_after_2030_is_not_a_vip(self):
        tx = {"customer_email": "b@x.test", "status": "SUCCESS", "plan": "bahits_1y", "entitlement_key": "fiqh_syafii",
              "subscription_expires_at": datetime(2030, 2, 1, tzinfo=timezone.utc)}
        protected, _, expired = policy.classify([tx], [], {}, set(), ["fiqh_syafii"], datetime(2030, 6, 1, tzinfo=timezone.utc))
        self.assertNotIn("b@x.test", protected)
        self.assertIn("b@x.test", expired["fiqh_syafii"])

if __name__ == "__main__":
    unittest.main()
