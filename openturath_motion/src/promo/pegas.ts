// Pegas dalam bentuk tertutup (respons langkah). Nilai yang berganti target
// berkali-kali adalah jumlah satu pegas per perubahan, jadi tetap fungsi murni dari waktu.
export const step = (t: number, w = 30, z = 0.85): number => {
  if (t <= 0) return 0;
  if (z >= 1) return 1 - Math.exp(-w * t) * (1 + w * t);
  const wd = w * Math.sqrt(1 - z * z);
  const e = Math.exp(-z * w * t);
  return 1 - e * (Math.cos(wd * t) + ((z * w) / wd) * Math.sin(wd * t));
};
export type Key = { t: number; v: number; w?: number; z?: number };
export const chan = (t: number, v0: number, keys: Key[], w = 30, z = 0.85): number => {
  let v = v0;
  let p = v0;
  for (const k of keys) {
    v += (k.v - p) * step(t - k.t, k.w ?? w, k.z ?? z);
    p = k.v;
  }
  return v;
};
export const mix = (a: number, b: number, x: number): number => a + (b - a) * x;
export const clamp = (x: number, a = 0, b = 1): number => Math.min(b, Math.max(a, x));
export const bump = (t: number, t0: number, dur: number): number =>
  t < t0 || t > t0 + dur ? 0 : Math.sin((Math.PI * (t - t0)) / dur);
