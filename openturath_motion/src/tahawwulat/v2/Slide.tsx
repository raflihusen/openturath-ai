import React from "react";
import { AbsoluteFill, Img, staticFile, useCurrentFrame } from "remotion";
import { HURUF } from "../../tema";
import {
  BAB,
  ISI,
  LEBAR,
  MALAM,
  Muncul,
  SLIDES,
  T,
  TINGGI,
  TEPI,
  KERTAS,
  acak,
  arabStyle,
  lembut,
  mix,
  p,
  type Pal,
  type Slide,
} from "./kit";
import { EmpatTiang, GarisWaktu, Mobil, Orang, Tuas, Wadah, Zaman } from "./motif";

// ── Kerangka slide ───────────────────────────────────────────────────────

export type VisProps = { s: Slide; c: Pal; h: number };

const Kepala: React.FC<{ s: Slide; i: number; c: Pal; gelap: boolean }> = ({ s, i, c, gelap }) => {
  const f = useCurrentFrame();
  const bab = BAB[s.bab];
  return (
    <div style={{ opacity: p(f, 0, 14) }}>
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          fontFamily: HURUF.ui,
          fontWeight: 600,
          fontSize: 22,
          letterSpacing: 3,
          color: c.muted,
        }}
      >
        <span>{s.bab === 0 ? "PENGANTAR" : `BAB ${String(s.bab).padStart(2, "0")} · ${bab.judul.toUpperCase()}`}</span>
        <span style={{ fontVariantNumeric: "tabular-nums" }}>
          {i + 1} / {SLIDES.length}
        </span>
      </div>
      <div style={{ display: "flex", gap: 5, marginTop: 16 }}>
        {BAB.map((b) => (
          <div
            key={b.no}
            style={{
              flex: 1,
              height: 3,
              borderRadius: 2,
              background: b.no <= s.bab ? (gelap ? c.ink : c.ink) : c.line,
              opacity: b.no < s.bab ? 0.45 : 1,
            }}
          />
        ))}
      </div>
    </div>
  );
};

const Kartu: React.FC<{ c: Pal; children: React.ReactNode; pad?: string }> = ({ c, children, pad = "24px 28px" }) => (
  <div style={{ background: c.surface, borderRadius: 22, padding: pad }}>{children}</div>
);

/** Ibarah Arab tampil utuh, langsung terbaca. */
const Ibarah: React.FC<{ s: Slide; c: Pal; mulai: number; ukuran?: number }> = ({ s, c, mulai, ukuran }) => {
  if (!s.ibarah) return null;
  const u = ukuran ?? (s.ibarah.length > 150 ? 34 : s.ibarah.length > 90 ? 38 : 44);
  return (
    <Muncul pada={mulai}>
      <Kartu c={c} pad="24px 30px 20px">
        <div style={{ ...arabStyle(u, c.ink) }}>{s.ibarah}</div>
        {s.sumber && (
          <div
            style={{
              marginTop: 14,
              paddingTop: 12,
              borderTop: `1.5px solid ${c.subtle}`,
              fontFamily: HURUF.ui,
              fontWeight: 600,
              fontSize: 20,
              letterSpacing: 0.4,
              color: c.muted,
            }}
          >
            {s.sumber}
          </div>
        )}
      </Kartu>
    </Muncul>
  );
};

const Poin: React.FC<{ s: Slide; c: Pal; mulai: number }> = ({ s, c, mulai }) => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 12 }}>
    {s.poin!.map((x, k) => (
      <Muncul key={x} pada={mulai + k * 7} geser={0}>
        <div
          style={{
            border: `2px solid ${c.line}`,
            borderRadius: 999,
            padding: "10px 22px",
            fontFamily: HURUF.ui,
            fontSize: 26,
            fontWeight: 600,
            color: c.ink,
            background: c.surface,
          }}
        >
          {x}
        </div>
      </Muncul>
    ))}
  </div>
);

const Dua: React.FC<{ s: Slide; c: Pal; mulai: number }> = ({ s, c, mulai }) => (
  <div style={{ display: "flex", gap: 18 }}>
    {[s.kiri!, s.kanan!].map((k, j) => (
      <Muncul key={j} pada={mulai + j * 10} style={{ flex: 1 }}>
        <Kartu c={c}>
          <div style={{ ...arabStyle(38, c.ink, 1.5) }}>{k.arab}</div>
          <div style={{ fontFamily: HURUF.ui, fontWeight: 600, fontSize: 29, color: c.ink, marginTop: 4 }}>{k.judul}</div>
          {k.isi.map((x) => (
            <div key={x} style={{ fontFamily: HURUF.ui, fontSize: 24, lineHeight: 1.4, color: c.muted, marginTop: 8 }}>
              {x}
            </div>
          ))}
        </Kartu>
      </Muncul>
    ))}
  </div>
);

