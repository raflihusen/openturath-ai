"""Tes manage_ota.py: logika saklar fitur, updateMask, dan ketahanan terhadap dokumen rusak.

Tidak menyentuh jaringan atau Firestore. Jalankan: python3 scripts/test_manage_ota.py
"""
import json
import sys
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import manage_ota as ota  # noqa: E402

DEFAULTS = {
    "soon_sub_agent_ids": ["fiqh_tahawwulat_khatib", "fiqh_tahawwulat_habib", "fiqh_tahawwulat_mukhtabir"],
    "introduction_enabled": False,
}


def _defaults():
    return {"soon_sub_agent_ids": list(DEFAULTS["soon_sub_agent_ids"]), "introduction_enabled": False}


class ReadFeaturesTest(unittest.TestCase):
    def test_empty_or_missing_document_uses_closed_defaults(self):
        for doc in (None, {}):
            state = ota.read_features(doc)
            self.assertEqual(sorted(state["soon_sub_agent_ids"]), sorted(DEFAULTS["soon_sub_agent_ids"]))
            self.assertFalse(state["introduction_enabled"])

    def test_empty_list_means_everything_open(self):
        state = ota.read_features({"soon_sub_agent_ids": [], "introduction_enabled": True})
        self.assertEqual(state["soon_sub_agent_ids"], [])
        self.assertTrue(state["introduction_enabled"])

    def test_wrong_types_are_ignored_not_trusted(self):
        # Rantai "true" bukan boolean; angka bukan boolean.
        self.assertFalse(ota.read_features({"introduction_enabled": "true"})["introduction_enabled"])
        self.assertFalse(ota.read_features({"introduction_enabled": 1})["introduction_enabled"])
        for bad in ("fiqh_tahawwulat_khatib", 7, None, {"a": 1}):
            state = ota.read_features({"soon_sub_agent_ids": bad})
            self.assertEqual(sorted(state["soon_sub_agent_ids"]), sorted(DEFAULTS["soon_sub_agent_ids"]), bad)

    def test_invalid_elements_dropped_valid_kept_and_deduplicated(self):
        state = ota.read_features({"soon_sub_agent_ids": [
            "fiqh_tahawwulat_khatib", "  fiqh_tahawwulat_habib  ", "fiqh_tahawwulat_khatib",
            42, None, "", "Salah Format", "a/b", "9angka"]})
        self.assertEqual(state["soon_sub_agent_ids"], ["fiqh_tahawwulat_khatib", "fiqh_tahawwulat_habib"])

    def test_over_limit_list_is_treated_as_typo(self):
        many = [f"agent_{i}" for i in range(ota.MAX_SOON_IDS + 1)]
        state = ota.read_features({"soon_sub_agent_ids": many})
        self.assertEqual(sorted(state["soon_sub_agent_ids"]), sorted(DEFAULTS["soon_sub_agent_ids"]))

    def test_operator_labels_say_coming_soon_not_hidden(self):
        # Mengenal tetap tampil sebagai "Segera hadir"; label operator tidak boleh bilang "disembunyikan".
        src = (Path(__file__).resolve().parent.parent / "manage_ota.py").read_text("utf8")
        self.assertIn("SEGERA HADIR (tombol tampil, slide tertutup)", src)
        self.assertNotIn("DISEMBUNYIKAN", src)

    def test_defaults_match_the_other_two_implementations(self):
        # Dart dan TypeScript menyimpan bawaan yang sama; tes ini menjaga kesepakatan.
        root = Path(__file__).resolve().parent.parent
        dart = (root / "openturath_ai/lib/services/feature_flags.dart").read_text("utf8")
        ts = (root / "openturath_ai/functions/src/index.ts").read_text("utf8")
        for agent in DEFAULTS["soon_sub_agent_ids"]:
            self.assertIn(f"'{agent}'", dart, f"{agent} tidak ada di feature_flags.dart")
            self.assertIn(f'"{agent}"', ts, f"{agent} tidak ada di index.ts")
        self.assertIn("introductionEnabled: false", dart)
        # Pola id dan batas jumlah harus sama di ketiganya.
        self.assertIn(r"^[a-z][a-z0-9_]{0,79}$", dart)
        self.assertIn(r"^[a-z][a-z0-9_]{0,79}$", ts)
        self.assertIn("maxSoonIds = 50", dart)
        self.assertIn("MAX_SOON_IDS = 50", ts)
        self.assertEqual(ota.MAX_SOON_IDS, 50)


