"""Bunyi animasi OpenTurath: lonceng kaca lembut (nada D), desir halaman kitab, denyut rendah. Tanpa lagu.
Disintesis numpy, stereo 48 kHz, ruang gema sintetis. Waktu acuan mengikuti film.html."""
import json, math, wave
import numpy as np
SR = 48000; DUR = 14.5; N = int(SR * DUR)
rng = np.random.default_rng(26102026)
dry = np.zeros((2, N)); wet = np.zeros((2, N))
T = np.arange(N) / SR

def place(sig, t0, pan=0.0, g=1.0, send=0.0):
    i = int(t0 * SR); m = min(len(sig), N - i)
    if m <= 0: return
    a = math.cos((pan + 1) * math.pi / 4); b = math.sin((pan + 1) * math.pi / 4)
    for ch, k in ((0, a), (1, b)):
        dry[ch, i:i + m] += sig[:m] * g * k * (1 - send * 0.4)
        wet[ch, i:i + m] += sig[:m] * g * k * send

def fft_filter(x, lo=None, hi=None, order=2):
    X = np.fft.rfft(x); f = np.fft.rfftfreq(len(x), 1 / SR); h = np.ones_like(f)
    if lo: h *= (f / lo) ** order / (1 + (f / lo) ** order)
    if hi: h *= 1 / (1 + (f / hi) ** order)
    return np.fft.irfft(X * h, len(x))

def noise(dur): return rng.standard_normal(int(dur * SR))
def env_ad(m, a, d):
    t = np.arange(m) / SR; return (1 - np.exp(-t / a)) * np.exp(-t / d)

def bell(f, dur=2.4, g=1.0, bright=1.0, decay=0.9):
    m = int(dur * SR); t = np.arange(m) / SR
    idx = 1.6 * bright * np.exp(-t * 3.5)
    y = np.sin(2 * np.pi * f * t + idx * np.sin(2 * np.pi * f * 2.0 * t))
    y += 0.30 * np.sin(2 * np.pi * f * 3.01 * t) * np.exp(-t * 6)
    y += 0.12 * np.sin(2 * np.pi * f * 5.43 * t) * np.exp(-t * 11)
    y *= (1 - np.exp(-t / 0.003)) * np.exp(-t / (decay * dur / 3.2))
    return y * g

def page(dur=0.34, g=1.0, hi=7000, lo=1400):
    """desir selembar halaman: derau pita sempit, awal lembut, remasan kasar."""
    m = int(dur * SR); x = fft_filter(noise(dur), lo, hi)
    t = np.arange(m) / SR; crinkle = 0.55 + 0.45 * np.abs(fft_filter(noise(dur), None, 90))
    crinkle /= crinkle.max()
    e = (1 - np.exp(-t / 0.035)) * np.exp(-t / (dur * 0.28))
    y = x * e * crinkle; return y / (np.abs(y).max() + 1e-9) * g

def air(dur, lo, hi, peak=0.5, g=1.0, skew=2.0):
    m = int(dur * SR); u = np.linspace(0, 1, m)
    e = np.where(u < peak, (u / peak) ** skew, ((1 - u) / (1 - peak)) ** (skew * 0.75))
    x = fft_filter(noise(dur), lo, hi) * e; return x / (np.abs(x).max() + 1e-9) * g

def swell_tone(f0, f1, dur, g=1.0, peak=0.8):
    m = int(dur * SR); u = np.linspace(0, 1, m); f = f0 * (f1 / f0) ** (u ** 1.5)
    ph = 2 * np.pi * np.cumsum(f) / SR
    y = (np.sin(ph) + 0.4 * np.sin(2 * ph) + 0.2 * np.sin(3 * ph)) * np.where(u < peak, (u / peak) ** 2.2, ((1 - u) / (1 - peak)) ** 1.2)
    return y / np.abs(y).max() * g

