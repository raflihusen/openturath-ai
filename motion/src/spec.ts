// Satu sumber angka gerak OpenTurath. Nilai di sini dicerminkan di
// openturath_ai/lib/core/design/ot_motion.dart; ubah keduanya bersama.
export const FPS = 60;
export const ms = (value: number) => Math.round((value / 1000) * FPS);

// Kurva: sama dengan Curves.easeOutCubic dan Curves.easeOutQuart di Flutter.
export const EASE_OUT_CUBIC = [0.33, 1, 0.68, 1] as const;
export const EASE_OUT_QUART = [0.25, 1, 0.5, 1] as const;

export const SPLASH = {
  drawStart: 0,
  drawEnd: 600, // garis lengkung ditulis
  markStart: 380,
  markEnd: 860, // tanda logo muncul di dalam lengkung
  echoStart: 460,
  echoStagger: 110,
  echoDuration: 760,
  echoCount: 3,
  wordStart: 700,
  wordEnd: 1150,
  wordShift: 8,
  total: 1400,
} as const;

export const LOADER = {
  loop: 1600,
  sweep: 0.22, // panjang cahaya terhadap keliling lengkung
  trackWidth: 132,
} as const;

export const LOGIN = {
  layers: 7,
  layerStagger: 60,
  layerDuration: 420,
  glowEnd: 900,
  headlineStart: 520,
  lineStagger: 80,
  revealDuration: 420,
  revealShift: 12,
  subtitleStart: 760,
  buttonStart: 880,
  legalStart: 1000,
  breath: 13000, // napas cahaya setelah masuk
  total: 1800,
} as const;

export type ThemeName = "light" | "dark";
export const THEME = {
  light: {
    canvas: "#fafafa",
    surface: "#ffffff",
    textPrimary: "#171717",
    textSecondary: "#606060",
    border: "#dadada",
    accent: "#171717",
    onAccent: "#ffffff",
  },
  dark: {
    canvas: "#111111",
    surface: "#191919",
    textPrimary: "#f5f5f5",
    textSecondary: "#b8b8b8",
    border: "#454545",
    accent: "#f5f5f5",
    onAccent: "#171717",
  },
} as const;

// Lengkung runcing logo: sama dengan _arch() di arch_echo_canvas.dart.
export const archPath = (
  x: number,
  y: number,
  w: number,
  h: number,
  open = false,
) => {
  const shoulder = y + h * 0.4;
  const cx = x + w / 2;
  const d = [
    `M ${x} ${y + h}`,
    `L ${x} ${shoulder}`,
    `C ${x} ${y + h * 0.19}, ${cx - w * 0.2} ${y + h * 0.075}, ${cx} ${y}`,
    `C ${cx + w * 0.2} ${y + h * 0.075}, ${x + w} ${y + h * 0.19}, ${x + w} ${shoulder}`,
    `L ${x + w} ${y + h}`,
  ];
  if (!open) d.push("Z");
  return d.join(" ");
};