class ApplyChangeTest(unittest.TestCase):
    def test_release_removes_only_that_agent(self):
        new = ota.apply_feature_change(_defaults(), release="fiqh_tahawwulat_khatib")
        self.assertEqual(new["soon_sub_agent_ids"], ["fiqh_tahawwulat_habib", "fiqh_tahawwulat_mukhtabir"])

    def test_release_all_three_leaves_empty_list(self):
        state = _defaults()
        for agent in DEFAULTS["soon_sub_agent_ids"]:
            state = ota.apply_feature_change(state, release=agent)
        self.assertEqual(state["soon_sub_agent_ids"], [])

    def test_soon_adds_once_and_is_idempotent(self):
        base = ota.apply_feature_change(_defaults(), release="fiqh_tahawwulat_khatib")
        again = ota.apply_feature_change(base, soon="fiqh_tahawwulat_khatib")
        twice = ota.apply_feature_change(again, soon="fiqh_tahawwulat_khatib")
        self.assertEqual(again, twice)
        self.assertEqual(again["soon_sub_agent_ids"].count("fiqh_tahawwulat_khatib"), 1)

    def test_intro_toggle_leaves_the_list_untouched(self):
        new = ota.apply_feature_change(_defaults(), intro="on")
        self.assertTrue(new["introduction_enabled"])
        self.assertEqual(new["soon_sub_agent_ids"], sorted(DEFAULTS["soon_sub_agent_ids"]))
        off = ota.apply_feature_change(new, intro="off")
        self.assertFalse(off["introduction_enabled"])

    def test_input_is_never_mutated(self):
        original = _defaults()
        snapshot = json.loads(json.dumps(original))
        ota.apply_feature_change(original, release="fiqh_tahawwulat_khatib", intro="on")
        self.assertEqual(original, snapshot)

    def test_invalid_and_unknown_ids_are_rejected(self):
        for bad in ("fiqh_syafii", "fiqh_tahawwulat", "Salah Format", "", "a/b", "fiqh_tahawwulat_xyz"):
            with self.assertRaises(ota.FeatureError, msg=bad):
                ota.apply_feature_change(_defaults(), soon=bad)
            with self.assertRaises(ota.FeatureError, msg=bad):
                ota.apply_feature_change(_defaults(), release=bad)

    def test_invalid_intro_value_is_rejected(self):
        for bad in ("ON", "true", "1", "", "yes"):
            with self.assertRaises(ota.FeatureError, msg=bad):
                ota.apply_feature_change(_defaults(), intro=bad)

    def test_every_known_sub_agent_is_valid(self):
        for agent in ota.KNOWN_SUB_AGENTS:
            self.assertEqual(ota.validate_sub_agent_id(agent), agent)


class PayloadTest(unittest.TestCase):
    def test_firestore_payload_shape_round_trips(self):
        state = {"soon_sub_agent_ids": ["fiqh_tahawwulat_habib"], "introduction_enabled": True}
        fields = ota.to_firestore_features_fields(state, "catatan")
        self.assertEqual(fields["introduction_enabled"], {"booleanValue": True})
        self.assertEqual(fields["soon_sub_agent_ids"]["arrayValue"]["values"], [{"stringValue": "fiqh_tahawwulat_habib"}])
        self.assertEqual(ota.read_features(ota.parse_firestore_fields(fields)), {
            "soon_sub_agent_ids": ["fiqh_tahawwulat_habib"], "introduction_enabled": True})

    def test_empty_list_round_trips_as_empty_not_as_defaults(self):
        # Daftar kosong adalah niat ("semua terbuka"), bukan "tidak diisi".
        fields = ota.to_firestore_features_fields({"soon_sub_agent_ids": [], "introduction_enabled": True})
        parsed = ota.parse_firestore_fields(fields)
        self.assertEqual(ota.read_features(parsed)["soon_sub_agent_ids"], [])

    def test_boolean_false_is_not_dropped(self):
        fields = ota.to_firestore_features_fields({"soon_sub_agent_ids": [], "introduction_enabled": False})
        self.assertEqual(fields["introduction_enabled"], {"booleanValue": False})


