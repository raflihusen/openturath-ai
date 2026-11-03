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
import {
  DashboardScreen,
  DirectoryScreen,
  TahawwulatScreen,
  PickerScreen,
  NotesScreen,
  U,
  InkCard,
} from "./AppUI";
import { ChatScreen, LibraryScreen, NoteReaderScreen } from "./StudyUI";

loadFont({
  family: "Scheherazade New",
  url: staticFile("fonts/NativeArabic.ttf"),
  weight: "400",
});
loadFont({
  family: "FilmArabicUI",
  url: staticFile("film60/Cairo-700.ttf"),
  weight: "700",
});
const ease = (t: number, at: number, w = 18, z = 0.95) => step(t - at, w, z);
const key = (t: number, initial: number, keys: [number, number][], w = 15) =>
  chan(
    t,
    initial,
    keys.map(([at, v]) => ({ t: at, v, w, z: 0.95 })),
  );
const range = (t: number, a: number, b: number) => clamp((t - a) / (b - a));
const show = (t: number, a: number, b: number) =>
  clamp(ease(t, a, 26, 1) * (1 - ease(t, b, 26, 1)));
const pos: React.CSSProperties = { position: "absolute" };
const captions: [number, number, string][] = [
  [5, 10.8, "Ruang belajar,\ndalam genggaman."],
  [11.2, 15.5, "Seluas\nkhazanah turats."],
  [15.8, 21.7, "Temukan AI\nsesuai bidangmu."],
  [22.2, 25.1, "Fikih Tahawwulat.\nLima peran AI."],
  [25.5, 29.1, "Pilih cara\nmendalami."],
  [29.4, 32.8, "Contohnya di\nFikih Syafi’i."],
  [33.2, 39.8, "Baca penjelasan.\nTelusuri ibarah."],
  [40.6, 45.8, "Kenali kitab\nyang dirujuk."],
  [46.3, 50.8, "Bandingkan\nruang kajian."],
  [51.6, 55.1, "Simpan untuk\ndipelajari kembali."],
];
const Q = "Bagaimana hukum bersentuhan kulit dengan non-mahram terhadap wudhu?";
const rail = [
  ["Hadits", "الحديث"],
  ["Tafsir", "التفسير"],
  ["Akidah", "العقيدة"],
  ["Ushul & Kaidah Fikih", "أصول الفقه"],
  ["Bahasa Arab", "علوم العربية"],
  ["Sejarah & Sirah", "التاريخ"],
  ["Tasawuf", "التصوف"],
  ["Bibliografi Kitab", "الفهارس"],
];

const Route: React.FC<{
  t: number;
  start: number;
  end: number;
  modal?: boolean;
  children: React.ReactNode;
}> = ({ t, start, end, modal = false, children }) => {
  const enter = ease(t, start, 20, 1),
    leave = ease(t, end, 25, 1);
  return (
    <div
      style={{
        ...pos,
        inset: 0,
        opacity: clamp(enter * (1 - leave)),
        transform: modal
          ? undefined
          : `translateX(${420 * (1 - enter) - 45 * leave}px)`,
        overflow: "hidden",
      }}
    >
      {children}
    </div>
  );
};
const Word: React.FC<{
  t: number;
  start: number;
  end: number;
  text: string;
  dark: number;
}> = ({ t, start, end, text, dark }) => {
  const p = ease(t, start, 18, 1),
    o = show(t, start, end);
  return (
    <div
      style={{
        ...pos,
        left: 86,
        right: 86,
        top: 116,
        opacity: o,
        color: dark > 0.5 ? "#FAFAFA" : "#171717",
        fontFamily: "Newsreader",
        fontSize: 87,
        lineHeight: 0.98,
        letterSpacing: -2.7,
        fontWeight: 400,
        whiteSpace: "pre-line",
        transform: `translateY(${26 * (1 - p)}px)`,
        zIndex: 30,
      }}
    >
      {text}
    </div>
  );
};
const PartLogo: React.FC<{ t: number; ending?: boolean }> = ({
  t,
  ending = false,
}) => {
  const time = ending ? t - 54.7 : t;
  const parts = ["arch", "dome", "left", "right"];
  return (
    <div
      style={{
        ...pos,
        left: "50%",
        top: "50%",
        width: 1024,
        height: 1024,
        transform: `translate(-50%,-50%) scale(${ending ? 0.72 : 0.84})`,
      }}
    >
      {parts.map((part, i) => {
        const p = ease(time, 0.25 + i * 0.27, 9, 0.85);
        const displace = [
          [-130, -90],
          [100, -200],
          [-170, 150],
          [170, 150],
        ][i];
        return (
          <Img
            key={part}
            src={staticFile(`film60/logo_${part}.svg`)}
            style={{
              ...pos,
              inset: 0,
              width: 1024,
              height: 1024,
              opacity: clamp(p),
              filter: ending ? "invert(1)" : "none",
              transform: `translate(${displace[0] * (1 - p)}px,${displace[1] * (1 - p)}px) rotate(${(i % 2 ? 1 : -1) * 16 * (1 - p)}deg)`,
            }}
          />
        );
      })}
    </div>
  );
};

