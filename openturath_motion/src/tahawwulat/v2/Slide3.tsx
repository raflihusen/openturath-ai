import React from "react";
import { AbsoluteFill, Img, staticFile, useCurrentFrame } from "remotion";
import { HURUF } from "../../tema";
import {
  ISI,
  LEBAR,
  Muncul,
  SLIDES,
  T,
  TINGGI,
  acak,
  arabStyle,
  lembut,
  mix,
  p,
  type Pal,
} from "./kit";
import { EmpatTiang, Mobil, Orang, Tuas } from "./motif";
import { Ar, Kanvas, Tx, type VisProps } from "./Slide";

const Kanvas2 = Kanvas;

// ── Bab 10 ───────────────────────────────────────────────────────────────

/** Nash penggaris: peristiwa diukur, bukan sebaliknya. */
export const Penggaris: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const ukur = p(f, 40, 110, lembut);
  const salah = p(f, 120, 170);
  return (
    <Kanvas2 h={h}>
      <g opacity={1 - salah * 0.7}>
        <rect x={60} y={40} width={800} height={46} rx={8} fill={c.ink} />
        {Array.from({ length: 41 }).map((_, k) => (
          <line key={k} x1={60 + k * 20} y1={86} x2={60 + k * 20} y2={k % 5 === 0 ? 108 : 98} stroke={c.ink} strokeWidth={2} />
        ))}
        {[0, 1, 2, 3].map((k) => {
          const t = p(f, 20 + k * 12, 40 + k * 12);
          return <rect key={k} x={129 + k * 190} y={mix(40, 150, ukur)} width={120} height={64} rx={12} fill={c.surface} stroke={c.line} strokeWidth={2} opacity={t} />;
        })}
        <Tx x={460} y={250} s="peristiwa ditimbang dengan nash" u={23} w={c.ink} bobot={600} o={ukur} />
      </g>
      <g opacity={salah}>
        <path d={`M200 290 Q460 190 720 290`} stroke={c.muted} strokeWidth={5} fill="none" />
        <Tx x={460} y={h - 20} s="bukan peristiwa yang membengkokkan nash" u={22} w={c.muted} />
      </g>
    </Kanvas2>
  );
};

/** Tanpa nama, tanpa tanggal. */
export const TanpaNama: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const coret = p(f, 70, 110);
  return (
    <Kanvas2 h={h}>
      <g opacity={0.85}>
        {Array.from({ length: 12 }).map((_, k) => (
          <rect key={k} x={70 + (k % 4) * 76} y={40 + Math.floor(k / 4) * 76} width={64} height={64} rx={8} fill="none" stroke={c.line} strokeWidth={2} />
        ))}
        <circle cx={680} cy={110} r={46} fill="none" stroke={c.line} strokeWidth={2} />
        <path d={`M654 84 L706 136 M706 84 L654 136`} stroke={c.muted} strokeWidth={4} opacity={coret} />
        <circle cx={680} cy={110} r={46} fill="none" stroke={c.muted} strokeWidth={4} opacity={coret} />
        <Tx x={190} y={240} s="tanggal" u={22} w={c.muted} bobot={600} />
        <Tx x={680} y={240} s="nama orang" u={22} w={c.muted} bobot={600} />
      </g>
      <g opacity={p(f, 110, 140)}>
        <path d={`M70 320 Q160 260 250 320 T430 320 T610 320 T790 320`} fill="none" stroke={c.ink} strokeWidth={5} />
        <Tx x={460} y={h - 24} s="yang dibaca: pola" u={24} w={c.ink} bobot={600} />
      </g>
    </Kanvas2>
  );
};

