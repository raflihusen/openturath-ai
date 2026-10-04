import React from "react";
import { staticFile } from "remotion";

// Tanda logo satu tinta, diwarnai lewat mask agar mengikuti tema.
export const Mark: React.FC<{
  size: number;
  color: string;
  style?: React.CSSProperties;
}> = ({ size, color, style }) => {
  const url = `url(${staticFile("mark.svg")})`;
  return (
    <div
      style={{
        width: size,
        height: size,
        backgroundColor: color,
        maskImage: url,
        WebkitMaskImage: url,
        maskSize: "contain",
        WebkitMaskSize: "contain",
        maskRepeat: "no-repeat",
        WebkitMaskRepeat: "no-repeat",
        maskPosition: "center",
        WebkitMaskPosition: "center",
        ...style,
      }}
    />
  );
};
