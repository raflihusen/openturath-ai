import type React from "react";
import {
  AbsoluteFill,
  CanvasImage,
  Easing,
  Interactive,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { ProceduralBackdrop } from "./ProceduralBackdrop";
import { CLAMP, FONT, MIHRAB_PATH, PALETTE } from "./tokens";

const SNAP = Easing.bezier(0.14, 1, 0.24, 1);

/**
 * ACT 5 (Local f 0–240 | Global f 1200–1440 | Beats 40–48 @ 120 BPM)
 * Dual Shockwave Ring Burst + Spring-Physics Emblem Lockup +
 * Cinematic Tracking-Contraction Wordmark + Shimmering CTA Pill.
 */
export const KineticAct5Finale: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();
  const isPortrait = height > width;

  // Dual shockwave rings exploding from center on the final sub-boom (f 0)
  const ring1Scale = interpolate(frame, [0, 48], [0.15, 3.6], {
    ...CLAMP,
    easing: SNAP,
  });
  const ring1Opacity = interpolate(frame, [0, 6, 48], [0, 0.65, 0], CLAMP);

  const ring2Scale = interpolate(frame, [8, 62], [0.1, 4.4], {
    ...CLAMP,
    easing: SNAP,
  });
  const ring2Opacity = interpolate(frame, [8, 16, 62], [0, 0.35, 0], CLAMP);

  // Spring physics lockup for Mihrab + Logo
  const lockupSpring = spring({
    frame,
    fps,
    config: { damping: 14, stiffness: 170, mass: 0.9 },
  });

  const mihrabDraw = interpolate(frame, [0, 42], [320, 0], {
    ...CLAMP,
    easing: SNAP,
  });

  // Cinematic letter-spacing contraction on Wordmark (f 18..68)
  const wordmarkTracking = interpolate(frame, [18, 68], [0.28, -0.025], {
    ...CLAMP,
    easing: SNAP,
  });
  const wordmarkOpacity = interpolate(frame, [16, 44], [0, 1], CLAMP);

  // CTA Pill + Shimmer sweep
  const ctaSpring = spring({
    frame: Math.max(0, frame - 66),
    fps,
    config: { damping: 16, stiffness: 160 },
  });
  const pillSheen = interpolate(frame, [95, 160], [-40, 145], CLAMP);

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.obsidian, overflow: "hidden" }}>
      <ProceduralBackdrop theme="dark" speed={0.55} />

      {/* Dual Shockwave Rings */}
      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div
          style={{
            position: "absolute",
            width: 260,
            height: 260,
            borderRadius: 999,
            border: `2px solid ${PALETTE.ivory}`,
            scale: `${ring1Scale}`,
            opacity: ring1Opacity,
          }}
        />
        <div
          style={{
            position: "absolute",
            width: 260,
            height: 260,
            borderRadius: 999,
            border: `1px solid ${PALETTE.obsidianMuted}`,
            scale: `${ring2Scale}`,
            opacity: ring2Opacity,
          }}
        />
      </AbsoluteFill>

      {/* Main Centered Finale Lockup */}
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          paddingLeft: 72,
          paddingRight: 72,
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            textAlign: "center",
            gap: isPortrait ? 30 : 22,
          }}
        >
          {/* Mihrab + Emblem Lockup */}
          <div
            style={{
              position: "relative",
              width: isPortrait ? 210 : 186,
              height: isPortrait ? 240 : 212,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              scale: `${lockupSpring}`,
            }}
          >
            <svg
              width={isPortrait ? 210 : 186}
              height={isPortrait ? 240 : 212}
              viewBox="0 0 120 148"
              fill="none"
              style={{ position: "absolute", inset: 0 }}
            >
              <path
                d={MIHRAB_PATH}
                stroke="rgba(250, 250, 250, 0.48)"
                strokeWidth={1.5}
                strokeLinecap="round"
                strokeDasharray={320}
                strokeDashoffset={mihrabDraw}
              />
            </svg>
            <div style={{ marginTop: 26 }}>
              <CanvasImage
                src={staticFile("logo_putih.png")}
                style={{
                  width: isPortrait ? 116 : 104,
                  height: isPortrait ? 116 : 104,
                  objectFit: "contain",
                }}
              />
            </div>
          </div>

          {/* Cinematic Tracking-Contraction Wordmark */}
          <Interactive.Div
            name="Finale Wordmark"
            style={{
              fontFamily: FONT.serif,
              fontSize: isPortrait ? 94 : 102,
              fontWeight: 400,
              lineHeight: 1.02,
              letterSpacing: `${wordmarkTracking}em`,
              color: PALETTE.ivory,
              opacity: wordmarkOpacity,
            }}
          >
            OpenTurath AI
          </Interactive.Div>

          {/* Arabic Seal */}
          <Interactive.Div
            name="Finale Arabic Seal"
            dir="rtl"
            lang="ar"
            style={{
              fontFamily: FONT.arabic,
              fontSize: isPortrait ? 48 : 44,
              lineHeight: 1.85,
              letterSpacing: 0,
              color: PALETTE.obsidianMuted,
              opacity: interpolate(frame, [42, 72], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
              }),
            }}
          >
            التُّرَاثُ الإِسْلَامِيُّ فِي مُتَنَاوَلِ يَدَيْكَ
          </Interactive.Div>

          {/* Shimmering Monochrome CTA Pill + Platforms */}
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              gap: 20,
              marginTop: 10,
              opacity: ctaSpring,
              scale: `${interpolate(ctaSpring, [0, 1], [0.86, 1])}`,
            }}
          >
            <div
              style={{
                position: "relative",
                overflow: "hidden",
                padding: isPortrait ? "18px 56px" : "16px 52px",
                borderRadius: 999,
                backgroundColor: PALETTE.ivory,
                color: PALETTE.obsidian,
                fontFamily: FONT.sans,
                fontSize: isPortrait ? 30 : 26,
                fontWeight: 600,
                letterSpacing: "0.06em",
              }}
            >
              openturath.id
              {/* Subtle specular sweep */}
              <div
                style={{
                  position: "absolute",
                  inset: 0,
                  background: `linear-gradient(110deg, transparent ${pillSheen - 18}%, rgba(9,9,11,0.12) ${pillSheen}%, transparent ${pillSheen + 18}%)`,
                }}
              />
            </div>

            <div
              style={{
                fontFamily: FONT.sans,
                fontSize: isPortrait ? 21 : 19,
                letterSpacing: "0.22em",
                textTransform: "uppercase",
                color: PALETTE.obsidianSubtle,
              }}
            >
              ANDROID &nbsp;·&nbsp; MACOS &nbsp;·&nbsp; WINDOWS
            </div>
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
