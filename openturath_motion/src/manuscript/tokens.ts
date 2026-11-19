import { Easing } from "remotion";
import { HURUF } from "../tema";

// Colors mirror DESIGN.md tokens; every text pairing is verified >= 4.5:1 WCAG AA.
export const INK = {
  paper: "#F6F6F6",
  surface: "#FFFFFF",
  paperRule: "#DADADA",
  ink: "#171717",
  inkMuted: "#52525B",
  darkBg: "#151515",
  darkSurface: "#222222",
  darkRule: "#383838",
  darkText: "#F5F5F5",
  darkMuted: "#B8B8B8",
  darkSubtle: "#9A9A9A",
} as const;

export const TYPE = {
  serif: HURUF.serif,
  sans: HURUF.ui,
  arabic: HURUF.arab,
} as const;

export const EASE_INK = Easing.bezier(0.22, 1, 0.36, 1);
export const EASE_SHIFT = Easing.bezier(0.72, 0, 0.28, 1);

export const CLAMP = {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
} as const;

export const MANUSCRIPT_FPS = 60;
export const MANUSCRIPT_FRAMES = 1560; // 26.0s @ 60fps

export const CASE_STUDY = {
  question:
    "Bagaimana hukum jual beli mu'athah tanpa lafal akad menurut Syafi'i dan jumhur?",
  syafiiTitle: "Mazhab Syafi'i",
  syafiiBody:
    "Qaul mu'tamad mensyaratkan ijab kabul. Imam an-Nawawi memilih sahnya mu'athah pada transaksi yang lazim di masyarakat.",
  jumhurTitle: "Jumhur (Hanafi, Maliki, Hanbali)",
  jumhurBody:
    "Sah selama ada kerelaan ('urf dan taradhi), meski tanpa ucapan ijab kabul.",
  ibarahLine1: "المُخْتَارُ صِحَّةُ بَيْعِ المُعَاطَاةِ",
  ibarahLine2: "فِي كُلِّ مَا يَعُدُّهُ النَّاسُ بَيْعاً",
  citationBook: "Al-Majmu' Syarh al-Muhadzdzab, Juz 9",
  citationAuthor: "Imam an-Nawawi",
} as const;
