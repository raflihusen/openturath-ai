import {
  AbsoluteFill,
  Img,
  Interactive,
  interpolate,
  staticFile,
  useCurrentFrame,
} from "remotion";
import { HURUF, W, halus, jepit } from "../tema";

// Ibarah asli dari الأسس والمنطلقات, hlm. 27 (dicek ke OUTPUT_V9_2/06, stempel [الأسس والمنطلقات ١/٢٧]).
const KATA =
  "فِي هَذَا الْعِلْمِ سَدُّ كَافَّةِ الثَّغَرَاتِ الَّتِي دَخَلَ مِنْهَا تَحْرِيشُ الشَّيْطَانِ بَيْنَ الْمُصَلِّينَ".split(
    " ",
  );
const BUKTI = ["Ibarah asli", "Nama kitab", "Juz dan halaman"];

/** Adegan 3: OpenTurath menjawab dengan ibarah dan stempel rujukan. */
export const Jawaban: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill
      name="Jawaban"
      style={{
        backgroundColor: W.kertas,
        padding: "220px 90px",
        fontFamily: HURUF.ui,
      }}
    >
      <Interactive.Div
        name="Label"
        style={{
          fontWeight: 600,
          fontSize: 32,
          letterSpacing: 5,
          color: W.abu,
          opacity: interpolate(frame, [0, 20], [0, 1], jepit),
        }}
      >
        DI OPENTURATH
      </Interactive.Div>
      <Interactive.Div
        name="Judul"
        style={{
          marginTop: 36,
          fontFamily: HURUF.serif,
          fontSize: 104,
          lineHeight: 1.04,
          letterSpacing: -2.5,
          color: W.tinta,
          opacity: interpolate(frame, [5, 30], [0, 1], jepit),
          translate: interpolate(frame, [5, 40], ["0px 40px", "0px 0px"], {
            ...jepit,
            easing: halus,
          }),
        }}
      >
        Jawaban menunjuk langsung ke kitabnya.
      </Interactive.Div>

      <Interactive.Div
        name="Kartu ibarah"
        style={{
          marginTop: 80,
          padding: "52px 52px 48px",
          borderRadius: 40,
          background: W.putih,
          border: `3px solid ${W.tinta}`,
          opacity: interpolate(frame, [25, 45], [0, 1], jepit),
          translate: interpolate(frame, [25, 60], ["0px 50px", "0px 0px"], {
            ...jepit,
            easing: halus,
          }),
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 16,
            fontWeight: 600,
            fontSize: 34,
          }}
        >
          <Img
            src={staticFile("logo_hitam.png")}
            style={{ width: 48, height: 48 }}
          />
          OpenTurath
        </div>
        <div
          style={{
            marginTop: 40,
            direction: "rtl",
            display: "flex",
            flexWrap: "wrap",
            columnGap: 18,
            rowGap: 6,
            fontFamily: HURUF.arab,
            fontSize: 66,
            lineHeight: 1.7,
            color: W.tinta,
          }}
        >
          <span
            style={{ opacity: interpolate(frame, [50, 56], [0, 1], jepit) }}
          >
            «
          </span>
          {KATA.map((k, i) => (
            <span
              key={i}
              style={{
                opacity: interpolate(
                  frame,
                  [52 + i * 5, 62 + i * 5],
                  [0, 1],
                  jepit,
                ),
                translate: interpolate(
                  frame,
                  [52 + i * 5, 66 + i * 5],
                  ["0px 18px", "0px 0px"],
                  { ...jepit, easing: halus },
                ),
              }}
            >
              {k}
            </span>
          ))}
          <span
            style={{ opacity: interpolate(frame, [110, 116], [0, 1], jepit) }}
          >
            »
          </span>
        </div>
        <div
          style={{
            marginTop: 36,
            display: "flex",
            justifyContent: "flex-start",
          }}
        >
          <span
            style={{
              fontFamily: HURUF.arab,
              direction: "rtl",
              fontSize: 46,
              background: W.tinta,
              color: W.putih,
              padding: "8px 30px",
              borderRadius: 16,
              opacity: interpolate(frame, [115, 130], [0, 1], jepit),
              scale: interpolate(frame, [115, 140], [0.85, 1], {
                ...jepit,
                easing: halus,
              }),
            }}
          >
            [الأسس والمنطلقات ١/٢٧]
          </span>
        </div>
      </Interactive.Div>

      <div
        style={{
          marginTop: 64,
          display: "flex",
          flexDirection: "column",
          gap: 26,
        }}
      >
        {BUKTI.map((b, i) => (
          <div
            key={b}
            style={{
              display: "flex",
              alignItems: "center",
              gap: 24,
              fontSize: 46,
              color: W.tinta,
              opacity: interpolate(
                frame,
                [140 + i * 10, 155 + i * 10],
                [0, 1],
                jepit,
              ),
              translate: interpolate(
                frame,
                [140 + i * 10, 165 + i * 10],
                ["-30px 0px", "0px 0px"],
                { ...jepit, easing: halus },
              ),
            }}
          >
            <span
              style={{
                width: 56,
                height: 56,
                borderRadius: 14,
                background: W.tinta,
                color: W.putih,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 32,
              }}
            >
              ✓
            </span>
            {b}
          </div>
        ))}
      </div>
    </AbsoluteFill>
  );
};
