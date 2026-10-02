import { Easing, interpolate, useVideoConfig } from "remotion";

// Monochrome palette taken from openturath_ai/lib/core/design/ot_colors.dart.
export const C = {
  night: "#0B0B0B",
  ink: "#171717",
  graphite: "#242424",
  smoke: "#606060",
  mist: "#B8B8B8",
  rule: "#DADADA",
  paper: "#F4F4F2",
  white: "#FAFAFA",
};

export const F = {
  serif: "OTNewsreader", // headings (Newsreader 600, as in the app)
  sans: "OTOutfit", // UI text (Outfit, as in the app)
  text: "OTInter", // long Latin transliteration (has ṭ, ā, ī)
  arabic: "OTArabic", // Scheherazade New, the app's Arabic face
};

export const FPS = 30;
export const DURATION = 900;

export const EASE_OUT = Easing.bezier(0.16, 1, 0.3, 1);
export const EASE_IN_OUT = Easing.bezier(0.65, 0, 0.35, 1);

const CLAMP = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

/** 0..1 progress between two frames with an ease. */
export const p = (
  frame: number,
  a: number,
  b: number,
  ease: (t: number) => number = EASE_OUT,
) => interpolate(frame, [a, b], [0, 1], { ...CLAMP, easing: ease });

export const mix = (a: number, b: number, t: number) => a + (b - a) * t;

/** Scene timeline (frames). Overlaps make the cuts feel continuous. */
export const T = {
  hook: [0, 120],
  brand: [110, 245],
  library: [235, 430],
  ask: [420, 640],
  notes: [630, 770],
  close: [760, 900],
} as const;

/** Layout helper shared by the vertical and wide compositions. */
export const useLayout = () => {
  const { width, height } = useVideoConfig();
  const portrait = height > width;
  // 1 unit = 1px in the 1080-wide vertical design.
  const u = portrait ? width / 1080 : height / 1080;
  return { width, height, portrait, u };
};
