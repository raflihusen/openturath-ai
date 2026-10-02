import type { CSSProperties, ReactNode } from "react";
import {
  AbsoluteFill,
  Composition,
  Easing,
  Img,
  Sequence,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

const WIDTH = 1080;
const HEIGHT = 1920;
const FPS = 30;
const DURATION = 900;
const PAPER = "#eeece5";
const INK = "#171716";
const MUTED = "#77746d";
const RULE = "#c9c4b9";
const ACCENT = "#a87742";
const OUT = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const EASE = Easing.bezier(0.22, 1, 0.36, 1);

const progress = (frame: number, start: number, end: number) =>
  interpolate(frame, [start, end], [0, 1], {
    ...OUT,
    easing: EASE,
  });

const arrive = (frame: number, fps: number, delay = 0) =>
  spring({
    frame: frame - delay,
    fps,
    config: { damping: 200, mass: 0.9, stiffness: 105 },
  });

const textStyle = (
  fontSize: number,
  color = INK,
  family = "OTInter",
): CSSProperties => ({
  color,
  fontFamily: family,
  fontSize,
  lineHeight: 1.12,
  letterSpacing: family === "OTNewsreader" ? "-0.025em" : "-0.015em",
});

const SmallLabel = ({ children }: { children: ReactNode }) => (
  <div
    style={{
      ...textStyle(23, MUTED),
      letterSpacing: "0.16em",
      fontWeight: 600,
      textTransform: "uppercase",
    }}
  >
    {children}
  </div>
);

const FilmBackground = () => {
  const frame = useCurrentFrame();
  const drift = interpolate(frame, [0, DURATION], [-36, 36], OUT);

  return (
    <AbsoluteFill style={{ overflow: "hidden", backgroundColor: PAPER }}>
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(ellipse at 50% 38%, #f8f6f0 0%, #f0eee8 58%, #e7e3da 100%)",
        }}
      />
      <svg
        aria-hidden="true"
        width={WIDTH}
        height={HEIGHT}
        viewBox={`0 0 ${WIDTH} ${HEIGHT}`}
        style={{ position: "absolute", inset: 0, opacity: 0.52 }}
      >
        <path
          d="M 110 1810 L 110 700 C 110 390 310 195 540 195 C 770 195 970 390 970 700 L 970 1810"
          fill="none"
          stroke={RULE}
          strokeWidth="1.5"
        />
        <path
          d="M 176 1810 L 176 748 C 176 478 336 310 540 310 C 744 310 904 478 904 748 L 904 1810"
          fill="none"
          stroke={RULE}
          strokeWidth="1"
          opacity="0.68"
        />
        <path d="M 84 254 L 996 254" stroke={RULE} strokeWidth="1" />
        <path d="M 84 1666 L 996 1666" stroke={RULE} strokeWidth="1" opacity="0.62" />
      </svg>
      <div
        style={{
          position: "absolute",
          left: 86,
          top: 254,
          width: 1,
          height: 1,
          backgroundColor: ACCENT,
          boxShadow: `0 0 0 4px ${PAPER}, 0 0 0 5px ${ACCENT}`,
          translate: `${Math.round(drift)}px 0px`,
          opacity: 0.65,
        }}
      />
    </AbsoluteFill>
  );
};

const FontFaces = () => (
  <style>{
    "@font-face{font-family:OTNewsreader;src:url(" +
    staticFile("assets/fonts/Newsreader.ttf") +
    ") format('truetype');font-weight:600;font-display:block}" +
    "@font-face{font-family:OTInter;src:url(" +
    staticFile("assets/fonts/Inter.ttf") +
    ") format('truetype');font-weight:100 900;font-display:block}"
  }</style>
);

const SceneFrame = ({
  children,
  duration,
}: {
  children: ReactNode;
  duration: number;
}) => {
  const frame = useCurrentFrame();
  const fadeIn = progress(frame, 0, 18);
  const fadeOut = interpolate(
    frame,
    [duration - 18, duration - 1],
    [1, 0],
    { ...OUT, easing: EASE },
  );

  return (
    <AbsoluteFill style={{ opacity: Math.min(fadeIn, fadeOut) }}>
      {children}
    </AbsoluteFill>
  );
};

const BrandMark = ({
  width,
  top,
  frame,
  fps,
}: {
  width: number;
  top: number;
  frame: number;
  fps: number;
}) => {
  const reveal = arrive(frame, fps, 7);
  const scale = interpolate(reveal, [0, 1], [0.91, 1]);

  return (
    <Img
      src={staticFile("assets/openturath-mark.svg")}
      style={{
        position: "absolute",
        left: "50%",
        top,
        width,
        height: width,
        objectFit: "contain",
        opacity: progress(frame, 0, 30),
        scale,
        translate: "-50% 0px",
      }}
    />
  );
};

