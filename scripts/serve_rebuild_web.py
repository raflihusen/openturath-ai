#!/usr/bin/env python3
"""
Local HTTP Server for OpenTurath Rebuild Web (rebuild-v1).
Serves /Users/apple/Downloads/rebuild-v1 with concurrent threading,
proper MIME types for WOFF2/SVG, custom 404 handler, and no-cache headers.
"""

import http.server
import mimetypes
import os
import sys

DOC_ROOT = "/Users/apple/Downloads/rebuild-v1"
PORT = 8080

mimetypes.add_type("font/woff2", ".woff2")
mimetypes.add_type("font/woff", ".woff")
mimetypes.add_type("image/svg+xml", ".svg")
mimetypes.add_type("application/manifest+json", ".webmanifest")
mimetypes.add_type("text/javascript", ".mjs")


class RebuildWebHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DOC_ROOT, **kwargs)

    def end_headers(self):
        # Mencegah browser caching agar iterasi desain langsung terlihat
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate, max-age=0")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

    def send_error(self, code, message=None, explain=None):
        if code == 404:
            custom_404 = os.path.join(DOC_ROOT, "404.html")
            if os.path.isfile(custom_404):
                self.send_response(404, "Not Found")
                self.send_header("Content-Type", "text/html; charset=utf-8")
                with open(custom_404, "rb") as f:
                    content = f.read()
                self.send_header("Content-Length", str(len(content)))
                self.end_headers()
                self.wfile.write(content)
                return
        super().send_error(code, message, explain)


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else PORT
    server_address = ("127.0.0.1", port)
    
    if not os.path.isdir(DOC_ROOT):
        print(f"Error: Direktori {DOC_ROOT} tidak ditemukan!", file=sys.stderr)
        sys.exit(1)

    httpd = http.server.ThreadingHTTPServer(server_address, RebuildWebHandler)
    print(f"=== OpenTurath Rebuild Web Server Aktif ===")
    print(f"Direktori  : {DOC_ROOT}")
    print(f"URL Lokal  : http://localhost:{port}/")
    print(f"Versi ID   : http://localhost:{port}/id/")
    print(f"Versi EN   : http://localhost:{port}/en/")
    print(f"Versi AR   : http://localhost:{port}/ar/")
    print(f"Workspace  : http://localhost:{port}/workspace/")
    print(f"Tekan Ctrl+C untuk menghentikan server.\n")
    sys.stdout.flush()

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer dihentikan.")


if __name__ == "__main__":
    main()
