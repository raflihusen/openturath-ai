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
import { ThreeCanvas } from "@remotion/three";
import * as THREE from "three";

const WIDTH = 1080;
const HEIGHT = 1920;
const FPS = 30;
const DURATION = 900;
const INK = "#0b0b0c";
const PAPER = "#f3eee5";
const GOLD = "#c99c61";
const OUT = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const EASE = Easing.bezier(0.16, 1, 0.3, 1);

const ease = (frame: number, start: number, end: number) =>
  interpolate(frame, [start, end], [0, 1], { ...OUT, easing: EASE });

const springIn = (frame: number, fps: number, delay = 0) =>
  spring({
    frame: frame - delay,
    fps,
    config: { damping: 22, mass: 0.8, stiffness: 90 },
  });

const font = (
  size: number,
  color = PAPER,
  family = "OTInter",
): CSSProperties => ({
  color,
  fontFamily: family,
  fontSize: size,
  lineHeight: 1.04,
  letterSpacing: family === "OTNewsreader" ? "-0.035em" : "-0.025em",
});

const FONT_FACES = (
  <style>
    {"@font-face{font-family:OTNewsreader;src:url(" +
      staticFile("assets/fonts/Newsreader.ttf") +
      ") format('truetype');font-weight:600;font-display:block}" +
      "@font-face{font-family:OTInter;src:url(" +
      staticFile("assets/fonts/Inter.ttf") +
      ") format('truetype');font-weight:100 900;font-display:block}"}
  </style>
);

const OUTER_ARCH = new THREE.CatmullRomCurve3([
  new THREE.Vector3(-2.25, -2.2, -1.8), new THREE.Vector3(-2.25, 0.45, -1.8),
  new THREE.Vector3(-2.1, 1.15, -1.8), new THREE.Vector3(-1.45, 1.8, -1.8),
  new THREE.Vector3(0, 2.45, -1.8), new THREE.Vector3(1.45, 1.8, -1.8),
  new THREE.Vector3(2.1, 1.15, -1.8), new THREE.Vector3(2.25, 0.45, -1.8),
  new THREE.Vector3(2.25, -2.2, -1.8),
]);
const INNER_ARCH = new THREE.CatmullRomCurve3([
  new THREE.Vector3(-1.7, -2.2, -1.95), new THREE.Vector3(-1.7, 0.35, -1.95),
  new THREE.Vector3(-1.55, 0.95, -1.95), new THREE.Vector3(-1.05, 1.48, -1.95),
  new THREE.Vector3(0, 1.95, -1.95), new THREE.Vector3(1.05, 1.48, -1.95),
  new THREE.Vector3(1.55, 0.95, -1.95), new THREE.Vector3(1.7, 0.35, -1.95),
  new THREE.Vector3(1.7, -2.2, -1.95),
]);

const Dust = () => {
  const frame = useCurrentFrame();
  return (
    <>
      {Array.from({ length: 42 }, (_, index) => {
        const x = Math.sin(index * 12.9898) * 2.2;
        const y = ((index * 73) % 190) / 42 - 2.25;
        const z = -2.6 + ((index * 17) % 25) / 10;
        const size = 0.009 + ((index * 13) % 9) / 1000;
        const drift = Math.sin(frame * 0.021 + index * 1.7);
        const lift = (frame * (0.003 + (index % 4) * 0.0007)) % 4.2;
        return (
          <mesh key={index} position={[x + drift * 0.08, ((y + lift + 2.1) % 4.2) - 2.1, z]}>
            <sphereGeometry args={[size, 8, 8]} />
            <meshBasicMaterial color={index % 3 === 0 ? GOLD : "#e7dfd2"} transparent opacity={0.4 + (index % 4) * 0.1} />
          </mesh>
        );
      })}
    </>
  );
};

