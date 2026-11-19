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
import { ProceduralBackdrop } from "./ProceduralBackdrop";
import { CLAMP, FONT, PALETTE } from "./tokens";

const SNAP = Easing.bezier(0.12, 1, 0.22, 1);
const IMPLODE = Easing.bezier(0.78, 0, 0.9, 0.2);

const ROWS = [
  CATALOG.slice(0, 5),
  CATALOG.slice(5, 10),
  CATALOG.slice(10, 14),
  CATALOG.slice(14, 18),
] as const;

const BEAT_CALLOUTS = [
  { label: "FIKIH EMPAT MAZHAB", arabic: "المَذَاهِبُ الأَرْبَعَةُ" },
  { label: "FIKIH TAHAWWULAT", arabic: "فِقْهُ التَّحَوُّلَاتِ" },
  { label: "HADIS · TAFSIR · AKIDAH", arabic: "الحَدِيثُ وَالتَّفْسِيرُ وَالعَقِيدَةُ" },
  { label: "18 BIDANG ILMU TURATS", arabic: "ثَمَانِيَةَ عَشَرَ عِلْماً" },
] as const;

/**
 * ACT 4 (Local f 0–300 | Global f 900–1200 | Beats 30–40 @ 120 BPM)
 * Tilted 3D Kinetic Wall of all 18 Disciplines + Beat-Synced Spotlight Callouts +
 * Implosion Match-Cut into Obsidian Finale.
 */
