import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { HURUF } from "../tema";
import {
  BAB,
  GELAP,
  ISI,
  Muncul,
  SLIDES,
  T,
  TEPI,
  TERANG,
  gayaArab,
  p,
  type Pal,
  type Slide,
} from "./kit";
import { META, type Bagian } from "./meta";
import { VISUAL } from "./visual";

/** Label kecil kapital di atas judul. */
const Kepala: React.FC<{ s: Slide; i: number; c: Pal }> = ({ s, i, c }) => {
  const f = useCurrentFrame();
  const bab = BAB[s.bab];
  return (
    <div style={{ opacity: p(f, 0, 15) }}>
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
        <span>
          {s.bab === 0
            ? "PENGANTAR"
            : `BAB ${String(s.bab).padStart(2, "0")} · ${bab.judul.toUpperCase()}`}
        </span>
        <span style={{ fontVariantNumeric: "tabular-nums" }}>
          {i + 1} / {SLIDES.length}
        </span>
      </div>
      {/* Bilah kemajuan per bab */}
      <div style={{ display: "flex", gap: 6, marginTop: 18 }}>
        {BAB.map((b) => (
          <div
            key={b.no}
            style={{
              flex: 1,
              height: 3,
              borderRadius: 2,
              background: b.no <= s.bab ? c.ink : c.line,
              opacity: b.no === s.bab ? 1 : b.no < s.bab ? 0.55 : 1,
            }}
          />
        ))}
      </div>
    </div>
  );
};

const Poin: React.FC<{ isi: string[]; c: Pal; mulai: number }> = ({
  isi,
  c,
  mulai,
}) => (
  <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
    {isi.map((x, k) => (
      <Muncul key={k} pada={mulai + k * 9} geser={0}>
        <div
          style={{
            display: "flex",
            gap: 20,
            alignItems: "baseline",
            fontFamily: HURUF.ui,
            fontSize: 32,
            lineHeight: 1.4,
            color: c.ink,
          }}
        >
          <span
            style={{
              flex: "0 0 10px",
              height: 10,
              borderRadius: 5,
              background: c.ink,
              transform: "translateY(-6px)",
            }}
          />
          <span>
            <T s={x} />
          </span>
        </div>
      </Muncul>
    ))}
  </div>
);

const Dua: React.FC<{ s: Slide; c: Pal; mulai: number }> = ({ s, c, mulai }) => (
  <div style={{ display: "flex", gap: 20 }}>
    {[s.kiri!, s.kanan!].map((k, j) => (
      <Muncul key={j} pada={mulai + j * 10} style={{ flex: 1 }}>
        <div
          style={{
            background: c.surface,
            borderRadius: 24,
            padding: "24px 28px",
            height: "100%",
            boxSizing: "border-box",
          }}
        >
          <div style={{ ...gayaArab(36, c.ink), lineHeight: 1.5 }}>{k.arab}</div>
          <div
            style={{
              fontFamily: HURUF.ui,
              fontWeight: 600,
              fontSize: 30,
              color: c.ink,
              marginTop: 4,
            }}
          >
            {k.judul}
          </div>
          {k.isi.map((x) => (
            <div
              key={x}
              style={{
                fontFamily: HURUF.ui,
                fontSize: 26,
                lineHeight: 1.4,
                color: c.muted,
                marginTop: 8,
              }}
            >
              {x}
            </div>
          ))}
        </div>
      </Muncul>
    ))}
  </div>
);

