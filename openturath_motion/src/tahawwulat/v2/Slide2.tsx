import React from "react";
import { useCurrentFrame } from "remotion";
import { ISI, Muncul, TEPI, acak, lembut, mix, p, type Pal } from "./kit";
import { EmpatTiang, GarisWaktu, Mobil, Orang, Tuas, Wadah, Zaman } from "./motif";
import { Ar, Kanvas, Tx, type VisProps } from "./Slide";

// ── Bab 6 ────────────────────────────────────────────────────────────────

/** Dua tugas: perisai dan corong suara, digantung pada tiang keempat. */
export const DuaTugas: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const buka = p(f, 20, 60, lembut);
  return (
    <Kanvas h={h}>
      <rect x={400} y={20} width={80} height={h - 90} rx={8} fill={c.ink} opacity={0.9} />
      <g opacity={buka}>
        <line x1={400} y1={110} x2={mix(400, 190, buka)} y2={110} stroke={c.ink} strokeWidth={3} />
        <line x1={480} y1={110} x2={mix(480, 690, buka)} y2={110} stroke={c.ink} strokeWidth={3} />
        <path d={`M190 60 L268 82 V140 C268 186 232 206 190 216 C148 206 112 186 112 140 V82 Z`} fill={c.surface} stroke={c.ink} strokeWidth={4} />
        <Tx x={190} y={140} s="menjaga" u={24} w={c.ink} bobot={600} />
        <path d={`M660 70 L720 90 V150 L660 170 Z`} fill={c.surface} stroke={c.ink} strokeWidth={4} />
        {[0, 1, 2].map((k) => {
          const r = 40 + ((f * 1.4 + k * 40) % 90);
          return <circle key={k} cx={690} cy={120} r={r} fill="none" stroke={c.faint} strokeWidth={2} opacity={1 - (r - 40) / 90} />;
        })}
        <Tx x={690} y={196} s="menyampaikan" u={24} w={c.ink} bobot={600} />
      </g>
      <Tx x={460} y={h - 30} s="dua arah, satu tiang" u={22} w={c.muted} />
    </Kanvas>
  );
};

/** Cara menyampaikan: cahaya sama, wadah penyampaian berganti. */
export const CaraSampaikan: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const tahap = Math.min(3, Math.floor(f / 30));
  const bentuk = ["halaqah", "kitab", "mimbar", "layar"];
  return (
    <Kanvas h={h}>
      {bentuk.map((b, k) => {
        const aktif = k === tahap;
        const x = 90 + k * 230;
        return (
          <g key={b} opacity={aktif ? 1 : 0.28}>
            {k < 3 && <line x1={x + 40} y1={150} x2={x + 190} y2={150} stroke={c.line} strokeWidth={3} strokeDasharray="6 6" />}
            {k === 0 && [0, 1, 2].map((j) => <circle key={j} cx={x + j * 40} cy={150} r={14} fill={c.surface} stroke={c.ink} strokeWidth={3} />)}
            {k === 1 && <rect x={x - 10} y={122} width={100} height={56} rx={6} fill={c.surface} stroke={c.ink} strokeWidth={3} />}
            {k === 2 && <path d={`M${x - 10} 178 H${x + 90} L${x + 76} 122 H${x + 4} Z`} fill={c.surface} stroke={c.ink} strokeWidth={3} />}
            {k === 3 && <rect x={x} y={104} width={80} height={92} rx={12} fill={c.surface} stroke={c.ink} strokeWidth={3} />}
            <Tx x={x + 40} y={224} s={b} u={22} w={c.ink} bobot={aktif ? 600 : 400} />
          </g>
        );
      })}
      <circle cx={460} cy={40} r={20} fill={c.ink} />
      <Tx x={460} y={h - 24} s="pesannya tidak berubah; caranya mengikuti zaman" u={22} w={c.muted} />
    </Kanvas>
  );
};

