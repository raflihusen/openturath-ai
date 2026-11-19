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
import { ProceduralBackdrop } from "./ProceduralBackdrop";
import { CLAMP, FONT, PALETTE } from "./tokens";

const SNAP = Easing.bezier(0.14, 1, 0.24, 1);
const WHIP = Easing.bezier(0.8, 0, 0.2, 1);

const TABS = [
  "Fikih Syafi’i",
  "Perbandingan Mazhab",
  "Usul Fikih",
  "Hadis",
] as const;

/**
 * ACT 3 (Local f 0–420 | Global f 480–900 | Beats 16–30 @ 120 BPM)
 * 3D Camera Fly-Over App Showcase + Cursor Choreography + Specular Sheen +
 * 3D Hero Ibarah Rack-Focus Lift + Whip-Pan Exit.
 */
export const KineticAct3Showcase3D: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  // Dynamic 3D camera rig (continuously moves like a real cinema camera!)
  // Phase A (0..75): Dramatic banking 3D arrival
  // Phase B (75..265): Settles into focused slight tilt & gentle dolly-in
  // Phase C (265..398): Slight tilt back while Hero Ibarah card lifts forward in 3D!
  // Phase D (398..420): High-velocity whip-pan left out of frame!
  const camRotateX = interpolate(
    frame,
    [0, 52, 265, 315, 398],
    [22, 6, 3, 8, 8],
    { ...CLAMP, easing: SNAP }
  );
  const camRotateY = interpolate(
    frame,
    [0, 52, 190, 275, 398],
    [-18, -5, 4, -3, 2],
    { ...CLAMP, easing: Easing.bezier(0.3, 0, 0.2, 1) }
  );
  const camScale = interpolate(
    frame,
    [0, 48, 270, 325],
    [0.84, 1.0, 1.04, 0.98],
    { ...CLAMP, easing: SNAP }
  );
  const whipOutX = interpolate(frame, [400, 420], [0, -width * 1.18], {
    ...CLAMP,
    easing: WHIP,
  });

  // Specular light sheen sweep across obsidian glass (f 12..85)
  const sheenX = interpolate(frame, [10, 90], [-60, 160], CLAMP);

  // Cursor choreography:
  // Clicks "Fikih Syafi'i" tab at local f 35 (global 515)
  // Moves to "Salin ibarah" button & clicks at local f 360 (global 840)
  const tabClicked = frame >= 35;
  const tabRippleScale = interpolate(frame, [35, 62], [0.2, 2.8], {
    ...CLAMP,
    easing: SNAP,
  });
  const tabRippleOpacity = interpolate(frame, [35, 42, 62], [0, 0.65, 0], CLAMP);

  // Rapid kinetic question launch (f 52..95), send pulse at f 95 (global 575)
  const typedLen = Math.floor(
    interpolate(frame, [46, 92], [0, DEMO.question.length], CLAMP)
  );
  const shownQ = DEMO.question.slice(0, typedLen);
  const sendPulseScale = interpolate(frame, [95, 122], [0.4, 2.6], {
    ...CLAMP,
    easing: SNAP,
  });
  const sendPulseOpacity = interpolate(frame, [95, 102, 122], [0, 0.7, 0], CLAMP);

  // Answer header + 6 items synced to local f 175, 185, 195, 205, 215, 225!
  const answerReady = interpolate(frame, [145, 170], [0, 1], {
    ...CLAMP,
    easing: SNAP,
  });

  // Hero Ibarah 3D Lift at local f 276 (global 756)
  const ibarahLift = interpolate(frame, [276, 318], [0, 1], {
    ...CLAMP,
    easing: SNAP,
  });
  const ibarahSheenX = interpolate(frame, [286, 355], [-50, 150], CLAMP);

  // "Salin ibarah" click at local f 360 (global 840)
  const copyClicked = frame >= 360;
  const copyRippleScale = interpolate(frame, [360, 386], [0.2, 2.6], {
    ...CLAMP,
    easing: SNAP,
  });
  const copyRippleOpacity = interpolate(
    frame,
    [360, 366, 386],
    [0, 0.75, 0],
    CLAMP
  );

  // Precision pointer position inside the app window
  const cursorVisible = (frame >= 14 && frame <= 78) || (frame >= 325 && frame <= 395);
  const cursorX =
    frame < 120
      ? interpolate(frame, [14, 34], [320, 138], { ...CLAMP, easing: SNAP })
      : interpolate(frame, [325, 358], [520, 108], { ...CLAMP, easing: SNAP });
  const cursorY =
    frame < 120
      ? interpolate(frame, [14, 34], [240, 38], { ...CLAMP, easing: SNAP })
      : interpolate(frame, [325, 358], [640, isPortrait ? 658 : 574], {
          ...CLAMP,
          easing: SNAP,
        });
  const cursorPress =
    (frame >= 34 && frame <= 40) || (frame >= 359 && frame <= 365) ? 0.82 : 1;

  const windowW = isPortrait ? 920 : 1180;

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.obsidian, overflow: "hidden" }}>
      <ProceduralBackdrop theme="dark" speed={0.85} />

      {/* Top Kinetic Label */}
      <div
        style={{
          position: "absolute",
          top: isPortrait ? 94 : 48,
          left: 0,
          right: 0,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 10,
          translate: `${whipOutX}px 0px`,
        }}
      >
        <div
          style={{
            fontFamily: FONT.sans,
            fontSize: 18,
            fontWeight: 600,
            letterSpacing: "0.26em",
            textTransform: "uppercase",
            color: PALETTE.obsidianMuted,
            opacity: interpolate(frame, [6, 24], [0, 1], CLAMP),
          }}
        >
          03 · MULTI-TAB &amp; VERIFIKASI IBARAH
        </div>
        <Interactive.Div
          name="Act 3 Kinetic Title"
          style={{
            fontFamily: FONT.serif,
            fontSize: isPortrait ? 64 : 54,
            fontWeight: 400,
            letterSpacing: "-0.02em",
            color: PALETTE.ivory,
            textAlign: "center",
            opacity: interpolate(frame, [10, 32], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
          }}
        >
          Tanya. Rujuk kitab aslinya.
        </Interactive.Div>
      </div>

      {/* 3D Perspective Stage */}
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          paddingTop: isPortrait ? 130 : 96,
          perspective: 1500,
          translate: `${whipOutX}px 0px`,
        }}
      >
        <div
          style={{
            position: "relative",
            width: windowW,
            transformStyle: "preserve-3d",
            transform: `rotateX(${camRotateX}deg) rotateY(${camRotateY}deg) scale(${camScale})`,
          }}
        >
          {/* Main App Window Shell */}
          <div
            style={{
              position: "relative",
              backgroundColor: PALETTE.obsidianSurface,
              border: `1.5px solid ${PALETTE.obsidianBorder}`,
              borderRadius: 28,
              overflow: "hidden",
              boxShadow: "0 48px 110px rgba(0, 0, 0, 0.78)",
            }}
          >
            {/* Specular Light Sheen Overlay */}
            <div
              style={{
                position: "absolute",
                inset: 0,
                pointerEvents: "none",
                background: `linear-gradient(112deg, transparent ${sheenX - 18}%, rgba(255,255,255,0.08) ${sheenX}%, transparent ${sheenX + 18}%)`,
                zIndex: 5,
              }}
            />

            {/* Multi-Tab Bar */}
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 10,
                padding: "18px 24px",
                backgroundColor: "#0D0D0F",
                borderBottom: `1px solid ${PALETTE.obsidianBorder}`,
              }}
            >
              <div style={{ display: "flex", gap: 8, marginRight: 12 }}>
                {[0, 1, 2].map((d) => (
                  <div
                    key={d}
                    style={{
                      width: 11,
                      height: 11,
                      borderRadius: 999,
                      backgroundColor: PALETTE.obsidianBorder,
                    }}
                  />
                ))}
              </div>

              {TABS.slice(0, isPortrait ? 3 : 4).map((label, idx) => {
                const isActive = idx === 0 && tabClicked;
                return (
                  <div
                    key={label}
                    style={{
                      position: "relative",
                      fontFamily: FONT.sans,
                      fontSize: 18,
                      fontWeight: isActive ? 600 : 400,
                      padding: "9px 20px",
                      borderRadius: 999,
                      backgroundColor: isActive ? PALETTE.ivory : "transparent",
                      color: isActive
                        ? PALETTE.obsidian
                        : PALETTE.obsidianSubtle,
                      border: `1px solid ${
                        isActive ? "transparent" : PALETTE.obsidianBorder
                      }`,
                      whiteSpace: "nowrap",
                    }}
                  >
                    {label}
                    {/* Click Ripple on Tab 0 */}
                    {idx === 0 && frame >= 35 && frame < 66 && (
                      <div
                        style={{
                          position: "absolute",
                          left: "50%",
                          top: "50%",
                          width: 48,
                          height: 48,
                          marginLeft: -24,
                          marginTop: -24,
                          borderRadius: 999,
                          border: `2px solid ${PALETTE.ivory}`,
                          scale: `${tabRippleScale}`,
                          opacity: tabRippleOpacity,
                          pointerEvents: "none",
                        }}
                      />
                    )}
                  </div>
                );
              })}
            </div>

            {/* App Content Body */}
            <div
              style={{
                padding: isPortrait ? "34px 36px 40px" : "30px 42px 36px",
                display: "flex",
                flexDirection: "column",
                gap: 24,
              }}
            >
              {/* Dim background parts subtly when Hero Ibarah lifts */}
              <div
                style={{
                  display: "flex",
                  flexDirection: "column",
                  gap: 22,
                  opacity: interpolate(ibarahLift, [0, 1], [1, 0.42]),
                }}
              >
                {/* Prompt Bubble with Send Pulse */}
                <div
                  style={{
                    position: "relative",
                    alignSelf: "flex-end",
                    backgroundColor: PALETTE.obsidianElevated,
                    border: `1px solid ${PALETTE.obsidianBorder}`,
                    borderRadius: "22px 22px 6px 22px",
                    padding: "16px 24px",
                    minHeight: 58,
                    maxWidth: "88%",
                    display: "flex",
                    alignItems: "center",
                    gap: 14,
                  }}
                >
                  <div
                    style={{
                      fontFamily: FONT.sans,
                      fontSize: isPortrait ? 25 : 23,
                      color: PALETTE.ivory,
                    }}
                  >
                    {shownQ || "\u00A0"}
                  </div>
                  {/* Send pulse indicator */}
                  {frame >= 95 && frame < 126 && (
                    <div
                      style={{
                        position: "absolute",
                        right: 16,
                        top: "50%",
                        width: 28,
                        height: 28,
                        marginTop: -14,
                        borderRadius: 999,
                        border: `2px solid ${PALETTE.ivory}`,
                        scale: `${sendPulseScale}`,
                        opacity: sendPulseOpacity,
                      }}
                    />
                  )}
                </div>

                {/* Structured Answer */}
                <div
                  style={{
                    opacity: answerReady,
                    display: "flex",
                    flexDirection: "column",
                    gap: 16,
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

                  <div
                    style={{
                      display: "grid",
                      gridTemplateColumns: "1fr 1fr",
                      gap: "12px 24px",
                    }}
                  >
                    {DEMO.items.map((item, i) => {
                      const fStart = 175 + i * 10; // Synced to 6 UI ticks!
                      const p = interpolate(frame, [fStart, fStart + 14], [0, 1], {
                        ...CLAMP,
                        easing: SNAP,
                      });
                      return (
                        <div
                          key={item}
                          style={{
                            display: "flex",
                            alignItems: "baseline",
                            gap: 12,
                            opacity: p,
                            translate: `${interpolate(p, [0, 1], [-18, 0])}px 0px`,
                            fontFamily: FONT.sans,
                            fontSize: isPortrait ? 22 : 20,
                            color: PALETTE.ivory,
                          }}
                        >
                          <span
                            style={{
                              fontSize: 15,
                              fontWeight: 600,
                              color: PALETTE.obsidianSubtle,
                            }}
                          >
                            0{i + 1}
                          </span>
                          <span>{item}</span>
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>

              {/* HERO 3D RACK-FOCUS IBARAH CARD */}
              <div
                style={{
                  position: "relative",
                  overflow: "hidden",
                  padding: isPortrait ? "26px 30px" : "24px 30px",
                  borderRadius: 22,
                  backgroundColor: PALETTE.paper,
                  color: PALETTE.ink,
                  opacity: interpolate(frame, [260, 286], [0, 1], CLAMP),
                  transform: `translateZ(${interpolate(
                    ibarahLift,
                    [0, 1],
                    [0, 90]
                  )}px) scale(${interpolate(ibarahLift, [0, 1], [0.96, 1.055])})`,
                  boxShadow: `0 ${interpolate(
                    ibarahLift,
                    [0, 1],
                    [10, 42]
                  )}px ${interpolate(
                    ibarahLift,
                    [0, 1],
                    [24, 90]
                  )}px rgba(0, 0, 0, ${interpolate(
                    ibarahLift,
                    [0, 1],
                    [0.2, 0.72]
                  )})`,
                  display: "flex",
                  flexDirection: "column",
                  gap: 12,
                }}
              >
                {/* Specular light sweep on the white citation card */}
                <div
                  style={{
                    position: "absolute",
                    inset: 0,
                    pointerEvents: "none",
                    background: `linear-gradient(110deg, transparent ${ibarahSheenX - 18}%, rgba(255,255,255,0.85) ${ibarahSheenX}%, transparent ${ibarahSheenX + 18}%)`,
                  }}
                />

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
                      fontSize: 14,
                      fontWeight: 600,
                      letterSpacing: "0.16em",
                      textTransform: "uppercase",
                      color: PALETTE.inkSecondary,
                    }}
                  >
                    IBARAH RUJUKAN TERVERIFIKASI
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
                    fontSize: isPortrait ? 48 : 44,
                    lineHeight: 1.85,
                    letterSpacing: 0,
                    color: PALETTE.ink,
                    textAlign: "right",
                  }}
                >
                  {DEMO.excerpt}
                </div>

                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    paddingTop: 12,
                    borderTop: `1px solid ${PALETTE.paperBorder}`,
                  }}
                >
                  <div style={{ display: "flex", gap: 10 }}>
                    <div
                      style={{
                        position: "relative",
                        fontFamily: FONT.sans,
                        fontSize: 16,
                        fontWeight: 600,
                        padding: "8px 18px",
                        borderRadius: 999,
                        backgroundColor: PALETTE.ink,
                        color: PALETTE.ivory,
                        scale: copyClicked && frame < 368 ? "0.94" : "1",
                      }}
                    >
                      Salin ibarah
                      {frame >= 360 && frame < 388 && (
                        <div
                          style={{
                            position: "absolute",
                            left: "50%",
                            top: "50%",
                            width: 44,
                            height: 44,
                            marginLeft: -22,
                            marginTop: -22,
                            borderRadius: 999,
                            border: `2px solid ${PALETTE.ink}`,
                            scale: `${copyRippleScale}`,
                            opacity: copyRippleOpacity,
                          }}
                        />
                      )}
                    </div>
                    <div
                      style={{
                        fontFamily: FONT.sans,
                        fontSize: 16,
                        padding: "8px 18px",
                        borderRadius: 999,
                        border: `1px solid ${PALETTE.paperBorder}`,
                        color: PALETTE.ink,
                      }}
                    >
                      Simpan catatan
                    </div>
                  </div>

                  <div
                    style={{
                      fontFamily: FONT.sans,
                      fontSize: 16,
                      fontWeight: 600,
                      color: PALETTE.ink,
                      opacity: interpolate(frame, [362, 374], [0, 1], CLAMP),
                      translate: `${interpolate(
                        frame,
                        [362, 376],
                        [14, 0],
                        CLAMP
                      )}px 0px`,
                    }}
                  >
                    ✓ Ibarah tersalin.
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Precision Motion-Graphic Cursor */}
          {cursorVisible && (
            <div
              style={{
                position: "absolute",
                left: cursorX,
                top: cursorY,
                width: 24,
                height: 24,
                pointerEvents: "none",
                zIndex: 50,
                scale: `${cursorPress}`,
                filter: "drop-shadow(0 6px 12px rgba(0,0,0,0.45))",
              }}
            >
              <svg width={24} height={24} viewBox="0 0 24 24" fill="none">
                <path
                  d="M4 3 L19 12 L11.8 13.8 L8.5 21 L4 3 Z"
                  fill={PALETTE.ivory}
                  stroke={PALETTE.obsidian}
                  strokeWidth={1.6}
                  strokeLinejoin="round"
                />
              </svg>
            </div>
          )}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
