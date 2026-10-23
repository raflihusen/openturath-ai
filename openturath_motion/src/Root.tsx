import { Composition, Folder } from "remotion";
import { OpenTurathIntro } from "./OpenTurathIntro";
import { Pembuka } from "./scenes/Pembuka";
import { Pertanyaan } from "./scenes/Pertanyaan";
import { Jawaban } from "./scenes/Jawaban";
import { Perpustakaan } from "./scenes/Perpustakaan";
import { DelapanBelasAI } from "./scenes/DelapanBelasAI";
import { Penutup } from "./scenes/Penutup";
import "./tema";
import { PromoLoop, PROMO_FPS, PROMO_FRAMES } from "./promo/PromoLoop";
import { KomposisiTahawwulat } from "./tahawwulat/Pengantar";
import { KomposisiV2 } from "./tahawwulat/v2/Pengantar";

const V = { width: 1080, height: 1920, fps: 30 } as const;

export const RemotionRoot: React.FC = () => (
  <>
    <Folder name="Adegan">
      <Composition id="Pembuka" component={Pembuka} durationInFrames={130} {...V} />
      <Composition id="Pertanyaan" component={Pertanyaan} durationInFrames={165} {...V} />
      <Composition id="Jawaban" component={Jawaban} durationInFrames={210} {...V} />
      <Composition id="Perpustakaan" component={Perpustakaan} durationInFrames={200} {...V} />
      <Composition id="DelapanBelasAI" component={DelapanBelasAI} durationInFrames={210} {...V} />
      <Composition id="Penutup" component={Penutup} durationInFrames={170} {...V} />
    </Folder>
    {/* 1085 bingkai adegan - 5 transisi x 18 = 995 bingkai (33,2 detik) */}
    <Composition id="OpenTurathIntro" component={OpenTurathIntro} durationInFrames={995} {...V} />
    <Composition id="PromoSegeraHadir" component={PromoLoop} durationInFrames={PROMO_FRAMES} fps={PROMO_FPS} width={1440} height={1440} />
    <KomposisiTahawwulat />
    <KomposisiV2 />
  </>
);