/** Tiga perusak: panah memantul dari perisai. */
export const TigaPerusak: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const cx = 460;
  const cy = h / 2 + 10;
  const dari = [
    [70, 40],
    [70, h - 30],
    [850, h / 2],
  ];
  const label = ["pemahaman berlebihan", "kepalsuan atas nama agama", "tafsir tanpa ilmu"];
  return (
    <Kanvas h={h}>
      <path d={`M${cx} ${cy - 130} L${cx + 108} ${cy - 92} V${cy} C${cx + 108} ${cy + 72} ${cx + 52} ${cy + 112} ${cx} ${cy + 140} C${cx - 52} ${cy + 112} ${cx - 108} ${cy + 72} ${cx - 108} ${cy} V${cy - 92} Z`} fill={c.ink} />
      <Ar x={cx} y={cy} s="الثوابت" u={34} w={c.onInk} />
      {dari.map(([x, y], k) => {
        const t = p(f, 16 + k * 12, 44 + k * 12, lembut);
        const pantul = p(f, 44 + k * 12, 66 + k * 12);
        const ujung = [mix(x, cx - 170, t) + (x - cx) * 0.18 * pantul, mix(y, cy + (y - cy) * 0.25, t) + (y - cy) * 0.18 * pantul];
        const sudut = Math.atan2(cy - y, cx - x);
        return (
          <g key={k} opacity={1 - pantul * 0.55}>
            <line x1={ujung[0] - Math.cos(sudut) * 74} y1={ujung[1] - Math.sin(sudut) * 74} x2={ujung[0]} y2={ujung[1]} stroke={c.ink} strokeWidth={4} strokeLinecap="round" />
            <circle cx={ujung[0]} cy={ujung[1]} r={7} fill={c.ink} />
            <Tx x={x < cx ? x + 110 : x - 110} y={y < cy ? y + 22 : y - 12} s={label[k]} u={21} w={c.muted} />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Isi dan wadah: empat wadah, satu retak tersembunyi. */
export const IsiWadah: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const isi = p(f, 10, 50);
  const lensa = p(f, 80, 130, lembut);
  return (
    <Kanvas h={h}>
      {[0, 1, 2, 3].map((k) => (
        <Wadah key={k} x={140 + k * 215} dasar={h - 60} c={c} isi={isi} retak={k === 2} terang={k !== 2} lebar={118} tinggi={170} />
      ))}
      <Tx x={460} y={30} s="isi sama, wadah berbeda" u={23} w={c.muted} o={p(f, 10, 30)} />
      <g opacity={lensa}>
        <circle cx={mix(120, 570, lensa)} cy={h / 2} r={92} fill="none" stroke={c.ink} strokeWidth={5} />
        <line x1={mix(120, 570, lensa) + 66} y1={h / 2 + 66} x2={mix(120, 570, lensa) + 108} y2={h / 2 + 108} stroke={c.ink} strokeWidth={9} strokeLinecap="round" />
      </g>
    </Kanvas>
  );
};

/** Kenali wadah: lensa menemukan wadah bermuka dua. */
export const KenaliWadah: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const sorot = p(f, 60, 100);
  return (
    <Kanvas h={h}>
      {[0, 1, 2].map((k) => (
        <Wadah key={k} x={180 + k * 280} dasar={h - 60} c={c} isi={1} retak={k === 1} terang={k !== 1} lebar={150} tinggi={200} />
      ))}
      <g opacity={sorot}>
        <circle cx={460} cy={h / 2 - 10} r={130} fill="none" stroke={c.ink} strokeWidth={5} />
        <Tx x={460} y={h - 20} s="bermuka indah, tetapi bocor" u={23} w={c.ink} bobot={600} />
      </g>
    </Kanvas>
  );
};

// ── Bab 7 ────────────────────────────────────────────────────────────────

/** Dua tanda: dari satu kartu menjadi dua panel. */
export const DuaTanda: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const pecah = p(f, 30, 80, lembut);
  return (
    <Kanvas h={h}>
      <rect x={90} y={30} width={680} height={260} rx={20} fill={c.surface} stroke={c.line} strokeWidth={2.5} opacity={1 - pecah} />
      <Tx x={430} y={160} s="tanda kiamat" u={26} w={c.muted} o={1 - pecah} />
      {[0, 1].map((k) => {
        const x = 40 + k * 440;
        return (
          <g key={k} opacity={pecah} transform={`translate(0 ${(1 - pecah) * 20})`}>
            <rect x={x} y={20} width={400} height={h - 80} rx={20} fill={c.surface} stroke={c.line} strokeWidth={2.5} />
            {k === 0 ? (
              <>
                <circle cx={x + 110} cy={210} r={54} fill={c.surface} stroke={c.ink} strokeWidth={5} />
                {[0, 1, 2].map((j) => (
                  <line key={j} x1={x + 110} y1={210} x2={x + 110 + Math.cos((j / 3) * 6.283 - 1.2) * 44} y2={210 + Math.sin((j / 3) * 6.283 - 1.2) * 44} stroke={c.ink} strokeWidth={3} />
                ))}
                <circle cx={x + 268} cy={150} r={34} fill={c.ink} />
                <path d={`M${x + 268} 184 q-6 44 -46 62`} stroke={c.ink} strokeWidth={3} fill="none" strokeDasharray="7 7" />
                <Tx x={x + 200} y={h - 46} s="budak melahirkan tuannya" u={23} w={c.ink} bobot={600} />
              </>
            ) : (
              <>
                {[0, 1, 2, 3, 4].map((j) => (
                  <rect key={j} x={x + 70 + j * 60} y={250 - (60 + acak(j + 4) * 130) * p(f, 50 + j * 8, 80 + j * 8)} width={44} height={(60 + acak(j + 4) * 130) * p(f, 50 + j * 8, 80 + j * 8)} fill={j % 2 ? c.ink : c.subtle} />
                ))}
                {[0, 1, 2].map((j) => (
                  <g key={`p${j}`}>
                    <circle cx={x + 70 + j * 44} cy={h - 120} r={11} fill="none" stroke={c.ink} strokeWidth={3} />
                    <rect x={x + 60 + j * 44} y={h - 108} width={20} height={26} rx={4} fill="none" stroke={c.ink} strokeWidth={3} />
                  </g>
                ))}
                <Tx x={x + 200} y={h - 46} s="penggembala berlomba bangunan" u={23} w={c.ink} bobot={600} />
              </>
            )}
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Kode: kalimat pendek dibuka lapis demi lapis. */
export const Kode: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <rect x={90} y={40} width={680} height={110} rx={16} fill={c.ink} />
      <Ar x={430} y={95} s="نص استباقي في ترميز بلاغي" u={38} w={c.onInk} />
      {[0, 1, 2].map((k) => {
        const t = p(f, 40 + k * 20, 64 + k * 20);
        return (
          <g key={k} opacity={t}>
            <rect x={90 + k * 228} y={190} width={216} height={130} rx={14} fill={c.surface} stroke={c.line} strokeWidth={2} />
            <Tx x={198 + k * 228} y={240} s={["berita masa depan", "bahasa singkat", "dibuka dengan kaidah"][k].split(" ")[0]} u={21} w={c.ink} bobot={600} />
            <Tx x={198 + k * 228} y={266} s={["berita masa depan", "bahasa singkat", "dibuka dengan kaidah"][k].split(" ").slice(1).join(" ")} u={21} w={c.ink} bobot={600} />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Dua kendali. */
export const DuaKendali: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <Tuas x={250} y={100} c={c} tarik={p(f, 20, 70, lembut)} label={["ilmu & keyakinan", "قرار العلم"]} skala={1.15} />
      <Tuas x={670} y={100} c={c} tarik={p(f, 30, 80, lembut)} label={["kekuasaan & harta", "قرار الحكم"]} skala={1.15} />
      <Tx x={460} y={h - 30} s="dua kendali penentu arah umat" u={23} w={c.muted} o={p(f, 70, 90)} />
    </Kanvas>
  );
};

/** Tanda 1: tuas ilmu bergeser ke tangan yang belum berhak. */
export const KendaliIlmu: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const geser = p(f, 40, 100, lembut);
  return (
    <Kanvas h={h}>
      <Tuas x={460} y={120} c={c} tarik={geser} label={["kendali ilmu", "قرار العلم والاعتقاد"]} skala={1.5} />
      <g opacity={p(f, 90, 110)}>
        <circle cx={mix(360, 560, geser)} cy={236} r={20} fill={c.surface} stroke={c.ink} strokeWidth={3} />
        <Tx x={460} y={290} s="dari yang berilmu kepada yang belum berhak" u={22} w={c.ink} bobot={600} />
      </g>
      <Ar x={460} y={h - 20} s="إذا ضيعت الأمانة فانتظر الساعة" u={30} w={c.muted} o={p(f, 110, 130)} />
    </Kanvas>
  );
};

/** Tanda 2: tuas kuasa; gedung naik, hati mengecil. */
export const KendaliKuasa: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const naik = p(f, 20, 90, lembut);
  return (
    <Kanvas h={h}>
      <Tuas x={180} y={100} c={c} tarik={naik} label={["kendali kuasa", "قرار الحكم والاقتصاد"]} skala={1} />
      {[0, 1, 2, 3, 4].map((k) => {
        const t = p(f, 20 + k * 9, 80 + k * 9, lembut);
        const tinggi = mix(20, 90 + acak(k + 3) * 110, t);
        return <rect key={k} x={470 + k * 66} y={300 - tinggi} width={50} height={tinggi} rx={5} fill={k % 2 ? c.ink : c.subtle} />;
      })}
      <line x1={450} y1={300} x2={820} y2={300} stroke={c.ink} strokeWidth={3} />
      <g transform={`translate(620 ${h - 60}) scale(${mix(1, 0.5, naik)})`} opacity={p(f, 40, 60)}>
        <path d="M0 6 C-26 -8 -22 -28 -10 -28 C-4 -28 0 -24 0 -18 C0 -24 4 -28 10 -28 C22 -28 26 -8 0 6 Z" fill={c.ink} />
      </g>
      <Ar x={620} y={h - 20} s="إذا وسد الأمر إلى غير أهله" u={28} w={c.muted} o={p(f, 90, 110)} />
    </Kanvas>
  );
};

/** Semua tanda masuk dua keranjang. */
export const DuaKeranjang: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      {Array.from({ length: 46 }).map((_, k) => {
        const keKanan = k % 2 === 0;
        const mulai = 4 + (k % 9) * 7;
        const t = p(f, mulai, mulai + 46, lembut);
        const x0 = 40 + acak(k) * 780;
        const y0 = 20 + acak(k + 50) * 80;
        const tx = keKanan ? 650 : 210;
        const ty = h - 110;
        return <rect key={k} x={mix(x0, tx, t) - 9} y={mix(y0, ty, t) - 9} width={18} height={18} rx={4} fill={c.muted} opacity={1 - t * 0.75} />;
      })}
      {[["ilmu", 210], ["kekuasaan", 650]].map(([n, x], j) => (
        <g key={j} opacity={p(f, 40, 60)}>
          <rect x={Number(x) - 120} y={h - 110} width={240} height={90} rx={16} fill={c.surface} stroke={c.ink} strokeWidth={4} />
          <Tx x={Number(x)} y={h - 62} s={String(n)} u={26} w={c.ink} bobot={600} />
        </g>
      ))}
    </Kanvas>
  );
};

/** Simpul: ikatan lepas satu per satu. */
export const Simpul: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const lepas = [0, 1, 2, 3, 4].map((k) => p(f, 30 + k * 24, 54 + k * 24, lembut));
  const y = h / 2;
  return (
    <Kanvas h={h}>
      <path d={`M20 ${y} Q${ISI / 2} ${y + 60} ${ISI - 20} ${y}`} fill="none" stroke={c.line} strokeWidth={14} strokeLinecap="round" />
      {lepas.map((t, k) => {
        const x = 90 + k * 170;
        const nama = ["kekuasaan", "amanah", "ilmu", "akhlak", "salat"][k];
        return (
          <g key={k} opacity={1 - t * 0.85}>
            <circle cx={x} cy={y + 30 - k * 6} r={30} fill="none" stroke={c.ink} strokeWidth={9} />
            <Tx x={x} y={y - 90} s={nama} u={21} w={t > 0.5 ? c.faint : c.ink} bobot={k === 4 ? 600 : 400} />
          </g>
        );
      })}
      <Tx x={460} y={h - 20} s="yang pertama lepas: kekuasaan · yang terakhir: salat" u={22} w={c.muted} />
    </Kanvas>
  );
};

/** Tanda 1 versi jelas: otoritas ilmu dibalikkan. */
export const KendaliIlmu2: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const balik = p(f, 60, 120, lembut);
  const xGuru = mix(300, 620, balik);
  const xMurid = mix(620, 300, balik);
  return (
    <Kanvas h={h}>
      <Tuas x={460} y={90} c={c} tarik={p(f, 20, 70)} label={["kendali ilmu", "قرار العلم والاعتقاد"]} skala={1.3} />
      <line x1={60} y1={h - 60} x2={ISI - 60} y2={h - 60} stroke={c.ink} strokeWidth={3} />
      <g>
        <Orang x={xGuru} y={h - 60} skala={1.05} c={c} />
        <Tx x={xGuru} y={h - 150} s="guru" u={22} w={c.ink} bobot={600} />
        <Orang x={xMurid} y={h - 60} skala={0.78} c={c} />
        <Tx x={xMurid} y={h - 140} s="murid" u={22} w={c.ink} bobot={600} />
      </g>
      <g opacity={p(f, 110, 140)}>
        <path d={`M${xMurid} ${h - 172} v-40 m-12 12 l12 -14 l12 14`} stroke={c.ink} strokeWidth={3} fill="none" />
        <Tx x={460} y={30} s="arah ilmu berbalik" u={23} w={c.ink} bobot={600} />
      </g>
    </Kanvas>
  );
};

/** Dua keranjang: isi keranjang supaya terlihat. */
export const DuaKeranjang2: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      {Array.from({ length: 44 }).map((_, k) => {
        const keKanan = k % 2 === 0;
        const mulai = 4 + (k % 8) * 8;
        const t = p(f, mulai, mulai + 44, lembut);
        const x0 = 40 + acak(k) * 780;
        const y0 = 16 + acak(k + 50) * 70;
        const tx = keKanan ? 640 : 280;
        const ty = h - 170;
        return <rect key={k} x={mix(x0, tx, t) - 8} y={mix(y0, ty, t) - 8} width={16} height={16} rx={3} fill={c.muted} opacity={0.3 + 0.7 * (1 - t)} />;
      })}
      {[["ilmu", 280], ["kekuasaan", 640]].map(([n, x], j) => (
        <g key={j} opacity={p(f, 30, 55)}>
          <path d={`M${Number(x) - 130} ${h - 190} H${Number(x) + 130} L${Number(x) + 100} ${h - 60} H${Number(x) - 100} Z`} fill={c.surface} stroke={c.ink} strokeWidth={4} />
          <Tx x={Number(x)} y={h - 34} s={String(n)} u={26} w={c.ink} bobot={600} />
        </g>
      ))}
      {[["setiap tanda kiamat", 190], ["masuk salah satu", 460]].map(([n, y], i) => (
        <Tx key={i} x={460} y={Number(y)} s={String(n)} u={22} w={c.muted} o={p(f, 90, 115)} />
      ))}
    </Kanvas>
  );
};

export const WadahDua: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <Wadah x={260} dasar={h - 90} c={c} isi={p(f, 10, 50)} terang lebar={190} tinggi={250} />
      <Wadah x={660} dasar={h - 90} c={c} isi={p(f, 10, 50)} retak lebar={190} tinggi={250} />
      <Tx x={260} y={h - 40} s="isi baik, wadah jujur" u={22} w={c.ink} bobot={600} />
      <Tx x={660} y={h - 40} s="isi baik, wadah bermuka" u={22} w={c.ink} bobot={600} />
      <Tx x={460} y={30} s="isinya sama; yang berbeda wadahnya" u={23} w={c.muted} o={p(f, 40, 60)} />
    </Kanvas>
  );
};

