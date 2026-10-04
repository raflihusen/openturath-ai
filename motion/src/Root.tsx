import React from "react";
import { Composition } from "remotion";
import { LoaderLoop } from "./LoaderLoop";
import { LoginEntrance } from "./LoginEntrance";
import { SplashIntro } from "./SplashIntro";
import { FPS, LOADER, ms, SPLASH, ThemeName } from "./spec";

const themes: ThemeName[] = ["light", "dark"];

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {themes.map((theme) => (
        <React.Fragment key={theme}>
          <Composition
            id={`SplashIntro-${theme}`}
            component={SplashIntro}
            defaultProps={{ theme }}
            width={390}
            height={844}
            fps={FPS}
            durationInFrames={ms(SPLASH.total) + ms(600)}
          />
          <Composition
            id={`LoaderLoop-${theme}`}
            component={LoaderLoop}
            defaultProps={{ theme }}
            width={240}
            height={240}
            fps={FPS}
            durationInFrames={ms(LOADER.loop) * 3}
          />
          <Composition
            id={`LoginEntrance-${theme}`}
            component={LoginEntrance}
            defaultProps={{ theme }}
            width={390}
            height={844}
            fps={FPS}
            durationInFrames={ms(4000)}
          />
        </React.Fragment>
      ))}
    </>
  );
};
