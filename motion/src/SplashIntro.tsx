import React from "react";
import { AbsoluteFill, Easing, interpolate, useCurrentFrame } from "remotion";
import { SERIF } from "./fonts";
import { Mark } from "./Mark";
import {
  archPath,
  EASE_OUT_CUBIC,
  EASE_OUT_QUART,
  ms,
  SPLASH,
  THEME,
  ThemeName,
} from "./spec";

const clamp = {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
} as const;

const ARCH_W = 92;
const ARCH_H = 112;

// Pintu dibuka: garis lengkung ditulis, tanda logo muncul di dalamnya,
// tiga gema merambat ke luar, lalu wordmark naik.
export const SplashIntro: React.FC<{ theme: ThemeName }> = ({ theme }) => {
  const frame = useCurrentFrame();
  const t = THEME[theme];
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
          gap: 28,
        }}
      >
        <div style={{ position: "relative", width: ARCH_W, height: ARCH_H }}>
          {Array.from({ length: SPLASH.echoCount }).map((_, index) => {
            const start = ms(SPLASH.echoStart + index * SPLASH.echoStagger);
            const end = start + ms(SPLASH.echoDuration);
            return (
              <svg
                key={index}
                width={ARCH_W}
                height={ARCH_H}
                viewBox={`0 0 ${ARCH_W} ${ARCH_H}`}
                style={{
                  position: "absolute",
                  inset: 0,
                  overflow: "visible",
                  transformOrigin: "50% 62%",
                  scale: interpolate(
                    frame,
                    [start, end],
                    [1, 1.45 + index * 0.4],
                    { ...clamp, easing: Easing.bezier(...EASE_OUT_QUART) },
                  ),
                  opacity: interpolate(
                    frame,
                    [start, start + 6, end],
                    [0, 0.34 - index * 0.08, 0],
                    clamp,
                  ),
                }}
              >
                <path
                  d={outline}
                  fill="none"
                  stroke={t.textPrimary}
                  strokeWidth={1}
                  vectorEffect="non-scaling-stroke"
                />
              </svg>
            );
          })}
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
              strokeWidth={1.5}
              strokeLinecap="round"
              pathLength={1}
              strokeDasharray={1}
              strokeDashoffset={interpolate(
                frame,
                [ms(SPLASH.drawStart), ms(SPLASH.drawEnd)],
                [1, 0],
                { ...clamp, easing: Easing.bezier(...EASE_OUT_CUBIC) },
              )}
            />
          </svg>
          <Mark
            size={48}
            color={t.textPrimary}
            style={{
              position: "absolute",
              left: (ARCH_W - 48) / 2,
              top: 46,
              opacity: interpolate(
                frame,
                [ms(SPLASH.markStart), ms(SPLASH.markEnd)],
                [0, 1],
                { ...clamp, easing: Easing.bezier(...EASE_OUT_CUBIC) },
              ),
              scale: interpolate(
                frame,
                [ms(SPLASH.markStart), ms(SPLASH.markEnd)],
                [0.9, 1],
                { ...clamp, easing: Easing.bezier(...EASE_OUT_CUBIC) },
              ),
            }}
          />
        </div>
        <div
          style={{
            fontFamily: SERIF,
            fontWeight: 600,
            fontSize: 36,
            letterSpacing: -0.6,
            color: t.textPrimary,
            opacity: interpolate(
              frame,
              [ms(SPLASH.wordStart), ms(SPLASH.wordEnd)],
              [0, 1],
              { ...clamp, easing: Easing.bezier(...EASE_OUT_CUBIC) },
            ),
            translate: interpolate(
              frame,
              [ms(SPLASH.wordStart), ms(SPLASH.wordEnd)],
              [`0px ${SPLASH.wordShift}px`, "0px 0px"],
              { ...clamp, easing: Easing.bezier(...EASE_OUT_CUBIC) },
            ),
          }}
        >
          OpenTurath
        </div>
      </div>
    </AbsoluteFill>
  );
};
