import React from "react";
import {
  AbsoluteFill,
  Audio,
  Easing,
  Img,
  interpolate,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { OpenTurathProductFilm } from "./Film";
import { CATALOG } from "./catalog";
import { Icon } from "../film60/AppUI";

const clamp = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const ease = Easing.bezier(0.22, 1, 0.36, 1);
const p = (t: number, a: number, b: number) =>
  interpolate(t, [a, b], [0, 1], clamp);
const e = (t: number, a: number, b: number) =>
  interpolate(t, [a, b], [0, 1], { ...clamp, easing: ease });
const mix = (a: number, b: number, n: number) => a + (b - a) * n;
const box: React.CSSProperties = {
  position: "absolute",
  boxSizing: "border-box",
};
const row: React.CSSProperties = { display: "flex", alignItems: "center" };
const paper = "#F6F6F6",
  ink = "#09090B",
  card = "#18181B",
  ui = "Outfit, sans-serif";
const splitNames: Record<string, string> = {
  fiqh_muqaran: "Perbandingan\nMazhab & Fatwa",
  thabaqat_rijal: "Rijal & Biografi\nUlama",
  ushul_fiqh: "Ushul & Kaidah\nFikih",
};

// All eighteen cards inhabit one continuous grid. Camera-like scroll, search,
// and the selected card's shared geometry connect the catalogue to the demo.
export function CatalogIntro({ t }: { t: number }) {
  const scroll = 828 * e(t, 3.6, 4.15) + 828 * e(t, 7.3, 7.85);
  const filtering = e(t, 11, 11.8);
  const opacity = 1 - p(t, 11.7, 11.85);
  const group = t < 3.86 ? 0 : t < 7.56 ? 1 : 2;
  const searchText = "Fikih Syafi’i";
  const query = searchText.slice(0, Math.floor(p(t, 10.95, 11.55) * searchText.length));
  return (
    <AbsoluteFill
      style={{
        background: paper,
        fontFamily: ui,
        color: ink,
        opacity,
        zIndex: 20,
        overflow: "hidden",
      }}
    >
      <div
        style={{
          ...box,
          left: 94,
          right: 94,
          top: 118,
          ...row,
          justifyContent: "space-between",
          opacity: e(t, 0, 0.35),
        }}
      >
        <div style={{ ...row, gap: 15 }}>
          <Img
            src={staticFile("promo/mark_black.svg")}
            style={{ width: 36, height: 48, objectFit: "contain" }}
          />
          <span
            style={{
              fontFamily: "Newsreader, serif",
              fontSize: 38,
              fontWeight: 600,
              letterSpacing: -0.7,
            }}
          >
            OpenTurath AI
          </span>
        </div>
        <span style={{ fontSize: 22, color: "#606060", letterSpacing: 2 }}>
          RUANG BELAJAR TURATS
        </span>
      </div>
      <div
        style={{
          ...box,
          left: 94,
          right: 80,
          top: 244,
          fontFamily: "Newsreader, serif",
          fontSize: 100,
          lineHeight: 1.02,
          letterSpacing: -3.7,
          opacity: 1 - p(t, 11.15, 11.6),
        }}
      >
        {["18 AI.", "Lintas keilmuan."].map((s, i) => (
          <div key={s} style={{ overflow: "hidden", paddingBottom: 8 }}>
            <div
              style={{
                translate: `0 ${112 * (1 - e(t, 0.03 + i * 0.08, 0.65 + i * 0.08))}%`,
              }}
            >
              {s}
            </div>
          </div>
        ))}
      </div>
      <div
        style={{
          ...box,
          left: 94,
          right: 94,
          top: 515,
          height: 90,
          borderRadius: 45,
          background: "#EDEDED",
          padding: "0 28px",
          ...row,
          gap: 18,
          fontSize: 31,
          color: query ? ink : "#606060",
          opacity: e(t, 0.18, 0.6) * (1 - p(t, 11.5, 11.8)),
        }}
      >
        <Icon name="search" size={32} />
        <span>{query || "Cari AI..."}</span>
        {query && <span style={{ width: 2, height: 33, background: ink }} />}
      </div>
      <div
        style={{
          ...box,
          left: 94,
          right: 94,
          top: 1550,
          ...row,
          justifyContent: "space-between",
          fontSize: 31,
          opacity: e(t, 0.4, 0.9) * (1 - p(t, 11.1, 11.5)),
        }}
      >
        <span style={{ fontWeight: 600 }}>
          {
            [
              "Fikih dan Tahawwulat",
              "Hadis dan Al-Qur’an",
              "Khazanah keilmuan",
            ][group]
          }
        </span>
        <span
          style={{
            fontVariantNumeric: "tabular-nums",
            color: "#606060",
            fontSize: 26,
          }}
        >
          {["01—06", "07—12", "13—18"][group]} / 18
        </span>
      </div>
      <div
        style={{
          ...box,
          left: 0,
          top: 640,
          right: 0,
          height: 865,
          overflow: "hidden",
        }}
      >
        {CATALOG.map((item, i) => {
          const selected = item.id === "fiqh_syafii";
          const x = 94 + (i % 2) * 458,
            y = 20 + Math.floor(i / 2) * 276 - scroll;
          const enter = e(t, 0.18 + (i % 6) * 0.055, 0.85 + (i % 6) * 0.055);
          const q = selected ? filtering : 0;
          return (
            <div
              key={item.id}
              data-catalog-id={item.id}
              style={{
                ...box,
                left: selected
                  ? mix(x, 94, q)
                  : x + (i % 2 ? 230 : -230) * filtering,
                top: selected
                  ? mix(y, 120, q)
                  : y + 60 * filtering + 65 * (1 - enter),
                width: 434,
                height: 248,
                borderRadius: 32,
                background: card,
                color: "#FAFAFA",
                overflow: "hidden",
                opacity: enter * (selected ? 1 : 1 - p(t, 11, 11.5)),
                zIndex: selected ? 3 : 1,
                boxShadow: "0 12px 24px rgba(9,9,11,.04)",
              }}
            >
              <div
                style={{
                  ...box,
                  left: 30,
                  right: 26,
                  top: mix(30, 38, q),
                  fontSize: selected ? mix(43, 39, q) : 43,
                  fontWeight: 600,
                  lineHeight: 1.16,
                  whiteSpace: "pre-line",
                  zIndex: 2,
                }}
              >
                {splitNames[item.id] || item.name.replace("'", "’")}
              </div>
              <div
                dir="rtl"
                lang="ar"
                style={{
                  ...box,
                  left: 205,
                  right: 24,
                  bottom: 22,
                  fontFamily: "FilmArabicUI, sans-serif",
                  fontSize: Math.min(52, 360 / item.arabic.length),
                  lineHeight: 1.85,
                  textAlign: "right",
                  whiteSpace: "nowrap",
                  opacity: 0.1,
                }}
              >
                {item.arabic}
              </div>
              <div style={{ ...box, left: 30, bottom: 30, ...row, gap: 20 }}>
                <div
                  style={{
                    padding: "12px 26px",
                    borderRadius: 32,
                    background: "#FAFAFA",
                    color: card,
                  }}
                >
                  <Icon name="chat" size={30} />
                </div>
                <div
                  style={{
                    padding: 12,
                    border: "1px solid #555",
                    borderRadius: 32,
                  }}
                >
                  <Icon name="book" size={30} />
                </div>
              </div>
            </div>
          );
        })}
      </div>
      <div
        style={{
          ...box,
          left: 94,
          right: 94,
          bottom: 143,
          fontSize: 28,
          textAlign: "center",
          color: "#606060",
          opacity: e(t, 0.5, 1) * (1 - p(t, 11.4, 11.8)),
        }}
      >
        Lihat ketersediaan dan akses di aplikasi.
      </div>
    </AbsoluteFill>
  );
}

export const OpenTurath18Ilmu: React.FC = () => {
  const f = useCurrentFrame(),
    { fps } = useVideoConfig(),
    t = f / fps;
  // Preserve deliberate reading pauses and the real save/navigation sequence.
  const storyTime = interpolate(
    t,
    [0, 11.85, 14.5, 18.75, 21.3, 24.7, 26.55, 30],
    [4.75, 4.75, 8.85, 14.4, 19.5, 24.05, 26.3, 30],
    clamp,
  );
  return (
    <AbsoluteFill style={{ background: paper, overflow: "hidden" }}>
      <Audio src={staticFile("productfilm/audio/master.wav")} />
      <OpenTurathProductFilm silent storyTime={storyTime} catalogDemo />
      {t < 11.85 && <CatalogIntro t={t} />}
    </AbsoluteFill>
  );
};