const Daftar: React.FC<{ s: Slide; c: Pal; mulai: number }> = ({ s, c, mulai }) => (
  <Muncul pada={mulai}>
    <Kartu c={c} pad="4px 26px">
      {s.rukun!.map((r, k) => (
        <div
          key={r.nama}
          style={{
            display: "flex",
            alignItems: "center",
            gap: 18,
            padding: "13px 0",
            borderTop: k ? `1.5px solid ${c.subtle}` : "none",
          }}
        >
          <div
            style={{
              flex: "0 0 46px",
              height: 46,
              borderRadius: 10,
              background: c.subtle,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontFamily: HURUF.ui,
              fontWeight: 600,
              fontSize: 20,
              color: c.ink,
            }}
          >
            {String(k + 1).padStart(2, "0")}
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: HURUF.ui, fontWeight: 600, fontSize: 27, color: c.ink }}>{r.nama}</div>
            <div style={{ fontFamily: HURUF.ui, fontSize: 21, lineHeight: 1.35, color: c.muted }}>{r.ilmu}</div>
          </div>
          <div style={{ ...arabStyle(28, c.ink, 1.4) }}>{r.arab}</div>
        </div>
      ))}
    </Kartu>
  </Muncul>
);

/** Kanvas animasi mengisi sisa ruang; tinggi tata letak tetap 470 agar proporsinya tetap. */
const AbsVis: React.FC<{ Vis: React.FC<VisProps>; s: Slide; c: Pal }> = ({ Vis, s, c }) => (
  <div style={{ position: "absolute", inset: 0 }}>
    <Vis s={s} c={c} h={470} />
  </div>
);

/** Slide umum: kepala, judul, animasi, kalimat inti, bukti. */
export const SlideUmum: React.FC<{ indeks: number; Vis?: React.FC<VisProps>; tinggiVis?: number; lead?: number }> = ({
  indeks,
  Vis,
  tinggiVis = 430,
  lead = 80,
}) => {
  const f = useCurrentFrame();
  const s = SLIDES[indeks];
  const gelap = s.bab === 0 || s.bab === 9;
  const c = gelap ? MALAM : KERTAS;
  const judulT = p(f, 4, 28);
  return (
    <AbsoluteFill style={{ background: c.bg, padding: `52px ${TEPI}px 46px`, boxSizing: "border-box", display: "flex", flexDirection: "column" }}>
      <Kepala s={s} i={indeks} c={c} gelap={gelap} />
      <div
        style={{
          marginTop: 30,
          fontFamily: HURUF.serif,
          fontSize: 62,
          lineHeight: 1.12,
          letterSpacing: -0.8,
          color: c.ink,
          opacity: judulT,
          transform: `translateY(${(1 - judulT) * 26}px)`,
        }}
      >
        <T s={s.judul} />
      </div>
      {Vis && (
        <div style={{ flex: 1, position: "relative", minHeight: 0, marginTop: 18 }}>
          <AbsVis Vis={Vis} s={s} c={c} />
        </div>
      )}
      <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "flex-end", gap: 22, minHeight: 0 }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 22 }}>
        {s.kunci && (
          <Muncul pada={lead}>
            <div style={{ display: "flex", gap: 22 }}>
              <div style={{ flex: "0 0 5px", borderRadius: 3, background: c.ink }} />
              <div style={{ fontFamily: HURUF.serif, fontSize: 38, lineHeight: 1.3, color: c.ink }}>
                <T s={s.kunci} />
              </div>
            </div>
          </Muncul>
        )}
        {s.poin && <Poin s={s} c={c} mulai={lead + 10} />}
        {s.kiri && s.kanan && <Dua s={s} c={c} mulai={lead + 10} />}
        {s.rukun && <Daftar s={s} c={c} mulai={lead + 10} />}
        {s.ibarah && <Ibarah s={s} c={c} mulai={lead + 14} />}
        {!s.ibarah && s.sumber && (
          <Muncul pada={lead + 20}>
            <div style={{ fontFamily: HURUF.ui, fontWeight: 600, fontSize: 20, color: c.muted }}>{s.sumber}</div>
          </Muncul>
        )}
      </div>
      </div>
    </AbsoluteFill>
  );
};


const Kanvas: React.FC<{ h: number; w?: number; children: React.ReactNode }> = ({ h, w = ISI, children }) => (
  <svg width={w} height={h} viewBox={`0 0 ${w} ${h}`} style={{ position: "absolute", inset: 0, overflow: "visible" }}>
    {children}
  </svg>
);

