/**
 * Monotone cubic interpolation through keyframes [frame, value].
 * Smooth velocity across keys (no jolts between camera moves), no overshoot.
 */
export const track = (frame: number, keys: [number, number][]): number => {
  const n = keys.length;
  if (frame <= keys[0][0]) return keys[0][1];
  if (frame >= keys[n - 1][0]) return keys[n - 1][1];
  const xs = keys.map((k) => k[0]);
  const ys = keys.map((k) => k[1]);
  const d: number[] = [];
  for (let i = 0; i < n - 1; i++) d.push((ys[i + 1] - ys[i]) / (xs[i + 1] - xs[i]));
  const m: number[] = new Array(n).fill(0);
  m[0] = 0; // ease in from rest
  m[n - 1] = 0; // ease out to rest
  for (let i = 1; i < n - 1; i++) {
    if (d[i - 1] * d[i] <= 0) m[i] = 0;
    else {
      const w1 = 2 * (xs[i + 1] - xs[i]) + (xs[i] - xs[i - 1]);
      const w2 = (xs[i + 1] - xs[i]) + 2 * (xs[i] - xs[i - 1]);
      m[i] = (w1 + w2) / (w1 / d[i - 1] + w2 / d[i]);
    }
  }
  let i = 0;
  while (frame > xs[i + 1]) i++;
  const h = xs[i + 1] - xs[i];
  const t = (frame - xs[i]) / h;
  const t2 = t * t;
  const t3 = t2 * t;
  return (
    (2 * t3 - 3 * t2 + 1) * ys[i] +
    (t3 - 2 * t2 + t) * h * m[i] +
    (-2 * t3 + 3 * t2) * ys[i + 1] +
    (t3 - t2) * h * m[i + 1]
  );
};
