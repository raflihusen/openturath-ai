import { Easing } from "remotion";
import { HURUF } from "../tema";

// OpenTurath AI — Monochrome Editorial ("The Quiet Islamic Scholar")
// Strict ink & archival paper palette. Zero gold, amber, or neon accents.
export const PALETTE = {
  obsidian: "#09090B",
  obsidianSurface: "#141416",
  obsidianElevated: "#18181B",
  obsidianBorder: "#27272A",
  obsidianMuted: "#A1A1AA",
  obsidianSubtle: "#71717A",
  paper: "#F6F6F6",
  paperPure: "#FFFFFF",
  paperSubtle: "#EBEBEB",
  paperBorder: "#DADADA",
  ink: "#171717",
  inkSecondary: "#52525B",
  inkTertiary: "#71717A",
  ivory: "#FAFAFA",
} as const;

export const FONT = {
  serif: HURUF.serif,
  sans: HURUF.ui,
  arabic: HURUF.arab,
} as const;

export const EASE_EDITORIAL = Easing.bezier(0.16, 1, 0.3, 1);
export const EASE_SMOOTH = Easing.bezier(0.65, 0, 0.35, 1);

export const CLAMP = {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
} as const;

export const MIHRAB_PATH =
  "M 14 140 V 66 C 14 40 30 26 60 8 C 90 26 106 40 106 66 V 140";

export const PROMO_FPS = 60;
export const TRANSITION_FRAMES = 24;

export const SCENE_DURATIONS = {
  opening: 336,
  monograph: 336,
  showcase: 480,
  disciplines: 408,
  finale: 336,
} as const;

// 336 + 336 + 480 + 408 + 336 - (4 * 24) = 1800 frames (30.0s @ 60fps)
export const TOTAL_PROMO_FRAMES =
  SCENE_DURATIONS.opening +
  SCENE_DURATIONS.monograph +
  SCENE_DURATIONS.showcase +
  SCENE_DURATIONS.disciplines +
  SCENE_DURATIONS.finale -
  4 * TRANSITION_FRAMES;
