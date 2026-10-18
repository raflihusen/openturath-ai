// Metadata visual tiap slide: tanpa React, agar bisa dibaca Node untuk manifest.
// tinggi: tinggi area animasi (px, kanvas 1080 x 1350).
// lead: berapa bingkai animasi berjalan sebelum teks berikutnya muncul.
// pakai: bagian naskah yang sudah digambar oleh animasi, sehingga tidak diulang.
export type Bagian =
  | "sub"
  | "arab"
  | "poin"
  | "dua"
  | "rukun"
  | "ibarah"
  | "kunci"
  | "nama"
  | "sumber";

export type Meta = {
  tinggi?: number;
  lead?: number;
  pakai?: Bagian[];
  gelap?: boolean;
  penuh?: boolean;
};

export const META: Record<string, Meta> = {
  sampul: { penuh: true, gelap: true },
  zaman: { tinggi: 430, lead: 80, gelap: true },
  kompas: { tinggi: 430, lead: 90, gelap: true },
  perintis: { tinggi: 330, lead: 100, pakai: ["nama", "arab"] },
  fikih: { tinggi: 330, lead: 70, pakai: ["arab"] },
  tahawwul: { tinggi: 380, lead: 110, pakai: ["arab"] },
  gabungan: { tinggi: 440, lead: 120, pakai: ["poin"] },
  definisi: { tinggi: 140, lead: 50 },
  bukanramalan: { tinggi: 400, lead: 130, pakai: ["poin"] },
  jibril: { tinggi: 470, lead: 130, pakai: ["poin"] },
  dinukum: { tinggi: 300, lead: 110 },
  empatrukun: { tinggi: 560, lead: 150, pakai: ["rukun"] },
  rukunkeempat: { tinggi: 330, lead: 120 },
  tetapberubah: { tinggi: 470, lead: 110, pakai: ["dua"] },
  duasalah: { tinggi: 260, lead: 70 },
  wadah: { tinggi: 420, lead: 120, pakai: ["arab"] },
  wadahretak: { tinggi: 340, lead: 110 },
  duatugas: { tinggi: 240, lead: 70 },
  tigaperusak: { tinggi: 300, lead: 100 },
  bahasa: { tinggi: 460, lead: 170, pakai: ["poin"] },
  duatanda: { tinggi: 300, lead: 80 },
  tandailmu: { tinggi: 300, lead: 100, pakai: ["arab"] },
  tandakuasa: { tinggi: 300, lead: 100, pakai: ["arab"] },
  duakeputusan: { tinggi: 460, lead: 140, pakai: ["dua"] },
  buih: { tinggi: 260, lead: 60, gelap: true },
  wahn: { tinggi: 380, lead: 90, pakai: ["dua"] },
  limababak: { tinggi: 700, lead: 170, pakai: ["rukun"] },
  istihtar: { tinggi: 280, lead: 90 },
  tahrisy: { tinggi: 440, lead: 130, pakai: ["poin"] },
  airmakanan: { tinggi: 380, lead: 110, pakai: ["poin"] },
  marham: { tinggi: 400, lead: 150, pakai: ["poin"] },
  dajjal: { tinggi: 330, lead: 110, pakai: ["rukun"], gelap: true },
  rekayasa: { tinggi: 420, lead: 120, pakai: ["poin"], gelap: true },
  vaksin: { tinggi: 320, lead: 60 },
  duasunnah: { tinggi: 260, lead: 70 },
  hasan: { tinggi: 320, lead: 130 },
  salamah: { tinggi: 230, lead: 70, pakai: ["dua"] },
  namath: { tinggi: 250, lead: 100 },
  khuwaishah: { tinggi: 330, lead: 80 },
  teknologi: { tinggi: 380, lead: 110, pakai: ["arab"] },
  sejarah: { tinggi: 300, lead: 80 },
  tenang: { tinggi: 300, lead: 90 },
  manfaat: { tinggi: 820, lead: 200, pakai: ["rukun"] },
  sebelumsesudah: { tinggi: 820, lead: 220, pakai: ["rukun"] },
  kitab: { tinggi: 500, lead: 140, pakai: ["rukun"] },
  limaai: { tinggi: 340, lead: 120, pakai: ["rukun"] },
  penutup: { penuh: true, gelap: true },
};
