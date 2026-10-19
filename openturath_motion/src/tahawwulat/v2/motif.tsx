import React from "react";
import { useCurrentFrame } from "remotion";
import { HURUF } from "../../tema";
import { Muncul, acak, halus, mix, p, type Pal } from "./kit";

// ── Lima motif visual yang dipakai berulang di seluruh pengantar ──────────

/** Mobil 4WD: diperkenalkan bab 1, dipakai lagi di bab 9 dan penutup. */
export const Mobil: React.FC<{
  x: number;
  y: number;
  skala?: number;
  c: Pal;
  miring?: number;
  tombol?: number; // 0 = redup, 1 = menyala
  label?: boolean;
}> = ({ x, y, skala = 1, c, miring = 0, tombol = 0, label = true }) => {
  const f = useCurrentFrame();
  const s = skala;
  return (
    <g transform={`translate(${x} ${y}) rotate(${miring}) scale(${s})`}>
      <path
        d="M-96 18 L-88 -14 L-38 -22 L-14 -54 L44 -54 L66 -22 L92 -14 L96 18 Z"
        fill={c.ink}
        stroke={c.ink}
        strokeWidth={4}
        strokeLinejoin="round"
      />
      <path d="M-30 -22 L-12 -46 L20 -46 L38 -22 Z" fill={c.bg} opacity={0.85} />
      <path d="M44 -22 L58 -12 L34 -12 Z" fill={c.bg} opacity={0.55} />
      {[-58, 58].map((wx) => (
        <g key={wx}>
          <circle cx={wx} cy={22} r={24} fill={c.surface} stroke={c.ink} strokeWidth={4} />
          <circle cx={wx} cy={22} r={8} fill={c.ink} />
          <line
            x1={wx - 14}
            y1={22}
            x2={wx + 14}
            y2={22}
            stroke={c.ink}
            strokeWidth={2.5}
            transform={`rotate(${f * 6} ${wx} 22)`}
          />
        </g>
      ))}
      {label && (
        <g transform="translate(0 -78)">
          <rect x={-46} y={-20} width={92} height={36} rx={10} fill={c.surface} stroke={c.line} strokeWidth={2} />
          <text
            x={0}
            y={-2}
            fontFamily={HURUF.ui}
            fontSize={19}
            fontWeight={600}
            fill={tombol > 0.5 ? c.ink : c.faint}
            textAnchor="middle"
            dominantBaseline="middle"
          >
            4WD
          </text>
          <circle cx={62} cy={-2} r={9} fill={tombol > 0.5 ? c.ink : c.line} />
        </g>
      )}
    </g>
  );
};

/** Empat tiang: muncul di sampul, tiang keempat pucat sampai penutup. */
export const EmpatTiang: React.FC<{
  x: number;
  dasar: number;
  tinggi: number;
  c: Pal;
  naik: number[]; // 0..1 per tiang
  pucat?: boolean[];
  lebar?: number;
  jarak?: number;
}> = ({ x, dasar, tinggi, c, naik, pucat = [], lebar = 54, jarak = 96 }) => (
  <g>
    {[0, 1, 2, 3].map((k) => {
      const h = tinggi * naik[k];
      const cx = x + k * jarak;
      return (
        <g key={k} opacity={pucat[k] ? 0.32 : 1}>
          <rect x={cx - lebar / 2} y={dasar - h} width={lebar} height={h} rx={6} fill={pucat[k] ? c.surface : c.ink} stroke={pucat[k] ? c.line : c.ink} strokeWidth={2.5} />
        </g>
      );
    })}
  </g>
);

/** Dua tuas kendali: ilmu dan kuasa. */
export const Tuas: React.FC<{
  x: number;
  y: number;
  c: Pal;
  tarik: number; // 0..1
  label: [string, string];
  aktif?: boolean;
  skala?: number;
}> = ({ x, y, c, tarik, label, aktif = true, skala = 1 }) => {
  const s = skala;
  return (
    <g transform={`translate(${x} ${y}) scale(${s})`}>
      <rect x={-84} y={-18} width={168} height={36} rx={18} fill={c.surface} stroke={c.line} strokeWidth={2} />
      <rect x={-84} y={-18} width={168 * 0.5} height={36} rx={18} fill={c.ink} opacity={aktif ? 0.9 : 0.15} />
      <circle cx={mix(-56, 56, tarik)} cy={0} r={13} fill={aktif ? c.ink : c.faint} stroke={c.bg} strokeWidth={3} />
      <text x={0} y={44} fontFamily={HURUF.ui} fontSize={21} fontWeight={600} fill={aktif ? c.ink : c.muted} textAnchor="middle">
        {label[0]}
      </text>
      <text x={0} y={70} fontFamily={HURUF.arab} fontSize={24} fill={aktif ? c.muted : c.faint} textAnchor="middle">
        {label[1]}
      </text>
    </g>
  );
};