const Wordmark = ({
  top,
  size,
  frame,
  align = "center",
}: {
  top: number;
  size: number;
  frame: number;
  align?: "center" | "left";
}) => {
  const reveal = arrive(frame, FPS, 22);
  const y = interpolate(reveal, [0, 1], [22, 0]);
  return (
    <div
      style={{
        position: "absolute",
        top,
        left: align === "center" ? "50%" : 84,
        width: align === "center" ? "100%" : 900,
        textAlign: align,
        ...textStyle(size, INK, "OTNewsreader"),
        fontWeight: 600,
        opacity: reveal,
        translate: (align === "center" ? "-50% " : "0px ") + y + "px",
      }}
    >
      OpenTurath
    </div>
  );
};

const Title = ({
  children,
  top,
  frame,
  size = 70,
  width = 900,
}: {
  children: ReactNode;
  top: number;
  frame: number;
  size?: number;
  width?: number;
}) => {
  const reveal = arrive(frame, FPS, 4);
  const y = interpolate(reveal, [0, 1], [32, 0]);
  return (
    <div
      style={{
        position: "absolute",
        top,
        left: 84,
        width,
        ...textStyle(size, INK, "OTNewsreader"),
        fontWeight: 600,
        opacity: reveal,
        translate: "0px " + y + "px",
      }}
    >
      {children}
    </div>
  );
};

const Rule = ({
  top,
  frame,
  width = 910,
}: {
  top: number;
  frame: number;
  width?: number;
}) => (
  <div
    style={{
      position: "absolute",
      top,
      left: 84,
      width: width * progress(frame, 8, 32),
      height: 1,
      backgroundColor: RULE,
      opacity: 0.9,
    }}
  />
);

const PhoneScreen = ({
  src,
  top,
  width,
  duration,
  focus = 1,
}: {
  src: string;
  top: number;
  width: number;
  duration: number;
  focus?: number;
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const show = arrive(frame, fps, 9);
  const y = interpolate(show, [0, 1], [104, 0]);
  const scale = interpolate(frame, [20, duration], [0.985, 1.025], OUT);
  const height = width * (src.includes("assistant") ? 760 / 360 : 801 / 360);

  return (
    <div
      style={{
        position: "absolute",
        left: "50%",
        top,
        width,
        height,
        overflow: "hidden",
        borderRadius: 54,
        backgroundColor: "#111110",
        border: "7px solid #292825",
        boxShadow:
          "0 54px 130px rgba(30, 26, 18, 0.24), 0 10px 28px rgba(30, 26, 18, 0.12)",
        opacity: show,
        scale,
        translate: "-50% " + y + "px",
      }}
    >
      <Img
        src={staticFile("assets/" + src)}
        style={{
          width: "100%",
          height: "100%",
          objectFit: "cover",
          objectPosition: "center",
          borderRadius: 47,
          opacity: focus,
        }}
      />
    </div>
  );
};

const SceneLabel = ({
  children,
  frame,
  top = 106,
}: {
  children: ReactNode;
  frame: number;
  top?: number;
}) => {
  const show = progress(frame, 4, 24);
  return (
    <div
      style={{
        position: "absolute",
        top,
        left: 84,
        display: "flex",
        alignItems: "center",
        gap: 18,
        opacity: show,
      }}
    >
      <div style={{ width: 34, height: 2, backgroundColor: ACCENT }} />
      <SmallLabel>{children}</SmallLabel>
    </div>
  );
};

const Opening = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const tagline = arrive(frame, fps, 42);

  return (
    <SceneFrame duration={126}>
      <SceneLabel frame={frame} top={300}>RUANG KAJIAN DIGITAL</SceneLabel>
      <BrandMark width={390} top={405} frame={frame} fps={fps} />
      <Wordmark top={810} size={112} frame={frame} />
      <Rule top={960} frame={frame} width={370} />
      <div
        style={{
          position: "absolute",
          top: 1030,
          left: 100,
          right: 100,
          textAlign: "center",
          ...textStyle(67, INK, "OTNewsreader"),
          fontWeight: 600,
          opacity: tagline,
          translate:
            "0px " + interpolate(tagline, [0, 1], [25, 0]) + "px",
        }}
      >
        Membaca kitab, menelusuri ibarah.
      </div>
      <div
        style={{
          position: "absolute",
          top: 1170,
          left: 180,
          right: 180,
          textAlign: "center",
          ...textStyle(29, MUTED),
          opacity: progress(frame, 58, 82),
        }}
      >
        Temukan pembahasan dan rujukan kitab.
      </div>
    </SceneFrame>
  );
};

const HomeScene = () => {
  const frame = useCurrentFrame();
  return (
    <SceneFrame duration={198}>
      <SceneLabel frame={frame}>MULAI DARI BIDANG ILMU</SceneLabel>
      <Title top={168} frame={frame} size={68}>
        Pilih bidang ilmu
        <br />
        yang ingin dikaji.
      </Title>
      <Rule top={345} frame={frame} />
      <PhoneScreen src="home.jpg" top={424} width={622} duration={198} />
      <div
        style={{
          position: "absolute",
          right: 85,
          bottom: 74,
          ...textStyle(24, MUTED),
          letterSpacing: "0.12em",
          opacity: progress(frame, 22, 44),
        }}
      >
        BERANDA / 01
      </div>
    </SceneFrame>
  );
};

