import React, { useMemo } from 'react';
import {
  AbsoluteFill,
  Audio,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import { ThreeCanvas } from '@remotion/three';
import * as THREE from 'three';

const clamp = { extrapolateLeft: 'clamp' as const, extrapolateRight: 'clamp' as const };

const ThreeStage: React.FC<{ t: number }> = ({ t }) => {
  const dotPositions = useMemo(() => {
    const pts: number[] = [];
    for (let ring = 1; ring <= 18; ring++) {
      const r = ring * 0.24;
      const count = Math.max(8, Math.round((2 * Math.PI * r) / 0.22));
      for (let i = 0; i < count; i++) {
        const a = (i / count) * Math.PI * 2;
        pts.push(Math.cos(a) * r, Math.sin(a) * r, 0);
      }
    }
    return new Float32Array(pts);
  }, []);

  const lightPhase =
    (t >= 2.0 && t < 10.5) ||
    (t >= 19.5 && t < 23.5 && Math.floor((t - 19.5) / 0.5) % 2 === 1);

  const showDesktop = t >= 10.5 && t < 19.5;
  const showPhone = t >= 16.0 && t < 19.5;
  const showEmblem = t >= 23.5;

  const desktopRotY =
    t < 16.0 ? interpolate(t, [10.5, 16.0], [-0.32, 0.24], clamp) : 0.28;
  const desktopPosX = t < 16.0 ? 0 : interpolate(t, [16.0, 17.1], [0, -1.05], clamp);
  const desktopPosZ = t < 16.0 ? 0 : interpolate(t, [16.0, 17.1], [0, -1.2], clamp);

  const phonePosY = interpolate(t, [16.0, 17.1], [-2.2, 0.15], clamp);
  const phoneRotY = interpolate(t, [16.0, 19.5], [-0.36, -0.16], clamp);

  const emblemRotY = interpolate(t, [23.5, 26.0], [-1.8, 0], clamp);
  const emblemPosY = interpolate(t, [25.0, 26.4], [0, 1.05], clamp);

  return (
    <>
      <color attach="background" args={[lightPhase ? '#f6f6f7' : '#09090b']} />
      <ambientLight intensity={0.5} />
      <directionalLight position={[4, 6, 7]} intensity={2.2} />
      <directionalLight position={[-5, 3, -4]} intensity={1.3} color="#dbeafe" />

      <points position={[0, 0, -1.6]} rotation={[0, 0, t * 0.14]}>
        <bufferGeometry>
          <bufferAttribute
            attach="attributes-position"
            count={dotPositions.length / 3}
            array={dotPositions}
            itemSize={3}
          />
        </bufferGeometry>
        <pointsMaterial
          color={lightPhase ? '#16161a' : '#f4f4f6'}
          size={0.032}
          transparent
          opacity={t >= 4.5 && t < 6.5 ? 0.52 : 0.24}
        />
      </points>

      {showDesktop && (
        <group position={[desktopPosX, 0.5, desktopPosZ]} rotation={[0.06, desktopRotY, 0]}>
          <mesh>
            <boxGeometry args={[3.55, 2.38, 0.1]} />
            <meshStandardMaterial color="#1e1e24" metalness={0.85} roughness={0.25} />
          </mesh>
        </group>
      )}

      {showPhone && (
        <group position={[0.75, phonePosY, 1.1]} rotation={[0.06, phoneRotY, -0.02]}>
          <mesh>
            <boxGeometry args={[1.52, 3.08, 0.11]} />
            <meshStandardMaterial color="#1c1c22" metalness={0.85} roughness={0.22} />
          </mesh>
        </group>
      )}

      {showEmblem && (
        <group position={[0, emblemPosY, 0.5]} rotation={[0.12 * Math.max(0, 1 - (t - 23.5) / 2.2), emblemRotY, 0]}>
          <mesh>
            <boxGeometry args={[1.55, 1.55, 0.24]} />
            <meshStandardMaterial color="#16161b" metalness={0.78} roughness={0.22} />
          </mesh>
          <mesh position={[0, 0, 0.135]}>
            <torusGeometry args={[0.48, 0.035, 16, 48]} />
            <meshStandardMaterial color="#f4f4f6" metalness={0.9} roughness={0.15} />
          </mesh>
        </group>
      )}
    </>
  );
};

export const OpenTurathPromo3D: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();
  const t = frame / fps;

  const beat1 = Math.min(3, Math.floor(t / 0.5));
  const hookLines = ['5.300+', 'kitab turats.', 'Satu pertanyaan.', 'Ibarah asli.'];

  const montageBeat = Math.min(7, Math.max(0, Math.floor((t - 19.5) / 0.5)));
  const montageDark = montageBeat % 2 === 0;
  const montageItems: [string, string][] = [
    ['18 AI', 'SPESIALIS BIDANG ILMU'],
    ['4 Mazhab Fikih.', "AI Fikih Syafi'i · Hanafi · Maliki · Hanbali"],
    ['AI Hadits.', "AI Tafsir Al-Qur'an"],
    ['AI Ushul Fikih.', 'Qawaid Fikih · Maqashid · Tarjih'],
    ['AI Bahasa Arab.', 'النحو · الصرف · البلاغة · المعاجم'],
    ['AI Fikih Tahawwulat.', '5 AI Terpadu · Manhaj Habib Abu Bakar'],
    ['28.000+', 'JILID KITAB RUJUKAN'],
    ['ID · EN · AR', 'Tiga bahasa. Satu rujukan.'],
  ];

  const cardSpring = spring({ frame: Math.max(0, frame - 6.5 * fps), fps, config: { damping: 16, stiffness: 120 } });

  return (
    <AbsoluteFill style={{ backgroundColor: '#09090b', fontFamily: 'Outfit, sans-serif' }}>
      <Audio src={staticFile('promopro/kinetic_120bpm.wav')} loop />

      <ThreeCanvas width={width} height={height} camera={{ position: [0, 0, 8.2], fov: 38 }}>
        <ThreeStage t={t} />
      </ThreeCanvas>

      <AbsoluteFill
        style={{
          justifyContent: 'center',
          alignItems: 'center',
          textAlign: 'center',
          padding: 64,
        }}
      >
        {t < 2.0 && (
          <div style={{ fontFamily: 'Newsreader, serif', fontSize: 132, fontWeight: 600, color: '#fafafa', letterSpacing: -3 }}>
            {hookLines[beat1]}
          </div>
        )}

        {t >= 6.5 && t < 10.5 && (
          <div
            style={{
              width: '92%',
              backgroundColor: '#ffffff',
              color: '#121216',
              borderRadius: 40,
              padding: 48,
              textAlign: 'left',
              transform: `scale(${interpolate(cardSpring, [0, 1], [0.92, 1])})`,
              boxShadow: '0 24px 60px rgba(0,0,0,0.09)',
            }}
          >
            <div style={{ display: 'inline-block', backgroundColor: '#141418', color: '#fafafa', padding: '10px 24px', borderRadius: 999, fontSize: 22, fontWeight: 600 }}>
              AI Fikih Syafi&apos;i · Rujukan Asli
            </div>
            <div style={{ margin: '28px 0', padding: 28, backgroundColor: '#f5f5f7', borderRadius: 24, borderRight: '6px solid #141418', textAlign: 'right', direction: 'rtl', fontSize: 44, lineHeight: 1.6 }}>
              «يُشْتَرَطُ لِلْقُدْوَةِ نِيَّةُ الِاقْتِدَاءِ، وَمُتَابَعَةُ الْإِمَامِ فِي الْأَفْعَالِ»
            </div>
            <div style={{ fontFamily: 'Newsreader, serif', fontSize: 36, lineHeight: 1.4 }}>
              Makmum wajib berniat mengikuti imam sejak takbiratul ihram dan menyelaraskan gerakan shalat.
            </div>
            <div style={{ marginTop: 28, display: 'inline-block', backgroundColor: '#141418', color: '#fafafa', padding: '14px 28px', borderRadius: 999, fontSize: 24, fontWeight: 600 }}>
              Minhāj al-Ṭālibīn · Juz 1, hlm. 42
            </div>
          </div>
        )}

        {t >= 10.5 && t < 19.5 && (
          <div style={{ position: 'absolute', bottom: 220, left: 64, right: 64, textAlign: 'center', color: '#fafafa' }}>
            <div style={{ fontFamily: 'Newsreader, serif', fontSize: 64, fontWeight: 600, letterSpacing: -1.4 }}>
              {t < 13.0 ? 'Multi-tab komparasi.' : t < 16.0 ? 'AI Fikih Tahawwulat.' : 'Satu ruang. Semua perangkat.'}
            </div>
            <div style={{ marginTop: 14, fontSize: 28, color: 'rgba(255,255,255,0.66)' }}>
              {t < 13.0
                ? 'Bandingkan hingga 5 AI spesialis sekaligus.'
                : t < 16.0
                  ? 'Lima sistem AI terpadu · Manhaj Habib Abu Bakar.'
                  : 'Android · macOS · Windows · Sinkronisasi catatan'}
            </div>
          </div>
        )}

        {t >= 19.5 && t < 23.5 && (
          <div>
            <div style={{ fontFamily: 'Newsreader, serif', fontSize: 132, fontWeight: 600, letterSpacing: -3, color: montageDark ? '#fafafa' : '#121216' }}>
              {montageItems[montageBeat][0]}
            </div>
            <div style={{ marginTop: 20, fontSize: 32, letterSpacing: 4, color: montageDark ? 'rgba(255,255,255,0.62)' : 'rgba(18,18,22,0.55)' }}>
              {montageItems[montageBeat][1]}
            </div>
          </div>
        )}

        {t >= 25.6 && (
          <div style={{ position: 'absolute', bottom: 240, left: 64, right: 64, textAlign: 'center', color: '#fafafa' }}>
            <div style={{ fontFamily: 'Newsreader, serif', fontSize: 110, fontWeight: 600, letterSpacing: -2.5 }}>
              OpenTurath AI
            </div>
            <div style={{ marginTop: 18, fontFamily: 'Newsreader, serif', fontSize: 40, color: 'rgba(255,255,255,0.74)' }}>
              Menjaga warisan, membuka cakrawala.
            </div>
            <div style={{ marginTop: 42, fontSize: 28, color: 'rgba(255,255,255,0.56)' }}>
              Android · macOS · Windows
            </div>
            <div style={{ marginTop: 28, display: 'inline-block', backgroundColor: '#fafafa', color: '#09090b', padding: '16px 46px', borderRadius: 999, fontSize: 28, fontWeight: 600 }}>
              openturath.id
            </div>
          </div>
        )}
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
