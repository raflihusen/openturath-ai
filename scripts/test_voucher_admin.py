import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from voucher_admin import VoucherError, build_voucher, display, generate_code  # noqa: E402


class VoucherAdminTest(unittest.TestCase):
    def test_single_and_multi_key_shapes(self):
        _, one = build_voucher(["hadits"], days=14)
        self.assertEqual(one["entitlement_key"], "hadits")
        self.assertNotIn("entitlement_keys", one)
        _, many = build_voucher(["hadits", "tafsir", "hadits"], days=14)
        self.assertEqual(many["entitlement_keys"], ["hadits", "tafsir"])

    def test_all_ai_alias_and_unknown_keys(self):
        _, doc = build_voucher(["all_ai"])
        self.assertEqual(doc["entitlement_key"], "all_access")
        with self.assertRaises(VoucherError):
            build_voucher(["bukan_ai"])
        with self.assertRaises(VoucherError):
            build_voucher([])

    def test_duration_rules_match_server(self):
        with self.assertRaises(VoucherError):
            build_voucher(["hadits"], days=365)
        with self.assertRaises(VoucherError):
            build_voucher(["hadits"], days=0)
        _, honor = build_voucher(["hadits"], vtype="honor", days=365)
        self.assertEqual(honor["duration_days"], 365)
        _, longv = build_voucher(["hadits"], days=90, allow_long=True)
        self.assertTrue(longv["allow_long_duration"])
        with self.assertRaises(VoucherError):
            build_voucher(["hadits"], vtype="trial", days=90, allow_long=True)

    def test_trial_prefix_rules(self):
        with self.assertRaises(VoucherError):
            build_voucher(["hadits"], prefix="TRIALKU")
        code, doc = build_voucher(["hadits"], vtype="trial", prefix="TRIAL", days=7)
        self.assertTrue(code.startswith("TRIAL"))
        self.assertTrue(doc["one_per_device"])

    def test_codes_are_normalised_random_and_unambiguous(self):
        code, _ = build_voucher(["hadits"], code="santri-7 a")
        self.assertEqual(code, "SANTRI7A")
        a, b = generate_code(), generate_code()
        self.assertNotEqual(a, b)
        self.assertEqual(len(a), 10)
        self.assertFalse(set(a) & set("01OIL"))
        self.assertEqual(display("ABCDEFGHJK"), "ABCD-EFGH-JK")
        with self.assertRaises(VoucherError):
            build_voucher(["hadits"], code="kode#ilegal")

    def test_expiry_and_limits(self):
        _, doc = build_voucher(["hadits"], expires="2026-12-31")
        self.assertEqual(doc["expires_at"].hour, 23)
        with self.assertRaises(VoucherError):
            build_voucher(["hadits"], expires="31/12/2026")
        with self.assertRaises(VoucherError):
            build_voucher(["hadits"], max_uses=0)


if __name__ == "__main__":
    unittest.main()
