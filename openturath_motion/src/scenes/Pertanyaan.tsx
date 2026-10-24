import {
  AbsoluteFill,
  Interactive,
  interpolate,
  useCurrentFrame,
} from "remotion";
import { HURUF, W, halus, jepit } from "../tema";

/** Adegan 2: AI umum menjawab dengan yakin, tetapi tanpa rujukan. */
export const Pertanyaan: React.FC = () => {
  const frame = useCurrentFrame();
  const baris = [0.92, 0.8, 0.86, 0.58];
  return (
    <AbsoluteFill
      name="Pertanyaan"
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
        SETIAP HARI
      </Interactive.Div>
      <Interactive.Div
        name="Kalimat 1"
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
        Kita bertanya kepada AI.
      </Interactive.Div>

      <Interactive.Div
        name="Kartu jawaban"
        style={{
          marginTop: 80,
          padding: "48px 52px",
          borderRadius: 40,
          border: `3px dashed ${W.garis}`,
          opacity: interpolate(frame, [30, 50], [0, 1], jepit),
          translate: interpolate(frame, [30, 60], ["0px 40px", "0px 0px"], {
            ...jepit,
            easing: halus,
          }),
        }}
      >
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <span style={{ fontWeight: 600, fontSize: 36, color: W.abu }}>
            Jawaban AI
          </span>
          <span
            style={{
              fontWeight: 600,
              fontSize: 28,
              color: W.abu,
              background: W.garisHalus,
              padding: "10px 24px",
              borderRadius: 999,
              opacity: interpolate(frame, [95, 110], [0, 1], jepit),
            }}
          >
            Tanpa rujukan
          </span>
        </div>
        <div
          style={{
            marginTop: 40,
            display: "flex",
            flexDirection: "column",
            gap: 22,
          }}
        >
          {baris.map((l, i) => (
            <div
              key={i}
              style={{
                height: 24,
                borderRadius: 12,
                background: W.garis,
                width: `${interpolate(frame, [45 + i * 8, 75 + i * 8], [0, l * 100], { ...jepit, easing: halus })}%`,
              }}
            />
          ))}
        </div>
      </Interactive.Div>

      <Interactive.Div
        name="Kalimat 2"
        style={{
          marginTop: 90,
          fontFamily: HURUF.serif,
          fontSize: 76,
          lineHeight: 1.1,
          color: W.abu,
          opacity: interpolate(frame, [70, 90], [0, 1], jepit),
        }}
      >
        Jawabannya terdengar yakin.
      </Interactive.Div>
      <Interactive.Div
        name="Kalimat 3"
        style={{
          marginTop: 20,
          fontFamily: HURUF.serif,
          fontSize: 120,
          lineHeight: 1.02,
          letterSpacing: -3,
          color: W.tinta,
          opacity: interpolate(frame, [95, 115], [0, 1], jepit),
          translate: interpolate(frame, [95, 125], ["0px 40px", "0px 0px"], {
            ...jepit,
            easing: halus,
          }),
        }}
      >
        Tapi dari kitab mana?
      </Interactive.Div>
    </AbsoluteFill>
  );
};