const BookModel = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const enter = springIn(frame, fps, 5);
  const frontness = interpolate(frame, [0, 120, 172, 628, 724, 840, 899], [1, 1, 0.29, 0.27, 0.82, 1, 1], OUT);
  const scale = interpolate(enter, [0, 1], [0.34, 0.58]) * frontness;
  const y = interpolate(frame, [0, 120, 172, 628, 724, 899], [-1.2, -1.28, -1.95, -1.95, -1.3, -1.3], { ...OUT, easing: EASE });
  const depth = interpolate(frame, [0, 120, 172, 628, 724, 899], [0, 0, -1.8, -1.8, 0, 0], OUT);
  const turn = interpolate(frame, [0, 24, 66, 100, 140, 172, 360, 520, 680, 740, 840, 899], [-0.8, -0.45, 0.25, 0.6, 0.15, 0.5, -0.25, 0.4, -0.55, 0.3, -0.28, 0.1], { ...OUT, easing: EASE });
  const bob = Math.sin(frame * 0.027) * 0.055;
  const pageOpen = interpolate(frame, [0, 22, 82, 140, 176, 655, 740, 850], [0.25, 0.62, 0.68, 0.68, 0.58, 0.58, 0.68, 0.3], { ...OUT, easing: EASE });

  return (
    <group position={[Math.sin(frame * 0.012) * 0.06, y + bob, depth]} rotation={[0.45 + Math.sin(frame * 0.013) * 0.035, turn, -0.035]} scale={scale}>
      <mesh position={[0, 0, -0.19]}>
        <boxGeometry args={[3.62, 2.48, 0.17]} />
        <meshStandardMaterial color="#49341f" roughness={0.44} metalness={0.36} />
      </mesh>
      <mesh position={[0, 0, -0.085]}>
        <boxGeometry args={[3.48, 2.36, 0.16]} />
        <meshStandardMaterial color="#cbbb9f" roughness={0.86} />
      </mesh>
      <group position={[-0.035, 0, 0.01]} rotation={[0, -pageOpen * 0.65, 0]}>
        <mesh position={[-0.84, 0, 0.025]}>
          <boxGeometry args={[1.67, 2.28, 0.045]} />
          <meshStandardMaterial color="#e4d7c2" roughness={0.78} />
        </mesh>
        {Array.from({ length: 8 }, (_, index) => (
          <mesh key={"l" + index} position={[-0.84, 0.73 - index * 0.19, 0.051]}>
            <boxGeometry args={[index === 0 ? 0.66 : 1.32 - (index % 3) * 0.12, 0.012, 0.006]} />
            <meshStandardMaterial color="#9e8667" transparent opacity={0.42} />
          </mesh>
        ))}
        <mesh position={[-0.84, 0.86, 0.057]}>
          <torusGeometry args={[0.12, 0.008, 6, 36]} />
          <meshStandardMaterial color={GOLD} metalness={0.65} roughness={0.38} />
        </mesh>
      </group>
      <group position={[0.035, 0, 0.01]} rotation={[0, pageOpen * 0.65, 0]}>
        <mesh position={[0.84, 0, 0.025]}>
          <boxGeometry args={[1.67, 2.28, 0.045]} />
          <meshStandardMaterial color="#e4d7c2" roughness={0.78} />
        </mesh>
        {Array.from({ length: 8 }, (_, index) => (
          <mesh key={"r" + index} position={[0.84, 0.73 - index * 0.19, 0.051]}>
            <boxGeometry args={[index === 0 ? 0.66 : 1.32 - (index % 3) * 0.12, 0.012, 0.006]} />
            <meshStandardMaterial color="#9e8667" transparent opacity={0.42} />
          </mesh>
        ))}
        <mesh position={[0.84, 0.86, 0.057]}>
          <torusGeometry args={[0.12, 0.008, 6, 36]} />
          <meshStandardMaterial color={GOLD} metalness={0.65} roughness={0.38} />
        </mesh>
      </group>
      <mesh position={[0, 0, 0.016]}>
        <boxGeometry args={[0.075, 2.25, 0.055]} />
        <meshStandardMaterial color="#b59163" metalness={0.72} roughness={0.32} />
      </mesh>
    </group>
  );
};

