import type React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { CLAMP, EASE_EDITORIAL, FONT, PALETTE } from "./tokens";

type EditorialChromeProps = {
  readonly theme: "dark" | "light";
  readonly folio: string;
  readonly section: string;
  readonly showTopRule?: boolean;
};

/**
 * Museum-grade architectural editorial frame:
 * subtle hairline border, folio numbering, and quiet corner registration marks.
 */
export const EditorialChrome: React.FC<EditorialChromeProps> = ({
  theme,
  folio,
  section,
  showTopRule = true,
}) => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();
  const isPortrait = height > width;

  const padX = isPortrait ? 72 : 96;
  const padY = isPortrait ? 88 : 64;
  const lineColor =
    theme === "dark" ? "rgba(250, 250, 250, 0.12)" : "rgba(23, 23, 23, 0.12)";
  const textColor =
    theme === "dark" ? PALETTE.obsidianMuted : PALETTE.inkSecondary;

  const chromeOpacity = interpolate(frame, [0, 0.5 * fps], [0, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  const ruleScaleX = interpolate(frame, [0, 0.8 * fps], [0, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  return (
    <AbsoluteFill
      style={{
        pointerEvents: "none",
        opacity: chromeOpacity,
      }}
    >
      {/* Subtle architectural vignette / grain texture via CSS radial */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            theme === "dark"
              ? "radial-gradient(circle at 50% 38%, rgba(255,255,255,0.035) 0%, rgba(9,9,11,0) 68%)"
              : "radial-gradient(circle at 50% 42%, rgba(255,255,255,0.75) 0%, rgba(246,246,246,0) 72%)",
        }}
      />

      {/* Top Editorial Header Bar */}
      {showTopRule && (
        <div
          style={{
            position: "absolute",
            top: padY,
            left: padX,
            right: padX,
            display: "flex",
            flexDirection: "column",
            gap: 16,
          }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              fontFamily: FONT.sans,
              fontSize: isPortrait ? 20 : 18,
              fontWeight: 600,
              letterSpacing: "0.18em",
              textTransform: "uppercase",
              color: textColor,
            }}
          >
            <span>OPENTURATH AI</span>
            <span>
              {folio} &nbsp;·&nbsp; {section}
            </span>
          </div>
          <div
            style={{
              height: 1,
              width: "100%",
              backgroundColor: lineColor,
              transformOrigin: "left center",
              scale: `${ruleScaleX} 1`,
            }}
          />
        </div>
      )}

      {/* Bottom subtle architectural hairline */}
      <div
        style={{
          position: "absolute",
          bottom: padY,
          left: padX,
          right: padX,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          paddingTop: 16,
          borderTop: `1px solid ${lineColor}`,
          fontFamily: FONT.sans,
          fontSize: isPortrait ? 18 : 16,
          letterSpacing: "0.14em",
          textTransform: "uppercase",
          color:
            theme === "dark" ? PALETTE.obsidianSubtle : PALETTE.inkTertiary,
        }}
      >
        <span>KHAZANAH TURATS ISLAM</span>
        <span>MONOCHROME SCHOLARLY EDITION</span>
      </div>
    </AbsoluteFill>
  );
};
