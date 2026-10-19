import React from "react";
import { Easing, interpolate, useCurrentFrame } from "remotion";
import { HURUF } from "../../tema";
import naskah from "../naskah2.json";

export type Baris = { nama: string; arab: string; ilmu: string };
export type Kolom = { judul: string; arab: string; isi: string[] };
export type Slide = {
  id: string;
  bab: number;
  judul: string;
  sub?: string;
  arab?: string;
  poin?: string[];
  kiri?: Kolom;
  kanan?: Kolom;
  rukun?: Baris[];
  ibarah?: string;
  kunci?: string;
  sumber?: string;
  durasi: number;
};

export const SLIDES = naskah.slide as Slide[];
export const BAB = naskah.bab;

// Kanvas 4:5 supaya muat di ponsel maupun di kolom baca desktop.
export const LEBAR = 1080;
export const TINGGI = 1350;
export const TEPI = 76;
export const ISI = LEBAR - TEPI * 2;

export type Pal = {
  bg: string;
  surface: string;
  subtle: string;
  ink: string;
  muted: string;
  line: string;
  onInk: string;
  faint: string;
};

export const KERTAS: Pal = {
  bg: "#F6F6F6",
  surface: "#FFFFFF",
  subtle: "#EDEDED",
  ink: "#171717",
  muted: "#5E5E5E",
  line: "#DADADA",
  onInk: "#FFFFFF",
  faint: "#9A9A9A",
};

export const MALAM: Pal = {
  bg: "#161616",
  surface: "#242424",
  subtle: "#313131",
  ink: "#F4F4F4",
  muted: "#B4B4B4",
  line: "#454545",
  onInk: "#171717",
  faint: "#7C7C7C",
};

export const halus = Easing.bezier(0.16, 1, 0.3, 1);
export const lembut = Easing.bezier(0.65, 0, 0.35, 1);

export const p = (f: number, a: number, b: number, ease = halus) =>
  interpolate(f, [a, b], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: ease,
  });

export const mix = (a: number, b: number, t: number) => a + (b - a) * t;

/** Gerak masuk: memudar sambil naik. */
export const Muncul: React.FC<{
  pada: number;
  lama?: number;
  geser?: number;
  style?: React.CSSProperties;
  children: React.ReactNode;
}> = ({ pada, lama = 22, geser = 26, style, children }) => {
  const f = useCurrentFrame();
  const t = p(f, pada, pada + lama);
  return (
    <div style={{ opacity: t, transform: `translateY(${(1 - t) * geser}px)`, ...style }}>
      {children}
    </div>
  );
};

/** Teks Latin; simbol ﷺ memakai fon Arab. */
export const T: React.FC<{ s: string }> = ({ s }) => {
  const bagian = s.split("ﷺ");
  return (
    <>
      {bagian.map((b, i) => (
        <React.Fragment key={i}>
          {b}
          {i < bagian.length - 1 && <span style={{ fontFamily: HURUF.arab }}>ﷺ</span>}
        </React.Fragment>
      ))}
    </>
  );
};

export const arabStyle = (u: number, warna: string, h = 1.85): React.CSSProperties => ({
  fontFamily: HURUF.arab,
  fontSize: u,
  lineHeight: h,
  direction: "rtl",
  textAlign: "right",
  color: warna,
  letterSpacing: 0,
});

/** Pembangkit acak deterministik. */
export const acak = (seed: number) => {
  const x = Math.sin(seed * 9301 + 49297) * 233280;
  return x - Math.floor(x);
};

/** Garis mihrab, seperti logo OpenTurath, dalam kotak 100 x 130. */
export const mihrab = (cx: number, bawah: number, lebar: number) => {
  const s = lebar / 84;
  const x = (v: number) => cx + (v - 50) * s;
  const y = (v: number) => bawah - (130 - v) * s;
  return `M${x(8)} ${y(130)} V${y(62)} C${x(8)} ${y(40)} ${x(22)} ${y(28)} ${x(50)} ${y(10)} C${x(78)} ${y(28)} ${x(92)} ${y(40)} ${x(92)} ${y(62)} V${y(130)}`;
};
