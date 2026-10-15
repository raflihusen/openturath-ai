#!/usr/bin/env python3
"""Generate an offline SVG QR with a four-module quiet zone."""
import sys,html
from pathlib import Path
from vendor.qrencoder import QRCode
url,output=sys.argv[1:]
qr=QRCode(None,0) # error correction M
qr.addData(url);qr.make();n=qr.getModuleCount();size=n+8
rects=''.join(f'M{x+4},{y+4}h1v1h-1z' for y in range(n) for x in range(n) if qr.isDark(y,x))
Path(output).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {size} {size}" role="img"><title>{html.escape(url)}</title><path fill="#fff" d="M0 0h{size}v{size}H0z"/><path fill="#000" d="{rects}"/></svg>')
