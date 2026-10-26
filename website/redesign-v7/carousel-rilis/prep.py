"""Menyiapkan tangkapan layar aplikasi untuk mockup iPhone.
Status bar asli (jam, baterai, mode pesawat) dihapus dengan warna latar; status bar bersih digambar ulang oleh CSS.
Jalankan: python3 prep.py
"""
from pathlib import Path
from PIL import Image, ImageDraw

HERE = Path(__file__).parent
DL = Path("/Users/apple/Downloads")
OUT = HERE / "assets"
OUT.mkdir(exist_ok=True)

SRC = {
    "home": DL / "Screenshot_20261026-164559 (2).png",  # beranda (terang)
    "sub": DL / "Screenshot_20261026-042335.png",        # langganan: harga perdana (gelap)
}
BAR_H = 160  # tinggi area status bar pada tangkapan layar 1080x2404

for name, p in SRC.items():
    im = Image.open(p).convert("RGB")
    bg = im.getpixel((20, BAR_H + 8))
    d = ImageDraw.Draw(im)
    d.rectangle((0, 0, im.width, BAR_H), fill=bg)
    if name == "sub":  # tutup lencana status akun ("AKTIF") agar tampil netral untuk calon pengguna
        d.rectangle((640, 385, 830, 462), fill=im.getpixel((930, 420)))
    im.save(OUT / f"{name}.png", optimize=True)
    print(name, im.size, "bg", bg)
