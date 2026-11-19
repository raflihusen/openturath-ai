import { OpenTurathJejakIlmu } from "./jejak/Film";
import { OpenTurathProductFilm } from "./productfilm/Film";
import { OpenTurath18Ilmu } from "./productfilm/CatalogFilm";
import { PromoProFilm } from "./promopro/PromoProFilm";
import { Scene1Opening } from "./promopro/Scene1Opening";
import { Scene2Monograph } from "./promopro/Scene2Monograph";
import { Scene3ProductShowcase } from "./promopro/Scene3ProductShowcase";
import { Scene4Disciplines } from "./promopro/Scene4Disciplines";
import { Scene5Finale } from "./promopro/Scene5Finale";
import { JejakWorld3D } from "./jejak/World";
import { OpenTurathLaunch30 } from "./film30/Film";
import { OpenTurathFilm60 } from "./film60/Film";
import { ProductMotion } from "./motion_v2/Film";
import { PromoElegan } from "./elegan/PromoElegan";
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
    <Folder name="PromoPro">
      <Composition
        id="OpenTurathPromoPro16x9"
        component={PromoProFilm}
        durationInFrames={1800}
        width={1920}
        height={1080}
        fps={60}
      />
      <Composition
        id="OpenTurathPromoPro9x16"
        component={PromoProFilm}
        durationInFrames={1800}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="PromoPro-01-Pengantar"
        component={Scene1Opening}
        durationInFrames={336}
        width={1920}
        height={1080}
        fps={60}
      />
      <Composition
        id="PromoPro-02-RuangBaca"
        component={Scene2Monograph}
        durationInFrames={336}
        width={1920}
        height={1080}
        fps={60}
      />
      <Composition
        id="PromoPro-03-RujukanIbarah"
        component={Scene3ProductShowcase}
        durationInFrames={480}
        width={1920}
        height={1080}
        fps={60}
      />
      <Composition
        id="PromoPro-04-18BidangIlmu"
        component={Scene4Disciplines}
        durationInFrames={408}
        width={1920}
        height={1080}
        fps={60}
      />
      <Composition
        id="PromoPro-05-Penutup"
        component={Scene5Finale}
        durationInFrames={336}
        width={1920}
        height={1080}
        fps={60}
      />
    </Folder>
    <Composition id="OpenTurath18Ilmu" component={OpenTurath18Ilmu} durationInFrames={1800} width={1080} height={1920} fps={60} />
    <Composition id="OpenTurathProductFilm" component={OpenTurathProductFilm} durationInFrames={1800} width={1080} height={1920} fps={60} />
    <Composition id="JejakWorld3D" component={JejakWorld3D} durationInFrames={900} width={1080} height={1920} fps={30} />
    <Composition id="OpenTurathJejakIlmu" component={OpenTurathJejakIlmu} durationInFrames={900} width={1080} height={1920} fps={30} />
    <Composition id="OpenTurathLaunch30" component={OpenTurathLaunch30} durationInFrames={1800} width={1080} height={1920} fps={60} />
    <Composition id="OpenTurathFilm60" component={OpenTurathFilm60} durationInFrames={3600} width={1080} height={1920} fps={60} />
    <Composition id="OpenTurathMotionV2" component={ProductMotion} durationInFrames={1680} width={1920} height={1080} fps={60} />
    <Composition id="PromoElegan" component={PromoElegan} durationInFrames={900} {...V} />
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
