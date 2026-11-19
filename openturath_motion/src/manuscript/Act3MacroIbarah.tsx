import type React from "react";
import {
  AbsoluteFill,
  Easing,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { CASE_STUDY, CLAMP, EASE_INK, EASE_SHIFT, INK, TYPE } from "./tokens";

export const Act3MacroIbarah: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const isPortrait = height > width;

  // Book margin rule sits on the right side for RTL Arabic kitab reading flow.
  const marginRight = isPortrait ? 80 : 160;
  const contentLeft = isPortrait ? 80 : 160;

  const line1Reveal = interpolate(frame, [10, 48], [0, 1], {
    ...CLAMP,
    easing: EASE_INK,
  });
  const line2Reveal = interpolate(frame, [44, 86], [0, 1], {
    ...CLAMP,
    easing: EASE_INK,
  });

  // Deliberate single accent: "Salin ibarah" inverts to solid ink at local f 225 (15.25s).
  const copied = frame >= 225;
  const pressScale = frame >= 224 && frame <= 232 ? 0.965 : 1;
  const confirmReveal = interpolate(frame, [230, 254], [0, 1], {
    ...CLAMP,
    easing: EASE_INK,
  });

  // Clean vertical upward slide out into Act 4 Fihris index.
  const exitY = interpolate(frame, [302, 330], [0, -height], {
    ...CLAMP,
    easing: EASE_SHIFT,
  });

  const arabicSize = isPortrait ? 68 : 78;

  return (
    <AbsoluteFill style={{ backgroundColor: INK.paper, overflow: "hidden" }}>
      <AbsoluteFill style={{ translate: `0px ${exitY}px` }}>
        {/* Right-edge RTL kitab vertical rule */}
        <div
          style={{
            position: "absolute",
            top: isPortrait ? 136 : 104,
            bottom: isPortrait ? 136 : 104,
            right: marginRight,
            width: 2,
            backgroundColor: INK.ink,
            transformOrigin: "top center",
            scale: `1 ${interpolate(frame, [0, 36], [0, 1], {
              ...CLAMP,
              easing: EASE_INK,
            })}`,
          }}
        />

        <div
          style={{
            position: "absolute",
            top: 0,
            bottom: 0,
            left: contentLeft,
            right: marginRight + (isPortrait ? 40 : 60),
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            gap: isPortrait ? 48 : 36,
          }}
        >
          {/* Real kitab source metadata */}
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: "flex-end",
              textAlign: "right",
              gap: 6,
              opacity: interpolate(frame, [4, 28], [0, 1], CLAMP),
            }}
          >
            <div
              style={{
                fontFamily: TYPE.serif,
                fontSize: isPortrait ? 32 : 28,
                fontWeight: 600,
                color: INK.ink,
              }}
            >
              {CASE_STUDY.citationBook}
            </div>
            <div
              style={{
                fontFamily: TYPE.sans,
                fontSize: isPortrait ? 24 : 20,
                color: INK.inkMuted,
              }}
            >
              {CASE_STUDY.citationAuthor}
            </div>
          </div>

          {/* Macro Classical Arabic Ibarah (animated line-by-line to keep letters joined) */}
          <div
            dir="rtl"
            lang="ar"
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: "flex-start",
              gap: isPortrait ? 18 : 12,
              paddingTop: 12,
              paddingBottom: 12,
            }}
          >
            <div style={{ overflow: "hidden", width: "100%" }}>
              <Interactive.Div
                name="Act 3 Arabic Line 1"
                style={{
                  fontFamily: TYPE.arabic,
                  fontSize: arabicSize,
                  fontWeight: 400,
                  lineHeight: 1.9,
                  letterSpacing: 0,
                  color: INK.ink,
                  opacity: line1Reveal,
                  translate: interpolate(
                    frame,
                    [10, 48],
                    ["0px 44px", "0px 0px"],
                    {
                      extrapolateLeft: "clamp",
                      extrapolateRight: "clamp",
                      easing: Easing.bezier(0.22, 1, 0.36, 1),
                    }
                  ),
                }}
              >
                {CASE_STUDY.ibarahLine1}
              </Interactive.Div>
            </div>

            <div style={{ overflow: "hidden", width: "100%" }}>
              <Interactive.Div
                name="Act 3 Arabic Line 2"
                style={{
                  fontFamily: TYPE.arabic,
                  fontSize: arabicSize,
                  fontWeight: 400,
                  lineHeight: 1.9,
                  letterSpacing: 0,
                  color: INK.ink,
                  opacity: line2Reveal,
                  translate: interpolate(
                    frame,
                    [44, 86],
                    ["0px 44px", "0px 0px"],
                    {
                      extrapolateLeft: "clamp",
                      extrapolateRight: "clamp",
                      easing: Easing.bezier(0.22, 1, 0.36, 1),
                    }
                  ),
                }}
              >
                {CASE_STUDY.ibarahLine2}
              </Interactive.Div>
            </div>
          </div>

          {/* Translation line for Indonesian readers */}
          <div
            style={{
              fontFamily: TYPE.sans,
              fontSize: isPortrait ? 28 : 24,
              lineHeight: 1.5,
              color: INK.inkMuted,
              textAlign: "right",
              maxWidth: isPortrait ? "100%" : 940,
              alignSelf: "flex-end",
              opacity: interpolate(frame, [96, 130], [0, 1], CLAMP),
            }}
          >
            Pendapat terpilih adalah sahnya jual beli mu&apos;athah pada segala
            transaksi yang dinilai masyarakat sebagai jual beli.
          </div>

          {/* Hairline divider + Single Deliberate Accent Action */}
          <div
            style={{
              borderTop: `1px solid ${INK.paperRule}`,
              paddingTop: 32,
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              gap: 24,
              opacity: interpolate(frame, [140, 174], [0, 1], CLAMP),
            }}
          >
            <div
              style={{
                fontFamily: TYPE.sans,
                fontSize: isPortrait ? 26 : 22,
                fontWeight: 600,
                padding: isPortrait ? "18px 38px" : "16px 34px",
                borderRadius: 999,
                backgroundColor: copied ? INK.ink : INK.surface,
                color: copied ? INK.paper : INK.ink,
                border: `2px solid ${INK.ink}`,
                scale: `${pressScale}`,
              }}
            >
              Salin ibarah
            </div>

            <div
              style={{
                fontFamily: TYPE.sans,
                fontSize: isPortrait ? 26 : 22,
                fontWeight: 600,
                color: INK.ink,
                opacity: confirmReveal,
                translate: `${interpolate(confirmReveal, [0, 1], [16, 0])}px 0px`,
              }}
            >
              Ibarah tersalin.
            </div>
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
