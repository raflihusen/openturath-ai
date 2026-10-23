#!/usr/bin/env python3
"""Lagu orisinal 120 BPM untuk video promo OpenTurath (14 detik, berulang mulus).
Semua bunyi disintesis dengan numpy; bunyi UI ditempatkan pada waktu yang sama dengan timeline.json."""
import json, wave, pathlib, numpy as np
root = pathlib.Path(__file__).resolve().parent.parent
TL = json.loads((root / "src/promo/timeline.json").read_text())
SR = 44100; BEAT = 60 / TL["bpm"]; T = TL["beats"] * BEAT; TAIL = 3.0
N = int((T + TAIL) * SR)
rng = np.random.default_rng(7)
def t_of(n): return np.arange(n) / SR
def put(buf, start, sig, gain=1.0, pan=0.0):
    i = int(start * SR)
    if i >= len(buf[0]): return
    j = min(len(buf[0]), i + len(sig))
    l = gain * (1 - max(0, pan)); r = gain * (1 + min(0, pan))
    buf[0][i:j] += sig[: j - i] * l; buf[1][i:j] += sig[: j - i] * r
def hp(x, a=0.97):
    y = np.zeros_like(x); p = 0.0; q = 0.0
    for i in range(len(x)):
        y[i] = a * (y[i - 1] + x[i] - (x[i - 1] if i else 0)) if i else x[0]
    return y
def lp(x, k):
    c = np.cumsum(np.insert(x, 0, 0)); y = (c[k:] - c[:-k]) / k
    return np.concatenate([np.full(k - 1, y[0]), y])
def env(n, decay): return np.exp(-t_of(n) * decay)

music = [np.zeros(N), np.zeros(N)]
duck = np.ones(N)
# kick
def kick():
    n = int(0.38 * SR); t = t_of(n); f = 46 + 110 * np.exp(-t * 28)
    ph = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(ph) * np.exp(-t * 9.5) * 0.95 + 0.25 * np.sin(2 * ph) * np.exp(-t * 30)
K = kick()
for b in range(TL["beats"]):
    put(music, b * BEAT, K, 0.9)
    i = int(b * BEAT * SR); n = int(0.28 * SR)
    duck[i:i + n] *= 1 - 0.5 * np.exp(-t_of(min(n, N - i)) * 11)
# clap on 2 and 4
def clap():
    n = int(0.22 * SR); x = rng.standard_normal(n); x = lp(x, 3) - lp(x, 40)
    return x * env(n, 22) * 0.9
C = clap()
for b in range(1, TL["beats"], 2): put(music, b * BEAT, C, 0.35, 0.08)
# hats: offbeat open-ish, 16th shaker
def hat(d, g):
    n = int(0.12 * SR); x = rng.standard_normal(n); x = x - lp(x, 6)
    return x * env(n, d) * g
H1 = hat(70, 0.5); H2 = hat(120, 0.25)
for b in range(TL["beats"]):
    put(music, (b + 0.5) * BEAT, H1, 0.28, -0.12)
    put(music, (b + 0.25) * BEAT, H2, 0.12, 0.15); put(music, (b + 0.75) * BEAT, H2, 0.12, -0.15)
# harmoni
prog = [("A", 110.0, [220, 261.63, 329.63]), ("F", 87.31, [174.61, 220, 261.63]), ("C", 130.81, [261.63, 329.63, 392]),
        ("G", 98.0, [196, 246.94, 293.66]), ("A", 110.0, [220, 261.63, 329.63]), ("F", 87.31, [174.61, 220, 261.63]), ("G", 98.0, [196, 246.94, 293.66])]
def pluck(f, dur=0.55):
    n = int(dur * SR); t = t_of(n)
    y = np.sin(2 * np.pi * f * t) + 0.42 * np.sin(4 * np.pi * f * t) * np.exp(-t * 14) + 0.2 * np.sin(6 * np.pi * f * t) * np.exp(-t * 22)
    return y * np.exp(-t * 7.5) * (1 - np.exp(-t * 900))
def bass(f, dur):
    n = int(dur * SR); t = t_of(n)
    y = np.sin(2 * np.pi * f * t) + 0.3 * np.sin(4 * np.pi * f * t)
    return y * np.minimum(1, t * 120) * np.exp(-t * 3.2)
def pad(freqs, dur):
    n = int(dur * SR); t = t_of(n); y = 0
    for f in freqs: y = y + np.sin(2 * np.pi * f * t) + 0.5 * np.sin(2 * np.pi * f * 1.004 * t)
    a = np.minimum(1, t / 0.5) * np.minimum(1, (dur - t) / 0.6)
    return y * a / len(freqs)
