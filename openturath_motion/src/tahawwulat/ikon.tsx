import React from "react";

// Ikon garis sederhana, digambar dalam SVG. Semua menerima pusat (x, y) dan skala u.

/** Sosok manusia: kepala dan bahu. */
export const Orang: React.FC<{
  x: number;
  y: number;
  u?: number;
  w: string;
  isi?: string;
  o?: number;
  tebal?: number;
}> = ({ x, y, u = 1, w, isi = "none", o = 1, tebal = 3 }) => (
  <g opacity={o}>
    <circle cx={x} cy={y - 34 * u} r={16 * u} fill={isi} stroke={w} strokeWidth={tebal} />
    <path
      d={`M${x - 30 * u} ${y + 20 * u} C${x - 30 * u} ${y - 8 * u} ${x - 16 * u} ${y - 12 * u} ${x} ${y - 12 * u} C${x + 16 * u} ${y - 12 * u} ${x + 30 * u} ${y - 8 * u} ${x + 30 * u} ${y + 20 * u} Z`}
      fill={isi}
      stroke={w}
      strokeWidth={tebal}
      strokeLinejoin="round"
    />
  </g>
);

/** Buku terbuka. */
export const Buku: React.FC<{ x: number; y: number; u?: number; w: string; isi?: string }> = ({
  x,
  y,
  u = 1,
  w,
  isi = "none",
}) => (
  <g stroke={w} strokeWidth={3} fill={isi} strokeLinejoin="round">
    <path d={`M${x} ${y - 18 * u} C${x - 14 * u} ${y - 26 * u} ${x - 34 * u} ${y - 26 * u} ${x - 44 * u} ${y - 20 * u} V${y + 22 * u} C${x - 34 * u} ${y + 16 * u} ${x - 14 * u} ${y + 16 * u} ${x} ${y + 24 * u} Z`} />
    <path d={`M${x} ${y - 18 * u} C${x + 14 * u} ${y - 26 * u} ${x + 34 * u} ${y - 26 * u} ${x + 44 * u} ${y - 20 * u} V${y + 22 * u} C${x + 34 * u} ${y + 16 * u} ${x + 14 * u} ${y + 16 * u} ${x} ${y + 24 * u} Z`} />
  </g>
);

/** Perisai. */
export const perisai = (x: number, y: number, u = 1) =>
  `M${x} ${y - 46 * u} L${x + 38 * u} ${y - 32 * u} V${y} C${x + 38 * u} ${y + 26 * u} ${x + 18 * u} ${y + 40 * u} ${x} ${y + 50 * u} C${x - 18 * u} ${y + 40 * u} ${x - 38 * u} ${y + 26 * u} ${x - 38 * u} ${y} V${y - 32 * u} Z`;

/** Hati. */
export const hati = (x: number, y: number, u = 1) =>
  `M${x} ${y + 34 * u} C${x - 50 * u} ${y} ${x - 46 * u} ${y - 40 * u} ${x - 20 * u} ${y - 40 * u} C${x - 8 * u} ${y - 40 * u} ${x} ${y - 30 * u} ${x} ${y - 22 * u} C${x} ${y - 30 * u} ${x + 8 * u} ${y - 40 * u} ${x + 20 * u} ${y - 40 * u} C${x + 46 * u} ${y - 40 * u} ${x + 50 * u} ${y} ${x} ${y + 34 * u} Z`;

/** Gelembung bicara. */
export const gelembung = (x: number, y: number, l: number, t: number) =>
  `M${x - l / 2 + 16} ${y - t / 2} H${x + l / 2 - 16} Q${x + l / 2} ${y - t / 2} ${x + l / 2} ${y - t / 2 + 16} V${y + t / 2 - 16} Q${x + l / 2} ${y + t / 2} ${x + l / 2 - 16} ${y + t / 2} H${x - l / 2 + 34} L${x - l / 2 + 14} ${y + t / 2 + 16} L${x - l / 2 + 18} ${y + t / 2} H${x - l / 2 + 16} Q${x - l / 2} ${y + t / 2} ${x - l / 2} ${y + t / 2 - 16} V${y - t / 2 + 16} Q${x - l / 2} ${y - t / 2} ${x - l / 2 + 16} ${y - t / 2} Z`;

/** Tanda centang. */
export const centang = (x: number, y: number, u = 1) =>
  `M${x - 14 * u} ${y} L${x - 4 * u} ${y + 10 * u} L${x + 16 * u} ${y - 12 * u}`;

/** Tanda silang. */
export const silang = (x: number, y: number, r: number) =>
  `M${x - r} ${y - r} L${x + r} ${y + r} M${x + r} ${y - r} L${x - r} ${y + r}`;

/** Kubah rumah sederhana. */
export const rumah = (x: number, y: number, u = 1) =>
  `M${x - 40 * u} ${y + 30 * u} V${y - 8 * u} L${x} ${y - 40 * u} L${x + 40 * u} ${y - 8 * u} V${y + 30 * u} Z`;
