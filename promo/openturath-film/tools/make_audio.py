"""Synthesize the film's score from scratch (no samples, no third-party audio).

Soft D-minor-ish pad with slow swell, airy transition swooshes at scene cuts,
a low pulse under the hook and a bell-like tone on each logo reveal.
Output: public/assets/audio/score.wav (48 kHz, stereo, 30 s)
"""
import os
import wave

import numpy as np

SR, DUR = 48000, 30.0
t = np.arange(int(SR * DUR)) / SR
rng = np.random.default_rng(7)
L = np.zeros_like(t)
R = np.zeros_like(t)


def env(a, b, attack, release):
    e = np.clip((t - a) / attack, 0, 1) * np.clip((b - t) / release, 0, 1)
    return np.sin(e * np.pi / 2) ** 2


def lowpass(x, cutoff):
    a = np.exp(-2 * np.pi * cutoff / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc = (1 - a) * x[i] + a * acc
        y[i] = acc
    return y


# pad: two chords, detuned partials, slow amplitude breathing
chords = [(0.0, 15.0, [146.83, 174.61, 220.0, 293.66]), (14.0, 30.0, [116.54, 174.61, 233.08, 293.66])]
for a, b, notes in chords:
    e = env(a, b, 4.0, 4.5)
    for k, f in enumerate(notes):
        for det, pan in ((-0.6, 0.3), (0.6, 0.7)):
            ph = rng.uniform(0, 2 * np.pi)
            s = np.sin(2 * np.pi * (f + det) * t + ph) + 0.25 * np.sin(2 * np.pi * 2 * (f + det) * t + ph)
            s *= 0.5 + 0.5 * np.sin(2 * np.pi * (0.07 + 0.02 * k) * t)
            L += s * e * (1 - pan) * 0.035
            R += s * e * pan * 0.035

# low pulse under the hook (0-4 s)
for beat in np.arange(0.4, 4.0, 0.9):
    e = np.exp(-np.clip(t - beat, 0, None) * 5) * (t >= beat)
    s = np.sin(2 * np.pi * 55 * t) * e * 0.18
    L += s
    R += s

# swooshes at transitions (filtered noise with a rise)
noise = lowpass(rng.standard_normal(len(t)), 1800)
for c in [3.8, 8.0, 14.2, 21.3, 25.5]:
    e = np.exp(-((t - c) / 0.42) ** 2)
    L += noise * e * 0.09
    R += np.roll(noise, 400) * e * 0.09

# bell on logo reveals
for c, f in [(5.4, 587.33), (27.2, 587.33)]:
    d = np.clip(t - c, 0, None)
    e = np.exp(-d * 1.4) * (t >= c)
    s = (np.sin(2 * np.pi * f * d) + 0.4 * np.sin(2 * np.pi * f * 2.76 * d) * np.exp(-d * 3) + 0.2 * np.sin(2 * np.pi * f * 5.4 * d) * np.exp(-d * 6)) * e
    L += s * 0.09
    R += s * 0.09

# master: fade ends, normalize to -3 dBFS
fade = np.clip(t / 0.4, 0, 1) * np.clip((DUR - t) / 1.6, 0, 1)
L *= fade
R *= fade
peak = max(np.abs(L).max(), np.abs(R).max())
gain = 10 ** (-3 / 20) / peak
data = np.stack([L * gain, R * gain], axis=1)
pcm = (np.clip(data, -1, 1) * 32767).astype("<i2")
out = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "public", "assets", "audio", "score.wav")
with wave.open(out, "wb") as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print("wrote", out)
