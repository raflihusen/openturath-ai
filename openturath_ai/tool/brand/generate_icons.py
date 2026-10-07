#!/usr/bin/env python3
"""Buat ulang ikon aplikasi dari logo OpenTurath dengan koreksi optis.

Kotak pembatas logo sudah di tengah, tetapi titik beratnya lebih rendah
(lengkung runcing di atas, lebar di bawah). Skrip ini menaikkan logo sehingga
titik beratnya mendekati pusat pelat, lalu menulis ikon semua platform.

Jalankan dari folder openturath_ai:  python3 tool/brand/generate_icons.py
"""
import glob
import os
import re

from PIL import Image, ImageChops, ImageDraw

SVG = 'assets/images/OpenTurath_logo_transparent.svg'
INK = (16, 15, 14, 255)
PLATE = (246, 246, 243, 255)
OPTICAL = 0.75  # bagian selisih titik berat yang dikoreksi
SS = 4  # supersampling


def subpaths(d):
    tokens = re.findall(r'[MLCZ]|-?\d*\.?\d+', d)
    paths, current, i, cmd = [], [], 0, None
    pos = (0.0, 0.0)
    while i < len(tokens):
        t = tokens[i]
        if t in 'MLCZ':
            cmd = t
            i += 1
            if cmd == 'Z':
                if current:
                    paths.append(current)
                current = []
            continue
        if cmd == 'M':
            if current:
                paths.append(current)
            pos = (float(tokens[i]), float(tokens[i + 1]))
            current = [pos]
            i += 2
            cmd = 'L'
        elif cmd == 'L':
            pos = (float(tokens[i]), float(tokens[i + 1]))
            current.append(pos)
            i += 2
        elif cmd == 'C':
            p1 = (float(tokens[i]), float(tokens[i + 1]))
            p2 = (float(tokens[i + 2]), float(tokens[i + 3]))
            p3 = (float(tokens[i + 4]), float(tokens[i + 5]))
            for k in range(1, 13):
                u = k / 12
                a, b, c, e = (1 - u) ** 3, 3 * u * (1 - u) ** 2, 3 * u * u * (1 - u), u ** 3
                current.append((a * pos[0] + b * p1[0] + c * p2[0] + e * p3[0],
                                a * pos[1] + b * p1[1] + c * p2[1] + e * p3[1]))
            pos = p3
            i += 6
    if current:
        paths.append(current)
    return paths


def render_mark(size):
    """Mask logo (L) berukuran size×size pada viewBox 1024, aturan even-odd per path."""
    svg = open(SVG, encoding='utf-8').read()
    scale = size * SS / 1024
    total = Image.new('1', (size * SS, size * SS), 0)
    for d in re.findall(r'\sd="([^"]+)"', svg):
        shape = Image.new('1', total.size, 0)
        for sub in subpaths(d):
            layer = Image.new('1', total.size, 0)
            ImageDraw.Draw(layer).polygon([(x * scale, y * scale) for x, y in sub], fill=1)
            shape = ImageChops.logical_xor(shape, layer)
        total = ImageChops.logical_or(total, shape)
    return total.convert('L').resize((size, size), Image.LANCZOS)


def optical_offset(mask):
    """Selisih (titik berat − pusat kotak pembatas) sebagai pecahan tinggi kanvas."""
    w, h = mask.size
    box = mask.getbbox()
    px = mask.load()
    total = weighted = 0
    for y in range(box[1], box[3]):
        row = sum(px[x, y] for x in range(box[0], box[2], 2))
        total += row
        weighted += row * y
    return (weighted / total - (box[1] + box[3]) / 2) / h


def compose(size, plate_ratio=1.0, radius_ratio=0.0, mark_ratio=0.62, transparent=False, no_plate=False):
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0) if (transparent or no_plate) else PLATE)
    plate_px = round(size * (1.0 if no_plate else plate_ratio))
    origin = (size - plate_px) // 2
    if transparent and not no_plate:
        big = Image.new('L', (plate_px * SS, plate_px * SS), 0)
        ImageDraw.Draw(big).rounded_rectangle(
            [0, 0, plate_px * SS - 1, plate_px * SS - 1], radius=plate_px * SS * radius_ratio, fill=255)
        plate_mask = big.resize((plate_px, plate_px), Image.LANCZOS)
        canvas.paste(Image.new('RGBA', (plate_px, plate_px), PLATE), (origin, origin), plate_mask)
    mark_px = max(8, round(plate_px * mark_ratio / 0.657))  # 0.657 = rasio tinggi emblem baru
    mask = render_mark(mark_px)
    shift = round(optical_offset(mask) * mark_px * OPTICAL)
    x = (size - mark_px) // 2
    y = (size - mark_px) // 2 - shift
    canvas.paste(Image.new('RGBA', (mark_px, mark_px), INK), (x, y), mask)
    return canvas


