// Ekspor pengantar Fikih Tahawwulat ke aplikasi Flutter.
// 1. Encode ulang MP4 dengan keyframe tepat di awal tiap slide (lompat slide presisi).
// 2. Tulis manifest slide (waktu mulai, bab, dan teks lengkap untuk aksesibilitas).
//
// Pakai: npx remotion render PengantarTahawwulat out/pengantar_tahawwulat.mp4 && node scripts/ekspor_tahawwulat.mjs
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

const FPS = 30;
const akar = path.resolve(import.meta.dirname, "..");
const app = path.resolve(akar, "../openturath_ai/assets");
const naskah = JSON.parse(fs.readFileSync(path.join(akar, "src/tahawwulat/naskah.json"), "utf8"));

let bingkai = 0;
const slide = naskah.slide.map((s) => {
  const mulai = bingkai;
  bingkai += s.durasi;
  return {
    ...s,
    durasi: undefined,
    mulai_ms: Math.round((mulai / FPS) * 1000),
    durasi_ms: Math.round((s.durasi / FPS) * 1000),
  };
});

const keyframe = slide.map((s) => (s.mulai_ms / 1000).toFixed(3)).join(",");
const masuk = path.join(akar, "out/pengantar_tahawwulat.mp4");
const keluar = path.join(app, "video/pengantar_tahawwulat.mp4");
fs.mkdirSync(path.dirname(keluar), { recursive: true });
execFileSync("ffmpeg", [
  "-loglevel", "error", "-y", "-i", masuk,
  "-c:v", "libx264", "-preset", "slow", "-crf", "24", "-pix_fmt", "yuv420p",
  "-profile:v", "high", "-force_key_frames", keyframe, "-an", "-movflags", "+faststart",
  keluar,
], { stdio: "inherit" });

fs.mkdirSync(path.join(app, "data"), { recursive: true });
fs.writeFileSync(
  path.join(app, "data/pengantar_tahawwulat.json"),
  JSON.stringify(
    { judul: naskah.judul, video: "assets/video/pengantar_tahawwulat.mp4", total_ms: Math.round((bingkai / FPS) * 1000), bab: naskah.bab, slide },
    null,
    1,
  ) + "\n",
);
console.log(`${slide.length} slide, ${(bingkai / FPS).toFixed(1)} detik -> ${keluar}`);
