import {
  AbsoluteFill,
  Interactive,
  interpolate,
  useCurrentFrame,
} from "remotion";
import { Lengkung } from "../Lengkung";
import { HURUF, W, halus, jepit } from "../tema";

const AI = [
  "Fikih Syafi'i",
  "Fikih Hanafi",
  "Fikih Maliki",
  "Fikih Hanbali",
  "Perbandingan Mazhab & Fatwa",
  "Ushul & Kaidah Fikih",
  "Hadits",
  "Syarah Hadits",
  "Ilmu Hadits",
  "Rijal & Biografi Ulama",
  "Tafsir",
  "Tajwid & Qira'at",
  "Aqidah",
  "Tasawuf",
  "Bahasa Arab",
  "Sejarah & Sirah",
  "Bibliografi Kitab",
];
const BILIK = [
  ["Al-Muhaqqiq", "المحقق"],
  ["Al-Bayan", "البيان"],
  ["Al-Mukhtabir", "المختبر"],
  ["Al-Habib", "الحبيب"],
  ["Al-Khatib", "الخطيب"],
];

/** Adegan 5: 17 AI bidang ilmu mengalir masuk, lalu kartu koleksi utama Fikih Tahawwulat. */
export const DelapanBelasAI: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill
      name="18 AI"
      style={{
        backgroundColor: W.gelap,
        padding: "170px 80px",
        fontFamily: HURUF.ui,
        color: W.terang,
      }}
    >
      <Interactive.Div
        name="Label"
        style={{
          fontWeight: 600,
          fontSize: 32,
          letterSpacing: 5,
          color: W.abuMuda,
          opacity: interpolate(frame, [0, 20], [0, 1], jepit),
        }}
      >
        18 AI
      </Interactive.Div>
      <Interactive.Div
        name="Judul"
        style={{
          marginTop: 30,
          fontFamily: HURUF.serif,
          fontSize: 92,
          lineHeight: 1.04,
          letterSpacing: -2.5,
          opacity: interpolate(frame, [5, 30], [0, 1], jepit),
          translate: interpolate(frame, [5, 40], ["0px 40px", "0px 0px"], {
            ...jepit,
            easing: halus,
          }),
        }}
      >
        Satu bidang ilmu, satu AI.
      </Interactive.Div>

      <div
        style={{
          marginTop: 44,
          display: "flex",
          flexWrap: "wrap",
          gap: 12,
          flexShrink: 0,
        }}
      >
        {AI.map((a, i) => (
          <span
            key={a}
            style={{
              fontSize: 30,
              padding: "11px 24px",
              borderRadius: 999,
              border: `2px solid ${W.gelap3}`,
              background: W.gelap2,
              opacity: interpolate(
                frame,
                [25 + i * 3, 40 + i * 3],
                [0, 1],
                jepit,
              ),
              translate: interpolate(
                frame,
                [25 + i * 3, 50 + i * 3],
                ["0px 24px", "0px 0px"],
                { ...jepit, easing: halus },
              ),
            }}
          >
            {a}
          </span>
        ))}
      </div>

      <Interactive.Div
        name="Kartu Tahawwulat"
        style={{
          position: "relative",
          overflow: "hidden",
          flexShrink: 0,
          marginTop: 44,
          padding: "36px 44px 18px",
          borderRadius: 44,
          background: "#0A0A0A",
          border: "2px solid #3D2A10",
          opacity: interpolate(frame, [95, 115], [0, 1], jepit),
          translate: interpolate(frame, [95, 130], ["0px 80px", "0px 0px"], {
            ...jepit,
            easing: halus,
          }),
        }}
      >
        <Lengkung
          lebar={520}
          kiri={520}
          atas={-60}
          warna="#262626"
          mulai={105}
          lama={50}
        />
        <div
          style={{
            position: "relative",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <span
            style={{
              fontWeight: 600,
              fontSize: 28,
              color: "#F2C48D",
              border: `2px solid ${W.aksen}`,
              padding: "10px 24px",
              borderRadius: 999,
            }}
          >
            Koleksi utama · 5 AI
          </span>
          <span
            style={{ fontFamily: HURUF.arab, fontSize: 52, color: "#BDBDBD" }}
          >
            فقه التحولات
          </span>
        </div>
        <div
          style={{
            position: "relative",
            marginTop: 20,
            fontFamily: HURUF.serif,
            fontSize: 64,
            letterSpacing: -1.5,
          }}
        >
          Fikih Tahawwulat
        </div>
        <div style={{ position: "relative", marginTop: 16 }}>
          {BILIK.map(([n, a], i) => (
            <div
              key={n}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 24,
                padding: "12px 0",
                borderTop: "1.5px solid #2B2B2B",
                opacity: interpolate(
                  frame,
                  [125 + i * 8, 140 + i * 8],
                  [0, 1],
                  jepit,
                ),
                translate: interpolate(
                  frame,
                  [125 + i * 8, 145 + i * 8],
                  ["30px 0px", "0px 0px"],
                  { ...jepit, easing: halus },
                ),
              }}
            >
              <span
                style={{
                  width: 56,
                  height: 56,
                  borderRadius: 14,
                  background: W.gelap3,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontWeight: 600,
                  fontSize: 26,
                }}
              >
                0{i + 1}
              </span>
              <span style={{ flex: 1, fontWeight: 600, fontSize: 38 }}>
                {n}
              </span>
              <span
                style={{
                  fontFamily: HURUF.arab,
                  fontSize: 46,
                  color: "#BDBDBD",
                }}
              >
                {a}
              </span>
            </div>
          ))}
        </div>
      </Interactive.Div>
    </AbsoluteFill>
  );
};