def save(image, path, flatten=False):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if flatten:
        image = image.convert('RGB')
    image.save(path)
    print('wrote', path, image.size)


def main():
    # macOS: pelat squircle dengan margin sesuai kisi ikon macOS.
    for n in (16, 32, 64, 128, 256, 512, 1024):
        save(compose(n, plate_ratio=0.805, radius_ratio=0.225, mark_ratio=0.58, transparent=True),
             f'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_{n}.png')
    # iOS: persegi penuh tanpa alfa; sistem yang membulatkan.
    for path in glob.glob('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-*.png'):
        m = re.search(r'Icon-App-([\d.]+)x[\d.]+@(\d)x', path)
        px = round(float(m.group(1)) * int(m.group(2)))
        save(compose(px, mark_ratio=0.56), path, flatten=True)
    # Android lama (sebelum adaptive icon).
    for name, px in (('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)):
        save(compose(px, plate_ratio=0.92, radius_ratio=0.22, mark_ratio=0.6, transparent=True),
             f'android/app/src/main/res/mipmap-{name}/ic_launcher.png')
    # Web dan situs.
    for target in ('web/icons/Icon-192.png', 'public/icon-192.png'):
        save(compose(192, mark_ratio=0.58), target)
    for target in ('web/icons/Icon-512.png', 'public/icon-512.png'):
        save(compose(512, mark_ratio=0.58), target)
    save(compose(192, mark_ratio=0.46), 'web/icons/Icon-maskable-192.png')
    save(compose(512, mark_ratio=0.46), 'web/icons/Icon-maskable-512.png')
    # Favicon PNG standar untuk browser tabs (Arc, Chrome, Safari)
    for px in (16, 32, 48):
        fav = compose(px, plate_ratio=0.92, radius_ratio=0.22, mark_ratio=0.62, transparent=True)
        save(fav, f'public/favicon-{px}x{px}.png')
        save(fav, f'public/assets/favicon-{px}x{px}.png')
    
    # Apple Touch Icon 180x180
    apple_icon = compose(180, plate_ratio=0.92, radius_ratio=0.22, mark_ratio=0.62, transparent=True)
    save(apple_icon, 'public/apple-touch-icon.png')
    save(apple_icon, 'public/assets/apple-touch-icon.png')

    # Favicon 64x64 umum
    for target in ('web/favicon.png', 'public/favicon.png', 'public/assets/favicon.png'):
        save(compose(64, plate_ratio=0.92, radius_ratio=0.22, mark_ratio=0.62, transparent=True), target)
    # Favicon .ico multi-resolusi
    ico_img = compose(48, plate_ratio=0.92, radius_ratio=0.22, mark_ratio=0.62, transparent=True)
    ico_img.save('public/favicon.ico', sizes=[(16, 16), (32, 32), (48, 48)])
    ico_img.save('public/assets/favicon.ico', sizes=[(16, 16), (32, 32), (48, 48)])
    print('wrote public/favicon.ico and public/assets/favicon.ico')
    # Windows.
    ico = compose(256, plate_ratio=0.94, radius_ratio=0.2, mark_ratio=0.6, transparent=True)
    ico.save('windows/runner/resources/app_icon.ico', sizes=[(16, 16), (32, 32), (48, 48), (256, 256)])
    print('wrote windows/runner/resources/app_icon.ico')
    # Android adaptive: geser grup vektor ke atas dengan koreksi yang sama.
    offset = optical_offset(render_mark(512)) * 1024 * OPTICAL * 0.66
    print(f'android adaptive translateY = {-offset:.1f} (unit viewport)')


if __name__ == '__main__':
    main()