def thump(g=1.0):
    m = int(3.2 * SR); t = np.arange(m) / SR
    f = 36.7 * (1 + 0.9 * np.exp(-t * 24)); ph = 2 * np.pi * np.cumsum(f) / SR
    y = np.sin(ph) * np.exp(-t * 1.5) + 0.35 * np.sin(2 * ph) * np.exp(-t * 3.2)
    y *= (1 - np.exp(-t / 0.004))
    knock = fft_filter(noise(0.25), 60, 900) * np.exp(-np.arange(int(0.25 * SR)) / SR / 0.025)
    y[:len(knock)] += knock / np.abs(knock).max() * 0.55
    return y / np.abs(y).max() * g

# ---- jadwal angkat dari kurva kamera (port film.html) ----
meta = json.load(open("assets/layers.json"))
def speed(t):
    sm = lambda x: (lambda v: v * v * (3 - 2 * v))(min(1, max(0, x)))
    if t <= 0: return 0
    if t < 0.6: return 0.5 * sm(t / 0.6)
    if t < 1.25: return 0.5
    if t < 1.6: return 0.5 + 0.5 * sm((t - 1.25) / 0.35)
    if t < 7.3: return 1 + 0.055 * math.sin(2 * math.pi * (t - 1.6) / 2.4)
    if t < 8.3: return speed(7.3 - 1e-6) + (0.12 - speed(7.3 - 1e-6)) * sm((t - 7.3) / 1.0)
    return 0.12 * (1 - sm((t - 8.3) / 0.6))
TAB = np.cumsum([speed(i * 0.001) * 0.001 for i in range(12001)])
integ = lambda t: float(np.interp(t * 1000, np.arange(12001), TAB))
PH = meta["height"]; Y0 = 360; CR = (PH - 330 - Y0) / integ(8.0)
Yv = lambda t: Y0 + CR * integ(t)
def when(y):
    lo, hi = 0.0, 8.0
    for _ in range(40):
        m = (lo + hi) / 2
        if Yv(m) < y: lo = m
        else: hi = m
    return hi

# ---- 0-1.4 s: potongan hero terangkat ----
place(page(0.9, 0.20, 5200, 900), 0.12, -0.1, 1, 0.25)
for k, (f, t0, pan) in enumerate([(587.33, 0.22, -0.35), (880.0, 0.40, 0.3), (698.46, 0.58, -0.1), (1174.66, 0.74, 0.4)]):
    place(bell(f, 1.8, 0.10, 0.7), t0, pan, 1, 0.5)
# ubin logo keluar sudut
place(air(1.5, 500, 4200, 0.35, 0.12), 1.15, 0, 1, 0.3)
for f, t0, pan in [(1396.9, 1.38, -0.8), (1760.0, 1.46, 0.8), (1174.66, 1.54, 0.7), (1568.0, 1.62, -0.7)]:
    place(bell(f, 1.6, 0.06, 0.5), t0, pan, 1, 0.55)

# ---- perjalanan: angin halus + desir halaman setiap kartu terangkat ----
tt = np.arange(int(5.9 * SR)) / SR + 1.5
wind = fft_filter(noise(5.9), 260, 1500) * (0.55 + 0.45 * np.sin(2 * np.pi * tt / 2.4))
wind *= np.minimum(1, np.minimum((tt - 1.5) / 0.8, (7.4 - tt) / 1.0)); place(wind / np.abs(wind).max() * 0.075, 1.5, 0, 1, 0.2)
PENTA = [587.33, 659.25, 698.46, 880.0, 987.77, 1174.66]
ev = []
for l in meta["layers"]:
    if l["kind"] in ("card", "photo", "testimonial") and not l["id"].startswith("hero"):
        yc = l["y"] + l["h"] / 2; ev.append((when(yc - 900 + 410), l["kind"], l["id"]))
