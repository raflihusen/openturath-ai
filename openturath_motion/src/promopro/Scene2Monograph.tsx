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
import { CLAMP, EASE_EDITORIAL, FONT, PALETTE } from "./tokens";

const KITAB_SPINES = [
  { title: "الأم", heightRatio: 0.72 },
  { title: "المجموع", heightRatio: 0.88 },
  { title: "صحيح البخاري", heightRatio: 0.96 },
  { title: "تفسير الطبري", heightRatio: 1.0 },
  { title: "فتح المعين", heightRatio: 0.84 },
  { title: "الرسالة", heightRatio: 0.78 },
  { title: "سفينة النجاة", heightRatio: 0.68 },
] as const;

export const Scene2Monograph: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();
  const isPortrait = height > width;

  const headlineSize = isPortrait ? 86 : 96;
  const bodySize = isPortrait ? 38 : 34;
  const maxSpineH = isPortrait ? 340 : 380;
  const spineW = isPortrait ? 84 : 76;

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.paper }}>
      <EditorialChrome theme="light" folio="02" section="RUANG BACA" />

      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          paddingLeft: isPortrait ? 76 : 120,
          paddingRight: isPortrait ? 76 : 120,
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: isPortrait ? "column" : "row",
            alignItems: "center",
            justifyContent: "space-between",
            width: "100%",
            maxWidth: isPortrait ? 920 : 1560,
            gap: isPortrait ? 84 : 96,
          }}
        >
          {/* Left / Top Editorial Typography */}
          <div
            style={{
              flex: 1,
              display: "flex",
              flexDirection: "column",
              alignItems: isPortrait ? "center" : "flex-start",
              textAlign: isPortrait ? "center" : "left",
              gap: 24,
            }}
          >
            <Interactive.Div
              name="Monograph Label"
              style={{
                fontFamily: FONT.sans,
                fontSize: 20,
                fontWeight: 600,
                letterSpacing: "0.2em",
                textTransform: "uppercase",
                color: PALETTE.inkTertiary,
                opacity: interpolate(frame, [0.2 * fps, 0.8 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                }),
              }}
            >
              PRINSIP OPENTURATH
            </Interactive.Div>

            <Interactive.Div
              name="Monograph Headline"
              style={{
                fontFamily: FONT.serif,
                fontSize: headlineSize,
                fontWeight: 400,
                lineHeight: 1.08,
                letterSpacing: "-0.025em",
                color: PALETTE.ink,
                opacity: interpolate(frame, [0.4 * fps, 1.2 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.16, 1, 0.3, 1),
                }),
                translate: interpolate(
                  frame,
                  [0.4 * fps, 1.2 * fps],
                  ["0px 44px", "0px 0px"],
                  {
                    extrapolateLeft: "clamp",
                    extrapolateRight: "clamp",
                    easing: Easing.bezier(0.16, 1, 0.3, 1),
                  }
                ),
              }}
            >
              Ribuan jilid kitab.
              <br />
              Satu ruang yang tenang.
            </Interactive.Div>

            <Interactive.Div
              name="Monograph Description"
              style={{
                fontFamily: FONT.sans,
                fontSize: bodySize,
                fontWeight: 400,
                lineHeight: 1.55,
                color: PALETTE.inkSecondary,
                maxWidth: isPortrait ? 780 : 620,
                opacity: interpolate(frame, [1.1 * fps, 1.9 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.16, 1, 0.3, 1),
                }),
                translate: interpolate(
                  frame,
                  [1.1 * fps, 1.9 * fps],
                  ["0px 24px", "0px 0px"],
                  {
                    extrapolateLeft: "clamp",
                    extrapolateRight: "clamp",
                    easing: Easing.bezier(0.16, 1, 0.3, 1),
                  }
                ),
              }}
            >
              Konten adalah tokoh utama. Antarmuka mundur satu langkah agar
              telaah fikih, hadis, dan tafsir mengalir tanpa gangguan.
            </Interactive.Div>
          </div>

          {/* Right / Bottom Architectural 7-Spine Kitab Monograph */}
          <div
            style={{
              display: "flex",
              alignItems: "flex-end",
              justifyContent: "center",
              gap: isPortrait ? 16 : 18,
              height: maxSpineH + 40,
              paddingBottom: 20,
              borderBottom: `2px solid ${PALETTE.ink}`,
            }}
          >
            {KITAB_SPINES.map((kitab, idx) => {
              const startF = Math.round(0.35 * fps + idx * 8);
              const endF = startF + Math.round(0.95 * fps);
              const progress = interpolate(frame, [startF, endF], [0, 1], {
                ...CLAMP,
                easing: EASE_EDITORIAL,
              });
              const isCenter = idx === 3;
              const h = Math.round(maxSpineH * kitab.heightRatio);
              const riseY = interpolate(progress, [0, 1], [80, 0]);

              return (
                <div
                  key={kitab.title}
                  style={{
                    width: spineW,
                    height: h,
                    backgroundColor: isCenter
                      ? PALETTE.ink
                      : PALETTE.paperPure,
                    border: `1.5px solid ${
                      isCenter ? PALETTE.ink : PALETTE.paperBorder
                    }`,
                    borderRadius: "10px 10px 2px 2px",
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    justifyContent: "space-between",
                    paddingTop: 18,
                    paddingBottom: 18,
                    opacity: progress,
                    translate: `0px ${riseY}px`,
                    boxShadow: isCenter
                      ? "0 20px 44px rgba(23, 23, 23, 0.16)"
                      : "0 8px 24px rgba(23, 23, 23, 0.05)",
                  }}
                >
                  {/* Top decorative headband lines */}
                  <div
                    style={{
                      width: "52%",
                      height: 2,
                      backgroundColor: isCenter
                        ? "rgba(255,255,255,0.35)"
                        : PALETTE.paperBorder,
                    }}
                  />

                  {/* Vertical classical Arabic kitab spine title */}
                  <div
                    dir="rtl"
                    lang="ar"
                    style={{
                      writingMode: "vertical-rl",
                      fontFamily: FONT.arabic,
                      fontSize: isPortrait ? 26 : 24,
                      lineHeight: 1.4,
                      letterSpacing: 0,
                      color: isCenter ? PALETTE.ivory : PALETTE.ink,
                      textAlign: "center",
                      whiteSpace: "nowrap",
                    }}
                  >
                    {kitab.title}
                  </div>

                  {/* Bottom volume dot */}
                  <div
                    style={{
                      width: 6,
                      height: 6,
                      borderRadius: 999,
                      backgroundColor: isCenter
                        ? PALETTE.ivory
                        : PALETTE.inkTertiary,
                    }}
                  />
                </div>
              );
            })}
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
