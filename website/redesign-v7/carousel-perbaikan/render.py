"""Ekspor carousel.html menjadi PNG 1080x1350 (satu berkas per slide) ke folder out/.
Jalankan: python3 render.py
"""
from pathlib import Path
from playwright.sync_api import sync_playwright

HERE = Path(__file__).parent
OUT = HERE / "out"
OUT.mkdir(exist_ok=True)

with sync_playwright() as p:
    b = p.chromium.launch(executable_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
    pg = b.new_page(viewport={"width": 1200, "height": 1500}, device_scale_factor=1)
    pg.goto((HERE / "carousel.html").as_uri())
    pg.evaluate("document.fonts.ready")
    pg.wait_for_timeout(600)
    for i, el in enumerate(pg.query_selector_all(".slide"), 1):
        el.screenshot(path=str(OUT / f"slide-{i:02d}.png"))
        print("ok", i)
    b.close()