const ThreeWorld = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  const canvasOpacity = interpolate(frame, [0, 12, 882, 899], [0, 1, 1, 0], OUT);
  const orbit = frame * 0.0024;

  return (
    <AbsoluteFill style={{ opacity: canvasOpacity, pointerEvents: "none" }}>
      <ThreeCanvas width={width} height={height} camera={{ position: [0, 0, 9], fov: 36 }} gl={{ alpha: true, antialias: true, powerPreference: "high-performance" }} style={{ position: "absolute", inset: 0 }}>
        <ambientLight intensity={0.72} />
        <directionalLight position={[3.5, 4.5, 7]} intensity={2.1} color="#f8ead0" />
        <pointLight position={[-4, -1, 4]} intensity={4.4} color="#bd8950" />
        <pointLight position={[4, 2, -1]} intensity={2.8} color="#877458" />
        <mesh position={[0, 0, -4.5]} rotation={[0.14, Math.sin(frame * 0.005) * 0.12, orbit]}>
          <torusGeometry args={[2.78, 0.008, 6, 180]} />
          <meshBasicMaterial color="#a98559" transparent opacity={0.27} />
        </mesh>
        <mesh position={[0, 0, -4.2]} rotation={[0.24, -0.15, -orbit * 0.66]}>
          <torusGeometry args={[2.34, 0.006, 6, 180]} />
          <meshBasicMaterial color="#e4d7c4" transparent opacity={0.16} />
        </mesh>
        <mesh position={[0, 0, -2.3]}>
          <tubeGeometry args={[OUTER_ARCH, 100, 0.011, 6, false]} />
          <meshBasicMaterial color={GOLD} transparent opacity={0.34} />
        </mesh>
        <mesh position={[0, 0, -2.4]}>
          <tubeGeometry args={[INNER_ARCH, 100, 0.007, 6, false]} />
          <meshBasicMaterial color="#f0e8dc" transparent opacity={0.2} />
        </mesh>
        <Dust />
        <BookModel />
      </ThreeCanvas>
    </AbsoluteFill>
  );
};

const Atmosphere = () => (
  <AbsoluteFill style={{ overflow: "hidden", backgroundColor: INK }}>
    <AbsoluteFill style={{ background: "radial-gradient(ellipse at 50% 46%, rgba(96,68,39,.30) 0%, rgba(30,25,20,.23) 31%, rgba(11,11,12,.90) 78%), linear-gradient(135deg,#141311 0%,#090a0d 52%,#13100d 100%)" }} />
    <AbsoluteFill style={{ opacity: 0.28, background: "linear-gradient(90deg, transparent 49.8%, rgba(214,183,136,.10) 50%, transparent 50.2%)" }} />
    <div style={{ position: "absolute", inset: 76, border: "1px solid rgba(206,178,138,.12)", borderRadius: 4 }} />
    <div style={{ position: "absolute", left: 76, top: 278, width: 928, height: 1, background: "linear-gradient(90deg,rgba(203,166,113,.36),rgba(203,166,113,.02))" }} />
    <div style={{ position: "absolute", left: 76, bottom: 234, width: 928, height: 1, background: "linear-gradient(90deg,rgba(203,166,113,.02),rgba(203,166,113,.30))" }} />
  </AbsoluteFill>
);

const Wordmark = ({ top, centered = false, size = 42 }: { top: number; centered?: boolean; size?: number }) => (
  <div style={{ position: "absolute", top, left: centered ? "50%" : 156, translate: centered ? "-50% 0px" : "0px 0px", ...font(size, PAPER, "OTNewsreader"), fontWeight: 600, whiteSpace: "nowrap" }}>
    OpenTurath
  </div>
);

const BrandGlyph = ({ size = 56, left = 78, top = 150 }: { size?: number; left?: number; top?: number }) => (
  <Img src={staticFile("assets/openturath-mark.svg")} style={{ position: "absolute", left, top, width: size, height: size, objectFit: "contain", filter: "brightness(0) saturate(100%) invert(83%) sepia(29%) saturate(382%) hue-rotate(352deg) brightness(88%) contrast(87%)" }} />
);