/** Dua kotak: yang disembunyikan dan yang diminta. */
export const DuaKotak: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas2 h={h}>
      <rect x={40} y={30} width={380} height={h - 80} rx={20} fill={c.surface} stroke={c.line} strokeWidth={2.5} />
      <rect x={450} y={30} width={380} height={h - 80} rx={20} fill={c.surface} stroke={c.line} strokeWidth={2.5} />
      <rect x={150} y={110} width={160} height={130} rx={10} fill="none" stroke={c.ink} strokeWidth={5} />
      <path d="M230 110 v-30 q0 -40 40 -40 q30 0 30 30" fill="none" stroke={c.ink} strokeWidth={6} />
      <Tx x={230} y={290} s="apa yang dikehendaki untuk kita" u={21} w={c.ink} bobot={600} />
      <Tx x={230} y={318} s="tidak dibuka" u={20} w={c.muted} />
      <rect x={510} y={110} width={260} height={130} rx={10} fill="none" stroke={c.ink} strokeWidth={5} opacity={p(f, 40, 80)} />
      {[0, 1, 2].map((k) => (
        <rect key={k} x={530} y={130 + k * 34} width={210 * p(f, 60 + k * 12, 84 + k * 12)} height={16} rx={8} fill={c.ink} />
      ))}
      <Tx x={640} y={290} s="apa yang diminta dari kita" u={21} w={c.ink} bobot={600} />
      <Tx x={640} y={318} s="dijelaskan" u={20} w={c.muted} />
    </Kanvas2>
  );
};

/** Palu diganti cermin. */
export const Merenung: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const ganti = p(f, 50, 100, lembut);
  return (
    <Kanvas2 h={h}>
      <g opacity={1 - ganti}>
        <rect x={390} y={60} width={140} height={70} rx={12} fill={c.ink} />
        <rect x={440} y={20} width={26} height={120} rx={8} fill={c.muted} />
        <Tx x={460} y={220} s="memvonis" u={24} w={c.muted} />
      </g>
      <g opacity={ganti}>
        <ellipse cx={460} cy={110} rx={90} ry={110} fill={c.surface} stroke={c.ink} strokeWidth={6} transform={`rotate(${(1 - ganti) * -30} 460 110)`} />
        <Tx x={460} y={260} s="mengajak merenung" u={24} w={c.ink} bobot={600} />
      </g>
    </Kanvas2>
  );
};

/** Tergesa vs sabar. */
export const Tergesa: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const sabar = p(f, 60, 120, lembut);
  return (
    <Kanvas2 h={h}>
      <path d="M140 230 Q200 110 300 170 Q260 250 200 230" fill={c.surface} stroke={c.ink} strokeWidth={5} />
      <path d="M330 230 Q390 110 490 170 Q450 250 390 230" fill={c.surface} stroke={c.ink} strokeWidth={5} opacity={0.35} />
      <g opacity={p(f, 10, 40)}>
        <path d={`M${mix(300, 470, sabar)} 60 v60 m-13 -13 l13 15 l13 -15`} stroke={c.ink} strokeWidth={4} fill="none" strokeLinecap="round" />
        <Tx x={mix(300, 470, sabar)} y={40} s="tergesa" u={21} w={c.ink} bobot={600} />
      </g>
      <line x1={200} y1={250} x2={720} y2={250} stroke={c.line} strokeWidth={3} />
      <Tx x={460} y={h - 30} s={sabar > 0.6 ? "menunggu sampai bentuknya jelas" : "tergesa memilih yang mirip"} u={23} w={c.ink} bobot={600} />
    </Kanvas2>
  );
};

// ── Bab 11 ───────────────────────────────────────────────────────────────

/** Dua pegangan: sikap dan sarana. */
export const DuaPegangan: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas2 h={h}>
      {[0, 1].map((k) => (
        <g key={k} opacity={p(f, k * 20, k * 20 + 30)}>
          <rect x={40 + k * 420} y={30} width={380} height={h - 80} rx={20} fill={c.surface} />
          {k === 0 ? (
            <>
              <circle cx={230} cy={150} r={60} fill="none" stroke={c.ink} strokeWidth={4} />
              <line x1={230} y1={150} x2={230} y2={100} stroke={c.ink} strokeWidth={4} />
              <path d="M230 150 L262 172" stroke={c.ink} strokeWidth={4} />
              <Tx x={230} y={250} s="sikap" u={24} w={c.ink} bobot={600} />
            </>
          ) : (
            <>
              <line x1={650} y1={130} x2={650} y2={200} stroke={c.ink} strokeWidth={4} />
              <line x1={560} y1={130} x2={740} y2={130} stroke={c.ink} strokeWidth={4} />
              <rect x={530} y={160} width={70} height={40} rx={6} fill={c.surface} stroke={c.ink} strokeWidth={3} />
              <rect x={700} y={160} width={70} height={40} rx={6} fill={c.ink} />
              <Tx x={650} y={250} s="sarana" u={24} w={c.ink} bobot={600} />
            </>
          )}
        </g>
      ))}
    </Kanvas2>
  );
};

