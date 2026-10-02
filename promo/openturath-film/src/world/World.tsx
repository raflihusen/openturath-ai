import { useThree } from "@react-three/fiber";
import { useLayoutEffect, useMemo } from "react";
import { useCurrentFrame } from "remotion";
import * as THREE from "three";
import { RoomEnvironment } from "three/examples/jsm/environments/RoomEnvironment.js";
import { SVGLoader } from "three/examples/jsm/loaders/SVGLoader.js";
import { track } from "../anim";
import { LOGO_PATHS } from "../logoPaths";
import { EASE_IN_OUT, mix, p } from "../theme";
import { ROWS } from "../titles";
import {
  BOOK_DEPTH,
  HERO,
  ROW_WIDTH,
  WALL_Z,
  buildHeroTextures,
  buildNoteTexture,
  buildShelfGeometry,
  rowBottom,
} from "./library";

/** Presentation pose of the hero book. */
export const P = new THREE.Vector3(0, -0.62, -5.0);
const SPREAD = new THREE.Vector3(P.x + 0.43, P.y, P.z);

type V3 = [number, number, number];
type Key = [number, V3, V3]; // frame, camera position, camera target

const CAM: Key[] = [
  [0, [-3.3, -0.25, -4.7], [-1.9, -0.55, -8]],
  [115, [-1.25, -0.5, -5.05], [0.25, -0.75, -8]],
  [180, [0, 0.2, 5.3], [0, 0.2, 0]],
  [242, [0, 0.12, 4.5], [0, 0.12, 0]],
  [300, [0.35, -0.72, -4.45], [HERO.x, -0.9, -8]],
  [345, [0.25, -0.76, -4.15], [HERO.x, -0.86, -7.6]],
  [398, [0, -0.48, -2.55], [P.x, P.y, P.z]],
  [432, [0, -0.46, -2.4], [P.x, P.y, P.z]],
  [492, [SPREAD.x, 0.7, -2.8], [SPREAD.x, P.y - 0.05, P.z]],
  [640, [SPREAD.x, 0.6, -3.0], [SPREAD.x, P.y - 0.05, P.z]],
  [700, [0.15, 0.25, -1.55], [0.15, -0.25, -4.6]],
  [772, [0.1, 0.22, -1.25], [0.1, -0.22, -4.6]],
  [845, [0, 0.35, 3.1], [0, 0.35, 0]],
  [900, [0, 0.35, 2.75], [0, 0.35, 0]],
];

const camAt = (f: number) => {
  const pick = (k: 1 | 2, a: 0 | 1 | 2) => track(f, CAM.map((c) => [c[0], c[k][a]] as [number, number]));
  return {
    pos: new THREE.Vector3(pick(1, 0), pick(1, 1), pick(1, 2)),
    tgt: new THREE.Vector3(pick(2, 0), pick(2, 1), pick(2, 2)),
  };
};

// Portrait: lift the camera so the subject sits in the lower two thirds
// (copy lives at the top). Wide: back off so the subject fits the shorter frame.
const LIFT: [number, number][] = [
  [0, 0.12],
  [110, 0.12],
  [180, 0],
  [250, 0],
  [300, 0.22],
  [398, 0.42],
  [432, 0.42],
  [492, 0.32],
  [640, 0.32],
  [700, 0.3],
  [772, 0.3],
  [845, 0],
];
const frame_ = (pos: THREE.Vector3, tgt: THREE.Vector3, f: number, portrait: boolean) => {
  if (portrait) {
    const l = track(f, LIFT);
    pos.y += l;
    tgt.y += l;
  } else {
    const k = track(f, [
      [0, 1.15],
      [180, 1.1],
      [300, 1.3],
      [845, 1.3],
      [900, 1.2],
    ]);
    pos.sub(tgt).multiplyScalar(k).add(tgt);
  }
};

const FOG: [number, number, number][] = [
  // frame, near, far
  [0, 1.5, 7.5],
  [110, 2.5, 9],
  [150, 2.0, 7],
  [180, 4.5, 8.5],
  [242, 4.5, 8.5],
  [275, 3.0, 9],
  [300, 2.5, 10],
  [430, 2.5, 9],
  [640, 2.2, 8],
  [772, 2.0, 7.5],
  [845, 3.2, 6.2],
  [900, 3.2, 6.0],
];