const BrandHeader = ({ top = 148 }: { top?: number }) => (
  <>
    <BrandGlyph top={top} />
    <Wordmark top={top + 7} size={41} />
    <div style={{ position: "absolute", left: 160, top: top + 56, ...font(13, "rgba(239,231,218,.50)"), letterSpacing: "0.31em", fontWeight: 600 }}>RUANG KAJIAN DIGITAL</div>
  </>
);

const Eyebrow = ({ children, frame, top = 340 }: { children: ReactNode; frame: number; top?: number }) => {
  const reveal = ease(frame, 0, 18);
  return (
    <div style={{ position: "absolute", left: 78, top, display: "flex", alignItems: "center", gap: 16, opacity: reveal, translate: "0px " + interpolate(reveal, [0, 1], [14, 0]) + "px" }}>
      <div style={{ width: 32, height: 2, backgroundColor: GOLD }} />
      <div style={{ ...font(20, "#d0b58e"), letterSpacing: "0.2em", fontWeight: 600 }}>{children}</div>
    </div>
  );
};

const KineticLines = ({ lines, frame, top, size = 81, left = 78, width = 920 }: { lines: string[]; frame: number; top: number; size?: number; left?: number; width?: number }) => (
  <div style={{ position: "absolute", top, left, width, ...font(size, PAPER, "OTNewsreader"), fontWeight: 600 }}>
    {lines.map((line, index) => {
      const reveal = springIn(frame, FPS, 5 + index * 5);
      const offset = interpolate(reveal, [0, 1], [size * 0.95, 0]);
      return (
        <div key={line + index} style={{ height: size * 1.09, overflow: "hidden" }}>
          <div style={{ opacity: reveal, translate: "0px " + offset + "px", filter: "blur(" + interpolate(reveal, [0, 1], [9, 0]) + "px)" }}>{line}</div>
        </div>
      );
    })}
  </div>
);

const Counter = ({ frame, number, label }: { frame: number; number: string; label: string }) => {
  const reveal = ease(frame, 4, 23);
  return (
    <div style={{ position: "absolute", right: 78, top: 154, display: "flex", alignItems: "center", gap: 13, opacity: reveal }}>
      <span style={{ ...font(15, "rgba(238,229,213,.55)"), letterSpacing: "0.13em" }}>{label}</span>
      <span style={{ ...font(15, GOLD), letterSpacing: "0.1em" }}>{number}</span>
    </div>
  );
};

const SceneFrame = ({ children, duration }: { children: ReactNode; duration: number }) => {
  const frame = useCurrentFrame();
  const enter = ease(frame, 0, 10);
  const leave = interpolate(frame, [duration - 13, duration - 1], [1, 0], { ...OUT, easing: EASE });
  return <AbsoluteFill style={{ opacity: Math.min(enter, leave) }}>{children}</AbsoluteFill>;
};

