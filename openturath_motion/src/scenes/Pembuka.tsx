import {
  AbsoluteFill,
  Img,
  Interactive,
  interpolate,
  staticFile,
  useCurrentFrame,
} from "remotion";
import { Lengkung } from "../Lengkung";
import { HURUF, W, halus, jepit } from "../tema";

/** Adegan 1: lengkung mihrab tergambar, logo muncul, nama OpenTurath. */
export const Pembuka: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill name="Pembuka" style={{ backgroundColor: W.gelap }}>
      <Lengkung
        lebar={900}
        kiri={90}
        atas={330}
        warna="#4A4A4A"
        mulai={0}
        lama={55}
      />
      <Lengkung
        lebar={700}
        kiri={190}
        atas={560}
        warna="#363636"
        mulai={8}
        lama={55}
      />
      <Lengkung
        lebar={500}
        kiri={290}
        atas={790}
        warna="#2A2A2A"
        mulai={16}
        lama={55}
      />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <Img
          name="Logo"
          src={staticFile("logo_putih.png")}
          style={{
            width: 260,
            height: 260,
            marginTop: 120,
            opacity: interpolate(frame, [30, 60], [0, 1], jepit),
            scale: interpolate(frame, [30, 75], [0.9, 1], {
              ...jepit,
              easing: halus,
            }),
          }}
        />
        <Interactive.Div
          name="Nama"
          style={{
            marginTop: 56,
            fontFamily: HURUF.ui,
            fontWeight: 600,
            fontSize: 112,
            letterSpacing: -2,
            color: W.terang,
            opacity: interpolate(frame, [55, 80], [0, 1], jepit),
            translate: interpolate(frame, [55, 90], ["0px 30px", "0px 0px"], {
              ...jepit,
              easing: halus,
            }),
          }}
        >
          OpenTurath
        </Interactive.Div>
        <Interactive.Div
          name="Slogan"
          style={{
            marginTop: 24,
            fontFamily: HURUF.ui,
            fontSize: 44,
            color: W.abuMuda,
            opacity: interpolate(frame, [75, 100], [0, 1], jepit),
            translate: interpolate(frame, [75, 105], ["0px 20px", "0px 0px"], {
              ...jepit,
              easing: halus,
            }),
          }}
        >
          Perpustakaan turath yang bisa ditanya
        </Interactive.Div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
