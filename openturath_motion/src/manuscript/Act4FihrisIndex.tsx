import type React from "react";
import {
  AbsoluteFill,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { CLAMP, EASE_INK, EASE_SHIFT, INK, TYPE } from "./tokens";

// Eight representative disciplines from OpenTurath's 18 real agents, ordered for the index sweep.
const FIHRIS_ROWS = [
  { name: "Fikih Syafi'i", arabic: "الفقه الشافعي" },
  { name: "Fikih Hanafi, Maliki, Hanbali", arabic: "المذاهب الفقهية" },
  { name: "Perbandingan Mazhab & Fatwa", arabic: "الفقه المقارن والفتاوى" },
  { name: "Hadis & Syarah Hadis", arabic: "الحديث الشريف وشروحه" },
  { name: "Tafsir & Ilmu Al-Qur'an", arabic: "التفسير وعلوم القرآن" },
  { name: "Usul & Kaidah Fikih", arabic: "أصول الفقه والقواعد الفقهية" },
  { name: "Akidah, Tasawuf & Bahasa Arab", arabic: "العقيدة والتصوف والعربية" },
  { name: "Fikih Tahawwulat", arabic: "فقه التحولات" },
] as const;

export const Act4FihrisIndex: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  // Highlight bar steps cleanly every 36 frames (0.6s), matching the acoustic oud/daf pulse.
  const activeIdx = Math.min(FIHRIS_ROWS.length - 1, Math.floor(frame / 36));

  // Entrance slide from bottom matches Act 3 upward slide-out.
  const enterY = interpolate(frame, [0, 26], [120, 0], {
    ...CLAMP,
    easing: EASE_INK,
  });

  // Final ink expansion from bottom row fills the screen into Act 5 dark monograph.
  const expandToDark = interpolate(frame, [268, 298], [0, 1], {
    ...CLAMP,
    easing: EASE_SHIFT,
  });

  const padX = isPortrait ? 64 : 120;

  return (
    <AbsoluteFill style={{ backgroundColor: INK.paper, overflow: "hidden" }}>
      <div
        style={{
          position: "absolute",
          inset: 0,
          paddingLeft: padX,
          paddingRight: padX,
          paddingTop: isPortrait ? 128 : 76,
          paddingBottom: isPortrait ? 120 : 72,
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          translate: `0px ${enterY}px`,
        }}
      >
        {/* Top Fihris heading */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "baseline",
            paddingBottom: 24,
            borderBottom: `2px solid ${INK.ink}`,
          }}
        >
          <Interactive.Div
            name="Act 4 Fihris Heading"
            style={{
              fontFamily: TYPE.serif,
              fontSize: isPortrait ? 58 : 52,
              fontWeight: 400,
              letterSpacing: "-0.02em",
              color: INK.ink,
            }}
          >
            18 bidang ilmu turats
          </Interactive.Div>
          <div
            dir="rtl"
            lang="ar"
            style={{
              fontFamily: TYPE.arabic,
              fontSize: isPortrait ? 44 : 40,
              lineHeight: 1.5,
              letterSpacing: 0,
              color: INK.inkMuted,
            }}
          >
            فِهْرِسُ العُلُومِ
          </div>
        </div>

        {/* Clean typographic index table (no cards, no bento grid, no shadows) */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            flex: 1,
            justifyContent: "center",
          }}
        >
          {FIHRIS_ROWS.map((row, idx) => {
            const isSelected = idx === activeIdx;
            return (
              <div
                key={row.name}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  paddingLeft: isPortrait ? 24 : 32,
                  paddingRight: isPortrait ? 24 : 32,
                  paddingTop: isPortrait ? 26 : 16,
                  paddingBottom: isPortrait ? 26 : 16,
                  borderBottom: `1px solid ${INK.paperRule}`,
                  backgroundColor: isSelected ? INK.ink : "transparent",
                  color: isSelected ? INK.paper : INK.ink,
                }}
              >
                <span
                  style={{
                    fontFamily: TYPE.sans,
                    fontSize: isPortrait ? 30 : 26,
                    fontWeight: isSelected ? 600 : 400,
                  }}
                >
                  {row.name}
                </span>
                <span
                  dir="rtl"
                  lang="ar"
                  style={{
                    fontFamily: TYPE.arabic,
                    fontSize: isPortrait ? 38 : 34,
                    lineHeight: 1.6,
                    letterSpacing: 0,
                    color: isSelected ? INK.paper : INK.inkMuted,
                  }}
                >
                  {row.arabic}
                </span>
              </div>
            );
          })}
        </div>

        {/* Quiet factual footnote */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            paddingTop: 20,
            fontFamily: TYPE.sans,
            fontSize: isPortrait ? 22 : 19,
            color: INK.inkMuted,
          }}
        >
          <span>Terbuka lintas tab untuk perbandingan langsung.</span>
          <span>18 asisten</span>
        </div>
      </div>

      {/* Ink expansion match-cut from bottom into Act 5 dark screen */}
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 0,
          height: `${expandToDark * 104}%`,
          backgroundColor: INK.darkBg,
        }}
      />
    </AbsoluteFill>
  );
};