const Rig = ({ portrait }: { portrait: boolean }) => {
  const frame = useCurrentFrame();
  const { camera, scene, size, gl } = useThree();
  useLayoutEffect(() => {
    const cam = camera as THREE.PerspectiveCamera;
    const { pos, tgt } = camAt(frame);
    frame_(pos, tgt, frame, portrait);
    // slow handheld-like breathing, very small
    pos.x += Math.sin(frame / 47) * 0.012;
    pos.y += Math.sin(frame / 61) * 0.01;
    cam.position.copy(pos);
    cam.lookAt(tgt);
    cam.fov = portrait ? 46 : 32;
    cam.near = 0.05;
    cam.far = 60;
    if (!portrait) {
      // put the subject on the right third, text lives on the left
      cam.setViewOffset(size.width * 1.42, size.height, 0, 0, size.width, size.height);
    } else cam.clearViewOffset();
    cam.updateProjectionMatrix();
    const fog = scene.fog as THREE.Fog;
    fog.near = track(frame, FOG.map((k) => [k[0], k[1]] as [number, number]));
    fog.far = track(frame, FOG.map((k) => [k[0], k[2]] as [number, number]));
    gl.toneMappingExposure = 1.0;
  }, [frame, camera, scene, size, portrait, gl]);
  return null;
};

const Lights = ({ portrait }: { portrait: boolean }) => {
  const frame = useCurrentFrame();
  const { pos, tgt } = camAt(frame);
  frame_(pos, tgt, frame, portrait);
  const spot = useMemo(() => new THREE.SpotLight("#fff7ec", 0, 22, 0.55, 0.65, 1.4), []);
  const hookSweep = Math.sin(p(frame, 0, 120) * Math.PI);
  const spotPos = pos.clone().add(new THREE.Vector3(-1.4, 2.6, 0.8));
  spot.position.copy(spotPos);
  spot.target.position.copy(tgt);
  spot.target.updateMatrixWorld();
  spot.intensity = 38 * (0.35 + 0.65 * p(frame, 0, 40)) + 10 * hookSweep;
  return (
    <>
      <ambientLight intensity={0.16} />
      <hemisphereLight args={["#ffffff", "#101010", 0.28]} />
      <primitive object={spot} />
      <primitive object={spot.target} />
      <directionalLight position={[3, 4, 6]} intensity={0.55} color="#f2f2f2" />
      <directionalLight position={[-4, 1, -2]} intensity={0.35} color="#dcdcdc" />
    </>
  );
};

const Shelves = () => {
  const { geometry, texture } = useMemo(() => buildShelfGeometry(), []);
  const bookMat = useMemo(
    () => new THREE.MeshStandardMaterial({ map: texture, roughness: 0.78, metalness: 0.0 }),
    [texture],
  );
  const wood = useMemo(
    () => new THREE.MeshStandardMaterial({ color: "#1b1b1b", roughness: 0.7, metalness: 0.05 }),
    [],
  );
  const width = Math.max(...ROW_WIDTH) + 0.5;
  return (
    <group>
      <mesh geometry={geometry} material={bookMat} />
      {Array.from({ length: ROWS }).map((_, r) => (
        <mesh key={r} material={wood} position={[0, rowBottom(r) - 0.035, WALL_Z - BOOK_DEPTH / 2 + 0.03]}>
          <boxGeometry args={[width, 0.07, BOOK_DEPTH + 0.12]} />
        </mesh>
      ))}
      {[-1, 1].map((s) => (
        <mesh key={s} material={wood} position={[(s * width) / 2, -0.05, WALL_Z - BOOK_DEPTH / 2]}>
          <boxGeometry args={[0.08, ROWS * 1.7 + 0.2, BOOK_DEPTH + 0.14]} />
        </mesh>
      ))}
      <mesh position={[0, 0, WALL_Z - BOOK_DEPTH - 0.02]}>
        <planeGeometry args={[width + 2, ROWS * 1.7 + 2]} />
        <meshStandardMaterial color="#0f0f0f" roughness={1} />
      </mesh>
    </group>
  );
};

