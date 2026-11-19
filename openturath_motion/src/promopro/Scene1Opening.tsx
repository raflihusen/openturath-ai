import type React from "react";
import {
  AbsoluteFill,
  Easing,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { EditorialChrome } from "./EditorialChrome";
import { CLAMP, EASE_EDITORIAL, FONT, MIHRAB_PATH, PALETTE } from "./tokens";

export const Scene1Opening: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();
  const isPortrait = height > width;

  // Mihrab architectural line drawing
  const pathLength = 320;
  const dashOffset = interpolate(frame, [6, 1.4 * fps], [pathLength, 0], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  const archOpacity = interpolate(frame, [0, 0.4 * fps], [0, 1], CLAMP);

  // Subtle ambient vertical parallax
  const slowDriftY = interpolate(frame, [0, 5.6 * fps], [14, -14], CLAMP);

  // Subtle horizontal divider rule
  const dividerScaleX = interpolate(frame, [1.5 * fps, 2.5 * fps], [0, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  const headlineSize = isPortrait ? 96 : 116;
  const subheadlineSize = isPortrait ? 44 : 48;
  const arabicSize = isPortrait ? 52 : 56;

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.obsidian }}>
      <EditorialChrome theme="dark" folio="01" section="PENGANTAR" />

      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          paddingLeft: isPortrait ? 80 : 140,
          paddingRight: isPortrait ? 80 : 140,
          translate: `0px ${slowDriftY}px`,
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            textAlign: "center",
            gap: isPortrait ? 36 : 28,
            maxWidth: isPortrait ? 920 : 1400,
          }}
        >
          {/* Architectural Mihrab Arch */}
          <div style={{ opacity: archOpacity, marginBottom: 8 }}>
            <svg
              width={isPortrait ? 120 : 108}
              height={isPortrait ? 148 : 132}
              viewBox="0 0 120 148"
              fill="none"
            >
              <path
                d={MIHRAB_PATH}
                stroke={PALETTE.ivory}
                strokeWidth={2}
                strokeLinecap="round"
                strokeDasharray={pathLength}
                strokeDashoffset={dashOffset}
              />
              <circle
                cx={60}
                cy={48}
                r={4}
                fill={PALETTE.ivory}
                opacity={interpolate(frame, [1.0 * fps, 1.5 * fps], [0, 0.9], CLAMP)}
              />
            </svg>
          </div>

          {/* Primary Headline Line 1 */}
          <div style={{ overflow: "hidden", paddingBottom: 8 }}>
            <Interactive.Div
              name="Opening Headline 1"
              style={{
                fontFamily: FONT.serif,
                fontSize: headlineSize,
                fontWeight: 400,
                lineHeight: 1.06,
                letterSpacing: "-0.025em",
                color: PALETTE.ivory,
                opacity: interpolate(frame, [0.5 * fps, 1.3 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.16, 1, 0.3, 1),
                }),
                translate: interpolate(
                  frame,
                  [0.5 * fps, 1.4 * fps],
                  ["0px 56px", "0px 0px"],
                  {
                    extrapolateLeft: "clamp",
                    extrapolateRight: "clamp",
                    easing: Easing.bezier(0.16, 1, 0.3, 1),
                  }
                ),
              }}
            >
              Khazanah ulama.
            </Interactive.Div>
          </div>

          {/* Primary Headline Line 2 */}
          <div style={{ overflow: "hidden", paddingBottom: 8, marginTop: -18 }}>
            <Interactive.Div
              name="Opening Headline 2"
              style={{
                fontFamily: FONT.serif,
                fontSize: headlineSize,
                fontWeight: 400,
                fontStyle: "italic",
                lineHeight: 1.08,
                letterSpacing: "-0.02em",
                color: PALETTE.obsidianMuted,
                opacity: interpolate(frame, [1.2 * fps, 2.0 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.16, 1, 0.3, 1),
                }),
                translate: interpolate(
                  frame,
                  [1.2 * fps, 2.1 * fps],
                  ["0px 56px", "0px 0px"],
                  {
                    extrapolateLeft: "clamp",
                    extrapolateRight: "clamp",
                    easing: Easing.bezier(0.16, 1, 0.3, 1),
                  }
                ),
              }}
            >
              Kini lebih dekat.
            </Interactive.Div>
          </div>

          {/* Hairline editorial rule */}
          <div
            style={{
              width: isPortrait ? 180 : 220,
              height: 1,
              backgroundColor: "rgba(250, 250, 250, 0.25)",
              scale: `${dividerScaleX} 1`,
              marginTop: 8,
            }}
          />

          {/* Classical Arabic Subtitle */}
          <Interactive.Div
            name="Opening Arabic Subtitle"
            dir="rtl"
            lang="ar"
            style={{
              fontFamily: FONT.arabic,
              fontSize: arabicSize,
              fontWeight: 400,
              lineHeight: 1.85,
              letterSpacing: 0,
              color: PALETTE.ivory,
              opacity: interpolate(frame, [2.0 * fps, 2.9 * fps], [0, 0.92], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: Easing.bezier(0.16, 1, 0.3, 1),
              }),
              translate: interpolate(
                frame,
                [2.0 * fps, 2.9 * fps],
                ["0px 24px", "0px 0px"],
                {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.16, 1, 0.3, 1),
                }
              ),
            }}
          >
            تُرَاثُ العُلَمَاءِ بَيْنَ يَدَيْكَ
          </Interactive.Div>

          {/* Quiet supporting caption */}
          <Interactive.Div
            name="Opening Supporting Copy"
            style={{
              fontFamily: FONT.sans,
              fontSize: subheadlineSize * 0.65,
              fontWeight: 400,
              lineHeight: 1.5,
              color: PALETTE.obsidianSubtle,
              maxWidth: isPortrait ? 720 : 880,
              opacity: interpolate(frame, [2.7 * fps, 3.5 * fps], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: Easing.bezier(0.16, 1, 0.3, 1),
              }),
            }}
          >
            Ruang telaah turats klasik dengan rujukan ibarah yang jernih.
          </Interactive.Div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
