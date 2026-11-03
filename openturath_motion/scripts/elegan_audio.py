#!/usr/bin/env python3
"""Create a 30 s OpenTurath motion bed and cue accents, deterministically.

Bed: synthesized sine partials, five slow overlapping chords. Scene accents:
earshot's procedural forge bank, rendered locally; no recordings are used.
Requires the earshot venv, numpy and scipy. All generated takes are temporary.
"""
from pathlib import Path
import subprocess
import tempfile
import numpy as np
from scipy.io import wavfile
from scipy.signal import resample_poly

ROOT = Path(__file__).resolve().parent.parent
EARSHOT = Path('/Users/apple/.claude/tools/earshot/.venv/bin/earshot')
SR = 48000
DURATION = 30
n = SR * DURATION
t = np.arange(n, dtype=np.float64) / SR
stereo = np.zeros((n, 2), dtype=np.float64)
# A minor, F major, C major, G major, A minor; each chord enters over
# 1.6 seconds, so the 6 s picture changes retain a continuous atmosphere.
chords = [(110, 164.81, 220, 261.63), (87.31, 130.81, 174.61, 220),
          (130.81, 164.81, 196, 261.63), (98, 146.83, 196, 246.94),
          (110, 164.81, 220, 261.63)]
for i, chord in enumerate(chords):
    start, end = max(0, i * 6 - .8), min(30, (i + 1) * 6 + .8)
    u = np.clip((t - start) / 1.6, 0, 1)
    v = np.clip((end - t) / 1.6, 0, 1)
    env = np.sin(u * np.pi / 2) ** 2 * np.sin(v * np.pi / 2) ** 2
    for j, f in enumerate(chord):
        phase = 0.63 * j + 0.19 * i
        left = np.sin(2 * np.pi * f * t + phase)
        right = 0.85 * left + 0.15 * np.sin(2 * np.pi * (f * 1.0007) * t + phase)
        harmonic = np.sin(2 * np.pi * 2 * f * t + phase) * 0.12
        gain = 0.018 if j else 0.024
        stereo[:, 0] += (left + harmonic) * env * gain
        stereo[:, 1] += (right + harmonic) * env * gain

def insert(path, when, gain, pan=0):
    sr, x = wavfile.read(path)
    x = x.astype(np.float64)
    if np.issubdtype(wavfile.read(path)[1].dtype, np.integer):
        x /= np.iinfo(wavfile.read(path)[1].dtype).max
    if x.ndim > 1: x = x.mean(axis=1)
    if sr != SR: x = resample_poly(x, SR, sr)
    start = max(0, round(when * SR)); x = x[:n-start]
    stereo[start:start+len(x), 0] += x * gain * (1 - max(0, pan))
    stereo[start:start+len(x), 1] += x * gain * (1 + min(0, pan))

with tempfile.TemporaryDirectory(prefix='openturath-audio-') as tmp:
    tmp = Path(tmp)
    sounds = [('mallet/celesta', 'E5', 'celesta.wav'),
              ('mallet/marimba', 'A4', 'marimba.wav'),
              ('reverse_swell/breath', None, 'breath.wav')]
    for sound, pitch, filename in sounds:
        cmd = [str(EARSHOT), 'sfx', 'render', sound, '-o', str(tmp / filename)]
        if pitch: cmd += ['--pitch', pitch]
        subprocess.run(cmd, check=True)
    # Cue onsets occur at chapter boundaries, deliberately understated.
    for when, gain, pan in [(0.35, .085, 0), (6, .075, -.2),
                            (12, .075, .2), (18, .075, -.2), (24, .09, 0)]:
        insert(tmp / ('celesta.wav' if when in (0.35, 12, 24) else 'marimba.wav'), when, gain, pan)
    # One gentle transition, peak ~0.733s into the bank sound, at 18 seconds.
    insert(tmp / 'breath.wav', 17.267, .022)
# Fade naturally to silence at both ends, preserving final AAC headroom.
fade = np.minimum(np.minimum(t / .55, (DURATION - t) / 2), 1).clip(0, 1)
stereo *= fade[:, None]
# Raise the measured bed from -29.6 to about -17 LUFS.
stereo *= 10 ** (12.6 / 20)
peak = np.max(np.abs(stereo))
if peak > .70: stereo *= .70 / peak
out = ROOT / 'public/promo/elegan_audio.wav'
out.parent.mkdir(parents=True, exist_ok=True)
wavfile.write(out, SR, np.round(stereo * 32767).astype(np.int16))
print(f'{out}: {DURATION} seconds, sample peak {20*np.log10(np.max(np.abs(stereo))):.2f} dBFS')
