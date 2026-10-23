"""Driver Playwright: still (--stills) atau render penuh (--full) film.html ke JPEG per frame."""
import argparse, base64, http.server, os, socketserver, sys, threading, time
from pathlib import Path
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parent.parent  # openturath_motion
PORT = 4191


class Q(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=str(ROOT), **k)

    def log_message(self, *a):
        pass


def serve():
    socketserver.TCPServer.allow_reuse_address = True
    s = socketserver.ThreadingTCPServer(("127.0.0.1", PORT), Q)
    threading.Thread(target=s.serve_forever, daemon=True).start()
    return s


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--stills", nargs="*", type=float)
    ap.add_argument("--full", action="store_true")
    ap.add_argument("--out", default=str(ROOT / "flyover" / "out"))
    ap.add_argument("--fps", type=int, default=60)
    ap.add_argument("--dur", type=float, default=14.5)
    ap.add_argument("--start", type=int, default=0)
    ap.add_argument("--end", type=int, default=None)
    ap.add_argument("--step", type=int, default=1)
    ap.add_argument("--q", type=float, default=0.93)
    a = ap.parse_args()
    out = Path(a.out); out.mkdir(parents=True, exist_ok=True)
    serve()
    with sync_playwright() as p:
        b = p.chromium.launch(channel="chrome", args=["--use-angle=metal", "--enable-gpu-rasterization", "--ignore-gpu-blocklist"])
        pg = b.new_page(viewport={"width": 1440, "height": 1152})
        pg.on("console", lambda m: print("console:", m.text, file=sys.stderr) if m.type in ("error", "warning") else None)
        pg.on("pageerror", lambda e: print("pageerror:", e, file=sys.stderr))
        pg.goto(f"http://127.0.0.1:{PORT}/flyover/film.html")
        pg.wait_for_function("window.ready===true", timeout=120000)
        def grab(t):
            d = pg.evaluate(f"window.renderFrame({t},{a.q})")
            return base64.b64decode(d.split(",", 1)[1])
        if a.stills is not None:
            for t in a.stills:
                t0 = time.time(); (out / f"still_{t:05.2f}.jpg").write_bytes(grab(t)); print(t, round(time.time() - t0, 2), "s")
        if a.full:
            n = int(round(a.dur * a.fps)); end = a.end or n
            t0 = time.time()
            for i in range(a.start, end, a.step):
                (out / f"f_{i:05d}.jpg").write_bytes(grab(i / a.fps))
                if i % 30 == 0: print(i, "/", n, round(time.time() - t0, 1), "s", flush=True)
        b.close()


main()
