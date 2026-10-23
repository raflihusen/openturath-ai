"""Bunyi animasi: whoosh, hit, tik kata, tanpa lagu. Disintesis numpy, stereo 48 kHz."""
import numpy as np, wave
SR = 48000; DUR = 14.5; n = int(SR * DUR)
rng = np.random.default_rng(7)
L = np.zeros(n); R = np.zeros(n)
def add(sig, t0, pan=0.0, g=1.0):
    i = int(t0 * SR); m = min(len(sig), n - i)
    if m <= 0: return
    a = np.cos((pan + 1) * np.pi / 4); b = np.sin((pan + 1) * np.pi / 4)
    L[i:i + m] += sig[:m] * g * a; R[i:i + m] += sig[:m] * g * b
def lp(x, fc):
    a = np.exp(-2 * np.pi * fc / SR); y = np.zeros_like(x); s = 0.0
    for k in range(len(x)): s = (1 - a) * x[k] + a * s; y[k] = s
    return y
def lpv(x, fcs):
    y = np.zeros_like(x); s = 0.0
    for k in range(len(x)):
        a = np.exp(-2 * np.pi * fcs[k] / SR); s = (1 - a) * x[k] + a * s; y[k] = s
    return y
def whoosh(dur, f0, f1, peak=0.5, g=1.0):
    m = int(dur * SR); t = np.linspace(0, 1, m); nz = rng.standard_normal(m)
    fc = f0 * (f1 / f0) ** t; y = lpv(nz, fc); y = lpv(y, fc)
    env = np.sin(np.pi * t ** (1 / (2 * peak + 0.001)) ) ** 2 if False else np.where(t < peak, (t / peak) ** 2, ((1 - t) / (1 - peak)) ** 1.5)
    y = y * env; return y / (np.abs(y).max() + 1e-9) * g
def hit(g=1.0):
    m = int(1.6 * SR); t = np.arange(m) / SR
    f = 50 + 70 * np.exp(-t * 30); ph = 2 * np.pi * np.cumsum(f) / SR
    body = np.sin(ph) * np.exp(-t * 3.2)
    click = lp(rng.standard_normal(m), 6000) * np.exp(-t * 90) * 0.5
    air = lp(rng.standard_normal(m), 2500) * np.exp(-t * 7) * 0.12
    y = body + click + air; return y / np.abs(y).max() * g
def tick(f, g=1.0):
    m = int(0.35 * SR); t = np.arange(m) / SR
    y = (np.sin(2 * np.pi * f * t) + 0.35 * np.sin(2 * np.pi * f * 2.01 * t)) * np.exp(-t * 28) * (1 - np.exp(-t * 900)); return y * g
def riser(dur, f0, f1, g=1.0):
    m = int(dur * SR); t = np.arange(m) / SR; u = t / dur
    f = f0 * (f1 / f0) ** u; y = np.sin(2 * np.pi * np.cumsum(f) / SR) * u ** 2 * (1 - u) ** 0.3
    return y * g
# pembuka: tarikan lembut saat potongan terangkat
add(whoosh(1.4, 400, 3200, 0.55), 0.05, 0, 0.16)
for k, (t0, pan) in enumerate([(0.15, -0.5), (0.3, 0.5), (0.45, -0.2), (0.6, 0.3)]): add(tick(660 * 2 ** (k / 12 * 3), 0.07), t0 + 0.2, pan, 1)
# kamera berlari: dengung rendah naik pelan
add(riser(6.2, 70, 140, 0.05), 1.5, 0, 1)
# penutup penerbangan
add(whoosh(1.5, 300, 5200, 0.7), 7.76, -0.2, 0.34)
add(whoosh(1.15, 900, 7000, 0.62), 8.66, 0.1, 0.42)
add(whoosh(0.5, 1200, 9000, 0.7), 9.55, 0, 0.30)
add(whoosh(0.4, 600, 3000, 0.4), 9.80, 0, 0.30)
add(hit(), 9.97, 0, 0.78)
add(whoosh(1.2, 4000, 500, 0.12), 10.0, 0, 0.12)
# kata demi kata
for i, w in enumerate(range(4)): add(tick(1175 if i != 3 else 1568, 0.16), 10.12 + 0.06 * i, -0.3 + 0.2 * i)
for i in range(4): add(tick(784 * 2 ** (i / 12 * 2), 0.10), 10.36 + 0.05 * i, 0.3 - 0.2 * i)
add(tick(1319, 0.12), 10.02, 0, 1)
# ekor lembut
fade = np.clip((DUR - np.arange(n) / SR) / 0.5, 0, 1); L *= fade; R *= fade
pk = max(np.abs(L).max(), np.abs(R).max()); L /= pk; R /= pk; L *= 0.89; R *= 0.89
pcm = (np.stack([L, R], 1) * 32767).astype("<i2")
with wave.open("anim.wav", "wb") as w: w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
print("ok", pk)
