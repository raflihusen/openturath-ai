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


class EditionTests(unittest.TestCase):
    def test_versioned_names_never_collide_between_editions(self):
        self.assertEqual(pub.versioned_apk_name("standard", 85), "OpenTurath_v85.apk")
        self.assertEqual(pub.versioned_apk_name("guru", 85), "OpenTurath_Guru_v85.apk")
        self.assertEqual(pub.versioned_apk_url("standard", 85), "https://openturath.web.app/OpenTurath_v85.apk")

    def test_guru_payload_only_touches_editions_guru(self):
        payload, mask = pub.build_firestore_payload("guru", "1.0.99", 99, "u", "a" * 64, "n", "t")
        self.assertEqual(mask, ["editions.guru"])
        self.assertEqual(list(payload["fields"]), ["editions"])
        guru = payload["fields"]["editions"]["mapValue"]["fields"]["guru"]["mapValue"]["fields"]
        self.assertEqual(guru["build"], {"integerValue": "99"})
        self.assertEqual(guru["url"], {"stringValue": "u"})

    def test_standard_payload_never_includes_editions(self):
        payload, mask = pub.build_firestore_payload("standard", "1.0.99", 99, "u", "a" * 64, "n", "t")
        self.assertNotIn("editions", payload["fields"])
        self.assertEqual(tuple(mask), pub.ANDROID_VERSION_FIELDS)

    def test_guru_broadcast_sends_only_guru_mask(self):
        with mock.patch.object(pub, "get_google_access_token", lambda: "tok"), \
                mock.patch.object(pub.urllib.request, "urlopen") as urlopen, \
                mock.patch("builtins.print"):
            urlopen.return_value.__enter__.return_value.read.return_value = b"{}"
            ok = pub.update_firestore_version("1.0.99", 99, "https://x.test/a.apk", "a" * 64, "n", edition="guru")
        self.assertTrue(ok)
        req = urlopen.call_args[0][0]
        self.assertEqual(parse_qs(urlparse(req.full_url).query)["updateMask.fieldPaths"], ["editions.guru"])


class LiveCheckTests(unittest.TestCase):
    def _resp(self, status=200, ctype="application/vnd.android.package-archive", length="10"):
        r = mock.MagicMock()
        r.status = status
        r.headers = {"Content-Type": ctype, "Content-Length": length}
        cm = mock.MagicMock()
        cm.__enter__.return_value = r
        return cm

    def test_ok(self):
        with mock.patch.object(pub.urllib.request, "urlopen", return_value=self._resp()):
            self.assertTrue(pub.verify_live_file("https://x.test/a.apk", 10)[0])

    def test_html_fallback_is_rejected(self):
        with mock.patch.object(pub.urllib.request, "urlopen", return_value=self._resp(ctype="text/html")):
            self.assertFalse(pub.verify_live_file("https://x.test/a.apk", 10)[0])

    def test_size_mismatch_is_rejected(self):
        with mock.patch.object(pub.urllib.request, "urlopen", return_value=self._resp(length="11")):
            self.assertFalse(pub.verify_live_file("https://x.test/a.apk", 10)[0])

    def test_network_error_is_rejected(self):
        with mock.patch.object(pub.urllib.request, "urlopen", side_effect=OSError("down")):
            self.assertFalse(pub.verify_live_file("https://x.test/a.apk", 10)[0])




class ReleaseEvidenceTests(unittest.TestCase):
    def test_badging_parsed(self):
        out = "package: name='id.x' versionCode='86' versionName='1.0.85' platformBuildVersionName='15'"
        self.assertEqual(pub.parse_badging(out), (86, '1.0.85'))
        self.assertEqual(pub.parse_badging('kosong'), (None, None))

    def test_embedded_version_mismatch_is_rejected(self):
        with mock.patch.object(pub, 'embedded_apk_version', lambda p: (85, '1.0.84')):
            self.assertIn('berbeda', pub.check_embedded_version('x.apk', '1.0.85', 86))
        with mock.patch.object(pub, 'embedded_apk_version', lambda p: (86, '1.0.85')):
            self.assertIsNone(pub.check_embedded_version('x.apk', '1.0.85', 86))
        with mock.patch.object(pub, 'embedded_apk_version', lambda p: (None, None)):
            self.assertIsNone(pub.check_embedded_version('x.apk', '1.0.85', 86))

    def test_versioned_file_is_never_overwritten_with_other_content(self):
        import tempfile
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / 'OpenTurath_v86.apk'
            path.write_bytes(b'lama')
            same = pub.compute_sha256(str(path))
            self.assertIsNone(pub.refuse_overwrite(str(path), same))
            self.assertIn('Naikkan build', pub.refuse_overwrite(str(path), 'b' * 64))
            self.assertIsNone(pub.refuse_overwrite(str(Path(d) / 'baru.apk'), same))

    def test_live_hash_compared(self):
        import hashlib
        body = b'apk-bytes'

        class R(Resp):
            def __init__(self):
                self.d = body

            def read(self, n=-1):
                out, self.d = self.d, b''
                return out

        with mock.patch.object(pub.urllib.request, 'urlopen', lambda *a, **k: R()):
            self.assertTrue(pub.verify_live_hash('https://x/y.apk', hashlib.sha256(body).hexdigest())[0])
            self.assertFalse(pub.verify_live_hash('https://x/y.apk', 'c' * 64)[0])


if __name__ == "__main__":
    unittest.main(verbosity=2)
