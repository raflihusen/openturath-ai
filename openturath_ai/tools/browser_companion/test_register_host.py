"""Installation fixtures use temporary homes; no real registration or accounts."""
import json
import os
from pathlib import Path
import shutil
import stat
import struct
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock

import register_host as installer

AUDITED_HOST = Path(__file__).with_name("native_host.py")


class PrivateHostInstallTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="openturath-install-fixture-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.home = self.root / "home"
        self.home.mkdir(mode=0o700)
        self.source = self.root / "checkout"
        self.source.mkdir(mode=0o700)
        self.source_host = self.source / "native_host.py"
        self.source_bytes = AUDITED_HOST.read_bytes()
        self.source_host.write_bytes(self.source_bytes)
        self.source_host.chmod(0o644)
        self.addCleanup(mock.patch.stopall)
        mock.patch.object(installer, "__file__", str(self.source / "register_host.py")).start()
        mock.patch.object(installer.sys, "platform", "darwin").start()
        self.private = self.home / "Library/Application Support/OpenTurath/Companion"
        self.registry = self.home / "Library/Application Support/Google/Chrome/NativeMessagingHosts"

    def install(self):
        return installer.install(self.home)

    def prepare_targets(self):
        self.private.mkdir(mode=0o700, parents=True)
        self.registry.mkdir(mode=0o700, parents=True)
        return (self.private / "native_host.py", self.private / "host-entry.sh",
                self.registry / (installer.HOST + ".json"))

    def assert_rejected(self):
        with self.assertRaises((RuntimeError, OSError)):
            self.install()

    def test_exact_private_copy_modes_and_pinned_manifest(self):
        manifest, wrapper = self.install()
        installed = self.private / "native_host.py"
        self.assertEqual(installed.read_bytes(), self.source_bytes)
        for path, mode in ((self.private, 0o700), (installed, 0o700), (wrapper, 0o700), (manifest, 0o600)):
            self.assertEqual(stat.S_IMODE(path.stat().st_mode), mode)
            self.assertEqual(path.stat().st_uid, os.getuid())
        for path in (installed, wrapper, manifest):
            self.assertEqual(path.stat().st_nlink, 1)
        registration = json.loads(manifest.read_text())
        self.assertEqual(registration, {
            "name": installer.HOST, "description": "OpenTurath personal browser companion",
            "path": str(wrapper), "type": "stdio",
            "allowed_origins": ["chrome-extension://hbbeklipfbgookgdmkmodkanoflegbok/"]})
        self.assertIn(str(installed), wrapper.read_text())
        self.assertNotIn(str(self.source), wrapper.read_text())
        self.assertFalse((self.private / "runtime.json").exists())

    def test_launcher_runs_private_copy_after_checkout_removed(self):
        _, wrapper = self.install()
        shutil.rmtree(self.source)
        probe = subprocess.run([str(wrapper), "chrome-extension://wrong-origin/"],
                               input=b"", capture_output=True, timeout=5, check=False)
        self.assertEqual(probe.returncode, 2)
        self.assertEqual(probe.stderr, b"")
        size = struct.unpack("<I", probe.stdout[:4])[0]
        self.assertEqual(len(probe.stdout), size + 4)
        self.assertEqual(json.loads(probe.stdout[4:]), {
            "type": "state", "status": "disconnected", "code": "invalid-caller"})

    def test_reinstall_refreshes_exact_copy_and_repairs_modes(self):
        manifest, wrapper = self.install()
        changed = self.source_bytes + b"\n# Fixture-only source revision.\n"
        self.source_host.write_bytes(changed)
        self.private.chmod(0o755)
        wrapper.chmod(0o644)
        manifest.chmod(0o644)
        self.install()
        self.assertEqual((self.private / "native_host.py").read_bytes(), changed)
        self.assertEqual(stat.S_IMODE(self.private.stat().st_mode), 0o700)
        self.assertEqual(stat.S_IMODE(wrapper.stat().st_mode), 0o700)
        self.assertEqual(stat.S_IMODE(manifest.stat().st_mode), 0o600)

    def test_linux_paths(self):
        with mock.patch.object(installer.sys, "platform", "linux"):
            manifest, wrapper = self.install()
        self.assertEqual(wrapper, self.home / ".local/share/OpenTurath/Companion/host-entry.sh")
        self.assertEqual(manifest, self.home / ".config/google-chrome/NativeMessagingHosts" / (installer.HOST + ".json"))
        self.assertEqual(wrapper.with_name("native_host.py").read_bytes(), self.source_bytes)

    def test_windows_fails_closed_before_installation(self):
        with mock.patch.object(installer.sys, "platform", "win32"):
            self.assert_rejected()
        self.assertEqual(list(self.home.iterdir()), [])

    def test_source_symlink_rejected(self):
        real = self.source_host.with_suffix(".real")
        self.source_host.rename(real)
        self.source_host.symlink_to(real)
        self.assert_rejected()
        self.assertEqual(list(self.home.iterdir()), [])

    def test_source_hardlink_rejected(self):
        os.link(self.source_host, self.source / "second-copy.py")
        self.assert_rejected()
        self.assertEqual(list(self.home.iterdir()), [])

    def test_source_wrong_owner_rejected(self):
        real_fstat = installer.os.fstat
        def other_owner(descriptor):
            info = real_fstat(descriptor)
            if stat.S_ISREG(info.st_mode):
                return SimpleNamespace(st_mode=info.st_mode, st_uid=os.getuid() + 1,
                                       st_nlink=info.st_nlink, st_size=info.st_size)
            return info
        with mock.patch.object(installer.os, "fstat", side_effect=other_owner):
            self.assert_rejected()
        self.assertEqual(list(self.home.iterdir()), [])

    def test_source_directory_rejected(self):
        self.source_host.unlink()
        self.source_host.mkdir()
        self.assert_rejected()

    def test_source_fifo_rejected_without_blocking(self):
        self.source_host.unlink()
        os.mkfifo(self.source_host, 0o600)
        self.assert_rejected()

    def test_writable_source_rejected(self):
        self.source_host.chmod(0o666)
        self.assert_rejected()

    def test_oversized_source_rejected(self):
        self.source_host.write_bytes(b"x" * (installer.MAX_HOST_SOURCE + 1))
        self.assert_rejected()

    def test_empty_source_rejected(self):
        self.source_host.write_bytes(b"")
        self.assert_rejected()

    def test_target_symlinks_rejected_without_overwrite(self):
        targets = self.prepare_targets()
        victim = self.root / "victim"
        victim.write_text("preserve")
        for target in targets:
            with self.subTest(target=target.name):
                target.symlink_to(victim)
                self.assert_rejected()
                self.assertEqual(victim.read_text(), "preserve")
                self.assertTrue(target.is_symlink())
                self.assertFalse(any(other.exists() for other in targets if other != target))
                target.unlink()

    def test_target_hardlinks_rejected_without_overwrite(self):
        targets = self.prepare_targets()
        victim = self.root / "victim"
        victim.write_text("preserve")
        for target in targets:
            with self.subTest(target=target.name):
                os.link(victim, target)
                self.assert_rejected()
                self.assertEqual(victim.read_text(), "preserve")
                self.assertFalse(any(other.exists() for other in targets if other != target))
                target.unlink()

    def test_target_directories_rejected(self):
        targets = self.prepare_targets()
        for target in targets:
            with self.subTest(target=target.name):
                target.mkdir()
                self.assert_rejected()
                self.assertFalse(any(other.exists() for other in targets if other != target))
                target.rmdir()

    def test_target_wrong_owner_rejected(self):
        targets = self.prepare_targets()
        targets[0].write_text("preserve")
        real_stat = installer.os.stat
        def other_owner(path, *args, **kwargs):
            info = real_stat(path, *args, **kwargs)
            if path == "native_host.py" and "dir_fd" in kwargs:
                return SimpleNamespace(st_mode=info.st_mode, st_uid=os.getuid() + 1,
                                       st_nlink=info.st_nlink)
            return info
        with mock.patch.object(installer.os, "stat", side_effect=other_owner):
            self.assert_rejected()
        self.assertEqual(targets[0].read_text(), "preserve")
        self.assertFalse(targets[1].exists())
        self.assertFalse(targets[2].exists())

    def test_symlink_directory_component_rejected(self):
        outside = self.root / "outside"
        outside.mkdir()
        (self.home / "Library").symlink_to(outside, target_is_directory=True)
        self.assert_rejected()
        self.assertEqual(list(outside.iterdir()), [])

    def test_symlink_home_rejected(self):
        linked = self.root / "linked-home"
        linked.symlink_to(self.home, target_is_directory=True)
        with self.assertRaises(OSError):
            installer.install(linked)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_directory_wrong_owner_rejected(self):
        with mock.patch.object(installer.os, "getuid", return_value=os.getuid() + 1):
            self.assert_rejected()
        self.assertEqual(list(self.home.iterdir()), [])

    def test_temporary_write_failure_keeps_previous_target_and_cleans_up(self):
        self.install()
        before = (self.private / "native_host.py").read_bytes()
        self.source_host.write_bytes(self.source_bytes + b"\n# Fixture revision.\n")
        with mock.patch.object(installer.os, "fsync", side_effect=OSError("fixture write failure")):
            self.assert_rejected()
        self.assertEqual((self.private / "native_host.py").read_bytes(), before)
        self.assertEqual({path.name for path in self.private.iterdir()}, {"native_host.py", "host-entry.sh"})


if __name__ == "__main__":
    unittest.main()
