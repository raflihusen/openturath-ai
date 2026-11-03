#!/usr/bin/env python3
"""Original 28 s / 120 BPM OpenTurath product film soundtrack.

Music is synthesized here; every visual effect is from the local earshot
procedural sound bank (some models fitted to CC0 audio; none are recordings).
Run with the earshot virtualenv Python to regenerate the WAV and print the
bank checks, cue gains, and measured loudness. No external media is needed.
"""
from pathlib import Path
import numpy as np
from scipy.io import wavfile
from scipy.signal import butter, sosfilt
import pyloudnorm as pyln
from earshot.forge import bank

ROOT = Path(__file__).resolve().parent.parent
SR = 48000
DURATION = 28
N = DURATION * SR
rng = np.random.default_rng(1247)
bed = np.zeros((N, 2), dtype=np.float64)
fx = np.zeros_like(bed)

def put(dst, wave, when, gain, pan=0):
    x = np.asarray(wave, dtype=np.float64)
    if x.ndim == 1: x = np.column_stack((x, x))
    start = max(0, round(when * SR))
    x = x[:N-start]
    dst[start:start+len(x), 0] += x[:, 0] * gain * (1 - max(0, pan))
    dst[start:start+len(x), 1] += x[:, 1] * gain * (1 + min(0, pan))

def sec(d): return np.arange(round(d * SR)) / SR
# Drums: a compact kick, rim and shaker; all are calculated, not sampled.
def kick():
    t = sec(.30); phase = 2*np.pi*np.cumsum(49 + 88*np.exp(-t*33))/SR
    return np.sin(phase)*np.exp(-t*13)*(.90+.10*np.exp(-t*40))
def rim():
    t = sec(.12); noise = rng.standard_normal(len(t))
    return (sosfilt(butter(2, [900, 5000], btype='bandpass', fs=SR, output='sos'), noise)*.20
            + np.sin(2*np.pi*720*t)*.25) * np.exp(-t*36)
def hat():
    t = sec(.065); noise = rng.standard_normal(len(t))
    return sosfilt(butter(2, 4800, btype='highpass', fs=SR, output='sos'), noise)*np.exp(-t*65)*.11
K, R, H = kick(), rim(), hat()
for beat in range(56):
    # Leave the first beat sparse; let the groove build after the lockup.
    when = beat*.5
    strength = .14 if beat < 4 else .20
    if beat % 4 in (0, 2): put(bed, K, when, strength)
    if beat % 4 in (1, 3) and beat >= 4: put(bed, R, when, .18)
    if beat >= 4:
        put(bed, H, when+.25, .12, .12 if beat % 2 else -.12)
        if beat % 2 == 1: put(bed, H, when+.375, .07, -.1)

# Short, plucked chord arpeggios and low bass pulses: no sustained drone.
chords = [(110, 220, 261.63, 329.63), (87.31, 174.61, 220, 261.63),
          (130.81, 261.63, 329.63, 392), (98, 196, 246.94, 293.66),
          (110, 220, 261.63, 329.63), (87.31, 174.61, 220, 261.63),
          (98, 196, 246.94, 293.66), (110, 220, 261.63, 329.63),
          (87.31, 174.61, 220, 261.63), (130.81, 261.63, 329.63, 392),
          (98, 196, 246.94, 293.66), (110, 220, 261.63, 329.63),
          (87.31, 174.61, 220, 261.63), (110, 220, 261.63, 329.63)]
def pluck(f):
    t = sec(.58)
    return (np.sin(2*np.pi*f*t)+.36*np.sin(4*np.pi*f*t)*np.exp(-t*8)+
            .12*np.sin(6*np.pi*f*t)*np.exp(-t*16))*np.exp(-t*5.5)*(1-np.exp(-t*600))
def bass(f):
    t = sec(.43)
    return (np.sin(2*np.pi*f*t)+.25*np.sin(4*np.pi*f*t))*np.exp(-t*6)*(1-np.exp(-t*120))
for bar, (root, *notes) in enumerate(chords):
    start = bar * 2
    for i, idx in enumerate((0,1,2,1,0,2,1,2)):
        level = .042 if bar < 2 else .066
        put(bed, pluck(notes[idx]), start + i*.25, level*(1 if i%2==0 else .72), (-.12 if i%2 else .12))
    for offset in (0, 1, 1.5): put(bed, bass(root), start+offset, .115 if bar >= 2 else .075)
# Dynamic lift after 13.5 and at the closing brand reveal.
envelope = np.ones(N)
for a, b, level in [(0,2,.78),(13.5,18,1.12),(24,27,1.16)]:
    envelope[int(a*SR):int(b*SR)] *= level
