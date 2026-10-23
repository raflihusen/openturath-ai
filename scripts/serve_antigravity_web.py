#!/usr/bin/env python3
"""
Local HTTP Server for OpenTurath Redesign Antigravity (v4).
Serves /Users/apple/Downloads/redesign-antigravity on port 8081 with threading,
proper MIME types for WOFF2/SVG, and no-cache headers.
"""

import http.server
import mimetypes
import os
import sys

DOC_ROOT = "/Users/apple/Downloads/redesign-antigravity"
PORT = 8081

mimetypes.add_type("font/woff2", ".woff2")
mimetypes.add_type("font/woff", ".woff")
mimetypes.add_type("image/svg+xml", ".svg")
mimetypes.add_type("application/manifest+json", ".webmanifest")
mimetypes.add_type("text/javascript", ".mjs")


class AntigravityWebHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DOC_ROOT, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate, max-age=0")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else PORT
    server_address = ("127.0.0.1", port)

    if not os.path.isdir(DOC_ROOT):
        print(f"Error: Direktori {DOC_ROOT} tidak ditemukan!", file=sys.stderr)
        sys.exit(1)

    httpd = http.server.ThreadingHTTPServer(server_address, AntigravityWebHandler)
    print(f"=== OpenTurath Redesign Antigravity Server Aktif ===")
    print(f"Direktori       : {DOC_ROOT}")
    print(f"URL Utama       : http://localhost:{port}/")
    print(f"V4 Standar      : http://localhost:{port}/v4/prototipe-v4.html")
    print(f"V4 Standalone   : http://localhost:{port}/v4/prototipe-v4-standalone.html")
    print(f"Tekan Ctrl+C untuk menghentikan server.\n")
    sys.stdout.flush()

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer dihentikan.")


if __name__ == "__main__":
    main()