/** Al-Hasan menyerahkan kekuasaan, dua barisan bergabung. */
export const Hasan: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const turun = p(f, 30, 70, lembut);
  const gabung = p(f, 70, 130, lembut);
  const y = h - 60;
  return (
    <Kanvas2 h={h}>
      {[0, 1, 2, 3].map((k) => (
        <Orang key={`a${k}`} x={mix(90 + k * 66, 170 + k * 62, gabung)} y={y} skala={0.78} c={c} />
      ))}
      {[0, 1, 2, 3].map((k) => (
        <Orang key={`b${k}`} x={mix(700 - k * 66, 620 - k * 62, gabung)} y={y} skala={0.78} c={c} />
      ))}
      <g transform={`translate(460 ${mix(70, 190, turun)})`} opacity={1 - gabung * 0.65}>
        <path d="M-46 18 L-46 -18 L-24 0 L0 -28 L24 0 L46 -18 L46 18 Z" fill={c.ink} />
      </g>
      <g opacity={p(f, 120, 150)}>
        <line x1={330} y1={y + 30} x2={590} y2={y + 30} stroke={c.ink} strokeWidth={4} />
        <Tx x={460} y={y + 66} s="satu barisan" u={22} w={c.ink} bobot={600} />
      </g>
    </Kanvas2>
  );
};

/** Sarana baru diuji dalil. */
export const Sarana: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["cetak", "rekaman", "layar", "gawai"];
  return (
    <Kanvas2 h={h}>
      <circle cx={460} cy={60} r={40} fill={c.ink} />
      <Tx x={460} y={60} s="dalil" u={20} w={c.onInk} bobot={600} />
      {nama.map((n, k) => {
        const t = p(f, 20 + k * 18, 50 + k * 18);
        const x = 110 + k * 230;
        const sah = k < 3;
        return (
          <g key={n} opacity={t}>
            <line x1={460} y1={100} x2={x} y2={210} stroke={sah ? c.ink : c.line} strokeWidth={sah ? 3 : 2} strokeDasharray={sah ? "0" : "7 7"} />
            <rect x={x - 60} y={210} width={120} height={80} rx={12} fill={sah ? c.surface : "none"} stroke={sah ? c.ink : c.line} strokeWidth={3} />
            <Tx x={x} y={250} s={n} u={21} w={sah ? c.ink : c.faint} bobot={600} />
            <g opacity={sah ? 1 : 0.45}>
              <path d={sah ? `M${x - 12} 268 L${x - 2} 280 L${x + 18} 254` : `M${x - 12} 258 L${x + 12} 282 M${x + 12} 258 L${x - 12} 282`} stroke={sah ? c.ink : c.faint} strokeWidth={4} fill="none" strokeLinecap="round" />
            </g>
          </g>
        );
      })}
      <Tx x={460} y={h - 24} s="ada dasarnya = boleh; tanpa dasar = tinggalkan" u={22} w={c.muted} />
    </Kanvas2>
  );
};

