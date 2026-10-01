#!/usr/bin/env python3
"""Register a private copy of the pilot host; never touches browser profile data."""
import argparse
import json
import os
from pathlib import Path
import secrets
import shlex
import stat
import sys

HOST = "com.openturath.browser_companion"
EXTENSION = "hbbeklipfbgookgdmkmodkanoflegbok"
MAX_HOST_SOURCE = 1024 * 1024


def _owned_directory(path):
    descriptor = os.open(path, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    info = os.fstat(descriptor)
    if not stat.S_ISDIR(info.st_mode) or info.st_uid != os.getuid():
        os.close(descriptor)
        raise RuntimeError("Unsafe installation directory ownership.")
    return descriptor


def _directory_tree(home, components):
    """Anchor operations to owned directories, refusing symlink components."""
    descriptor = _owned_directory(home)
    try:
        for component in components:
            try:
                os.mkdir(component, mode=0o700, dir_fd=descriptor)
            except FileExistsError:
                pass
            child = os.open(component, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                            dir_fd=descriptor)
            info = os.fstat(child)
            if not stat.S_ISDIR(info.st_mode) or info.st_uid != os.getuid():
                os.close(child)
                raise RuntimeError("Unsafe installation directory ownership.")
            os.close(descriptor)
            descriptor = child
        return descriptor
    except BaseException:
        os.close(descriptor)
        raise


def _check_target(directory, name):
    try:
        info = os.stat(name, dir_fd=directory, follow_symlinks=False)
    except FileNotFoundError:
        return
    if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid()
            or info.st_nlink != 1):
        raise RuntimeError("Unsafe existing installation target.")


def _atomic_write(directory, name, data, mode):
    temporary = "." + name + "." + secrets.token_hex(16)
    try:
        descriptor = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
                             mode, dir_fd=directory)
        with os.fdopen(descriptor, "wb") as stream:
            os.fchmod(stream.fileno(), mode)
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        _check_target(directory, name)
        os.replace(temporary, name, src_dir_fd=directory, dst_dir_fd=directory)
    finally:
        try:
            os.unlink(temporary, dir_fd=directory)
        except FileNotFoundError:
            pass


def _host_source(path):
    directory = _owned_directory(path.parent)
    try:
        descriptor = os.open(path.name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK,
                             dir_fd=directory)
        with os.fdopen(descriptor, "rb") as stream:
            info = os.fstat(stream.fileno())
            if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid()
                    or info.st_nlink != 1 or info.st_mode & 0o022
                    or not 1 <= info.st_size <= MAX_HOST_SOURCE):
                raise RuntimeError("Unsafe native host source.")
            data = stream.read(MAX_HOST_SOURCE + 1)
            if not 1 <= len(data) <= MAX_HOST_SOURCE:
                raise RuntimeError("Unsafe native host source.")
            return data
    finally:
        os.close(directory)


def install(home=None):
    home = Path(home or Path.home()).absolute()
    if sys.platform == "darwin":
        private_parts = ("Library", "Application Support", "OpenTurath", "Companion")
        registry_parts = ("Library", "Application Support", "Google", "Chrome", "NativeMessagingHosts")
    elif sys.platform.startswith("linux"):
        private_parts = (".local", "share", "OpenTurath", "Companion")
        registry_parts = (".config", "google-chrome", "NativeMessagingHosts")
    else:
        raise RuntimeError("Windows requires a packaged native host and verified private ACLs.")
    # Read the audited source once. Launching Chrome later needs only this private copy.
    source = _host_source(Path(__file__).absolute().with_name("native_host.py"))
    if not sys.executable or not Path(sys.executable).is_absolute():
        raise RuntimeError("A persistent absolute Python interpreter path is required.")
    private = home.joinpath(*private_parts)
    registry = home.joinpath(*registry_parts)
    private_fd = _directory_tree(home, private_parts)
    try:
        registry_fd = _directory_tree(home, registry_parts)
        try:
            for directory, name in ((private_fd, "native_host.py"), (private_fd, "host-entry.sh"),
                                    (registry_fd, HOST + ".json")):
                _check_target(directory, name)
            os.fchmod(private_fd, 0o700)
            host_script = private / "native_host.py"
            wrapper = private / "host-entry.sh"
            manifest = registry / (HOST + ".json")
            launcher = ("#!/bin/sh\nexec " + shlex.quote(sys.executable) + " " +
                        shlex.quote(str(host_script)) + ' "$@"\n').encode("utf-8")
            registration = (json.dumps({
                "name": HOST, "description": "OpenTurath personal browser companion",
                "path": str(wrapper), "type": "stdio",
                "allowed_origins": ["chrome-extension://" + EXTENSION + "/"]
            }, indent=2) + "\n").encode("utf-8")
            _atomic_write(private_fd, "native_host.py", source, 0o700)
            _atomic_write(private_fd, "host-entry.sh", launcher, 0o700)
            _atomic_write(registry_fd, HOST + ".json", registration, 0o600)
            return manifest, wrapper
        finally:
            os.close(registry_fd)
    finally:
        os.close(private_fd)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--install", action="store_true", required=True)
    args = parser.parse_args()
    try:
        manifest, wrapper = install()
        print("Registered local Chrome host:", manifest)
        print("Launcher:", wrapper)
        print("Load the audited extension directory through Chrome Extensions for the local pilot.")
    except (OSError, RuntimeError) as error:
        print("Installation failed:", error, file=sys.stderr)
        sys.exit(1)
