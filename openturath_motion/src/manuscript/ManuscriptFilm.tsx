import type React from "react";
import { AbsoluteFill, Audio, Sequence, Track, staticFile } from "remotion";
import { Act1MarginStatement } from "./Act1MarginStatement";
import { Act2SplitComparison } from "./Act2SplitComparison";
import { Act3MacroIbarah } from "./Act3MacroIbarah";
import { Act4FihrisIndex } from "./Act4FihrisIndex";
import { Act5MonographFinale } from "./Act5MonographFinale";
import { INK } from "./tokens";

export const ManuscriptFilm: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: INK.paper }}>
      <Sequence name="01 Premis Kertas & Margin" durationInFrames={270}>
        <Act1MarginStatement />
      </Sequence>

      <Sequence
        name="02 Belahan Perbandingan Mazhab"
        from={270}
        durationInFrames={420}
      >
        <Act2SplitComparison />
      </Sequence>

      <Sequence
        name="03 Makro Ibarah Al-Majmu"
        from={690}
        durationInFrames={330}
      >
        <Act3MacroIbarah />
      </Sequence>

      <Sequence name="04 Fihris 18 Bidang Ilmu" from={1020} durationInFrames={300}>
        <Act4FihrisIndex />
      </Sequence>

      <Sequence name="05 Penutup OpenTurath" from={1320} durationInFrames={240}>
        <Act5MonographFinale />
      </Sequence>

      <Track name="Akustik Oud, Cello, Daf & Foley">
        <Audio src={staticFile("manuscript/scholarly_acoustics.wav")} />
      </Track>
    </AbsoluteFill>
  );
};
