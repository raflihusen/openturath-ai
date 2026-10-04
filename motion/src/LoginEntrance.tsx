import React from "react";
import { AbsoluteFill, Easing, interpolate, useCurrentFrame } from "remotion";
import { SANS, SERIF } from "./fonts";
import { Mark } from "./Mark";
import {
  archPath,
  EASE_OUT_CUBIC,
  FPS,
  LOGIN,
  ms,
  THEME,
  ThemeName,
} from "./spec";

const clamp = {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
} as const;

const PANEL_W = 358;
const PANEL_H = 288;

// Gema lengkung: tujuh lapisan seperti lorong, terbangun dari yang terdalam.
const ArchEcho: React.FC = () => {
  const frame = useCurrentFrame();
  const top = PANEL_H * 0.12;
  const bottom = PANEL_H * 1.25;
  const vanish = PANEL_H * 0.62;
  const width = Math.min(PANEL_W * 0.56, (bottom - top) * 0.74);
  const cx = PANEL_W / 2;
  const seconds = frame / FPS;
  const wave = (phase: number) => {
    const s = 0.5 + 0.5 * Math.sin(phase * 2 * Math.PI);
    return s * s * (3 - 2 * s);
  };
  const breath = (seconds * 1000) / LOGIN.breath;

  return (
    <svg
      width={PANEL_W}
      height={PANEL_H}
      viewBox={`0 0 ${PANEL_W} ${PANEL_H}`}
      style={{ position: "absolute", inset: 0 }}
    >
      <defs>
        <radialGradient id="glow">
          <stop offset="0" stopColor="#fff" stopOpacity={1} />
          <stop offset="1" stopColor="#fff" stopOpacity={0} />
        </radialGradient>
        <linearGradient id="fade" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#fff" stopOpacity={1} />
          <stop offset="0.5" stopColor="#fff" stopOpacity={1} />
          <stop offset="1" stopColor="#fff" stopOpacity={0} />
        </linearGradient>
      </defs>
      <circle
        cx={cx}
        cy={vanish + (bottom - vanish) * 0.1}
        r={width * 0.46}
        fill="url(#glow)"
        opacity={
          interpolate(frame, [0, ms(LOGIN.glowEnd)], [0, 1], {
            ...clamp,
            easing: Easing.bezier(...EASE_OUT_CUBIC),
          }) *
          (0.06 + 0.06 * wave(breath))
        }
      />
      {Array.from({ length: LOGIN.layers }).map((_, i) => {
        const depth = i / (LOGIN.layers - 1);
        const start = ms((LOGIN.layers - 1 - i) * LOGIN.layerStagger);
        const end = start + ms(LOGIN.layerDuration);
        const pulse = wave(breath - (LOGIN.layers - 1 - i) * 0.085);
        const scale = (1 - depth * 0.74) * (1 + 0.012 * (pulse - 0.5));
        const w = width * scale;
        const y = vanish - (vanish - top) * scale;
        const h = vanish + (bottom - vanish) * scale - y;
        return (
          <g
            key={i}
            style={{
              transformOrigin: `${cx}px ${vanish}px`,
              opacity: interpolate(frame, [start, end], [0, 1], {
                ...clamp,
                easing: Easing.bezier(...EASE_OUT_CUBIC),
              }),
              scale: interpolate(frame, [start, end], [0.94, 1], {
                ...clamp,
                easing: Easing.bezier(...EASE_OUT_CUBIC),
              }),
            }}
          >
            <path
              d={archPath(cx - w / 2, y, w, h)}
              fill="url(#fade)"
              fillOpacity={0.018 + 0.016 * pulse}
            />
            <path
              d={archPath(cx - w / 2, y, w, h, true)}
              fill="none"
              stroke="url(#fade)"
              strokeOpacity={0.07 + 0.03 * depth + 0.09 * pulse}
              strokeWidth={1}
            />
          </g>
        );
      })}
    </svg>
  );
};

const Reveal: React.FC<{
  at: number;
  shift?: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({ at, shift = LOGIN.revealShift, children, style }) => {
  const frame = useCurrentFrame();
  const range = [ms(at), ms(at + LOGIN.revealDuration)];
  return (
    <div
      style={{
        ...style,
        opacity: interpolate(frame, range, [0, 1], {
          ...clamp,
          easing: Easing.bezier(...EASE_OUT_CUBIC),
        }),
        translate: interpolate(frame, range, [`0px ${shift}px`, "0px 0px"], {
          ...clamp,
          easing: Easing.bezier(...EASE_OUT_CUBIC),
        }),
      }}
    >
      {children}
    </div>
  );
};

export const LoginEntrance: React.FC<{ theme: ThemeName }> = ({ theme }) => {
  const t = THEME[theme];
  return (
    <AbsoluteFill style={{ backgroundColor: t.canvas, fontFamily: SANS }}>
      <div
        style={{
          position: "absolute",
          left: 24,
          top: 24,
          display: "flex",
          alignItems: "center",
          gap: 10,
        }}
      >
        <Mark size={28} color={t.textPrimary} />
        <div
          style={{
            fontFamily: SERIF,
            fontWeight: 600,
            fontSize: 18,
            letterSpacing: -0.4,
            color: t.textPrimary,
          }}
        >
          OpenTurath
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          left: 16,
          top: 76,
          width: PANEL_W,
          height: PANEL_H,
          borderRadius: 20,
          overflow: "hidden",
          backgroundColor: "#171717",
        }}
      >
        <ArchEcho />
      </div>
      <div style={{ position: "absolute", left: 24, right: 24, top: 452 }}>
        {["Masuk ke", "OpenTurath"].map((line, index) => (
          <Reveal
            key={line}
            at={LOGIN.headlineStart + index * LOGIN.lineStagger}
            style={{
              fontFamily: SERIF,
              fontWeight: 600,
              fontSize: 36,
              lineHeight: 1.15,
              letterSpacing: -1,
              color: t.textPrimary,
            }}
          >
            {line}
          </Reveal>
        ))}
        <Reveal
          at={LOGIN.subtitleStart}
          style={{
            marginTop: 12,
            fontSize: 16,
            lineHeight: 1.5,
            color: t.textSecondary,
          }}
        >
          Lanjutkan telaah kitab dengan akun Google Anda.
        </Reveal>
        <Reveal
          at={LOGIN.buttonStart}
          shift={8}
          style={{
            marginTop: 24,
            height: 50,
            borderRadius: 999,
            backgroundColor: t.accent,
            color: t.onAccent,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontWeight: 600,
            fontSize: 16,
          }}
        >
          Lanjutkan dengan Google
        </Reveal>
        <Reveal
          at={LOGIN.legalStart}
          shift={0}
          style={{
            marginTop: 20,
            fontSize: 12,
            lineHeight: 1.5,
            color: t.textSecondary,
          }}
        >
          Dengan masuk, Anda menyetujui Ketentuan Layanan dan Kebijakan
          Privasi
        </Reveal>
      </div>
    </AbsoluteFill>
  );
};
