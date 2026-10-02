import type { CSSProperties, ReactNode } from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { Fade, Rule, Typed, Words, body, display, eyebrow } from "./Type";
import { C, F, p, useLayout } from "./theme";

/** Copy column. Vertical: top block inside the safe area. Wide: left column. */
const Column = ({ children, top, style }: { children: ReactNode; top?: number; style?: CSSProperties }) => {
  const { portrait, u } = useLayout();
  return (
    <div
      style={{
        position: "absolute",
        left: (portrait ? 92 : 132) * u,
        width: (portrait ? 880 : 760) * u,
        top: (top ?? (portrait ? 250 : 330)) * u,
        display: "flex",
        flexDirection: "column",
        gap: 26 * u,
        ...style,
      }}
    >
      {children}
    </div>
  );
};

const Hook = () => {
  const { portrait, u } = useLayout();
  const s = display(u, portrait ? 132 : 118);
  return (
    <Column top={portrait ? 300 : 380}>
      <div style={{ position: "relative", height: (s.fontSize as number) * 1.1 }}>
        <div style={{ position: "absolute", inset: 0 }}>
          <Words text="Turats itu luas." t={{ in: 10, out: 56 }} style={s} />
        </div>
        <div style={{ position: "absolute", inset: 0 }}>
          <Words text="Mulai dari mana?" t={{ in: 62, out: 110 }} style={s} />
        </div>
      </div>
    </Column>
  );
};

const Brand = () => {
  const { portrait, u } = useLayout();
  const word = { ...display(u, portrait ? 150 : 140), letterSpacing: "-0.035em" };
  const box: CSSProperties = portrait
    ? { position: "absolute", top: 1150 * u, left: 0, right: 0, alignItems: "center", display: "flex", flexDirection: "column", gap: 26 * u }
    : { position: "absolute", top: 400 * u, left: 132 * u, width: 820 * u, display: "flex", flexDirection: "column", gap: 26 * u };
  return (
    <div style={box}>
      <Words text="OpenTurath" t={{ in: 196, out: 246 }} style={word} align={portrait ? "center" : "left"} />
      <Fade t={{ in: 212, out: 244 }}>
        <div style={{ ...body(u, 46), textAlign: portrait ? "center" : "left", color: "#cfcfcf" }}>
          Membaca kitab, menelusuri ibarah.
        </div>
      </Fade>
    </div>
  );
};

const Library = () => {
  const { portrait, u } = useLayout();
  return (
    <>
      <Column>
        <Fade t={{ in: 262, out: 344 }}>
          <div style={eyebrow(u)}>Pustaka rujukan</div>
        </Fade>
        <Words text="Kenali kitabnya dulu." t={{ in: 266, out: 340 }} style={display(u, portrait ? 112 : 104)} />
        <Fade t={{ in: 282, out: 336 }}>
          <div style={body(u, 42)}>Katalog per bidang, lengkap dengan pengarang, muhaqqiq, penerbit, jilid, dan halaman.</div>
        </Fade>
      </Column>
      <Column>
        <Fade t={{ in: 356, out: 420 }}>
          <div style={eyebrow(u)}>Dari katalog Fikih Syafi&apos;i</div>
        </Fade>
        <Words
          text="منهاج الطالبين"
          dir="rtl"
          align="left"
          t={{ in: 360, out: 418 }}
          style={{ fontFamily: F.arabic, fontWeight: 600, fontSize: (portrait ? 128 : 116) * u, lineHeight: 1.5, color: C.white }}
        />
        <Fade t={{ in: 368, out: 416 }}>
          <div style={{ ...body(u, 40), fontFamily: F.text, color: "#d0d0d0" }}>
            Minhāj al-Ṭālibīn · Imam al-Nawawi, w. 676 H
          </div>
          <div style={{ ...body(u, 34), fontFamily: F.text, color: C.mist, marginTop: 10 * u }}>
            Dār al-Fikr · 1 jilid · 370 halaman
          </div>
        </Fade>
        <Rule start={372} len={30} width={(portrait ? 880 : 700) * u} />
      </Column>
    </>
  );
};

