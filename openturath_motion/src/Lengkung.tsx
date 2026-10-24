import { interpolate, useCurrentFrame } from "remotion";
import { LENGKUNG, halus, jepit } from "./tema";

/** Garis lengkung mihrab yang digambar dari kaki kiri, melewati puncak, ke kaki kanan. */
export const Lengkung: React.FC<{
  lebar: number;
  kiri: number;
  atas: number;
  warna: string;
  tebal?: number;
  mulai?: number;
  lama?: number;
}> = ({ lebar, kiri, atas, warna, tebal = 2, mulai = 0, lama = 45 }) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [mulai, mulai + lama], [0, 1], {
    ...jepit,
    easing: halus,
  });
  return (
    <svg
      width={lebar}
      height={lebar * 1.3}
      viewBox="0 0 100 130"
      style={{
        position: "absolute",
        left: kiri,
        top: atas,
        overflow: "visible",
      }}
    >
      <path
        d={LENGKUNG}
        fill="none"
        stroke={warna}
        strokeWidth={(tebal * 100) / lebar}
        pathLength={1}
        strokeDasharray="1 1"
        strokeDashoffset={1 - p}
      />
    </svg>
  );
};
