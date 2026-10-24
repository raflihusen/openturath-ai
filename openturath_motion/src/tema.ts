import { loadFont } from "@remotion/fonts";
import { Easing, staticFile } from "remotion";

// Bahasa desain OpenTurath: kertas dan tinta, garis tipis, satu aksen untuk Tahawwulat.
export const W = {
  kertas: "#F6F6F6",
  putih: "#FFFFFF",
  tinta: "#171717",
  abu: "#606060",
  abuMuda: "#9A9A9A",
  garis: "#DADADA",
  garisHalus: "#EBEBEB",
  gelap: "#111111",
  gelap2: "#1C1C1C",
  gelap3: "#2A2A2A",
  terang: "#F5F5F5",
  aksen: "#D97706",
};

export const HURUF = {
  ui: "Outfit",
  serif: "Newsreader",
  arab: "Scheherazade",
};

export const FPS = 30;

export const halus = Easing.bezier(0.16, 1, 0.3, 1);
export const lembut = Easing.bezier(0.65, 0, 0.35, 1);

export const jepit = {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
} as const;

// Lengkung mihrab dari logo, dalam koordinat 100 x 130.
export const LENGKUNG = "M8 130 V62 C8 40 22 28 50 10 C78 28 92 40 92 62 V130";

/** Format angka gaya Indonesia: 5382 -> 5.382 */
export const angkaID = (n: number) =>
  Math.round(n)
    .toString()
    .replace(/\B(?=(\d{3})+(?!\d))/g, ".");

Promise.all([
  loadFont({
    family: HURUF.ui,
    url: staticFile("fonts/NativeOutfit.ttf"),
    weight: "400",
  }),
  loadFont({
    family: HURUF.ui,
    url: staticFile("fonts/NativeOutfit-600.ttf"),
    weight: "600",
  }),
  loadFont({
    family: HURUF.serif,
    url: staticFile("fonts/NativeNewsreader-400.ttf"),
    weight: "400",
  }),
  loadFont({
    family: HURUF.serif,
    url: staticFile("fonts/NativeNewsreader.ttf"),
    weight: "600",
  }),
  loadFont({
    family: HURUF.arab,
    url: staticFile("fonts/NativeArabic.ttf"),
    weight: "400",
  }),
]);