const HeroBook = () => {
  const frame = useCurrentFrame();
  const tex = useMemo(() => buildHeroTextures(), []);
  const mats = useMemo(() => {
    const cloth = new THREE.MeshStandardMaterial({ color: HERO.shade.bg, roughness: 0.62, metalness: 0.05 });
    const paper = new THREE.MeshStandardMaterial({ color: "#d9d6cf", roughness: 0.95 });
    const page = new THREE.MeshStandardMaterial({ map: tex.page, roughness: 0.9 });
    const cover = new THREE.MeshStandardMaterial({ map: tex.cover, roughness: 0.55, metalness: 0.08 });
    const spine = new THREE.MeshStandardMaterial({ map: tex.spine, roughness: 0.6 });
    return { cloth, paper, page, cover, spine };
  }, [tex]);

  const w = HERO.w;
  const h = HERO.h;
  const D = BOOK_DEPTH;
  const t = 0.014; // board thickness

  const out = p(frame, 300, 338);
  const fly = p(frame, 334, 396, EASE_IN_OUT);
  const open = p(frame, 438, 492, EASE_IN_OUT);
  const shelfPos = new THREE.Vector3(HERO.x, HERO.y, HERO.z + out * 0.95);
  const pos = shelfPos.clone().lerp(P, fly);
  pos.y += Math.sin(fly * Math.PI) * 0.18;
  const ry = mix(0, Math.PI / 2, fly);
  const rz = Math.sin(fly * Math.PI) * 0.12;
  const rx = mix(0, -0.12, open);
  const coverAngle = open * Math.PI * 0.985;

  // page line #10 of the generated page texture (see buildHeroTextures)
  const pageH = Math.round((1024 * h) / D);
  const hlY = h / 2 - ((150 + 46 * 10 + 6) / pageH) * h;
  const zRight = -D / 2 + (914 / 1024) * (D - 0.03);
  const hlLen = 0.78 * (D - 0.03);
  const hl = p(frame, 556, 600, EASE_IN_OUT);
  const hlZ = zRight - (hl * hlLen) / 2;

  // board materials: [+x, -x, +y, -y, +z, -z]
  const frontBoard = [mats.page, mats.cover, mats.cloth, mats.cloth, mats.cloth, mats.cloth];
  const blockMats = [mats.paper, mats.page, mats.paper, mats.paper, mats.paper, mats.paper];

  return (
    <group position={pos} rotation={[rx, ry, rz]}>
      {/* page block */}
      <mesh material={blockMats} position={[0, 0, -0.005]}>
        <boxGeometry args={[w - 2 * t - 0.01, h - 0.03, D - 0.03]} />
      </mesh>
      {/* back board (+x) */}
      <mesh material={mats.cloth} position={[w / 2 - t / 2, 0, 0]}>
        <boxGeometry args={[t, h, D]} />
      </mesh>
      {/* spine (+z) */}
      <mesh position={[0, 0, D / 2 + 0.002]}>
        <planeGeometry args={[w, h]} />
        <primitive object={mats.spine} attach="material" />
      </mesh>
      {/* reading mark: sweeps right-to-left along one line of the left page */}
      <mesh
        position={[-(w - 2 * t - 0.01) / 2 - 0.0015, hlY, hlZ]}
        rotation={[0, -Math.PI / 2, 0]}
        visible={hl > 0.001}
      >
        <planeGeometry args={[Math.max(hl * hlLen, 0.0001), 0.03]} />
        <meshBasicMaterial color="#171717" transparent opacity={0.16} depthWrite={false} />
      </mesh>
      {/* front board, hinged at the spine (-x, +z) */}
      <group position={[-w / 2 + t / 2, 0, D / 2]} rotation={[0, coverAngle, 0]}>
        <mesh material={frontBoard} position={[0, 0, -D / 2]}>
          <boxGeometry args={[t, h, D]} />
        </mesh>
      </group>
    </group>
  );
};

