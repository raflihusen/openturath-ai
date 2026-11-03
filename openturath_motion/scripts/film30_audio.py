#!/usr/bin/env python3
"""Original 30 s product score, 120 BPM, with cue-aligned earshot effects.
Uses local procedural instruments and earshot's synthesized sound bank. The
melody and arrangement are original; no prerecorded music is used. Run with
the earshot virtualenv Python, ffmpeg and pyloudnorm installed.
"""
from pathlib import Path
import json
import subprocess
import tempfile
import numpy as np
from scipy.signal import butter, sosfilt
from scipy.io import wavfile
import pyloudnorm as pyln
from earshot.forge import bank

ROOT=Path(__file__).resolve().parent.parent
SR=48000
N=30*SR
rng=np.random.default_rng(301201)
bed=np.zeros((N,2),np.float64)
fx=np.zeros_like(bed)
meter=pyln.Meter(SR)
def tt(d): return np.arange(round(d*SR))/SR
def put(dst, wave, when, gain, pan=0):
    x=np.asarray(wave,np.float64)
    if x.ndim==1: x=np.column_stack((x,x))
    start=max(0,round(when*SR)); x=x[:N-start]
    dst[start:start+len(x),0]+=x[:,0]*gain*(1-max(0,pan))
    dst[start:start+len(x),1]+=x[:,1]*gain*(1+min(0,pan))
def checked(sound,pitch=None):
    wave,meta=bank.render(sound,pitch=pitch)
    print('BANK',sound,pitch,meta['checks']['summary'],flush=True)
    if not meta['checks']['ok']: raise RuntimeError(meta['checks']['summary'])
    return wave,meta
# Tuned mallets provide a 4-note identity, with phrase variation rather than
# four repeated chords. Their envelopes are bank-rendered and checked.
melody={n:checked('mallet/marimba',n)[0] for n in ['A4','C5','E5','G5']}
accent={n:checked('mallet/celesta',n)[0] for n in ['A5','C6','E5']}
notes={'A4':440.0,'C5':523.25,'E5':659.26,'G5':783.99}

def pluck(freq,d=.48):
    x=tt(d)
    # Midrange partials and a short noise contact transient keep the motif
    # legible on phone speakers, with no continuous oscillator bed.
    contact=sosfilt(butter(2,[900,5000],btype='bandpass',fs=SR,output='sos'),rng.standard_normal(len(x)))
    return (np.sin(2*np.pi*freq*x)+.65*np.sin(4*np.pi*freq*x)*np.exp(-x*7)+
            .38*np.sin(6*np.pi*freq*x)*np.exp(-x*14))*np.exp(-x*5.8)*(1-np.exp(-x*550))+contact*.12*np.exp(-x*70)
def bass(freq):
    x=tt(.38)
    # Harmonic content gives the bass an audible midrange on small speakers.
    return (np.sin(2*np.pi*freq*x)+.52*np.sin(4*np.pi*freq*x)+.20*np.sin(6*np.pi*freq*x))*np.exp(-x*8)*(1-np.exp(-x*130))
def kick():
    x=tt(.22); phase=2*np.pi*np.cumsum(52+94*np.exp(-x*34))/SR
    return np.sin(phase)*np.exp(-x*17)
def snare():
    x=tt(.13); z=rng.standard_normal(len(x))
    return (sosfilt(butter(2,[850,6800],btype='bandpass',fs=SR,output='sos'),z)*.24+
            .20*np.sin(2*np.pi*870*x))*np.exp(-x*31)
def hat():
    x=tt(.075); z=rng.standard_normal(len(x))
    return sosfilt(butter(2,5000,btype='highpass',fs=SR,output='sos'),z)*np.exp(-x*54)*.17