class UpdateMaskTest(unittest.TestCase):
    """rest_patch harus mengirim updateMask, supaya bidang lain tidak terhapus."""

    def _capture(self, **kwargs):
        sent = {}

        class Resp:
            def __enter__(self_inner):
                return self_inner

            def __exit__(self_inner, *a):
                return False

            def read(self_inner):
                return b"{}"

        def fake_urlopen(req):
            sent["url"] = req.full_url
            sent["method"] = req.get_method()
            sent["body"] = json.loads(req.data.decode("utf-8"))
            return Resp()

        with mock.patch.object(ota.urllib.request, "urlopen", fake_urlopen):
            ota.rest_patch("features", {"a": {"stringValue": "x"}}, "token", **kwargs)
        return sent

    def test_without_mask_url_has_no_query(self):
        sent = self._capture()
        self.assertEqual(sent["method"], "PATCH")
        self.assertNotIn("updateMask", sent["url"])

    def test_with_mask_each_field_path_is_sent(self):
        sent = self._capture(update_mask=["soon_sub_agent_ids", "introduction_enabled"])
        self.assertIn("updateMask.fieldPaths=soon_sub_agent_ids", sent["url"])
        self.assertIn("updateMask.fieldPaths=introduction_enabled", sent["url"])
        self.assertTrue(sent["url"].split("?")[0].endswith("/app_config/features"))


class CommandFlowTest(unittest.TestCase):
    """Alur perintah dengan Firestore palsu: dry-run tidak menulis, perintah nyata menulis dengan mask."""

    def _run(self, fn, *args, existing=None, dry_run=False):
        writes = []
        doc = {"fields": existing} if existing is not None else None
        with mock.patch.object(ota, "rest_get", lambda name, token: doc), \
                mock.patch.object(ota, "rest_patch", lambda *a, **k: writes.append((a, k))), \
                mock.patch("builtins.print"):
            fn(*args, dry_run, "token")
        return writes

    def test_dry_run_never_writes(self):
        self.assertEqual(self._run(ota.cmd_release_sub_agent, "fiqh_tahawwulat_khatib", dry_run=True), [])
        self.assertEqual(self._run(ota.cmd_intro, "on", dry_run=True), [])
        self.assertEqual(self._run(ota.cmd_soon_sub_agent, "fiqh_tahawwulat_bayan", dry_run=True), [])

    def test_release_writes_with_mask_limited_to_feature_fields(self):
        writes = self._run(ota.cmd_release_sub_agent, "fiqh_tahawwulat_khatib")
        self.assertEqual(len(writes), 1)
        (name, payload, token), kwargs = writes[0]
        self.assertEqual(name, "features")
        self.assertEqual(set(kwargs["update_mask"]),
                         {"soon_sub_agent_ids", "introduction_enabled", "updated_at", "note"})
        values = [v["stringValue"] for v in payload["soon_sub_agent_ids"]["arrayValue"]["values"]]
        self.assertNotIn("fiqh_tahawwulat_khatib", values)
        self.assertEqual(set(values), {"fiqh_tahawwulat_habib", "fiqh_tahawwulat_mukhtabir"})

    def test_no_op_changes_do_not_write(self):
        # khatib sudah segera hadir secara bawaan -> menandainya lagi tidak menulis.
        # Dokumen belum ada: perubahan no-op tetap membuat dokumen? Tidak: tidak ada perubahan niat.
        existing = {
            "soon_sub_agent_ids": {"arrayValue": {"values": [{"stringValue": a} for a in DEFAULTS["soon_sub_agent_ids"]]}},
            "introduction_enabled": {"booleanValue": False},
        }
        self.assertEqual(self._run(ota.cmd_soon_sub_agent, "fiqh_tahawwulat_khatib", existing=existing), [])
        self.assertEqual(self._run(ota.cmd_intro, "off", existing=existing), [])

    def test_first_write_creates_document_even_if_state_equals_defaults(self):
        # Dokumen belum ada dan operator menyalakan sesuatu yang berbeda dari bawaan: menulis.
        writes = self._run(ota.cmd_intro, "on", existing=None)
        self.assertEqual(len(writes), 1)
        payload = writes[0][0][1]
        self.assertEqual(payload["introduction_enabled"], {"booleanValue": True})

    def test_writes_preserve_the_other_setting(self):
        existing = {
            "soon_sub_agent_ids": {"arrayValue": {"values": [{"stringValue": "fiqh_tahawwulat_habib"}]}},
            "introduction_enabled": {"booleanValue": True},
        }
        writes = self._run(ota.cmd_release_sub_agent, "fiqh_tahawwulat_habib", existing=existing)
        payload = writes[0][0][1]
        self.assertEqual(payload["introduction_enabled"], {"booleanValue": True}, "Mengenal tidak boleh ikut berubah")
        self.assertEqual(payload["soon_sub_agent_ids"]["arrayValue"]["values"], [])