const Daftar: React.FC<{ s: Slide; c: Pal; mulai: number }> = ({
  s,
  c,
  mulai,
}) => (
  <div
    style={{
      background: c.surface,
      borderRadius: 24,
      padding: "6px 28px",
    }}
  >
    {s.rukun!.map((r, k) => (
      <Muncul key={k} pada={mulai + k * 8} geser={0}>
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 22,
            padding: "16px 0",
            borderTop: k ? `1.5px solid ${c.subtle}` : "none",
          }}
        >
          <div
            style={{
              flex: "0 0 52px",
              height: 52,
              borderRadius: 12,
              background: c.subtle,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontFamily: HURUF.ui,
              fontWeight: 600,
              fontSize: 22,
              color: c.ink,
            }}
          >
            {String(k + 1).padStart(2, "0")}
          </div>
          <div style={{ flex: 1 }}>
            <div
              style={{
                fontFamily: HURUF.ui,
                fontWeight: 600,
                fontSize: 28,
                color: c.ink,
              }}
            >
              {r.nama}
            </div>
            <div
              style={{
                fontFamily: HURUF.ui,
                fontSize: 23,
                lineHeight: 1.35,
                color: c.muted,
                marginTop: 2,
              }}
            >
              {r.ilmu}
            </div>
          </div>
          <div style={{ ...gayaArab(30, c.ink), lineHeight: 1.4 }}>{r.arab}</div>
        </div>
      </Muncul>
    ))}
  </div>
);

/** Kartu ibarah: teks Arab muncul kata demi kata, lalu makna dan rujukan. */
const Ibarah: React.FC<{ s: Slide; c: Pal; mulai: number }> = ({
  s,
  c,
  mulai,
}) => {
  const f = useCurrentFrame();
  const kata = s.ibarah!.split(" ");
  const panjang = s.ibarah!.length;
  const ukuran = panjang > 220 ? 36 : panjang > 110 ? 40 : 46;
  const laju = Math.max(1.5, Math.min(4, 70 / kata.length));
  const akhir = mulai + kata.length * laju + 10;
  return (
    <Muncul pada={mulai}>
      <div
        style={{
          background: c.surface,
          borderRadius: 24,
          padding: "26px 34px 24px",
        }}
      >
        <div
          style={{
            ...gayaArab(ukuran, c.ink),
            display: "flex",
            flexWrap: "wrap",
            columnGap: ukuran * 0.28,
          }}
        >
          {kata.map((k, i) => {
            const t = p(f, mulai + 6 + i * laju, mulai + 18 + i * laju);
            return (
              <span key={i} style={{ opacity: t }}>
                {i === 0 ? "«" : ""}
                {k}
                {i === kata.length - 1 ? "»" : ""}
              </span>
            );
          })}
        </div>
        {s.makna && (
          <div
            style={{
              opacity: p(f, akhir, akhir + 20),
              borderTop: `1.5px solid ${c.subtle}`,
              marginTop: 10,
              paddingTop: 14,
              fontFamily: HURUF.serif,
              fontStyle: "italic",
              fontSize: 29,
              lineHeight: 1.45,
              color: c.ink,
            }}
          >
            {s.makna}
          </div>
        )}
        {s.sumber && (
          <div
            style={{
              opacity: p(f, akhir + 10, akhir + 30),
              marginTop: 14,
              fontFamily: HURUF.ui,
              fontWeight: 600,
              fontSize: 21,
              letterSpacing: 0.5,
              color: c.muted,
            }}
          >
            {s.sumber}
          </div>
        )}
      </div>
    </Muncul>
  );
};

const Kunci: React.FC<{ s: string; c: Pal; mulai: number }> = ({
  s,
  c,
  mulai,
}) => {
  const f = useCurrentFrame();
  const t = p(f, mulai, mulai + 30);
  return (
    <div style={{ display: "flex", gap: 26 }}>
      <div
        style={{
          flex: "0 0 5px",
          borderRadius: 3,
          background: c.ink,
          transform: `scaleY(${t})`,
          transformOrigin: "top",
        }}
      />
      <div
        style={{
          opacity: t,
          fontFamily: HURUF.serif,
          fontSize: 38,
          lineHeight: 1.3,
          color: c.ink,
        }}
      >
        <T s={s} />
      </div>
    </div>
  );
};

