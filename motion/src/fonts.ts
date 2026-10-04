import { loadFont } from "@remotion/fonts";
import { staticFile } from "remotion";

// Fon yang sama dengan yang dibundel aplikasi.
const faces: [string, string, string][] = [
  ["Outfit", "fonts/NativeOutfit.ttf", "400"],
  ["Outfit", "fonts/NativeOutfit-600.ttf", "600"],
  ["Newsreader", "fonts/NativeNewsreader-400.ttf", "400"],
  ["Newsreader", "fonts/NativeNewsreader.ttf", "600"],
];
for (const [family, file, weight] of faces) {
  loadFont({ family, url: staticFile(file), weight });
}

export const SERIF = "Newsreader, Georgia, serif";
export const SANS = "Outfit, system-ui, sans-serif";