K,S,H=kick(),snare(),hat()
# Groove is revoiced over a 60-beat arc, with a deliberate query gap at 11.7.
for b in range(60):
    time=b*.5
    if time<2 or 11.5<=time<13.5 or 25.5<=time<26.5 or time>=29: continue
    if time<7.5: energy=.75
    elif time<11.5: energy=.68
    elif time<20.5: energy=1.0
    elif time<24.5: energy=.82
    elif time<25.5: energy=.55
    else: energy=.9
    if b%4 in (0,3): put(bed,K,time,.14*energy)
    if b%4==2: put(bed,S,time,.13*energy)
    if b%2==1:
        put(bed,H,time+.25,.11*energy, -.10 if b%4==1 else .10)
    if b%8 in (0,3,6):
        roots=[110,98,87.31,130.81,110,98,87.31,110]
        put(bed,bass(roots[(b//8)%len(roots)]),time,.08*energy)
# Compose distinct scored phrases: tease, rising entry, sparse middle, main
# line, reprise, and resolving signature. Times align to a 120 BPM grid.
phrases=[
 ([(0.25,'A4'),(.75,'C5'),(1.25,'E5')],.043),
 ([(2.25,'A4'),(2.5,'C5'),(3,'E5'),(3.5,'G5')],.064),
 ([(4.25,'E5'),(4.5,'C5'),(5,'A4'),(5.5,'C5')],.060),
 ([(6.25,'A4'),(6.5,'C5'),(7,'E5')],.067),
 ([(8.25,'C5'),(8.75,'E5'),(9.25,'G5'),(9.75,'E5')],.055),
 ([(10.5,'C5'),(11,'A4')],.052),
 ([(13.5,'A4'),(13.75,'C5'),(14.25,'E5'),(14.75,'G5'),(15.25,'E5'),(15.75,'C5')],.078),
 ([(16.5,'A4'),(16.75,'C5'),(17.25,'E5'),(17.75,'G5')],.074),
 ([(18.5,'G5'),(18.75,'E5'),(19.25,'C5'),(19.75,'A4')],.068),
 ([(20.5,'A4'),(20.75,'C5'),(21.25,'E5'),(21.75,'G5')],.066),
 ([(22.5,'E5'),(23,'C5'),(23.5,'A4')],.058),
 ([(26.5,'A4'),(26.75,'C5'),(27.25,'E5'),(27.75,'A4')],.078),
]
for phrase,gain in phrases:
    for i,(when,note) in enumerate(phrase):
        put(bed,melody[note],when,gain,(-.12 if i%2 else .12))
        put(bed,pluck(notes[note],.35),when,gain*.28,(.10 if i%2 else -.10))
# Three high harmonics carry the closing identity without a long tail.
for when,n in [(26.5,'A5'),(26.75,'C6'),(27.25,'E5')]: put(bed,accent[n],when,.038, .10)
# Short stop-down around both the answer reveal and final mark.
envelope=np.ones(N)
for hit in [13.5,26.5]:
    a,b=int((hit-.36)*SR),int(hit*SR); envelope[a:b]*=np.linspace(1,.40,b-a)
envelope[:int(.12*SR)]*=np.linspace(0,1,int(.12*SR))
envelope[int(29.3*SR):]*=np.linspace(1,0,N-int(29.3*SR))
bed*=envelope[:,None]
bed*=10**((-19.2-meter.integrated_loudness(bed))/20)

ids={'tick':'tap/finger','paper':'swipe/paper','confirm':'notify/mid_wood',
     'whoosh':'swish/bright','click':'fit/click/floss_lid','pop':'ui_pop/soft',
     'key':'typing_key/crisp','hit':'cut_hit/punch'}
takes={role:checked(sound) for role,sound in ids.items()}
manifest=json.loads((ROOT/'scripts/film30_cues.json').read_text())
for cue in manifest['cues']:
    when,role=cue['time'],cue['role']; wave,meta=takes[role]
    l=max(0,int((when-1)*SR)); r=max(l+1,int(when*SR))
    local=max(float(np.sqrt(np.mean(bed[l:r]**2))),.012)
    gain=min(.48,local*10**(cue['bed_over_db']/20)/10**(meta['peak_db']/20))
    # The stop-down makes the local bed near-silent; keep the final fold and
    # logo audible without multiplying all other cues.
    if cue['label']=='fold': gain=max(gain,.04)
    if cue['label']=='logo': gain=max(gain,.08)
    offset=meta['peak_s' if cue['alignment']=='peak' else 'onset_s']
    put(fx,wave,when-offset,gain,cue['pan'])
    print('CUE',f'{when:.3f}',role,'bed_rms',round(20*np.log10(local),1),
          'gain_db',round(20*np.log10(gain),1),cue['alignment'],cue['label'],flush=True)
fx[int(29.3*SR):]*=np.linspace(1,0,N-int(29.3*SR))[:,None]
y=np.tanh((bed+fx)*1.1)/1.1
peak=np.max(np.abs(y))
if peak>.76: y*=.76/peak
out=ROOT/'public/film30/soundtrack.wav'; out.parent.mkdir(parents=True,exist_ok=True)
with tempfile.TemporaryDirectory(prefix='ot-film30-master-') as tmp:
    pre=Path(tmp)/'pre.wav'; wavfile.write(pre,SR,np.round(y*32767).astype(np.int16))
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(pre),
                    '-af','loudnorm=I=-14:TP=-1.7:LRA=11','-ar',str(SR),
                    '-c:a','pcm_s16le',str(out)],check=True)
_,master=wavfile.read(out); master=master.astype(np.float64)/32768
mono=master.mean(axis=1)
print('OUTPUT',out,'lufs',round(meter.integrated_loudness(master),2),
      'peak_dbfs',round(20*np.log10(np.max(np.abs(master))),2),
      'correlation',round(np.corrcoef(master.T)[0,1],3),
      'mono_loss_db',round(20*np.log10(np.sqrt(np.mean(mono**2))/np.sqrt(np.mean(master**2))),3))