/** Satu slide utuh: kepala, judul, animasi, lalu teks pendukung bergiliran. */
export const SlideView: React.FC<{ indeks: number }> = ({ indeks }) => {
  const f = useCurrentFrame();
  const s = SLIDES[indeks];
  const m = META[s.id] ?? {};
  const c = m.gelap ? GELAP : TERANG;
  const Vis = VISUAL[s.id] as (typeof VISUAL)[string] | undefined;

  if (m.penuh && Vis) {
    return (
      <AbsoluteFill style={{ background: c.bg }}>
        <Vis s={s} c={c} h={1350} />
      </AbsoluteFill>
    );
  }

  const pakai = new Set<Bagian>(m.pakai ?? []);
  const lead = Vis ? m.lead ?? 90 : 20;
  // Urutan tetap; tiap bagian muncul 30 bingkai setelah bagian sebelumnya.
  const urutan: [Bagian, React.ReactNode][] = [];
  let t = lead;
  const tambah = (b: Bagian, n: (mulai: number) => React.ReactNode, jeda = 30) => {
    if (pakai.has(b)) return;
    urutan.push([b, n(t)]);
    t += jeda;
  };
  if (s.sub)
    tambah("sub", (mulai) => (
      <Muncul pada={mulai}>
        <div
          style={{
            fontFamily: HURUF.ui,
            fontSize: 31,
            lineHeight: 1.45,
            color: c.muted,
          }}
        >
          <T s={s.sub!} />
        </div>
      </Muncul>
    ));
  if (s.nama)
    tambah("nama", (mulai) => (
      <Muncul pada={mulai}>
        <div style={{ fontFamily: HURUF.serif, fontSize: 40, color: c.ink }}>
          {s.nama}
        </div>
      </Muncul>
    ));
  if (s.arab)
    tambah("arab", (mulai) => (
      <Muncul pada={mulai}>
        <div style={{ ...gayaArab(54, c.ink), lineHeight: 1.6 }}>{s.arab}</div>
      </Muncul>
    ));
  if (s.poin)
    tambah(
      "poin",
      (mulai) => <Poin isi={s.poin!} c={c} mulai={mulai} />,
      30 + s.poin.length * 9,
    );
  if (s.kiri && s.kanan)
    tambah("dua", (mulai) => <Dua s={s} c={c} mulai={mulai} />, 40);
  if (s.rukun)
    tambah(
      "rukun",
      (mulai) => <Daftar s={s} c={c} mulai={mulai} />,
      30 + s.rukun.length * 8,
    );
  if (s.ibarah)
    tambah(
      "ibarah",
      (mulai) => <Ibarah s={s} c={c} mulai={mulai} />,
      60 + s.ibarah.split(" ").length * 3,
    );
  if (s.kunci)
    tambah("kunci", (mulai) => <Kunci s={s.kunci!} c={c} mulai={mulai} />);
  if (s.sumber && !s.ibarah)
    tambah("sumber", (mulai) => (
      <Muncul pada={mulai}>
        <div
          style={{
            fontFamily: HURUF.ui,
            fontWeight: 600,
            fontSize: 21,
            color: c.muted,
          }}
        >
          {s.sumber}
        </div>
      </Muncul>
    ));

  const judulT = p(f, 4, 30);
  return (
    <AbsoluteFill
      style={{
        background: c.bg,
        padding: `56px ${TEPI}px 0`,
        boxSizing: "border-box",
      }}
    >
      <Kepala s={s} i={indeks} c={c} />
      <div
        style={{
          marginTop: 40,
          fontFamily: HURUF.serif,
          fontSize: 60,
          lineHeight: 1.1,
          letterSpacing: -1,
          color: c.ink,
          opacity: judulT,
          transform: `translateY(${(1 - judulT) * 30}px)`,
        }}
      >
        <T s={s.judul} />
      </div>
      {Vis && m.tinggi && (
        <div
          style={{
            position: "relative",
            width: ISI,
            height: m.tinggi,
            marginTop: 28,
          }}
        >
          <Vis s={s} c={c} h={m.tinggi} />
        </div>
      )}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: 26,
          marginTop: 30,
        }}
      >
        {urutan.map(([b, n]) => (
          <React.Fragment key={b}>{n}</React.Fragment>
        ))}
      </div>
    </AbsoluteFill>
  );
};
