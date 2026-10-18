import React from "react";
import { Easing, interpolate, useCurrentFrame } from "remotion";
import { HURUF } from "../tema";
import naskah from "./naskah.json";

// ── Data ────────────────────────────────────────────────────────────────

export type Baris = { nama: string; arab: string; ilmu: string };
export type Kolom = { judul: string; arab: string; isi: string[] };
export type Slide = {
  id: string;
  bab: number;
  judul: string;
  sub?: string;
  arab?: string;
  nama?: string;
  poin?: string[];
  kiri?: Kolom;
  kanan?: Kolom;
  rukun?: Baris[];
  ibarah?: string;
  makna?: string;
  kunci?: string;
  sumber?: string;
  durasi: number;
};

export const SLIDES = naskah.slide as Slide[];
export const BAB = naskah.bab;

// ── Kanvas dan warna ────────────────────────────────────────────────────
// 4:5 portrait: muat utuh di ponsel dan di kolom baca desktop.
export const LEBAR = 1080;
export const TINGGI = 1350;
export const TEPI = 80;
export const ISI = LEBAR - TEPI * 2;

/** Tinta dan kertas OpenTurath (DESIGN.md §2). Tanpa warna aksen. */
export type Pal = {
  bg: string;
  surface: string;
  subtle: string;
  ink: string;
  muted: string;
  faint: string;
  line: string;
  onInk: string;
};

export const TERANG: Pal = {
  bg: "#F6F6F6",
  surface: "#FFFFFF",
  subtle: "#EDEDED",
  ink: "#171717",
  muted: "#606060",
  faint: "#9A9A9A",
  line: "#DADADA",
  onInk: "#FFFFFF",
};

export const GELAP: Pal = {
  bg: "#151515",
  surface: "#292929",
  subtle: "#353535",
  ink: "#F5F5F5",
  muted: "#B8B8B8",
  faint: "#7A7A7A",
  line: "#454545",
  onInk: "#171717",
};

// ── Gerak ───────────────────────────────────────────────────────────────

export const halus = Easing.bezier(0.16, 1, 0.3, 1);
export const lembut = Easing.bezier(0.65, 0, 0.35, 1);

/** Kemajuan 0..1 antara bingkai a dan b. */
export const p = (f: number, a: number, b: number, ease = halus) =>
  interpolate(f, [a, b], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: ease,
  });

export const mix = (a: number, b: number, t: number) => a + (b - a) * t;

/** Muncul: memudar sambil naik sedikit. */
export const Muncul: React.FC<{
  pada: number;
  geser?: number;
  lama?: number;
  style?: React.CSSProperties;
  children: React.ReactNode;
}> = ({ pada, geser = 24, lama = 20, style, children }) => {
  const f = useCurrentFrame();
  const t = p(f, pada, pada + lama);
  return (
    <div
      style={{
        opacity: t,
        transform: `translateY(${(1 - t) * geser}px)`,
        ...style,
      }}
    >
      {children}
    </div>
  );
};

// ── Huruf ───────────────────────────────────────────────────────────────

/** Teks Latin; simbol ﷺ memakai fon Arab agar tidak jatuh ke fon sistem. */
export const T: React.FC<{ s: string }> = ({ s }) => {
  const bagian = s.split("ﷺ");
  return (
    <>
      {bagian.map((b, i) => (
        <React.Fragment key={i}>
          {b}
          {i < bagian.length - 1 && (
            <span style={{ fontFamily: HURUF.arab }}>ﷺ</span>
          )}
        </React.Fragment>
      ))}
    </>
  );
};

export const gayaArab = (ukuran: number, warna: string): React.CSSProperties => ({
  fontFamily: HURUF.arab,
  fontSize: ukuran,
  lineHeight: 1.85,
  direction: "rtl",
  color: warna,
  letterSpacing: 0,
});

// ── Komponen SVG kecil ─────────────────────────────────────────────────

/** Garis yang tergambar sepanjang jalurnya. */
export const Jalur: React.FC<{
  d: string;
  t: number;
  warna: string;
  tebal?: number;
  isi?: string;
  putus?: boolean;
}> = ({ d, t, warna, tebal = 3, isi = "none", putus }) => (
  <path
    d={d}
    fill={isi}
    stroke={warna}
    strokeWidth={tebal}
    strokeLinecap="round"
    strokeLinejoin="round"
    pathLength={1}
    strokeDasharray={putus ? "0.02 0.02" : "1 1"}
    strokeDashoffset={putus ? 0 : 1 - t}
    opacity={putus ? t : 1}
  />
);

/** Teks SVG Latin. */
export const Tx: React.FC<{
  x: number;
  y: number;
  s: string;
  u?: number;
  w?: string;
  bobot?: number;
  a?: "start" | "middle" | "end";
  o?: number;
  serif?: boolean;
}> = ({ x, y, s, u = 26, w = "#000", bobot = 400, a = "middle", o = 1, serif }) => (
  <text
    x={x}
    y={y}
    fontFamily={serif ? HURUF.serif : HURUF.ui}
    fontSize={u}
    fontWeight={bobot}
    fill={w}
    textAnchor={a}
    opacity={o}
    dominantBaseline="middle"
  >
    {s}
  </text>
);

/** Teks SVG Arab. `a` bersifat visual: "end" = tepi kanan, "start" = tepi kiri. */
export const Ar: React.FC<{
  x: number;
  y: number;
  s: string;
  u?: number;
  w?: string;
  a?: "start" | "middle" | "end";
  o?: number;
}> = ({ x, y, s, u = 34, w = "#000", a = "middle", o = 1 }) => (
  <text
    x={x}
    y={y}
    fontFamily={HURUF.arab}
    fontSize={u}
    fill={w}
    textAnchor={a === "end" ? "start" : a === "start" ? "end" : "middle"}
    direction="rtl"
    opacity={o}
    dominantBaseline="middle"
  >
    {s}
  </text>
);

/** Lengkung mihrab (logo OpenTurath) berpusat di cx, kaki di y bawah. */
export const mihrab = (cx: number, bawah: number, lebar: number) => {
  const s = lebar / 84;
  const x = (v: number) => cx + (v - 50) * s;
  const y = (v: number) => bawah - (130 - v) * s;
  return `M${x(8)} ${y(130)} V${y(62)} C${x(8)} ${y(40)} ${x(22)} ${y(28)} ${x(50)} ${y(10)} C${x(78)} ${y(28)} ${x(92)} ${y(40)} ${x(92)} ${y(62)} V${y(130)}`;
};

/** Pembangkit acak deterministik untuk tata letak partikel. */
export const acak = (seed: number) => {
  const x = Math.sin(seed * 9301 + 49297) * 233280;
  return x - Math.floor(x);
};
