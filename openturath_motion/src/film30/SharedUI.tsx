import React from "react";
import { Icon, InkCard, TahawwulatScreen, U } from "../film60/AppUI";

// Derived directly from the approved film60 reconstruction and source materials.
export const QuoteCard: React.FC<{ compact?: boolean }> = ({
  compact = false,
}) => (
  <div
    style={{
      width: 360,
      boxSizing: "border-box",
      borderLeft: "2px solid #BDBDBD",
      padding: compact ? "8px 14px" : "12px 16px",
      background: "#fff",
      borderRadius: "0 10px 10px 0",
      color: U.ink,
    }}
  >
    <div
      lang="ar"
      dir="rtl"
      style={{
        fontFamily: "Scheherazade New, serif",
        fontSize: compact ? 24 : 26,
        lineHeight: 1.75,
        textAlign: "right",
      }}
    >
      «وَإِذَا أَفْضَى الرَّجُلُ بِيَدِهِ إلَى امْرَأَتِهِ أَوْ بِبَعْضِ
      جَسَدِهِ إلَى بَعْضِ جَسَدِهَا لَا حَائِلَ بَيْنَهُ وَبَيْنَهَا بِشَهْوَةٍ
      أَوْ بِغَيْرِ شَهْوَةٍ وَجَبَ عَلَيْهِ الْوُضُوءُ…»
    </div>
    <div
      lang="ar"
      dir="rtl"
      style={{
        fontFamily: "Scheherazade New, serif",
        fontSize: 20,
        color: "#666",
        marginTop: 6,
      }}
    >
      الأم ج١، ص٢٩-٣٠
    </div>
  </div>
);

export const CatalogRow: React.FC = () => (
  <div
    dir="rtl"
    lang="ar"
    style={{
      width: 384,
      height: 144,
      boxSizing: "border-box",
      background: U.paper,
      borderTop: `1px solid ${U.border}`,
      padding: "12px 3px",
      fontFamily: "Scheherazade New, serif",
      color: U.ink,
      textAlign: "right",
    }}
  >
    <div style={{ display: "flex", gap: 10, alignItems: "baseline" }}>
      <span style={{ fontSize: 22, lineHeight: 1.5, fontWeight: 600, flex: 1 }}>
        الأم
      </span>
      <span style={{ fontSize: 13, lineHeight: 1.5, color: "#777" }}>٣</span>
    </div>
    <div style={{ fontSize: 17, lineHeight: 1.5, color: "#666", marginTop: 4 }}>
      الإمام الشافعي
    </div>
    <div
      style={{
        display: "flex",
        gap: 18,
        color: "#777",
        fontSize: 14,
        lineHeight: 1.5,
        marginTop: 5,
      }}
    >
      <span>ت ٢٠٤ هـ</span>
      <span>المجلدات: ٨</span>
    </div>
  </div>
);

export const NoteCard: React.FC = () => (
  <div
    style={{
      width: 380,
      height: 110,
      boxSizing: "border-box",
      padding: 20,
      background: "#fff",
      border: `1px solid ${U.border}`,
      borderRadius: 20,
      color: U.ink,
      fontFamily: U.fontOutfit,
    }}
  >
    <span
      style={{
        fontSize: 11,
        background: U.subtle,
        borderRadius: 20,
        padding: "3px 8px",
      }}
    >
      Fikih Syafi’i
    </span>
    <div style={{ fontSize: 16, fontWeight: 600, marginTop: 10 }}>
      Hukum bersentuhan kulit
    </div>
    <div
      style={{
        fontSize: 12,
        color: U.muted,
        marginTop: 5,
        overflow: "hidden",
        whiteSpace: "nowrap",
        textOverflow: "ellipsis",
      }}
    >
      Menurut mazhab Syafi’i, bertemunya kulit laki-laki dengan perempuan
      non-mahram membatalkan wudhu.
    </div>
  </div>
);

