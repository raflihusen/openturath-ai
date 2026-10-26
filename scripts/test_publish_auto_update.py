"""Tes publish_auto_update.py: siaran versi Android tidak boleh menghapus bidang lain.

Tidak menyentuh jaringan atau Firestore. Jalankan: python3 scripts/test_publish_auto_update.py
"""
import json
import sys
import unittest
from pathlib import Path
from unittest import mock
from urllib.parse import parse_qs, urlparse

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import publish_auto_update as pub  # noqa: E402


class Resp:
    def __enter__(self):
        return self

    def __exit__(self, *a):
        return False

    def read(self):
        return b"{}"


def broadcast():
    sent = {}

    def fake_urlopen(req):
        sent["url"] = req.full_url
        sent["method"] = req.get_method()
        sent["body"] = json.loads(req.data.decode("utf-8"))
        return Resp()

    with mock.patch.object(pub, "get_google_access_token", lambda: "token"), \
            mock.patch.object(pub.urllib.request, "urlopen", fake_urlopen), \
            mock.patch("builtins.print"):
        ok = pub.update_firestore_version("1.0.99", 99, "https://openturath.web.app/app-release-latest.apk",
                                          "a" * 64, "catatan")
    return ok, sent


class BroadcastMaskTest(unittest.TestCase):
    def test_request_is_patch_with_update_mask(self):
        ok, sent = broadcast()
        self.assertTrue(ok)
        self.assertEqual(sent["method"], "PATCH")
        self.assertIn("updateMask.fieldPaths=", sent["url"])

    def test_mask_covers_exactly_the_android_fields_written(self):
        _, sent = broadcast()
        masked = set(parse_qs(urlparse(sent["url"]).query)["updateMask.fieldPaths"])
        written = set(sent["body"]["fields"])
        # Setiap bidang yang ditulis harus ada di mask (kalau tidak, diabaikan diam-diam)
        # dan tidak ada bidang di mask yang tidak ditulis (kalau tidak, ikut dihapus).
        self.assertEqual(masked, written)
        self.assertEqual(masked, set(pub.ANDROID_VERSION_FIELDS))

    def test_platform_blocks_are_never_written_or_masked(self):
        _, sent = broadcast()
        masked = set(parse_qs(urlparse(sent["url"]).query)["updateMask.fieldPaths"])
        for key in ("platforms", "platforms.macos", "platforms.windows", "macos", "windows"):
            self.assertNotIn(key, masked)
            self.assertNotIn(key, sent["body"]["fields"])

    def test_targets_the_version_document(self):
        _, sent = broadcast()
        self.assertTrue(urlparse(sent["url"]).path.endswith("/app_config/version"))

    def test_values_are_sent_with_correct_firestore_types(self):
        _, sent = broadcast()
        f = sent["body"]["fields"]
        self.assertEqual(f["latest_version"], {"stringValue": "1.0.99"})
        self.assertEqual(f["latest_version_code"], {"integerValue": "99"})
        self.assertEqual(f["sha256"], {"stringValue": "a" * 64})

    def test_no_token_means_no_request(self):
        with mock.patch.object(pub, "get_google_access_token", lambda: None), \
                mock.patch.object(pub.urllib.request, "urlopen") as urlopen, \
                mock.patch("builtins.print"):
            ok = pub.update_firestore_version("1.0.99", 99, "u", "a" * 64, "n")
        self.assertFalse(ok)
        urlopen.assert_not_called()


if __name__ == "__main__":
    unittest.main(verbosity=2)
