# OpenTurath promo film

Editable 30-second vertical brand film built with Remotion and Three.js. The film combines a frame-animated 3D book, moving light and particles, kinetic typography, and the OpenTurath logo with real app screenshots in a perspective device frame.

## Preview and render

```sh
npm install
npm run dev
npx remotion render src/index.ts OpenTurathPromo out/openturath-promo-vertical.mp4 --codec h264
```

Composition: 1080 × 1920, 30 fps, 900 frames. The cut introduces the brand, shows Beranda and Asisten, highlights Catatan, and closes with the OpenTurath wordmark and CTA. It is designed to read without sound; there is no music or voiceover track. The closing asks viewers to check AI answers against the cited book.

## Assets

The screenshots and logo are copies of files from the OpenTurath workspace. The included font license files are from the app's font assets. No third-party music or stock footage is used.

Remotion's licensing terms vary with team size and use. See [Remotion license and pricing](https://www.remotion.dev/docs/license/pricing).
