import { ManuscriptFilm } from "./manuscript/ManuscriptFilm";
import { AktifKembaliFilm } from "./aktifkembali/AktifKembaliFilm";
import { Act1MarginStatement } from "./manuscript/Act1MarginStatement";
import { Act2SplitComparison } from "./manuscript/Act2SplitComparison";
import { Act3MacroIbarah } from "./manuscript/Act3MacroIbarah";
import { Act4FihrisIndex } from "./manuscript/Act4FihrisIndex";
import { Act5MonographFinale } from "./manuscript/Act5MonographFinale";
import { OpenTurathJejakIlmu } from "./jejak/Film";
import { OpenTurathProductFilm } from "./productfilm/Film";
import { OpenTurath18Ilmu } from "./productfilm/CatalogFilm";
import { PromoProFilm } from "./promopro/PromoProFilm";
import { KineticAct1Spark } from "./promopro/KineticAct1Spark";
import { KineticAct2Matrix } from "./promopro/KineticAct2Matrix";
import { KineticAct3Showcase3D } from "./promopro/KineticAct3Showcase3D";
import { KineticAct4DisciplinesWall } from "./promopro/KineticAct4DisciplinesWall";
import { KineticAct5Finale } from "./promopro/KineticAct5Finale";
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
    <Composition
      id="OpenTurathAktifKembali9x16"
      component={AktifKembaliFilm}
      durationInFrames={720}
      width={1080}
      height={1920}
      fps={60}
    />
    <Folder name="Manuscript">
      <Composition
        id="OpenTurathManuscript9x16"
        component={ManuscriptFilm}
        durationInFrames={1560}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="OpenTurathManuscript16x9"
        component={ManuscriptFilm}
        durationInFrames={1560}
        width={1920}
        height={1080}
        fps={60}
      />
      <Composition
        id="Manuscript-01-Margin"
        component={Act1MarginStatement}
        durationInFrames={270}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="Manuscript-02-SplitMazhab"
        component={Act2SplitComparison}
        durationInFrames={420}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="Manuscript-03-MacroIbarah"
        component={Act3MacroIbarah}
        durationInFrames={330}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="Manuscript-04-Fihris"
        component={Act4FihrisIndex}
        durationInFrames={300}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="Manuscript-05-Finale"
        component={Act5MonographFinale}
        durationInFrames={240}
        width={1080}
        height={1920}
        fps={60}
      />
    </Folder>
    <Folder name="PromoPro">
      <Composition
        id="OpenTurathPromoPro9x16"
        component={PromoProFilm}
        durationInFrames={1440}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="OpenTurathPromoPro16x9"
        component={PromoProFilm}
        durationInFrames={1440}
        width={1920}
        height={1080}
        fps={60}
      />
      <Composition
        id="Kinetic-01-SparkPortal"
        component={KineticAct1Spark}
        durationInFrames={240}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="Kinetic-02-3DKitabMatrix"
        component={KineticAct2Matrix}
        durationInFrames={240}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="Kinetic-03-3DAppShowcase"
        component={KineticAct3Showcase3D}
        durationInFrames={420}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="Kinetic-04-18DisciplinesWall"
        component={KineticAct4DisciplinesWall}
        durationInFrames={300}
        width={1080}
        height={1920}
        fps={60}
      />
      <Composition
        id="Kinetic-05-ShockwaveFinale"
        component={KineticAct5Finale}
        durationInFrames={240}
        width={1080}
        height={1920}
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
