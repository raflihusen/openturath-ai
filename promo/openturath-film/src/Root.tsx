import { Composition } from "remotion";
import { Film } from "./Film";
import { DURATION, FPS } from "./theme";

export const RemotionRoot: React.FC = () => (
  <>
    <Composition id="OpenTurathVertical" component={Film} durationInFrames={DURATION} fps={FPS} width={1080} height={1920} />
    <Composition id="OpenTurathWide" component={Film} durationInFrames={DURATION} fps={FPS} width={1920} height={1080} />
  </>
);
