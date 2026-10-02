import * as THREE from "three";
import { mergeGeometries } from "three/examples/jsm/utils/BufferGeometryUtils.js";
import { COLS, HERO_COL, HERO_ROW, ROWS, TITLES } from "../titles";
import { F } from "../theme";

// ---------- deterministic layout ----------
let seed = 20261002;
const rand = () => {
  seed = (seed * 1664525 + 1013904223) % 4294967296;
  return seed / 4294967296;
};

export const WALL_Z = -8;
export const BOOK_DEPTH = 0.86;
export const rowBottom = (r: number) => (ROWS / 2 - 0.5 - r) * 1.7 - 0.72;

const SHADES = [
  { bg: "#151515", fg: "#cfcfcf" },
  { bg: "#1d1d1d", fg: "#d6d6d6" },
  { bg: "#262626", fg: "#d9d9d9" },
  { bg: "#2f2f2f", fg: "#e0e0e0" },
  { bg: "#3b3b3b", fg: "#e6e6e6" },
  { bg: "#565656", fg: "#f0f0f0" },
  { bg: "#bdbdbb", fg: "#262626" },
  { bg: "#dcdad5", fg: "#202020" },
];

export type Book = {
  i: number;
  row: number;
  col: number;
  x: number; // center
  y: number; // center
  z: number; // center
  w: number; // spine width (x)
  h: number; // height (y)
  title: string;
  shade: (typeof SHADES)[number];
  hero: boolean;
};

export const BOOKS: Book[] = [];
export const ROW_WIDTH: number[] = [];
for (let r = 0; r < ROWS; r++) {
  const widths: number[] = [];
  for (let c = 0; c < COLS; c++) {
    const hero = r === HERO_ROW && c === HERO_COL;
    widths.push(hero ? 0.3 : 0.17 + rand() * 0.15);
  }
  const gap = 0.014;
  const total = widths.reduce((a, b) => a + b, 0) + gap * (COLS - 1);
  ROW_WIDTH.push(total);
  let x = -total / 2;
  for (let c = 0; c < COLS; c++) {
    const i = r * COLS + c;
    const hero = r === HERO_ROW && c === HERO_COL;
    const w = widths[c];
    const h = hero ? 1.3 : 1.02 + rand() * 0.36;
    const shadeIdx = hero ? 0 : Math.floor(rand() * rand() * SHADES.length * 1.0);
    BOOKS.push({
      i,
      row: r,
      col: c,
      x: x + w / 2,
      y: rowBottom(r) + h / 2,
      z: WALL_Z - BOOK_DEPTH / 2 + (hero ? 0.02 : rand() * 0.07),
      w,
      h,
      title: TITLES[i],
      shade: SHADES[Math.min(shadeIdx, SHADES.length - 1)],
      hero,
    });
    x += w + gap;
  }
}
export const HERO = BOOKS.find((b) => b.hero)!;

// ---------- spine atlas ----------
const CW = 160; // cell width (px)
const CH = 480; // cell height (px)
const AW = (COLS + 1) * CW;
const AH = ROWS * CH;
const STRIP = 8;

const contentWidth = (b: Book) => Math.min(CW - STRIP - 4, Math.round((CH * b.w) / b.h));

const drawSpine = (
  ctx: CanvasRenderingContext2D,
  x0: number,
  y0: number,
  cw: number,
  ch: number,
  b: { title: string; shade: { bg: string; fg: string } },
  big = false,
) => {
  ctx.save();
  ctx.fillStyle = b.shade.bg;
  ctx.fillRect(x0, y0, cw, ch);
  // subtle cloth gradient
  const g = ctx.createLinearGradient(x0, 0, x0 + cw, 0);
  g.addColorStop(0, "rgba(0,0,0,0.28)");
  g.addColorStop(0.35, "rgba(255,255,255,0.05)");
  g.addColorStop(1, "rgba(0,0,0,0.32)");
  ctx.fillStyle = g;
  ctx.fillRect(x0, y0, cw, ch);
  // classic bands
  ctx.strokeStyle = b.shade.fg;
  ctx.globalAlpha = 0.55;
  ctx.lineWidth = Math.max(1.5, ch * 0.004);
  for (const f of [0.075, 0.1, 0.9, 0.925]) {
    ctx.beginPath();
    ctx.moveTo(x0 + 4, y0 + ch * f);
    ctx.lineTo(x0 + cw - 4, y0 + ch * f);
    ctx.stroke();
  }
  ctx.globalAlpha = 1;
  // title, rotated (reads top to bottom)
  const maxLen = ch * 0.68;
  let size = Math.min(cw * (big ? 0.5 : 0.56), big ? 120 : 52);
  ctx.font = `600 ${size}px ${F.arabic}`;
  const m = ctx.measureText(b.title).width;
  if (m > maxLen) {
    size *= maxLen / m;
    ctx.font = `600 ${size}px ${F.arabic}`;
  }
  ctx.translate(x0 + cw / 2, y0 + ch / 2);
  ctx.rotate(Math.PI / 2);
  ctx.direction = "rtl";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  ctx.fillStyle = b.shade.fg;
  ctx.fillText(b.title, 0, size * 0.08);
  ctx.restore();
};

