import React, { useEffect, useState } from "react";
import { AbsoluteFill, cancelRender, continueRender, delayRender, staticFile, useCurrentFrame } from "remotion";
import { loadFont } from "@remotion/fonts";
import TL from "./timeline.json";
import { bump, chan, clamp, Key, mix, step } from "./pegas";

export const PROMO_FPS = 240;
export const PROMO_FRAMES = 3360; // 14 detik, 28 beat pada 120 BPM
const BEAT = 60 / TL.bpm;
const bt = (b: number) => b * BEAT;
const M = TL.morphs;

const CANVAS = "#EDEDE9";
const INK = "#111111";
const WHITE = "#FFFFFF";
const MUTED_DARK = "#A1A1AA";
const MUTED_LIGHT = "#55575C";
const UI = "GSF, system-ui, sans-serif";
const AR = "OTNaskh, serif";
const P0 = { x: 300, y: 120 };

type St = { id: string; m: number; w: number; h: number; r: number; d: number };
const S: St[] = [
  { id: "btn", m: M.btn, w: 500, h: 88, r: 44, d: 1 },
  { id: "loader", m: M.loader, w: 84, h: 84, r: 42, d: 1 },
  { id: "check", m: M.check, w: 84, h: 84, r: 42, d: 0 },
  { id: "island", m: M.island, w: 480, h: 100, r: 50, d: 1 },
  { id: "answer", m: M.answer, w: 700, h: 460, r: 36, d: 0 },
  { id: "player", m: M.player, w: 600, h: 168, r: 84, d: 1 },
  { id: "slider", m: M.slider, w: 680, h: 120, r: 60, d: 0 },
  { id: "toggle", m: M.toggle, w: 240, h: 120, r: 60, d: 0 },
  { id: "tabs", m: M.tabs, w: 780, h: 100, r: 50, d: 0 },
  { id: "chart", m: M.chart, w: 780, h: 480, r: 36, d: 0 },
  { id: "key", m: M.key, w: 160, h: 92, r: 28, d: 0 },
  { id: "cmdk", m: M.cmdk, w: 700, h: 400, r: 30, d: 0 },
  { id: "toast", m: M.toast, w: 560, h: 92, r: 46, d: 1 },
  { id: "btn2", m: M.back, w: 500, h: 88, r: 44, d: 1 },
];
const END = TL.beats;
const win = (id: string): [number, number] => {
  const i = S.findIndex((s) => s.id === id);
  return [S[i].m, i + 1 < S.length ? S[i + 1].m : END];
};
const camOf = (s: St) => Math.min(4.2, (0.76 * 1440) / Math.max(s.w, s.h * 1.15));

const keysOf = (f: (s: St) => number, w?: number, z?: number): Key[] =>
  S.slice(1).map((s) => ({ t: bt(s.m), v: f(s), w, z }));

// jendela tampil isi: masuk setelah bentuk mulai berubah, keluar sedikit sebelum bentuk berubah lagi
const vis = (t: number, a: number, b: number, first = false, last = false): number => {
  const inn = first ? 1 : step(t - (bt(a) + 0.075), 44, 0.92);
  const out = last ? 0 : step(t - (bt(b) - 0.11), 50, 0.92);
  return clamp(inn * (1 - out));
};
const wrapStyle = (o: number): React.CSSProperties => ({
  position: "absolute",
  left: 0,
  top: 0,
  opacity: o,
  filter: o < 0.995 ? `blur(${((1 - o) * 9).toFixed(2)}px)` : undefined,
  display: o < 0.002 ? "none" : undefined,
});

// ---------- ikon (garis 2 px seragam) ----------
const Ico: React.FC<{ d: React.ReactNode; size: number; color: string; style?: React.CSSProperties }> = ({ d, size, color, style }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" style={style}>
    {d}
  </svg>
);
const SUN = (
  <>
    <circle cx="12" cy="12" r="4" />
    <path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
  </>
);
const MOON = <path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" />;
const SEARCH = (
  <>
    <circle cx="11" cy="11" r="7" />
    <path d="M20 20l-4-4" />
  </>
);
const BOOK = <path d="M4 5.5C4 4.7 4.7 4 5.5 4H11v15H5.5C4.7 19 4 19.7 4 20.5zM20 5.5c0-.8-.7-1.5-1.5-1.5H13v15h5.5c.8 0 1.5.7 1.5 1.5z" />;