/** Kaidah keselamatan: lisan dan tangan. */
export const KaidahSelamat: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas2 h={h}>
      {[210, 690].map((x, k) => {
        const t = p(f, 10 + k * 20, 50 + k * 20, lembut);
        return (
          <g key={x}>
            <circle cx={x} cy={h / 2 - 20} r={94} fill="none" stroke={c.ink} strokeWidth={5} pathLength={1} strokeDasharray="1 1" strokeDashoffset={1 - t} transform={`rotate(-90 ${x} ${h / 2 - 20})`} />
            {k === 0 ? (
              <path d={`M${x - 44} ${h / 2 - 20} Q${x} ${h / 2 + 22} ${x + 44} ${h / 2 - 20} Q${x} ${h / 2 - 6} ${x - 44} ${h / 2 - 20} Z`} fill={c.ink} />
            ) : (
              <path d={`M${x - 26} ${h / 2 + 34} V${h / 2 - 6} Q${x - 26} ${h / 2 - 32} ${x - 12} ${h / 2 - 32} V${h / 2 - 2} M${x - 12} ${h / 2 - 32} Q${x} ${h / 2 - 40} ${x + 4} ${h / 2 - 26} V${h / 2 - 2} M${x + 4} ${h / 2 - 30} Q${x + 18} ${h / 2 - 34} ${x + 20} ${h / 2 - 20} V${h / 2 + 34} Z`} fill={c.surface} stroke={c.ink} strokeWidth={3} strokeLinejoin="round" />
            )}
            <path d={`M${x + 62} ${h / 2 - 82} L${x + 74} ${h / 2 - 70} L${x + 96} ${h / 2 - 96}`} stroke={c.ink} strokeWidth={4} fill="none" strokeLinecap="round" opacity={t} />
          </g>
        );
      })}
    </Kanvas2>
  );
};

/** Jalan tengah. */
export const JalanTengah: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const t = p(f, 20, 100, lembut);
  const y = h / 2;
  return (
    <Kanvas2 h={h}>
      <line x1={20} y1={y} x2={ISI - 20} y2={y} stroke={c.line} strokeWidth={3} />
      <rect x={340} y={y - 46} width={240} height={92} rx={46} fill={c.ink} opacity={p(f, 0, 24)} />
      <Ar x={460} y={y} s="النمط الأوسط" u={30} w={c.onInk} />
      <Tx x={90} y={y - 66} s="tertinggal" u={21} w={c.muted} />
      <Tx x={830} y={y - 66} s="berlebihan" u={21} w={c.muted} />
      {Array.from({ length: 5 }).map((_, k) => (
        <circle key={`a${k}`} cx={mix(40 + k * 40, 360 + k * 6, t * (0.7 + k * 0.06))} cy={y + (k - 2) * 16} r={9} fill={c.muted} />
      ))}
      {Array.from({ length: 5 }).map((_, k) => (
        <circle key={`b${k}`} cx={mix(880 - k * 40, 560 - k * 6, t * (0.7 + k * 0.06))} cy={y + (k - 2) * 16} r={9} fill={c.muted} />
      ))}
    </Kanvas2>
  );
};

/** Lingkaran terdekat. */
export const Lingkaran: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const tutup = p(f, 30, 70, lembut);
  return (
    <Kanvas2 h={h}>
      {Array.from({ length: 48 }).map((_, k) => {
        const a = acak(k) * Math.PI * 2 + f / 40;
        const r = 200 + acak(k + 5) * 190;
        const x = 460 + Math.cos(a) * r;
        const y = h / 2 + Math.sin(a) * r * 0.42;
        return <line key={k} x1={x} y1={y} x2={x - 18} y2={y + 6} stroke={c.line} strokeWidth={2.5} />;
      })}
      <circle cx={460} cy={h / 2} r={mix(0, 132, tutup)} fill={c.surface} stroke={c.ink} strokeWidth={4} />
      {[["diri", 0], ["keluarga", 1], ["majelis", 2]].map(([n, k]) => (
        <g key={String(n)} opacity={p(f, 50 + Number(k) * 10, 70 + Number(k) * 10)}>
          <circle cx={460 + (Number(k) - 1) * 84} cy={h / 2 - 34} r={22} fill={c.ink} />
          <Tx x={460 + (Number(k) - 1) * 84} y={h / 2 + 80} s={String(n)} u={19} w={c.ink} bobot={600} />
        </g>
      ))}
    </Kanvas2>
  );
};

