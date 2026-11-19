import type React from "react";
import {
  AbsoluteFill,
  Easing,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { CLAMP, EASE_INK, EASE_SHIFT, INK, TYPE } from "./tokens";

export const Act1MarginStatement: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  // Vertical book-margin rule draws top to bottom before sweeping into Act 2.
  const ruleDrawY = interpolate(frame, [4, 48], [0, 1], {
    ...CLAMP,
    easing: EASE_INK,
  });

  // Ink curtain expands from the margin rule to transition cleanly into dark Act 2.
  const wipeProgress = interpolate(frame, [224, 268], [0, 1], {
    ...CLAMP,
    easing: EASE_SHIFT,
  });

  const marginLeft = isPortrait ? 88 : 168;
  const contentRight = isPortrait ? 84 : 180;
  const statementSize = isPortrait ? 66 : 72;
  const answerSize = isPortrait ? 82 : 90;

  return (
    <AbsoluteFill style={{ backgroundColor: INK.paper, overflow: "hidden" }}>
      {/* Classical kitab vertical margin line (identity motif) */}
      <div
        style={{
          position: "absolute",
          top: isPortrait ? 140 : 108,
          bottom: isPortrait ? 140 : 108,
          left: marginLeft,
          width: 2,
          backgroundColor: INK.ink,
          transformOrigin: "top center",
          scale: `1 ${ruleDrawY}`,
        }}
      />

      {/* Asymmetric left-aligned monograph prose */}
      <div
        style={{
          position: "absolute",
          top: 0,
          bottom: 0,
          left: marginLeft + (isPortrait ? 44 : 68),
          right: contentRight,
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          gap: isPortrait ? 52 : 42,
        }}
      >
        <div
          style={{
            fontFamily: TYPE.sans,
            fontSize: isPortrait ? 24 : 20,
            fontWeight: 600,
            color: INK.inkMuted,
            opacity: interpolate(frame, [10, 32], [0, 1], CLAMP),
          }}
        >
          OpenTurath
        </div>

        <div style={{ overflow: "hidden" }}>
          <Interactive.Div
            name="Act 1 Opening Premise"
            style={{
              fontFamily: TYPE.serif,
              fontSize: statementSize,
              fontWeight: 400,
              lineHeight: 1.24,
              letterSpacing: "-0.015em",
              color: INK.ink,
              maxWidth: isPortrait ? 840 : 1240,
              opacity: interpolate(frame, [16, 48], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: Easing.bezier(0.22, 1, 0.36, 1),
              }),
              translate: interpolate(
                frame,
                [16, 52],
                ["0px 48px", "0px 0px"],
                {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.22, 1, 0.36, 1),
                }
              ),
            }}
          >
            Saat mencari hukum jual beli tanpa lafal akad, kita tidak butuh
            tebakan.
          </Interactive.Div>
        </div>

        <div
          style={{
            height: 1,
            width: isPortrait ? 220 : 280,
            backgroundColor: INK.paperRule,
            transformOrigin: "left center",
            scale: `${interpolate(frame, [120, 152], [0, 1], {
              ...CLAMP,
              easing: EASE_INK,
            })} 1`,
          }}
        />

        <div style={{ overflow: "hidden" }}>
          <Interactive.Div
            name="Act 1 Resolution Line"
            style={{
              fontFamily: TYPE.serif,
              fontSize: answerSize,
              fontWeight: 600,
              fontStyle: "italic",
              lineHeight: 1.14,
              letterSpacing: "-0.02em",
              color: INK.ink,
              opacity: interpolate(frame, [138, 168], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: Easing.bezier(0.22, 1, 0.36, 1),
              }),
              translate: interpolate(
                frame,
                [138, 174],
                ["0px 56px", "0px 0px"],
                {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.22, 1, 0.36, 1),
                }
              ),
            }}
          >
            Kita butuh ibarah kitabnya.
          </Interactive.Div>
        </div>
      </div>

      {/* Ink curtain sweep expanding from the left margin line */}
      <div
        style={{
          position: "absolute",
          top: 0,
          bottom: 0,
          left: 0,
          width: `${wipeProgress * 104}%`,
          backgroundColor: INK.darkBg,
        }}
      />
    </AbsoluteFill>
  );
};
