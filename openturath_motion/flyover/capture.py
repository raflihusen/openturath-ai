#!/usr/bin/env python3
"""Tangkap halaman landing OpenTurath menjadi satu tekstur halaman + potongan (layer) yang akan terangkat."""
import json, sys
from playwright.sync_api import sync_playwright
URL = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:4180/id/index.html?theme=light&nofx=1"
OUT = "assets"
KEEP = [0, 1, 2, 4, 9, 10]  # hero, masalah, contoh nyata, angka, pendiri, unduh
LAYERS = [
    ("hero-mark", ".hero-mark", "tile", 1),
    ("hero-btn", ".welcome .cta-row .btn.primary", "button", 1),
    ("hero-chip", ".welcome .meta-row span", "chip", 3),
    ("trio", ".trio3 > div", "card", 3),
    ("answer", ".answer", "card", 1),
    ("answer-chip", ".answer li", "chip", 3),
    ("q-box", ".q1 .qbox", "photo", 1),
    ("q-refs", ".q1 .refs", "photo", 1),
    ("stat", ".stats .stat", "card", 5),
    ("founder-chip", ".founder .chip.big", "chip", 1),
    ("founder", ".founder", "testimonial", 1),
    ("dl-btn", "#unduh .btn.inv", "button", 1),
]
with sync_playwright() as p:
    b = p.chromium.launch(channel="chrome", headless=True)
    pg = b.new_page(viewport={"width": 1440, "height": 900}, device_scale_factor=2)
    pg.goto(URL)
    pg.wait_for_timeout(1200)
    pg.add_style_tag(content="*{animation:none!important;transition:none!important;scroll-behavior:auto!important}.rv{opacity:1!important;transform:none!important;filter:none!important}.progress{display:none!important}header.site{position:relative!important}")
    pg.evaluate("""(keep)=>{const secs=[...document.querySelectorAll('main > section')];secs.forEach((s,i)=>{if(!keep.includes(i))s.style.display='none'});document.querySelectorAll('.rv').forEach(e=>e.classList.add('in'));}""", KEEP)
    pg.evaluate("window.scrollTo(0, document.documentElement.scrollHeight)"); pg.wait_for_timeout(600)
    pg.evaluate("window.scrollTo(0,0)"); pg.wait_for_timeout(600)
    H = pg.evaluate("document.documentElement.scrollHeight")
    print("tinggi halaman", H)
    # tandai lapisan
    meta = []
    pg.evaluate("""(L)=>{L.forEach(([id,sel,kind,n])=>{[...document.querySelectorAll(sel)].slice(0,n).forEach((e,i)=>{e.setAttribute('data-layer',id+'-'+i);e.setAttribute('data-kind',kind)})})}""", LAYERS)
    layers = pg.evaluate("""()=>[...document.querySelectorAll('[data-layer]')].map(e=>{const r=e.getBoundingClientRect();const cs=getComputedStyle(e);return {id:e.dataset.layer,kind:e.dataset.kind,x:r.left+scrollX,y:r.top+scrollY,w:r.width,h:r.height,radius:parseFloat(cs.borderTopLeftRadius)||0}})""")
    # halaman tanpa lapisan
    pg.add_style_tag(content="[data-layer], [data-layer] *{visibility:hidden!important}")
    pg.screenshot(path=f"{OUT}/page.png", full_page=True)
    hero = pg.evaluate("(()=>{const r=document.querySelector('.welcome').getBoundingClientRect();return {y:r.top+scrollY,h:r.height}})()")
    # tiap lapisan sendirian
    pg.add_style_tag(content="html.iso, html.iso body{background:transparent!important}html.iso *{visibility:hidden!important;background-image:none}html.iso .iso-on, html.iso .iso-on *{visibility:visible!important}")
    pg.evaluate("document.documentElement.classList.add('iso')")
    PAD = 28
    for l in layers:
        pg.evaluate("(id)=>{document.querySelectorAll('.iso-on').forEach(e=>e.classList.remove('iso-on'));const e=document.querySelector(`[data-layer=\"${id}\"]`);e.classList.add('iso-on');}", l["id"])
        pg.add_style_tag(content="[data-layer].iso-on, [data-layer].iso-on *{visibility:visible!important}")
        clip = {"x": max(0, l["x"] - PAD), "y": max(0, l["y"] - PAD), "width": l["w"] + 2 * PAD, "height": l["h"] + 2 * PAD}
        if clip["x"] + clip["width"] > 1440: clip["width"] = 1440 - clip["x"]
        pg.screenshot(path=f"{OUT}/layer_{l['id']}.png", clip=clip, omit_background=True, full_page=True)
        l["pad"] = PAD; l["cx"] = clip["x"]; l["cy"] = clip["y"]; l["cw"] = clip["width"]; l["ch"] = clip["height"]
    json.dump({"height": H, "width": 1440, "hero": hero, "layers": layers}, open(f"{OUT}/layers.json", "w"), indent=1)
    print(len(layers), "lapisan")
    b.close()