const Box: React.FC<{ x: number; y: number; w?: number; h?: number; children?: React.ReactNode; style?: React.CSSProperties }> = ({ x, y, w, h, children, style }) => (
  <div style={{ position: "absolute", left: x, top: y, width: w, height: h, transform: "translate(-50%,-50%)", ...style }}>{children}</div>
);
const Txt: React.FC<{ x: number; y: number; size: number; color: string; weight?: number; align?: "left" | "center" | "right"; w?: number; children: React.ReactNode; font?: string; ls?: number; lh?: number }> = ({
  x, y, size, color, weight = 500, align = "left", w = 700, children, font = UI, ls = 0, lh = 1.2,
}) => (
  <div
    style={{
      position: "absolute",
      left: align === "left" ? x : align === "center" ? x - w / 2 : x - w,
      top: y,
      width: w,
      transform: "translateY(-50%)",
      textAlign: align,
      fontFamily: font,
      fontSize: size,
      fontWeight: weight,
      color,
      letterSpacing: ls,
      lineHeight: lh,
      whiteSpace: "nowrap",
    }}
  >
    {children}
  </div>
);

// ---------- kursor ----------
const CUR: [number, number, number][] = [
  [0.8, 34, 6], [2.3, 150, 70], [4.3, 190, 60], [5.3, 250, 95], [6.2, 120, 12], [7.4, 260, 180],
  [10.2, -130, 150], [11.0, -210, 0], [12.4, -55, 52], [13.05, 165, 52], [14.2, 260, 100],
  [14.6, -72, 16], [15.05, 345, 16], [16.45, 300, 70], [17.2, -60, 0], [18.4, 150, 70],
  [19.4, 0, 2], [20.5, 200, 90], [22.0, -294, -8], [22.95, -196, 60], [23.9, 250, 150], [24.4, 300, 170], [26.0, 240, 40], [26.6, P0.x, P0.y],
];
const curKeys = (i: 1 | 2): Key[] => CUR.map(([b, x, y]) => ({ t: bt(b), v: i === 1 ? x : y }));
const cursorAt = (t: number) => ({ x: chan(t, P0.x, curKeys(1), 15, 0.9), y: chan(t, P0.y, curKeys(2), 15, 0.9) });

// geometri bersama
const TRACK = { l: -240, w: 480, y: 16 };
const BAR = { l: -120, w: 360, y: 52 };
const [H1a, H1b] = TL.holds[0];
const [H2a, H2b] = TL.holds[1];

const holdValue = (t: number, a: number, b: number, v0: number, f: (cx: number) => number, clampMax = 1, restTarget?: number) => {
  // nilai yang dihitung langsung dari posisi kursor selama ditekan; setelah dilepas kembali dengan pegas
  const c = cursorAt(Math.min(t, bt(b))).x;
  const held = f(c);
  const pre = v0;
  if (t < bt(a)) return { v: pre, over: 0 };
  if (t <= bt(b)) return { v: clamp(held, 0, clampMax), over: Math.max(0, held - clampMax) };
  if (restTarget === undefined) return { v: clamp(held, 0, clampMax), over: Math.max(0, held - clampMax) };
  const k = step(t - bt(b), 26, 0.62);
  return { v: mix(clamp(held, 0, clampMax), restTarget, k), over: Math.max(0, held - clampMax) * (1 - k) };
};

