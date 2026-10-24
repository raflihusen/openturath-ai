import { TransitionSeries, linearTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { Pembuka } from "./scenes/Pembuka";
import { Pertanyaan } from "./scenes/Pertanyaan";
import { Jawaban } from "./scenes/Jawaban";
import { Perpustakaan } from "./scenes/Perpustakaan";
import { DelapanBelasAI } from "./scenes/DelapanBelasAI";
import { Penutup } from "./scenes/Penutup";
import "./tema";

/** Video pengenalan OpenTurath: 6 adegan, 1080 x 1920, 30 fps. */
export const OpenTurathIntro: React.FC = () => (
  <TransitionSeries>
    <TransitionSeries.Sequence name="Pembuka" durationInFrames={130}>
      <Pembuka />
    </TransitionSeries.Sequence>
    <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: 18 })} />
    <TransitionSeries.Sequence name="Pertanyaan" durationInFrames={165}>
      <Pertanyaan />
    </TransitionSeries.Sequence>
    <TransitionSeries.Transition presentation={slide({ direction: "from-right" })} timing={linearTiming({ durationInFrames: 18 })} />
    <TransitionSeries.Sequence name="Jawaban" durationInFrames={210}>
      <Jawaban />
    </TransitionSeries.Sequence>
    <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: 18 })} />
    <TransitionSeries.Sequence name="Perpustakaan" durationInFrames={200}>
      <Perpustakaan />
    </TransitionSeries.Sequence>
    <TransitionSeries.Transition presentation={slide({ direction: "from-bottom" })} timing={linearTiming({ durationInFrames: 18 })} />
    <TransitionSeries.Sequence name="18 AI" durationInFrames={210}>
      <DelapanBelasAI />
    </TransitionSeries.Sequence>
    <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: 18 })} />
    <TransitionSeries.Sequence name="Penutup" durationInFrames={170}>
      <Penutup />
    </TransitionSeries.Sequence>
  </TransitionSeries>
);
