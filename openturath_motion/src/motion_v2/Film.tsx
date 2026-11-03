import React from "react";
import {
  AbsoluteFill,
  Audio,
  Img,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { loadFont } from "@remotion/fonts";
import { chan, clamp, mix, step } from "../promo/pegas";

loadFont({
  family: "MotionSans",
  url: staticFile("promo/googlesansflex.woff2"),
  weight: "100 900",
});
const INK = "#09090B",
  PAPER = "#FAFAFA";
const UI = "MotionSans, Outfit, sans-serif";
const AR = "Scheherazade, serif";
const ABS: React.CSSProperties = { position: "absolute" };
const center: React.CSSProperties = {
  ...ABS,
  left: 0,
  top: 0,
  transform: "translate(-50%,-50%)",
};
const c = (t: number, a: number, b: number) => clamp((t - a) / (b - a));
const win = (t: number, a: number, b: number) =>
  clamp(step(t - a, 24, 1) * (1 - step(t - b, 30, 1)));
const cc = (n: number) =>
  `rgb(${Math.round(n)},${Math.round(n)},${Math.round(n)})`;
const val = (t: number, start: number, k: [number, number][], w = 18) =>
  chan(
    t,
    start,
    k.map(([at, v]) => ({ t: at, v, w, z: 0.88 })),
  );
const Icon: React.FC<{ kind?: string; size?: number; color?: string }> = ({
  kind = "book",
  size = 44,
  color = "currentColor",
}) => {
  const paths: Record<string, React.ReactNode> = {
    book: (
      <path d="M3 4c5-1 7 0 9 2 2-2 4-3 9-2v15c-5-1-7 0-9 2-2-2-4-3-9-2zM12 6v15" />
    ),
    search: (
      <>
        <circle cx="10" cy="10" r="6" />
        <path d="m15 15 6 6" />
      </>
    ),
    light: (
      <>
        <path d="M9 18h6M10 21h4M8 14a7 7 0 1 1 8 0l-1 2H9z" />
      </>
    ),
    quiz: (
      <>
        <path d="M5 3h14v18H5zM9 7h6M9 11h2M9 15l2 2 4-4" />
      </>
    ),
    mic: (
      <>
        <rect x="9" y="2" width="6" height="13" rx="3" />
        <path d="M5 10v2a7 7 0 0 0 14 0v-2M12 19v3M8 22h8" />
      </>
    ),
    pen: (
      <>
        <path d="m4 17-1 4 4-1L21 6l-3-3zM14 7l3 3M3 3h9M3 8h5" />
      </>
    ),
    arrow: <path d="M4 12h16M13 5l7 7-7 7" />,
    note: (
      <>
        <path d="M4 3h16v18H4zM8 8h8M8 12h8M8 16h5" />
      </>
    ),
    check: <path d="m4 12 5 5L20 6" />,
  };
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke={color}
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      {paths[kind] || paths.book}
    </svg>
  );
};
const Mark: React.FC<{ white?: boolean; size?: number }> = ({
  white = false,
  size = 90,
}) => (
  <Img
    src={staticFile(`promo/mark_${white ? "white" : "black"}.svg`)}
    style={{ width: size, height: size * 1.1, objectFit: "contain" }}
  />
);
const roles = [
  {
    name: "Al-Muhaqqiq",
    sub: "Teks & ibarah",
    ar: "المحقق",
    icon: "search",
    x: -480,
    y: -218,
  },
  {
    name: "Al-Bayan",
    sub: "Penjelasan sederhana",
    ar: "البيان",
    icon: "light",
    x: 480,
    y: -218,
  },
  {
    name: "Al-Mukhtabir",
    sub: "Uji pemahaman",
    ar: "المختبر",
    icon: "quiz",
    x: 605,
    y: 88,
  },
  {
    name: "Al-Habib",
    sub: "Ceramah Habib Abu Bakar",
    ar: "الحبيب",
    icon: "mic",
    x: 0,
    y: 312,
  },
  {
    name: "Al-Khatib",
    sub: "Materi dakwah & khutbah",
    ar: "الخطيب",
    icon: "pen",
    x: -605,
    y: 88,
  },
];