SHA_A, SHA_B = "a" * 64, "b" * 64
APK = "https://openturath.web.app/app-release-latest.apk"
DMG = "https://openturath.web.app/OpenTurath_AI_macOS.dmg"


def release_doc(**over):
    doc = {
        "latest_version": "1.0.82", "latest_version_code": 83, "apk_url": APK, "sha256": SHA_A,
        "platforms": {"macos": {"url": DMG, "build": 83, "version": "1.0.82", "sha256": SHA_A}},
    }
    doc.update(over)
    return doc


class ExtractReleaseTest(unittest.TestCase):
    def test_android_reads_flat_fields_when_no_platform_block(self):
        r = ota.extract_release(release_doc(), "android")
        self.assertEqual((r["build"], r["version"], r["url"]), (83, "1.0.82", APK))

    def test_macos_reads_platform_block_and_is_not_inherited_from_android(self):
        self.assertEqual(ota.extract_release(release_doc(), "macos")["url"], DMG)
        doc = release_doc()
        del doc["platforms"]
        self.assertIsNone(ota.extract_release(doc, "macos"), "desktop tidak boleh mewarisi data Android")

    def test_unparseable_or_incomplete_returns_none(self):
        for bad in ({"latest_version_code": "x"}, {"latest_version_code": 0}, {"latest_version_code": -3},
                    {"apk_url": 5}, {"latest_version": ""}):
            self.assertIsNone(ota.extract_release(release_doc(**bad), "android"), bad)


class CheckEntryTest(unittest.TestCase):
    def release(self, **over):
        base = {"build": 90, "version": "1.0.9", "url": APK, "sha256": SHA_A}
        base.update(over)
        return base

    def test_clean_release_has_no_problems(self):
        self.assertEqual(ota.check_release_entry("android", self.release(), 83), [])

    def test_older_build_than_the_app_is_flagged(self):
        p = ota.check_release_entry("android", self.release(build=52), 83)
        self.assertTrue(any("LAMA" in x for x in p), p)

    def test_same_build_is_not_flagged(self):
        self.assertEqual(ota.check_release_entry("android", self.release(build=83), 83), [])

    def test_unknown_host_scheme_extension_are_flagged(self):
        self.assertTrue(ota.check_release_entry("android", self.release(url="http://openturath.web.app/a.apk"), 1))
        self.assertTrue(ota.check_release_entry("android", self.release(url="https://evil.example/a.apk"), 1))
        self.assertTrue(ota.check_release_entry("android", self.release(url="https://openturath.web.app/a.exe"), 1))
        self.assertTrue(ota.check_release_entry("android", self.release(url="https://openturath.web.app:8443/a.apk"), 1))
        self.assertTrue(ota.check_release_entry("android", self.release(url="https://u:p@openturath.web.app/a.apk"), 1))

    def test_android_requires_a_valid_sha256_but_desktop_does_not(self):
        for bad in (None, "", "abc", "z" * 64):
            self.assertTrue(ota.check_release_entry("android", self.release(sha256=bad), 1), bad)
        self.assertEqual(ota.check_release_entry("macos", self.release(url=DMG, sha256=None), 1), [])
        self.assertTrue(ota.check_release_entry("macos", self.release(url=DMG, sha256="abc"), 1))

    def test_missing_release_is_reported(self):
        self.assertTrue(ota.check_release_entry("android", None, 1))