const drawPaper = (ctx: CanvasRenderingContext2D, x0: number, y0: number, w: number, h: number) => {
  ctx.fillStyle = "#dedcd6";
  ctx.fillRect(x0, y0, w, h);
  ctx.strokeStyle = "rgba(0,0,0,0.08)";
  ctx.lineWidth = 1;
  for (let y = y0 + 2; y < y0 + h; y += 3) {
    ctx.beginPath();
    ctx.moveTo(x0, y);
    ctx.lineTo(x0 + w, y);
    ctx.stroke();
  }
};

const canvasTexture = (canvas: HTMLCanvasElement) => {
  const t = new THREE.CanvasTexture(canvas);
  t.colorSpace = THREE.SRGBColorSpace;
  t.anisotropy = 8;
  t.generateMipmaps = true;
  t.minFilter = THREE.LinearMipmapLinearFilter;
  return t;
};

export const buildShelfGeometry = () => {
  const canvas = document.createElement("canvas");
  canvas.width = AW;
  canvas.height = AH;
  const ctx = canvas.getContext("2d")!;
  const px = COLS * CW;
  drawPaper(ctx, px, 0, CW, CH);

  const parts: THREE.BufferGeometry[] = [];
  for (const b of BOOKS) {
    const x0 = b.col * CW;
    const y0 = b.row * CH;
    const cw = contentWidth(b);
    drawSpine(ctx, x0, y0, cw, CH, b);
    if (b.hero) continue;
    const g = new THREE.BoxGeometry(b.w, b.h, BOOK_DEPTH);
    const uv = g.attributes.uv as THREE.BufferAttribute;
    const set = (face: number, ua: number, ub: number, va: number, vb: number) => {
      for (let k = 0; k < 4; k++) {
        const idx = face * 4 + k;
        const u = uv.getX(idx);
        const v = uv.getY(idx);
        uv.setXY(idx, (ua + u * (ub - ua)) / AW, 1 - (va + (1 - v) * (vb - va)) / AH);
      }
    };
    set(4, x0, x0 + cw, y0, y0 + CH); // +z : spine
    set(0, x0 + CW - STRIP, x0 + CW, y0, y0 + CH); // +x cover edge
    set(1, x0 + CW - STRIP, x0 + CW, y0, y0 + CH); // -x
    set(2, px + 8, px + CW - 8, 8, CH - 8); // +y paper
    set(3, px + 8, px + CW - 8, 8, CH - 8); // -y
    set(5, px + 8, px + CW - 8, 8, CH - 8); // -z
    g.translate(b.x, b.y, b.z);
    parts.push(g);
  }
  // paint the strip of each cell with the book colour (for cover edges)
  for (const b of BOOKS) {
    ctx.fillStyle = b.shade.bg;
    ctx.fillRect(b.col * CW + CW - STRIP, b.row * CH, STRIP, CH);
  }
  const geometry = mergeGeometries(parts, false)!;
  return { geometry, texture: canvasTexture(canvas) };
};

// ---------- hero book textures ----------
export const HERO_TITLE = "منهاج الطالبين";
export const HERO_FULL = "منهاج الطالبين وعمدة المفتين في الفقه";
export const HERO_AUTHOR = "أبو زكريا محيي الدين يحيى بن شرف النووي";