const Tx: React.FC<{
  x: number;
  y: number;
  s: string;
  u?: number;
  w: string;
  bobot?: number;
  a?: "start" | "middle" | "end";
  o?: number;
  serif?: boolean;
}> = ({ x, y, s, u = 24, w, bobot = 400, a = "middle", o = 1, serif }) => (
  <text x={x} y={y} fontFamily={serif ? HURUF.serif : HURUF.ui} fontSize={u} fontWeight={bobot} fill={w} textAnchor={a} opacity={o} dominantBaseline="middle">
    {s}
  </text>
);

const Ar: React.FC<{ x: number; y: number; s: string; u?: number; w: string; a?: "start" | "middle" | "end"; o?: number }> = ({
  x,
  y,
  s,
  u = 32,
  w,
  a = "middle",
  o = 1,
}) => (
  <text x={x} y={y} fontFamily={HURUF.arab} fontSize={u} fill={w} textAnchor={a === "end" ? "start" : a === "start" ? "end" : "middle"} direction="rtl" opacity={o} dominantBaseline="middle">
    {s}
  </text>
);

// ── Bab 0 ────────────────────────────────────────────────────────────────

const Sampul: React.FC<{ c: Pal }> = ({ c }) => {
  const f = useCurrentFrame();
  const s = SLIDES[0];
  return (
    <AbsoluteFill style={{ background: c.bg }}>
      <Kanvas h={TINGGI} w={LEBAR}>
        <EmpatTiang
          x={396}
          dasar={760}
          tinggi={330}
          c={c}
          naik={[0, 1, 2, 3].map((k) => p(f, 10 + k * 12, 45 + k * 12, lembut))}
          pucat={[false, false, false, true]}
          lebar={58}
          jarak={92}
        />
        <path d={`M330 430 H750`} stroke={c.line} strokeWidth={3} opacity={p(f, 60, 80)} />
        <Tx x={540} y={398} s="AGAMA" u={20} w={c.muted} bobot={600} o={p(f, 60, 80)} />
      </Kanvas>
      <div style={{ position: "absolute", left: 0, right: 0, top: 66, display: "flex", justifyContent: "center", opacity: p(f, 20, 44) }}>
        <Img src={staticFile("logo_putih.png")} style={{ width: 60, height: 60 }} />
      </div>
      <div style={{ position: "absolute", left: 70, right: 70, top: 810, textAlign: "center" }}>
        <div style={{ ...arabStyle(78, c.ink, 1.4), opacity: p(f, 70, 96) }}>{s.arab}</div>
        <div style={{ fontFamily: HURUF.serif, fontSize: 66, lineHeight: 1.1, color: c.ink, marginTop: 8, opacity: p(f, 88, 112) }}>
          {s.judul}
        </div>
        <div style={{ fontFamily: HURUF.ui, fontSize: 30, lineHeight: 1.4, color: c.muted, marginTop: 20, opacity: p(f, 110, 134) }}>{s.sub}</div>
        <div style={{ fontFamily: HURUF.ui, fontWeight: 600, fontSize: 20, letterSpacing: 3, color: c.faint, marginTop: 40, opacity: p(f, 130, 152) }}>
          {SLIDES.length} SLIDE · 14 BAB
        </div>
      </div>
    </AbsoluteFill>
  );
};

/** 0.2 Orang menunduk di depan layar berita. */
const Takut: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const tunduk = p(f, 30, 90);
  return (
    <Kanvas h={h}>
      <rect x={180} y={30} width={560} height={330} rx={20} fill={c.surface} stroke={c.line} strokeWidth={3} />
      {Array.from({ length: 14 }).map((_, k) => {
        const t = p(f, 6 + k * 3, 20 + k * 3);
        const y = 60 + k * 21;
        const l = 300 + acak(k) * 220;
        return <rect key={k} x={210} y={y} width={l * t} height={11} rx={5} fill={k % 3 === 0 ? c.ink : c.faint} />;
      })}
      <rect x={210} y={60} width={120} height={96} rx={8} fill={c.subtle} />
      <Orang x={120} y={h - 20} skala={1.1} c={c} miring={tunduk * 45} />
    </Kanvas>
  );
};

