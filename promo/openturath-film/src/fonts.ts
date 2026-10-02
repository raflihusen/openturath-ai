import { staticFile } from "remotion";

// All faces ship with the app (openturath_ai/assets/native_fonts), OFL licensed.
const FACES: { family: string; file: string; weight: string }[] = [
  { family: "OTNewsreader", file: "Newsreader.ttf", weight: "100 900" },
  { family: "OTInter", file: "Inter.ttf", weight: "100 900" },
  { family: "OTOutfit", file: "Outfit.ttf", weight: "100 900" },
  { family: "OTArabic", file: "ScheherazadeNew.ttf", weight: "100 900" },
];

export const fontsReady: Promise<void> =
  typeof document === "undefined"
    ? Promise.resolve()
    : Promise.all(
        FACES.map(async ({ family, file, weight }) => {
          const face = new FontFace(
            family,
            `url(${staticFile(`assets/fonts/${file}`)})`,
            { weight },
          );
          await face.load();
          document.fonts.add(face);
        }),
      ).then(() => undefined);