/** Garis waktu bertirai: ujung "kiamat" tertutup. */
export const GarisWaktu: React.FC<{
  x: number;
  y: number;
  lebar: number;
  c: Pal;
  tirai: number; // 0..1 posisi tirai
  titik?: { pos: number; kecil?: boolean }[];
  tampilTitik?: number;
}> = ({ x, y, lebar, c, tirai, titik = [], tampilTitik = 99 }) => (
  <g>
    <line x1={x} y1={y} x2={x + lebar} y2={y} stroke={c.ink} strokeWidth={3} />
    <line x1={x + lebar * tirai} y1={y - 46} x2={x + lebar * tirai} y2={y + 46} stroke={c.muted} strokeWidth={2} strokeDasharray="6 7" />
    {titik.slice(0, tampilTitik).map((t, k) => (
      <circle
        key={k}
        cx={x + lebar * t.pos}
        cy={y}
        r={t.kecil ? 7 : 11}
        fill={c.ink}
        stroke={c.bg}
        strokeWidth={3}
      />
    ))}
  </g>
);

/** Wadah: isi yang jernih dan wadah yang membawa tapi tidak tulus. */
export const Wadah: React.FC<{
  x: number;
  dasar: number;
  c: Pal;
  isi: number;
  retak?: boolean;
  terang?: boolean;
  lebar?: number;
  tinggi?: number;
}> = ({ x, dasar, c, isi, retak = false, terang = false, lebar = 130, tinggi = 190 }) => {
  const f = useCurrentFrame();
  const l = lebar;
  const y0 = dasar - tinggi;
  const body = `M${x - l / 2} ${y0} C${x - l / 2 - 12} ${y0 + tinggi * 0.5} ${x - l / 2 + 14} ${dasar} ${x - l / 4} ${dasar} H${x + l / 4} C${x + l / 2 - 14} ${dasar} ${x + l / 2 + 12} ${y0 + tinggi * 0.5} ${x + l / 2} ${y0}`;
  return (
    <g>
      <defs>
        <clipPath id={`w-${x}-${dasar}`}>
          <path d={`${body} Z`} />
        </clipPath>
      </defs>
      <g clipPath={`url(#w-${x}-${dasar})`}>
        <rect x={x - l} y={dasar - tinggi * isi} width={l * 2} height={tinggi * isi + 10} fill={terang ? c.ink : c.faint} opacity={0.85} />
      </g>
      <path d={body} fill="none" stroke={c.ink} strokeWidth={5} />
      {retak && (
        <>
          <path
            d={`M${x + 26} ${dasar - 40} L${x + 12} ${dasar - 74} L${x + 32} ${dasar - 96}`}
            stroke={c.bg}
            strokeWidth={9}
            fill="none"
          />
          {[0, 1, 2].map((k) => {
            const jatuh = ((f / 1.6 + k * 18) % 54) / 54;
            return (
              <circle key={k} cx={x + 22} cy={dasar - 34 + jatuh * 70} r={6} fill={c.ink} opacity={1 - jatuh} />
            );
          })}
        </>
      )}
    </g>
  );
};

/** Bayangan latar zaman: unta, kereta, gedung, ponsel. */
export const Zaman: React.FC<{ x: number; y: number; skala: number; c: Pal; jenis: number }> = ({
  x,
  y,
  skala,
  c,
  jenis,
}) => {
  const s = skala;
  const warna = c.subtle;
  const g = (isi: React.ReactNode) => (
    <g transform={`translate(${x} ${y}) scale(${s})`} fill={warna} stroke={c.line} strokeWidth={2}>
      {isi}
    </g>
  );
  switch (jenis % 4) {
    case 0: // unta
      return g(
        <>
          <path d="M-60 -10 Q-50 -44 -30 -26 Q-14 -48 2 -24 Q22 -40 30 -12 L30 -6 H-60 Z" />
          <rect x={-56} y={-10} width={80} height={8} rx={4} />
          <circle cx={34} cy={-30} r={9} />
        </>,
      );
    case 1: // kereta
      return g(
        <>
          <rect x={-44} y={-56} width={64} height={44} rx={6} />
          <rect x={20} y={-34} width={34} height={24} rx={4} />
          <circle cx={-26} cy={-6} r={12} />
          <circle cx={22} cy={-6} r={12} />
        </>,
      );
    case 2: // gedung
      return g(
        <>
          <rect x={-48} y={-70} width={34} height={64} />
          <rect x={-8} y={-96} width={30} height={90} />
          <rect x={28} y={-54} width={28} height={48} />
        </>,
      );
    default: // ponsel
      return g(
        <>
          <rect x={-26} y={-66} width={52} height={72} rx={10} />
          <rect x={-16} y={-54} width={32} height={44} rx={3} fill={c.surface} />
        </>,
      );
  }
};

/** Orang menunduk — dipakai di 0.2 dan dibalik di 12.3. */
export const Orang: React.FC<{
  x: number;
  y: number;
  skala?: number;
  c: Pal;
  miring?: number;
}> = ({ x, y, skala = 1, c, miring = 0 }) => (
  <g transform={`translate(${x} ${y}) rotate(${miring}) scale(${skala})`}>
    <circle cx={0} cy={-72} r={22} fill="none" stroke={c.ink} strokeWidth={5} />
    <path d="M-34 0 C-34 -42 -16 -50 0 -50 C16 -50 34 -42 34 0 Z" fill={c.surface} stroke={c.ink} strokeWidth={5} strokeLinejoin="round" />
  </g>
);

export { Muncul, p, mix, halus, acak };