/** 0.3 Layar sama, tetapi orang menegak dan kembali ke sekitarnya. */
const Justru: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const bangkit = p(f, 40, 100, lembut);
  return (
    <Kanvas h={h}>
      <g opacity={1 - bangkit * 0.75}>
        <rect x={180} y={30} width={560} height={330} rx={20} fill={c.surface} stroke={c.line} strokeWidth={3} />
        {Array.from({ length: 14 }).map((_, k) => (
          <rect key={k} x={210} y={60 + k * 21} width={300 + acak(k) * 220} height={11} rx={5} fill={k % 3 === 0 ? c.muted : c.line} />
        ))}
      </g>
      <circle cx={460} cy={190} r={mix(0, 150, bangkit)} fill="none" stroke={c.ink} strokeWidth={4} opacity={bangkit} />
      <Orang x={330} y={h - 30} skala={1} c={c} miring={mix(45, 0, bangkit)} />
      {[0, 1, 2].map((k) => (
        <Orang key={k} x={520 + k * 70} y={h - 30} skala={0.8} c={c} />
      ))}
    </Kanvas>
  );
};

// ── Bab 1 ────────────────────────────────────────────────────────────────

const MobilJalan: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const x = mix(-120, 520, p(f, 0, 90, lembut));
  return (
    <Kanvas h={h}>
      <line x1={0} y1={h - 40} x2={ISI} y2={h - 40} stroke={c.ink} strokeWidth={4} />
      {Array.from({ length: 12 }).map((_, k) => (
        <line key={k} x1={(k * 90 + f * 4) % ISI} y1={h - 22} x2={((k * 90 + f * 4) % ISI) + 42} y2={h - 22} stroke={c.faint} strokeWidth={4} strokeLinecap="round" />
      ))}
      <Mobil x={x} y={h - 92} skala={1} c={c} tombol={0} />
    </Kanvas>
  );
};

const MobilLupa: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <line x1={0} y1={h - 40} x2={ISI} y2={h - 40} stroke={c.ink} strokeWidth={4} />
      {[0, 1, 2].map((k) => (
        <g key={k} opacity={p(f, k * 40, k * 40 + 24)}>
          <Mobil x={150 + k * 260} y={h - 92} skala={0.62} c={c} tombol={0} label={k === 0} />
          {k > 0 && (
            <g>
              <rect x={150 + k * 260 - 40} y={h - 210} width={80} height={30} rx={8} fill={c.surface} stroke={c.line} strokeWidth={2} strokeDasharray="5 5" />
              <Tx x={150 + k * 260} y={h - 195} s="?" u={20} w={c.faint} />
            </g>
          )}
        </g>
      ))}
      <g opacity={p(f, 110, 130)}>
        <rect x={250} y={30} width={420} height={70} rx={14} fill={c.subtle} />
        <Tx x={460} y={65} s="Fiturnya terlupakan" u={26} w={c.ink} bobot={600} />
      </g>
    </Kanvas>
  );
};

const MobilLumpur: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nyala = p(f, 60, 80);
  const keluar = p(f, 100, 150, lembut);
  return (
    <Kanvas h={h}>
      <rect x={0} y={h - 120} width={ISI} height={120} rx={20} fill={c.subtle} />
      {Array.from({ length: 26 }).map((_, k) => (
        <ellipse key={k} cx={acak(k) * ISI} cy={h - 100 + acak(k + 40) * 80} rx={18 + acak(k + 9) * 26} ry={8} fill={c.line} />
      ))}
      <Mobil x={mix(260, 640, keluar)} y={h - 100 - keluar * 90} skala={0.95} c={c} tombol={nyala} miring={-10 * (1 - keluar)} />
      <g opacity={p(f, 70, 90)}>
        <Tx x={460} y={40} s="Penggerak keempat menyala" u={26} w={c.ink} bobot={600} />
      </g>
      <g opacity={p(f, 150, 170)}>
        <Tx x={460} y={90} s="= rukun keempat agama" u={24} w={c.muted} />
      </g>
    </Kanvas>
  );
};

// ── Bab 2 ────────────────────────────────────────────────────────────────

const Tamu: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      {Array.from({ length: 8 }).map((_, k) => {
        const a = (k / 8) * Math.PI * 2;
        return <circle key={k} cx={460 + Math.cos(a) * 210} cy={h / 2 + 20 + Math.sin(a) * 96} r={17} fill="none" stroke={c.muted} strokeWidth={3} opacity={p(f, 0, 20) * 0.7} />;
      })}
      <circle cx={460} cy={h / 2 + 10} r={mix(0, 54, p(f, 30, 70, lembut))} fill={c.surface} stroke={c.ink} strokeWidth={4} />
      {Array.from({ length: 12 }).map((_, k) => {
        const a = (k / 12) * Math.PI * 2 + f / 60;
        return <line key={k} x1={460 + Math.cos(a) * 62} y1={h / 2 + 10 + Math.sin(a) * 62} x2={460 + Math.cos(a) * 86} y2={h / 2 + 10 + Math.sin(a) * 86} stroke={c.ink} strokeWidth={2.5} opacity={p(f, 45, 60)} />;
      })}
      <Tx x={460} y={h - 20} s="Tamu tak dikenal, pakaian sangat putih" u={23} w={c.muted} o={p(f, 60, 80)} />
    </Kanvas>
  );
};