const Phone = ({ src, frame, top = 500, width = 560, tilt = -1 }: { src: string; frame: number; top?: number; width?: number; tilt?: number }) => {
  const { fps } = useVideoConfig();
  const show = springIn(frame, fps, 4);
  const tiltY = interpolate(frame, [0, 24, 80, 142, 190], [tilt * -5, tilt * 2, 0, tilt * 2, tilt * -4], OUT);
  const tiltX = interpolate(frame, [0, 30, 92, 160, 190], [13, -1.5, 1, -4, 12], { ...OUT, easing: EASE });
  const rotateZ = interpolate(frame, [0, 27, 90, 170, 190], [-5, -0.5, 1.2, -1, 4], OUT);
  const float = Math.sin(frame * 0.055) * 22;
  const scale = interpolate(show, [0, 1], [0.76, 1]);
  const reflection = interpolate(frame, [18, 70, 108], [-125, 0, 125], OUT);

  return (
    <>
      <div style={{ position: "absolute", left: "50%", top: top + 155, width: width * 1.18, height: width * 1.18, borderRadius: "50%", translate: "-50% 0px", background: "radial-gradient(circle,rgba(184,127,66,.16) 0%,rgba(184,127,66,.055) 38%,transparent 70%)", opacity: show }} />
      <div style={{ position: "absolute", left: "50%", top: top + float, width, height: width * (src.includes("assistant") ? 760 / 360 : 801 / 360), padding: 9, boxSizing: "border-box", borderRadius: 62, background: "linear-gradient(135deg,#635742 0%,#232220 24%,#111214 58%,#78654b 100%)", border: "1px solid rgba(219,185,130,.62)", boxShadow: "0 62px 120px rgba(0,0,0,.76), 0 12px 34px rgba(177,127,68,.19), inset 0 0 0 2px rgba(255,245,225,.12)", opacity: show, scale, translate: "-50% 0px", transform: "perspective(1500px) rotateX(" + tiltX + "deg) rotateY(" + tiltY + "deg) rotateZ(" + rotateZ + "deg) translateZ(70px)", transformStyle: "preserve-3d", filter: "blur(" + interpolate(show, [0, 1], [8, 0]) + "px)" }}>
        <div style={{ position: "absolute", inset: 8, borderRadius: 52, overflow: "hidden", backgroundColor: "#09090a", boxShadow: "inset 0 0 0 1px rgba(255,255,255,.15)" }}>
          <Img src={staticFile("assets/" + src)} style={{ width: "100%", height: "100%", objectFit: "cover", objectPosition: "center" }} />
          <div style={{ position: "absolute", inset: -120, background: "linear-gradient(112deg,transparent 43%,rgba(255,246,226,.17) 49%,rgba(255,246,226,.025) 53%,transparent 59%)", translate: reflection + "px 0px", opacity: ease(frame, 14, 31) * (1 - ease(frame, 104, 121)) }} />
        </div>
        <div style={{ position: "absolute", left: 18, top: 14, bottom: 14, width: 2, background: "linear-gradient(180deg,transparent,rgba(249,224,180,.36),transparent)", borderRadius: 2 }} />
      </div>
    </>
  );
};

const ProductScene = ({ duration, number, eyebrow, lines, src, label, top = 506 }: { duration: number; number: string; eyebrow: string; lines: string[]; src: string; label: string; top?: number }) => {
  const frame = useCurrentFrame();
  return (
    <SceneFrame duration={duration}>
      <Counter frame={frame} number={number} label="OPENTURATH" />
      <Eyebrow frame={frame} top={324}>{eyebrow}</Eyebrow>
      <KineticLines frame={frame} top={375} size={74} lines={lines} />
      <Phone src={src} frame={frame} top={top} width={500} tilt={-3} />
      <div style={{ position: "absolute", left: 78, bottom: 126, display: "flex", alignItems: "center", gap: 13, opacity: ease(frame, 30, 48) }}>
        <div style={{ width: 7, height: 7, borderRadius: 9, backgroundColor: GOLD, boxShadow: "0 0 18px rgba(201,156,97,.78)" }} />
        <div style={{ ...font(21, "rgba(244,237,226,.72)"), letterSpacing: "0.015em" }}>{label}</div>
      </div>
      <div style={{ position: "absolute", right: 78, bottom: 126, ...font(14, "rgba(240,230,213,.44)"), letterSpacing: "0.2em", opacity: ease(frame, 36, 55) }}>{number} / 04</div>
    </SceneFrame>
  );
};