export const PosisiKita2: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["Ahlas", "Sarra'", "Duhaima'", "keempat", "Shailamah"];
  return (
    <Kanvas h={h}>
      {nama.map((n, k) => (
        <g key={n} opacity={p(f, k * 12, k * 12 + 26)}>
          <rect x={k * 168} y={h / 2 - 46} width={152} height={92} rx={12} fill={k === 4 ? c.ink : c.subtle} />
          <Tx x={k * 168 + 76} y={h / 2 + 4} s={n} u={19} w={k === 4 ? c.onInk : c.ink} bobot={600} />
        </g>
      ))}
      <g opacity={p(f, 70, 100)}>
        <path d={`M${4 * 168 + 76} ${h / 2 - 58} v-46 m-14 14 l14 -14 l14 14`} stroke={c.ink} strokeWidth={4} fill="none" strokeLinecap="round" />
        <Tx x={4 * 168 + 76} y={h / 2 - 124} s="di sini" u={26} w={c.ink} bobot={600} />
      </g>
      <Tx x={460} y={h / 2 + 76} s="pembacaan beliau atas zamannya, bukan tanggal" u={22} w={c.muted} o={p(f, 90, 110)} />
    </Kanvas>
  );
};

// ── Bab 8 ────────────────────────────────────────────────────────────────