const EmpatPertanyaan: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["Islam", "Iman", "Ihsan", "Kiamat & tandanya"];
  return (
    <Kanvas h={h}>
      {nama.map((n, k) => {
        const t = p(f, 8 + k * 18, 26 + k * 18);
        const x = 60 + k * 215;
        return (
          <g key={n} opacity={t} transform={`translate(0 ${(1 - t) * 24})`}>
            <rect x={x} y={70} width={190} height={130} rx={18} fill={c.surface} stroke={c.line} strokeWidth={2.5} />
            <circle cx={x + 30} cy={98} r={16} fill={c.ink} />
            <Tx x={x + 30} y={99} s={`${k + 1}`} u={18} w={c.onInk} bobot={600} />
            <Tx x={x + 60} y={99} s={n.length > 12 ? "Kiamat &" : n} u={22} w={c.ink} bobot={600} a="start" />
            {n.length > 12 && <Tx x={x + 60} y={178} s="tandanya" u={22} w={c.ink} bobot={600} a="start" />}
          </g>
        );
      })}
      <g opacity={p(f, 90, 110)}>
        <rect x={60} y={230} width={800} height={54} rx={27} fill={c.subtle} />
        <Tx x={460} y={257} s="Satu majelis, satu penanya, empat pertanyaan" u={24} w={c.ink} bobot={600} />
      </g>
    </Kanvas>
  );
};

const DuaJawaban: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <g>
        <rect x={30} y={30} width={390} height={190} rx={18} fill={c.surface} stroke={c.line} strokeWidth={2.5} />
        <Tx x={225} y={68} s="KAPAN KIAMAT?" u={20} w={c.muted} bobot={600} />
        <rect x={30 + 62} y={110} width={266} height={86} rx={10} fill={c.ink} opacity={p(f, 30, 60)} />
        <Tx x={225} y={153} s="Hanya Allah yang tahu" u={25} w={c.onInk} bobot={600} o={p(f, 40, 60)} />
      </g>
      <g opacity={p(f, 20, 40)}>
        <rect x={500} y={30} width={390} height={190} rx={18} fill={c.surface} stroke={c.ink} strokeWidth={3} />
        <Tx x={695} y={68} s="APA TANDANYA?" u={20} w={c.ink} bobot={600} />
        <rect x={548} y={104} width={140} height={96} rx={10} fill={c.ink} opacity={p(f, 70, 90)} />
        <rect x={700} y={104} width={140} height={96} rx={10} fill={c.ink} opacity={p(f, 85, 105)} />
        <Tx x={695} y={250} s="Dijawab dengan jelas" u={22} w={c.muted} bobot={600} o={p(f, 90, 110)} />
      </g>
    </Kanvas>
  );
};

const AgamaKalian: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const lingkar = p(f, 30, 80, lembut);
  return (
    <Kanvas h={h}>
      {["Islam", "Iman", "Ihsan", "Kiamat"].map((n, k) => (
        <g key={n} opacity={p(f, k * 8, k * 8 + 16)}>
          <rect x={40 + k * 210} y={70} width={180} height={84} rx={14} fill={k === 3 ? c.ink : c.surface} stroke={k === 3 ? c.ink : c.line} strokeWidth={2} />
          <Tx x={130 + k * 210} y={112} s={n} u={24} w={k === 3 ? c.onInk : c.ink} bobot={600} />
        </g>
      ))}
      <Jalur3 d={`M40 40 H830 V190 H40 Z`} t={lingkar} warna={c.ink} />
      <g opacity={p(f, 70, 90)}>
        <rect x={285} y={220} width={350} height={56} rx={28} fill={c.ink} />
        <Ar x={460} y={248} s="دِينَكُمْ · agama kalian" u={30} w={c.onInk} />
      </g>
    </Kanvas>
  );
};

const Jalur3: React.FC<{ d: string; t: number; warna: string }> = ({ d, t, warna }) => (
  <path d={d} fill="none" stroke={warna} strokeWidth={4} strokeLinejoin="round" pathLength={1} strokeDasharray="1 1" strokeDashoffset={1 - t} />
);

