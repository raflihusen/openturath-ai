import React from 'react';
import {AbsoluteFill, Audio, Img, interpolate, Sequence, staticFile, useCurrentFrame} from 'remotion';

const paper = '#FAFAFA';
const ink = '#09090B';
const sans = 'Outfit, sans-serif';
const serif = 'Newsreader, Georgia, serif';
const clamp = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;
const fade = (f: number, start = 0, end = 180) => interpolate(f, [start, start + 20, end - 20, end], [0, 1, 1, 0], clamp);
const rise = (f: number, delay = 0) => interpolate(f, [delay, delay + 35], [42, 0], clamp);

const Frame: React.FC<{dark?: boolean; children: React.ReactNode; index: string}> = ({dark = false, children, index}) => {
  const f = useCurrentFrame();
  return <AbsoluteFill style={{background: dark ? ink : paper, color: dark ? paper : ink, overflow: 'hidden', opacity: fade(f)}}>
    <div style={{position: 'absolute', top: 92, left: 88, right: 88, display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontFamily: sans, fontSize: 20, letterSpacing: 3.5, textTransform: 'uppercase', opacity: .68}}>
      <span>OpenTurath AI</span><span>{index} / 05</span>
    </div>
    <div style={{position: 'absolute', top: 133, left: 88, right: 88, height: 1, background: 'currentColor', opacity: .23}} />
    {children}
    <div style={{position: 'absolute', bottom: 92, left: 88, right: 88, display: 'flex', alignItems: 'center', gap: 15, opacity: .45}}>
      {[0,1,2,3,4].map(i => <div key={i} style={{height: 2, flex: 1, background: 'currentColor', opacity: i === Number(index) - 1 ? 1 : .23}} />)}
    </div>
  </AbsoluteFill>;
};

const Label: React.FC<{children: React.ReactNode}> = ({children}) => <div style={{fontFamily: sans, fontSize: 23, letterSpacing: 4, textTransform: 'uppercase', opacity: .58}}>{children}</div>;
const Title: React.FC<{children: React.ReactNode; delay?: number; size?: number}> = ({children, delay = 0, size = 100}) => {
  const f = useCurrentFrame();
  return <div style={{fontFamily: serif, fontWeight: 400, fontSize: size, lineHeight: 1.06, letterSpacing: -2, opacity: interpolate(f, [delay, delay + 25], [0, 1], clamp), translate: `0 ${rise(f, delay)}px`}}>{children}</div>;
};