const Notes = () => {
  const frame = useCurrentFrame();
  const texes = useMemo(() => [buildNoteTexture(true), buildNoteTexture(false), buildNoteTexture(false)], []);
  const start = new THREE.Vector3(SPREAD.x - 0.2, P.y + 0.05, P.z + 0.15);
  return (
    <group>
      {[2, 1, 0].map((k) => {
        const a = 640 + k * 9;
        const s = p(frame, a, a + 40, EASE_IN_OUT);
        const visible = frame >= a - 1;
        const end = new THREE.Vector3(-0.32 + k * 0.1, -0.05 - k * 0.07, -3.75 - k * 0.12);
        const pos = start.clone().lerp(end, s);
        pos.y += Math.sin(s * Math.PI) * 0.35;
        const rx = mix(-Math.PI / 2 + 0.25, -0.12, s);
        const rz = mix(0, 0.05 - k * 0.06, s);
        return (
          <mesh key={k} visible={visible} position={pos} rotation={[rx, 0.12 * (1 - s), rz]} scale={mix(0.5, 1, s)}>
            <planeGeometry args={[0.6, 0.8]} />
            <meshStandardMaterial map={texes[k]} roughness={0.85} side={THREE.DoubleSide} />
          </mesh>
        );
      })}
    </group>
  );
};

const logoGeometry = () => {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">${LOGO_PATHS.map(
    (d) => `<path d="${d}"/>`,
  ).join("")}</svg>`;
  const data = new SVGLoader().parse(svg);
  const geos: THREE.ExtrudeGeometry[] = [];
  for (const path of data.paths) {
    for (const shape of SVGLoader.createShapes(path)) {
      geos.push(
        new THREE.ExtrudeGeometry(shape, {
          depth: 46,
          bevelEnabled: true,
          bevelThickness: 7,
          bevelSize: 4,
          bevelSegments: 4,
          curveSegments: 10,
        }),
      );
    }
  }
  return geos;
};

const Logo = ({ portrait }: { portrait: boolean }) => {
  const frame = useCurrentFrame();
  const geos = useMemo(() => logoGeometry(), []);
  const mat = useMemo(
    () =>
      new THREE.MeshPhysicalMaterial({
        color: "#e9e9e7",
        metalness: 0.55,
        roughness: 0.26,
        clearcoat: 0.6,
        clearcoatRoughness: 0.2,
        transparent: true,
      }),
    [],
  );
  // brand entrance, fly-through exit, closing return
  const inA = p(frame, 160, 215, EASE_IN_OUT);
  const outA = p(frame, 246, 272);
  const inB = p(frame, 792, 850, EASE_IN_OUT);
  const brandPhase = frame < 500;
  const opacity = brandPhase ? inA * (1 - outA) : inB;
  mat.opacity = opacity;
  mat.depthWrite = opacity > 0.98;
  const wob = Math.sin(frame / 40) * 0.02;
  const ry = brandPhase ? mix(-1.05, 0, inA) + outA * 0.25 + wob : mix(0.9, 0, inB) + wob;
  const y = brandPhase ? mix(-0.2, portrait ? 0.62 : 0.3, inA) : portrait ? mix(0.75, 0.86, inB) : mix(0.2, 0.35, inB);
  const size = brandPhase ? 1.3 * mix(0.85, 1, inA) * (1 + outA * 0.6) : (portrait ? 0.62 : 0.66) * mix(0.88, 1, inB);
  const s = size / 1024;
  return (
    <group visible={opacity > 0.002} position={[0, y, 0]} rotation={[0, ry, 0]}>
      <group scale={[s, -s, s]} position={[-512 * s, 512 * s, -23 * s]}>
        {geos.map((g, i) => (
          <mesh key={i} geometry={g} material={mat} />
        ))}
      </group>
    </group>
  );
};

const Env = () => {
  const { gl, scene } = useThree();
  useLayoutEffect(() => {
    const pm = new THREE.PMREMGenerator(gl);
    const env = pm.fromScene(new RoomEnvironment(), 0.04).texture;
    scene.environment = env;
    scene.environmentIntensity = 0.32;
    scene.background = new THREE.Color("#0b0b0b");
    scene.fog = new THREE.Fog("#0b0b0b", 2, 9);
    return () => {
      env.dispose();
      pm.dispose();
    };
  }, [gl, scene]);
  return null;
};

export const World = ({ portrait }: { portrait: boolean }) => (
  <>
    <Env />
    <Rig portrait={portrait} />
    <Lights portrait={portrait} />
    <Shelves />
    <HeroBook />
    <Notes />
    <Logo portrait={portrait} />
  </>
);
