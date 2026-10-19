import React from "react";
import { AbsoluteFill, Composition, Folder, Sequence, useCurrentFrame } from "remotion";
import "../../tema";
import { KERTAS, LEBAR, MALAM, SLIDES, TINGGI, p, type Pal } from "./kit";
import { Sampul, SlideUmum, VIS } from "./Slide";
import { VIS2 } from "./Slide2";
import { Penutup, VIS3 } from "./Slide3";

const SEMUA = { ...VIS, ...VIS2, ...VIS3 };

/** Latar gelap untuk bab pembuka dan bab peta perjalanan. */
const gelap = (bab: number) => bab === 0 || bab === 9;

const Satu: React.FC<{ indeks: number }> = ({ indeks }) => {
  const s = SLIDES[indeks];
  const c: Pal = gelap(s.bab) ? MALAM : KERTAS;
  if (s.id === "sampul") return <Sampul c={c} />;
  if (s.id === "penutup") return <Penutup c={c} />;
  const v = SEMUA[s.id];
  return <SlideUmum indeks={indeks} Vis={v?.Vis} tinggiVis={v?.tinggi} lead={v ? 70 : 24} />;
};

export const MULAI = SLIDES.reduce<number[]>(
  (acc, s, i) => [...acc, i === 0 ? 0 : acc[i - 1] + SLIDES[i - 1].durasi],
  [],
);
export const TOTAL = MULAI[MULAI.length - 1] + SLIDES[SLIDES.length - 1].durasi;

export const PengantarV2: React.FC = () => {
  // Latar mengikuti slide aktif supaya perpindahan gelap-terang tidak berkedip.
  const f = useCurrentFrame();
  const aktif = MULAI.reduce((a, v, i) => (f >= v ? i : a), 0);
  const s = SLIDES[aktif];
  const sekarang = gelap(s.bab) ? MALAM : KERTAS;
  const sebelumnya = aktif > 0 && gelap(SLIDES[aktif - 1].bab) ? MALAM : KERTAS;
  const lewat = p(f, MULAI[aktif], MULAI[aktif] + 14);
  return (
    <AbsoluteFill style={{ background: sekarang.bg }}>
      <AbsoluteFill style={{ background: sebelumnya.bg, opacity: 1 - lewat }} />
      {SLIDES.map((sl, i) => (
        <Sequence key={sl.id} name={`${i + 1}. ${sl.id}`} from={MULAI[i]} durationInFrames={sl.durasi}>
          <Satu indeks={i} />
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};

const V = { width: LEBAR, height: TINGGI, fps: 30 } as const;

export const KomposisiV2: React.FC = () => (
  <Folder name="TahawwulatV2">
    <Composition id="PengantarV2" component={PengantarV2} durationInFrames={TOTAL} {...V} />
    <Folder name="Slide">
      {SLIDES.map((s, i) => (
        <Composition
          key={s.id}
          id={`v2-${String(i + 1).padStart(2, "0")}-${s.id}`}
          component={() => <Satu indeks={i} />}
          durationInFrames={s.durasi}
          {...V}
        />
      ))}
    </Folder>
  </Folder>
);
