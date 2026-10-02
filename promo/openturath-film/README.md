# OpenTurath promo film

Editable 30-second vertical motion graphics film built with Remotion. The composition uses the OpenTurath logo, two existing app screenshots, and the Newsreader and Inter fonts already shipped with the app.

## Preview and render

```sh
npm install
npm run dev
npx remotion render src/index.ts OpenTurathPromo out/openturath-promo-vertical.mp4 --codec h264
```

Composition: 1080 × 1920, 30 fps, 900 frames. On-screen copy stays visible without audio. The ending asks viewers to check AI answers against the cited book.

## Assets

The screenshots and logo are copies of files from the OpenTurath workspace. The included font license files are from the app's font assets. No third-party music or stock footage is used.

Remotion's licensing terms vary with team size and use. See [Remotion license and pricing](https://www.remotion.dev/docs/license/pricing).