const Ask = () => {
  const { portrait, u } = useLayout();
  const frame = useCurrentFrame();
  const box = p(frame, 452, 474);
  const boxOut = p(frame, 622, 640);
  const chip = p(frame, 584, 604);
  return (
    <Column>
      <Fade t={{ in: 436, out: 624 }}>
        <div style={eyebrow(u)}>Asisten</div>
      </Fade>
      <Words text="Ajukan mas'alah." t={{ in: 440, out: 622 }} style={display(u, portrait ? 112 : 104)} />
      <div
        style={{
          opacity: box * (1 - boxOut),
          transform: `translateY(${(1 - box) * 20}px) scale(${0.98 + 0.02 * box})`,
          transformOrigin: "left center",
          border: `1.5px solid rgba(255,255,255,0.28)`,
          background: "rgba(23,23,23,0.72)",
          backdropFilter: "blur(12px)",
          borderRadius: 30 * u,
          padding: `${26 * u}px ${32 * u}px`,
          ...body(u, 38),
          fontFamily: F.text,
          color: C.white,
          minHeight: 92 * u,
        }}
      >
        <Typed text="Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn?" start={474} cps={36} />
      </div>
      <Fade t={{ in: 540, out: 620 }}>
        <div style={body(u, 42)}>Telusuri pembahasannya langsung dari naskah turats.</div>
      </Fade>
      <div style={{ display: "flex", gap: 14 * u, opacity: chip * (1 - boxOut), transform: `translateY(${(1 - chip) * 14}px)` }}>
        <span
          style={{
            fontFamily: F.sans,
            fontSize: 30 * u,
            color: C.ink,
            background: C.white,
            borderRadius: 999,
            padding: `${10 * u}px ${24 * u}px`,
          }}
        >
          Rujukan [1]
        </span>
      </div>
    </Column>
  );
};

const Notes = () => {
  const { portrait, u } = useLayout();
  return (
    <Column>
      <Fade t={{ in: 652, out: 756 }}>
        <div style={eyebrow(u)}>Catatan</div>
      </Fade>
      <Words text="Simpan yang penting." t={{ in: 656, out: 754 }} style={display(u, portrait ? 112 : 104)} />
      <Fade t={{ in: 672, out: 752 }}>
        <div style={body(u, 42)}>Jawaban dan ibarah tersimpan di Catatan, siap dibaca lagi kapan saja.</div>
      </Fade>
    </Column>
  );
};

const Close = () => {
  const { portrait, u } = useLayout();
  const box: CSSProperties = portrait
    ? { position: "absolute", top: 1080 * u, left: 0, right: 0, display: "flex", flexDirection: "column", alignItems: "center", gap: 24 * u }
    : { position: "absolute", top: 360 * u, left: 132 * u, width: 820 * u, display: "flex", flexDirection: "column", gap: 24 * u };
  const align = portrait ? "center" : "left";
  return (
    <div style={box}>
      <Words text="OpenTurath" t={{ in: 818 }} style={{ ...display(u, portrait ? 132 : 128), letterSpacing: "-0.035em" }} align={align} />
      <Fade t={{ in: 832 }}>
        <div style={{ ...body(u, 44), textAlign: align, color: "#d6d6d6" }}>Membaca kitab, menelusuri ibarah.</div>
      </Fade>
      <Fade t={{ in: 846 }}>
        <div
          style={{
            marginTop: 30 * u,
            fontFamily: F.sans,
            fontWeight: 500,
            fontSize: 40 * u,
            color: C.ink,
            background: C.white,
            borderRadius: 999,
            padding: `${18 * u}px ${44 * u}px`,
            alignSelf: portrait ? "center" : "flex-start",
          }}
        >
          openturath.id
        </div>
      </Fade>
      <Fade t={{ in: 858 }}>
        <div style={{ ...body(u, 27), marginTop: 26 * u, textAlign: align, color: "#8a8a8a" }}>
          Jawaban AI tetap perlu diperiksa pada kitab rujukan.
        </div>
      </Fade>
    </div>
  );
};

export const Overlay = () => (
  <AbsoluteFill style={{ pointerEvents: "none" }}>
    <Hook />
    <Brand />
    <Library />
    <Ask />
    <Notes />
    <Close />
  </AbsoluteFill>
);
