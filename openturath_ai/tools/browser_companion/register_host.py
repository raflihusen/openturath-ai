#!/usr/bin/env python3
"""Register the local pilot host with Chrome; never touches browser profile data."""
import argparse
import json
import os
from pathlib import Path
import shlex
import stat
import sys

HOST = "com.openturath.browser_companion"
EXTENSION = "hbbeklipfbgookgdmkmodkanoflegbok"

def install(home=None):
    home = Path(home or Path.home())
    if sys.platform == "darwin":
        private = home / "Library/Application Support/OpenTurath/Companion"
        registry = home / "Library/Application Support/Google/Chrome/NativeMessagingHosts"
    elif sys.platform.startswith("linux"):
        private = home / ".local/share/OpenTurath/Companion"
        registry = home / ".config/google-chrome/NativeMessagingHosts"
    else:
        raise RuntimeError("Windows requires a packaged native host and verified private ACLs.")
    host_script = Path(__file__).resolve().with_name("native_host.py")
    if not host_script.is_file():
        raise RuntimeError("Native host source missing.")
    for directory in (private, registry):
        if directory.is_symlink():
            raise RuntimeError("Refusing a symlink installation directory.")
        directory.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(private, 0o700)
    wrapper = private / "host-entry.sh"
    manifest = registry / (HOST + ".json")
    for target in (wrapper, manifest):
        if target.is_symlink():
            raise RuntimeError("Refusing a symlink installation target.")
        if target.exists() and (target.stat().st_uid != os.getuid() or target.stat().st_nlink != 1):
            raise RuntimeError("Unsafe existing installation target.")
    wrapper.write_text("#!/bin/sh\nexec " + shlex.quote(sys.executable) + " " +
                       shlex.quote(str(host_script)) + ' "$@"\n', encoding="utf-8")
    os.chmod(wrapper, 0o700)
    manifest.write_text(json.dumps({
        "name": HOST, "description": "OpenTurath personal browser companion",
        "path": str(wrapper), "type": "stdio",
        "allowed_origins": ["chrome-extension://" + EXTENSION + "/"]
    }, indent=2) + "\n", encoding="utf-8")
    os.chmod(manifest, 0o600)
    return manifest, wrapper

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

