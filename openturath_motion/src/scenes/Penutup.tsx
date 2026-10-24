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

/** Adegan 6: logo dalam lengkung, kalimat kunci, alamat situs, harga mulai. */
export const Penutup: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill
      name="Penutup"
      style={{
        backgroundColor: W.gelap,
        fontFamily: HURUF.ui,
        color: W.terang,
      }}
    >
      <Lengkung
        lebar={560}
        kiri={260}
        atas={250}
        warna="#5A5A5A"
        mulai={0}
        lama={50}
      />
      <Img
        name="Logo"
        src={staticFile("logo_putih.png")}
        style={{
          position: "absolute",
          left: 420,
          top: 520,
          width: 240,
          height: 240,
          opacity: interpolate(frame, [20, 45], [0, 1], jepit),
          scale: interpolate(frame, [20, 60], [0.88, 1], {
            ...jepit,
            easing: halus,
          }),
        }}
      />
      <AbsoluteFill
        style={{
          padding: "1060px 90px 0",
          alignItems: "center",
          textAlign: "center",
        }}
      >
        <Interactive.Div
          name="Kalimat kunci"
          style={{
            fontFamily: HURUF.serif,
            fontSize: 108,
            lineHeight: 1.04,
            letterSpacing: -2.8,
            opacity: interpolate(frame, [40, 65], [0, 1], jepit),
            translate: interpolate(frame, [40, 75], ["0px 40px", "0px 0px"], {
              ...jepit,
              easing: halus,
            }),
          }}
        >
          Bertanya langsung kepada kitabnya.
        </Interactive.Div>
        <Interactive.Div
          name="Situs"
          style={{
            marginTop: 70,
            background: W.terang,
            color: W.gelap,
            borderRadius: 999,
            padding: "30px 64px",
            fontWeight: 600,
            fontSize: 52,
            opacity: interpolate(frame, [70, 90], [0, 1], jepit),
            scale: interpolate(frame, [70, 100], [0.9, 1], {
              ...jepit,
              easing: halus,
            }),
          }}
        >
          openturath.id
        </Interactive.Div>
        <Interactive.Div
          name="Harga"
          style={{
            marginTop: 40,
            fontSize: 40,
            color: W.abuMuda,
            opacity: interpolate(frame, [90, 110], [0, 1], jepit),
          }}
        >
          Mulai Rp49 ribu per bulan · bayar lewat Midtrans
        </Interactive.Div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