/** Tiga garis waktu ditumpuk. */
export const TigaGaris: React.FC<VisProps & { sorot?: number }> = ({ c, h, sorot }) => {
  const f = useCurrentFrame();
  const semua = [
    ["kecil", 0.02, 0.98, 39],
    ["tengah", 0.18, 0.72, 18],
    ["besar", 0.72, 0.96, 10],
  ] as const;
  const baris = sorot === undefined ? [...semua].reverse() : semua;
  return (
    <Kanvas h={h}>
      {baris.map(([n, a, b, jml], k) => {
        const t = p(f, 10 + k * 12, 50 + k * 12, lembut);
        const y = 60 + k * 130;
        const redup = sorot !== undefined && k !== sorot;
        return (
          <g key={n} opacity={t * (redup ? 0.22 : 1)}>
            <line x1={a * ISI} y1={y} x2={b * ISI} y2={y} stroke={c.line} strokeWidth={10} strokeLinecap="round" />
            <line x1={a * ISI} y1={y} x2={mix(a, b, p(f, 20 + k * 12, 60 + k * 12)) * ISI} y2={y} stroke={c.ink} strokeWidth={10} strokeLinecap="round" />
            <Tx x={30} y={y - 26} s={n} u={22} w={c.ink} bobot={600} a="start" />
            <Tx x={ISI - 10} y={y - 26} s={`${jml} tanda`} u={19} w={c.muted} a="end" />
          </g>
        );
      })}
      <Tx x={460} y={h - 40} s="panjang = rentang waktu, bukan tingkat kepentingan" u={22} w={c.muted} o={p(f, 60, 80)} />
    </Kanvas>
  );
};

