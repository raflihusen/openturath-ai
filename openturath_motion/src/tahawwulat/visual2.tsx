import { Img, staticFile, useCurrentFrame } from "remotion";
import { HURUF } from "../tema";
import { Ar, Jalur, Tx, acak, gayaArab, lembut, mihrab, mix, p } from "./kit";
import { Buku, Orang, centang, hati, perisai, rumah, silang } from "./ikon";
import { Kanvas, Jarum, type Vis } from "./visual1";

// ── Bab 6 · Zaman buih ────────────────────────────────────────────────

/** Buih: banyak gelembung di atas arus, semuanya terseret ke kanan. */
const Buih: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const arus = (y: number, fase: number) =>
    Array.from({ length: 47 })
      .map((_, k) => `${k ? "L" : "M"}${k * 20} ${y + Math.sin(k / 3 + f / 8 + fase) * 10}`)
      .join(" ");
  return (
    <Kanvas h={h}>
      {[0, 1, 2].map((k) => (
        <path key={k} d={arus(h - 60 + k * 22, k)} fill="none" stroke={c.line} strokeWidth={3} opacity={p(f, 0, 15)} />
      ))}
      {Array.from({ length: 90 }).map((_, k) => {
        const r = 6 + acak(k) * 16;
        const x = ((acak(k + 9) * 1000 + f * (2 + acak(k + 3) * 3)) % 1000) - 40;
        const y = h - 80 - acak(k + 21) * (h - 120) + Math.sin((f + k * 7) / 9) * 6;
        return <circle key={k} cx={x} cy={y} r={r} fill="none" stroke={c.muted} strokeWidth={1.8} opacity={p(f, k * 0.5, 10 + k * 0.5) * 0.85} />;
      })}
    </Kanvas>
  );
};

/** Al-wahn: dua beban di hati menarik sosok hingga tertunduk. */
const Wahn: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const tarik = p(f, 20, 80, lembut);
  const cx = 460;
  const y = 170;
  return (
    <Kanvas h={h}>
      <g transform={`rotate(${tarik * 12} ${cx} ${y + 60})`}>
        <Orang x={cx} y={y} u={2} w={c.ink} isi={c.surface} />
      </g>
      {[-1, 1].map((sisi) => {
        const bx = cx + sisi * 250;
        const by = mix(y + 20, y + 150, tarik);
        return (
          <g key={sisi}>
            <line x1={cx + sisi * 40} y1={y + 10} x2={bx} y2={by - 40} stroke={c.ink} strokeWidth={2.5} />
            <path d={`M${bx - 60} ${by - 40} H${bx + 60} L${bx + 80} ${by + 40} H${bx - 80} Z`} fill={c.ink} />
            <Ar x={bx} y={by + 4} s={sisi < 0 ? "حب الدنيا" : "كراهية الموت"} u={30} w={c.onInk} />
          </g>
        );
      })}
      <Ar x={110} y={50} s="الْوَهْن" u={56} w={c.ink} o={p(f, 60, 80)} />
    </Kanvas>
  );
};