class VerifyReportTest(unittest.TestCase):
    ok_probe = staticmethod(lambda url: (200, 1000, "application/octet-stream"))

    def status_of(self, report):
        return {p: s for p, s, _ in report}

    def test_everything_good_passes_and_windows_is_skipped(self):
        report = ota.verify_release_report(release_doc(), 83, probe=self.ok_probe)
        self.assertEqual(self.status_of(report), {"android": "OK", "macos": "OK", "windows": "LEWAT"})

    def test_404_is_reported_as_failure(self):
        def probe(url):
            return (404, None, "text/html") if url == DMG else (200, 10, "application/vnd.android.package-archive")
        status = self.status_of(ota.verify_release_report(release_doc(), 83, probe=probe))
        self.assertEqual(status["macos"], "GAGAL")
        self.assertEqual(status["android"], "OK")

    def test_html_masquerading_as_200_is_caught(self):
        status = self.status_of(ota.verify_release_report(
            release_doc(), 83, probe=lambda u: (200, 512, "text/html; charset=utf-8")))
        self.assertEqual(status["android"], "GAGAL")

    def test_network_failure_is_a_failure_not_a_crash(self):
        status = self.status_of(ota.verify_release_report(
            release_doc(), 83, probe=lambda u: (None, None, "Temporary failure in name resolution")))
        self.assertEqual(status["android"], "GAGAL")

    def test_old_build_in_document_fails_even_when_the_file_exists(self):
        doc = release_doc(latest_version_code=52)
        status = self.status_of(ota.verify_release_report(doc, 83, probe=self.ok_probe))
        self.assertEqual(status["android"], "GAGAL")

    def test_deep_check_catches_a_hash_mismatch(self):
        report = ota.verify_release_report(
            release_doc(), 83, probe=self.ok_probe, deep=True, hasher=lambda url: (SHA_B, 1000))
        android = dict((p, (s, l)) for p, s, l in report)["android"]
        self.assertEqual(android[0], "GAGAL")
        self.assertTrue(any("TIDAK cocok" in x for x in android[1]), android[1])

    def test_deep_check_passes_when_hash_matches(self):
        report = ota.verify_release_report(
            release_doc(), 83, probe=self.ok_probe, deep=True, hasher=lambda url: (SHA_A, 1000))
        android = dict((p, (s, l)) for p, s, l in report)["android"]
        self.assertEqual(android[0], "OK")
        self.assertTrue(any("cocok" in x for x in android[1]))

    def test_deep_check_is_skipped_unless_requested(self):
        called = []
        ota.verify_release_report(release_doc(), 83, probe=self.ok_probe,
                                  hasher=lambda u: called.append(u) or (SHA_A, 1))
        self.assertEqual(called, [], "tanpa --deep tidak boleh mengunduh apa pun")

    def test_hasher_error_is_reported_not_raised(self):
        def boom(url):
            raise OSError("koneksi terputus")
        status = self.status_of(ota.verify_release_report(
            release_doc(), 83, probe=self.ok_probe, deep=True, hasher=boom))
        self.assertEqual(status["android"], "GAGAL")

    def test_verification_never_writes(self):
        with mock.patch.object(ota, "rest_patch") as patch_:
            ota.verify_release_report(release_doc(), 83, probe=self.ok_probe)
        patch_.assert_not_called()


if __name__ == "__main__":
    unittest.main(verbosity=2)
