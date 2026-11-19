import type React from "react";
import { TransitionSeries, linearTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { wipe } from "@remotion/transitions/wipe";
import {
  AbsoluteFill,
  Audio,
  Track,
  interpolate,
  staticFile,
  useVideoConfig,
} from "remotion";
import { Scene1Opening } from "./Scene1Opening";
import { Scene2Monograph } from "./Scene2Monograph";
import { Scene3ProductShowcase } from "./Scene3ProductShowcase";
import { Scene4Disciplines } from "./Scene4Disciplines";
import { Scene5Finale } from "./Scene5Finale";
import { CLAMP, PALETTE, SCENE_DURATIONS, TRANSITION_FRAMES } from "./tokens";

export const PromoProFilm: React.FC = () => {
  const { durationInFrames, fps } = useVideoConfig();

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.obsidian }}>
      <TransitionSeries>
        <TransitionSeries.Sequence
          name="01 Pengantar"
          durationInFrames={SCENE_DURATIONS.opening}
        >
          <Scene1Opening />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={wipe({ direction: "from-bottom" })}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />

        <TransitionSeries.Sequence
          name="02 Ruang Baca"
          durationInFrames={SCENE_DURATIONS.monograph}
        >
          <Scene2Monograph />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />

        <TransitionSeries.Sequence
          name="03 Rujukan Ibarah"
          durationInFrames={SCENE_DURATIONS.showcase}
        >
          <Scene3ProductShowcase />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={slide({ direction: "from-right" })}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />

        <TransitionSeries.Sequence
          name="04 18 Bidang Ilmu"
          durationInFrames={SCENE_DURATIONS.disciplines}
        >
          <Scene4Disciplines />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />

        <TransitionSeries.Sequence
          name="05 Penutup"
          durationInFrames={SCENE_DURATIONS.finale}
        >
          <Scene5Finale />
        </TransitionSeries.Sequence>
      </TransitionSeries>

      <Track name="Soundtrack">
        <Audio
          src={staticFile("film60/soundtrack.wav")}
          endAt={durationInFrames}
          volume={(f) => {
            const fadeIn = interpolate(f, [0, 1.2 * fps], [0, 0.85], CLAMP);
            const fadeOut = interpolate(
              f,
              [durationInFrames - 2.2 * fps, durationInFrames],
              [0.85, 0],
              CLAMP
            );
            return Math.min(fadeIn, fadeOut);
          }}
        />
      </Track>
    </AbsoluteFill>
  );
};