const Opening: React.FC = () => {
  const f = useCurrentFrame();
  return <Frame dark index="01">
    <div style={{position: 'absolute', left: 88, right: 88, top: 330}}><Label>Tradisi ilmu · ruang baru</Label><div style={{height: 40}}/><Title size={110} delay={8}>Khazanah ilmu,<br/><i>lebih dekat.</i></Title></div>
    <div style={{position: 'absolute', top: 900, left: 166, width: 748, height: 710, border: '1px solid #777', borderRadius: '374px 374px 0 0', opacity: .65, scale: interpolate(f, [0, 180], [.96, 1.03], clamp)}} />
    <div style={{position: 'absolute', top: 1035, left: 225, right: 225, textAlign: 'center', fontFamily: 'Scheherazade, serif', fontSize: 150, lineHeight: 1.3, opacity: interpolate(f, [24, 65], [0, .9], clamp)}}>التراث</div>
    <div style={{position: 'absolute', top: 1330, left: 270, right: 270, textAlign: 'center', fontFamily: sans, fontSize: 30, letterSpacing: 6, opacity: .55}}>WARISAN ILMU</div>
  </Frame>;
};
const Ask: React.FC = () => {
  const f = useCurrentFrame();
  return <Frame index="02">
    <div style={{position: 'absolute', top: 290, left: 88, right: 88}}><Label>Mulai dari pertanyaan</Label><div style={{height: 35}}/><Title delay={8}>Bertanya.<br/><i>Memahami.</i></Title><p style={{fontFamily: sans, fontSize: 38, lineHeight: 1.35, marginTop: 40, maxWidth: 750, color: '#52525B'}}>Ruang untuk menemani perjalanan membaca kitab.</p></div>
    <div style={{position: 'absolute', top: 1000, left: 88, right: 88, border: '1px solid #D4D4D8', background: '#fff', padding: '48px 50px', boxShadow: '0 28px 70px #0000000b', translate: `0 ${rise(f, 28)}px`, opacity: interpolate(f, [28, 55], [0, 1], clamp)}}>
      <div style={{fontFamily: sans, fontSize: 22, letterSpacing: 3, color: '#71717A'}}>PERTANYAAN ANDA</div>
      <div style={{fontFamily: serif, fontSize: 52, lineHeight: 1.25, marginTop: 30}}>Apa makna dari<br/>ibārah ini?</div>
      <div style={{height: 1, background: '#D4D4D8', marginTop: 45}} />
      <div style={{display: 'flex', justifyContent: 'space-between', marginTop: 30, fontFamily: sans, fontSize: 25, color: '#71717A'}}><span>Mulai percakapan</span><span style={{color: ink}}>↗</span></div>
    </div>
    <div style={{position: 'absolute', bottom: 205, left: 88, fontFamily: sans, fontSize: 24, color: '#71717A'}}>Ilustrasi alur penggunaan</div>
  </Frame>;
};
const Read: React.FC = () => {
  const f = useCurrentFrame();
  return <Frame dark index="03">
    <div style={{position: 'absolute', top: 285, left: 88, right: 88}}><Label>Membaca dengan saksama</Label><div style={{height: 35}}/><Title delay={8} size={98}>Penjelasan yang<br/><i>membuka jalan.</i></Title></div>
    <div style={{position: 'absolute', top: 850, left: 88, right: 88, borderTop: '1px solid #71717A', paddingTop: 42}}>
      {['Baca penjelasan', 'Telusuri ibarah', 'Periksa rujukan'].map((s, i) => <div key={s} style={{display: 'flex', alignItems: 'center', gap: 38, borderBottom: '1px solid #3F3F46', padding: '34px 0', opacity: interpolate(f, [25 + i * 16, 45 + i * 16], [0, 1], clamp), translate: `${interpolate(f, [25 + i * 16, 45 + i * 16], [24, 0], clamp)}px 0`}}><span style={{fontFamily: sans, fontSize: 22, color: '#A1A1AA'}}>0{i+1}</span><span style={{fontFamily: serif, fontSize: 53}}>{s}</span><span style={{marginLeft: 'auto', fontSize: 32}}>↗</span></div>)}
    </div>
    <div style={{position: 'absolute', left: 88, right: 88, bottom: 240, fontFamily: sans, fontSize: 32, lineHeight: 1.45, color: '#A1A1AA'}}>Setiap jawaban adalah awal untuk<br/>membaca dan menelaah lebih jauh.</div>
  </Frame>;
};
const Study: React.FC = () => {
  const f = useCurrentFrame();
  return <Frame index="04">
    <div style={{position: 'absolute', top: 300, left: 88, right: 88}}><Label>Ilmu tumbuh bersama</Label><div style={{height: 35}}/><Title delay={8} size={103}>Dari layar,<br/><i>kembali ke ilmu.</i></Title></div>
    <div style={{position: 'absolute', top: 940, left: 88, right: 88, height: 420}}>
      {[0,1,2].map(i => <div key={i} style={{position: 'absolute', left: 25 + i * 170, top: 45 + i * 32, width: 410, height: 300, border: '1px solid #A1A1AA', background: i === 2 ? ink : paper, color: i === 2 ? paper : ink, padding: 34, boxSizing: 'border-box', rotate: `${-6 + i * 6}deg`, translate: `0 ${rise(f, 22 + i * 10)}px`, opacity: interpolate(f, [22 + i * 10, 45 + i * 10], [0, 1], clamp)}}><div style={{fontFamily: sans, fontSize: 20, letterSpacing: 2.5, opacity: .65}}>0{i+1} / BELAJAR</div><div style={{marginTop: 90, fontFamily: serif, fontSize: 49}}>{['Baca', 'Telaah', 'Diskusi'][i]}</div></div>)}
    </div>
    <div style={{position: 'absolute', left: 88, right: 100, bottom: 220, fontFamily: sans, fontSize: 38, lineHeight: 1.4}}>Lanjutkan pembacaan dan<br/>diskusikan bersama guru.</div>
  </Frame>;
};
const Close: React.FC = () => {
  const f = useCurrentFrame();
  return <Frame dark index="05">
    <div style={{position: 'absolute', top: 360, left: 160, right: 160, height: 760, border: '1px solid #52525B', borderRadius: '380px 380px 0 0', opacity: .72}} />
    <div style={{position: 'absolute', top: 570, left: 0, right: 0, display: 'flex', justifyContent: 'center', opacity: interpolate(f, [15, 55], [0,1], clamp), translate: `0 ${rise(f,15)}px`}}><Img src={staticFile('promo/mark_white.svg')} style={{width: 190, height: 240, objectFit: 'contain'}} /></div>
    <div style={{position: 'absolute', top: 1195, left: 88, right: 88, textAlign: 'center'}}><div style={{fontFamily: serif, fontSize: 92, letterSpacing: -2}}>OpenTurath AI</div><div style={{fontFamily: sans, fontSize: 35, marginTop: 25, color: '#D4D4D8'}}>Teman membaca khazanah Islam.</div><div style={{width: 70, height: 1, background: '#71717A', margin: '55px auto'}}/><div style={{fontFamily: sans, fontSize: 30, letterSpacing: 1}}>openturath.id <span style={{marginLeft: 14}}>↗</span></div></div>
  </Frame>;
};

export const PromoElegan: React.FC = () => <AbsoluteFill style={{background: ink}}>
  <Audio src={staticFile('promo/elegan_audio.wav')} />
  <Sequence from={0} durationInFrames={180}><Opening /></Sequence>
  <Sequence from={180} durationInFrames={180}><Ask /></Sequence>
  <Sequence from={360} durationInFrames={180}><Read /></Sequence>
  <Sequence from={540} durationInFrames={180}><Study /></Sequence>
  <Sequence from={720} durationInFrames={180}><Close /></Sequence>
</AbsoluteFill>;