const EmpatRukunVis: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const dasar = h - 40;
  return (
    <Kanvas h={h}>
      <EmpatTiang x={210} dasar={dasar} tinggi={260} c={c} naik={[0, 1, 2, 3].map((k) => p(f, 10 + k * 18, 45 + k * 18, lembut))} pucat={[false, false, false, true]} lebar={72} jarak={170} />
      <path d={`M150 ${dasar - 280} H770`} stroke={c.line} strokeWidth={3} opacity={p(f, 90, 110)} />
      <Tx x={460} y={dasar - 306} s="AGAMA" u={20} w={c.muted} bobot={600} o={p(f, 95, 115)} />
      <line x1={110} y1={dasar} x2={810} y2={dasar} stroke={c.ink} strokeWidth={3} />
      <Tx x={460} y={dasar + 40} s="Tiang keempat masih ada, tetapi paling terabaikan" u={23} w={c.muted} o={p(f, 110, 130)} />
    </Kanvas>
  );
};

const Bukhari: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const kata = ["iman", "Islam", "ihsan", "ilmu kiamat"];
  return (
    <Kanvas h={h}>
      <rect x={180} y={30} width={560} height={40} rx={8} fill={c.subtle} />
      <rect x={180} y={70} width={560} height={h - 110} rx={14} fill={c.surface} stroke={c.line} strokeWidth={2.5} />
      <Tx x={460} y={110} s="Judul bab dalam Sahih al-Bukhari" u={22} w={c.muted} bobot={600} o={p(f, 10, 30)} />
      {kata.map((k, i) => (
        <g key={k} opacity={p(f, 30 + i * 16, 48 + i * 16)}>
          <rect x={230} y={150 + i * 56} width={460} height={40} rx={20} fill={i === 3 ? c.ink : c.subtle} />
          <Tx x={460} y={171 + i * 56} s={k} u={23} w={i === 3 ? c.onInk : c.ink} bobot={600} />
        </g>
      ))}
      <Tx x={460} y={h - 26} s="… فجعل ذلك كله دينا — semuanya disebut agama" u={22} w={c.ink} bobot={600} o={p(f, 110, 130)} />
    </Kanvas>
  );
};

// ── Bab 3 ────────────────────────────────────────────────────────────────

const BedaKiamat: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <GarisWaktu x={60} y={h / 2} lebar={h * 1.9} c={c} tirai={0.72} tampilTitik={9} titik={Array.from({ length: 9 }).map((_, k) => ({ pos: 0.06 + k * 0.07 }))} />
      <g opacity={p(f, 40, 70)}>
        <rect x={h * 1.9 + 30} y={h / 2 - 56} width={120} height={112} rx={12} fill={c.ink} />
        <Ar x={h * 1.9 + 90} y={h / 2} s="الساعة" u={30} w={c.onInk} />
      </g>
      <Tx x={h * 0.75} y={h / 2 - 70} s="DUNIA: tanda-tanda" u={22} w={c.ink} bobot={600} o={p(f, 20, 40)} />
      <Tx x={h * 1.9 + 90} y={h / 2 + 86} s="kiamat" u={22} w={c.muted} o={p(f, 50, 70)} />
    </Kanvas>
  );
};

const RukunTerpisah: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <rect x={0} y={20} width={860} height={h - 60} rx={20} fill={c.surface} />
      <line x1={430} y1={20} x2={430} y2={h - 40} stroke={c.line} strokeWidth={3} />
      <Tx x={215} y={70} s="SEKARANG" u={20} w={c.muted} bobot={600} />
      <Tx x={645} y={70} s="SETELAH DUNIA BERAKHIR" u={20} w={c.muted} bobot={600} />
      <Ar x={215} y={150} s="علاماتها" u={40} w={c.ink} o={p(f, 20, 40)} />
      <Tx x={215} y={205} s="bisa dipelajari" u={23} w={c.ink} o={p(f, 30, 50)} />
      <Ar x={645} y={150} s="الساعة" u={40} w={c.ink} o={p(f, 40, 60)} />
      <Tx x={645} y={205} s="waktunya hanya Allah yang tahu" u={22} w={c.muted} o={p(f, 50, 70)} />
    </Kanvas>
  );
};

// ── Bab 4 ────────────────────────────────────────────────────────────────

const TetapVis: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <Zaman x={120} y={h - 40} skala={1.1} c={c} jenis={Math.floor(f / 40)} />
      <Zaman x={isiC(h)} y={h - 40} skala={1.1} c={c} jenis={Math.floor(f / 40) + 1} />
      <EmpatTiang x={250} dasar={h - 100} tinggi={250} c={c} naik={[1, 1, 1, p(f, 30, 70)]} pucat={[false, false, false, true]} lebar={64} jarak={130} />
      <Tx x={460} y={30} s="latar zaman berganti, tiga tiang tetap" u={23} w={c.muted} o={p(f, 20, 40)} />
    </Kanvas>
  );
};