export const PromoLoop: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / PROMO_FPS;
  const beats = t / BEAT;
  const [h] = useState(() => delayRender("font"));
  useEffect(() => {
    Promise.all([
      loadFont({ family: "GSF", url: staticFile("promo/googlesansflex.woff2"), weight: "400 600" }),
      loadFont({ family: "OTNaskh", url: staticFile("promo/ScheherazadeNew-Regular.ttf") }),
    ])
      .then(() => continueRender(h))
      .catch((e) => cancelRender(e));
  }, [h]);

  // ----- bentuk -----
  const s0 = S[0];
  const press = bump(t, bt(TL.clicks[0]), 0.2);
  const stretch = holdValue(t, H2a, H2b, 0.35, (cx) => (cx - TRACK.l) / TRACK.w, 1, 1);
  const wBase = chan(t, s0.w, keysOf((s) => s.w), 30, 0.85);
  const hBase = chan(t, s0.h, keysOf((s) => s.h), 28, 0.86);
  const w = wBase * (1 - 0.04 * press) + stretch.over * TRACK.w * 0.38;
  const hh = hBase * (1 - 0.04 * press);
  const rr = Math.min(chan(t, s0.r, keysOf((s) => s.r), 26, 0.86), Math.min(w, hh) / 2);
  const dKeys: Key[] = [];
  S.slice(1).forEach((s) => {
    if (s.id === "tabs") dKeys.push({ t: bt(TL.flip), v: 1, w: 40 });
    dKeys.push({ t: bt(s.m), v: s.d, w: 44 });
  });
  const dark = clamp(chan(t, s0.d, dKeys, 44, 0.95));
  const cam = chan(t, camOf(s0), S.slice(1).map((s) => ({ t: bt(s.m) - 0.08, v: camOf(s) })), 22, 0.95);
  const bg = Math.round(mix(255, 17, dark));
  const shadowA = (1 - dark) * 0.18;

  // ----- kursor -----
  const cur = cursorAt(t);
  const clickT = TL.clicks.map(bt);
  let cPress = 0;
  for (const c of clickT) cPress = Math.max(cPress, bump(t, c, 0.16));
  for (const [a, b] of TL.holds) cPress = Math.max(cPress, step(t - bt(a), 60, 1) * (1 - step(t - bt(b), 60, 1)));
  const ripple = (() => {
    let best: { p: number; x: number; y: number } | null = null;
    const evs = [...TL.clicks, ...TL.holds.map((x) => x[0]), TL.enter];
    for (const c of evs) {
      const p = (t - bt(c)) / 0.32;
      if (p >= 0 && p <= 1) {
        const c2 = cursorAt(bt(c));
        best = { p, x: c2.x, y: c2.y };
      }
    }
    return best;
  })();

  // ----- jendela isi -----
  const vBtn = Math.max(vis(t, 0, S[1].m, true, false), vis(t, M.back, END, false, true));
  const vLoader = vis(t, ...win("loader"));
  const vCheck = vis(t, ...win("check"));
  const vIsland = vis(t, ...win("island"));
  const vAnswer = vis(t, ...win("answer"));
  const vPlayer = vis(t, ...win("player"));
  const vSlider = vis(t, ...win("slider"));
  const vInd = vis(t, M.toggle, M.key);
  const vTabs = vis(t, M.tabs, M.key);
  const vChart = vis(t, ...win("chart"));
  const vKey = vis(t, ...win("key"));
  const vCmd = vis(t, ...win("cmdk"));
  const vToast = vis(t, ...win("toast"));

  // ----- indikator cair (kenop toggle menjadi indikator tab) -----
  const dirR = (from: number, to: number) => (to > from ? 1 : -1);
  const indicator = (() => {
    const kL: Key[] = [];
    const kR: Key[] = [];
    const seq: { b: number; L: number; R: number; H: number; c: number; y: number }[] = [
      { b: TL.flip, L: 16, R: 104, H: 88, c: 1, y: 0 },
      { b: M.tabs, L: -332, R: -128, H: 84, c: 0, y: 0 },
      { b: TL.clicks[4], L: -102, R: 102, H: 84, c: 0, y: 0 },
      { b: M.chart, L: -102, R: 102, H: 84, c: 0, y: -190 },
    ];
    let pL = -104;
    let pR = -16;
    for (const q of seq) {
      const right = dirR(pL, q.L) > 0 || (q.L === pL && q.R > pR);
      kL.push({ t: bt(q.b), v: q.L, w: right ? 15 : 34, z: 0.86 });
      kR.push({ t: bt(q.b), v: q.R, w: right ? 34 : 15, z: 0.86 });
      pL = q.L;
      pR = q.R;
    }
    const Hk = seq.map((q) => ({ t: bt(q.b), v: q.H, w: 26 }));
    const ck = seq.map((q) => ({ t: bt(q.b), v: q.c, w: 20 }));
    const yk = seq.map((q) => ({ t: bt(q.b), v: q.y, w: 28 }));
    return {
      L: chan(t, -104, kL), R: chan(t, -16, kR), H: chan(t, 88, Hk), c: clamp(chan(t, 0, ck)), y: chan(t, 0, yk),
    };
  })();
  const tabY = chan(t, 0, [{ t: bt(M.chart), v: -190, w: 28 }], 28, 0.86);
  const TAB = [
    { name: "Jawaban", cx: -230 },
    { name: "Rujukan", cx: 0 },
    { name: "Catatan", cx: 230 },
  ];
  const cover = (cx: number) => clamp((Math.min(indicator.R, cx + 110) - Math.max(indicator.L, cx - 110)) / 220);

  // ----- isi tiap state -----
  const typed = (txt: string, a: number, b: number, tt: number) => txt.slice(0, Math.max(0, Math.min(txt.length, Math.floor(((tt / BEAT - a) / (b - a)) * txt.length + 0.0001))));
  const Q = "Apa itu rukun keempat?";
  const qShown = typed(Q, TL.typeQ[0], TL.typeQ[1], t);
  const caret = Math.floor(beats * 4) % 2 === 0;

  // pemutar
  const playing = step(t - bt(11.75), 60, 1);
  const prog = holdValue(t, H1a, H1b, 0.18, (cx) => (cx - BAR.l) / BAR.w, 1);
  const progV = prog.v;
  const wave = (i: number) => {
    const base = 0.3 + 0.7 * Math.abs(Math.sin(i * 0.83 + beats * Math.PI * 1.0));
    const pulse = 0.55 + 0.45 * Math.abs(Math.cos(beats * Math.PI * 2 + i * 0.4));
    return mix(0.18, base * pulse, playing);
  };
  const polyL = (k: number) =>
    [[-10, -18], [-10, 18], [4, 9], [4, -9]].map(([x, y], i) => [mix(x, [-14, -14, -4, -4][i], k), mix(y, [-18, 18, 18, -18][i], k)]);
  const polyR = (k: number) =>
    [[4, -9], [4, 9], [18, 0], [18, 0]].map(([x, y], i) => [mix(x, [4, 4, 14, 14][i], k), mix(y, [-18, 18, 18, -18][i], k)]);
  const pts = (p: number[][]) => p.map((q) => q.join(",")).join(" ");

  // slider
  const sv = stretch.v;
  const pct = Math.round(mix(85, 200, sv));
  const handleX = TRACK.l + sv * TRACK.w;

  // chart
  const bars = [
    { n: "Al-Umm", u: 3 }, { n: "Al-Majmu'", u: 2 }, { n: "Ar-Rafi'i", u: 1 }, { n: "Fath al-Wahhab", u: 1 },
    { n: "Bujairimi", u: 1 }, { n: "Nihayat az-Zain", u: 1 }, { n: "Tuhfah", u: 1 },
  ];
  const cx0 = (i: number) => -294 + i * 98;
  const baseY = 170;
  const hov0 = TL.hover[0].map(bt);
  const hov1 = TL.hover[1].map(bt);
  const tipOp = Math.max(step(t - hov0[0], 46, 0.9) * (1 - step(t - hov0[1] - 0.03, 46, 0.9)), step(t - hov1[0], 46, 0.9) * (1 - step(t - hov1[1] - 0.2, 40, 0.9)));
  const tipX = chan(t, cx0(0), [{ t: hov1[0], v: cx0(1), w: 26 }], 26, 0.9);
  const tipTopY = chan(t, baseY - 3 * 70, [{ t: hov1[0], v: baseY - 2 * 70, w: 26 }], 26, 0.9);
  const tipText = t < hov1[0] ? "Al-Umm · 3 rujukan" : "Al-Majmu' · 2 rujukan";
  const hoverIdx = t >= hov1[0] ? 1 : t >= hov0[0] ? 0 : -1;

  // palet perintah
  const rows = [
    { n: "Al-Umm", s: "Imam asy-Syafi'i" },
    { n: "Al-Majmu'", s: "An-Nawawi" },
    { n: "Fikih Tahawwulat", s: "Bidang ilmu" },
    { n: "Catatan saya", s: "Catatan" },
  ];
  const QK = "umm";
  const typedK = QK.slice(0, Math.max(0, Math.min(3, Math.floor(((t / BEAT - TL.typeK[0]) / (TL.typeK[1] - TL.typeK[0])) * 3 + 0.0001) + 0)));
  const charT = (i: number) => bt(TL.typeK[0] + ((TL.typeK[1] - TL.typeK[0]) * i) / 3);
  const rowF = rows.map((r) => {
    let hide = Infinity;
    for (let i = 1; i <= QK.length; i++) if (!r.n.toLowerCase().includes(QK.slice(0, i))) { hide = charT(i - 1); break; }
    return 1 - step(t - hide, 30, 0.95);
  });
  let cum = 0;
  const rowY = rowF.map((f) => { const y = cum; cum += 64 * f; return y; });
  const enterFlash = bump(t, bt(TL.enter), 0.2);

  // peta kursor: tombol simpan toast
  return (
    <AbsoluteFill style={{ backgroundColor: CANVAS, overflow: "hidden" }}>
      <div style={{ position: "absolute", left: 720, top: 720, width: 0, height: 0, transform: `scale(${cam})` }}>
        {/* bentuk tunggal */}
        <div
          style={{
            position: "absolute",
            left: -w / 2,
            top: -hh / 2,
            width: w,
            height: hh,
            borderRadius: rr,
            background: `rgb(${bg},${bg},${bg})`,
            overflow: "hidden",
            boxShadow: `0 1px 2px rgba(17,17,17,${shadowA * 0.35}), 0 26px 60px -22px rgba(17,17,17,${shadowA})`,
          }}
        >
          <div style={{ position: "absolute", left: w / 2, top: hh / 2, width: 0, height: 0 }}>
            {/* 1 tombol */}
            <div style={wrapStyle(vBtn)}>
              <img src={staticFile("promo/mark_white.svg")} style={{ position: "absolute", left: -218, top: -22, height: 44 }} />
              <Txt x={22} y={0} size={26} weight={600} color={WHITE} align="center" w={420} ls={0.1}>
                Segera hadir · 26.10.2026
              </Txt>
            </div>
            {/* 2 pemuat */}
            <div style={wrapStyle(vLoader)}>
              {[-22, 0, 22].map((x, i) => {
                const p = 0.55 + 0.45 * bump(beats * 2 - i * 0.28 - 4, 0, 1);
                const ph = (((beats * 2 - i * 0.28) % 2) + 2) % 2;
                const sc = 0.62 + 0.38 * Math.sin(Math.min(1, ph) * Math.PI) * (ph <= 1 ? 1 : 0);
                void p;
                return <Box key={i} x={x} y={0} w={13} h={13} style={{ borderRadius: 9, background: WHITE, transform: `translate(-50%,-50%) scale(${sc})`, opacity: 0.6 + 0.4 * sc }} />;
              })}
            </div>
            {/* 3 centang */}
            <div style={wrapStyle(vCheck)}>
              <svg width="44" height="44" viewBox="0 0 24 24" style={{ position: "absolute", left: -22, top: -22 }} fill="none" stroke={INK} strokeWidth={2.4} strokeLinecap="round" strokeLinejoin="round">
                <path d="M5 12.5l4.5 4.5L19 7.5" pathLength={1} strokeDasharray={1} strokeDashoffset={1 - step(t - bt(M.check + 0.3), 18, 1)} />
              </svg>
            </div>
            {/* 4 dynamic island */}
            <div style={wrapStyle(vIsland)}>
              <img src={staticFile("promo/mark_white.svg")} style={{ position: "absolute", left: -208, top: -24, height: 48 }} />
              <Txt x={-160} y={-13} size={23} weight={600} color={WHITE}>OpenTurath AI</Txt>
              <Txt x={-160} y={16} size={15} weight={400} color={MUTED_DARK}>Menyiapkan jawaban</Txt>
              {[0, 1, 2].map((i) => {
                const ph = (((beats * 2 - i * 0.28) % 2) + 2) % 2;
                const sc = 0.62 + 0.38 * (ph <= 1 ? Math.sin(ph * Math.PI) : 0);
                return <Box key={i} x={176 + i * 22} y={0} w={11} h={11} style={{ borderRadius: 6, background: WHITE, transform: `translate(-50%,-50%) scale(${sc})`, opacity: 0.55 + 0.45 * sc }} />;
              })}
            </div>
            {/* 5 kartu jawaban */}
            <div style={wrapStyle(vAnswer)}>
              <Txt x={-310} y={-176} size={31} weight={500} color={INK} w={640}>
                {qShown}
                <span style={{ display: "inline-block", width: 3, height: 30, marginLeft: 3, verticalAlign: "-5px", background: INK, opacity: caret && qShown.length < Q.length + 99 ? 1 : 0 }} />
              </Txt>
              <div style={{ position: "absolute", left: -310, top: -138, width: 620, height: 1, background: "rgba(17,17,17,.1)", opacity: step(t - bt(9.3), 30, 1) }} />
              <div style={{ position: "absolute", left: -310, top: -118, width: 620, opacity: step(t - bt(9.4), 22, 0.95), transform: `translateY(${(1 - step(t - bt(9.4), 22, 0.95)) * 10}px)`, fontFamily: UI, fontSize: 23, lineHeight: 1.45, color: MUTED_LIGHT, fontWeight: 400 }}>
                Menurut Fikih Tahawwulat, rukun agama ada empat: Islam, iman, ihsan, dan tanda-tanda kiamat.
              </div>
              <div style={{ position: "absolute", left: -310, top: 8, width: 620, textAlign: "right", direction: "rtl", fontFamily: AR, fontSize: 35, lineHeight: 1.9, color: INK, opacity: step(t - bt(9.9), 22, 0.95), transform: `translateY(${(1 - step(t - bt(9.9), 22, 0.95)) * 10}px)` }}>
                ويعلم من سياق الحديث أن أركان الدين أربعة
              </div>
              <Box x={-130} y={156} w={360} h={46} style={{ opacity: step(t - bt(10.3), 24, 0.95), transform: `translate(-50%,-50%) translateY(${(1 - step(t - bt(10.3), 24, 0.95)) * 8}px)` }}>
                <div style={{ width: 360, height: 46, borderRadius: 23, background: `rgba(17,17,17,${0.06 + 0.07 * step(t - bt(10.6), 30, 1)})`, display: "flex", alignItems: "center", gap: 10, paddingLeft: 18, fontFamily: UI, fontSize: 17, fontWeight: 500, color: INK }}>
                  <Ico d={BOOK} size={20} color={INK} />
                  An-Nubdzah ash-Shughra · hlm. 10
                </div>
              </Box>
            </div>
            {/* 6 pemutar */}
            <div style={wrapStyle(vPlayer)}>
              <Box x={-210} y={0} w={112} h={112} style={{ borderRadius: 56, background: WHITE, transform: `translate(-50%,-50%) scale(${1 - 0.06 * bump(t, bt(11.75), 0.16)})` }}>
                <svg width="112" height="112" viewBox="-28 -28 56 56" style={{ position: "absolute", left: 0, top: 0 }}>
                  <polygon points={pts(polyL(playing))} fill={INK} />
                  <polygon points={pts(polyR(playing))} fill={INK} />
                </svg>
              </Box>
              <Txt x={-128} y={-40} size={25} weight={600} color={WHITE}>Arsip muhadharah</Txt>
              <Txt x={-128} y={-10} size={16} weight={400} color={MUTED_DARK}>Fikih Tahawwulat</Txt>
              {Array.from({ length: 12 }).map((_, i) => (
                <Box key={i} x={140 + i * 12} y={-24} w={6} h={Math.max(6, wave(i) * 48)} style={{ borderRadius: 3, background: WHITE, opacity: 0.55 + 0.45 * wave(i) }} />
              ))}
              <div style={{ position: "absolute", left: BAR.l, top: BAR.y - 4, width: BAR.w, height: 8, borderRadius: 4, background: "rgba(255,255,255,.22)" }} />
              <div style={{ position: "absolute", left: BAR.l, top: BAR.y - 4, width: BAR.w * progV, height: 8, borderRadius: 4, background: WHITE }} />
              <Box x={BAR.l + BAR.w * progV} y={BAR.y} w={22} h={22} style={{ borderRadius: 11, background: WHITE, transform: `translate(-50%,-50%) scale(${0.55 + 0.45 * Math.max(step(t - bt(H1a), 40, 1) * (1 - step(t - bt(H1b), 40, 1)), step(t - bt(12.4), 18, 1) * (1 - step(t - bt(H1b + 0.1), 18, 1)))})` }} />
            </div>
            {/* 7 slider ukuran huruf */}
            <div style={wrapStyle(vSlider)}>
              <Txt x={-318} y={16} size={20} weight={600} color={INK}>A</Txt>
              <Txt x={318} y={16} size={36} weight={600} color={INK} align="right" w={60}>A</Txt>
              <Txt x={handleX} y={-30} size={19} weight={600} color={INK} align="center" w={120}>{pct}%</Txt>
              <div style={{ position: "absolute", left: TRACK.l, top: TRACK.y - 5, width: TRACK.w, height: 10, borderRadius: 5, background: "rgba(17,17,17,.12)" }} />
              <div style={{ position: "absolute", left: TRACK.l, top: TRACK.y - 5, width: handleX - TRACK.l, height: 10, borderRadius: 5, background: INK }} />
              <Box x={handleX} y={TRACK.y} w={40} h={40} style={{ borderRadius: 20, background: INK, boxShadow: "0 0 0 6px #fff" }} />
            </div>
            {/* indikator cair: kenop toggle lalu indikator tab */}
            <div style={wrapStyle(vInd)}>
              <div
                style={{
                  position: "absolute",
                  left: indicator.L,
                  top: indicator.y - indicator.H / 2,
                  width: Math.max(0, indicator.R - indicator.L),
                  height: indicator.H,
                  borderRadius: indicator.H / 2,
                  background: `rgb(${Math.round(mix(17, 255, indicator.c))},${Math.round(mix(17, 255, indicator.c))},${Math.round(mix(17, 255, indicator.c))})`,
                }}
              />
              {/* ikon di kenop */}
              <Box x={(indicator.L + indicator.R) / 2} y={indicator.y} w={44} h={44} style={{ opacity: 1 - step(t - bt(M.tabs - 0.2), 40, 0.9) }}>
                <div style={{ position: "absolute", inset: 0, opacity: 1 - step(t - bt(TL.flip), 36, 0.9), filter: `blur(${step(t - bt(TL.flip), 36, 0.9) * 6}px)` }}>
                  <Ico d={SUN} size={44} color={WHITE} />
                </div>
                <div style={{ position: "absolute", inset: 0, opacity: step(t - bt(TL.flip + 0.05), 36, 0.9), filter: `blur(${(1 - step(t - bt(TL.flip + 0.05), 36, 0.9)) * 6}px)` }}>
                  <Ico d={MOON} size={44} color={INK} />
                </div>
              </Box>
            </div>
            {/* label tab (toggle→tab→grafik) */}
            <div style={wrapStyle(Math.min(vTabs, step(t - bt(M.tabs + 0.1), 40, 0.9)))}>
              {TAB.map((q) => {
                const k = cover(q.cx);
                const c = Math.round(mix(17, 255, k));
                return <Txt key={q.name} x={q.cx} y={tabY} size={24} weight={600} color={`rgb(${c},${c},${c})`} align="center" w={220}>{q.name}</Txt>;
              })}
            </div>
            {/* 10 grafik */}
            <div style={wrapStyle(vChart)}>
              <Txt x={-340} y={-124} size={18} weight={500} color={MUTED_LIGHT}>10 rujukan dalam satu jawaban</Txt>
              <div style={{ position: "absolute", left: -330, top: baseY, width: 660 * step(t - bt(M.chart + 0.15), 16, 1), height: 2, background: "rgba(17,17,17,.2)" }} />
              {bars.map((b, i) => {
                const hv = b.u * 70 * step(t - bt(M.chart + 0.35 + i * 0.1), 20, 0.88);
                const act = hoverIdx === i;
                return (
                  <React.Fragment key={b.n}>
                    <div style={{ position: "absolute", left: cx0(i) - 35, top: baseY - hv, width: 70, height: hv, borderRadius: 14, background: act ? INK : "rgba(17,17,17,.82)", opacity: act || hoverIdx < 0 ? 1 : 0.55 }} />
                    <Txt x={cx0(i)} y={baseY + 28} size={13} weight={500} color={MUTED_LIGHT} align="center" w={96}>{b.n}</Txt>
                  </React.Fragment>
                );
              })}
              <div style={{ position: "absolute", left: tipX, top: tipTopY - 52, transform: "translateX(-50%)", opacity: tipOp }}>
                <div style={{ background: INK, color: WHITE, borderRadius: 14, padding: "9px 16px", fontFamily: UI, fontSize: 16, fontWeight: 600, whiteSpace: "nowrap" }}>{tipText}</div>
                <div style={{ width: 12, height: 12, background: INK, transform: "translate(-50%,-6px) rotate(45deg)", marginLeft: "50%" }} />
              </div>
            </div>
            {/* 11a keycap ⌘K */}
            <div style={wrapStyle(vKey)}>
              <Txt x={0} y={0} size={40} weight={600} color={INK} align="center" w={160}>⌘ K</Txt>
            </div>
            {/* 11b palet perintah */}
            <div style={wrapStyle(vCmd)}>
              <Ico d={SEARCH} size={26} color={MUTED_LIGHT} style={{ position: "absolute", left: -322, top: -163 }} />
              <Txt x={-278} y={-150} size={27} weight={500} color={INK} w={500}>
                {typedK}
                <span style={{ display: "inline-block", width: 2.5, height: 28, marginLeft: 2, verticalAlign: "-5px", background: INK, opacity: caret && typedK.length < 3 ? 1 : typedK.length === 3 && caret ? 1 : 0 }} />
              </Txt>
              <Box x={296} y={-150} w={64} h={36} style={{ borderRadius: 11, border: "1.5px solid rgba(17,17,17,.2)", fontFamily: UI, fontSize: 17, fontWeight: 600, color: MUTED_LIGHT, display: "flex", alignItems: "center", justifyContent: "center" }}>⌘K</Box>
              <div style={{ position: "absolute", left: -350, top: -108, width: 700, height: 1, background: "rgba(17,17,17,.1)" }} />
              {rows.map((r, i) => (
                <div key={r.n} style={{ position: "absolute", left: -336, top: -92 + rowY[i], width: 672, height: 56, opacity: rowF[i], transform: `scale(${0.96 + 0.04 * rowF[i]})`, transformOrigin: "left center" }}>
                  <div style={{ position: "absolute", inset: 0, borderRadius: 16, background: i === 0 ? `rgba(17,17,17,${0.06 + 0.06 * enterFlash})` : "transparent" }} />
                  <Txt x={20} y={28} size={21} weight={600} color={INK} w={320}>{r.n}</Txt>
                  <Txt x={652} y={28} size={16} weight={400} color={MUTED_LIGHT} align="right" w={300}>{r.s}</Txt>
                </div>
              ))}
            </div>
            {/* 12 toast */}
            <div style={wrapStyle(vToast)}>
              <Box x={-222} y={0} w={44} h={44} style={{ borderRadius: 22, background: WHITE }}>
                <svg width="44" height="44" viewBox="0 0 24 24" style={{ position: "absolute", left: 0, top: 0 }} fill="none" stroke={INK} strokeWidth={2.4} strokeLinecap="round" strokeLinejoin="round">
                  <path d="M7 12.5l3.5 3.5L17 9" pathLength={1} strokeDasharray={1} strokeDashoffset={1 - step(t - bt(M.toast + 0.2), 20, 1)} />
                </svg>
              </Box>
              <Txt x={-178} y={0} size={25} weight={600} color={WHITE}>Tersimpan ke Catatan</Txt>
              <Txt x={246} y={0} size={18} weight={500} color={MUTED_DARK} align="right" w={120}>Urungkan</Txt>
            </div>
          </div>
        </div>

        {/* kursor di atas semuanya, ukurannya tetap di layar */}
        {ripple && (
          <div
            style={{
              position: "absolute",
              left: ripple.x,
              top: ripple.y,
              width: 0,
              height: 0,
              transform: `scale(${1 / cam})`,
            }}
          >
            <div style={{ position: "absolute", left: -(14 + 36 * ripple.p), top: -(14 + 36 * ripple.p), width: 2 * (14 + 36 * ripple.p), height: 2 * (14 + 36 * ripple.p), borderRadius: "50%", border: "2.5px solid rgba(120,120,120,.75)", opacity: 1 - ripple.p }} />
          </div>
        )}
        <div style={{ position: "absolute", left: cur.x, top: cur.y, width: 0, height: 0, transform: `scale(${(1 / cam) * (1 - 0.12 * cPress)})` }}>
          <svg width="66" height="66" viewBox="0 0 24 24" style={{ position: "absolute", left: -14, top: -9 }}>
            <path d="M5 3l14 8-6.2 1.6L9.8 19z" fill={INK} stroke="#fff" strokeWidth="1.5" strokeLinejoin="round" />
          </svg>
        </div>
      </div>
    </AbsoluteFill>
  );
};