# Create the pre-hit stop-down, then return precisely on the visual event.
for hit in (13.5, 24):
    a, b = int((hit-.4)*SR), int(hit*SR)
    envelope[a:b] *= np.linspace(1, .35, b-a)
bed *= envelope[:,None]
bed[:int(.15*SR)] *= np.linspace(0,1,int(.15*SR))[:,None]
bed[int(27*SR):] *= np.linspace(1,0,SR)[:,None]
meter = pyln.Meter(SR)
bed *= 10 ** ((-19.5-meter.integrated_loudness(bed))/20)

# Effect takes are rendered in memory with the bank's model-free checks.
sounds = {
 'tick': 'tap/finger', 'click': 'fit/click/floss_lid',
 'whoosh': 'whoosh_fast/tight', 'pop': 'ui_pop/soft',
 'key': 'typing_key/light', 'hit': 'cut_hit/punch',
 'swell': 'reverse_swell/dark', 'mallet': 'mallet/pluck',
 'paper': 'swipe/paper', 'confirm': 'notify/mid_wood',
}
takes = {}
for name, sound in sounds.items():
    wave, meta = bank.render(sound)
    takes[name] = (wave, meta)
    print('BANK', name, sound, meta['checks']['summary'])
    if not meta['checks']['ok']:
        raise RuntimeError(f'Choose another take: {sound}: {meta["checks"]["summary"]}')
# cue = visual time, bank role, bed-relative 50 ms peak, alignment, pan.
cues = [(.4,'tick',3,'onset',0),(1,'whoosh',5,'peak',-.1),(2,'confirm',5,'onset',0),
 (3,'whoosh',5,'peak',.1),(4.5,'click',5,'onset',0),(5.5,'whoosh',5,'peak',0),
 (5.7,'pop',5,'onset',-.2),(5.85,'pop',5,'onset',.2),(6,'pop',5,'onset',-.1),
 (6.15,'pop',5,'onset',.1),(6.3,'pop',5,'onset',0),
 (8,'tick',3,'onset',-.2),(8.5,'tick',3,'onset',0),(9,'tick',3,'onset',.2),
 (10,'click',5,'onset',0),(11,'whoosh',5,'peak',0),
 (13,'click',5,'onset',0),(13.5,'hit',7,'onset',0),
 (14,'pop',5,'onset',-.15),(14.25,'pop',5,'onset',0),(14.5,'pop',5,'onset',.15),
 (16,'click',5,'onset',0),(16.5,'paper',5,'peak',0),(17,'confirm',5,'onset',0),
 (19,'whoosh',5,'peak',0),(20,'pop',5,'onset',-.2),(20.25,'pop',5,'onset',.2),
 (20.5,'pop',5,'onset',-.1),(20.75,'pop',5,'onset',.1),(21,'pop',5,'onset',0),
 (21.5,'click',5,'onset',0),(24,'swell',6,'peak',0),(24,'hit',7,'onset',0),
 (24.4,'mallet',5,'onset',0)]
for i, when in enumerate(np.arange(11.5, 12.71, .12)):
    cues.append((float(when),'key',3,'onset',(-.12 if i%2 else .12)))
for when, name, db_over, alignment, pan in sorted(cues):
    wave, meta = takes[name]
    # Match the bank peak to a bounded ratio over the one-second local bed RMS.
    left = max(0,int((when-1)*SR)); right=max(left+1,int(when*SR))
    rms = float(np.sqrt(np.mean(bed[left:right]**2)))
    rms = max(rms, .012)
    gain = min(.60, rms * 10**(db_over/20) / 10**(meta['peak_db']/20))
    at = when - meta['peak_s' if alignment == 'peak' else 'onset_s']
    put(fx, wave, at, gain, pan)
    print('CUE', f'{when:.3f}', name, 'bed_rms_dbfs', round(20*np.log10(rms),1),
          'gain_db', round(20*np.log10(gain),1), alignment)
# Fade effects into silence in the final second too.
fx[27*SR:] *= np.linspace(1,0,SR)[:,None]
y = bed + fx
# Soft limiter preserves transient headroom and avoids digital clipping.
y = np.tanh(y * 1.15) / 1.15
loudness = meter.integrated_loudness(y)
y *= 10**((-14.5-loudness)/20)
peak = np.max(np.abs(y))
if peak > .79:
    print('HEADROOM adjustment', round(20*np.log10(.79/peak),2), 'dB')
    y *= .79 / peak
out = ROOT / 'public/promo/motion_v2.wav'
wavfile.write(out, SR, np.round(y*32767).astype(np.int16))
print('OUTPUT', out, 'lufs', round(meter.integrated_loudness(y),2),
      'peak_dbfs', round(20*np.log10(np.max(np.abs(y))),2),
      'stereo_correlation', round(np.corrcoef(y.T)[0,1],3))