/** Cahaya keluar dari lingkaran: tetap berdakwah. */
export const TetapDakwah: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const pancar = p(f, 30, 100, lembut);
  return (
    <Kanvas2 h={h}>
      <circle cx={460} cy={h / 2} r={110} fill={c.surface} stroke={c.ink} strokeWidth={4} />
      <Tx x={460} y={h / 2} s="lingkaran" u={22} w={c.ink} bobot={600} />
      {Array.from({ length: 12 }).map((_, k) => {
        const a = (k / 12) * Math.PI * 2;
        const r = mix(120, 300, pancar);
        return <line key={k} x1={460 + Math.cos(a) * 116} y1={h / 2 + Math.sin(a) * 116} x2={460 + Math.cos(a) * r} y2={h / 2 + Math.sin(a) * r} stroke={c.ink} strokeWidth={3} opacity={0.7} strokeLinecap="round" />;
      })}
    </Kanvas2>
  );
};

/** Sahabat bukan bola. */
export const BukanBola: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const angkat = p(f, 70, 120, lembut);
  return (
    <Kanvas2 h={h}>
      {[0, 1, 2].map((k) => (
        <Orang key={`a${k}`} x={170 + k * 70} y={h - 60} skala={0.85} c={c} />
      ))}
      {[0, 1, 2].map((k) => (
        <Orang key={`b${k}`} x={660 + k * 70} y={h - 60} skala={0.85} c={c} />
      ))}
      <circle cx={460} cy={mix(h - 90, 100, angkat)} r={34} fill={c.ink} opacity={angkat > 0.9 ? 0.35 : 1} />
      <Tx x={460} y={h - 20} s={angkat > 0.6 ? "diangkat dari lapangan" : "diperebutkan"} u={22} w={c.ink} bobot={600} />
    </Kanvas2>
  );
};

// ── Bab 12 ───────────────────────────────────────────────────────────────

/** Tujuh pintu. */
export const TujuhPintu: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["kemiskinan", "kekayaan", "penyakit", "usia tua", "kematian massal", "tipu daya", "kiamat"];
  return (
    <Kanvas2 h={h}>
      {nama.map((n, k) => {
        const t = p(f, k * 10, k * 10 + 24);
        const x = 30 + k * 118;
        return (
          <g key={n} opacity={t}>
            <path d={`M${x} ${h - 40} V110 Q${x + 46} 60 ${x + 92} 110 V${h - 40}`} fill={c.surface} stroke={c.ink} strokeWidth={4} />
            <path d={`M${x} ${h - 40} V110 Q${x + 46} 60 ${x + 92} 110 V${h - 40} Z`} fill={c.ink} opacity={0.06 + (k / 7) * 0.5} />
            <Tx x={x + 46} y={h - 60} s={n.split(" ")[0]} u={17} w={c.ink} bobot={600} />
            {n.split(" ").length > 1 && <Tx x={x + 46} y={h - 40} s={n.split(" ").slice(1).join(" ")} u={16} w={c.muted} />}
          </g>
        );
      })}
    </Kanvas2>
  );
};

/** Tujuh langkah: pintu terbuka, tangan bekerja. */
export const TujuhLangkah: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const tahap = Math.min(6, Math.floor(p(f, 10, 150) * 7));
  const ikon = ["tanam", "beri", "rawat", "baktikan", "damaikan", "ajarkan", "kembali"];
  return (
    <Kanvas2 h={h}>
      <rect x={0} y={0} width={ISI} height={h} rx={20} fill={c.ink} opacity={0.05} />
      <g transform="translate(300 30)">
        <path d={`M0 ${h - 110} V100 Q130 20 260 100 V${h - 110}`} fill={c.surface} stroke={c.ink} strokeWidth={5} />
        <path d={`M0 ${h - 110} V100 Q130 20 260 100 V${h - 110} Z`} fill={c.ink} opacity={0.04 + tahap * 0.07} />
      </g>
      <Tx x={430} y={h / 2 - 20} s={ikon[tahap]} u={30} w={c.ink} bobot={600} />
      <Tx x={460} y={h - 30} s="bekerja sekarang, bukan menunggu" u={22} w={c.muted} />
    </Kanvas2>
  );
};