harm = [np.zeros(N), np.zeros(N)]
for bar, (nm, rf, ch) in enumerate(prog):
    s0 = bar * 4 * BEAT
    put(harm, s0, pad(ch + [rf * 2], 4 * BEAT + 0.4), 0.05)
    pat = [0, 1, 2, 1, 0, 1, 2, 1]
    for k in range(8):
        f = ch[pat[k]] * (2 if k == 6 else 1)
        put(harm, s0 + k * BEAT / 2, pluck(f), 0.20 if k % 2 == 0 else 0.13, 0.25 * (-1) ** k)
    for off, dur in [(0, 0.9), (1.5, 0.45), (2.5, 0.9)]:
        put(music, s0 + off * BEAT, bass(rf, dur * BEAT * 1.9), 0.55)
music[0] += harm[0] * duck; music[1] += harm[1] * duck
# gema (reverb) untuk harmoni saja
ir_n = int(1.8 * SR); ir = rng.standard_normal(ir_n) * np.exp(-t_of(ir_n) * 2.6); ir[:50] = 0
def conv(x):
    n = len(x) + len(ir) - 1; m = 1 << (n - 1).bit_length()
    return np.fft.irfft(np.fft.rfft(x, m) * np.fft.rfft(ir, m), m)[:len(x)]
wet = [conv(harm[0]) * 0.012, conv(harm[1]) * 0.012]
music[0] += wet[0]; music[1] += wet[1]
# bunyi UI
sfx = [np.zeros(N), np.zeros(N)]
def tick(f=1900):
    n = int(0.05 * SR); t = t_of(n); x = rng.standard_normal(n); x = (x - lp(x, 8)) * np.exp(-t * 300) * 0.5
    return x + np.sin(2 * np.pi * f * t) * np.exp(-t * 130) * 0.6
def swish(up=True):
    n = int(0.32 * SR); t = t_of(n); x = rng.standard_normal(n); x = lp(x, 5) - lp(x, 60)
    a = np.sin(np.pi * (t / t[-1] if up else 1 - t / t[-1])) ** 2
    return x * a * 0.5
def pop():
    n = int(0.12 * SR); t = t_of(n); f = 420 * np.exp(-t * 12) + 110
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 28) * 0.7
def chime():
    n = int(0.7 * SR); t = t_of(n)
    return (np.sin(2 * np.pi * 1046.5 * t) + 0.6 * np.sin(2 * np.pi * 1568 * t) * np.exp(-t * 3)) * np.exp(-t * 7) * 0.5
def key():
    n = int(0.03 * SR); t = t_of(n); x = rng.standard_normal(n); x = (x - lp(x, 4)) * np.exp(-t * 400)
    return x * 0.5 + np.sin(2 * np.pi * 3300 * t) * np.exp(-t * 300) * 0.3
M = TL["morphs"]
for c in TL["clicks"]: put(sfx, c * BEAT, tick(), 0.55)
for k, b in M.items():
    if k not in ("btn",): put(sfx, b * BEAT, pop(), 0.30); put(sfx, b * BEAT, swish(k not in ("key", "back")), 0.20, 0.1)
a, b = TL["typeQ"]
for i in range(22): put(sfx, (a + (b - a) * i / 22) * BEAT, key(), 0.25, rng.uniform(-.2, .2))
a, b = TL["typeK"]
for i in range(3): put(sfx, (a + (b - a) * i / 3) * BEAT, key(), 0.3)
put(sfx, TL["flip"] * BEAT, pop(), 0.4); put(sfx, TL["flip"] * BEAT, tick(700), 0.5)
put(sfx, TL["enter"] * BEAT, tick(500), 0.6)
put(sfx, M["toast"] * BEAT + 0.04, chime(), 0.4)
for h in TL["hover"]: put(sfx, h[0] * BEAT, key(), 0.35)
for hold in TL["holds"]: put(sfx, hold[0] * BEAT, tick(1500), 0.45)
mix = [music[0] + sfx[0], music[1] + sfx[1]]
# bungkus ekor ke awal agar berulang mulus
Ln = int(T * SR); tl = N - Ln
out = [m[:Ln].copy() for m in mix]
for ch in range(2): out[ch][:tl] += mix[ch][Ln:Ln + tl]
y = np.stack(out, 1); y = y / (np.max(np.abs(y)) / 0.89)
y = np.tanh(y * 1.1) / np.tanh(1.1)
w = wave.open(str(root / "public/promo/promo_loop.wav"), "wb"); w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
w.writeframes((y * 32767).astype("<i2").tobytes()); w.close()
print("ok", y.shape, "detik", Ln / SR)
