import React from "react";
import { Img, staticFile, useCurrentFrame } from "remotion";
import { HURUF } from "../tema";
import {
  Ar,
  ISI,
  Jalur,
  SLIDES,
  Tx,
  acak,
  gayaArab,
  mihrab,
  mix,
  p,
  lembut,
  type Pal,
  type Slide,
} from "./kit";
import { Buku, Orang, centang, gelembung, perisai, silang } from "./ikon";

export type VisProps = { s: Slide; c: Pal; h: number };
export type Vis = React.FC<VisProps>;

const Kanvas: React.FC<{ h: number; w?: number; children: React.ReactNode }> = ({
  h,
  w = ISI,
  children,
}) => (
  <svg width={w} height={h} viewBox={`0 0 ${w} ${h}`} style={{ position: "absolute", inset: 0, overflow: "visible" }}>
    {children}
  </svg>
);

/** Jarum kompas: bergoyang lalu menetap ke atas. */
const Jarum: React.FC<{ x: number; y: number; r: number; c: Pal; tenang: number; f: number }> = ({
  x,
  y,
  r,
  c,
  tenang,
  f,
}) => {
  const goyang = Math.sin(f / 4) * 70 * (1 - tenang) + Math.sin(f / 9) * 25 * (1 - tenang);
  return (
    <g transform={`rotate(${goyang} ${x} ${y})`}>
      <path d={`M${x} ${y - r} L${x + r * 0.16} ${y} L${x - r * 0.16} ${y} Z`} fill={c.ink} />
      <path d={`M${x} ${y + r} L${x + r * 0.16} ${y} L${x - r * 0.16} ${y} Z`} fill="none" stroke={c.ink} strokeWidth={3} />
      <circle cx={x} cy={y} r={r * 0.07} fill={c.bg} stroke={c.ink} strokeWidth={3} />
    </g>
  );
};

// ── Bab 0 · Pengantar ──────────────────────────────────────────────────

/** Sampul: lengkung mihrab tergambar, kompas menetap, judul muncul. */
const Sampul: Vis = ({ s, c }) => {
  const f = useCurrentFrame();
  const cx = 540;
  return (
    <>
      <Kanvas h={1350} w={1080}>
        {[620, 500, 380].map((l, k) => (
          <Jalur key={l} d={mihrab(cx, 820, l)} t={p(f, k * 8, 60 + k * 8)} warna={k ? c.line : c.faint} tebal={k ? 2 : 3} />
        ))}
        <g opacity={p(f, 40, 70)}>
          <circle cx={cx} cy={560} r={118} fill="none" stroke={c.line} strokeWidth={2} />
          {Array.from({ length: 24 }).map((_, k) => {
            const a = (k / 24) * Math.PI * 2;
            const r1 = k % 6 === 0 ? 96 : 106;
            return (
              <line key={k} x1={cx + Math.sin(a) * r1} y1={560 - Math.cos(a) * r1} x2={cx + Math.sin(a) * 114} y2={560 - Math.cos(a) * 114} stroke={c.faint} strokeWidth={2} />
            );
          })}
          <Jarum x={cx} y={560} r={86} c={c} tenang={p(f, 60, 130, lembut)} f={f} />
        </g>
      </Kanvas>
      <div style={{ position: "absolute", left: 80, right: 80, top: 900, textAlign: "center" }}>
        <div style={{ ...gayaArab(84, c.ink), lineHeight: 1.4, opacity: p(f, 70, 95) }}>{s.arab}</div>
        <div style={{ fontFamily: HURUF.serif, fontSize: 72, lineHeight: 1.1, color: c.ink, marginTop: 6, opacity: p(f, 85, 110), transform: `translateY(${(1 - p(f, 85, 115)) * 24}px)` }}>
          {s.judul}
        </div>
        <div style={{ fontFamily: HURUF.ui, fontSize: 32, lineHeight: 1.4, color: c.muted, marginTop: 22, opacity: p(f, 105, 130) }}>{s.sub}</div>
        <div style={{ fontFamily: HURUF.ui, fontWeight: 600, fontSize: 22, letterSpacing: 3, color: c.faint, marginTop: 40, opacity: p(f, 125, 150) }}>
          PENGANTAR · {SLIDES.length} SLIDE · 11 BAB
        </div>
      </div>
      <div style={{ position: "absolute", left: 0, right: 0, top: 70, display: "flex", justifyContent: "center", opacity: p(f, 20, 45) }}>
        <Img src={staticFile("logo_putih.png")} style={{ width: 64, height: 64 }} />
      </div>
    </>
  );
};