export const KineticAct4DisciplinesWall: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  // Whip-pan entrance (f 0..16)
  const whipInX = interpolate(frame, [0, 16], [width * 0.65, 0], {
    ...CLAMP,
    easing: SNAP,
  });

  // Giant "18" Kinetic Stamp Impact at f 0
  const stampScale = interpolate(frame, [0, 18], [2.4, 1], {
    ...CLAMP,
    easing: SNAP,
  });

  // Implosion match-cut into Act 5 Obsidian (f 268..300)
  const implodeScale = interpolate(frame, [268, 298], [1, 0.04], {
    ...CLAMP,
    easing: IMPLODE,
  });
  const implodeDarkness = interpolate(frame, [278, 299], [0, 1], CLAMP);

  // Beat-synced callout index changes every 60 frames (every 2 beats @ 120 BPM!)
  const calloutIdx = Math.min(3, Math.floor(frame / 68));
  const calloutLocal = frame % 68;
  const activeCallout = BEAT_CALLOUTS[calloutIdx];

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.paper, overflow: "hidden" }}>
      <ProceduralBackdrop theme="light" speed={1.8} showGrid={false} />

      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          perspective: 1400,
          translate: `${whipInX}px 0px`,
          scale: `${implodeScale}`,
        }}
      >
        {/* Tilted 3D Kinetic Discipline Wall */}
        <div
          style={{
            position: "absolute",
            width: "140%",
            display: "flex",
            flexDirection: "column",
            gap: isPortrait ? 22 : 18,
            transform: "rotateZ(-5deg) rotateX(10deg)",
            opacity: 0.92,
          }}
        >
          {ROWS.map((row, rowIdx) => {
            const dir = rowIdx % 2 === 0 ? -1 : 1;
            const speed = (rowIdx % 2 === 0 ? 4.6 : 4.1) * dir;
            const shift =
              dir < 0
                ? interpolate(frame, [0, 300], [180, 180 + 300 * speed], CLAMP)
                : interpolate(frame, [0, 300], [-950, -950 + 300 * speed], CLAMP);
            const repeated = [...row, ...row, ...row];

            return (
              <div
                key={rowIdx}
                style={{
                  display: "flex",
                  gap: 18,
                  translate: `${shift}px 0px`,
                }}
              >
                {repeated.map((item, idx) => {
                  const isInk = (idx + rowIdx) % 3 === 0;
                  return (
                    <div
                      key={`${item.id}-${idx}`}
                      style={{
                        flexShrink: 0,
                        display: "flex",
                        alignItems: "center",
                        gap: 18,
                        padding: isPortrait ? "18px 28px" : "16px 26px",
                        borderRadius: 18,
                        backgroundColor: isInk ? PALETTE.ink : PALETTE.paperPure,
                        border: `1.5px solid ${
                          isInk ? PALETTE.ink : PALETTE.paperBorder
                        }`,
                        boxShadow: isInk
                          ? "0 14px 32px rgba(9, 9, 11, 0.16)"
                          : "0 6px 18px rgba(9, 9, 11, 0.05)",
                      }}
                    >
                      <span
                        style={{
                          fontFamily: FONT.sans,
                          fontSize: isPortrait ? 24 : 22,
                          fontWeight: 600,
                          color: isInk ? PALETTE.ivory : PALETTE.ink,
                          whiteSpace: "nowrap",
                        }}
                      >
                        {item.name}
                      </span>
                      <span
                        dir="rtl"
                        lang="ar"
                        style={{
                          fontFamily: FONT.arabic,
                          fontSize: isPortrait ? 30 : 28,
                          lineHeight: 1.5,
                          letterSpacing: 0,
                          color: isInk
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
          })}
        </div>

        {/* Center High-Contrast Monochrome Hero Badge (Floating above the 3D Wall) */}
        <div
          style={{
            position: "relative",
            zIndex: 20,
            backgroundColor: PALETTE.obsidian,
            color: PALETTE.ivory,
            border: `2px solid ${PALETTE.obsidianBorder}`,
            borderRadius: 32,
            padding: isPortrait ? "44px 56px" : "38px 64px",
            boxShadow: "0 40px 100px rgba(9, 9, 11, 0.45)",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            textAlign: "center",
            gap: 12,
            scale: `${stampScale}`,
            maxWidth: isPortrait ? 860 : 960,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "baseline",
              gap: 20,
            }}
          >
            <Interactive.Div
              name="Act 4 Giant 18"
              style={{
                fontFamily: FONT.serif,
                fontSize: isPortrait ? 132 : 124,
                fontWeight: 400,
                lineHeight: 0.9,
                letterSpacing: "-0.04em",
                color: PALETTE.ivory,
              }}
            >
              18
            </Interactive.Div>
            <Interactive.Div
              name="Act 4 Label"
              style={{
                fontFamily: FONT.serif,
                fontSize: isPortrait ? 58 : 56,
                fontWeight: 400,
                lineHeight: 1.05,
                color: PALETTE.obsidianMuted,
              }}
            >
              Bidang Ilmu
            </Interactive.Div>
          </div>

          <div
            style={{
              width: "100%",
              height: 1,
              backgroundColor: PALETTE.obsidianBorder,
              marginTop: 6,
              marginBottom: 6,
            }}
          />

          {/* Beat-Synced Dynamic Spotlight Pill */}
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              gap: 6,
              opacity: interpolate(calloutLocal, [0, 10], [0, 1], CLAMP),
              translate: `0px ${interpolate(calloutLocal, [0, 12], [18, 0], {
                ...CLAMP,
                easing: SNAP,
              })}px`,
            }}
          >
            <div
              style={{
                fontFamily: FONT.sans,
                fontSize: isPortrait ? 24 : 22,
                fontWeight: 600,
                letterSpacing: "0.22em",
                color: PALETTE.ivory,
              }}
            >
              {activeCallout.label}
            </div>
            <div
              dir="rtl"
              lang="ar"
              style={{
                fontFamily: FONT.arabic,
                fontSize: isPortrait ? 40 : 38,
                lineHeight: 1.7,
                letterSpacing: 0,
                color: PALETTE.obsidianMuted,
              }}
            >
              {activeCallout.arabic}
            </div>
          </div>
        </div>
      </AbsoluteFill>

      {/* Seamless Dark Implosion Veil into Act 5 Finale */}
      <AbsoluteFill
        style={{
          backgroundColor: PALETTE.obsidian,
          opacity: implodeDarkness,
          pointerEvents: "none",
        }}
      />
    </AbsoluteFill>
  );
};
