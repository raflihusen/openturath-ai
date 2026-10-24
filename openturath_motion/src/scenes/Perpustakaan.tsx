import {
  AbsoluteFill,
  Interactive,
  interpolate,
  useCurrentFrame,
} from "remotion";
import { HURUF, LENGKUNG, W, angkaID, halus, jepit } from "../tema";

// Angka resmi rilis V9.2 (info_ai.json).
const ANGKA = [
  { nilai: 5382, satuan: "kitab turath" },
  { nilai: 812590909, satuan: "kata teks kitab" },
  { nilai: 3001, satuan: "muhadharah" },
];

// Punggung kitab di dalam lengkung: tinggi acak yang tetap (deterministik).
const PUNGGUNG = Array.from({ length: 34 }, (_, i) => ({
  x: 10 + i * 2.35,
  t: 46 + ((((Math.sin(i * 12.9898) * 43758.5453) % 1) + 1) % 1) * 60,
}));

/** Adegan 4: rak kitab tumbuh di dalam lengkung, angka menghitung naik. */
export const Perpustakaan: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill
      name="Perpustakaan"
      style={{ backgroundColor: W.kertas, fontFamily: HURUF.ui }}
    >
      <svg
        width={760}
        height={988}
        viewBox="0 0 100 130"
        style={{ position: "absolute", left: 160, top: 170 }}
      >
        <defs>
          <clipPath id="mihrab">
            <path d={LENGKUNG + " Z"} />
          </clipPath>
        </defs>
        <g clipPath="url(#mihrab)">
          {PUNGGUNG.map((p, i) => {
            const h = interpolate(
              frame,
              [8 + Math.abs(i - 16.5) * 2.2, 50 + Math.abs(i - 16.5) * 2.2],
              [0, p.t],
              { ...jepit, easing: halus },
            );
            return (
              <rect
                key={i}
                x={p.x}
                y={130 - h}
                width={1.7}
                height={h}
                rx={0.4}
                fill={
                  i % 9 === 4 ? W.tinta : i % 3 === 0 ? "#BDBDBD" : "#D4D4D4"
                }
              />
            );
          })}
        </g>
        <path
          d={LENGKUNG}
          fill="none"
          stroke={W.tinta}
          strokeWidth={0.7}
          pathLength={1}
          strokeDasharray="1 1"
          strokeDashoffset={
            1 - interpolate(frame, [0, 50], [0, 1], { ...jepit, easing: halus })
          }
        />
      </svg>

      <AbsoluteFill style={{ padding: "1200px 90px 0" }}>
        <Interactive.Div
          name="Label"
          style={{
            fontWeight: 600,
            fontSize: 32,
            letterSpacing: 5,
            color: W.abu,
            opacity: interpolate(frame, [40, 60], [0, 1], jepit),
          }}
        >
          ISI PERPUSTAKAAN
        </Interactive.Div>
        <div
          style={{
            marginTop: 30,
            display: "flex",
            flexDirection: "column",
            gap: 18,
          }}
        >
          {ANGKA.map((a, i) => (
            <div
              key={a.satuan}
              style={{
                display: "flex",
                alignItems: "baseline",
                justifyContent: "space-between",
                borderTop: `2px solid ${W.garis}`,
                paddingTop: 18,
                opacity: interpolate(
                  frame,
                  [50 + i * 14, 70 + i * 14],
                  [0, 1],
                  jepit,
                ),
              }}
            >
              <span
                style={{
                  fontFamily: HURUF.serif,
                  fontSize: 112,
                  letterSpacing: -3,
                  color: W.tinta,
                  lineHeight: 1,
                }}
              >
                {angkaID(
                  interpolate(
                    frame,
                    [50 + i * 14, 130 + i * 14],
                    [0, a.nilai],
                    { ...jepit, easing: halus },
                  ),
                )}
              </span>
              <span style={{ fontSize: 40, color: W.abu }}>{a.satuan}</span>
            </div>
          ))}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
