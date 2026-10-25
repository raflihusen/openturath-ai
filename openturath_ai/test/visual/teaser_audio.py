#!/usr/bin/env python3
"""Sound design tenang untuk video pengumuman (selaras render_teaser_test.dart).

Hanya sintesis (sinus, derau tersaring, gaung buatan); tidak memakai sampel
berhak cipta. Penggunaan: python3 teaser_audio.py keluaran.wav
"""
import sys
import wave
import numpy as np

SR = 44100
DUR = 15.2
N = int(SR * DUR)
rng = np.random.default_rng(7)
t = np.arange(N) / SR
L = np.zeros(N)
R = np.zeros(N)


def add(sig, at, gain=1.0, pan=0.0):
    i = int(at * SR)
    if i >= N:
        return
    seg = sig[: N - i]
    L[i : i + len(seg)] += seg * gain * (1 - max(pan, 0))
    R[i : i + len(seg)] += seg * gain * (1 + min(pan, 0))


def env(n, a=0.004, d=0.3, curve=4.0):
    x = np.arange(n) / SR
    return np.minimum(1, x / a) * np.exp(-x * curve / d)


def tone(f, d, a=0.004, curve=5.0, harm=((1, 1.0),)):
    n = int(SR * d)
    x = np.arange(n) / SR
    s = sum(h * np.sin(2 * np.pi * f * k * x) for k, h in harm)
    return s * env(n, a, d, curve)


def noise(d):
    return rng.standard_normal(int(SR * d))


def lowpass(x, fc):
    # satu kutub, cukup untuk membulatkan derau
    a = np.exp(-2 * np.pi * fc / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = a * acc + (1 - a) * v
        y[i] = acc
    return y


def highpass(x, fc):
    return x - lowpass(x, fc)


def swell(d, up=True, fc=2500):
    n = int(SR * d)
    x = highpass(lowpass(noise(d), fc), 400)
    shape = np.linspace(0, 1, n) ** 2.2
    if not up:
        shape = shape[::-1]
    return x * shape * 0.5


# Lantai ruang: dengung rendah A1 dan kuinnya, sangat pelan, masuk dan keluar halus.
pad = 0.5 * np.sin(2 * np.pi * 55 * t) + 0.3 * np.sin(2 * np.pi * 82.4 * t + 0.6)
pad += 0.12 * np.sin(2 * np.pi * 110 * t)
pad *= np.minimum(1, t / 1.5) * np.minimum(1, (DUR - t) / 1.4) * 0.09
air = lowpass(noise(DUR), 900) * np.minimum(1, t / 2) * np.minimum(1, (DUR - t) / 1.4)
L += pad + air * 0.22
R += pad + air * 0.22

# Baris teks: petik lembut bernada pentatonik, tiap baris naik sedikit.
notes = [392.0, 440.0, 523.25, 587.33, 659.25, 784.0]
lines = [0.30, 0.72, 2.95, 3.37, 5.50, 5.92, 6.34]
for k, at in enumerate(lines):
    f = notes[k % len(notes)]
    add(tone(f, 0.9, curve=6.0, harm=((1, 1), (2, 0.25), (3, 0.08))), at + 0.05, 0.34, pan=(-1) ** k * 0.3)
    add(swell(0.45, up=True), at - 0.2, 0.10)

# Keluar adegan: desir pendek ke atas.
for at in (2.45, 5.0, 8.4):
    add(swell(0.5, up=False, fc=3500), at, 0.07)

# Tekanan pada "26 Oktober.": dentum rendah.
hit = tone(55, 1.4, a=0.01, curve=6.0, harm=((1, 1), (2, 0.4)))
add(hit, 6.05, 0.55)

# Logo: penanjak, lonceng saat lengkung terisi, ketukan halus tiap huruf.
add(swell(0.9, up=True, fc=5000), 8.1, 0.14)
add(hit, 8.9, 0.4)
bell = (
    tone(523.25, 2.4, a=0.005, curve=5.5, harm=((1, 1), (2.76, 0.18), (5.4, 0.06)))
    + 0.7 * tone(784.0, 2.4, a=0.005, curve=5.5, harm=((1, 1), (2.76, 0.12)))
    + 0.5 * tone(1046.5, 2.4, a=0.005, curve=6.0)
)
add(bell, 9.9, 0.34)
for i in range(10):
    add(tone(1500 + i * 40, 0.12, a=0.002, curve=8.0), 10.4 + i * 0.045, 0.07, pan=(i - 5) / 12)

# Tanggal: denting kaca tipis dan dentum lembut.
add(tone(1568.0, 1.6, a=0.003, curve=6.0, harm=((1, 1), (2.4, 0.2))), 11.3, 0.26)
add(tone(1975.5, 1.4, a=0.003, curve=6.5), 11.42, 0.13)
add(hit, 11.3, 0.3)


# Gaung buatan: derau meluruh sepanjang 1,6 dtk, dicampur tipis.
def reverb(x, wet=0.28):
    ir = highpass(noise(1.6), 200) * np.exp(-np.arange(int(SR * 1.6)) / SR * 3.2)
    n = len(x) + len(ir)
    y = np.fft.irfft(np.fft.rfft(x, n) * np.fft.rfft(ir, n), n)[: len(x)]
    y *= np.max(np.abs(x)) / (np.max(np.abs(y)) + 1e-9)
    return x * (1 - wet) + y * wet


L = reverb(L)
R = reverb(R)

# Penutup halus dan normalisasi puncak ke -3 dBFS.
fade = np.minimum(1, (DUR - t) / 0.9)
out = np.stack([L * fade, R * fade], axis=1)
out = np.tanh(out * 1.2)
out *= 0.7 / np.max(np.abs(out))
pcm = (out * 32767).astype("<i2")
with wave.open(sys.argv[1], "wb") as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print("ok", sys.argv[1])
