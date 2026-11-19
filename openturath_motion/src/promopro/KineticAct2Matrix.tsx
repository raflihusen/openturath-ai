import type React from "react";
import {
  AbsoluteFill,
  Easing,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { ProceduralBackdrop } from "./ProceduralBackdrop";
import { CLAMP, FONT, PALETTE } from "./tokens";

const SNAP = Easing.bezier(0.16, 1, 0.3, 1);
const WHIP = Easing.bezier(0.76, 0, 0.24, 1);

const KITAB_CARDS = [
  { arabic: "الأم", latin: "Al-Umm", field: "Fikih Syafi’i" },
  { arabic: "المجموع", latin: "Al-Majmu’", field: "Syarah Muhadzab" },
  { arabic: "صحيح البخاري", latin: "Sahih al-Bukhari", field: "Hadis" },
  { arabic: "سفينة النجاة", latin: "Safinatun Najah", field: "Fikih Syafi’i", hero: true },
  { arabic: "تفسير الطبري", latin: "Tafsir al-Tabari", field: "Tafsir" },
  { arabic: "فتح المعين", latin: "Fathul Mu’in", field: "Fikih" },
  { arabic: "الرسالة", latin: "Ar-Risalah", field: "Usul Fikih" },
] as const;

/**
 * ACT 2 (f 0–240 local | Global f 240–480 | Beats 8–16 @ 120 BPM)
 * 3D Fanning Kitab Carousel + Counter-Scrolling Kinetic Typography +
 * Seamless 3D Card Expansion Morph into the Dark OpenTurath App Window.
 */
export const KineticAct2Matrix: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  // Counter-scrolling giant kinetic editorial bands
  const bandTopX = interpolate(frame, [0, 240], [180, -680], CLAMP);
  const bandBottomX = interpolate(frame, [0, 240], [-620, 220], CLAMP);

  // 3D Fan opens from stacked center (f 0..55), glides (f 55..175), then hero card expands into Act 3 (f 185..240)
  const fanSpread = interpolate(frame, [6, 56], [0, 1], {
    ...CLAMP,
    easing: SNAP,
  });
  const cameraPanX = interpolate(frame, [20, 180], [90, -50], {
    ...CLAMP,
    easing: Easing.bezier(0.4, 0, 0.2, 1),
  });

  // Hero Card Morph (f 182..236): center dark kitab card scales up & swallows screen into obsidian Act 3!
  const morphProgress = interpolate(frame, [182, 236], [0, 1], {
    ...CLAMP,
    easing: WHIP,
  });
  const nonHeroFade = interpolate(frame, [175, 205], [1, 0], CLAMP);
  const cardW = isPortrait ? 230 : 240;
  const cardH = isPortrait ? 390 : 380;
  const spacing = isPortrait ? 195 : 225;

  return (
    <AbsoluteFill style={{ backgroundColor: PALETTE.paper, overflow: "hidden" }}>
      <ProceduralBackdrop theme="light" speed={1.2} />

      {/* Counter-Scrolling Giant Kinetic Background Typography */}
      <div
        style={{
          position: "absolute",
          top: isPortrait ? "10%" : "6%",
          left: -200,
          whiteSpace: "nowrap",
          fontFamily: FONT.serif,
          fontSize: isPortrait ? 136 : 164,
          fontWeight: 400,
          letterSpacing: "-0.03em",
          color: "rgba(23, 23, 23, 0.055)",
          translate: `${bandTopX}px 0px`,
          opacity: nonHeroFade,
        }}
      >
        KHAZANAH ULAMA &nbsp;·&nbsp; RUANG BACA TENANG &nbsp;·&nbsp; KHAZANAH ULAMA &nbsp;·&nbsp;
      </div>

      <div
        dir="rtl"
        lang="ar"
        style={{
          position: "absolute",
          bottom: isPortrait ? "9%" : "5%",
          left: -200,
          whiteSpace: "nowrap",
          fontFamily: FONT.arabic,
          fontSize: isPortrait ? 160 : 185,
          lineHeight: 1.4,
          letterSpacing: 0,
          color: "rgba(23, 23, 23, 0.055)",
          translate: `${bandBottomX}px 0px`,
          opacity: nonHeroFade,
        }}
      >
        الفِقْهُ &nbsp;·&nbsp; الحَدِيثُ &nbsp;·&nbsp; التَّفْسِيرُ &nbsp;·&nbsp; أُصُولُ الفِقْهِ &nbsp;·&nbsp; العَقِيدَةُ &nbsp;·&nbsp;
      </div>

      {/* Top Editorial Kinetic Header */}
      <div
        style={{
          position: "absolute",
          top: isPortrait ? 120 : 76,
          left: 0,
          right: 0,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          textAlign: "center",
          paddingLeft: 64,
          paddingRight: 64,
          gap: 14,
          opacity: nonHeroFade,
        }}
      >
        <div
          style={{
            fontFamily: FONT.sans,
            fontSize: isPortrait ? 20 : 18,
            fontWeight: 600,
            letterSpacing: "0.26em",
            textTransform: "uppercase",
            color: PALETTE.inkTertiary,
            opacity: interpolate(frame, [8, 28], [0, 1], CLAMP),
          }}
        >
          02 · KHAZANAH TERSTRUKTUR
        </div>
        <Interactive.Div
          name="Act 2 Headline"
          style={{
            fontFamily: FONT.serif,
            fontSize: isPortrait ? 78 : 76,
            fontWeight: 400,
            lineHeight: 1.05,
            letterSpacing: "-0.025em",
            color: PALETTE.ink,
            opacity: interpolate(frame, [10, 36], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
              easing: Easing.bezier(0.16, 1, 0.3, 1),
            }),
            translate: interpolate(
              frame,
              [10, 38],
              ["0px 44px", "0px 0px"],
              {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: Easing.bezier(0.16, 1, 0.3, 1),
              }
            ),
          }}
        >
          Dari matan klasik ke telaah instan.
        </Interactive.Div>
      </div>

      {/* 3D Perspective Kitab Fan Stage */}
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          marginTop: isPortrait ? 80 : 64,
          perspective: 1400,
        }}
      >
        <div
          style={{
            position: "relative",
            width: cardW,
            height: cardH,
            transformStyle: "preserve-3d",
            transform: `translateX(${cameraPanX * (1 - morphProgress)}px) rotateX(${interpolate(
              frame,
              [0, 180],
              [14, 4],
              CLAMP
            ) * (1 - morphProgress)}deg)`,
          }}
        >
          {KITAB_CARDS.map((card, i) => {
            const offsetIdx = i - 3; // -3..+3, 0 is Hero
            const isHero = offsetIdx === 0;
            const xPos = offsetIdx * spacing * fanSpread;
            const zPos = isHero
              ? interpolate(morphProgress, [0, 1], [60, 520])
              : -Math.abs(offsetIdx) * 85 * fanSpread;
            const rotY = isHero
              ? interpolate(frame, [0, 180], [-10, 8], CLAMP) * (1 - morphProgress)
              : offsetIdx * -14 * fanSpread;
            const scaleCard = isHero
              ? interpolate(morphProgress, [0, 1], [1.08, 7.5])
              : 1;

            return (
              <div
                key={card.latin}
                style={{
                  position: "absolute",
                  inset: 0,
                  borderRadius: isHero
                    ? interpolate(morphProgress, [0, 0.6], [24, 6], CLAMP)
                    : 22,
                  backgroundColor: isHero ? PALETTE.obsidian : PALETTE.paperPure,
                  border: `1.5px solid ${
                    isHero ? PALETTE.obsidianBorder : PALETTE.paperBorder
                  }`,
                  boxShadow: isHero
                    ? "0 36px 80px rgba(9, 9, 11, 0.34)"
                    : "0 18px 40px rgba(23, 23, 23, 0.08)",
                  display: "flex",
                  flexDirection: "column",
                  justifyContent: "space-between",
                  padding: "28px 24px",
                  opacity: isHero ? 1 : nonHeroFade,
                  transform: `translateX(${xPos}px) translateZ(${zPos}px) rotateY(${rotY}deg) scale(${scaleCard})`,
                  zIndex: isHero ? 20 : 10 - Math.abs(offsetIdx),
                }}
              >
                {/* Top Card Metadata */}
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    opacity: isHero ? 1 - morphProgress * 2.2 : 1,
                  }}
                >
                  <span
                    style={{
                      fontFamily: FONT.sans,
                      fontSize: 13,
                      fontWeight: 600,
                      letterSpacing: "0.14em",
                      textTransform: "uppercase",
                      color: isHero
                        ? PALETTE.obsidianMuted
                        : PALETTE.inkTertiary,
                    }}
                  >
                    {card.field}
                  </span>
                  <div
                    style={{
                      width: 8,
                      height: 8,
                      borderRadius: 999,
                      backgroundColor: isHero ? PALETTE.ivory : PALETTE.ink,
                    }}
                  />
                </div>

                {/* Center Classical Arabic Title */}
                <div
                  dir="rtl"
                  lang="ar"
                  style={{
                    fontFamily: FONT.arabic,
                    fontSize: isHero ? 50 : 42,
                    lineHeight: 1.7,
                    letterSpacing: 0,
                    textAlign: "center",
                    color: isHero ? PALETTE.ivory : PALETTE.ink,
                    opacity: isHero ? 1 - morphProgress * 2.5 : 1,
                  }}
                >
                  {card.arabic}
                </div>

                {/* Bottom Latin Title */}
                <div
                  style={{
                    borderTop: `1px solid ${
                      isHero ? PALETTE.obsidianBorder : PALETTE.paperBorder
                    }`,
                    paddingTop: 14,
                    fontFamily: FONT.serif,
                    fontSize: 22,
                    color: isHero ? PALETTE.ivory : PALETTE.ink,
                    textAlign: "center",
                    opacity: isHero ? 1 - morphProgress * 2.5 : 1,
                  }}
                >
                  {card.latin}
                </div>
              </div>
            );
          })}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
