#!/usr/bin/env python3
"""Produce Jejak Ilmu's 30 s soundtrack from licensed source recordings.

Example:
  earshot-venv/bin/python scripts/jejak_audio.py --music /tmp/reawakening-tail.mp3 --paper /tmp/page-turn.wav
Use the original downloaded file or a contiguous excerpt of at least 27 s.
Short excerpts are slowed slightly to cover 30 s; all edits are disclosed. Licensed source files are intentionally not stored
in the repository. See public/jejak/audio/CREDITS.md for terms and attribution.
"""
import argparse
import subprocess
import tempfile
from pathlib import Path
import numpy as np
import pyloudnorm as pyln
from scipy.io import wavfile

ROOT=Path(__file__).resolve().parent.parent
SR=48000
N=30*SR
p=argparse.ArgumentParser()
p.add_argument('--music',required=True,type=Path)
p.add_argument('--paper',required=True,type=Path)
a=p.parse_args()

def decode(src,dst):
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(src),
                    '-ar',str(SR),'-ac','2','-c:a','pcm_f32le',str(dst)],check=True)

with tempfile.TemporaryDirectory(prefix='ot-jejak-audio-') as tmp:
    tmp=Path(tmp); mw=tmp/'music.wav'; pw=tmp/'paper.wav'
    decode(a.music,mw); decode(a.paper,pw)
    _,music=wavfile.read(mw); _,paper=wavfile.read(pw)
    if len(music)<27*SR: raise ValueError('Music excerpt must contain at least 27 seconds.')
    if len(music)<N:
        tempo=len(music)/N
        slower=tmp/'slower.wav'
        subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(mw),
                        '-af',f'atempo={tempo:.8f}','-ar',str(SR),'-ac','2',
                        '-c:a','pcm_f32le',str(slower)],check=True)
        _,music=wavfile.read(slower)
        print('TIME_STRETCH',round(tempo,5),'of original tempo')
    # A single continuous excerpt rather than a stitched-together track.
    if len(music)<N: music=np.pad(music,((0,N-len(music)),(0,0)))
    music=music[:N].astype(np.float64)
    paper=paper.astype(np.float64)
    music[:int(.8*SR)]*=np.linspace(0,1,int(.8*SR))[:,None]
    meter=pyln.Meter(SR)
    before=meter.integrated_loudness(music)
    music*=10**((-18-before)/20)
    # A small number of actual page sounds; no synthesized UI tics. The source
    # has its measured peak at 0.142 s; align peak to the picture cue.
    for cue,gain in [(.7,.055),(14.5,.045),(24.6,.06)]:
        start=round((cue-.142)*SR); n=min(len(paper),N-start)
        music[start:start+n]+=paper[:n]*gain
    music[-int(1.5*SR):]*=np.linspace(1,0,int(1.5*SR))[:,None]
    # Keep the recording's center clear on phone and mono playback.
    mid=(music[:,0]+music[:,1])*.5
    side=(music[:,0]-music[:,1])*.18
    music=np.column_stack((mid+side,mid-side))
    # Protect the intermediate 16-bit PCM, then let EBU loudnorm set delivery.
    peak=np.max(np.abs(music))
    if peak>.80: music*=.80/peak
    pre=tmp/'pre.wav'; wavfile.write(pre,SR,np.round(music*32767).astype(np.int16))
    out=ROOT/'public/jejak/audio/soundtrack.wav'; out.parent.mkdir(parents=True,exist_ok=True)
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(pre),
                    '-af','loudnorm=I=-16:TP=-1.8:LRA=11','-ar',str(SR),
                    '-c:a','pcm_s16le',str(out)],check=True)
    _,final=wavfile.read(out); final=final.astype(np.float64)/32768
    mono=final.mean(axis=1)
    print('OUTPUT',out,'lufs',round(meter.integrated_loudness(final),2),
          'peak_dbfs',round(20*np.log10(np.max(np.abs(final))),2),
          'correlation',round(np.corrcoef(final.T)[0,1],3),
          'mono_loss_db',round(20*np.log10(np.sqrt(np.mean(mono**2))/np.sqrt(np.mean(final**2))),3))