const isiC = (h: number) => 800;

const BerubahVis: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const baca = p(f, 30, 90);
  return (
    <Kanvas h={h}>
      {[0, 1, 2, 3].map((k) => (
        <g key={k} opacity={k === Math.min(3, Math.floor(baca * 4)) ? 1 : 0.35}>
          <Zaman x={120 + k * 215} y={h - 60} skala={1} c={c} jenis={k} />
        </g>
      ))}
      <line x1={40} y1={h - 130} x2={820} y2={h - 130} stroke={c.line} strokeWidth={3} strokeDasharray="8 8" />
      <g opacity={baca}>
        <path d={`M${mix(120, 760, baca)} ${h - 130} v-70`} stroke={c.ink} strokeWidth={3} />
        <circle cx={mix(120, 760, baca)} cy={h - 200} r={16} fill={c.ink} />
      </g>
      <Tx x={460} y={40} s="nash menjelaskan tiap perubahan" u={23} w={c.muted} o={p(f, 40, 60)} />
    </Kanvas>
  );
};

const BukanAgama: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <rect x={30} y={40} width={380} height={h - 130} rx={20} fill={c.surface} />
      <rect x={450} y={40} width={380} height={h - 130} rx={20} fill={c.surface} />
      <Tx x={220} y={90} s="agama mengikuti zaman" u={22} w={c.muted} bobot={600} />
      <path d={`M170 ${h / 2} L270 ${h / 2 - 50} M270 ${h / 2} L170 ${h / 2 - 50}`} stroke={c.ink} strokeWidth={6} strokeLinecap="round" opacity={p(f, 20, 40)} />
      <Tx x={640} y={90} s="zaman ditimbang agama" u={22} w={c.ink} bobot={600} />
      <line x1={560} y1={h / 2 - 25} x2={720} y2={h / 2 - 25} stroke={c.ink} strokeWidth={4} opacity={p(f, 40, 60)} />
      <circle cx={640} cy={h / 2 - 25} r={12} fill={c.ink} opacity={p(f, 40, 60)} />
      <path d={`M615 ${h / 2 + 30} L628 ${h / 2 + 44} L662 ${h / 2 + 4}`} stroke={c.ink} strokeWidth={6} fill="none" strokeLinecap="round" opacity={p(f, 60, 80)} />
    </Kanvas>
  );
};

// ── Bab 5 ────────────────────────────────────────────────────────────────

const TigaNama: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["علم آخر الزمان", "علم علامات الساعة", "فقه التحولات"];
  const nyala = Math.min(2, Math.floor(p(f, 30, 120) * 3));
  return (
    <Kanvas h={h}>
      <rect x={330} y={10} width={260} height={90} rx={16} fill={c.surface} stroke={c.ink} strokeWidth={3} />
      <Tx x={460} y={55} s="satu ilmu" u={26} w={c.ink} bobot={600} />
      {nama.map((n, k) => {
        const x = 225 + k * 235;
        return (
          <g key={n} opacity={nyala === k ? 1 : 0.28}>
            <Jalur3 d={`M460 100 L${x} 170`} t={p(f, 10 + k * 8, 40 + k * 8)} warna={c.line} />
            <rect x={x - 108} y={178} width={216} height={70} rx={35} fill={nyala === k ? c.ink : c.surface} stroke={nyala === k ? c.ink : c.line} strokeWidth={2} />
            <Ar x={x} y={214} s={n} u={25} w={nyala === k ? c.onInk : c.muted} />
          </g>
        );
      })}
      <Tx x={460} y={h - 10} s="tiga papan nama untuk satu ilmu" u={23} w={c.muted} o={p(f, 90, 110)} />
    </Kanvas>
  );
};

