import type React from "react";
import {
  AbsoluteFill,
  Easing,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { CATALOG } from "../productfilm/catalog";
import { EditorialChrome } from "./EditorialChrome";
import { CLAMP, EASE_EDITORIAL, FONT, PALETTE } from "./tokens";

const ROW_1 = CATALOG.slice(0, 6);
const ROW_2 = CATALOG.slice(6, 12);
const ROW_3 = CATALOG.slice(12, 18);

export const Scene4Disciplines: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();
  const isPortrait = height > width;

  // Animated count-up 0 -> 18
  const countVal = Math.round(
    interpolate(frame, [0.15 * fps, 1.4 * fps], [1, 18], {
      ...CLAMP,
      easing: EASE_EDITORIAL,
    })
  );

  // Smooth opposing horizontal glides for the 3 discipline rows
  const glideLeft = interpolate(frame, [0, 6.8 * fps], [40, -340], CLAMP);
  const glideRight = interpolate(frame, [0, 6.8 * fps], [-320, 60], CLAMP);
  const glideLeftSlow = interpolate(frame, [0, 6.8 * fps], [0, -260], CLAMP);

  const rowsOpacity = interpolate(frame, [0.6 * fps, 1.3 * fps], [0, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  const renderRow = (
    items: readonly (typeof CATALOG)[number][],
    shiftX: number,
    highlightIndex: number
  ) => {
    // Repeat twice so parallax never runs out of cards
    const doubled = [...items, ...items];
    return (
      <div
        style={{
          display: "flex",
          gap: 18,
          translate: `${shiftX}px 0px`,
          willChange: "transform",
        }}
      >
        {doubled.map((item, idx) => {
          const isDarkCard = idx % items.length === highlightIndex;
          return (
            <div
              key={`${item.id}-${idx}`}
              style={{
                flexShrink: 0,
                display: "flex",
                alignItems: "center",
                gap: 20,
                padding: isPortrait ? "20px 30px" : "18px 28px",
                borderRadius: 20,
                backgroundColor: isDarkCard ? PALETTE.ink : PALETTE.paperPure,
                border: `1.5px solid ${
                  isDarkCard ? PALETTE.ink : PALETTE.paperBorder
                }`,
                boxShadow: isDarkCard
                  ? "0 14px 32px rgba(23, 23, 23, 0.14)"
                  : "0 4px 16px rgba(23, 23, 23, 0.04)",
              }}
            >
              <span
                style={{
                  fontFamily: FONT.sans,
                  fontSize: isPortrait ? 26 : 23,
                  fontWeight: 600,
                  color: isDarkCard ? PALETTE.ivory : PALETTE.ink,
                  whiteSpace: "nowrap",
                }}
              >
                {item.name}
              </span>
              <span
                style={{
                  width: 1,
                  height: 24,
                  backgroundColor: isDarkCard
                    ? "rgba(250,250,250,0.24)"
                    : PALETTE.paperBorder,
                }}
              />
              <span
                dir="rtl"
                lang="ar"
                style={{
                  fontFamily: FONT.arabic,
                  fontSize: isPortrait ? 32 : 28,
                  lineHeight: 1.6,
                  letterSpacing: 0,
                  color: isDarkCard
                    ? PALETTE.obsidianMuted
                    : PALETTE.inkSecondary,
                  whiteSpace: "nowrap",
                }}
              >
                {item.arabic}
              </span>
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.paper }}>
      <EditorialChrome theme="light" folio="04" section="KHAZANAH" />

      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          gap: isPortrait ? 64 : 52,
        }}
      >
        {/* Header Counter + Headline */}
        <div
          style={{
            display: "flex",
            flexDirection: isPortrait ? "column" : "row",
            alignItems: isPortrait ? "center" : "baseline",
            textAlign: isPortrait ? "center" : "left",
            gap: isPortrait ? 12 : 36,
            paddingLeft: isPortrait ? 76 : 120,
            paddingRight: isPortrait ? 76 : 120,
            maxWidth: isPortrait ? 940 : 1620,
            width: "100%",
          }}
        >
          <div
            style={{
              fontFamily: FONT.serif,
              fontSize: isPortrait ? 168 : 156,
              fontWeight: 400,
              lineHeight: 0.9,
              letterSpacing: "-0.04em",
              color: PALETTE.ink,
              fontVariantNumeric: "tabular-nums",
            }}
          >
            {countVal}
          </div>

          <div
            style={{
              display: "flex",
              flexDirection: "column",
              gap: 12,
              alignItems: isPortrait ? "center" : "flex-start",
            }}
          >
            <Interactive.Div
              name="Disciplines Headline"
              style={{
                fontFamily: FONT.serif,
                fontSize: isPortrait ? 76 : 74,
                fontWeight: 400,
                lineHeight: 1.06,
                letterSpacing: "-0.02em",
                color: PALETTE.ink,
                opacity: interpolate(frame, [0.3 * fps, 1.0 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.16, 1, 0.3, 1),
                }),
              }}
            >
              Bidang ilmu turats.
            </Interactive.Div>

            <Interactive.Div
              name="Disciplines Subtitle"
              style={{
                fontFamily: FONT.sans,
                fontSize: isPortrait ? 32 : 28,
                lineHeight: 1.45,
                color: PALETTE.inkSecondary,
                maxWidth: isPortrait ? 780 : 940,
                opacity: interpolate(frame, [0.6 * fps, 1.3 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                }),
              }}
            >
              Dari fikih empat mazhab dan fikih tahawwulat, hingga hadis,
              tafsir, akidah, usul fikih, dan bahasa Arab.
            </Interactive.Div>
          </div>
        </div>

        {/* 3 Opposing Architectural Marquee Rows */}
        <div
          style={{
            width: "100%",
            overflow: "hidden",
            display: "flex",
            flexDirection: "column",
            gap: isPortrait ? 24 : 20,
            opacity: rowsOpacity,
            paddingTop: 8,
            paddingBottom: 8,
            WebkitMaskImage:
              "linear-gradient(to right, transparent 0%, black 8%, black 92%, transparent 100%)",
            maskImage:
              "linear-gradient(to right, transparent 0%, black 8%, black 92%, transparent 100%)",
          }}
        >
          {renderRow(ROW_1, glideLeft, 1)}
          {renderRow(ROW_2, glideRight, 0)}
          {renderRow(ROW_3, glideLeftSlow, 2)}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