const Opening = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const reveal = springIn(frame, fps, 44);
  const flash = interpolate(frame, [32, 39, 54], [0, 0.44, 0], OUT);
  return (
    <SceneFrame duration={126}>
      <BrandHeader top={145} />
      <Counter frame={frame} number="01" label="SEBUAH RUANG UNTUK MENELUSURI ILMU" />
      <Eyebrow frame={frame} top={376}>KITAB · IBARAH · RUJUKAN</Eyebrow>
      <KineticLines frame={frame} top={425} size={88} lines={["Membaca kitab.", "Menelusuri ibarah."]} />
      <div style={{ position: "absolute", left: 78, top: 666, width: 860, height: 1, background: "linear-gradient(90deg,rgba(201,156,97,.62),rgba(201,156,97,.04))", scale: interpolate(frame, [28, 56], [0.1, 1], OUT), transformOrigin: "left" }} />
      <div style={{ position: "absolute", left: 78, top: 704, width: 840, ...font(23, "rgba(238,229,213,.65)"), letterSpacing: "0.015em", opacity: reveal, translate: "0px " + interpolate(reveal, [0, 1], [16, 0]) + "px" }}>
        Ruang digital untuk menelusuri khazanah keilmuan Islam.
      </div>
      <AbsoluteFill style={{ backgroundColor: "#f2d4a4", opacity: flash, mixBlendMode: "screen" }} />
    </SceneFrame>
  );
};

const NotesFeature = ({ frame }: { frame: number }) => {
  const { fps } = useVideoConfig();
  const pop = springIn(frame, fps, 42);
  const rotate = interpolate(pop, [0, 1], [-13, 0]);
  return (
    <div style={{ position: "absolute", right: 53, top: 1310, width: 298, minHeight: 198, padding: "24px 24px 27px", boxSizing: "border-box", borderRadius: 18, background: "linear-gradient(142deg,rgba(247,239,223,.98),rgba(215,201,179,.95))", color: INK, boxShadow: "0 30px 70px rgba(0,0,0,.54),0 1px 0 rgba(255,255,255,.72) inset", transform: "perspective(850px) rotateY(-15deg) rotateZ(" + rotate + "deg) translateZ(110px)", opacity: pop, scale: interpolate(pop, [0, 1], [0.62, 1]) }}>
      <div style={{ ...font(14, "#765632"), letterSpacing: "0.18em", fontWeight: 700 }}>CATATAN</div>
      <div style={{ marginTop: 17, height: 1, backgroundColor: "rgba(72,55,35,.2)" }} />
      <div style={{ marginTop: 17, ...font(23, "#211d18", "OTNewsreader"), fontWeight: 600, lineHeight: 1.14 }}>Jawaban dan kutipan</div>
      <div style={{ marginTop: 8, ...font(15, "#756b5b"), lineHeight: 1.32 }}>Tersimpan untuk dibaca kembali.</div>
      <div style={{ position: "absolute", right: 19, bottom: 21, width: 24, height: 24, border: "1px solid rgba(125,91,53,.48)", borderRadius: "50%", color: "#765632", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 15 }}>↗</div>
    </div>
  );
};

const NotesScene = () => {
  const frame = useCurrentFrame();
  return (
    <SceneFrame duration={178}>
      <Counter frame={frame} number="04" label="JEJAK KAJIAN" />
      <Eyebrow frame={frame} top={324}>CATATAN PRIBADI</Eyebrow>
      <KineticLines frame={frame} top={375} size={74} lines={["Simpan yang penting.", "Lanjutkan kapan saja."]} />
      <Phone src="home.jpg" frame={frame} top={560} width={475} tilt={-2} />
      <div style={{ position: "absolute", left: "57.1%", top: 1514, width: 124, height: 84, border: "2px solid " + GOLD, borderRadius: 23, translate: "-50% 0px", opacity: ease(frame, 41, 56), boxShadow: "0 0 34px rgba(201,156,97,.36),0 0 0 11px rgba(201,156,97,.08)" }} />
      <NotesFeature frame={frame} />
      <div style={{ position: "absolute", left: 78, bottom: 126, ...font(20, "rgba(244,237,226,.70)"), opacity: ease(frame, 48, 64) }}>Simpan jawaban atau kutipan ke Catatan.</div>
    </SceneFrame>
  );
};