/** Zaman: notifikasi berdatangan makin cepat mengepung seorang pembaca. */
const Zaman: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const n = 26;
  return (
    <Kanvas h={h}>
      <Orang x={460} y={h / 2 + 30} u={1.4} w={c.ink} isi={c.bg} />
      {Array.from({ length: n }).map((_, k) => {
        // Jeda antarnotifikasi makin pendek: zaman makin cepat.
        const mulai = 6 + 60 * Math.sqrt(k / n) * 2.2;
        const t = p(f, mulai, mulai + 12);
        const sudut = acak(k + 3) * Math.PI * 2;
        const jarak = 150 + acak(k + 7) * 230;
        const x = 460 + Math.cos(sudut) * jarak * 1.3;
        const y = h / 2 + Math.sin(sudut) * jarak * 0.55;
        const l = 90 + acak(k) * 90;
        const drift = Math.sin((f + k * 13) / 11) * 4;
        return (
          <g key={k} opacity={t * (k % 3 === 0 ? 1 : 0.7)} transform={`translate(${drift} ${-drift}) scale(${mix(0.6, 1, t)})`} style={{ transformOrigin: `${x}px ${y}px` }}>
            <rect x={x - l / 2} y={y - 22} width={l} height={44} rx={14} fill={c.surface} stroke={c.line} strokeWidth={2} />
            <circle cx={x - l / 2 + 22} cy={y} r={8} fill={k % 4 === 0 ? c.ink : c.faint} />
            <rect x={x - l / 2 + 38} y={y - 5} width={l - 54} height={10} rx={5} fill={c.line} />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Kompas: badai hujan; jalan tergambar menuju tujuan; hujan reda saat jalan selesai. */
const Kompas: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const jalan = p(f, 30, 120, lembut);
  const reda = 1 - jalan * 0.85;
  const d = `M120 ${h - 30} C 260 ${h - 120}, 160 ${h - 230}, 380 ${h - 250} S 640 ${h - 330}, 780 ${h - 380}`;
  return (
    <Kanvas h={h}>
      {Array.from({ length: 60 }).map((_, k) => {
        const x = ((acak(k) * 1100 + f * 9) % 1100) - 90;
        const y = ((acak(k + 50) * h + f * 26) % (h + 60)) - 30;
        return <line key={k} x1={x} y1={y} x2={x - 14} y2={y + 34} stroke={c.faint} strokeWidth={2} opacity={0.6 * reda} />;
      })}
      <Jalur d={d} t={1} warna={c.line} tebal={14} putus />
      <Jalur d={d} t={jalan} warna={c.ink} tebal={6} />
      <g opacity={p(f, 110, 130)}>
        <circle cx={780} cy={h - 380} r={18} fill={c.ink} />
        <circle cx={780} cy={h - 380} r={34 + Math.sin(f / 6) * 4} fill="none" stroke={c.ink} strokeWidth={2} />
      </g>
      <g>
        <circle cx={160} cy={110} r={74} fill={c.surface} stroke={c.line} strokeWidth={2} />
        <Jarum x={160} y={110} r={56} c={c} tenang={p(f, 40, 120, lembut)} f={f} />
      </g>
    </Kanvas>
  );
};

/** Perintis: nama Arab, nama Latin, lalu garis hidup 1366–1444 H. */
const Perintis: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const garis = p(f, 40, 90, lembut);
  const y = h - 70;
  return (
    <>
      <div style={{ position: "absolute", left: 0, right: 0, top: 0, textAlign: "center", ...gayaArab(50, c.ink), lineHeight: 1.6, opacity: p(f, 0, 25) }}>
        {s.arab}
      </div>
      <div style={{ position: "absolute", left: 0, right: 0, top: 100, textAlign: "center", fontFamily: HURUF.serif, fontSize: 38, color: c.ink, opacity: p(f, 20, 45) }}>
        {s.nama}
      </div>
      <Kanvas h={h}>
        <line x1={120} y1={y} x2={mix(120, 800, garis)} y2={y} stroke={c.ink} strokeWidth={3} />
        <circle cx={120} cy={y} r={10} fill={c.ink} opacity={p(f, 40, 50)} />
        <circle cx={800} cy={y} r={10} fill={c.ink} opacity={p(f, 85, 95)} />
        <Tx x={120} y={y + 40} s="Lahir 1366 H · 1947 M" u={22} w={c.muted} o={p(f, 45, 60)} />
        <Tx x={800} y={y + 40} s="Wafat 1444 H · 2022 M" u={22} w={c.muted} o={p(f, 88, 100)} />
        <Tx x={460} y={y - 30} s="Hadhramaut, Yaman" u={22} bobot={600} w={c.ink} o={p(f, 60, 80)} />
      </Kanvas>
    </>
  );
};

// ── Bab 1 · Arti nama ──────────────────────────────────────────────────

/** Fikih: bor turun menembus lapisan, dari tahu ke paham. */
const Fikih: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const lapis = ["Tahu", "Mengerti", "Paham maksudnya"];
  const turun = p(f, 20, 80, lembut);
  return (
    <Kanvas h={h}>
      <Ar x={130} y={h / 2} s={s.arab!} u={120} w={c.ink} o={p(f, 0, 20)} />
      {lapis.map((l, k) => {
        const y = 20 + k * 100;
        const aktif = turun * 3 > k + 0.3;
        return (
          <g key={l} opacity={p(f, 6 + k * 6, 20 + k * 6)}>
            <rect x={300} y={y} width={520} height={88} rx={18} fill={k === 2 && aktif ? c.ink : c.surface} />
            <Tx x={340} y={y + 44} s={l} a="start" u={28} bobot={600} w={k === 2 && aktif ? c.onInk : c.ink} />
          </g>
        );
      })}
      <line x1={870} y1={0} x2={870} y2={mix(0, 290, turun)} stroke={c.ink} strokeWidth={5} strokeLinecap="round" opacity={0.9} />
      <path d={`M856 ${mix(0, 290, turun) - 14} L870 ${mix(0, 290, turun) + 6} L884 ${mix(0, 290, turun) - 14}`} fill="none" stroke={c.ink} strokeWidth={5} strokeLinecap="round" strokeLinejoin="round" />
    </Kanvas>
  );
};

/** Tahawwul: satu titik berpindah keadaan; lalu menjadi rangkaian perubahan. */
const Tahawwul: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const satu = p(f, 10, 45, lembut);
  const banyak = p(f, 55, 110, lembut);
  const bentuk = (k: number, x: number, y: number, r: number, isi: string) => {
    const j = k % 3;
    if (j === 0) return <circle cx={x} cy={y} r={r} fill={isi} stroke={c.ink} strokeWidth={3} />;
    if (j === 1) return <rect x={x - r} y={y - r} width={r * 2} height={r * 2} rx={8} fill={isi} stroke={c.ink} strokeWidth={3} />;
    return <path d={`M${x} ${y - r} L${x + r} ${y + r * 0.8} L${x - r} ${y + r * 0.8} Z`} fill={isi} stroke={c.ink} strokeWidth={3} strokeLinejoin="round" />;
  };
  return (
    <Kanvas h={h}>
      <Ar x={460} y={34} s="تَحَوُّل" u={44} w={c.ink} o={p(f, 0, 15)} />
      <Tx x={460} y={78} s="satu perubahan" u={22} w={c.muted} o={p(f, 0, 15)} />
      {bentuk(0, 300, 150, 32, c.surface)}
      <line x1={350} y1={150} x2={mix(350, 560, satu)} y2={150} stroke={c.ink} strokeWidth={3} />
      <g opacity={satu}>{bentuk(1, 620, 150, 32, c.ink)}</g>
      <Ar x={460} y={232} s="تَحَوُّلَات" u={44} w={c.ink} o={p(f, 50, 65)} />
      <Tx x={460} y={276} s="rangkaian perubahan" u={22} w={c.muted} o={p(f, 50, 65)} />
      {Array.from({ length: 7 }).map((_, k) => {
        const x = 70 + k * 130;
        const t = p(f, 60 + k * 7, 75 + k * 7);
        return (
          <g key={k} opacity={t}>
            {k > 0 && <line x1={x - 100} y1={340} x2={x - 30} y2={340} stroke={c.faint} strokeWidth={2} />}
            {bentuk(k, x, 340, 22, k === 6 ? c.ink : c.surface)}
          </g>
        );
      })}
      <rect x={0} y={0} width={0} height={0} opacity={banyak} />
    </Kanvas>
  );
};

/** Gabungan: fikih + tahawwulat; lensa di tengah, lima wilayah di sekeliling. */
const Gabungan: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const cx = 460;
  const cy = h / 2 + 10;
  const poin = s.poin!;
  return (
    <Kanvas h={h}>
      <g opacity={p(f, 0, 20)}>
        <rect x={cx - 280} y={6} width={200} height={62} rx={31} fill={c.surface} />
        <Ar x={cx - 180} y={40} s="فقه" u={36} w={c.ink} />
        <Tx x={cx} y={37} s="+" u={40} w={c.muted} />
        <rect x={cx + 80} y={6} width={200} height={62} rx={31} fill={c.surface} />
        <Ar x={cx + 180} y={40} s="تحولات" u={36} w={c.ink} />
      </g>
      <circle cx={cx} cy={cy} r={mix(0, 92, p(f, 25, 55))} fill={c.ink} />
      <Tx x={cx} y={cy - 14} s="Fikih" u={28} bobot={600} w={c.onInk} o={p(f, 45, 60)} />
      <Tx x={cx} y={cy + 20} s="Tahawwulat" u={28} bobot={600} w={c.onInk} o={p(f, 45, 60)} />
      {poin.map((x, k) => {
        const a = -Math.PI / 2 + ((k + 0.5) / poin.length) * Math.PI * 2 - Math.PI / poin.length;
        const rx = 320;
        const ry = 150;
        const px = cx + Math.cos(a) * rx;
        const py = cy + 30 + Math.sin(a) * ry;
        const t = p(f, 60 + k * 10, 80 + k * 10);
        return (
          <g key={x} opacity={t}>
            <line x1={cx + Math.cos(a) * 96} y1={cy + Math.sin(a) * 96} x2={mix(cx, px, t)} y2={mix(cy, py, t)} stroke={c.faint} strokeWidth={2} />
            <rect x={px - 120} y={py - 26} width={240} height={52} rx={26} fill={c.surface} stroke={c.line} strokeWidth={2} />
            <Tx x={px} y={py} s={x} u={24} w={c.ink} />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Definisi: garis waktu dari azali sampai kiamat. */
const Definisi: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const t = p(f, 0, 50, lembut);
  const titik = [
    ["Azali", 40],
    ["Telah terjadi", 300],
    ["Sedang terjadi", 560],
    ["Hari kiamat", 880],
  ] as const;
  return (
    <Kanvas h={h}>
      <line x1={40} y1={50} x2={mix(40, 880, t)} y2={50} stroke={c.ink} strokeWidth={3} />
      {titik.map(([l, x], k) => (
        <g key={l} opacity={p(f, k * 12, k * 12 + 14)}>
          <circle cx={x} cy={50} r={k === 2 ? 12 : 8} fill={k === 2 ? c.ink : c.bg} stroke={c.ink} strokeWidth={3} />
          <Tx x={x} y={96} s={l} u={22} w={c.muted} a={k === 0 ? "start" : k === 3 ? "end" : "middle"} />
        </g>
      ))}
      <circle cx={560} cy={50} r={12 + 10 * ((f % 40) / 40)} fill="none" stroke={c.ink} strokeWidth={2} opacity={1 - (f % 40) / 40} />
    </Kanvas>
  );
};

/** Bukan ramalan: kalender, sosok, dan rasa takut dicoret; yang tersisa pola. */
const BukanRamalan: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const kolom = [150, 460, 770];
  const ikon = [
    // Kalender
    (x: number) => (
      <g>
        <rect x={x - 46} y={46} width={92} height={84} rx={12} fill={c.surface} stroke={c.ink} strokeWidth={3} />
        <line x1={x - 46} y1={72} x2={x + 46} y2={72} stroke={c.ink} strokeWidth={3} />
        <Tx x={x} y={102} s="?" u={34} bobot={600} w={c.ink} />
      </g>
    ),
    (x: number) => <Orang x={x} y={110} u={1.1} w={c.ink} isi={c.surface} />,
    (x: number) => (
      <g>
        <path d={`M${x - 40} 120 L${x} 46 L${x + 40} 120 Z`} fill={c.surface} stroke={c.ink} strokeWidth={3} strokeLinejoin="round" />
        <Tx x={x} y={98} s="!" u={34} bobot={600} w={c.ink} />
      </g>
    ),
  ];
  const pola = p(f, 70, 130, lembut);
  const gelombang = Array.from({ length: 61 })
    .map((_, k) => `${k ? "L" : "M"}${80 + k * 12.7} ${300 + Math.sin(k / 4.8) * 38}`)
    .join(" ");
  return (
    <Kanvas h={h}>
      {kolom.map((x, k) => (
        <g key={x} opacity={p(f, k * 8, k * 8 + 16)}>
          {ikon[k](x)}
          <path d={silang(x, 88, 56)} stroke={c.ink} strokeWidth={5} strokeLinecap="round" pathLength={1} strokeDasharray="1 1" strokeDashoffset={1 - p(f, 25 + k * 10, 45 + k * 10)} fill="none" />
          <Tx x={x} y={180} s={["Menebak tanggal", "Menunjuk tokoh", "Menakut-nakuti"][k]} u={24} w={c.muted} />
        </g>
      ))}
      <Jalur d={gelombang} t={pola} warna={c.ink} tebal={4} />
      <g opacity={p(f, 120, 135)}>
        <circle cx={860} cy={250} r={26} fill={c.ink} />
        <path d={centang(860, 250)} stroke={c.onInk} strokeWidth={4} fill="none" strokeLinecap="round" />
      </g>
      <Tx x={460} y={380} s="Yang dipelajari: pola perubahannya" u={26} bobot={600} w={c.ink} o={p(f, 110, 130)} />
    </Kanvas>
  );
};

// ── Bab 2 · Hadis Jibril ───────────────────────────────────────────────

/** Empat pertanyaan muncul satu per satu dari sebuah majelis (tanpa menggambar sosok mulia). */
const Jibril: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <Jalur d={mihrab(460, h - 10, 230)} t={p(f, 0, 30)} warna={c.line} tebal={3} />
      <circle cx={460} cy={h - 150} r={40 + Math.sin(f / 10) * 3} fill={c.surface} opacity={p(f, 10, 30)} />
      {s.poin!.map((q, k) => {
        const kiri = k % 2 === 0;
        const x = kiri ? 220 : 700;
        const y = 70 + Math.floor(k / 2) * 150;
        const t = p(f, 25 + k * 22, 42 + k * 22);
        const akhir = k === 3;
        return (
          <g key={q} opacity={t} transform={`translate(0 ${(1 - t) * 20})`}>
            <path d={gelembung(x, y, 340, 92)} fill={akhir ? c.ink : c.surface} stroke={akhir ? c.ink : c.line} strokeWidth={2} />
            <Tx x={x - 130} y={y} s={`${k + 1}`} u={26} bobot={600} w={akhir ? c.onInk : c.muted} a="start" />
            <Tx x={x - 100} y={y} s={q.length > 18 ? "Kiamat & tandanya" : q} u={28} bobot={600} w={akhir ? c.onInk : c.ink} a="start" />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Dinukum: empat kotak dirangkul satu garis "agama kalian". */
const Dinukum: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["Islam", "Iman", "Ihsan", "Tanda kiamat"];
  const rangkul = p(f, 40, 90, lembut);
  return (
    <Kanvas h={h}>
      {nama.map((n, k) => {
        const x = 30 + k * 220;
        return (
          <g key={n} opacity={p(f, k * 8, k * 8 + 16)}>
            <rect x={x} y={70} width={200} height={100} rx={20} fill={k === 3 ? c.ink : c.surface} />
            <Tx x={x + 100} y={120} s={n} u={26} bobot={600} w={k === 3 ? c.onInk : c.ink} />
          </g>
        );
      })}
      <Jalur d="M460 20 H30 Q10 20 10 40 V200 Q10 220 30 220 H890 Q910 220 910 200 V40 Q910 20 890 20 Z" t={rangkul} warna={c.ink} tebal={4} />
      <g opacity={p(f, 80, 100)}>
        <rect x={300} y={248} width={320} height={52} rx={26} fill={c.ink} />
        <Ar x={460} y={276} s="دِينَكُمْ · agama kalian" u={30} w={c.onInk} />
      </g>
    </Kanvas>
  );
};

/** Empat tiang menopang atap agama; tiang keempat ditonjolkan. */
const EmpatRukun: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const r = s.rukun!;
  const dasar = h - 150;
  return (
    <Kanvas h={h}>
      <path d={`M40 130 L460 ${10} L880 130 Z`} fill={c.surface} stroke={c.ink} strokeWidth={3} strokeLinejoin="round" opacity={p(f, 95, 120)} transform={`translate(0 ${(1 - p(f, 95, 125)) * -30})`} />
      <Ar x={460} y={92} s="الدِّين" u={44} w={c.ink} o={p(f, 105, 125)} />
      {r.map((b, k) => {
        const x = 110 + k * 233;
        const naik = p(f, 10 + k * 20, 45 + k * 20, lembut);
        const tinggi = (dasar - 140) * naik;
        const sorot = k === 3;
        return (
          <g key={b.nama}>
            <rect x={x - 46} y={dasar - tinggi} width={92} height={tinggi} rx={10} fill={sorot ? c.ink : c.subtle} />
            <g opacity={p(f, 30 + k * 20, 50 + k * 20)}>
              <Ar x={x} y={dasar + 40} s={b.arab} u={32} w={c.ink} />
              <Tx x={x} y={dasar + 92} s={b.nama === "Tanda-tanda kiamat" ? "Tanda kiamat" : b.nama} u={24} bobot={600} w={c.ink} />
              <Tx x={x} y={dasar + 126} s={b.ilmu} u={21} w={c.muted} />
            </g>
          </g>
        );
      })}
      <line x1={30} y1={dasar} x2={890} y2={dasar} stroke={c.ink} strokeWidth={3} opacity={p(f, 0, 10)} />
    </Kanvas>
  );
};

/** Rak kitab: tiga tumpukan tinggi, tumpukan keempat pendek lalu mulai tumbuh. */
const RukunKeempat: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["Fikih", "Akidah", "Tasawuf", "Fikih Tahawwulat"];
  const dasar = h - 50;
  return (
    <Kanvas h={h}>
      {nama.map((n, k) => {
        const x = 120 + k * 228;
        const jumlah = k < 3 ? 9 : Math.round(mix(1, 5, p(f, 80, 140)));
        const tampil = k < 3 ? Math.ceil(p(f, k * 10, 50 + k * 10) * jumlah) : jumlah;
        return (
          <g key={n}>
            {Array.from({ length: tampil }).map((_, j) => (
              <rect key={j} x={x - 70 + (acak(k * 20 + j) - 0.5) * 14} y={dasar - (j + 1) * 27} width={140} height={22} rx={5} fill={k === 3 ? c.ink : j % 2 ? c.subtle : c.surface} stroke={c.line} strokeWidth={1.5} />
            ))}
            <Tx x={x} y={dasar + 30} s={n} u={22} bobot={600} w={c.ink} o={p(f, 10, 30)} />
          </g>
        );
      })}
      <line x1={20} y1={dasar} x2={900} y2={dasar} stroke={c.ink} strokeWidth={3} />
    </Kanvas>
  );
};

// ── Bab 3 · Tetap dan berubah ──────────────────────────────────────────

/** Kiri tiang yang diam; kanan gelombang yang terus bergerak. */
const TetapBerubah: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const kiri = ["Salat dan wudu", "Pokok akidah", "Halal dan haram"];
  const kanan = ["Teknologi", "Media", "Politik", "Ekonomi"];
  return (
    <Kanvas h={h}>
      <rect x={0} y={0} width={440} height={h} rx={24} fill={c.surface} opacity={p(f, 0, 15)} />
      <rect x={480} y={0} width={440} height={h} rx={24} fill={c.surface} opacity={p(f, 8, 23)} />
      <Ar x={220} y={56} s="الثَّوَابِت" u={44} w={c.ink} o={p(f, 5, 20)} />
      <Tx x={220} y={110} s="Yang tetap" u={28} bobot={600} w={c.ink} o={p(f, 5, 20)} />
      <Ar x={700} y={56} s="الْمُتَغَيِّرَات" u={44} w={c.ink} o={p(f, 12, 28)} />
      <Tx x={700} y={110} s="Yang berubah" u={28} bobot={600} w={c.ink} o={p(f, 12, 28)} />
      {kiri.map((k, j) => (
        <g key={k} opacity={p(f, 25 + j * 8, 40 + j * 8)}>
          <rect x={60} y={160 + j * 92} width={320} height={70} rx={12} fill={c.ink} />
          <Tx x={220} y={195 + j * 92} s={k} u={25} w={c.onInk} />
        </g>
      ))}
      {kanan.map((k, j) => {
        const dx = Math.sin((f + j * 25) / 14) * 18;
        const dy = Math.cos((f + j * 17) / 18) * 10;
        return (
          <g key={k} opacity={p(f, 30 + j * 8, 45 + j * 8)} transform={`translate(${dx} ${dy})`}>
            <rect x={560} y={160 + j * 70} width={280} height={54} rx={27} fill={c.bg} stroke={c.ink} strokeWidth={2.5} strokeDasharray="10 8" />
            <Tx x={700} y={187 + j * 70} s={k} u={24} w={c.ink} />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Timbangan: miring ke kaku, miring ke longgar, lalu seimbang. */
const DuaSalah: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const seimbang = p(f, 60, 110, lembut);
  const sudut = Math.sin(f / 12) * 14 * (1 - seimbang);
  const cx = 460;
  const cy = 90;
  return (
    <Kanvas h={h}>
      <path d={`M${cx} ${cy} L${cx - 40} ${h - 20} H${cx + 40} Z`} fill={c.subtle} />
      <g transform={`rotate(${sudut} ${cx} ${cy})`}>
        <line x1={cx - 330} y1={cy} x2={cx + 330} y2={cy} stroke={c.ink} strokeWidth={5} strokeLinecap="round" />
        {[-1, 1].map((sisi) => (
          <g key={sisi} transform={`rotate(${-sudut} ${cx + sisi * 330} ${cy})`}>
            <line x1={cx + sisi * 330} y1={cy} x2={cx + sisi * 330} y2={cy + 50} stroke={c.ink} strokeWidth={2} />
            <rect x={cx + sisi * 330 - 110} y={cy + 50} width={220} height={60} rx={30} fill={c.surface} stroke={c.line} strokeWidth={2} />
            <Tx x={cx + sisi * 330} y={cy + 80} s={sisi < 0 ? "Terlalu kaku" : "Terlalu longgar"} u={23} bobot={600} w={c.ink} />
          </g>
        ))}
      </g>
      <circle cx={cx} cy={cy} r={12} fill={c.ink} />
      <Tx x={cx} y={30} s="Seimbang" u={24} bobot={600} w={c.ink} o={seimbang} />
    </Kanvas>
  );
};

// ── Bab 4 · Wadah dan dua tugas ────────────────────────────────────────

const bejana = (cx: number, atas: number, l: number, t: number) =>
  `M${cx - l / 2} ${atas} C${cx - l / 2 - 20} ${atas + t * 0.5} ${cx - l / 2 + 10} ${atas + t} ${cx - l / 3} ${atas + t} H${cx + l / 3} C${cx + l / 2 - 10} ${atas + t} ${cx + l / 2 + 20} ${atas + t * 0.5} ${cx + l / 2} ${atas}`;

/** Wadah: bejana tergambar, tiga lapis isi mengisi. */
const Wadah: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const cx = 300;
  const atas = 40;
  const l = 360;
  const t = h - 80;
  const isi = ["Ihsan", "Iman", "Islam"];
  return (
    <Kanvas h={h}>
      <defs>
        <clipPath id="isi-wadah">
          <path d={bejana(cx, atas, l, t) + " Z"} />
        </clipPath>
      </defs>
      <g clipPath="url(#isi-wadah)">
        {isi.map((n, k) => {
          const tinggi = (t - 50) / 3;
          const naik = p(f, 30 + (2 - k) * 18, 55 + (2 - k) * 18, lembut);
          const y = atas + 50 + k * tinggi + (1 - naik) * tinggi;
          return <rect key={n} x={cx - l} y={y} width={l * 2} height={tinggi + 4} fill={k === 2 ? c.ink : k === 1 ? c.faint : c.line} />;
        })}
      </g>
      <Jalur d={bejana(cx, atas, l, t)} t={p(f, 0, 30)} warna={c.ink} tebal={5} />
      {isi.map((n, k) => {
        const tinggi = (t - 50) / 3;
        const y = atas + 50 + k * tinggi + tinggi / 2;
        return (
          <g key={n} opacity={p(f, 45 + (2 - k) * 18, 60 + (2 - k) * 18)}>
            <line x1={cx + l / 2 + 10} y1={y} x2={600} y2={y} stroke={c.faint} strokeWidth={2} strokeDasharray="4 6" />
            <Tx x={620} y={y} s={`${n} · isi`} a="start" u={26} bobot={600} w={c.ink} />
          </g>
        );
      })}
      <g opacity={p(f, 100, 120)}>
        <Tx x={620} y={atas + 6} s="Rukun keempat · wadah" a="start" u={26} bobot={600} w={c.ink} />
        <Ar x={740} y={atas + 52} s={s.arab!} u={34} w={c.muted} />
      </g>
    </Kanvas>
  );
};

/** Wadah retak: retakan menjalar, tetes isi jatuh. */
const WadahRetak: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const cx = 460;
  const atas = 20;
  const l = 340;
  const t = h - 90;
  const retak = p(f, 20, 60);
  return (
    <Kanvas h={h}>
      <defs>
        <clipPath id="isi-retak">
          <path d={bejana(cx, atas, l, t) + " Z"} />
        </clipPath>
      </defs>
      <rect x={cx - l} y={atas + 40 + p(f, 50, 140) * 80} width={l * 2} height={t} fill={c.faint} clipPath="url(#isi-retak)" />
      <path d={bejana(cx, atas, l, t)} fill="none" stroke={c.ink} strokeWidth={5} />
      <Jalur d={`M${cx + 140} ${atas + 60} L${cx + 120} ${atas + 110} L${cx + 150} ${atas + 150} L${cx + 125} ${atas + 200}`} t={retak} warna={c.bg} tebal={9} />
      <Jalur d={`M${cx + 140} ${atas + 60} L${cx + 120} ${atas + 110} L${cx + 150} ${atas + 150} L${cx + 125} ${atas + 200}`} t={retak} warna={c.ink} tebal={2.5} />
      {Array.from({ length: 7 }).map((_, k) => {
        const mulai = 55 + k * 12;
        const jatuh = ((f - mulai) % 50) / 50;
        if (f < mulai) return null;
        return <circle key={k} cx={cx + 140 + k * 4} cy={atas + 200 + jatuh * 120} r={7} fill={c.ink} opacity={1 - jatuh} />;
      })}
      <Tx x={cx} y={h - 30} s="Isi yang baik ikut tumpah" u={24} w={c.muted} o={p(f, 60, 80)} />
    </Kanvas>
  );
};

/** Dua tugas: perisai tergambar; gelembung dakwah memancar. */
const DuaTugas: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <Jalur d={perisai(230, 110, 1.6)} t={p(f, 0, 35)} warna={c.ink} tebal={4} />
      <Ar x={230} y={110} s="الثوابت" u={30} w={c.ink} o={p(f, 25, 40)} />
      <Jalur d={gelembung(690, 100, 200, 120)} t={p(f, 20, 55)} warna={c.ink} tebal={4} />
      {[0, 1, 2].map((k) => {
        const r = 80 + ((f * 1.4 + k * 40) % 120);
        return <circle key={k} cx={690} cy={100} r={r} fill="none" stroke={c.faint} strokeWidth={2} opacity={p(f, 50, 60) * (1 - (r - 80) / 120)} />;
      })}
      <Ar x={690} y={100} s="الدعوة" u={30} w={c.ink} o={p(f, 45, 60)} />
    </Kanvas>
  );
};

/** Tiga panah perusak memantul dari perisai. */
const TigaPerusak: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const cx = 460;
  const cy = h / 2;
  const asal = [
    [80, 40],
    [80, h - 40],
    [840, h / 2],
  ];
  return (
    <Kanvas h={h}>
      <path d={perisai(cx, cy, 2.4)} fill={c.ink} opacity={p(f, 0, 20)} />
      <Ar x={cx} y={cy} s="الثوابت" u={36} w={c.onInk} o={p(f, 10, 25)} />
      {asal.map(([x, y], k) => {
        const t = p(f, 20 + k * 15, 50 + k * 15, lembut);
        const pantul = p(f, 50 + k * 15, 70 + k * 15);
        const tx = mix(x, cx + (x - cx) * 0.35, t) + (x - cx) * 0.25 * pantul;
        const ty = mix(y, cy + (y - cy) * 0.35, t) + (y - cy) * 0.25 * pantul;
        const sudut = Math.atan2(cy - y, cx - x);
        return (
          <g key={k} opacity={1 - pantul * 0.6}>
            <line x1={tx - Math.cos(sudut) * 70} y1={ty - Math.sin(sudut) * 70} x2={tx} y2={ty} stroke={c.ink} strokeWidth={4} strokeLinecap="round" />
            <path d={`M${tx} ${ty} l${-Math.cos(sudut - 0.5) * 18} ${-Math.sin(sudut - 0.5) * 18} M${tx} ${ty} l${-Math.cos(sudut + 0.5) * 18} ${-Math.sin(sudut + 0.5) * 18}`} stroke={c.ink} strokeWidth={4} strokeLinecap="round" />
          </g>
        );
      })}
      <Ar x={150} y={22} s="تحريف الغالين" u={26} w={c.muted} o={p(f, 15, 30)} />
      <Ar x={150} y={h - 18} s="انتحال المبطلين" u={26} w={c.muted} o={p(f, 30, 45)} />
      <Ar x={800} y={h / 2 - 50} s="تأويل الجاهلين" u={26} w={c.muted} o={p(f, 45, 60)} />
    </Kanvas>
  );
};

/** Bahasa dakwah: inti pesan tetap; sarananya berganti dari mimbar sampai AI. */
const Bahasa: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const media = s.poin!;
  const langkah = 26;
  const aktif = Math.min(media.length - 1, Math.max(0, Math.floor((f - 20) / langkah)));
  const cx = 460;
  const cy = 150;
  const cincin = 120 + Math.sin(f / 8) * 4;
  return (
    <Kanvas h={h}>
      <circle cx={cx} cy={cy} r={cincin} fill="none" stroke={c.faint} strokeWidth={2} strokeDasharray={`${8 + aktif * 6} 10`} opacity={p(f, 15, 30)} />
      <circle cx={cx} cy={cy} r={84} fill={c.ink} opacity={p(f, 0, 15)} />
      <Ar x={cx} y={cy - 12} s="الرسالة" u={34} w={c.onInk} o={p(f, 5, 20)} />
      <Tx x={cx} y={cy + 30} s="isi tetap" u={20} w={c.onInk} o={p(f, 5, 20)} />
      <line x1={60} y1={h - 110} x2={860} y2={h - 110} stroke={c.line} strokeWidth={3} />
      {media.map((m, k) => {
        const x = 60 + k * 200;
        const nyala = f >= 20 + k * langkah;
        const kini = k === aktif && nyala;
        return (
          <g key={m} opacity={p(f, 15 + k * langkah, 30 + k * langkah) * 0.6 + 0.4}>
            <circle cx={x} cy={h - 110} r={kini ? 18 : 11} fill={nyala ? c.ink : c.bg} stroke={c.ink} strokeWidth={3} />
            <Tx x={x} y={h - 60} s={m} u={kini ? 28 : 24} bobot={kini ? 600 : 400} w={nyala ? c.ink : c.faint} />
            {kini && <line x1={cx} y1={cy + 84} x2={x} y2={h - 128} stroke={c.ink} strokeWidth={2} strokeDasharray="6 6" />}
          </g>
        );
      })}
    </Kanvas>
  );
};

// ── Bab 5 · Dua isyarat ────────────────────────────────────────────────

/** Dua tanda: sosok kecil tumbuh melampaui yang besar; bangunan berlomba naik. */
const DuaTanda: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const balik = p(f, 20, 70, lembut);
  const dasar = h - 40;
  return (
    <Kanvas h={h}>
      <rect x={0} y={0} width={440} height={h} rx={24} fill={c.surface} />
      <rect x={480} y={0} width={440} height={h} rx={24} fill={c.surface} />
      <Orang x={150} y={dasar - 60} u={mix(1.8, 1.2, balik)} w={c.ink} isi={c.subtle} />
      <Orang x={290} y={dasar - 60} u={mix(1, 2, balik)} w={c.ink} isi={c.ink} />
      <line x1={40} y1={dasar} x2={400} y2={dasar} stroke={c.line} strokeWidth={3} />
      {[0, 1, 2, 3, 4].map((k) => {
        const naik = p(f, 15 + ((k * 7) % 5) * 10, 90 + k * 6, lembut);
        const tinggi = mix(30, 90 + ((k * 53) % 90), naik);
        return <rect key={k} x={530 + k * 70} y={dasar - tinggi} width={52} height={tinggi} rx={6} fill={k === 2 ? c.ink : c.subtle} stroke={c.line} />;
      })}
      <line x1={520} y1={dasar} x2={880} y2={dasar} stroke={c.line} strokeWidth={3} />
      <Tx x={220} y={36} s="Tanda pertama" u={22} bobot={600} w={c.muted} />
      <Tx x={700} y={36} s="Tanda kedua" u={22} bobot={600} w={c.muted} />
    </Kanvas>
  );
};

/** Tanda pertama: arah ilmu terbalik antara guru dan murid. */
const TandaIlmu: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const balik = p(f, 40, 80, lembut);
  const y = h / 2 + 50;
  const panah = mix(1, -1, balik);
  return (
    <Kanvas h={h}>
      <Orang x={220} y={y} u={mix(1.8, 1.3, balik)} w={c.ink} isi={c.surface} />
      <Orang x={700} y={y} u={mix(1.2, 1.8, balik)} w={c.ink} isi={c.ink} />
      <g transform={`translate(${220} ${y - 140}) rotate(${balik * 25})`} opacity={1 - balik * 0.4}>
        <Buku x={0} y={0} u={0.9} w={c.ink} isi={c.surface} />
      </g>
      <g transform={`translate(460 ${y - 40}) scale(${panah} 1)`}>
        <line x1={-150} y1={0} x2={150} y2={0} stroke={c.ink} strokeWidth={4} strokeLinecap="round" />
        <path d="M128 -18 L152 0 L128 18" fill="none" stroke={c.ink} strokeWidth={4} strokeLinecap="round" strokeLinejoin="round" />
      </g>
      <Tx x={220} y={h - 10} s="Guru" u={24} bobot={600} w={c.ink} />
      <Tx x={700} y={h - 10} s="Murid" u={24} bobot={600} w={c.ink} />
    </Kanvas>
  );
};

/** Tanda kedua: gedung menjulang, hati di bawahnya mengecil. */
const TandaKuasa: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const dasar = h - 40;
  const naik = p(f, 10, 90, lembut);
  return (
    <Kanvas h={h}>
      {Array.from({ length: 9 }).map((_, k) => {
        const tinggi = mix(40, 90 + acak(k + 11) * 160, naik);
        return (
          <g key={k}>
            <rect x={40 + k * 96} y={dasar - tinggi} width={76} height={tinggi} rx={6} fill={k % 3 === 1 ? c.ink : c.subtle} />
            {Array.from({ length: Math.floor(tinggi / 30) }).map((__, j) => (
              <rect key={j} x={54 + k * 96} y={dasar - tinggi + 12 + j * 30} width={48} height={8} rx={3} fill={k % 3 === 1 ? c.faint : c.surface} />
            ))}
          </g>
        );
      })}
      <line x1={20} y1={dasar} x2={900} y2={dasar} stroke={c.ink} strokeWidth={3} />
      <g transform={`translate(460 ${dasar + 0}) scale(${mix(1, 0.45, naik)})`}>
        <circle r={36} cx={0} cy={-10} fill={c.bg} stroke={c.ink} strokeWidth={4} />
        <path d="M0 6 C-26 -8 -22 -28 -10 -28 C-4 -28 0 -24 0 -18 C0 -24 4 -28 10 -28 C22 -28 26 -8 0 6 Z" fill={c.ink} />
      </g>
    </Kanvas>
  );
};

