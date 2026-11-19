import type React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { PALETTE } from "./tokens";

type ProceduralBackdropProps = {
  readonly theme: "dark" | "light";
  readonly speed?: number;
  readonly showGrid?: boolean;
  readonly showAstrolabe?: boolean;
  readonly gridProgress?: number;
};

// Deterministic procedural dust/ink motes
const MOTES = Array.from({ length: 22 }, (_, i) => ({
  id: i,
  x: ((i * 73 + 19) % 94) + 3,
  y: ((i * 41 + 11) % 92) + 4,
  size: (i % 3) * 1.5 + 2,
  speedY: ((i % 5) + 1) * 0.42,
  phase: i * 0.7,
}));

export const ProceduralBackdrop: React.FC<ProceduralBackdropProps> = ({
  theme,
  speed = 1,
  showGrid = true,
  showAstrolabe = true,
}) => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  const isDark = theme === "dark";
  const strokeMain = isDark
    ? "rgba(250, 250, 250, 0.085)"
    : "rgba(23, 23, 23, 0.075)";
  const strokeAccent = isDark
    ? "rgba(250, 250, 250, 0.14)"
    : "rgba(23, 23, 23, 0.13)";
  const gridColor = isDark
    ? "rgba(250, 250, 250, 0.055)"
    : "rgba(23, 23, 23, 0.055)";

  const rotOuter = frame * 0.18 * speed;
  const rotInner = -frame * 0.28 * speed;
  const gridOffset = (frame * 2.4 * speed) % 96;
  const ringSize = isPortrait ? 940 : 1080;

  return (
    <AbsoluteFill style={{ overflow: "hidden", pointerEvents: "none" }}>
      {/* Radial depth light */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: isDark
            ? "radial-gradient(circle at 50% 45%, rgba(255,255,255,0.06) 0%, rgba(9,9,11,0) 64%)"
            : "radial-gradient(circle at 50% 45%, rgba(255,255,255,0.95) 0%, rgba(235,235,235,0.4) 78%)",
        }}
      />

      {/* 3D Perspective Architectural Floor Grid */}
      {showGrid && (
        <div
          style={{
            position: "absolute",
            left: "-30%",
            right: "-30%",
            bottom: isPortrait ? "-8%" : "-18%",
            height: isPortrait ? "48%" : "58%",
            perspective: 900,
            WebkitMaskImage:
              "linear-gradient(to top, rgba(0,0,0,0.85) 0%, rgba(0,0,0,0.2) 55%, transparent 100%)",
            maskImage:
              "linear-gradient(to top, rgba(0,0,0,0.85) 0%, rgba(0,0,0,0.2) 55%, transparent 100%)",
          }}
        >
          <div
            style={{
              width: "100%",
              height: "200%",
              transform: `rotateX(68deg) translateY(${gridOffset}px)`,
              transformOrigin: "center top",
              backgroundImage: `linear-gradient(to right, ${gridColor} 1px, transparent 1px), linear-gradient(to bottom, ${gridColor} 1px, transparent 1px)`,
              backgroundSize: "96px 96px",
            }}
          />
        </div>
      )}

      {/* Rotating Minimalist Islamic Geometric Astrolabe Rings */}
      {showAstrolabe && (
        <div
          style={{
            position: "absolute",
            inset: 0,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <svg
            width={ringSize}
            height={ringSize}
            viewBox="0 0 1000 1000"
            fill="none"
            style={{ opacity: 0.9 }}
          >
            {/* Outer compass ring */}
            <g transform={`rotate(${rotOuter} 500 500)`}>
              <circle
                cx={500}
                cy={500}
                r={440}
                stroke={strokeMain}
                strokeWidth={1.2}
                strokeDasharray="6 14"
              />
              <circle
                cx={500}
                cy={500}
                r={395}
                stroke={strokeAccent}
                strokeWidth={1}
              />
              {/* 8-point subtle architectural ticks */}
              {Array.from({ length: 12 }, (_, idx) => {
                const deg = idx * 30;
                return (
                  <line
                    key={deg}
                    x1={500}
                    y1={56}
                    x2={500}
                    y2={84}
                    stroke={strokeAccent}
                    strokeWidth={1.5}
                    transform={`rotate(${deg} 500 500)`}
                  />
                );
              })}
            </g>

            {/* Inner counter-rotating Rub el Hizb inspired minimalist squares */}
            <g transform={`rotate(${rotInner} 500 500)`}>
              <rect
                x={270}
                y={270}
                width={460}
                height={460}
                stroke={strokeMain}
                strokeWidth={1}
              />
              <rect
                x={270}
                y={270}
                width={460}
                height={460}
                stroke={strokeMain}
                strokeWidth={1}
                transform="rotate(45 500 500)"
              />
              <circle
                cx={500}
                cy={500}
                r={260}
                stroke={strokeMain}
                strokeWidth={1}
                strokeDasharray="2 10"
              />
            </g>
          </svg>
        </div>
      )}

      {/* Subtle Floating Depth Motes */}
      {MOTES.map((m) => {
        const yDrift = (m.y - frame * 0.06 * m.speedY * speed + 120) % 104 - 2;
        const opacity = interpolate(
          Math.sin(frame * 0.05 + m.phase),
          [-1, 1],
          [0.08, 0.32]
        );
        return (
          <div
            key={m.id}
            style={{
              position: "absolute",
              left: `${m.x}%`,
              top: `${yDrift}%`,
              width: m.size,
              height: m.size,
              borderRadius: 999,
              backgroundColor: isDark ? PALETTE.ivory : PALETTE.ink,
              opacity,
            }}
          />
        );
      })}
    </AbsoluteFill>
  );
};