const AssistantScene = () => {
  const frame = useCurrentFrame();
  return (
    <SceneFrame duration={216}>
      <SceneLabel frame={frame}>TELUSURI DENGAN BANTUAN AI</SceneLabel>
      <Title top={168} frame={frame} size={66}>
        Cari pembahasan
        <br />
        dan rujukan kitab.
      </Title>
      <Rule top={345} frame={frame} />
      <PhoneScreen
        src="assistant.jpg"
        top={424}
        width={622}
        duration={216}
      />
      <div
        style={{
          position: "absolute",
          left: 84,
          bottom: 73,
          ...textStyle(26, MUTED),
          opacity: progress(frame, 36, 60),
        }}
      >
        Pilih asisten sesuai bidang yang dipelajari.
      </div>
    </SceneFrame>
  );
};

const NotesScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const pulse = progress(frame, 72, 92);
  const ringScale = interpolate(arrive(frame, fps, 46), [0, 1], [0.76, 1]);

  return (
    <SceneFrame duration={198}>
      <SceneLabel frame={frame}>CATATAN</SceneLabel>
      <Title top={168} frame={frame} size={66}>
        Simpan untuk
        <br />
        dibaca kembali.
      </Title>
      <Rule top={345} frame={frame} />
      <PhoneScreen src="home.jpg" top={424} width={610} duration={198} />
      <div
        style={{
          position: "absolute",
          left: "57.1%",
          top: 1628,
          width: 146,
          height: 96,
          border: "2px solid " + ACCENT,
          borderRadius: 30,
          opacity: pulse * 0.92,
          scale: ringScale,
          translate: "-50% 0px",
          boxShadow: "0 0 0 12px rgba(168, 119, 66, 0.08)",
        }}
      />
      <div
        style={{
          position: "absolute",
          left: 84,
          bottom: 78,
          ...textStyle(25, MUTED),
          opacity: progress(frame, 36, 58),
        }}
      >
        Simpan jawaban atau kutipan ke Catatan.
      </div>
    </SceneFrame>
  );
};

const Closing = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const reveal = arrive(frame, fps, 10);

  return (
    <SceneFrame duration={234}>
      <SceneLabel frame={frame} top={300}>OPENTURATH</SceneLabel>
      <BrandMark width={300} top={405} frame={frame} fps={fps} />
      <Wordmark top={745} size={104} frame={frame} />
      <div
        style={{
          position: "absolute",
          top: 908,
          left: 130,
          right: 130,
          textAlign: "center",
          ...textStyle(62, INK, "OTNewsreader"),
          fontWeight: 600,
          opacity: reveal,
        }}
      >
        Membaca kitab,
        <br />
        menelusuri ibarah.
      </div>
      <div
        style={{
          position: "absolute",
          left: "50%",
          top: 1180,
          width: 620,
          height: 102,
          borderRadius: 51,
          backgroundColor: INK,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          gap: 22,
          color: PAPER,
          ...textStyle(31, PAPER),
          letterSpacing: "0.015em",
          opacity: reveal,
          scale: interpolate(reveal, [0, 1], [0.96, 1]),
          translate: "-50% 0px",
        }}
      >
        Jelajahi OpenTurath
        <span style={{ fontSize: 34, color: "#d5b28a" }}>↗</span>
      </div>
      <Rule top={1395} frame={frame} width={450} />
      <div
        style={{
          position: "absolute",
          top: 1452,
          left: 150,
          right: 150,
          textAlign: "center",
          ...textStyle(26, MUTED),
          lineHeight: 1.35,
          opacity: progress(frame, 80, 105),
        }}
      >
        Jawaban AI perlu diperiksa pada kitab yang dirujuk.
      </div>
      <div
        style={{
          position: "absolute",
          bottom: 86,
          left: 0,
          right: 0,
          textAlign: "center",
          ...textStyle(22, MUTED),
          letterSpacing: "0.16em",
          opacity: progress(frame, 135, 160),
        }}
      >
        OPEN TURATH / RUANG KAJIAN DIGITAL
      </div>
    </SceneFrame>
  );
};

const OpenTurathFilm = () => {
  const { fps } = useVideoConfig();

  return (
    <AbsoluteFill style={{ color: INK, fontFamily: "OTInter" }}>
      <FontFaces />
      <FilmBackground />
      <Sequence from={0} durationInFrames={126} premountFor={fps}>
        <Opening />
      </Sequence>
      <Sequence from={108} durationInFrames={198} premountFor={fps}>
        <HomeScene />
      </Sequence>
      <Sequence from={288} durationInFrames={216} premountFor={fps}>
        <AssistantScene />
      </Sequence>
      <Sequence from={486} durationInFrames={198} premountFor={fps}>
        <NotesScene />
      </Sequence>
      <Sequence from={666} durationInFrames={234} premountFor={fps}>
        <Closing />
      </Sequence>
    </AbsoluteFill>
  );
};

export const MyComposition = () => (
  <Composition
    id="OpenTurathPromo"
    component={OpenTurathFilm}
    durationInFrames={DURATION}
    fps={FPS}
    width={WIDTH}
    height={HEIGHT}
  />
);
