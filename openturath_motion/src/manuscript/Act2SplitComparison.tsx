import type React from "react";
import {
  AbsoluteFill,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { CASE_STUDY, CLAMP, EASE_INK, EASE_SHIFT, INK, TYPE } from "./tokens";

export const Act2SplitComparison: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  // Question types smoothly across frames 24..108 (synced to soft keystroke cues).
  const typedCount = Math.floor(
    interpolate(frame, [24, 108], [0, CASE_STUDY.question.length], CLAMP)
  );
  const visibleQuestion = CASE_STUDY.question.slice(0, typedCount);

  // Asymmetric split proportion shifts as comparison opens (f 145..195).
  const splitOpen = interpolate(frame, [145, 196], [0, 1], {
    ...CLAMP,
    easing: EASE_SHIFT,
  });

  // Portrait stacks top ink / bottom paper; landscape reflows to left ink / right paper.
  const darkZonePct = isPortrait
    ? interpolate(splitOpen, [0, 1], [100, 38])
    : interpolate(splitOpen, [0, 1], [100, 44]);

  const syafiiOpacity = interpolate(frame, [176, 212], [0, 1], {
    ...CLAMP,
    easing: EASE_INK,
  });
  const syafiiY = interpolate(frame, [176, 214], [32, 0], {
    ...CLAMP,
    easing: EASE_INK,
  });

  // Jumhur panel enters on frame 270 (9.0s global) as a distinct second comparison beat.
  const jumhurReveal = interpolate(frame, [270, 310], [0, 1], {
    ...CLAMP,
    easing: EASE_INK,
  });

  // At frames 392..420, the paper zone rises to fill 100% of the canvas into Act 3.
  const exitToPaper = interpolate(frame, [392, 420], [0, 1], {
    ...CLAMP,
    easing: EASE_SHIFT,
  });

  const finalDarkPct = darkZonePct * (1 - exitToPaper);
  const paperZonePct = 100 - finalDarkPct;

  const padX = isPortrait ? 76 : 84;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: INK.darkBg,
        display: "flex",
        flexDirection: isPortrait ? "column" : "row",
        overflow: "hidden",
      }}
    >
      {/* Dark Workspace Zone: active tabs and real fiqh question */}
      <div
        style={{
          width: isPortrait ? "100%" : `${finalDarkPct}%`,
          height: isPortrait ? `${finalDarkPct}%` : "100%",
          backgroundColor: INK.darkBg,
          paddingLeft: padX,
          paddingRight: padX,
          paddingTop: isPortrait ? 110 : 96,
          paddingBottom: isPortrait ? 48 : 96,
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          gap: isPortrait ? 34 : 32,
          overflow: "hidden",
          opacity: interpolate(exitToPaper, [0, 0.6], [1, 0], CLAMP),
        }}
      >
        {/* Multi-tab selector showing active cross-discipline comparison */}
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: 12,
            opacity: interpolate(frame, [6, 24], [0, 1], CLAMP),
          }}
        >
          <span
            style={{
              fontFamily: TYPE.sans,
              fontSize: isPortrait ? 22 : 19,
              fontWeight: 600,
              padding: "10px 22px",
              borderRadius: 999,
              backgroundColor: INK.darkText,
              color: INK.darkBg,
            }}
          >
            Fikih Syafi&apos;i
          </span>
          <span
            style={{
              fontFamily: TYPE.sans,
              fontSize: isPortrait ? 22 : 19,
              fontWeight: 600,
              padding: "10px 22px",
              borderRadius: 999,
              backgroundColor:
                frame >= 265 ? INK.darkText : INK.darkSurface,
              color: frame >= 265 ? INK.darkBg : INK.darkMuted,
              border: `1px solid ${INK.darkRule}`,
            }}
          >
            Perbandingan Mazhab
          </span>
        </div>

        <Interactive.Div
          name="Act 2 Fiqh Question"
          style={{
            fontFamily: TYPE.serif,
            fontSize: isPortrait ? 52 : 48,
            fontWeight: 400,
            lineHeight: 1.24,
            letterSpacing: "-0.015em",
            color: INK.darkText,
          }}
        >
          {visibleQuestion}
        </Interactive.Div>

        <div
          style={{
            fontFamily: TYPE.sans,
            fontSize: isPortrait ? 24 : 20,
            color: INK.darkMuted,
            opacity: interpolate(frame, [112, 136], [0, 1], CLAMP),
          }}
        >
          Menelaah dua ruang mazhab dalam satu layar.
        </div>
      </div>

      {/* Archival Paper Zone: side-by-side / stacked mazhab findings */}
      <div
        style={{
          width: isPortrait ? "100%" : `${paperZonePct}%`,
          height: isPortrait ? `${paperZonePct}%` : "100%",
          backgroundColor: INK.paper,
          borderTop: isPortrait ? `2px solid ${INK.ink}` : "none",
          borderLeft: isPortrait ? "none" : `2px solid ${INK.ink}`,
          paddingLeft: padX,
          paddingRight: padX,
          paddingTop: isPortrait ? 68 : 96,
          paddingBottom: isPortrait ? 88 : 96,
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          gap: isPortrait ? 44 : 40,
          overflow: "hidden",
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            gap: isPortrait ? 44 : 40,
            opacity: interpolate(exitToPaper, [0, 0.45], [1, 0], CLAMP),
          }}
        >
          {/* Panel 1: Mazhab Syafi'i */}
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              gap: 16,
              opacity: syafiiOpacity,
              translate: `0px ${syafiiY}px`,
            }}
          >
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "baseline",
                gap: 16,
              }}
            >
              <span
                style={{
                  fontFamily: TYPE.sans,
                  fontSize: isPortrait ? 24 : 21,
                  fontWeight: 600,
                  color: INK.ink,
                }}
              >
                {CASE_STUDY.syafiiTitle}
              </span>
              <span
                dir="rtl"
                lang="ar"
                style={{
                  fontFamily: TYPE.arabic,
                  fontSize: isPortrait ? 34 : 30,
                  lineHeight: 1.6,
                  letterSpacing: 0,
                  color: INK.inkMuted,
                }}
              >
                المذهب الشافعي
              </span>
            </div>

            <div
              style={{
                fontFamily: TYPE.serif,
                fontSize: isPortrait ? 40 : 34,
                lineHeight: 1.38,
                color: INK.ink,
              }}
            >
              {CASE_STUDY.syafiiBody}
            </div>

            <div
              style={{
                fontFamily: TYPE.sans,
                fontSize: isPortrait ? 22 : 19,
                color: INK.inkMuted,
              }}
            >
              Rujukan: {CASE_STUDY.citationBook}
            </div>
          </div>

          {/* 1px hairline divider */}
          <div
            style={{
              height: 1,
              width: "100%",
              backgroundColor: INK.paperRule,
              transformOrigin: "left center",
              scale: `${jumhurReveal} 1`,
            }}
          />

          {/* Panel 2: Jumhur */}
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              gap: 16,
              opacity: jumhurReveal,
              translate: `0px ${interpolate(jumhurReveal, [0, 1], [28, 0])}px`,
            }}
          >
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "baseline",
                gap: 16,
              }}
            >
              <span
                style={{
                  fontFamily: TYPE.sans,
                  fontSize: isPortrait ? 24 : 21,
                  fontWeight: 600,
                  color: INK.ink,
                }}
              >
                {CASE_STUDY.jumhurTitle}
              </span>
              <span
                dir="rtl"
                lang="ar"
                style={{
                  fontFamily: TYPE.arabic,
                  fontSize: isPortrait ? 34 : 30,
                  lineHeight: 1.6,
                  letterSpacing: 0,
                  color: INK.inkMuted,
                }}
              >
                جمهور الفقهاء
              </span>
            </div>

            <div
              style={{
                fontFamily: TYPE.serif,
                fontSize: isPortrait ? 40 : 34,
                lineHeight: 1.38,
                color: INK.ink,
              }}
            >
              {CASE_STUDY.jumhurBody}
            </div>
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};
