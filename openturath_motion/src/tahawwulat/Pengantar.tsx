import React from "react";
import { AbsoluteFill, Composition, Folder, Sequence } from "remotion";
import "../tema";
import { SlideView } from "./Kerangka";
import { LEBAR, SLIDES, TINGGI } from "./kit";

// Slide disusun berurutan tanpa transisi silang: aplikasi melompat ke awal
// tiap slide (manifest), sehingga setiap slide harus mulai bersih.
export const MULAI = SLIDES.reduce<number[]>(
  (acc, s, i) => [...acc, i === 0 ? 0 : acc[i - 1] + SLIDES[i - 1].durasi],
  [],
);
export const TOTAL = MULAI[MULAI.length - 1] + SLIDES[SLIDES.length - 1].durasi;

export const PengantarTahawwulat: React.FC = () => (
  <AbsoluteFill>
    {SLIDES.map((s, i) => (
      <Sequence key={s.id} name={`${i + 1}. ${s.id}`} from={MULAI[i]} durationInFrames={s.durasi}>
        <SlideView indeks={i} />
      </Sequence>
    ))}
  </AbsoluteFill>
);

const V = { width: LEBAR, height: TINGGI, fps: 30 } as const;

export const KomposisiTahawwulat: React.FC = () => (
  <Folder name="Tahawwulat">
    <Composition id="PengantarTahawwulat" component={PengantarTahawwulat} durationInFrames={TOTAL} {...V} />
    <Folder name="Slide">
      {SLIDES.map((s, i) => (
        <Composition
          key={s.id}
          id={`slide-${String(i + 1).padStart(2, "0")}-${s.id}`}
          component={() => <SlideView indeks={i} />}
          durationInFrames={s.durasi}
          {...V}
        />
      ))}
    </Folder>
  </Folder>
);