/** Dua muara: semua titik tanda mengalir ke dua lingkaran ilmu dan kuasa. */
const DuaKeputusan: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const kiri = [250, h - 140];
  const kanan = [670, h - 140];
  return (
    <Kanvas h={h}>
      {Array.from({ length: 40 }).map((_, k) => {
        const tuju = k % 2 ? kanan : kiri;
        const mulai = (k * 3) % 90;
        const t = p(f, mulai, mulai + 50, lembut);
        const x0 = 40 + acak(k) * 840;
        const y0 = 10 + acak(k + 40) * 90;
        return <circle key={k} cx={mix(x0, tuju[0], t)} cy={mix(y0, tuju[1], t)} r={7} fill={c.faint} opacity={1 - t * 0.9} />;
      })}
      {[kiri, kanan].map(([x, y], j) => (
        <g key={j} opacity={p(f, 20, 40)}>
          <circle cx={x} cy={y} r={mix(70, 110, p(f, 40, 130))} fill={c.ink} />
          <Ar x={x} y={y - 12} s={j ? "الحكم" : "العلم"} u={44} w={c.onInk} />
          <Tx x={x} y={y + 40} s={j ? "kekuasaan" : "ilmu"} u={22} w={c.onInk} />
        </g>
      ))}
      <Tx x={250} y={h - 6} s="Siapa yang memegang ilmu" u={24} w={c.ink} bobot={600} o={p(f, 60, 80)} />
      <Tx x={670} y={h - 6} s="Siapa yang memegang kekuasaan" u={24} w={c.ink} bobot={600} o={p(f, 70, 90)} />
    </Kanvas>
  );
};

export const VISUAL_1: Record<string, Vis> = {
  sampul: Sampul,
  zaman: Zaman,
  kompas: Kompas,
  perintis: Perintis,
  fikih: Fikih,
  tahawwul: Tahawwul,
  gabungan: Gabungan,
  definisi: Definisi,
  bukanramalan: BukanRamalan,
  jibril: Jibril,
  dinukum: Dinukum,
  empatrukun: EmpatRukun,
  rukunkeempat: RukunKeempat,
  tetapberubah: TetapBerubah,
  duasalah: DuaSalah,
  wadah: Wadah,
  wadahretak: WadahRetak,
  duatugas: DuaTugas,
  tigaperusak: TigaPerusak,
  bahasa: Bahasa,
  duatanda: DuaTanda,
  tandailmu: TandaIlmu,
  tandakuasa: TandaKuasa,
  duakeputusan: DuaKeputusan,
};

export { Kanvas, Jarum };
