import { ThreeCanvas } from "@remotion/three";
import { useEffect, useState } from "react";
import { AbsoluteFill, cancelRender, continueRender, delayRender, useCurrentFrame } from "remotion";
import * as THREE from "three";
import { fontsReady } from "./fonts";
import { Overlay } from "./Overlay";
import { C, p, useLayout } from "./theme";
import { World } from "./world/World";

/** Darkens the copy area so type stays legible over the 3D scene. */
const Scrim = () => {
  const { portrait } = useLayout();
  return (
    <AbsoluteFill
      style={{
        background: portrait
          ? "linear-gradient(180deg, rgba(11,11,11,0.94) 0%, rgba(11,11,11,0.86) 24%, rgba(11,11,11,0.5) 38%, rgba(11,11,11,0) 52%, rgba(11,11,11,0) 82%, rgba(11,11,11,0.6) 100%)"
          : "linear-gradient(90deg, rgba(11,11,11,0.92) 0%, rgba(11,11,11,0.6) 38%, rgba(11,11,11,0) 60%)",
      }}
    />
  );
};

const Vignette = () => (
  <AbsoluteFill
    style={{ background: "radial-gradient(ellipse at 50% 50%, rgba(0,0,0,0) 55%, rgba(0,0,0,0.55) 100%)" }}
  />
);

/** Static film grain (seeded by frame), very light. */
const Grain = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{ opacity: 0.06, mixBlendMode: "overlay" }}>
      <svg width="100%" height="100%">
        <filter id="g">
          <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed={frame % 24} />
        </filter>
        <rect width="100%" height="100%" filter="url(#g)" />
      </svg>
    </AbsoluteFill>
  );
};

/** Fade from/to black at the very ends. */
const Edges = () => {
  const frame = useCurrentFrame();
  const o = 1 - p(frame, 0, 14);
  return <AbsoluteFill style={{ background: C.night, opacity: o }} />;
};

export const Film = () => {
  const { width, height, portrait } = useLayout();
  const [handle] = useState(() => delayRender("fonts"));
  const [ready, setReady] = useState(false);
  useEffect(() => {
    fontsReady.then(() => {
      setReady(true);
      continueRender(handle);
    }).catch((e) => cancelRender(e));
  }, [handle]);
  return (
    <AbsoluteFill style={{ background: C.night }}>
      {ready ? (
        <ThreeCanvas
          width={width}
          height={height}
          gl={{ antialias: true, toneMapping: THREE.ACESFilmicToneMapping, preserveDrawingBuffer: true }}
          dpr={1}
          camera={{ fov: 46, position: [0, 0, 5] }}
        >
          <World portrait={portrait} />
        </ThreeCanvas>
      ) : null}
      <Vignette />
      <Scrim />
      {ready ? <Overlay /> : null}
      <Grain />
      <Edges />
    </AbsoluteFill>
  );
};