const ArtiNama: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <rect x={30} y={30} width={380} height={h - 120} rx={20} fill={c.surface} />
      <Ar x={220} y={110} s="فقه" u={54} w={c.ink} />
      <Tx x={220} y={190} s="paham sampai ke dasar" u={24} w={c.ink} bobot={600} />
      {[0, 1, 2].map((k) => (
        <line key={k} x1={120} y1={230 + k * 40} x2={320} y2={230 + k * 40} stroke={c.line} strokeWidth={k === 2 ? 5 : 3} opacity={p(f, 20 + k * 10, 40 + k * 10)} />
      ))}
      <rect x={450} y={30} width={380} height={h - 120} rx={20} fill={c.surface} />
      <Ar x={640} y={110} s="تحولات" u={54} w={c.ink} />
      <Tx x={640} y={190} s="perubahan-perubahan" u={24} w={c.ink} bobot={600} />
      {[0, 1, 2, 3, 4].map((k) => {
        const t = p(f, 30 + k * 12, 50 + k * 12);
        return (
          <g key={k} opacity={t}>
            {k > 0 && <line x1={502 + (k - 1) * 68} y1={272} x2={530 + k * 68} y2={272} stroke={c.ink} strokeWidth={2.5} />}
            {k % 2 === 0 ? <circle cx={516 + k * 68} cy={272} r={15} fill={c.surface} stroke={c.ink} strokeWidth={3} /> : <rect x={501 + k * 68} y={257} width={30} height={30} rx={4} fill={c.surface} stroke={c.ink} strokeWidth={3} />}
          </g>
        );
      })}
    </Kanvas>
  );
};

const DefinisiVis: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const keping = ["berdasar wahyu", "dari ketetapan Allah", "perubahan punya hukum", "ilmu, budaya, peristiwa", "sampai kiamat"];
  return (
    <Kanvas h={h}>
      <line x1={40} y1={150} x2={820} y2={150} stroke={c.ink} strokeWidth={3} />
      {keping.map((k, i) => {
        const t = p(f, 20 + i * 16, 44 + i * 16);
        const x = 84 + i * 188;
        return (
          <g key={k} opacity={t}>
            <circle cx={x} cy={150} r={11} fill={c.ink} />
            <rect x={x - 86} y={176 + (i % 2) * 30} width={172} height={84} rx={14} fill={c.surface} stroke={c.line} strokeWidth={2} />
            <Tx x={x} y={208 + (i % 2) * 30} s={k.split(" ").slice(0, 2).join(" ")} u={19} w={c.ink} bobot={600} />
            {k.split(" ").length > 2 && <Tx x={x} y={234 + (i % 2) * 30} s={k.split(" ").slice(2).join(" ")} u={19} w={c.ink} bobot={600} />}
          </g>
        );
      })}
    </Kanvas>
  );
};

const PolaVis: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const susun = p(f, 30, 100, lembut);
  return (
    <Kanvas h={h}>
      {Array.from({ length: 60 }).map((_, k) => {
        const acakX = acak(k) * 820;
        const acakY = 30 + acak(k + 70) * (h - 80);
        const baris = Math.floor(k / 12);
        const kol = k % 12;
        const x = mix(acakX, 90 + kol * 62, susun);
        const y = mix(acakY, 80 + baris * 70, susun);
        return <circle key={k} cx={x} cy={y} r={7} fill={c.ink} opacity={0.75} />;
      })}
    </Kanvas>
  );
};

export const VIS: Record<string, { Vis?: React.FC<VisProps>; tinggi?: number; lead?: number }> = {
  takut: { Vis: Takut, tinggi: 400 },
  justru: { Vis: Justru, tinggi: 400 },
  mobil: { Vis: MobilJalan, tinggi: 330 },
  lupa: { Vis: MobilLupa, tinggi: 330 },
  lumpur: { Vis: MobilLumpur, tinggi: 380 },
  tamu: { Vis: Tamu, tinggi: 360 },
  "empat-pertanyaan": { Vis: EmpatPertanyaan, tinggi: 330 },
  "dua-jawaban": { Vis: DuaJawaban, tinggi: 320 },
  "agama-kalian": { Vis: AgamaKalian, tinggi: 300 },
  "empat-rukun": { Vis: EmpatRukunVis, tinggi: 380, lead: 110 },
  bukhari: { Vis: Bukhari, tinggi: 360 },
  beda: { Vis: BedaKiamat, tinggi: 300 },
  "rukun-terpisah": { Vis: RukunTerpisah, tinggi: 330 },
  tetap: { Vis: TetapVis, tinggi: 400 },
  berubah: { Vis: BerubahVis, tinggi: 400 },
  "bukan-agama": { Vis: BukanAgama, tinggi: 360 },
  "tiga-nama": { Vis: TigaNama, tinggi: 380 },
  "arti-nama": { Vis: ArtiNama, tinggi: 380 },
  definisi: { Vis: DefinisiVis, tinggi: 320 },
  pola: { Vis: PolaVis, tinggi: 360 },
};

export { Kanvas, Tx, Ar, Jalur3, Sampul, Wadah, Tuas, Mobil, GarisWaktu, Orang };
void Wadah;
