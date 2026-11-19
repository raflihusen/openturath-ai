import type React from "react";
import {
  AbsoluteFill,
  CanvasImage,
  Easing,
  Interactive,
  interpolate,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { CLAMP, EASE_INK, INK, TYPE } from "./tokens";

export const Act5MonographFinale: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  const emblemOpacity = interpolate(frame, [6, 36], [0, 1], {
    ...CLAMP,
    easing: EASE_INK,
  });
  const emblemY = interpolate(frame, [6, 40], [28, 0], {
    ...CLAMP,
    easing: EASE_INK,
  });

  const ruleScaleX = interpolate(frame, [38, 80], [0, 1], {
    ...CLAMP,
    easing: EASE_INK,
  });

  const ctaReveal = interpolate(frame, [68, 108], [0, 1], {
    ...CLAMP,
    easing: EASE_INK,
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: INK.darkBg,
        justifyContent: "center",
        alignItems: "center",
        paddingLeft: isPortrait ? 84 : 160,
        paddingRight: isPortrait ? 84 : 160,
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          textAlign: "center",
          gap: isPortrait ? 36 : 28,
          maxWidth: isPortrait ? 900 : 1200,
        }}
      >
        <div
          style={{
            opacity: emblemOpacity,
            translate: `0px ${emblemY}px`,
          }}
        >
          <CanvasImage
            src={staticFile("logo_putih.png")}
            style={{
              width: isPortrait ? 112 : 96,
              height: isPortrait ? 112 : 96,
              objectFit: "contain",
            }}
          />
        </div>

        <Interactive.Div
          name="Act 5 Wordmark"
          style={{
            fontFamily: TYPE.serif,
            fontSize: isPortrait ? 92 : 96,
            fontWeight: 400,
            letterSpacing: "-0.02em",
            lineHeight: 1.04,
            color: INK.darkText,
            opacity: interpolate(frame, [16, 48], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
              easing: Easing.bezier(0.22, 1, 0.36, 1),
            }),
            translate: interpolate(
              frame,
              [16, 52],
              ["0px 26px", "0px 0px"],
              {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: Easing.bezier(0.22, 1, 0.36, 1),
              }
            ),
          }}
        >
          OpenTurath
        </Interactive.Div>

        <div
          style={{
            width: isPortrait ? 140 : 180,
            height: 1,
            backgroundColor: INK.darkRule,
            scale: `${ruleScaleX} 1`,
          }}
        />

        <Interactive.Div
          name="Act 5 Value Statement"
          style={{
            fontFamily: TYPE.sans,
            fontSize: isPortrait ? 34 : 30,
            lineHeight: 1.48,
            color: INK.darkMuted,
            maxWidth: isPortrait ? 760 : 820,
            opacity: interpolate(frame, [42, 76], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
          }}
        >
          Telaah 18 bidang ilmu turats langsung dari ibarah kitabnya.
        </Interactive.Div>

        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 20,
            marginTop: 14,
            opacity: ctaReveal,
            translate: `0px ${interpolate(ctaReveal, [0, 1], [20, 0])}px`,
          }}
        >
          <div
            style={{
              padding: isPortrait ? "20px 48px" : "18px 44px",
              borderRadius: 999,
              backgroundColor: INK.darkText,
              color: INK.darkBg,
              fontFamily: TYPE.sans,
              fontSize: isPortrait ? 28 : 24,
              fontWeight: 600,
            }}
          >
            Unduh di openturath.id
          </div>

          <div
            style={{
              fontFamily: TYPE.sans,
              fontSize: isPortrait ? 22 : 19,
              color: INK.darkSubtle,
            }}
          >
            Android · macOS · Windows
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};