/** Tanda tengah: titik besar yang membelokkan arah. */
export const GarisTengah: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["wafat Nabi ﷺ", "Umar", "Utsman", "Ali", "al-Hasan"];
  return (
    <Kanvas h={h}>
      <path d={`M40 ${h - 60} Q${ISI * 0.4} ${h - 60} ${ISI - 40} 60`} fill="none" stroke={c.line} strokeWidth={8} strokeLinecap="round" />
      {nama.map((n, k) => {
        const t = p(f, 10 + k * 18, 32 + k * 18, lembut);
        const x = 120 + k * 165;
        const y = mix(h - 60, 80, x / ISI);
        return (
          <g key={n} opacity={t}>
            <circle cx={x} cy={y} r={13} fill={c.ink} stroke={c.bg} strokeWidth={4} />
            <line x1={x} y1={y} x2={x} y2={y - 46} stroke={c.line} strokeWidth={2} />
            <Tx x={x} y={y - 62} s={n} u={19} w={c.ink} bobot={600} />
          </g>
        );
      })}
      <Tx x={460} y={h - 20} s="peristiwa engsel: sekali terjadi, mengubah arah" u={22} w={c.muted} o={p(f, 90, 110)} />
    </Kanvas>
  );
};

/** Tanda besar: sepuluh titik di ujung garis. */
export const GarisBesar: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["Mahdi", "Dajjal", "Isa", "Ya'juj", "asap", "3 gerhana", "api", "dabbah", "matahari", "sangkakala"];
  return (
    <Kanvas h={h}>
      <line x1={40} y1={h / 2} x2={ISI - 40} y2={h / 2} stroke={c.ink} strokeWidth={4} />
      {nama.map((n, k) => {
        const t = p(f, 8 + k * 8, 28 + k * 8);
        const x = 70 + k * 84;
        const atas = k % 2 === 0;
        return (
          <g key={n} opacity={t}>
            <circle cx={x} cy={h / 2} r={11} fill={c.ink} />
            <line x1={x} y1={h / 2} x2={x} y2={h / 2 + (atas ? -34 : 34)} stroke={c.line} strokeWidth={2} />
            <Tx x={x} y={h / 2 + (atas ? -52 : 52)} s={n} u={18} w={c.ink} bobot={k === 9 ? 600 : 400} />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Bertumpuk: tiga garis dan satu penanda waktu. */
export const Bertumpuk: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const x = mix(80, 760, p(f, 20, 100, lembut));
  return (
    <Kanvas h={h}>
      {[["besar", 0.72, 0.95], ["tengah", 0.18, 0.72], ["kecil", 0.02, 0.98]].map(([n, a, b], k) => (
        <g key={String(n)}>
          <line x1={Number(a) * ISI} y1={70 + k * 90} x2={Number(b) * ISI} y2={70 + k * 90} stroke={c.line} strokeWidth={9} strokeLinecap="round" />
          <Tx x={30} y={70 + k * 90} s={String(n)} u={21} w={c.ink} bobot={600} a="start" />
        </g>
      ))}
      <line x1={x} y1={20} x2={x} y2={h - 70} stroke={c.ink} strokeWidth={3} strokeDasharray="8 8" />
      <Tx x={x} y={h - 40} s="satu titik waktu" u={21} w={c.ink} bobot={600} />
      <Tx x={460} y={h - 8} s="bisa memuat lebih dari satu jenis tanda" u={21} w={c.muted} />
    </Kanvas>
  );
};

// ── Bab 9 ────────────────────────────────────────────────────────────────

/** Jalan perjalanan umat. */
export const JalanUmat: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const gerbang = ["kenabian", "khilafah", "kerajaan", "memaksa", "keadilan kembali"];
  const maju = p(f, 10, 110, lembut);
  return (
    <Kanvas h={h}>
      <line x1={40} y1={h - 60} x2={ISI - 40} y2={h - 60} stroke={c.line} strokeWidth={8} />
      {gerbang.map((g, k) => {
        const t = p(f, k * 16, k * 16 + 30);
        const x = 80 + k * 170;
        return (
          <g key={g} opacity={t}>
            <path d={`M${x - 46} ${h - 60} V140 Q${x} 80 ${x + 46} 140 V${h - 60}`} fill="none" stroke={c.ink} strokeWidth={5} />
            <Tx x={x} y={h - 24} s={g} u={20} w={c.ink} bobot={600} />
          </g>
        );
      })}
      <Mobil x={mix(60, ISI - 120, maju)} y={h - 96} skala={0.5} c={c} label={false} />
    </Kanvas>
  );
};

/** Peta fase: papan nama tiap fase. */
export const PetaFase: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const fase = ["kenabian", "khilafah rasyidah", "dua kerajaan", "negeri terpecah", "Utsmani", "zaman buih"];
  return (
    <Kanvas h={h}>
      <line x1={20} y1={h / 2} x2={ISI - 20} y2={h / 2} stroke={c.ink} strokeWidth={3} />
      {fase.map((n, k) => {
        const t = p(f, 8 + k * 14, 28 + k * 14);
        const x = 70 + k * 146;
        const atas = k % 2 === 0;
        return (
          <g key={n} opacity={t}>
            <circle cx={x} cy={h / 2} r={10} fill={k === 5 ? c.ink : c.bg} stroke={c.ink} strokeWidth={3} />
            <line x1={x} y1={h / 2} x2={x} y2={h / 2 + (atas ? -44 : 44)} stroke={c.line} strokeWidth={2} />
            <rect x={x - 64} y={h / 2 + (atas ? -96 : 44)} width={128} height={52} rx={10} fill={k === 5 ? c.ink : c.surface} stroke={c.line} strokeWidth={2} />
            <Tx x={x} y={h / 2 + (atas ? -70 : 70)} s={n.split(" ")[0]} u={19} w={k === 5 ? c.onInk : c.ink} bobot={600} />
            {n.split(" ").length > 1 && <Tx x={x} y={h / 2 + (atas ? -50 : 90)} s={n.split(" ").slice(1).join(" ")} u={18} w={k === 5 ? c.onInk : c.ink} />}
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Payung: mengecil di fase akhir. */
export const Payung: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      <line x1={20} y1={h - 40} x2={ISI - 20} y2={h - 40} stroke={c.ink} strokeWidth={3} />
      {[1, 0.86, 0.72, 0.58, 0.44, 0.22].map((r, k) => {
        const x = 80 + k * 146;
        const t = p(f, k * 14, k * 14 + 26);
        return (
          <g key={k} opacity={t}>
            <path d={`M${x - 60 * r} ${h - 150} Q${x} ${h - 150 - 70 * r} ${x + 60 * r} ${h - 150}`} fill="none" stroke={c.ink} strokeWidth={4} />
            <line x1={x} y1={h - 150} x2={x} y2={h - 70} stroke={c.ink} strokeWidth={3} />
          </g>
        );
      })}
      <Tx x={460} y={40} s="tiap fase punya pelindung; di zaman buih hampir habis" u={22} w={c.muted} o={p(f, 60, 80)} />
    </Kanvas>
  );
};

/** Buih: banyak gelembung terseret arus. */
export const Buih: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      {[0, 1, 2].map((k) => (
        <path
          key={k}
          d={Array.from({ length: 47 })
            .map((_, i) => `${i ? "L" : "M"}${i * 20} ${h - 70 + k * 26 + Math.sin(i / 3 + f / 8 + k) * 10}`)
            .join(" ")}
          fill="none"
          stroke={c.line}
          strokeWidth={3}
        />
      ))}
      {Array.from({ length: 80 }).map((_, k) => {
        const r = 5 + acak(k) * 15;
        const x = ((acak(k + 9) * 940 + f * (2 + acak(k + 3) * 3)) % 940) - 30;
        const y = h - 90 - acak(k + 21) * (h - 150) + Math.sin((f + k * 7) / 9) * 6;
        return <circle key={k} cx={x} cy={y} r={r} fill="none" stroke={c.muted} strokeWidth={1.8} opacity={0.8} />;
      })}
    </Kanvas>
  );
};

/** Wahn: dua beban menarik hati. */
export const Wahn: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const tarik = p(f, 20, 80, lembut);
  return (
    <Kanvas h={h}>
      <g transform={`translate(460 120) rotate(${tarik * 10})`}>
        <path d="M0 0 C-30 -18 -26 -44 -12 -44 C-5 -44 0 -38 0 -30 C0 -38 5 -44 12 -44 C26 -44 30 -18 0 0 Z" fill={c.ink} />
      </g>
      {[-1, 1].map((sisi) => {
        const bx = 460 + sisi * 230;
        const by = mix(160, 250, tarik);
        return (
          <g key={sisi}>
            <line x1={460 + sisi * 34} y1={130} x2={bx} y2={by - 40} stroke={c.ink} strokeWidth={2.5} />
            <rect x={bx - 92} y={by - 40} width={184} height={80} rx={14} fill={c.ink} />
            <Ar x={bx} y={by} s={sisi < 0 ? "حب الدنيا" : "كراهية الموت"} u={28} w={c.onInk} />
            <Tx x={bx} y={by + 62} s={sisi < 0 ? "cinta dunia" : "takut mati"} u={20} w={c.muted} />
          </g>
        );
      })}
      <Ar x={110} y={60} s="الْوَهْن" u={48} w={c.ink} o={p(f, 60, 80)} />
    </Kanvas>
  );
};

/** Tanpa payung: hujan umum, lingkaran kecil bercahaya. */
export const TanpaPayung: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      {Array.from({ length: 60 }).map((_, k) => {
        const x = ((acak(k) * 1000 + f * 4) % 1000) - 40;
        const y = ((acak(k + 60) * h + f * 14) % (h + 40)) - 20;
        return <line key={k} x1={x} y1={y} x2={x - 8} y2={y + 22} stroke={c.line} strokeWidth={2.5} />;
      })}
      {[[240, 200, "diri"], [460, 220, "keluarga"], [680, 200, "majelis"]].map(([x, y, n], k) => (
        <g key={String(n)} opacity={p(f, 40 + k * 14, 70 + k * 14)}>
          <circle cx={Number(x)} cy={Number(y)} r={64} fill={c.surface} stroke={c.ink} strokeWidth={3} />
          <Tx x={Number(x)} y={Number(y)} s={String(n)} u={22} w={c.ink} bobot={600} />
        </g>
      ))}
      <Tx x={460} y={h - 20} s="tidak ada pelindung fase; yang tinggal penjagaan umum dan lingkaran terdekat" u={21} w={c.muted} o={p(f, 80, 100)} />
    </Kanvas>
  );
};

/** Lima babak: jalan makin dalam. */
export const LimaBabak: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const nama = ["Ahlas", "Sarra'", "Duhaima'", "Fitnah keempat", "Shailamah"];
  const arab = ["الأحلاس", "السراء", "الدهيماء", "الرابعة", "الصيلمة"];
  return (
    <Kanvas h={h}>
      {nama.map((n, k) => {
        const t = p(f, 8 + k * 16, 30 + k * 16, lembut);
        const y = 30 + k * ((h - 80) / 5);
        const gelap = k >= 3;
        return (
          <g key={n} opacity={t} transform={`translate(${(1 - t) * -40} 0)`}>
            <rect x={k * 26} y={y} width={ISI - k * 26} height={(h - 80) / 5 - 12} rx={14} fill={[c.surface, c.subtle, c.line, c.muted, c.ink][k]} />
            <Tx x={40 + k * 26} y={y + 34} s={`${k + 1}. ${n}`} u={24} w={gelap ? c.onInk : c.ink} bobot={600} a="start" />
            <Ar x={ISI - 30} y={y + 36} s={arab[k]} u={30} w={gelap ? c.onInk : c.ink} a="end" />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Satu rangkaian: lima ruas disambung menuju dua tuas. */
export const SatuRangkaian: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const sambung = p(f, 20, 90, lembut);
  return (
    <Kanvas h={h}>
      {[0, 1, 2, 3, 4].map((k) => {
        const x = 60 + k * 150;
        return <rect key={k} x={x} y={60} width={120} height={70} rx={12} fill={k >= 3 ? c.ink : c.surface} stroke={c.line} strokeWidth={2} />;
      })}
      <JalurS d={`M60 95 H${mix(60, 800, sambung)}`} c={c} />
      <line x1={800} y1={95} x2={800} y2={200} stroke={c.ink} strokeWidth={3} opacity={sambung} />
      <Tuas x={640} y={240} c={c} tarik={1} label={["ilmu", "قرار العلم"]} skala={0.72} aktif={sambung > 0.9} />
      <Tuas x={800} y={240} c={c} tarik={1} label={["kuasa", "قرار الحكم"]} skala={0.72} aktif={sambung > 0.9} />
      <Tx x={460} y={h - 20} s="tiap babak menyiapkan babak berikutnya, menuju dua kendali yang sama" u={21} w={c.muted} o={p(f, 80, 100)} />
    </Kanvas>
  );
};

const JalurS: React.FC<{ d: string; c: Pal }> = ({ d, c }) => <path d={d} fill="none" stroke={c.ink} strokeWidth={4} strokeLinecap="round" />;

/** Posisi kita: penanda di ruas kelima, tanpa angka tahun. */
export const PosisiKita: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  return (
    <Kanvas h={h}>
      {[0, 1, 2, 3, 4].map((k) => (
        <rect key={k} x={k * 168} y={h / 2 - 40} width={150} height={80} rx={12} fill={k === 4 ? c.ink : c.subtle} opacity={p(f, k * 10, k * 10 + 20)} />
      ))}
      <g opacity={p(f, 60, 90)}>
        <path d={`M${4 * 168 + 75} ${h / 2 - 60} v-50 m-16 16 l16 -16 l16 16`} stroke={c.ink} strokeWidth={4} fill="none" strokeLinecap="round" />
        <Tx x={4 * 168 + 75} y={h / 2 - 130} s="di sini" u={24} w={c.ink} bobot={600} />
      </g>
      <Tx x={460} y={h / 2 + 90} s="pembacaan beliau atas zamannya, bukan tanggal" u={22} w={c.muted} o={p(f, 80, 100)} />
    </Kanvas>
  );
};

/** Terang: jeda kebaikan di tiap fase. */
export const Terang: React.FC<VisProps> = ({ c, h }) => {
  const f = useCurrentFrame();
  const cerah = p(f, 40, 110, lembut);
  return (
    <Kanvas h={h}>
      <rect x={0} y={0} width={ISI} height={h} rx={20} fill={c.ink} opacity={0.06 + cerah * 0.04} />
      <line x1={30} y1={h - 60} x2={ISI - 30} y2={h - 60} stroke={c.ink} strokeWidth={4} />
      {[0.12, 0.32, 0.55, 0.78, 0.95].map((x, k) => (
        <circle key={k} cx={x * ISI} cy={h - 60} r={10 + (k === 4 ? cerah * 8 : 0)} fill={c.ink} opacity={p(f, 20 + k * 12, 40 + k * 12)} />
      ))}
      <g opacity={cerah}>
        <circle cx={0.95 * ISI} cy={h - 140} r={70} fill={c.ink} opacity={0.1} />
        <Tx x={0.95 * ISI - 200} y={h - 140} s="keadilan kembali" u={24} w={c.ink} bobot={600} />
      </g>
    </Kanvas>
  );
};

export const VIS2: Record<string, { Vis?: React.FC<VisProps>; tinggi?: number }> = {
  "dua-tugas": { Vis: DuaTugas, tinggi: 340 },
  cara: { Vis: CaraSampaikan, tinggi: 300 },
  "tiga-perusak": { Vis: TigaPerusak, tinggi: 340 },
  wadah: { Vis: WadahDua, tinggi: 340 },
  "kenali-wadah": { Vis: KenaliWadah, tinggi: 300 },
  "dua-tanda": { Vis: DuaTanda, tinggi: 380 },
  kode: { Vis: Kode, tinggi: 330 },
  kendali: { Vis: DuaKendali, tinggi: 300 },
  "kendali-ilmu": { Vis: KendaliIlmu2, tinggi: 360 },
  "kendali-kuasa": { Vis: KendaliKuasa, tinggi: 360 },
  "dua-keranjang": { Vis: DuaKeranjang2, tinggi: 360 },
  simpul: { Vis: Simpul, tinggi: 320 },
  "tiga-garis": { Vis: (pp) => <TigaGaris {...pp} sorot={1} />, tinggi: 320 },
  "garis-kecil": { Vis: (pp) => <TigaGaris {...pp} sorot={2} />, tinggi: 320 },
  "garis-tengah": { Vis: GarisTengah, tinggi: 300 },
  "garis-besar": { Vis: GarisBesar, tinggi: 260 },
  bertumpuk: { Vis: Bertumpuk, tinggi: 300 },
  "jalan-umat": { Vis: JalanUmat, tinggi: 320 },
  "peta-fase": { Vis: PetaFase, tinggi: 300 },
  payung: { Vis: Payung, tinggi: 300 },
  buih: { Vis: Buih, tinggi: 300 },
  wahn: { Vis: Wahn, tinggi: 360 },
  "tanpa-payung": { Vis: TanpaPayung, tinggi: 340 },
  "lima-babak": { Vis: LimaBabak, tinggi: 400 },
  "satu-rangkaian": { Vis: SatuRangkaian, tinggi: 320 },
  "posisi-kita": { Vis: PosisiKita2, tinggi: 280 },
  terang: { Vis: Terang, tinggi: 260 },
};
void Muncul;
void Zaman;
void EmpatTiang;
void Mobil;
void GarisWaktu;
void TEPI;