/** Menanam bibit. */
export const Menanam: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const tumbuh = p(f, 40, 110, lembut);
  const batang = mix(0, 200, tumbuh);
  return (
    <Kanvas2 h={h}>
      <line x1={120} y1={h - 50} x2={800} y2={h - 50} stroke={c.ink} strokeWidth={4} />
      <path d={`M${460 - 80} ${h - 50} Q460 ${h - 82} ${460 + 80} ${h - 50}`} fill={c.subtle} />
      <path d={`M460 ${h - 50} Q470 ${h - 50 - batang / 2} 460 ${h - 50 - batang}`} stroke={c.ink} strokeWidth={7} fill="none" strokeLinecap="round" />
      {Array.from({ length: 7 }).map((_, k) => {
        const a = -Math.PI + (k / 6) * Math.PI;
        const pj = 110 * p(f, 60 + k * 4, 100 + k * 4);
        const tx = 460 + Math.cos(a) * pj;
        const ty = h - 50 - batang - 10 + Math.sin(a) * pj * 0.6 + pj * 0.25;
        return <path key={k} d={`M460 ${h - 50 - batang} Q${(460 + tx) / 2} ${h - 50 - batang - 40} ${tx} ${ty}`} stroke={c.ink} strokeWidth={5} fill="none" strokeLinecap="round" />;
      })}
      <Orang x={250} y={h - 50} skala={0.9} c={c} miring={-6} />
    </Kanvas2>
  );
};

// ── Bab 13 ───────────────────────────────────────────────────────────────

/** Tangga kitab. */
export const Tangga: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["An-Nubdzah", "At-Talid", "Dawa'ir", "Al-Usus"];
  return (
    <Kanvas2 h={h}>
      {nama.map((n, k) => {
        const t = p(f, k * 18, k * 18 + 34, lembut);
        const x = k * 96;
        const y = h - (k + 1) * ((h - 60) / 4);
        const akhir = k === 3;
        return (
          <g key={n} opacity={t} transform={`translate(0 ${(1 - t) * 22})`}>
            <rect x={x} y={y} width={ISI - x} height={(h - 60) / 4 - 12} rx={14} fill={akhir ? c.ink : c.surface} />
            <Tx x={x + 28} y={y + 40} s={`${k + 1}. ${n}`} u={25} w={akhir ? c.onInk : c.ink} bobot={600} a="start" />
          </g>
        );
      })}
    </Kanvas2>
  );
};

/** Rantai guru. */
export const RantaiGuru: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const y = h / 2;
  return (
    <Kanvas2 h={h}>
      <line x1={40} y1={y} x2={ISI - 40} y2={y} stroke={c.line} strokeWidth={4} />
      {Array.from({ length: 6 }).map((_, k) => {
        const t = p(f, k * 14, k * 14 + 28);
        const x = 90 + k * 140;
        return (
          <g key={k} opacity={t}>
            <circle cx={x} cy={y} r={36} fill={c.surface} stroke={c.ink} strokeWidth={4} />
            <rect x={x - 13} y={y - 18} width={26} height={36} rx={4} fill={c.ink} />
          </g>
        );
      })}
      <g opacity={p(f, 100, 130)}>
        <circle cx={ISI - 84} cy={y} r={36} fill={c.ink} />
        <Tx x={ISI - 84} y={y + 58} s="kita" u={20} w={c.ink} bobot={600} />
      </g>
    </Kanvas2>
  );
};

/** Lima AI. */
export const LimaAI: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["Al-Bayan", "Al-Muhaqqiq", "Al-Mukhtabir", "Al-Habib", "Al-Khatib"];
  const gilir = Math.floor(p(f, 30, 140) * 5);
  return (
    <Kanvas2 h={h}>
      {nama.map((n, k) => {
        const x = 90 + k * 184;
        const t = p(f, k * 10, k * 10 + 26);
        const nyala = k === gilir;
        return (
          <g key={n} opacity={t}>
            <path d={`M${x - 60} ${h - 90} V180 Q${x} 100 ${x + 60} 180 V${h - 90} Z`} fill={nyala ? c.ink : c.surface} stroke={c.ink} strokeWidth={3} />
            <Tx x={x} y={h - 40} s={n} u={19} w={c.ink} bobot={600} />
          </g>
        );
      })}
      <rect x={230} y={40} width={460} height={44} rx={22} fill={c.ink} />
      <Tx x={460} y={63} s="satu sumber: kitab dan ceramah beliau" u={20} w={c.onInk} bobot={600} />
    </Kanvas2>
  );
};

