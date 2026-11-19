import type React from "react";
import {
  AbsoluteFill,
  Easing,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { DEMO } from "../productfilm/content";
import { EditorialChrome } from "./EditorialChrome";
import { CLAMP, EASE_EDITORIAL, FONT, PALETTE } from "./tokens";

const TABS = [
  { label: "Fikih Syafi’i", active: true },
  { label: "Perbandingan Mazhab", active: false },
  { label: "Usul Fikih", active: false },
  { label: "Hadis", active: false },
] as const;

export const Scene3ProductShowcase: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();
  const isPortrait = height > width;

  // Device entrance
  const windowOpacity = interpolate(frame, [0, 0.7 * fps], [0, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });
  const windowY = interpolate(frame, [0, 0.9 * fps], [64, 0], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  // Live question typing (0.7s -> 2.4s)
  const typedChars = Math.floor(
    interpolate(frame, [0.7 * fps, 2.3 * fps], [0, DEMO.question.length], CLAMP)
  );
  const shownQuestion = DEMO.question.slice(0, typedChars);
  const showCaret = frame >= 0.7 * fps && frame <= 2.5 * fps && Math.floor(frame / 18) % 2 === 0;

  // Structured answer container reveal (2.6s)
  const answerOpacity = interpolate(frame, [2.6 * fps, 3.1 * fps], [0, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });

  // Ibarah citation card spotlight (4.5s -> 7.8s)
  const citationOpacity = interpolate(frame, [4.3 * fps, 5.0 * fps], [0, 1], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });
  const citationY = interpolate(frame, [4.3 * fps, 5.1 * fps], [28, 0], {
    ...CLAMP,
    easing: EASE_EDITORIAL,
  });
  const citationFocusScale = interpolate(
    frame,
    [5.4 * fps, 6.2 * fps],
    [1, 1.025],
    {
      ...CLAMP,
      easing: EASE_EDITORIAL,
    }
  );

  // Action pill feedback ("Ibarah tersalin.")
  const copiedVisible = interpolate(frame, [6.4 * fps, 6.8 * fps], [0, 1], CLAMP);

  const windowW = isPortrait ? 936 : 1140;

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.obsidian }}>
      <EditorialChrome theme="dark" folio="03" section="RUJUKAN IBARAH" />

      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          paddingLeft: isPortrait ? 72 : 100,
          paddingRight: isPortrait ? 72 : 100,
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: isPortrait ? "column" : "row",
            alignItems: "center",
            justifyContent: "center",
            gap: isPortrait ? 44 : 68,
            width: "100%",
            maxWidth: isPortrait ? 940 : 1720,
          }}
        >
          {/* Side / Top Editorial Callout */}
          <div
            style={{
              width: isPortrait ? "100%" : 440,
              display: "flex",
              flexDirection: "column",
              alignItems: isPortrait ? "center" : "flex-start",
              textAlign: isPortrait ? "center" : "left",
              gap: 18,
            }}
          >
            <Interactive.Div
              name="Showcase Eyebrow"
              style={{
                fontFamily: FONT.sans,
                fontSize: 18,
                fontWeight: 600,
                letterSpacing: "0.2em",
                textTransform: "uppercase",
                color: PALETTE.obsidianSubtle,
                opacity: interpolate(frame, [0.2 * fps, 0.8 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                }),
              }}
            >
              MULTI-TAB · RUJUKAN KITAB
            </Interactive.Div>

            <Interactive.Div
              name="Showcase Headline"
              style={{
                fontFamily: FONT.serif,
                fontSize: isPortrait ? 72 : 68,
                fontWeight: 400,
                lineHeight: 1.08,
                letterSpacing: "-0.02em",
                color: PALETTE.ivory,
                opacity: interpolate(frame, [0.3 * fps, 1.0 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                  easing: Easing.bezier(0.16, 1, 0.3, 1),
                }),
              }}
            >
              Tanya dengan tenang.
              <br />
              Verifikasi ibarahnya.
            </Interactive.Div>

            <Interactive.Div
              name="Showcase Subtitle"
              style={{
                fontFamily: FONT.sans,
                fontSize: isPortrait ? 30 : 25,
                lineHeight: 1.55,
                color: PALETTE.obsidianMuted,
                opacity: interpolate(frame, [0.7 * fps, 1.4 * fps], [0, 1], {
                  extrapolateLeft: "clamp",
                  extrapolateRight: "clamp",
                }),
              }}
            >
              Bandingkan hingga 5 tab bidang ilmu sekaligus, lengkap dengan
              matan Arab dan nama kitab rujukan.
            </Interactive.Div>
          </div>

          {/* Monochrome OpenTurath App Window Mockup */}
          <div
            style={{
              width: windowW,
              backgroundColor: PALETTE.obsidianSurface,
              border: `1.5px solid ${PALETTE.obsidianBorder}`,
              borderRadius: 28,
              overflow: "hidden",
              opacity: windowOpacity,
              translate: `0px ${windowY}px`,
              boxShadow: "0 36px 90px rgba(0, 0, 0, 0.65)",
            }}
          >
            {/* App Multi-Tab Bar */}
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 10,
                padding: "18px 24px",
                backgroundColor: "#0E0E10",
                borderBottom: `1px solid ${PALETTE.obsidianBorder}`,
              }}
            >
              <div style={{ display: "flex", gap: 8, marginRight: 14 }}>
                <div
                  style={{
                    width: 11,
                    height: 11,
                    borderRadius: 999,
                    backgroundColor: PALETTE.obsidianBorder,
                  }}
                />
                <div
                  style={{
                    width: 11,
                    height: 11,
                    borderRadius: 999,
                    backgroundColor: PALETTE.obsidianBorder,
                  }}
                />
                <div
                  style={{
                    width: 11,
                    height: 11,
                    borderRadius: 999,
                    backgroundColor: PALETTE.obsidianBorder,
                  }}
                />
              </div>

              {TABS.slice(0, isPortrait ? 3 : 4).map((tab) => (
                <div
                  key={tab.label}
                  style={{
                    fontFamily: FONT.sans,
                    fontSize: 18,
                    fontWeight: tab.active ? 600 : 400,
                    padding: "9px 18px",
                    borderRadius: 999,
                    backgroundColor: tab.active
                      ? PALETTE.ivory
                      : "transparent",
                    color: tab.active
                      ? PALETTE.obsidian
                      : PALETTE.obsidianSubtle,
                    border: tab.active
                      ? "1px solid transparent"
                      : `1px solid ${PALETTE.obsidianBorder}`,
                    whiteSpace: "nowrap",
                  }}
                >
                  {tab.label}
                </div>
              ))}
            </div>

            {/* Workspace Body */}
            <div
              style={{
                padding: isPortrait ? "34px 36px 38px" : "34px 44px 38px",
                display: "flex",
                flexDirection: "column",
                gap: 26,
              }}
            >
              {/* User Question Bubble */}
              <div
                style={{
                  alignSelf: "flex-end",
                  backgroundColor: PALETTE.obsidianElevated,
                  border: `1px solid ${PALETTE.obsidianBorder}`,
                  borderRadius: "22px 22px 6px 22px",
                  padding: "18px 26px",
                  maxWidth: "86%",
                  minHeight: 62,
                }}
              >
                <div
                  style={{
                    fontFamily: FONT.sans,
                    fontSize: isPortrait ? 26 : 24,
                    lineHeight: 1.45,
                    color: PALETTE.ivory,
                  }}
                >
                  {shownQuestion}
                  {showCaret && (
                    <span
                      style={{
                        display: "inline-block",
                        width: 2,
                        height: 24,
                        backgroundColor: PALETTE.ivory,
                        marginLeft: 4,
                        verticalAlign: "middle",
                      }}
                    />
                  )}
                </div>
              </div>

              {/* Structured Scholarly Response */}
              <div
                style={{
                  opacity: answerOpacity,
                  display: "flex",
                  flexDirection: "column",
                  gap: 18,
                }}
              >
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "baseline",
                  }}
                >
                  <div
                    style={{
                      fontFamily: FONT.serif,
                      fontSize: isPortrait ? 34 : 30,
                      color: PALETTE.ivory,
                    }}
                  >
                    {DEMO.title} — {DEMO.introduction}
                  </div>
                </div>

                {/* 2-Column Compact List of 6 Rukun */}
                <div
                  style={{
                    display: "grid",
                    gridTemplateColumns: "1fr 1fr",
                    gap: "12px 24px",
                  }}
                >
                  {DEMO.items.map((item, i) => {
                    const itemStart = 2.8 * fps + i * 10;
                    const itemOp = interpolate(
                      frame,
                      [itemStart, itemStart + 18],
                      [0, 1],
                      CLAMP
                    );
                    const itemY = interpolate(
                      frame,
                      [itemStart, itemStart + 18],
                      [12, 0],
                      { ...CLAMP, easing: EASE_EDITORIAL }
                    );

                    return (
                      <div
                        key={item}
                        style={{
                          display: "flex",
                          alignItems: "baseline",
                          gap: 12,
                          opacity: itemOp,
                          translate: `0px ${itemY}px`,
                          fontFamily: FONT.sans,
                          fontSize: isPortrait ? 22 : 21,
                          lineHeight: 1.4,
                          color: PALETTE.obsidianMuted,
                        }}
                      >
                        <span
                          style={{
                            color: PALETTE.obsidianSubtle,
                            fontSize: 17,
                            fontWeight: 600,
                          }}
                        >
                          0{i + 1}
                        </span>
                        <span style={{ color: PALETTE.ivory }}>{item}</span>
                      </div>
                    );
                  })}
                </div>

                {/* Authentic Arabic Ibarah Citation Card */}
                <div
                  style={{
                    marginTop: 8,
                    padding: "24px 28px",
                    borderRadius: 20,
                    backgroundColor: PALETTE.paper,
                    color: PALETTE.ink,
                    opacity: citationOpacity,
                    translate: `0px ${citationY}px`,
                    scale: `${citationFocusScale}`,
                    display: "flex",
                    flexDirection: "column",
                    gap: 10,
                  }}
                >
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                    }}
                  >
                    <span
                      style={{
                        fontFamily: FONT.sans,
                        fontSize: 15,
                        fontWeight: 600,
                        letterSpacing: "0.14em",
                        textTransform: "uppercase",
                        color: PALETTE.inkSecondary,
                      }}
                    >
                      IBARAH RUJUKAN
                    </span>
                    <span
                      style={{
                        fontFamily: FONT.serif,
                        fontSize: 20,
                        fontWeight: 600,
                        color: PALETTE.ink,
                      }}
                    >
                      {DEMO.book} · {DEMO.section}
                    </span>
                  </div>

                  <div
                    dir="rtl"
                    lang="ar"
                    style={{
                      fontFamily: FONT.arabic,
                      fontSize: isPortrait ? 44 : 42,
                      lineHeight: 1.85,
                      letterSpacing: 0,
                      color: PALETTE.ink,
                      textAlign: "right",
                    }}
                  >
                    {DEMO.excerpt}
                  </div>

                  {/* Quiet Action Row */}
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                      paddingTop: 10,
                      borderTop: `1px solid ${PALETTE.paperBorder}`,
                    }}
                  >
                    <div style={{ display: "flex", gap: 10 }}>
                      <span
                        style={{
                          fontFamily: FONT.sans,
                          fontSize: 16,
                          fontWeight: 600,
                          padding: "7px 16px",
                          borderRadius: 999,
                          backgroundColor: PALETTE.ink,
                          color: PALETTE.ivory,
                        }}
                      >
                        Salin ibarah
                      </span>
                      <span
                        style={{
                          fontFamily: FONT.sans,
                          fontSize: 16,
                          fontWeight: 500,
                          padding: "7px 16px",
                          borderRadius: 999,
                          border: `1px solid ${PALETTE.paperBorder}`,
                          color: PALETTE.ink,
                        }}
                      >
                        Simpan catatan
                      </span>
                    </div>

                    <span
                      style={{
                        fontFamily: FONT.sans,
                        fontSize: 16,
                        color: PALETTE.inkSecondary,
                        opacity: copiedVisible,
                      }}
                    >
                      Ibarah tersalin.
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