// One camera and one persistent surface, changing shape through the whole film.
export const ProductMotion: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const t = frame / fps;
  const bgDark = clamp(
    val(
      t,
      0,
      [
        [5.35, 1],
        [10.65, 0],
        [19, 1],
        [24, 0],
      ],
      14,
    ),
  );
  const bg = cc(mix(250, 9, bgDark));
  const bodyDark = clamp(
    val(
      t,
      1,
      [
        [2.95, 0],
        [4.45, 1],
        [5.45, 0],
        [10.8, 1],
        [13.45, 0],
        [19, 0],
        [23.7, 1],
      ],
      20,
    ),
  );
  const body = cc(mix(250, 9, bodyDark));
  const fg = cc(mix(9, 250, bodyDark));
  const W = val(t, 8, [
    [0.18, 180],
    [1.4, 720],
    [2.95, 1190],
    [4.45, 770],
    [5.45, 174],
    [10.75, 1030],
    [13.45, 1230],
    [16.45, 950],
    [19, 1100],
    [22.35, 180],
    [23.7, 174],
  ]);
  const H = val(t, 8, [
    [0.18, 180],
    [1.4, 136],
    [2.95, 530],
    [4.45, 164],
    [5.45, 174],
    [10.75, 140],
    [13.45, 674],
    [16.45, 640],
    [19, 660],
    [22.35, 180],
    [23.7, 190],
  ]);
  const R = val(t, 4, [
    [0.18, 46],
    [1.4, 72],
    [2.95, 38],
    [4.45, 84],
    [5.45, 50],
    [10.75, 72],
    [13.45, 32],
    [16.45, 24],
    [19, 30],
    [22.35, 90],
    [23.7, 38],
  ]);
  const x = val(t, 960, [
    [13.45, 960],
    [16.45, 720],
    [19, 960],
    [22.35, 960],
  ]);
  const y = val(t, 540, [
    [2.95, 570],
    [4.45, 560],
    [5.45, 560],
    [10.75, 570],
    [13.45, 555],
    [19, 555],
    [22.35, 500],
    [25.0, 393],
  ]);
  const cameraScale = val(
    t,
    1,
    [
      [0.18, 1.03],
      [1.4, 1],
      [2.95, 1.02],
      [4.45, 1.05],
      [5.45, 0.98],
      [10.75, 1.03],
      [13.45, 1],
      [16.45, 0.98],
      [19, 0.96],
      [22.35, 1.12],
      [24.5, 1],
    ],
    11,
  );
  const cameraX = 14 * Math.sin(t * 0.38) * win(t, 2, 23);
  const cameraY = 7 * Math.cos(t * 0.49) * win(t, 2, 23);
  const opening = win(t, 1.35, 2.9),
    modules = win(t, 3.04, 4.42),
    selected = win(t, 4.5, 5.42);
  const hub = win(t, 5.55, 10.75),
    input = win(t, 10.95, 13.42),
    work = win(t, 13.65, 18.95),
    tabs = win(t, 19.2, 22.3);
  const final = win(t, 23.95, 40);
  const q = "Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?";
  const qText = q.slice(0, Math.floor(c(t, 11.5, 12.7) * q.length));
  const active = Math.floor(Math.max(0, t - 7.5) * 2) % 5;
  const roleEnter = (i: number) =>
    step(t - 5.7 - i * 0.15, 18, 0.82) * (1 - step(t - 10.15, 20, 0.9));
  const rolePos = (i: number) => {
    const r = roles[i],
      p = roleEnter(i),
      hover = 1.0 + Math.sin(t * 1.7 + i) * 0.012;
    return {
      x: r.x * p + 10 * Math.sin(t * 0.7 + i) * p,
      y: r.y * p + 7 * Math.cos(t * 0.9 + i) * p,
      p,
      hover,
    };
  };
  const pointerX = val(
    t,
    1340,
    [
      [3.1, 1330],
      [3.7, 710],
      [4.05, 1180],
      [4.45, 1180],
      [5.5, 1350],
      [7.6, 1440],
      [8.0, 1440],
      [8.5, 1565],
      [9, 960],
      [9.5, 480],
      [10, 480],
      [10.8, 1410],
      [12.9, 1407],
      [16, 1080],
      [17, 1450],
      [20, 1290],
      [21.5, 1350],
      [22.2, 1900],
    ],
    12,
  );
  const pointerY = val(
    t,
    1100,
    [
      [3.1, 730],
      [3.7, 565],
      [4.05, 565],
      [4.45, 565],
      [5.5, 850],
      [7.6, 345],
      [8, 345],
      [8.5, 648],
      [9, 872],
      [9.5, 342],
      [10, 342],
      [10.8, 580],
      [12.9, 570],
      [16, 740],
      [17, 545],
      [20, 310],
      [21.5, 790],
      [22.2, 1100],
    ],
    12,
  );
  const clicks = [3.7, 4.5, 8, 8.5, 9, 10, 13, 16, 20, 21.5];
  const pointerPulse = clicks.reduce(
    (m, at) => Math.max(m, Math.max(0, Math.sin(c(t, at, at + 0.2) * Math.PI))),
    0,
  );
  return (
    <AbsoluteFill
      style={{
        backgroundColor: bg,
        overflow: "hidden",
        fontFamily: UI,
        color: INK,
      }}
    >
      <Audio src={staticFile("promo/motion_v2.wav")} />
      {/* Spatial tracks: light moves along these paths as the camera pulls through. */}
      <svg
        width="1920"
        height="1080"
        style={{ ...ABS, inset: 0, opacity: 0.12 }}
      >
        {[0, 1, 2, 3, 4, 5].map((i) => (
          <ellipse
            key={i}
            cx={960 + Math.sin(t * 0.15) * 110}
            cy="565"
            rx={280 + i * 175}
            ry={160 + i * 110}
            fill="none"
            stroke={bgDark > 0.5 ? PAPER : INK}
            strokeWidth=".7"
            transform={`rotate(${-20 + t * 1.2} 960 565)`}
          />
        ))}
        <path
          d={`M0 ${540 + Math.sin(t * 0.4) * 150}H1920`}
          stroke={bgDark > 0.5 ? PAPER : INK}
          strokeWidth=".7"
        />
      </svg>
      <div
        style={{
          ...ABS,
          inset: 0,
          transform: `translate(${cameraX}px,${cameraY}px) scale(${cameraScale})`,
          transformOrigin: "960px 540px",
        }}
      >
        {/* Type is attached to the choreography, never a numbered slide. */}
        <div
          style={{
            ...ABS,
            left: 0,
            right: 0,
            top: 115,
            textAlign: "center",
            fontSize: 78,
            fontWeight: 500,
            letterSpacing: -3,
            color: INK,
            opacity: win(t, 2.8, 4.45),
            translate: `0 ${val(t, 40, [
              [2.8, 0],
              [4.45, -65],
            ])}px`,
          }}
        >
          Pilih ruang ilmumu.
        </div>
        <div
          style={{
            ...ABS,
            left: 0,
            right: 0,
            top: 90,
            textAlign: "center",
            color: PAPER,
            opacity: win(t, 5.45, 10.15),
            translate: `0 ${val(t, 30, [
              [5.45, 0],
              [10.15, -50],
            ])}px`,
          }}
        >
          <div style={{ fontSize: 25, letterSpacing: 2, opacity: 0.58 }}>
            FIKIH TAHAWWULAT
          </div>
          <div style={{ fontSize: 64, letterSpacing: -2, marginTop: 12 }}>
            Lima AI. Lima cara mendalami.
          </div>
        </div>
        <div
          style={{
            ...ABS,
            left: 0,
            right: 0,
            top: 145,
            textAlign: "center",
            fontSize: 72,
            fontWeight: 500,
            letterSpacing: -2,
            color: INK,
            opacity: win(t, 10.85, 13.4),
          }}
        >
          Dari satu pertanyaan.
        </div>
        <div
          style={{
            ...ABS,
            left: 0,
            right: 0,
            top: 100,
            textAlign: "center",
            fontSize: 67,
            fontWeight: 500,
            letterSpacing: -2,
            color: INK,
            opacity: win(t, 13.6, 18.8),
          }}
        >
          Telusuri sampai ke sumber.
        </div>
        <div
          style={{
            ...ABS,
            left: 0,
            right: 0,
            top: 95,
            textAlign: "center",
            fontSize: 64,
            letterSpacing: -2,
            color: PAPER,
            opacity: win(t, 19.1, 22.3),
          }}
        >
          Percakapanmu. Ruang belajarmu.
        </div>
        {/* Five research roles grow from one hub and return to it. */}
        <svg
          width="1920"
          height="1080"
          style={{ ...ABS, inset: 0, opacity: hub }}
        >
          {roles.map((r, i) => {
            const p = rolePos(i);
            return (
              <g key={r.name}>
                <path
                  d={`M960 560 Q${960 + p.x * 0.22} ${560 + p.y * 0.9} ${960 + p.x} ${560 + p.y}`}
                  stroke="#52525B"
                  strokeWidth="1.4"
                  fill="none"
                  pathLength={1}
                  strokeDasharray={1}
                  strokeDashoffset={1 - p.p}
                />
                <circle
                  cx={960 + p.x * (((t - 5.5) * 0.5 + i * 0.21) % 1)}
                  cy={560 + p.y * (((t - 5.5) * 0.5 + i * 0.21) % 1)}
                  r="3"
                  fill={PAPER}
                  opacity={p.p}
                />
              </g>
            );
          })}
        </svg>
        {roles.map((r, i) => {
          const p = rolePos(i);
          return (
            <div
              key={r.name}
              style={{
                ...ABS,
                left: 960 + p.x,
                top: 560 + p.y,
                width: 355,
                height: 136,
                boxSizing: "border-box",
                padding: "24px 27px",
                border: `1px solid ${i === active ? "#FAFAFA" : "#3F3F46"}`,
                background: i === active ? "#FAFAFA" : "#18181B",
                color: i === active ? INK : PAPER,
                borderRadius: 22,
                opacity: p.p,
                transform: `translate(-50%,-50%) scale(${Math.max(0.01, p.p) * p.hover}) rotate(${(1 - p.p) * (i - 2) * 12}deg)`,
                boxShadow: "0 20px 45px #0002",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
                <Icon kind={r.icon} size={30} />
                <span
                  style={{ fontSize: 32, fontWeight: 550, letterSpacing: -1 }}
                >
                  {r.name}
                </span>
              </div>
              <div style={{ fontSize: 20, marginTop: 13, opacity: 0.64 }}>
                {r.sub}
              </div>
            </div>
          );
        })}
        {/* The persistent surface: tile -> selector -> hub -> query -> research -> tabs -> mark. */}
        <div
          style={{
            ...ABS,
            left: x,
            top: y,
            width: Math.max(1, W),
            height: Math.max(1, H),
            borderRadius: Math.max(0, R),
            background: body,
            color: fg,
            transform: `translate(-50%,-50%) rotate(${val(
              t,
              0,
              [
                [0.18, -8],
                [1.4, 0],
                [2.95, -1],
                [4.45, 0],
                [13.45, -1],
                [16.45, -3],
                [19, 1],
                [22.35, -12],
                [24, 0],
              ],
              16,
            )}deg)`,
            boxShadow: `0 1px 0 #ffffff30 inset,0 30px 90px rgba(0,0,0,${mix(0.15, 0.04, bodyDark)})`,
            overflow: "hidden",
            border: `1px solid ${bodyDark > 0.5 ? "#27272A" : "#D4D4D8"}`,
          }}
        >
          <div style={{ ...ABS, left: "50%", top: "50%" }}>
            <div style={{ ...center, opacity: win(t, 0.25, 1.35) }}>
              <Mark white size={92} />
            </div>
            <div
              style={{
                ...center,
                display: "flex",
                alignItems: "center",
                gap: 28,
                width: 630,
                justifyContent: "center",
                opacity: opening,
              }}
            >
              <div
                style={{
                  scale: val(t, 0.7, [
                    [0.3, 1],
                    [1.4, 0.85],
                  ]),
                }}
              >
                <Mark white size={81} />
              </div>
              <span
                style={{
                  fontSize: 61,
                  fontWeight: 550,
                  letterSpacing: -3,
                  whiteSpace: "nowrap",
                  clipPath: `inset(0 ${100 * (1 - step(t - 1.4, 14, 1))}% 0 0)`,
                }}
              >
                OpenTurath AI
              </span>
            </div>
            <div
              style={{
                ...ABS,
                left: -560,
                top: -225,
                width: 1120,
                height: 450,
                opacity: modules,
                display: "flex",
                gap: 26,
              }}
            >
              {[0, 1].map((i) => (
                <div
                  key={i}
                  style={{
                    position: "relative",
                    width: 547,
                    height: 450,
                    background: i ? "#09090B" : "#F0F0F1",
                    color: i ? PAPER : INK,
                    borderRadius: 22,
                    overflow: "hidden",
                    transform: `translateX(${(1 - step(t - 3.07 - i * 0.13, 20, 0.83)) * (i ? 140 : -140)}px) scale(${i ? 1 + 0.02 * Math.sin(c(t, 4.05, 4.45) * Math.PI) : 1})`,
                  }}
                >
                  {i ? (
                    <Img
                      src={staticFile("promo/tahawwulat-current.png")}
                      style={{
                        width: 310,
                        height: 310,
                        objectFit: "cover",
                        position: "absolute",
                        right: -5,
                        top: 0,
                        opacity: 0.75,
                        transform: `scale(${1.05 + c(t, 3, 4.5) * 0.1})`,
                      }}
                    />
                  ) : (
                    <svg
                      width="380"
                      height="280"
                      viewBox="0 0 380 280"
                      style={{ ...ABS, right: 0, top: 15, opacity: 0.65 }}
                    >
                      {[0, 1, 2, 3, 4, 5, 6].map((j) => (
                        <path
                          key={j}
                          d={`M${35 + j * 20} 240V${100 - j * 9}Q190 ${20 + j * 5} ${345 - j * 8} ${90 + j * 8}V240`}
                          stroke="#52525B"
                          strokeWidth="2"
                          fill="none"
                          transform={`rotate(${Math.sin(t + j) * 2} 190 140)`}
                        />
                      ))}
                    </svg>
                  )}
                  <div style={{ ...ABS, left: 35, bottom: 40 }}>
                    <div
                      style={{ fontSize: 22, opacity: 0.55, marginBottom: 12 }}
                    >
                      BIDANG ILMU
                    </div>
                    <div
                      style={{
                        fontSize: 43,
                        fontWeight: 550,
                        letterSpacing: -1,
                      }}
                    >
                      {i ? "Fikih Tahawwulat" : "Fikih Syafi’i"}
                    </div>
                  </div>
                  <div style={{ ...ABS, right: 30, bottom: 40 }}>
                    <Icon kind="arrow" size={34} />
                  </div>
                </div>
              ))}
            </div>
            <div
              style={{
                ...center,
                width: 680,
                display: "flex",
                alignItems: "center",
                gap: 25,
                opacity: selected,
              }}
            >
              <Img
                src={staticFile("promo/tahawwulat-current.png")}
                style={{
                  width: 105,
                  height: 105,
                  objectFit: "cover",
                  borderRadius: 53,
                }}
              />
              <div>
                <div style={{ fontSize: 20, opacity: 0.55, marginBottom: 5 }}>
                  RUANG PILIHANMU
                </div>
                <div style={{ fontSize: 44, letterSpacing: -1 }}>
                  Fikih Tahawwulat
                </div>
              </div>
              <div style={{ marginLeft: "auto" }}>
                <Icon kind="check" />
              </div>
            </div>
            <div style={{ ...center, opacity: hub }}>
              <Mark size={81} />
            </div>
            <div
              style={{
                ...center,
                width: 930,
                display: "flex",
                alignItems: "center",
                gap: 24,
                opacity: input,
              }}
            >
              <Icon kind="search" size={30} />
              <div
                style={{
                  fontSize: 25,
                  whiteSpace: "nowrap",
                  letterSpacing: -0.6,
                }}
              >
                {qText}
                <span style={{ opacity: t < 12.8 ? 1 : 0, color: "#A1A1AA" }}>
                  |
                </span>
              </div>
              <div
                style={{
                  marginLeft: "auto",
                  padding: "13px 16px",
                  borderRadius: 28,
                  background: PAPER,
                  color: INK,
                  scale: 1 - pointerPulse * 0.13,
                }}
              >
                <Icon kind="arrow" size={28} />
              </div>
            </div>
            {/* A diagram of the product flow, without fabricated quotations or page numbers. */}
            <div
              style={{
                ...ABS,
                left: -W / 2,
                top: -H / 2,
                width: W,
                height: H,
                opacity: work,
              }}
            >
              <div
                style={{
                  height: 76,
                  borderBottom: "1px solid #E4E4E7",
                  padding: "0 30px",
                  display: "flex",
                  alignItems: "center",
                  gap: 15,
                }}
              >
                <Mark size={28} />
                <span style={{ fontSize: 23, fontWeight: 550 }}>
                  Al-Muhaqqiq
                </span>
                <span
                  style={{ fontSize: 18, marginLeft: "auto", opacity: 0.45 }}
                >
                  Fikih Tahawwulat
                </span>
              </div>
              <div style={{ display: "flex", height: H - 76 }}>
                <div
                  style={{
                    width: "64%",
                    boxSizing: "border-box",
                    padding: "35px 38px",
                    borderRight: "1px solid #E4E4E7",
                  }}
                >
                  <div
                    style={{
                      background: "#F1F1F2",
                      borderRadius: 19,
                      padding: "21px 25px",
                      fontSize: 25,
                      lineHeight: 1.4,
                    }}
                  >
                    {q}
                  </div>
                  <div style={{ marginTop: 34, fontSize: 20, opacity: 0.5 }}>
                    ALUR PENELUSURAN
                  </div>
                  {["Penjelasan", "Ibarah", "Rujukan kitab"].map((word, i) => (
                    <div
                      key={word}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: 17,
                        marginTop: 20,
                        opacity: step(t - 14 - i * 0.25, 19, 1),
                        transform: `translateY(${28 * (1 - step(t - 14 - i * 0.25, 20, 1))}px)`,
                      }}
                    >
                      <div
                        style={{
                          width: 34,
                          height: 34,
                          border: "1px solid #A1A1AA",
                          borderRadius: 18,
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          fontSize: 16,
                        }}
                      >
                        {i + 1}
                      </div>
                      <span style={{ fontSize: 30 }}>{word}</span>
                      <div
                        style={{
                          height: 1,
                          flex: 1,
                          background: "#D4D4D8",
                          transform: `scaleX(${step(t - 14.15 - i * 0.25, 14, 1)})`,
                          transformOrigin: "left",
                        }}
                      />
                    </div>
                  ))}
                  <div style={{ display: "flex", marginTop: 27, gap: 9 }}>
                    {[0, 1, 2, 3, 4, 5].map((i) => (
                      <div
                        key={i}
                        style={{
                          height: 6,
                          width: 35 + i * 4,
                          borderRadius: 3,
                          background: "#D4D4D8",
                          opacity: 0.4 + 0.5 * Math.sin(t * 3 + i) ** 2,
                        }}
                      />
                    ))}
                  </div>
                </div>
                <div
                  style={{
                    padding: "35px 30px",
                    width: "36%",
                    boxSizing: "border-box",
                  }}
                >
                  <div style={{ fontSize: 16, opacity: 0.5, marginBottom: 26 }}>
                    KITAB DALAM BIDANG INI
                  </div>
                  <div
                    style={{
                      background: INK,
                      borderRadius: 14,
                      padding: "27px 20px",
                      color: PAPER,
                      transform: `translateY(${7 * Math.sin(t)}px)`,
                    }}
                  >
                    <div
                      style={{
                        fontFamily: AR,
                        fontSize: 42,
                        textAlign: "right",
                      }}
                    >
                      المرصد النبوي
                    </div>
                    <div style={{ fontSize: 23, marginTop: 12 }}>
                      Al-Marshad An-Nabawi
                    </div>
                    <div
                      style={{
                        fontSize: 17,
                        opacity: 0.6,
                        marginTop: 12,
                        lineHeight: 1.5,
                      }}
                    >
                      Habib Abu Bakar
                      <br />
                      Al-Masyhur
                    </div>
                  </div>
                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: 10,
                      fontSize: 20,
                      marginTop: 25,
                    }}
                  >
                    <Icon kind="book" size={25} />
                    <span>Telusuri kitab</span>
                  </div>
                </div>
              </div>
            </div>
            {/* Multi-tab workspace: surfaces continue moving into a five-page fan. */}
            <div
              style={{
                ...ABS,
                left: -W / 2,
                top: -H / 2,
                width: W,
                height: H,
                opacity: tabs,
              }}
            >
              <div
                style={{
                  height: 80,
                  padding: "0 24px",
                  display: "flex",
                  alignItems: "end",
                  borderBottom: "1px solid #D4D4D8",
                  gap: 5,
                }}
              >
                {["Tahawwulat", "Syafi’i", "Catatan"].map((txt, i) => (
                  <div
                    key={txt}
                    style={{
                      borderRadius: "14px 14px 0 0",
                      background: i === 2 ? INK : "#EEEEEF",
                      color: i === 2 ? PAPER : INK,
                      padding: "18px 26px",
                      fontSize: 21,
                      transform: `translateY(${40 * (1 - step(t - 19.5 - i * 0.15, 22, 0.8))}px)`,
                    }}
                  >
                    {txt}
                  </div>
                ))}
              </div>
              <div style={{ padding: "40px 55px" }}>
                <div
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 20,
                    fontSize: 31,
                  }}
                >
                  <Icon kind="note" size={36} />
                  Catatan pembacaan
                  <div
                    style={{
                      fontSize: 17,
                      marginLeft: "auto",
                      color: "#71717A",
                      display: "flex",
                      gap: 8,
                      opacity: step(t - 21.5, 22, 1),
                    }}
                  >
                    <Icon kind="check" size={19} />
                    Tersimpan
                  </div>
                </div>
                {[78, 91, 67, 85, 52, 73].map((w, i) => (
                  <div
                    key={i}
                    style={{
                      height: 9,
                      background: "#D4D4D8",
                      borderRadius: 5,
                      marginTop: i ? 24 : 40,
                      width: `${w}%`,
                      transform: `scaleX(${step(t - 20 - i * 0.13, 18, 1)})`,
                      transformOrigin: "left",
                    }}
                  />
                ))}
              </div>
            </div>
            <div
              style={{
                ...center,
                opacity: win(t, 22.6, 40),
                transform: `translate(-50%,-50%) rotate(${val(t, 0, [
                  [22.4, 20],
                  [24, 0],
                ])}deg)`,
              }}
            >
              <Mark white={bodyDark > 0.5} size={93} />
            </div>
          </div>
        </div>
        {/* Pages lift out of the workspace, briefly becoming a dimensional fan. */}
        {[0, 1, 2, 3].map((i) => {
          const p = win(t, 20 + i * 0.25, 23.1),
            out = step(t - 22.3, 17, 0.85);
          return (
            <div
              key={i}
              style={{
                ...ABS,
                left: 960 + (i - 1.5) * 230 * (1 - out),
                top: 570 + Math.abs(i - 1.5) * 40 - 130 * out,
                width: 260 * (1 - out) + 10,
                height: 340 * (1 - out) + 10,
                background: i % 2 ? PAPER : "#18181B",
                border: "1px solid #71717A",
                borderRadius: 20,
                opacity: p * 0.85,
                transform: `translate(-50%,-50%) rotate(${(i - 1.5) * 12 * (1 - out)}deg) scale(${step(t - 20 - i * 0.25, 20, 0.8)})`,
                zIndex: -1,
                boxShadow: "0 15px 45px #0004",
              }}
            />
          );
        })}
        {/* Source cover extracts from the study surface into the foreground. */}
        <div
          style={{
            ...ABS,
            left: 1455,
            top: 560,
            width: 350,
            height: 470,
            background: INK,
            color: PAPER,
            borderRadius: "7px 20px 20px 7px",
            borderLeft: "10px solid #3F3F46",
            boxShadow: "12px 18px 0 #D4D4D8,0 40px 60px #0002",
            opacity: win(t, 16.5, 18.9),
            transform: `translate(-50%,-50%) perspective(1300px) rotateY(${val(
              t,
              -55,
              [
                [16.5, -12],
                [17.7, 10],
                [18.8, 65],
              ],
            )}deg) rotateZ(-4deg) scale(${val(t, 0.2, [[16.5, 1]])})`,
          }}
        >
          <div
            style={{
              padding: "38px 20px",
              border: "1px solid #52525B",
              margin: 22,
              height: 420,
              boxSizing: "border-box",
              textAlign: "center",
            }}
          >
            <div
              style={{
                fontFamily: AR,
                fontSize: 42,
                marginTop: 35,
                whiteSpace: "nowrap",
                lineHeight: 1.2,
              }}
            >
              المرصد النبوي
            </div>
            <div
              style={{ height: 1, background: "#71717A", margin: "25px 10px" }}
            />
            <div style={{ fontSize: 25, lineHeight: 1.35 }}>
              Al-Marshad
              <br />
              An-Nabawi
            </div>
            <div
              style={{
                fontSize: 17,
                lineHeight: 1.4,
                opacity: 0.55,
                marginTop: 30,
              }}
            >
              Habib Abu Bakar
              <br />
              Al-Masyhur
            </div>
          </div>
        </div>
        {/* Final identity resolves from the same surface. */}
        <div
          style={{
            ...ABS,
            left: 0,
            right: 0,
            top: 570,
            textAlign: "center",
            opacity: final,
            translate: `0 ${35 * (1 - step(t - 24, 14, 1))}px`,
          }}
        >
          <div style={{ fontSize: 94, fontWeight: 550, letterSpacing: -5 }}>
            OpenTurath AI
          </div>
          <div style={{ fontSize: 29, color: "#71717A", marginTop: 16 }}>
            Fikih Syafi’i · Fikih Tahawwulat
          </div>
          <div
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: 28,
              marginTop: 49,
              fontSize: 26,
              padding: "18px 27px",
              borderRadius: 40,
              border: "1px solid #D4D4D8",
            }}
          >
            <span>openturath.id</span>
            <Icon kind="arrow" size={26} />
          </div>
        </div>
      </div>
      {/* The pointer traces the actual actions, with contact compression and a ripple. */}
      <div
        style={{
          ...ABS,
          left: pointerX,
          top: pointerY,
          opacity: win(t, 3.1, 22.15),
          transform: `rotate(-8deg) scale(${1 - pointerPulse * 0.16})`,
          filter: "drop-shadow(0 4px 4px #0003)",
        }}
      >
        <svg width="33" height="43" viewBox="0 0 28 36">
          <path
            d="M2 2v29l7-7 5 10 5-3-5-10h11z"
            fill={PAPER}
            stroke={INK}
            strokeWidth="2.1"
            strokeLinejoin="round"
          />
        </svg>
      </div>
      {clicks.map((at) => {
        const p = c(t, at, at + 0.42);
        return p > 0 && p < 1 ? (
          <div
            key={at}
            style={{
              ...ABS,
              left: pointerX,
              top: pointerY,
              width: 12 + p * 80,
              height: 12 + p * 80,
              border: `2px solid ${bgDark > 0.5 ? PAPER : INK}`,
              borderRadius: "50%",
              transform: "translate(-50%,-50%)",
              opacity: (1 - p) * 0.5,
            }}
          />
        ) : null;
      })}
      <div
        style={{
          ...ABS,
          left: 64,
          bottom: 42,
          display: "flex",
          gap: 12,
          alignItems: "center",
          color: bgDark > 0.5 ? PAPER : INK,
          opacity: win(t, 2.7, 23.4) * 0.36,
          fontSize: 16,
          letterSpacing: 1,
        }}
      >
        <span
          style={{
            width: 5,
            height: 5,
            background: "currentColor",
            borderRadius: 3,
          }}
        />
        VISUALISASI ALUR OPENTURATH AI
      </div>
      <div
        style={{
          ...ABS,
          right: 64,
          bottom: 42,
          color: bgDark > 0.5 ? PAPER : INK,
          opacity: 0.35,
          fontSize: 16,
          letterSpacing: 2,
        }}
      >
        OPENTURATH
      </div>
      <div
        style={{
          ...ABS,
          left: 0,
          bottom: 0,
          height: 3,
          width: `${c(t, 0, 28) * 100}%`,
          background: bgDark > 0.5 ? PAPER : INK,
          opacity: 0.12,
        }}
      />
    </AbsoluteFill>
  );
};
