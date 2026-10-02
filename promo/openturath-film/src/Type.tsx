import type { CSSProperties, ReactNode } from "react";
import { useCurrentFrame } from "remotion";
import { C, EASE_IN_OUT, EASE_OUT, F, mix, p } from "./theme";

type Timing = { in: number; out?: number; stagger?: number };

/**
 * Kinetic line: words rise out of a mask with a soft blur, then leave upward.
 * Enter and exit overlap with the next line so swaps feel continuous.
 */
export const Words = ({
  text,
  t,
  style,
  dir = "ltr",
  align = "left",
}: {
  text: string;
  t: Timing;
  style?: CSSProperties;
  dir?: "ltr" | "rtl";
  align?: "left" | "center" | "right";
}) => {
  const frame = useCurrentFrame();
  const words = dir === "rtl" ? [text] : text.split(" ");
  const st = t.stagger ?? 3;
  return (
    <div
      dir={dir}
      style={{
        display: "flex",
        flexWrap: "wrap",
        justifyContent: align === "center" ? "center" : align === "right" ? "flex-end" : "flex-start",
        columnGap: "0.24em",
        ...style,
      }}
    >
      {words.map((w, i) => {
        const a = p(frame, t.in + i * st, t.in + i * st + 22, EASE_OUT);
        const b = t.out === undefined ? 0 : p(frame, t.out + i * 1.5, t.out + i * 1.5 + 16, EASE_IN_OUT);
        return (
          <span key={i} style={{ display: "inline-block", overflow: "hidden", paddingBottom: "0.12em", marginBottom: "-0.12em" }}>
            <span
              style={{
                display: "inline-block",
                transform: `translateY(${mix(70, 0, a) - b * 55}%)`,
                opacity: Math.min(a * 1.4, 1) * (1 - b),
                filter: `blur(${(1 - a) * 10 + b * 8}px)`,
              }}
            >
              {w}
            </span>
          </span>
        );
      })}
    </div>
  );
};

/** Fades a block in and out with a small drift; for captions and meta lines. */
export const Fade = ({
  t,
  children,
  style,
  drift = 18,
}: {
  t: Timing;
  children: ReactNode;
  style?: CSSProperties;
  drift?: number;
}) => {
  const frame = useCurrentFrame();
  const a = p(frame, t.in, t.in + 24);
  const b = t.out === undefined ? 0 : p(frame, t.out, t.out + 18, EASE_IN_OUT);
  return (
    <div
      style={{
        opacity: a * (1 - b),
        transform: `translateY(${(1 - a) * drift - b * drift * 0.6}px)`,
        filter: `blur(${(1 - a) * 6 + b * 5}px)`,
        ...style,
      }}
    >
      {children}
    </div>
  );
};

/** Typewriter for the sample question; caret blinks while idle. */
export const Typed = ({
  text,
  start,
  cps,
  style,
}: {
  text: string;
  start: number;
  cps: number;
  style?: CSSProperties;
}) => {
  const frame = useCurrentFrame();
  const n = Math.max(0, Math.min(text.length, Math.floor(((frame - start) * cps) / 30)));
  const done = n >= text.length;
  const caretOn = !done || Math.floor(frame / 15) % 2 === 0;
  return (
    <span style={style}>
      {text.slice(0, n)}
      <span
        style={{
          display: "inline-block",
          width: "0.06em",
          height: "1em",
          marginLeft: "0.06em",
          transform: "translateY(0.14em)",
          background: C.white,
          opacity: caretOn ? 0.9 : 0,
        }}
      />
    </span>
  );
};

/** A hairline that draws itself; the film's recurring "reading mark". */
export const Rule = ({ start, len, width, color = C.mist, style }: { start: number; len: number; width: number; color?: string; style?: CSSProperties }) => {
  const frame = useCurrentFrame();
  const a = p(frame, start, start + len, EASE_IN_OUT);
  return <div style={{ height: 2, width: width * a, background: color, opacity: 0.7, ...style }} />;
};

export const eyebrow = (u: number): CSSProperties => ({
  fontFamily: F.sans,
  fontWeight: 500,
  fontSize: 26 * u,
  letterSpacing: "0.22em",
  textTransform: "uppercase",
  color: C.mist,
});

export const display = (u: number, size = 150): CSSProperties => ({
  fontFamily: F.serif,
  fontWeight: 600,
  fontSize: size * u,
  lineHeight: 1.0,
  letterSpacing: "-0.03em",
  color: C.white,
});

export const body = (u: number, size = 44): CSSProperties => ({
  fontFamily: F.sans,
  fontWeight: 400,
  fontSize: size * u,
  lineHeight: 1.3,
  letterSpacing: "-0.005em",
  color: "#d4d4d4",
});
