import os
import unittest
from writer_guard import assert_legacy_writes_allowed, LegacyWriterBlocked


class WriterGuardTest(unittest.TestCase):
    def setUp(self):
        os.environ.pop("OPENTURATH_LEGACY_WRITE_OVERRIDE", None)

    def test_blocks_when_vps_writer_active(self):
        with self.assertRaises(LegacyWriterBlocked):
            assert_legacy_writes_allowed(lambda: {"writer": "vps-v2"})

    def test_allows_before_cutover(self):
        assert_legacy_writes_allowed(lambda: {"writer": "legacy"})

    def test_fails_closed_when_unreadable(self):
        def boom():
            raise OSError("no network")
        with self.assertRaises(LegacyWriterBlocked):
            assert_legacy_writes_allowed(boom)

    def test_explicit_override_allows(self):
        os.environ["OPENTURATH_LEGACY_WRITE_OVERRIDE"] = "1"
        assert_legacy_writes_allowed(lambda: {"writer": "vps-v2"})


if __name__ == "__main__":
    unittest.main()