export const OpenTurathFilm60: React.FC = () => {
  const frame = useCurrentFrame(),
    { fps } = useVideoConfig(),
    t = frame / fps;
  const dark = clamp(
    key(
      t,
      0,
      [
        [22, 0.98],
        [29.35, 0],
        [55.1, 1],
      ],
      9,
    ),
  );
  const bg = Math.round(mix(246, 9, dark));
  const phoneVisible = show(t, 3.8, 55.1);
  const scale = key(
    t,
    0.15,
    [
      [3.8, 0.2],
      [4.85, 1.66],
      [7.2, 1.72],
      [10.6, 1.67],
      [11.2, 1.72],
      [15.5, 1.74],
      [19.5, 1.7],
      [22, 1.67],
      [25.3, 1.7],
      [29.5, 1.68],
      [30.3, 1.74],
      [32.5, 1.7],
      [36.8, 1.74],
      [40.35, 1.72],
      [46, 1.7],
      [49.5, 1.7],
      [51.4, 1.68],
      [55.1, 0.18],
    ],
    10,
  );
  const px = key(
    t,
    540,
    [
      [7.2, 530],
      [10.6, 540],
      [15.5, 545],
      [19.5, 537],
      [22, 540],
      [30.3, 535],
      [32.5, 540],
      [36.8, 538],
      [40.35, 544],
      [46, 535],
      [51.4, 540],
      [55.1, 540],
    ],
    9,
  );
  const py = key(
    t,
    870,
    [
      [3.8, 870],
      [4.85, 1040],
      [7.2, 1040],
      [10.6, 1040],
      [11.2, 1045],
      [15.5, 1045],
      [19.5, 1040],
      [22, 1040],
      [25.3, 1040],
      [29.5, 1040],
      [30.3, 1040],
      [32.5, 1040],
      [36.8, 1045],
      [40.35, 1045],
      [46, 1040],
      [49.5, 1040],
      [51.4, 1040],
      [55.1, 900],
    ],
    9,
  );
  const tilt = key(
    t,
    0,
    [
      [4.85, -2],
      [7.2, 1],
      [10.6, 0],
      [11.2, -1],
      [19.5, 1],
      [22, 0],
      [30.3, -1],
      [32.5, 0],
      [40.35, 1],
      [46, -1],
      [51.4, 0],
      [55.1, 8],
    ],
    10,
  );
  const ry = key(
    t,
    -18,
    [
      [4.85, -5],
      [7.2, 2],
      [10.6, 0],
      [11.2, 3],
      [19.5, -2],
      [22, 0],
      [30.3, 0],
      [32.5, 0],
      [40.35, -3],
      [46, 2],
      [51.4, 0],
      [55.1, 36],
    ],
    10,
  );
  const dashboardScroll = key(
    t,
    0,
    [
      [7.8, 110],
      [9, 255],
      [10, 300],
    ],
    8,
  );
  // Real content scrolls within its native viewport; the header and bottom nav stay fixed.
  const directoryScroll = key(
    t,
    0,
    [
      [12, 280],
      [13.5, 485],
      [15, 680],
      [16.5, 890],
      [18, 1100],
      [19.5, 1380],
      [20.2, 1660],
    ],
    7,
  );
  const typed = Q.slice(0, Math.floor(range(t, 30.5, 32.25) * Q.length));
  const answer = range(t, 33, 36.7);
  const answerScroll = key(
    t,
    0,
    [
      [35.7, 80],
      [37.2, 205],
      [38.5, 225],
    ],
    7,
  );
  const libraryScroll = key(
    t,
    0,
    [
      [41.4, 65],
      [42.7, 165],
      [44.1, 245],
    ],
    7,
  );
  const modalP = clamp(ease(t, 25.3, 14, 1) * (1 - ease(t, 29, 20, 1)));
  const select = t > 27.7 && t < 28.5 ? 0 : -1;
  const final = show(t, 56.4, 70);
  const clickTimes = [
    11, 25, 29, 30.3, 32.5, 37.5, 40, 46, 47.3, 48.6, 50.8, 51.4, 53.5,
  ];
  // Cursor coordinates are defined in the actual 420 × 820 app plane.
  const cursorX = key(
    t,
    210,
    [
      [10.9, 156],
      [24.8, 175],
      [28.8, 210],
      [30.2, 100],
      [32.4, 384],
      [37.5, 335],
      [39.9, 355],
      [45.8, 26],
      [47.2, 175],
      [48.5, 64],
      [50.7, 26],
      [51.3, 265],
      [53.4, 200],
    ],
    14,
  );
  const cursorY = key(
    t,
    890,
    [
      [10.9, 788],
      [24.8, 240],
      [28.8, 76],
      [30.2, 340],
      [32.4, 786],
      [37.5, 400],
      [39.9, 33],
      [45.8, 31],
      [47.2, 85],
      [48.5, 85],
      [50.7, 31],
      [51.3, 788],
      [53.4, 268],
    ],
    14,
  );
  const cursorOpacity =
    show(t, 10.7, 11.4) +
    show(t, 24.8, 25.5) +
    show(t, 28.7, 29.3) +
    show(t, 30.1, 30.65) +
    show(t, 32.25, 32.8) +
    show(t, 37.25, 37.85) +
    show(t, 39.75, 40.55) +
    show(t, 45.75, 46.3) +
    show(t, 47.05, 49) +
    show(t, 50.6, 51.7) +
    show(t, 53.3, 53.85);
  const press = clickTimes.reduce(
    (m, a) => Math.max(m, Math.sin(range(t, a, a + 0.19) * Math.PI)),
    0,
  );
  return (
    <AbsoluteFill
      style={{
        backgroundColor: `rgb(${bg},${bg},${bg})`,
        overflow: "hidden",
        fontFamily: "Outfit",
        color: U.ink,
      }}
    >
      <Audio src={staticFile("film60/soundtrack.wav")} />
      {/* A paper axis connects the composition to the app's editorial visual language. */}
      <div
        style={{
          ...pos,
          left: 63,
          top: 70,
          bottom: 70,
          width: 1,
          background: dark > 0.5 ? "#fff" : "#171717",
          opacity: 0.055,
        }}
      />
      <div
        style={{
          ...pos,
          right: 63,
          top: 70,
          bottom: 70,
          width: 1,
          background: dark > 0.5 ? "#fff" : "#171717",
          opacity: 0.055,
        }}
      />
      <div
        style={{
          ...pos,
          left: 87,
          top: 54,
          fontSize: 20,
          letterSpacing: 2.2,
          color: dark > 0.5 ? "#fff" : "#171717",
          opacity: show(t, 4.7, 55) * 0.47,
        }}
      >
        OPENTURATH AI
      </div>
      {/* Opening: the exact four vector components from the app assemble in space. */}
      <div
        style={{
          ...pos,
          left: 0,
          right: 0,
          top: 120,
          height: 1250,
          opacity: 1 - ease(t, 3.85, 17, 1),
          transform: `translateY(${-140 * ease(t, 3.8, 15, 1)}px) scale(${1 - 0.3 * ease(t, 3.8, 15, 1)})`,
        }}
      >
        <PartLogo t={t} />
        <div
          style={{
            ...pos,
            left: 80,
            right: 80,
            top: 1030,
            textAlign: "center",
            fontFamily: "Newsreader",
            fontSize: 92,
            letterSpacing: -3,
            opacity: ease(t, 1.9, 15, 1),
          }}
        >
          OpenTurath AI
        </div>
        <div
          style={{
            ...pos,
            left: 80,
            right: 80,
            top: 1145,
            textAlign: "center",
            fontSize: 29,
            letterSpacing: 0.2,
            color: "#606060",
            opacity: ease(t, 2.3, 14, 1),
          }}
        >
          Khazanah turats, bidang demi bidang.
        </div>
      </div>
      {/* The complete AI directory widens the field of view using actual app cards. */}
      <div
        style={{
          ...pos,
          left: 0,
          right: 0,
          top: 380,
          bottom: 180,
          opacity: show(t, 11.5, 21.7) * 0.22,
          overflow: "hidden",
          pointerEvents: "none",
        }}
      >
        {[-1, 1].map((side) => (
          <div
            key={side}
            style={{
              ...pos,
              left: side < 0 ? -150 : 870,
              top: -220 - (((t - 11.5) * 100) % 1280),
              width: 350,
              transform: `perspective(1200px) rotateY(${side * -18}deg) rotate(${side * 5}deg)`,
            }}
          >
            {rail.map(([name, arab], i) => (
              <div
                key={name}
                style={{
                  marginBottom: 24,
                  transform: `translateX(${12 * Math.sin(t * 0.6 + i)}px)`,
                }}
              >
                <InkCard title={name} arabic={arab} height={220} centered />
              </div>
            ))}
          </div>
        ))}
      </div>
      {captions.map(([a, b, text]) => (
        <Word key={a} t={t} start={a} end={b} text={text} dark={dark} />
      ))}
      {/* Persistent app viewport; native routes and sheets animate inside it. */}
      <div
        style={{
          ...pos,
          left: px,
          top: py,
          width: 420,
          height: 820,
          transform: `translate(-50%,-50%) perspective(1600px) rotateY(${ry}deg) rotateZ(${tilt}deg) scale(${scale})`,
          opacity: phoneVisible,
          transformOrigin: "center",
          borderRadius: 27,
          boxShadow:
            "0 0 0 1px #FFFFFF80,0 0 0 6px #171717,0 26px 80px #00000028",
          background: U.paper,
          overflow: "hidden",
        }}
      >
        <Route t={t} start={3.85} end={11.1}>
          <DashboardScreen scrollY={dashboardScroll} />
        </Route>
        <Route t={t} start={11} end={22.15}>
          <DirectoryScreen scrollY={directoryScroll} />
        </Route>
        <Route t={t} start={22} end={29.55}>
          <TahawwulatScreen />
        </Route>
        <div
          style={{
            ...pos,
            inset: 0,
            opacity: show(t, 25.25, 29.5),
            pointerEvents: "none",
          }}
        >
          <PickerScreen selected={select} progress={modalP} />
        </div>
        <Route t={t} start={29.2} end={30.55}>
          <DirectoryScreen field="fiqh" />
        </Route>
        <Route t={t} start={30.4} end={40.5}>
          <ChatScreen
            typed={typed}
            answerProgress={answer}
            sent={t >= 32.5}
            scrollY={answerScroll}
          />
        </Route>
        <Route t={t} start={40.35} end={46.15}>
          <LibraryScreen scrollY={libraryScroll} />
        </Route>
        <Route t={t} start={46} end={50.95}>
          <ChatScreen
            typed={Q}
            answerProgress={1}
            tabbed
            activeTab={t >= 47.3 && t < 48.6 ? 1 : 0}
            scrollY={t >= 47.3 && t < 48.6 ? 0 : 120}
          />
        </Route>
        <Route t={t} start={50.85} end={51.6}>
          <DashboardScreen scrollY={0} />
        </Route>
        <Route t={t} start={51.4} end={53.75}>
          <NotesScreen saved />
        </Route>
        <Route t={t} start={53.6} end={55.2}>
          <NoteReaderScreen />
        </Route>
        {/* One soft contact marker anchors each visible interaction. */}
        <div
          style={{
            ...pos,
            left: cursorX,
            top: cursorY,
            opacity: clamp(cursorOpacity),
            transform: `scale(${1 - press * 0.16})`,
          }}
        >
          <svg
            width="18"
            height="23"
            viewBox="0 0 28 36"
            style={{ filter: "drop-shadow(1px 2px 2px #0005)" }}
          >
            <path
              d="M2 2v29l7-7 5 10 5-3-5-10h11z"
              fill="#fff"
              stroke="#171717"
              strokeWidth="2.2"
              strokeLinejoin="round"
            />
          </svg>
        </div>
        {clickTimes.map((at) => {
          const p = range(t, at, at + 0.4);
          return p > 0 && p < 1 ? (
            <div
              key={at}
              style={{
                ...pos,
                left: cursorX,
                top: cursorY,
                width: 8 + p * 48,
                height: 8 + p * 48,
                border: "1px solid #606060",
                borderRadius: "50%",
                opacity: (1 - p) * 0.4,
                transform: "translate(-50%,-50%)",
              }}
            />
          ) : null;
        })}
      </div>
      {/* Closing derives from the same app mark, without adding a new brand tagline. */}
      <div
        style={{
          ...pos,
          left: 0,
          right: 0,
          top: 150,
          height: 1000,
          opacity: show(t, 55.3, 70),
          transform: `translateY(${50 * (1 - ease(t, 55.3, 12, 1))}px)`,
        }}
      >
        <PartLogo t={t} ending />
      </div>
      <div
        style={{
          ...pos,
          left: 80,
          right: 80,
          top: 1115,
          textAlign: "center",
          color: "#FAFAFA",
          opacity: final,
          transform: `translateY(${30 * (1 - ease(t, 56.4, 13, 1))}px)`,
        }}
      >
        <div
          style={{ fontFamily: "Newsreader", fontSize: 96, letterSpacing: -3 }}
        >
          OpenTurath AI
        </div>
        <div
          style={{
            height: 1,
            width: 75,
            background: "#71717A",
            margin: "46px auto",
          }}
        />
        <div style={{ fontSize: 39, letterSpacing: 0.3 }}>
          openturath.id <span style={{ marginLeft: 18 }}>↗</span>
        </div>
      </div>
      <div
        style={{
          ...pos,
          left: 87,
          right: 87,
          textAlign: "center",
          bottom: 108,
          fontSize: 21,
          color: dark > 0.5 ? "#B8B8B8" : "#777",
          opacity: show(t, 4.8, 55),
        }}
      >
        Visualisasi antarmuka · contoh percakapan
      </div>
      <div
        style={{
          ...pos,
          left: 87,
          right: 87,
          bottom: 34,
          height: 1,
          background: dark > 0.5 ? "#ffffff18" : "#00000012",
        }}
      >
        <div
          style={{
            height: 1,
            width: `${range(t, 0, 60) * 100}%`,
            background: dark > 0.5 ? "#B8B8B8" : "#606060",
            opacity: 0.4,
          }}
        />
      </div>
    </AbsoluteFill>
  );
};
