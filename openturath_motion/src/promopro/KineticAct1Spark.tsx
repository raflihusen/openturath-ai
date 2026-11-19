import type React from "react";
import {
  AbsoluteFill,
  Easing,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { ProceduralBackdrop } from "./ProceduralBackdrop";
import { CLAMP, FONT, MIHRAB_PATH, PALETTE } from "./tokens";

const SNAP = Easing.bezier(0.12, 1, 0.22, 1);
const ACCEL = Easing.bezier(0.75, 0, 0.9, 0.2);

/**
 * ACT 1 (f 0–240 | 0.0s–4.0s @ 60fps | Beats 0–8 @ 120 BPM)
 * Kinetic staccato typography synced to 120 BPM + Mihrab Portal Zoom-Through match-cut.
 */
export const KineticAct1Spark: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  // Beat 0 (f 0–30): Center spark expands horizontally into razor-sharp horizon line
  const sparkLineScaleX = interpolate(frame, [0, 26], [0, 1], {
    ...CLAMP,
    easing: SNAP,
  });
  const sparkRingScale = interpolate(frame, [0, 36], [0.1, 3.2], {
    ...CLAMP,
    easing: SNAP,
  });
  const sparkRingOpacity = interpolate(frame, [0, 8, 36], [0, 0.55, 0], CLAMP);

  // Beat 3 (f 90–96): Crisp 6-frame editorial invert flash on kick hit!
  const isInvertFlash = frame >= 90 && frame < 96;

  // Continuous kinetic camera push-in on staccato words
  const word1Active = frame >= 24 && frame < 60;
  const word2Active = frame >= 60 && frame < 90;
  const word3Active = frame >= 90 && frame < 126;
  const portalActive = frame >= 120;

  // Beat 4–8 (f 120–240): Mihrab Portal draws and camera flies THROUGH it into bright paper!
  const mihrabDraw = interpolate(frame, [120, 178], [320, 0], {
    ...CLAMP,
    easing: SNAP,
  });
  const portalScale = interpolate(frame, [126, 188, 238], [0.78, 1.15, 22], {
    ...CLAMP,
    easing: ACCEL,
  });
  const portalFillOpacity = interpolate(frame, [186, 224], [0, 1], CLAMP);
  const portalWhiteout = interpolate(frame, [218, 239], [0, 1], CLAMP);

  const bigDisplay = isPortrait ? 116 : 148;
  const bgColor = isInvertFlash ? PALETTE.paper : PALETTE.obsidian;
  const fgColor = isInvertFlash ? PALETTE.ink : PALETTE.ivory;

  return (
    <AbsoluteFill style={{ backgroundColor: bgColor, overflow: "hidden" }}>
      <ProceduralBackdrop
        theme={isInvertFlash ? "light" : "dark"}
        speed={1.4}
        showGrid={!portalActive}
      />

      {/* Beat 0 Spark Ring */}
      {frame < 40 && (
        <AbsoluteFill
          style={{ justifyContent: "center", alignItems: "center" }}
        >
          <div
            style={{
              width: 240,
              height: 240,
              borderRadius: 999,
              border: `2px solid ${PALETTE.ivory}`,
              scale: `${sparkRingScale}`,
              opacity: sparkRingOpacity,
            }}
          />
        </AbsoluteFill>
      )}

      {/* Horizon Split Line (f 0..124) */}
      {frame < 124 && (
        <AbsoluteFill
          style={{ justifyContent: "center", alignItems: "center" }}
        >
          <div
            style={{
              width: isPortrait ? "84%" : "72%",
              height: 1.5,
              backgroundColor: isInvertFlash
                ? "rgba(23,23,23,0.35)"
                : "rgba(250,250,250,0.35)",
              scale: `${sparkLineScaleX} 1`,
              opacity: interpolate(frame, [110, 124], [1, 0], CLAMP),
            }}
          />
        </AbsoluteFill>
      )}

      {/* BEAT 1 (f 24–60): "RIBUAN KITAB." split-mask emergence */}
      {word1Active && (
        <AbsoluteFill
          style={{
            justifyContent: "center",
            alignItems: "center",
            gap: 14,
            scale: `${interpolate(frame, [24, 60], [0.94, 1.07], CLAMP)}`,
          }}
        >
          <div style={{ overflow: "hidden", paddingBottom: 8 }}>
            <Interactive.Div
              name="Beat 1 Top"
              style={{
                fontFamily: FONT.sans,
                fontSize: isPortrait ? 24 : 22,
                fontWeight: 600,
                letterSpacing: "0.35em",
                color: PALETTE.obsidianMuted,
                translate: interpolate(
                  frame,
                  [24, 38],
                  ["0px 40px", "0px 0px"],
                  {
                    extrapolateLeft: "clamp",
                    extrapolateRight: "clamp",
                    easing: Easing.bezier(0.12, 1, 0.22, 1),
                  }
                ),
              }}
            >
              01 · KHAZANAH KLASIK
            </Interactive.Div>
          </div>
          <div style={{ overflow: "hidden" }}>
            <Interactive.Div
              name="Beat 1 Display"
              style={{
                fontFamily: FONT.serif,
                fontSize: bigDisplay,
                fontWeight: 400,
                letterSpacing: "-0.03em",
                lineHeight: 0.98,
                color: fgColor,
                textAlign: "center",
                translate: interpolate(
                  frame,
                  [26, 44],
                  ["0px 130px", "0px 0px"],
                  {
                    extrapolateLeft: "clamp",
                    extrapolateRight: "clamp",
                    easing: Easing.bezier(0.12, 1, 0.22, 1),
                  }
                ),
              }}
            >
              Ribuan kitab.
            </Interactive.Div>
          </div>
        </AbsoluteFill>
      )}

      {/* BEAT 2 (f 60–90): "SATU RUANG." + Giant Arabic Watermark Fly-In */}
      {word2Active && (
        <AbsoluteFill
          style={{
            justifyContent: "center",
            alignItems: "center",
            scale: `${interpolate(frame, [60, 90], [0.92, 1.1], CLAMP)}`,
          }}
        >
          {/* Giant translucent Arabic depth watermark */}
          <div
            dir="rtl"
            lang="ar"
            style={{
              position: "absolute",
              fontFamily: FONT.arabic,
              fontSize: isPortrait ? 460 : 520,
              lineHeight: 1.4,
              letterSpacing: 0,
              color: "rgba(250, 250, 250, 0.06)",
              scale: `${interpolate(frame, [60, 90], [0.7, 1.25], {
                ...CLAMP,
                easing: SNAP,
              })}`,
            }}
          >
            عِلْمٌ
          </div>
          <Interactive.Div
            name="Beat 2 Display"
            style={{
              fontFamily: FONT.serif,
              fontSize: bigDisplay,
              fontWeight: 400,
              fontStyle: "italic",
              letterSpacing: "-0.03em",
              color: fgColor,
              textAlign: "center",
              scale: interpolate(frame, [60, 74], [1.28, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: Easing.bezier(0.12, 1, 0.22, 1),
              }),
            }}
          >
            Satu ruang.
          </Interactive.Div>
        </AbsoluteFill>
      )}

      {/* BEAT 3 (f 90–126): "TANPA RIUH." with Beat 3 Invert Flash Slam */}
      {word3Active && (
        <AbsoluteFill
          style={{
            justifyContent: "center",
            alignItems: "center",
            gap: 20,
            scale: `${interpolate(frame, [90, 126], [1.14, 0.96], {
              ...CLAMP,
              easing: SNAP,
            })}`,
          }}
        >
          <Interactive.Div
            name="Beat 3 Display"
            style={{
              fontFamily: FONT.sans,
              fontSize: isPortrait ? 104 : 132,
              fontWeight: 600,
              letterSpacing: "-0.04em",
              color: fgColor,
              textAlign: "center",
            }}
          >
            Tanpa riuh.
          </Interactive.Div>
          <div
            dir="rtl"
            lang="ar"
            style={{
              fontFamily: FONT.arabic,
              fontSize: isPortrait ? 56 : 62,
              lineHeight: 1.85,
              letterSpacing: 0,
              color: isInvertFlash
                ? PALETTE.inkSecondary
                : PALETTE.obsidianMuted,
            }}
          >
            تُرَاثُ العُلَمَاءِ بَيْنَ يَدَيْكَ
          </div>
        </AbsoluteFill>
      )}

      {/* BEAT 4–8 (f 120–240): MIHRAB PORTAL FLY-THROUGH MATCH-CUT */}
      {portalActive && (
        <AbsoluteFill
          style={{
            justifyContent: "center",
            alignItems: "center",
          }}
        >
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              scale: `${portalScale}`,
              transformOrigin: "50% 54%",
            }}
          >
            <svg
              width={isPortrait ? 360 : 380}
              height={isPortrait ? 440 : 460}
              viewBox="0 0 120 148"
              fill="none"
            >
              {/* Filled bright paper portal inside the mihrab */}
              <path
                d={`${MIHRAB_PATH} Z`}
                fill={PALETTE.paper}
                opacity={portalFillOpacity}
              />
              {/* Razor sharp mihrab outline */}
              <path
                d={MIHRAB_PATH}
                stroke={PALETTE.ivory}
                strokeWidth={1.8}
                strokeLinecap="round"
                strokeDasharray={320}
                strokeDashoffset={mihrabDraw}
              />
            </svg>
          </div>

          {/* Floating kinetic caption before portal swallow */}
          {frame < 198 && (
            <div
              style={{
                position: "absolute",
                bottom: isPortrait ? "16%" : "12%",
                fontFamily: FONT.sans,
                fontSize: isPortrait ? 26 : 24,
                fontWeight: 600,
                letterSpacing: "0.28em",
                textTransform: "uppercase",
                color: PALETTE.obsidianMuted,
                opacity: interpolate(frame, [132, 152, 180, 196], [0, 1, 1, 0], CLAMP),
              }}
            >
              MEMASUKI OPENTURATH AI
            </div>
          )}

          {/* Seamless whiteout into Act 2 Paper */}
          <AbsoluteFill
            style={{
              backgroundColor: PALETTE.paper,
              opacity: portalWhiteout,
              pointerEvents: "none",
            }}
          />
        </AbsoluteFill>
      )}
    </AbsoluteFill>
  );
};
