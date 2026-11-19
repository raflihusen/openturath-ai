import type React from "react";
import { AbsoluteFill, Audio, Sequence, Track, staticFile } from "remotion";
import { KineticAct1Spark } from "./KineticAct1Spark";
import { KineticAct2Matrix } from "./KineticAct2Matrix";
import { KineticAct3Showcase3D } from "./KineticAct3Showcase3D";
import { KineticAct4DisciplinesWall } from "./KineticAct4DisciplinesWall";
import { KineticAct5Finale } from "./KineticAct5Finale";
import { PALETTE } from "./tokens";

/**
 * OpenTurath AI — High-Craft Kinetic Motion Graphic (120 BPM · 24.0s @ 60fps = 1440 frames)
 * Every cut is a seamless visual match-cut synced to original procedural audio & SFX:
 *   f 0–240    (0.0–4.0s)   : Kinetic Staccato + Mihrab Portal Zoom-Through
 *   f 240–480  (4.0–8.0s)   : 3D Fanning Kitab Carousel + Card-to-App Expansion Morph
 *   f 480–900  (8.0–15.0s)  : 3D Camera Fly-Over App UI + Cursor Clicks + Hero Ibarah Lift
 *   f 900–1200 (15.0–20.0s) : Tilted 3D 18-Discipline Kinetic Wall + Center Implosion
 *   f 1200–1440 (20.0–24.0s): Dual Shockwave Ring Burst + Spring Emblem Lockup + Finale
 */
export const PromoProFilm: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.obsidian }}>
      <Sequence name="01 Kinetic Spark & Portal" from={0} durationInFrames={240}>
        <KineticAct1Spark />
      </Sequence>

      <Sequence name="02 3D Kitab Carousel" from={240} durationInFrames={240}>
        <KineticAct2Matrix />
      </Sequence>

      <Sequence name="03 3D App Fly-Over" from={480} durationInFrames={420}>
        <KineticAct3Showcase3D />
      </Sequence>

      <Sequence name="04 18 Disciplines 3D Wall" from={900} durationInFrames={300}>
        <KineticAct4DisciplinesWall />
      </Sequence>

      <Sequence name="05 Shockwave Finale" from={1200} durationInFrames={240}>
        <KineticAct5Finale />
      </Sequence>

      <Track name="Original 120 BPM Soundtrack & SFX">
        <Audio src={staticFile("promopro/kinetic_120bpm.wav")} />
      </Track>
    </AbsoluteFill>
  );
};
