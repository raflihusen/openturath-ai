import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { Mark } from "./Mark";
import { archPath, LOADER, ms, THEME, ThemeName } from "./spec";

const ARCH_W = 72;
const ARCH_H = 88;

// Memuat: tanda logo diam, satu cahaya menyusuri garis lengkung, dan garis
// mistar di bawahnya terisi lalu kosong. Putaran mulus tanpa sambungan.
export const LoaderLoop: React.FC<{ theme: ThemeName }> = ({ theme }) => {
  const frame = useCurrentFrame();
  const t = THEME[theme];
  const loop = ms(LOADER.loop);
  const progress = (frame % loop) / loop;
  const outline = archPath(0, 0, ARCH_W, ARCH_H, true);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: t.canvas,
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 22,
        }}
      >
        <div style={{ position: "relative", width: ARCH_W, height: ARCH_H }}>
          <svg
            width={ARCH_W}
            height={ARCH_H}
            viewBox={`0 0 ${ARCH_W} ${ARCH_H}`}
            style={{ position: "absolute", inset: 0, overflow: "visible" }}
          >
            <path
              d={outline}
              fill="none"
              stroke={t.textPrimary}
              strokeOpacity={0.12}
              strokeWidth={1.5}
            />
            <path
              d={outline}
              fill="none"
              stroke={t.textPrimary}
              strokeWidth={1.5}
              strokeLinecap="round"
              pathLength={1}
              strokeDasharray={`${LOADER.sweep} ${1 + LOADER.sweep}`}
              strokeDashoffset={interpolate(
                progress,
                [0, 1],
                [LOADER.sweep, -1],
              )}
            />
          </svg>
          <Mark
            size={38}
            color={t.textPrimary}
            style={{ position: "absolute", left: (ARCH_W - 38) / 2, top: 36 }}
          />
        </div>
        <div
          style={{
            width: LOADER.trackWidth,
            height: 2,
            borderRadius: 1,
            overflow: "hidden",
            backgroundColor: `${t.textPrimary}1a`,
          }}
        >
          <div
            style={{
              width: LOADER.trackWidth * 0.36,
              height: 2,
              backgroundColor: t.textPrimary,
              translate: interpolate(
                progress,
                [0, 1],
                [
                  `${-LOADER.trackWidth * 0.36}px 0px`,
                  `${LOADER.trackWidth}px 0px`,
                ],
              ),
            }}
          />
        </div>
      </div>
    </AbsoluteFill>
  );
};