const Closing = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const reveal = springIn(frame, fps, 28);
  const line = ease(frame, 45, 78);
  return (
    <SceneFrame duration={254}>
      <Counter frame={frame} number="05" label="OPEN TURATH" />
      <div style={{ position: "absolute", left: "50%", top: 358, width: 158, height: 158, translate: "-50% 0px", borderRadius: "50%", border: "1px solid rgba(203,166,113,.35)", boxShadow: "0 0 80px rgba(201,156,97,.14), inset 0 0 42px rgba(201,156,97,.12)", opacity: reveal, scale: interpolate(reveal, [0, 1], [0.55, 1]) }} />
      <BrandGlyph left={504} top={405} size={70} />
      <div style={{ position: "absolute", top: 565, left: "50%", translate: "-50% 0px", ...font(88, PAPER, "OTNewsreader"), fontWeight: 600, opacity: reveal, scale: interpolate(reveal, [0, 1], [0.82, 1]) }}>OpenTurath</div>
      <div style={{ position: "absolute", top: 716, left: 140, right: 140, textAlign: "center", ...font(30, "rgba(239,231,219,.72)"), letterSpacing: "0.025em", opacity: ease(frame, 46, 75) }}>Membaca kitab, menelusuri ibarah.</div>
      <div style={{ position: "absolute", left: "50%", top: 880, width: 660, height: 1, translate: "-50% 0px", background: "linear-gradient(90deg,transparent,rgba(201,156,97,.72),transparent)", scale: line, transformOrigin: "center" }} />
      <div style={{ position: "absolute", left: "50%", top: 926, width: 606, height: 102, border: "1px solid rgba(224,184,124,.7)", borderRadius: 52, translate: "-50% 0px", display: "flex", alignItems: "center", justifyContent: "center", gap: 22, background: "linear-gradient(110deg,rgba(201,156,97,.20),rgba(201,156,97,.04))", boxShadow: "0 0 42px rgba(201,156,97,.10),inset 0 0 24px rgba(255,255,255,.035)", ...font(27, PAPER), letterSpacing: "0.045em", opacity: reveal, scale: interpolate(reveal, [0, 1], [0.92, 1]) }}>
        JELAJAHI OPENTURATH <span style={{ color: GOLD, fontSize: 32 }}>↗</span>
      </div>
      <div style={{ position: "absolute", left: 154, right: 154, top: 1126, textAlign: "center", ...font(17, "rgba(236,226,211,.50)"), lineHeight: 1.4, opacity: ease(frame, 90, 116) }}>Jawaban AI tetap perlu diperiksa pada kitab yang dirujuk.</div>
      <div style={{ position: "absolute", left: 0, right: 0, bottom: 111, textAlign: "center", ...font(13, "rgba(236,226,211,.42)"), letterSpacing: "0.25em", opacity: ease(frame, 150, 174) }}>ILMU · WARISAN · MANFAAT</div>
    </SceneFrame>
  );
};

const OpenTurathFilm = () => {
  const { fps } = useVideoConfig();
  return (
    <AbsoluteFill style={{ color: PAPER, fontFamily: "OTInter", backgroundColor: INK }}>
      {FONT_FACES}
      <Atmosphere />
      <ThreeWorld />
      <Sequence durationInFrames={126} premountFor={fps}><Opening /></Sequence>
      <Sequence from={112} durationInFrames={196} premountFor={fps}>
        <ProductScene duration={196} number="02" eyebrow="MULAI DARI BIDANG ILMU" lines={["Pilih bidang ilmu", "yang ingin dikaji."]} src="home.jpg" label="Fikih · Hadis · Tafsir · Akidah" top={590} />
      </Sequence>
      <Sequence from={294} durationInFrames={202} premountFor={fps}>
        <ProductScene duration={202} number="03" eyebrow="ASISTEN KAJIAN" lines={["Telusuri pembahasan.", "Temukan rujukan kitab."]} src="assistant.jpg" label="Asisten sesuai bidang kajian" top={590} />
      </Sequence>
      <Sequence from={482} durationInFrames={178} premountFor={fps}><NotesScene /></Sequence>
      <Sequence from={646} durationInFrames={254} premountFor={fps}><Closing /></Sequence>
    </AbsoluteFill>
  );
};

export const MyComposition = () => (
  <Composition id="OpenTurathPromo" component={OpenTurathFilm} durationInFrames={DURATION} fps={FPS} width={WIDTH} height={HEIGHT} />
);