/** Lima babak: tangga menurun; tiap babak turun satu anak tangga, makin gelap. */
const LimaBabak: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const babak = s.rukun!;
  const tinggi = 118;
  return (
    <Kanvas h={h}>
      {babak.map((b, k) => {
        const t = p(f, 10 + k * 26, 34 + k * 26, lembut);
        const x = k * 70;
        const y = 10 + k * (tinggi + 18);
        const isi = [c.surface, c.subtle, c.line, c.faint, c.ink][k];
        const tulis = k >= 3 ? c.onInk : c.ink;
        const sub = k >= 3 ? c.onInk : c.muted;
        return (
          <g key={b.nama} opacity={t} transform={`translate(${(1 - t) * -40} 0)`}>
            <rect x={x} y={y} width={920 - x} height={tinggi} rx={20} fill={isi} />
            <Tx x={x + 30} y={y + 38} s={`${k + 1}. ${b.nama}`} a="start" u={28} bobot={600} w={tulis} />
            <Ar x={890} y={y + 40} s={b.arab} u={36} w={tulis} a="end" />
            <Tx x={x + 30} y={y + 84} s={b.ilmu} a="start" u={21} w={sub} />
            {k < 4 && <path d={`M${x + 50} ${y + tinggi + 2} v14 m-8 -8 l8 8 l8 -8`} stroke={c.faint} strokeWidth={2.5} fill="none" strokeLinecap="round" />}
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Al-istihtar: dua kubu ideologi tarik-menarik; umat di tengah menjadi korban. */
const Istihtar: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const goyang = Math.sin(f / 7) * 30 * p(f, 20, 40);
  const cx = 460 + goyang;
  const y = h / 2;
  return (
    <Kanvas h={h}>
      <rect x={20} y={y - 70} width={180} height={140} rx={20} fill={c.ink} />
      <Tx x={110} y={y} s="Ideologi Barat" u={22} bobot={600} w={c.onInk} />
      <rect x={720} y={y - 70} width={180} height={140} rx={20} fill={c.ink} />
      <Tx x={810} y={y} s="Ideologi Timur" u={22} bobot={600} w={c.onInk} />
      <line x1={200} y1={y} x2={cx - 50} y2={y} stroke={c.ink} strokeWidth={4} strokeDasharray="12 8" />
      <line x1={cx + 50} y1={y} x2={720} y2={y} stroke={c.ink} strokeWidth={4} strokeDasharray="12 8" />
      <circle cx={cx} cy={y} r={50} fill={c.surface} stroke={c.ink} strokeWidth={3} />
      <Ar x={cx} y={y + 2} s="الأمة" u={32} w={c.ink} />
      <Tx x={460} y={y + 100} s="Islam dan kaum muslimin menjadi korban" u={23} w={c.muted} o={p(f, 50, 70)} />
    </Kanvas>
  );
};

// ── Bab 7 · Luka dari dalam ────────────────────────────────────────────

/** Adu domba: retakan menjalar dari kecil sampai membelah barisan. */
const Tahrisy: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const tahap = s.poin!;
  const belah = p(f, 100, 130, lembut);
  return (
    <Kanvas h={h}>
      {Array.from({ length: 10 }).map((_, k) => {
        const kiri = k < 5;
        const x = 70 + k * 88 + (kiri ? -1 : 1) * belah * 40;
        return <Orang key={k} x={x} y={h - 50} u={0.9} w={c.ink} isi={c.surface} o={p(f, 0, 15)} />;
      })}
      {tahap.map((t, k) => {
        const y = 30 + k * 62;
        const muncul = p(f, 15 + k * 20, 30 + k * 20);
        const akhir = k === tahap.length - 1;
        return (
          <g key={t} opacity={muncul}>
            <rect x={300} y={y - 24} width={320} height={48} rx={24} fill={akhir ? c.ink : c.surface} stroke={c.line} strokeWidth={1.5} />
            <Tx x={460} y={y} s={t} u={23} bobot={akhir ? 600 : 400} w={akhir ? c.onInk : c.ink} />
          </g>
        );
      })}
      <Jalur d={`M460 ${h - 150} L448 ${h - 120} L470 ${h - 95} L452 ${h - 60} L466 ${h - 20}`} t={p(f, 30, 110)} warna={c.ink} tebal={3 + belah * 3} />
    </Kanvas>
  );
};

/** Lebih dari air, makanan, dan obat: ilmu ini paling penuh. */
const AirMakanan: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const item = ["Air", "Makanan", "Obat", "Fikih Tahawwulat"];
  const tinggiMaks = h - 110;
  return (
    <Kanvas h={h}>
      {item.map((n, k) => {
        const x = 60 + k * 215;
        const target = k === 3 ? 1 : 0.62 - k * 0.04;
        const t = p(f, 10 + k * 15, 60 + k * 15, lembut) * target;
        const akhir = k === 3;
        return (
          <g key={n}>
            <rect x={x} y={10} width={150} height={tinggiMaks} rx={22} fill="none" stroke={c.line} strokeWidth={2.5} />
            <rect x={x + 6} y={10 + tinggiMaks - (tinggiMaks - 12) * t - 6} width={138} height={(tinggiMaks - 12) * t} rx={16} fill={akhir ? c.ink : c.faint} />
            <Tx x={x + 75} y={h - 50} s={n} u={akhir ? 22 : 24} bobot={600} w={c.ink} />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Salep untuk luka: lima sendi kehidupan diberi plester satu per satu. */
const Marham: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const sendi = s.poin!;
  return (
    <Kanvas h={h}>
      {sendi.map((n, k) => {
        const x = 92 + k * 184;
        const y = 150;
        const obat = p(f, 40 + k * 20, 60 + k * 20, lembut);
        return (
          <g key={n} opacity={p(f, k * 6, 15 + k * 6)}>
            <circle cx={x} cy={y} r={70} fill={c.surface} stroke={obat > 0.9 ? c.ink : c.line} strokeWidth={3} />
            <path d={`M${x - 26} ${y - 22} L${x - 6} ${y} L${x - 18} ${y + 14} L${x + 10} ${y + 30}`} stroke={c.ink} strokeWidth={3} fill="none" opacity={1 - obat} strokeLinecap="round" />
            <g transform={`rotate(-35 ${x} ${y}) translate(0 ${(1 - obat) * -60})`} opacity={obat}>
              <rect x={x - 46} y={y - 15} width={92} height={30} rx={15} fill={c.ink} />
              <rect x={x - 14} y={y - 10} width={28} height={20} rx={4} fill={c.faint} />
            </g>
            <Tx x={x} y={y + 108} s={n} u={22} bobot={600} w={c.ink} />
            {obat > 0.95 && <path d={centang(x + 54, y - 54, 0.9)} stroke={c.ink} strokeWidth={4} fill="none" strokeLinecap="round" />}
          </g>
        );
      })}
    </Kanvas>
  );
};

// ── Bab 8 · Fitnah Dajjal ──────────────────────────────────────────────

/** Tiga lapis: sosok (titik inti), sistem (cincin), para pendusta (titik luar). */
const Dajjal: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const cx = 230;
  const cy = h / 2;
  const lapis = s.rukun!;
  return (
    <Kanvas h={h}>
      <circle cx={cx} cy={cy} r={mix(0, 150, p(f, 50, 80))} fill="none" stroke={c.line} strokeWidth={2} strokeDasharray="6 8" />
      {Array.from({ length: 14 }).map((_, k) => {
        const a = (k / 14) * Math.PI * 2 + f / 90;
        return <circle key={k} cx={cx + Math.cos(a) * 150} cy={cy + Math.sin(a) * 150} r={7} fill={c.muted} opacity={p(f, 70 + k * 2, 85 + k * 2)} />;
      })}
      <circle cx={cx} cy={cy} r={mix(0, 95, p(f, 25, 55))} fill="none" stroke={c.muted} strokeWidth={6} />
      <circle cx={cx} cy={cy} r={mix(0, 36, p(f, 0, 25))} fill={c.ink} />
      {lapis.map((l, k) => (
        <g key={l.nama} opacity={p(f, k * 25 + 10, k * 25 + 30)}>
          <line x1={cx + [36, 95, 150][k]} y1={cy} x2={460} y2={50 + k * 100} stroke={c.line} strokeWidth={1.5} />
          <Ar x={900} y={42 + k * 100} s={l.arab} u={30} w={c.ink} a="end" />
          <Tx x={470} y={44 + k * 100} s={l.nama} a="start" u={26} bobot={600} w={c.ink} />
          <Tx x={470} y={80 + k * 100} s={l.ilmu} a="start" u={20} w={c.muted} />
        </g>
      ))}
    </Kanvas>
  );
};

/** Rekayasa: tangan-tangan tak terlihat memasang benang pada enam sendi kehidupan. */
const Rekayasa: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const sendi = s.poin!;
  return (
    <Kanvas h={h}>
      <rect x={160} y={10} width={600} height={30} rx={15} fill={c.subtle} opacity={p(f, 0, 15)} />
      {sendi.map((n, k) => {
        const kol = k % 3;
        const bar = Math.floor(k / 3);
        const x = 160 + kol * 300;
        const y = 190 + bar * 150;
        const tarik = p(f, 20 + k * 12, 50 + k * 12);
        const ayun = Math.sin((f + k * 20) / 10) * 8 * tarik;
        return (
          <g key={n}>
            <line x1={x + ayun * 0.2} y1={40} x2={x + ayun} y2={mix(40, y - 40, tarik)} stroke={c.faint} strokeWidth={1.5} />
            <g transform={`translate(${ayun} 0)`} opacity={tarik}>
              <rect x={x - 110} y={y - 40} width={220} height={80} rx={20} fill={c.surface} stroke={c.line} strokeWidth={2} />
              <Tx x={x} y={y} s={n} u={26} bobot={600} w={c.ink} />
            </g>
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Vaksin: virus berdatangan, perisai menangkis. */
const Vaksin: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const cx = 460;
  const cy = h / 2;
  return (
    <Kanvas h={h}>
      <Orang x={cx} y={cy + 30} u={1.4} w={c.ink} isi={c.surface} />
      <circle cx={cx} cy={cy} r={mix(40, 120, p(f, 10, 40))} fill="none" stroke={c.ink} strokeWidth={4} opacity={p(f, 10, 25)} />
      {Array.from({ length: 12 }).map((_, k) => {
        const a = (k / 12) * Math.PI * 2;
        const siklus = ((f + k * 11) % 60) / 60;
        const r = mix(420, 130, Math.min(1, siklus * 1.3)) + (siklus > 0.77 ? (siklus - 0.77) * 300 : 0);
        const x = cx + Math.cos(a) * r;
        const y = cy + Math.sin(a) * r * 0.42;
        return (
          <g key={k} opacity={p(f, 20, 30) * (1 - Math.max(0, siklus - 0.77) * 4)}>
            <circle cx={x} cy={y} r={11} fill={c.muted} />
            {[0, 1, 2, 3].map((j) => (
              <line key={j} x1={x} y1={y} x2={x + Math.cos(j * 1.57) * 18} y2={y + Math.sin(j * 1.57) * 18} stroke={c.muted} strokeWidth={2.5} />
            ))}
          </g>
        );
      })}
    </Kanvas>
  );
};

// ── Bab 9 · Sikap seorang muslim ───────────────────────────────────────

/** Dua sunnah: dua orang yang berselisih didamaikan; sarana dakwah ditimbang. */
const DuaSunnah: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const damai = p(f, 30, 80, lembut);
  return (
    <Kanvas h={h}>
      <rect x={0} y={0} width={440} height={h} rx={24} fill={c.surface} />
      <rect x={480} y={0} width={440} height={h} rx={24} fill={c.surface} />
      <Orang x={mix(110, 170, damai)} y={h / 2 + 40} u={1.1} w={c.ink} isi={c.subtle} />
      <Orang x={mix(330, 270, damai)} y={h / 2 + 40} u={1.1} w={c.ink} isi={c.subtle} />
      <path d={silang(220, h / 2 - 40, 16)} stroke={c.ink} strokeWidth={4} opacity={1 - damai} strokeLinecap="round" />
      <path d={hati(220, h / 2 - 40, 0.5)} fill={c.ink} opacity={damai} />
      {(() => {
        const ok = p(f, 40, 60);
        return (
          <g>
            <rect x={540} y={60} width={140} height={60} rx={14} fill={c.ink} opacity={ok} />
            <Tx x={610} y={90} s="Dipakai" u={22} bobot={600} w={c.onInk} o={ok} />
            <rect x={720} y={60} width={140} height={60} rx={14} fill="none" stroke={c.line} strokeWidth={2} opacity={ok} />
            <Tx x={790} y={90} s="Ditinggal" u={22} w={c.muted} o={ok} />
            <circle cx={mix(700, 610, p(f, 60, 90))} cy={mix(h - 50, 150, p(f, 60, 90))} r={16} fill={c.ink} />
          </g>
        );
      })()}
    </Kanvas>
  );
};

/** Sayyidina Hasan: dua barisan berhadapan; mahkota diletakkan; garis bertemu. */
const Hasan: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const lepas = p(f, 30, 70, lembut);
  const satu = p(f, 70, 120, lembut);
  const y = h - 60;
  return (
    <Kanvas h={h}>
      {Array.from({ length: 4 }).map((_, k) => (
        <Orang key={`a${k}`} x={mix(60 + k * 70, 150 + k * 70, satu)} y={y} u={0.85} w={c.ink} isi={c.surface} />
      ))}
      {Array.from({ length: 4 }).map((_, k) => (
        <Orang key={`b${k}`} x={mix(650 + k * 70, 560 + k * 70, satu)} y={y} u={0.85} w={c.ink} isi={c.surface} />
      ))}
      <g transform={`translate(${mix(460, 460, lepas)} ${mix(60, 200, lepas)})`} opacity={1 - satu * 0.7}>
        <path d="M-50 20 L-50 -20 L-25 0 L0 -30 L25 0 L50 -20 L50 20 Z" fill={c.ink} />
      </g>
      <path d={hati(460, 120, 0.9)} fill={c.ink} opacity={satu} transform={`translate(0 ${(1 - satu) * 20})`} />
    </Kanvas>
  );
};

/** Manhaj as-salamah: lisan dan tangan dikelilingi lingkaran keselamatan. */
const Salamah: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const kolom = [230, 690];
  return (
    <Kanvas h={h}>
      {kolom.map((x, k) => {
        const t = p(f, 10 + k * 20, 50 + k * 20, lembut);
        return (
          <g key={x}>
            <circle cx={x} cy={h / 2} r={86} fill="none" stroke={c.ink} strokeWidth={5} pathLength={1} strokeDasharray="1 1" strokeDashoffset={1 - t} transform={`rotate(-90 ${x} ${h / 2})`} />
            {k === 0 ? (
              <path d={`M${x - 40} ${h / 2} Q${x} ${h / 2 + 34} ${x + 40} ${h / 2} Q${x} ${h / 2 + 10} ${x - 40} ${h / 2} Z`} fill={c.ink} />
            ) : (
              <path d={`M${x - 26} ${h / 2 + 30} V${h / 2 - 10} Q${x - 26} ${h / 2 - 36} ${x - 12} ${h / 2 - 36} V${h / 2 - 6} M${x - 12} ${h / 2 - 36} Q${x} ${h / 2 - 44} ${x + 4} ${h / 2 - 30} V${h / 2 - 6} M${x + 4} ${h / 2 - 34} Q${x + 18} ${h / 2 - 38} ${x + 20} ${h / 2 - 24} V${h / 2 + 30} Z`} fill={c.surface} stroke={c.ink} strokeWidth={3} strokeLinejoin="round" />
            )}
            <g opacity={t}>
              <circle cx={x + 70} cy={h / 2 - 66} r={22} fill={c.ink} />
              <path d={centang(x + 70, h / 2 - 66, 0.75)} stroke={c.onInk} strokeWidth={4} fill="none" strokeLinecap="round" />
            </g>
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Jalan tengah: titik yang tertinggal menyusul, titik yang berlebih kembali. */
const Namath: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const t = p(f, 30, 100, lembut);
  const y = h / 2;
  return (
    <Kanvas h={h}>
      <line x1={20} y1={y} x2={900} y2={y} stroke={c.line} strokeWidth={3} />
      <rect x={340} y={y - 50} width={240} height={100} rx={50} fill={c.ink} opacity={p(f, 0, 20)} />
      <Ar x={460} y={y} s="النَّمَطُ الْأَوْسَط" u={32} w={c.onInk} o={p(f, 10, 25)} />
      <Tx x={100} y={y - 60} s="Yang tertinggal" u={22} w={c.muted} o={p(f, 10, 25)} />
      <Tx x={820} y={y - 60} s="Yang berlebihan" u={22} w={c.muted} o={p(f, 10, 25)} />
      {Array.from({ length: 5 }).map((_, k) => (
        <circle key={`k${k}`} cx={mix(40 + k * 40, 360 + k * 6, t * (0.6 + k * 0.08))} cy={y + (k - 2) * 14} r={10} fill={c.muted} />
      ))}
      {Array.from({ length: 5 }).map((_, k) => (
        <circle key={`n${k}`} cx={mix(880 - k * 40, 560 - k * 6, t * (0.6 + k * 0.08))} cy={y + (k - 2) * 14} r={10} fill={c.muted} />
      ))}
    </Kanvas>
  );
};

/** Al-khuwaishah: badai di luar; rumah tetap terang di tengah. */
const Khuwaishah: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const cx = 460;
  const cy = h / 2 + 20;
  const lingkar = p(f, 20, 60, lembut);
  return (
    <Kanvas h={h}>
      {Array.from({ length: 50 }).map((_, k) => {
        const a = acak(k) * Math.PI * 2 + f / 30;
        const r = 210 + acak(k + 5) * 200;
        const x = cx + Math.cos(a) * r;
        const y = cy + Math.sin(a) * r * 0.4;
        return <line key={k} x1={x} y1={y} x2={x - 20} y2={y + 6} stroke={c.faint} strokeWidth={2} opacity={0.8} />;
      })}
      <circle cx={cx} cy={cy} r={mix(0, 160, lingkar)} fill={c.surface} stroke={c.ink} strokeWidth={4} />
      <path d={rumah(cx, cy - 10, 1.4)} fill={c.ink} opacity={p(f, 40, 60)} />
      <rect x={cx - 12} y={cy + 4} width={24} height={28} rx={4} fill={c.surface} opacity={p(f, 50, 65) * (0.7 + Math.sin(f / 8) * 0.3)} />
      {[-1, 0, 1].map((k) => (
        <Orang key={k} x={cx + k * 46} y={cy + 110} u={0.55} w={c.ink} isi={c.subtle} o={p(f, 60 + (k + 1) * 6, 75 + (k + 1) * 6)} />
      ))}
    </Kanvas>
  );
};

/** Teknologi: layar ponsel berganti isi, dari silang menjadi buku. */
const Teknologi: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const ubah = p(f, 50, 80, lembut);
  const cx = 460;
  return (
    <Kanvas h={h}>
      <rect x={cx - 110} y={10} width={220} height={h - 30} rx={36} fill={c.surface} stroke={c.ink} strokeWidth={4} />
      <rect x={cx - 30} y={26} width={60} height={10} rx={5} fill={c.line} />
      <g opacity={1 - ubah}>
        {[0, 1, 2].map((k) => (
          <g key={k}>
            <rect x={cx - 80} y={70 + k * 80} width={160} height={60} rx={14} fill={c.subtle} />
            <path d={silang(cx + 50, 100 + k * 80, 10)} stroke={c.ink} strokeWidth={3} />
          </g>
        ))}
      </g>
      <g opacity={ubah}>
        <Buku x={cx} y={150} u={1.4} w={c.ink} isi={c.subtle} />
        <rect x={cx - 80} y={230} width={160} height={14} rx={7} fill={c.line} />
        <rect x={cx - 60} y={258} width={120} height={14} rx={7} fill={c.line} />
      </g>
      <Tx x={140} y={h / 2} s="Alat fitnah" u={26} bobot={600} w={c.ink} o={1 - ubah * 0.7} />
      <Tx x={780} y={h / 2} s="Mimbar petunjuk" u={26} bobot={600} w={c.ink} o={0.3 + ubah * 0.7} />
    </Kanvas>
  );
};

/** Sejarah: kaca pembesar menyapu garis waktu; titik keruh menjadi jernih. */
const Sejarah: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const sapu = p(f, 10, 70, lembut);
  const y = h / 2;
  const lx = mix(60, 860, sapu);
  return (
    <Kanvas h={h}>
      <line x1={40} y1={y} x2={880} y2={y} stroke={c.ink} strokeWidth={3} />
      {Array.from({ length: 9 }).map((_, k) => {
        const x = 70 + k * 98;
        const jernih = lx > x;
        return <circle key={k} cx={x} cy={y} r={14} fill={jernih ? c.ink : c.surface} stroke={jernih ? c.ink : c.faint} strokeWidth={3} strokeDasharray={jernih ? "0" : "4 4"} />;
      })}
      <g transform={`translate(${lx} ${y - 10})`}>
        <circle r={56} fill="none" stroke={c.ink} strokeWidth={5} />
        <line x1={40} y1={40} x2={80} y2={80} stroke={c.ink} strokeWidth={8} strokeLinecap="round" />
      </g>
    </Kanvas>
  );
};

/** Tetap menanam: bibit ditanam, tunas tumbuh menjadi pohon kurma. */
const Tenang: Vis = ({ c, h }) => {
  const f = useCurrentFrame();
  const tumbuh = p(f, 20, 90, lembut);
  const cx = 460;
  const dasar = h - 30;
  const batang = mix(0, 190, tumbuh);
  return (
    <Kanvas h={h}>
      <path d={`M140 ${dasar} H780`} stroke={c.ink} strokeWidth={3} />
      <path d={`M${cx - 70} ${dasar} Q${cx} ${dasar - 26} ${cx + 70} ${dasar}`} fill={c.subtle} />
      <circle cx={cx} cy={mix(dasar - 120, dasar - 6, p(f, 0, 20))} r={9} fill={c.ink} opacity={1 - tumbuh} />
      <path d={`M${cx} ${dasar} Q${cx + 10} ${dasar - batang / 2} ${cx} ${dasar - batang}`} stroke={c.ink} strokeWidth={7} fill="none" strokeLinecap="round" />
      {Array.from({ length: 7 }).map((_, k) => {
        const a = -Math.PI + (k / 6) * Math.PI;
        const pj = 110 * p(f, 60 + k * 4, 100 + k * 4);
        const tx = cx + Math.cos(a) * pj;
        const ty = dasar - batang - 10 + Math.sin(a) * pj * 0.6 + pj * 0.25;
        return <path key={k} d={`M${cx} ${dasar - batang} Q${(cx + tx) / 2} ${dasar - batang - 40} ${tx} ${ty}`} stroke={c.ink} strokeWidth={5} fill="none" strokeLinecap="round" />;
      })}
    </Kanvas>
  );
};

// ── Bab 10 · Manfaat ───────────────────────────────────────────────────

/** Enam manfaat: kisi 2 x 3, tiap kartu dengan ikon bergerak sendiri. */
const Manfaat: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const r = s.rukun!;
  const ikon = (k: number, x: number, y: number, t: number) => {
    switch (k) {
      case 0:
        return (
          <g>
            <circle cx={x} cy={y} r={34} fill="none" stroke={c.ink} strokeWidth={3} />
            <Jarum x={x} y={y} r={26} c={c} tenang={t} f={f} />
          </g>
        );
      case 1:
        return <path d={perisai(x, y, 0.75)} fill={c.ink} />;
      case 2:
        return <path d={hati(x, y, 0.75)} fill={c.ink} />;
      case 3:
        return (
          <g>
            <path d={`M${x - 30} ${y - 26} C${x - 36} ${y + 4} ${x - 24} ${y + 30} ${x} ${y + 30} C${x + 24} ${y + 30} ${x + 36} ${y + 4} ${x + 30} ${y - 26}`} fill="none" stroke={c.ink} strokeWidth={4} />
            <rect x={x - 28} y={y + 30 - 46 * t} width={56} height={46 * t} rx={6} fill={c.ink} />
          </g>
        );
      case 4:
        return (
          <g>
            <rect x={x - 22} y={y - 36} width={44} height={72} rx={9} fill="none" stroke={c.ink} strokeWidth={3} />
            <Buku x={x} y={y} u={0.35} w={c.ink} />
          </g>
        );
      default:
        return (
          <g>
            <circle cx={x - 6} cy={y - 6} r={24} fill="none" stroke={c.ink} strokeWidth={4} />
            <line x1={x + 12} y1={y + 12} x2={x + 30} y2={y + 30} stroke={c.ink} strokeWidth={6} strokeLinecap="round" />
          </g>
        );
    }
  };
  return (
    <Kanvas h={h}>
      {r.map((b, k) => {
        const kol = k % 2;
        const bar = Math.floor(k / 2);
        const x = kol * 470;
        const y = bar * 276;
        const t = p(f, 10 + k * 25, 40 + k * 25, lembut);
        return (
          <g key={b.nama} opacity={t} transform={`translate(0 ${(1 - t) * 30})`}>
            <rect x={x} y={y} width={450} height={256} rx={24} fill={c.surface} />
            {ikon(k, x + 70, y + 74, t)}
            <Tx x={x + 128} y={y + 74} s={`0${k + 1}`} u={22} bobot={600} w={c.faint} a="start" />
            <Tx x={x + 30} y={y + 150} s={b.nama} a="start" u={30} bobot={600} w={c.ink} />
            <Ar x={x + 424} y={y + 74} s={b.arab} u={28} w={c.muted} a="end" />
            {b.ilmu.split(" ").reduce<string[]>((acc, kata) => {
              const akhir = acc[acc.length - 1];
              if (akhir !== undefined && (akhir + " " + kata).length <= 28) acc[acc.length - 1] = akhir + " " + kata;
              else acc.push(kata);
              return acc;
            }, []).map((baris, j) => (
              <Tx key={j} x={x + 30} y={y + 192 + j * 30} s={baris} a="start" u={22} w={c.muted} />
            ))}
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Sebelum dan sesudah: tiap baris berbalik dari kiri (keruh) ke kanan (jernih). */
const SebelumSesudah: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const r = s.rukun!;
  const tinggi = 136;
  return (
    <Kanvas h={h}>
      <Tx x={340} y={20} s="SEBELUM" u={20} bobot={600} w={c.muted} />
      <Tx x={720} y={20} s="SESUDAH" u={20} bobot={600} w={c.ink} />
      {r.map((b, k) => {
        const [sebelum, sesudah] = b.ilmu.split("|");
        const y = 56 + k * (tinggi + 18);
        const muncul = p(f, 10 + k * 30, 30 + k * 30);
        const balik = p(f, 30 + k * 30, 55 + k * 30, lembut);
        return (
          <g key={b.nama} opacity={muncul}>
            {b.nama.split(" ").map((kata, j, arr) => (
              <Tx key={j} x={0} y={y + tinggi / 2 + (j - (arr.length - 1) / 2) * 30} s={kata} a="start" u={24} bobot={600} w={c.ink} />
            ))}
            <rect x={190} y={y} width={300} height={tinggi} rx={20} fill={c.subtle} />
            <path d={silang(222, y + 30, 9)} stroke={c.muted} strokeWidth={3} strokeLinecap="round" />
            <Tx x={340} y={y + tinggi / 2 + 10} s={sebelum} u={22} w={c.muted} />
            <path d={`M500 ${y + tinggi / 2} h${mix(0, 50, balik)}`} stroke={c.ink} strokeWidth={3} />
            <g opacity={balik} transform={`translate(${(1 - balik) * -30} 0)`}>
              <rect x={570} y={y} width={300} height={tinggi} rx={20} fill={c.ink} />
              <path d={centang(604, y + 30, 0.7)} stroke={c.onInk} strokeWidth={3.5} fill="none" strokeLinecap="round" />
              <Tx x={720} y={y + tinggi / 2 + 10} s={sesudah} u={22} bobot={600} w={c.onInk} />
            </g>
          </g>
        );
      })}
    </Kanvas>
  );
};

// ── Bab 11 · Mulai belajar ─────────────────────────────────────────────

/** Urutan kitab: tangga naik; penanda pembaca melangkah dari kitab pertama. */
const Kitab: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const r = s.rukun!;
  const anak = 112;
  return (
    <Kanvas h={h}>
      {r.map((b, k) => {
        const x = k * 70;
        const y = h - (k + 1) * (anak + 10);
        const t = p(f, 10 + k * 22, 35 + k * 22, lembut);
        const akhir = k === r.length - 1;
        return (
          <g key={b.nama} opacity={t} transform={`translate(0 ${(1 - t) * 24})`}>
            <rect x={x} y={y} width={920 - x} height={anak} rx={20} fill={akhir ? c.ink : c.surface} />
            <Tx x={x + 30} y={y + 38} s={`${k + 1}. ${b.nama}`} a="start" u={27} bobot={600} w={akhir ? c.onInk : c.ink} />
            <Tx x={x + 30} y={y + 78} s={b.ilmu} a="start" u={21} w={akhir ? c.onInk : c.muted} />
            <Ar x={890} y={y + 46} s={b.arab} u={32} w={akhir ? c.onInk : c.ink} a="end" />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Lima AI: satu sumber di tengah, lima lengkung mihrab menyala bergiliran. */
const LimaAi: Vis = ({ s, c, h }) => {
  const f = useCurrentFrame();
  const nama = s.rukun ?? [];
  const giliran = Math.floor(Math.max(0, f - 50) / 24) % 5;
  return (
    <Kanvas h={h}>
      <rect x={260} y={h - 64} width={400} height={60} rx={30} fill={c.ink} opacity={p(f, 0, 15)} />
      <Tx x={460} y={h - 34} s="Kitab dan muhadharah beliau" u={22} bobot={600} w={c.onInk} o={p(f, 0, 15)} />
      {nama.map((n, k) => {
        const x = 92 + k * 184;
        const t = p(f, 10 + k * 8, 40 + k * 8);
        const nyala = f > 50 && k === giliran;
        return (
          <g key={n.nama}>
            <line x1={460} y1={h - 64} x2={x} y2={230} stroke={nyala ? c.ink : c.line} strokeWidth={nyala ? 3 : 1.5} opacity={t} />
            <path d={mihrab(x, 180, 130) + " Z"} fill={nyala ? c.ink : c.surface} stroke={c.ink} strokeWidth={3} opacity={t} />
            <Ar x={x} y={120} s={n.arab} u={28} w={nyala ? c.onInk : c.ink} o={t} />
            <Tx x={x} y={214} s={n.nama} u={21} bobot={600} w={c.ink} o={t} />
          </g>
        );
      })}
    </Kanvas>
  );
};

/** Penutup: tiga kata kunci, lengkung, dan logo. */
const Penutup: Vis = ({ s, c }) => {
  const f = useCurrentFrame();
  const kata = ["Memahami zaman", "Menjaga iman", "Menyebar kedamaian"];
  return (
    <>
      <Kanvas h={1350} w={1080}>
        <Jalur d={mihrab(540, 640, 420)} t={p(f, 0, 50)} warna={c.faint} tebal={3} />
      </Kanvas>
      <div style={{ position: "absolute", left: 0, right: 0, top: 290, display: "flex", justifyContent: "center", opacity: p(f, 30, 55) }}>
        <Img src={staticFile("logo_putih.png")} style={{ width: 150, height: 150 }} />
      </div>
      <div style={{ position: "absolute", left: 80, right: 80, top: 700, textAlign: "center" }}>
        {kata.map((k, i) => (
          <div key={k} style={{ fontFamily: HURUF.serif, fontSize: 64, lineHeight: 1.18, color: c.ink, opacity: p(f, 50 + i * 15, 70 + i * 15), transform: `translateY(${(1 - p(f, 50 + i * 15, 80 + i * 15)) * 20}px)` }}>
            {k}
          </div>
        ))}
        <div style={{ fontFamily: HURUF.ui, fontSize: 30, lineHeight: 1.45, color: c.muted, marginTop: 34, opacity: p(f, 110, 135) }}>{s.sub}</div>
        <div style={{ ...gayaArab(48, c.ink), lineHeight: 1.4, marginTop: 30, opacity: p(f, 135, 160) }}>{s.arab}</div>
      </div>
    </>
  );
};

export const VISUAL_2: Record<string, Vis> = {
  buih: Buih,
  wahn: Wahn,
  limababak: LimaBabak,
  istihtar: Istihtar,
  tahrisy: Tahrisy,
  airmakanan: AirMakanan,
  marham: Marham,
  dajjal: Dajjal,
  rekayasa: Rekayasa,
  vaksin: Vaksin,
  duasunnah: DuaSunnah,
  hasan: Hasan,
  salamah: Salamah,
  namath: Namath,
  khuwaishah: Khuwaishah,
  teknologi: Teknologi,
  sejarah: Sejarah,
  tenang: Tenang,
  manfaat: Manfaat,
  sebelumsesudah: SebelumSesudah,
  kitab: Kitab,
  limaai: LimaAi,
  penutup: Penutup,
};