// ── Penutup ──────────────────────────────────────────────────────────────

export const Penutup: React.FC<{ c: Pal }> = ({ c }) => {
  const f = useCurrentFrame();
  const s = SLIDES[SLIDES.length - 1];
  return (
    <AbsoluteFill style={{ background: c.bg }}>
      <Kanvas2 h={TINGGI} w={LEBAR}>
        <EmpatTiang x={396} dasar={820} tinggi={330} c={c} naik={[0, 1, 2, 3].map((k) => p(f, 10 + k * 12, 50 + k * 12, lembut))} pucat={[false, false, false, false]} lebar={58} jarak={92} />
        <path d="M330 490 H750" stroke={c.ink} strokeWidth={3} opacity={p(f, 60, 80)} />
        <Mobil x={540} y={560} skala={0.5} c={c} tombol={1} label={false} />
      </Kanvas2>
      <div style={{ position: "absolute", left: 0, right: 0, top: 70, display: "flex", justifyContent: "center", opacity: p(f, 20, 44) }}>
        <Img src={staticFile("logo_putih.png")} style={{ width: 58, height: 58 }} />
      </div>
      <div style={{ position: "absolute", left: 70, right: 70, top: 860, textAlign: "center" }}>
        <div style={{ fontFamily: HURUF.serif, fontSize: 56, lineHeight: 1.16, color: c.ink, opacity: p(f, 80, 110) }}>
          <T s={s.judul} />
        </div>
        <div style={{ fontFamily: HURUF.ui, fontSize: 29, lineHeight: 1.45, color: c.muted, marginTop: 20, opacity: p(f, 105, 130) }}>
          <T s={s.kunci ?? ""} />
        </div>
        <div style={{ ...arabStyle(46, c.ink, 1.4), marginTop: 32, opacity: p(f, 130, 156) }}>{s.arab}</div>
        <div style={{ fontFamily: HURUF.serif, fontStyle: "italic", fontSize: 26, lineHeight: 1.45, color: c.muted, marginTop: 26, opacity: p(f, 155, 180) }}>
          «لا يصنع الإجابات.. وإنما يضع الإنسان أمام مسؤولياته» — Al-Usus, hlm. 106
        </div>
      </div>
    </AbsoluteFill>
  );
};

export const VIS3: Record<string, { Vis?: React.FC<VisProps>; tinggi?: number }> = {
  penggaris: { Vis: Penggaris, tinggi: 330 },
  "tanpa-nama": { Vis: TanpaNama, tinggi: 360 },
  "yang-tersembunyi": { Vis: DuaKotak, tinggi: 300 },
  merenung: { Vis: Merenung, tinggi: 300 },
  "jangan-tergesa": { Vis: Tergesa, tinggi: 260 },
  "dua-pegangan": { Vis: DuaPegangan, tinggi: 300 },
  hasan: { Vis: Hasan, tinggi: 330 },
  sarana: { Vis: Sarana, tinggi: 330 },
  "kaidah-selamat": { Vis: KaidahSelamat, tinggi: 300 },
  "jalan-tengah": { Vis: JalanTengah, tinggi: 260 },
  lingkaran: { Vis: Lingkaran, tinggi: 320 },
  "tetap-dakwah": { Vis: TetapDakwah, tinggi: 320 },
  "bukan-bola": { Vis: BukanBola, tinggi: 320 },
  bersegera: { Vis: TujuhPintu, tinggi: 300 },
  "tujuh-langkah": { Vis: TujuhLangkah, tinggi: 320 },
  menanam: { Vis: Menanam, tinggi: 340 },
  "urutan-kitab": { Vis: Tangga, tinggi: 400 },
  guru: { Vis: RantaiGuru, tinggi: 280 },
  "lima-ai": { Vis: LimaAI, tinggi: 340 },
};

void Muncul;
void Tuas;
void Ar;
void acak;
