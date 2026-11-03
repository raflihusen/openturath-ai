#!/usr/bin/env python3
"""Create the 30 s product-film working mix from the licensed Mixkit MP3.

Download the publisher's item 175 to a temporary file, then run:
  python scripts/productfilm_audio.py --input /tmp/ot-product-175.mp3
The original stock file is intentionally not committed. The WAV is an
intermediate for the larger film, not a standalone music release.
"""
import argparse
from pathlib import Path
import subprocess

p=argparse.ArgumentParser()
p.add_argument('--input',type=Path,required=True)
a=p.parse_args()
root=Path(__file__).resolve().parent.parent
out=root/'public/productfilm/audio/master.wav'
out.parent.mkdir(parents=True,exist_ok=True)
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-ss','54.9',
                '-i',str(a.input),'-t','30',
                '-af','afade=t=in:st=0:d=0.25,afade=t=out:st=28.8:d=1.2,loudnorm=I=-14.5:TP=-1.8:LRA=11',
                '-ar','48000','-ac','2','-c:a','pcm_s16le',str(out)],check=True)
print(out)