export const AssistantTile: React.FC<{ title: string; arabic: string }> = ({
  title,
  arabic,
}) => (
  <div style={{ width: 180, height: 160, fontFamily: U.fontOutfit }}>
    <InkCard title={title} arabic={arabic} height={160} centered>
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          gap: 8,
          marginTop: 16,
          position: "relative",
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            width: 60,
            height: 42,
            borderRadius: 30,
            background: "#fff",
            color: U.ink,
          }}
        >
          <Icon name="chat" size={21} />
        </div>
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            width: 42,
            height: 42,
            borderRadius: 30,
            background: "rgba(255,255,255,.12)",
            color: "#fff",
          }}
        >
          <Icon name="book" size={21} />
        </div>
      </div>
    </InkCard>
  </div>
);

const roles = [
  ["Al-Muhaqqiq", "Telusuri teks kitab dan ibarah rujukan.", "research"],
  ["Al-Bayan", "Pahami konsep dan istilah dengan penjelasan ringkas.", "bulb"],
  ["Al-Mukhtabir", "Uji pemahaman lewat evaluasi konsep.", "quiz"],
  ["Al-Habib", "Telusuri arsip ceramah Habib Abu Bakar.", "mic"],
  ["Al-Khatib", "Susun bahan dakwah dan khutbah.", "edit"],
] as const;
const clamp = (v: number) => Math.min(1, Math.max(0, v));
export const RoleSheet: React.FC<{
  progress: number;
  focus: number;
  stagger: number;
}> = ({ progress, focus, stagger }) => (
  <div
    style={{
      width: 420,
      height: 820,
      position: "relative",
      overflow: "hidden",
      fontFamily: U.fontOutfit,
      color: U.ink,
    }}
  >
    <TahawwulatScreen />
    <div
      style={{
        position: "absolute",
        inset: 0,
        background: "rgba(0,0,0,.46)",
        opacity: clamp(progress),
        zIndex: 6,
      }}
    />
    <div
      style={{
        position: "absolute",
        left: 0,
        right: 0,
        bottom: 0,
        height: 694,
        transform: `translateY(${(1 - clamp(progress)) * 694}px)`,
        background: "#fff",
        borderRadius: "28px 28px 0 0",
        padding: "10px 24px 24px",
        boxSizing: "border-box",
        zIndex: 7,
      }}
    >
      <div
        style={{
          width: 32,
          height: 4,
          borderRadius: 4,
          background: "#bbb",
          margin: "0 auto 22px",
        }}
      />
      <div style={{ fontSize: 20, fontWeight: 600 }}>AI Fikih Tahawwulat</div>
      <div
        style={{ fontSize: 14, color: U.muted, marginTop: 8, marginBottom: 22 }}
      >
        Pilih AI sesuai kebutuhan penelusuran Anda.
      </div>
      {roles.map(([name, desc, icon], i) => {
        const p = clamp((stagger - i * 0.12) / 0.28);
        const eased = 1 - (1 - p) * (1 - p);
        return (
          <div
            key={name}
            style={{
              display: "flex",
              alignItems: "center",
              marginBottom: 10,
              padding: 16,
              borderRadius: 20,
              background: focus === i ? "#dedede" : U.subtle,
              gap: 14,
              minHeight: 68,
              boxSizing: "border-box",
              opacity: eased,
              transform: `translateY(${15 * (1 - eased)}px)`,
            }}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                width: 42,
                height: 42,
                borderRadius: 13,
                background: "#fff",
                flexShrink: 0,
              }}
            >
              <Icon name={icon} size={21} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600 }}>{name}</div>
              <div
                style={{
                  fontSize: 12,
                  lineHeight: 1.35,
                  color: U.muted,
                  marginTop: 4,
                }}
              >
                {desc}
              </div>
            </div>
            <Icon name="arrow" size={18} />
          </div>
        );
      })}
    </div>
  </div>
);
