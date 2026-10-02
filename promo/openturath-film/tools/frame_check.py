"""Numeric frame check (for reviewers without image input).

For each image: mean luminance, % of near-black, % of bright pixels, a coarse
luminance grid (rows x cols, 0-9) and Vision OCR lines.
Usage: python3 tools/frame_check.py img1.jpg [img2.jpg ...]
"""
import subprocess
import sys

import numpy as np
from PIL import Image

OCR = "/tmp/ocr"
for path in sys.argv[1:]:
    im = np.asarray(Image.open(path).convert("L"), dtype=np.float32)
    h, w = im.shape
    print(f"== {path} {w}x{h} mean={im.mean():.1f} black<12={np.mean(im < 12) * 100:.0f}% bright>200={np.mean(im > 200) * 100:.1f}%")
    rows, cols = (16, 9) if h > w else (9, 16)
    for r in range(rows):
        line = ""
        for c in range(cols):
            cell = im[r * h // rows:(r + 1) * h // rows, c * w // cols:(c + 1) * w // cols]
            line += str(min(9, int(cell.mean() / 256 * 10 * 1.6)))
        print("   " + line)
    out = subprocess.run([OCR, path], capture_output=True, text=True).stdout.strip()
    lines = [l for l in out.splitlines() if "| 0.30 |" not in l]
    print("\n".join("   ocr " + l for l in lines) or "   ocr (none)")