ev.sort(); last = -1; ni = 0
for t0, kind, _id in ev:
    if t0 - last < 0.32 or t0 > 7.6: continue
    last = t0; pan = (-0.45, 0.4, -0.15, 0.5)[ni % 4]
    place(page(0.42 if kind != "photo" else 0.55, 0.30, 6500, 1100), t0 - 0.12, pan, 1, 0.3)
    place(bell(PENTA[(ni * 2 + (ni // 3)) % 6], 2.2, 0.14, 0.8), t0 + 0.02, pan * 0.7, 1, 0.55); ni += 1

# ---- naik ke atas (7.75-9.25) ----
place(swell_tone(73.4, 293.7, 1.55, 0.20), 7.72, 0, 1, 0.35)
place(air(1.6, 700, 6500, 0.72, 0.30, 2.6), 7.75, -0.1, 1, 0.5)
place(air(0.9, 1500, 9000, 0.6, 0.20, 2.2), 8.55, 0.1, 1, 0.5)
for f, t0, pan in [(1174.66, 8.74, -0.5), (1568.0, 8.9, 0.5), (1760.0, 9.06, -0.3)]: place(bell(f, 1.9, 0.07, 0.6), t0, pan, 1, 0.6)
# ---- menukik (9.47-9.97) ----
place(air(0.58, 900, 11000, 0.86, 0.50, 3.2), 9.42, 0, 1, 0.45)
place(swell_tone(146.8, 587.3, 0.55, 0.30, 0.95), 9.44, 0, 1, 0.3)
# ---- dentum judul (9.97) ----
place(thump(0.95), 9.97, 0, 1, 0.22)
for f, g, dly in [(587.33, 0.20, 0), (880.0, 0.17, 0.015), (1174.66, 0.15, 0.03), (1396.91, 0.10, 0.05)]:
    place(bell(f, 4.0, g, 1.0, 1.1), 9.98 + dly, 0, 1, 0.7)
place(air(1.4, 3500, 11000, 0.2, 0.10, 1.4), 9.98, 0, 1, 0.6)
# kata demi kata: kerlip kaca halus
for i in range(4): place(bell([1760.0, 1976.0, 2349.3, 2637.0][i], 1.2, 0.045, 0.4), 10.12 + 0.06 * i, -0.3 + 0.2 * i, 1, 0.6)
for i in range(4): place(bell([1568.0, 1396.9, 1174.66, 1046.5][i], 1.6, 0.04, 0.4), 10.36 + 0.05 * i, 0.3 - 0.2 * i, 1, 0.65)
place(bell(2349.3, 2.2, 0.05, 0.3), 10.02, 0, 1, 0.6)
# alas udara sangat tipis di kartu akhir
tail = fft_filter(noise(4.3), 180, 900) * np.linspace(0, 1, int(4.3 * SR)) ** 2 * np.linspace(1, 0.4, int(4.3 * SR))
place(tail / np.abs(tail).max() * 0.03, 10.2, 0, 1, 0.3)

# ---- gema: IR sintetis ----
IRN = int(3.2 * SR); irt = np.arange(IRN) / SR
ir = []
for c in range(2):
    x = rng.standard_normal(IRN) * np.exp(-irt / 0.62)
    X = np.fft.rfft(x); f = np.fft.rfftfreq(IRN, 1 / SR); X *= 1 / (1 + (f / (5200 - 1300 * c)) ** 2) * (f / 140) ** 2 / (1 + (f / 140) ** 2)
    x = np.fft.irfft(X, IRN); x[:int(0.012 * SR)] *= np.linspace(0, 1, int(0.012 * SR)); ir.append(x / np.sqrt((x ** 2).sum()))
L = N + IRN; nfft = 1 << (L - 1).bit_length()
rev = np.stack([np.fft.irfft(np.fft.rfft(wet[c], nfft) * np.fft.rfft(ir[c], nfft), nfft)[:N] for c in range(2)])
mix = dry + rev * 1.35
# penutup halus dan normalisasi puncak -1,5 dB
fade = np.clip((DUR - T) / 0.9, 0, 1) ** 1.5; mix *= fade
mix = np.tanh(mix * 1.05) / np.tanh(1.05)
mix *= 0.84 / np.abs(mix).max()
pcm = (mix.T * 32767).astype("<i2")
with wave.open("anim.wav", "wb") as w: w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
print("ok peak", np.abs(mix).max(), "events", ni)
