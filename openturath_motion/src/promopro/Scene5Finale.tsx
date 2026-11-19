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
import { EditorialChrome } from "./EditorialChrome";
import { CLAMP, EASE_EDITORIAL, FONT, MIHRAB_PATH, PALETTE } from "./tokens";

export const Scene5Finale: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();
  const isPortrait = height > width;

  // Mihrab ring draws around the emblem
  const pathLen = 320;
  const dashOffset = interpolate(frame, [6, 1.3 * fps], [pathLen, 0], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  const logoScale = interpolate(frame, [0.35 * fps, 1.3 * fps], [0.88, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });
  const logoOpacity = interpolate(frame, [0.35 * fps, 1.1 * fps], [0, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  const ctaOpacity = interpolate(frame, [2.1 * fps, 2.9 * fps], [0, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });
  const ctaY = interpolate(frame, [2.1 * fps, 2.9 * fps], [24, 0], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.obsidian }}>
      <EditorialChrome theme="dark" folio="05" section="OPENTURATH" />

      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          paddingLeft: isPortrait ? 80 : 120,
          paddingRight: isPortrait ? 80 : 120,
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            textAlign: "center",
            gap: isPortrait ? 34 : 26,
          }}
        >
          {/* Architectural Mihrab + Emblem Lockup */}
          <div
            style={{
              position: "relative",
              width: isPortrait ? 220 : 196,
              height: isPortrait ? 250 : 224,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <svg
              width={isPortrait ? 220 : 196}
              height={isPortrait ? 250 : 224}
              viewBox="0 0 120 148"
              fill="none"
              style={{ position: "absolute", inset: 0 }}
            >
              <path
                d={MIHRAB_PATH}
                stroke="rgba(250, 250, 250, 0.35)"
                strokeWidth={1.2}
                strokeLinecap="round"
                strokeDasharray={pathLen}
                strokeDashoffset={dashOffset}
              />
            </svg>

            <div
              style={{
                opacity: logoOpacity,
                scale: `${logoScale}`,
                marginTop: 28,
              }}
            >
              <CanvasImage
                src={staticFile("logo_putih.png")}
                style={{
                  width: isPortrait ? 124 : 112,
                  height: isPortrait ? 124 : 112,
                  objectFit: "contain",
                }}
              />
            </div>
          </div>

          {/* Wordmark */}
          <Interactive.Div
            name="Finale Wordmark"
            style={{
              fontFamily: FONT.serif,
              fontSize: isPortrait ? 92 : 96,
              fontWeight: 400,
              letterSpacing: "-0.025em",
              lineHeight: 1.05,
              color: PALETTE.ivory,
              opacity: interpolate(frame, [0.9 * fps, 1.7 * fps], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: Easing.bezier(0.16, 1, 0.3, 1),
              }),
              translate: interpolate(
                frame,
                [0.9 * fps, 1.7 * fps],
                ["0px 30px", "0px 0px"],
                {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.16, 1, 0.3, 1),
                }
              ),
            }}
          >
            OpenTurath AI
          </Interactive.Div>

          {/* Calm Scholarly Tagline */}
          <Interactive.Div
            name="Finale Tagline"
            style={{
              fontFamily: FONT.sans,
              fontSize: isPortrait ? 34 : 32,
              fontWeight: 400,
              color: PALETTE.obsidianMuted,
              opacity: interpolate(frame, [1.4 * fps, 2.2 * fps], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: Easing.bezier(0.16, 1, 0.3, 1),
              }),
            }}
          >
            Membaca khazanah dengan tenang.
          </Interactive.Div>

          {/* Arabic Seal */}
          <Interactive.Div
            name="Finale Arabic Seal"
            dir="rtl"
            lang="ar"
            style={{
              fontFamily: FONT.arabic,
              fontSize: isPortrait ? 44 : 42,
              lineHeight: 1.85,
              letterSpacing: 0,
              color: PALETTE.obsidianSubtle,
              opacity: interpolate(frame, [1.7 * fps, 2.5 * fps], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
              }),
            }}
          >
            التُّرَاثُ الإِسْلَامِيُّ فِي مُتَنَاوَلِ يَدَيْكَ
          </Interactive.Div>

          {/* CTA Pill + Cross-Platform Strip */}
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              gap: 22,
              marginTop: 12,
              opacity: ctaOpacity,
              translate: `0px ${ctaY}px`,
            }}
          >
            <div
              style={{
                padding: isPortrait ? "18px 52px" : "16px 48px",
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
            </div>

            <div
              style={{
                fontFamily: FONT.sans,
                fontSize: isPortrait ? 22 : 20,
                letterSpacing: "0.18em",
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