export const buildHeroTextures = () => {
  // spine (portrait, same look as the shelf, a little richer)
  const sp = document.createElement("canvas");
  sp.width = 256;
  sp.height = Math.round((256 * HERO.h) / HERO.w);
  drawSpine(sp.getContext("2d")!, 0, 0, sp.width, sp.height, HERO, true);

  // front cover: W = BOOK_DEPTH, H = HERO.h
  const cv = document.createElement("canvas");
  cv.width = 1024;
  cv.height = Math.round((1024 * HERO.h) / BOOK_DEPTH);
  const c = cv.getContext("2d")!;
  const W = cv.width;
  const H = cv.height;
  c.fillStyle = HERO.shade.bg;
  c.fillRect(0, 0, W, H);
  const rg = c.createRadialGradient(W * 0.45, H * 0.35, 10, W * 0.5, H * 0.5, H * 0.75);
  rg.addColorStop(0, "rgba(255,255,255,0.06)");
  rg.addColorStop(1, "rgba(0,0,0,0.35)");
  c.fillStyle = rg;
  c.fillRect(0, 0, W, H);
  c.strokeStyle = "#bfbfbf";
  c.lineWidth = 4;
  c.strokeRect(54, 54, W - 108, H - 108);
  c.lineWidth = 1.5;
  c.strokeRect(70, 70, W - 140, H - 140);
  c.direction = "rtl";
  c.textAlign = "center";
  c.fillStyle = "#e4e4e4";
  c.font = `600 150px ${F.arabic}`;
  c.fillText("منهاج", W / 2, H * 0.36);
  c.fillText("الطالبين", W / 2, H * 0.36 + 170);
  c.font = `400 56px ${F.arabic}`;
  c.fillStyle = "#bdbdbd";
  c.fillText("وعمدة المفتين في الفقه", W / 2, H * 0.36 + 290);
  c.beginPath();
  c.moveTo(W * 0.4, H * 0.66);
  c.lineTo(W * 0.6, H * 0.66);
  c.strokeStyle = "#9a9a9a";
  c.lineWidth = 2;
  c.stroke();
  c.font = `400 50px ${F.arabic}`;
  c.fillText("للإمام النووي", W / 2, H * 0.74);

  // open pages: abstract text lines only (no invented content)
  const pg = document.createElement("canvas");
  pg.width = 1024;
  pg.height = Math.round((1024 * HERO.h) / BOOK_DEPTH);
  const p = pg.getContext("2d")!;
  p.fillStyle = "#e9e7e2";
  p.fillRect(0, 0, pg.width, pg.height);
  p.fillStyle = "rgba(20,20,20,0.55)";
  let s2 = 11;
  const r2 = () => {
    s2 = (s2 * 16807) % 2147483647;
    return s2 / 2147483647;
  };
  const top = 150;
  for (let y = top; y < pg.height - 150; y += 46) {
    const isLast = r2() < 0.12;
    const len = isLast ? 0.3 + r2() * 0.4 : 0.92 + r2() * 0.08;
    const right = pg.width - 110;
    const w = (pg.width - 220) * len;
    // words as short bars, right-aligned (RTL)
    let x = right;
    while (x > right - w) {
      const ww = 30 + r2() * 90;
      p.fillRect(Math.max(right - w, x - ww), y, Math.min(ww, x - (right - w)), 12);
      x -= ww + 16;
    }
  }
  return {
    spine: canvasTexture(sp),
    cover: canvasTexture(cv),
    page: canvasTexture(pg),
  };
};

export const buildNoteTexture = (primary: boolean) => {
  const cv = document.createElement("canvas");
  cv.width = 720;
  cv.height = 960;
  const c = cv.getContext("2d")!;
  c.fillStyle = "#fafafa";
  c.fillRect(0, 0, 720, 960);
  c.fillStyle = "#171717";
  c.font = `600 30px ${F.sans}`;
  c.textAlign = "left";
  c.direction = "ltr";
  c.fillStyle = "#606060";
  c.fillText("CATATAN", 56, 86);
  c.fillStyle = "#dadada";
  c.fillRect(56, 112, 608, 2);
  if (primary) {
    c.direction = "rtl";
    c.textAlign = "right";
    c.fillStyle = "#171717";
    c.font = `600 76px ${F.arabic}`;
    c.fillText(HERO_TITLE, 664, 236);
    c.font = `400 38px ${F.arabic}`;
    c.fillStyle = "#606060";
    c.fillText(HERO_AUTHOR, 664, 314);
  }
  c.fillStyle = "rgba(23,23,23,0.16)";
  for (let k = 0; k < 9; k++) {
    const y = (primary ? 400 : 190) + k * 52;
    const w = k % 4 === 3 ? 300 : 608;
    c.fillRect(664 - w, y, w, 14);
  }
  return canvasTexture(cv);
};
