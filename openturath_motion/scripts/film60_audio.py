#!/usr/bin/env python3
"""Original 60-second, 120-BPM score + procedural earshot SFX.
Run using earshot's Python virtualenv. All sounds are synthesized locally.
The effects bank contains original procedural sounds and CC0-fitted models;
those fitted models synthesize samples and are not recordings.
"""
from pathlib import Path
import json
import subprocess
import tempfile
import numpy as np
import pyloudnorm as pyln
from scipy.signal import butter, sosfilt
from scipy.io import wavfile
from earshot.forge import bank

ROOT = Path(__file__).resolve().parent.parent
SR = 48000
N = 60 * SR
rng = np.random.default_rng(604120)
bed = np.zeros((N, 2), np.float64)
fx = np.zeros_like(bed)
meter = pyln.Meter(SR)
def t(d): return np.arange(int(d * SR)) / SR
def put(dst, wave, when, gain, pan=0):
    x = np.asarray(wave, np.float64)
    if x.ndim == 1: x = np.column_stack((x,x))
    start = max(0, round(when*SR)); x = x[:N-start]
    dst[start:start+len(x),0] += x[:,0] * gain * (1-max(0,pan))
    dst[start:start+len(x),1] += x[:,1] * gain * (1+min(0,pan))

def kick():
    x=t(.3); phase=2*np.pi*np.cumsum(47+87*np.exp(-x*30))/SR
    return np.sin(phase)*np.exp(-x*13)
def rim():
    x=t(.11); noise=rng.standard_normal(len(x))
    return (sosfilt(butter(2,[850,4700],btype='bandpass',fs=SR,output='sos'),noise)*.19+
            np.sin(2*np.pi*710*x)*.23)*np.exp(-x*34)
def shaker():
    x=t(.075); noise=rng.standard_normal(len(x))
    return sosfilt(butter(2,5000,btype='highpass',fs=SR,output='sos'),noise)*np.exp(-x*58)*.10
def pluck(f):
    x=t(.6)
    return (np.sin(2*np.pi*f*x)+.45*np.sin(4*np.pi*f*x)*np.exp(-x*8)+
            .17*np.sin(6*np.pi*f*x)*np.exp(-x*16))*np.exp(-x*6)*(1-np.exp(-x*600))
def bass(f):
    x=t(.42)
    return (np.sin(2*np.pi*f*x)+.27*np.sin(4*np.pi*f*x))*np.exp(-x*6)*(1-np.exp(-x*120))
K,R,H=kick(),rim(),shaker()
# Each 4/4 bar = 2 seconds; arrangement changes are explicit, not loops of
# the earlier soundtrack. Five sections leave space for the actual product UI.
chords=[(110,220,261.63,329.63),(87.31,174.61,220,261.63),
        (130.81,261.63,329.63,392),(98,196,246.94,293.66)]
for bar in range(30):
    start=bar*2
    if start < 6: intensity=.46
    elif start < 22: intensity=.86
    elif start < 34: intensity=.62
    elif start < 46: intensity=1.0
    elif start < 52: intensity=.75
    elif start < 56: intensity=.46
    else: intensity=.58
    root,*notes=chords[bar%4]
    if start >= 4 and start < 56:
        put(bed,K,start,.17*intensity)
        put(bed,R,start+1,.15*intensity)
        # Half-second texture every second bar, rather than a constant hat.
        if bar%2==0 and intensity>.65:
            put(bed,H,start+.75,.10*intensity,.08)
            put(bed,H,start+1.75,.08*intensity,-.08)
        put(bed,bass(root),start,.11*intensity)
        if intensity>.8: put(bed,bass(root),start+1.5,.065*intensity)
    pattern=((0,0),(.5,1),(1,2),(1.5,1)) if intensity>.75 else ((0,0),(1,2))
    for i,(offset,index) in enumerate(pattern):
        put(bed,pluck(notes[index]),start+offset,.068*intensity,(-.09 if i%2 else .09))
# Short stop-downs make room before the answer and brand reveal.
envelope=np.ones(N)
for hit in (33,56.5):
    a,b=int((hit-.4)*SR),int(hit*SR)
    envelope[a:b] *= np.linspace(1,.42,b-a)
envelope[:int(.3*SR)] *= np.linspace(0,1,int(.3*SR))
envelope[59*SR:] *= np.linspace(1,0,SR)
bed *= envelope[:,None]
bed *= 10 ** ((-20.0-meter.integrated_loudness(bed))/20)

sound_ids={'tick':'tap/finger','paper':'swipe/paper','confirm':'notify/mid_wood',
 'whoosh':'whoosh_fast/tight','click':'fit/click/floss_lid','pop':'ui_pop/soft',
 'key':'typing_key/crisp','hit':'cut_hit/punch','mallet':'mallet/pluck'}
takes={}
for role,sound in sound_ids.items():
    wave,meta=bank.render(sound)
    print('BANK',role,sound,meta['checks']['summary'])
    if not meta['checks']['ok']: raise RuntimeError(meta['checks']['summary'])
    takes[role]=(wave,meta)
manifest=json.loads((ROOT/'scripts/film60_cues.json').read_text())
for cue in manifest['cues']:
    when,role=cue['time'],cue['role']; wave,meta=takes[role]
    left=max(0,int((when-1)*SR)); right=max(left+1,int(when*SR))
    local=max(float(np.sqrt(np.mean(bed[left:right]**2))),.010)
    gain=min(.50,local*10**(cue['bed_over_db']/20)/10**(meta['peak_db']/20))
    when_start=when-meta['peak_s' if cue['alignment']=='peak' else 'onset_s']
    put(fx,wave,when_start,gain,cue['pan'])
    print('CUE',f'{when:.3f}',role,'local_bed_rms_dbfs',round(20*np.log10(local),1),
          'gain_db',round(20*np.log10(gain),1),cue['alignment'],cue['label'])
fx[59*SR:] *= np.linspace(1,0,SR)[:,None]
y=np.tanh((bed+fx)*1.15)/1.15
# First provide headroom, then an EBU loudness master at 48 kHz.
peak=np.max(np.abs(y))
if peak>.75: y*=.75/peak
out=ROOT/'public/film60/soundtrack.wav'
out.parent.mkdir(parents=True,exist_ok=True)
with tempfile.TemporaryDirectory(prefix='ot-film60-master-') as tmp:
    pre=Path(tmp)/'pre.wav'
    wavfile.write(pre,SR,np.round(y*32767).astype(np.int16))
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(pre),
                    '-af','loudnorm=I=-14.5:TP=-1.5:LRA=11','-ar',str(SR),
                    '-c:a','pcm_s16le',str(out)],check=True)
_,master=wavfile.read(out); master=master.astype(np.float64)/32768
mono=master.mean(axis=1)
mono_loss=20*np.log10(np.sqrt(np.mean(mono**2))/np.sqrt(np.mean(master**2)))
print('OUTPUT',out,'lufs',round(meter.integrated_loudness(master),2),
      'sample_peak_dbfs',round(20*np.log10(np.max(np.abs(master))),2),
      'correlation',round(np.corrcoef(master.T)[0,1],3),'mono_loss_db',round(mono_loss,3))
