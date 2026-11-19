import fs from "node:fs";
import path from "node:path";

const SAMPLE_RATE = 48000;
const DURATION_SEC = 26.0;
const NUM_SAMPLES = Math.floor(SAMPLE_RATE * DURATION_SEC);

const left = new Float32Array(NUM_SAMPLES);
const right = new Float32Array(NUM_SAMPLES);

let seed = 14480519;
const rand = () => {
  seed = (seed * 1664525 + 1013904223) >>> 0;
  return (seed / 0xffffffff) * 2 - 1;
};

const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));

const mixStereo = (idx, s, pan = 0) => {
  if (idx < 0 || idx >= NUM_SAMPLES) return;
  const lGain = Math.cos(((pan + 1) * Math.PI) / 4);
  const rGain = Math.sin(((pan + 1) * Math.PI) / 4);
  left[idx] += s * lGain;
  right[idx] += s * rGain;
};

// Karplus-Strong physical string model for a warm wooden oud pluck.
const addOudPluck = (startSec, freq, durSec = 2.4, gain = 0.28, pan = 0, brightness = 0.42) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(durSec * SAMPLE_RATE);
  const delayLen = Math.max(16, Math.round(SAMPLE_RATE / freq));
  const ring = new Float32Array(delayLen);

  // Soft thumb-pick excitation burst shaped with a low-pass smoothing pass.
  let lp = 0;
  for (let i = 0; i < delayLen; i++) {
    const raw = rand() * Math.sin((Math.PI * i) / delayLen);
    lp += brightness * (raw - lp);
    ring[i] = lp;
  }

  let ptr = 0;
  const decay = 0.9962;
  for (let i = 0; i < len; i++) {
    const nextPtr = (ptr + 1) % delayLen;
    const sample = ring[ptr];
    ring[ptr] = 0.5 * (sample + ring[nextPtr]) * decay;
    ptr = nextPtr;

    const t = i / SAMPLE_RATE;
    const bodyResonance = Math.sin(2 * Math.PI * freq * 0.5 * t) * Math.exp(-t * 5.2) * 0.14;
    const env = Math.min(1, t / 0.008) * Math.min(1, (durSec - t) / 0.12);
    mixStereo(start + i, (sample * 1.45 + bodyResonance) * env * gain, pan);
  }
};

// Low bowed cello drone built from gently detuned odd/even harmonics.
const addCelloBed = (startSec, durSec, freq, gain = 0.11) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(durSec * SAMPLE_RATE);
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const env =
      Math.min(1, t / 0.85) *
      Math.min(1, (durSec - t) / 1.0) *
      (0.92 + 0.08 * Math.sin(2 * Math.PI * 0.28 * t));
    const vib = 1 + 0.0028 * Math.sin(2 * Math.PI * 4.6 * t);
    const f = freq * vib;
    const base =
      Math.sin(2 * Math.PI * f * t) * 0.62 +
      Math.sin(2 * Math.PI * f * 2 * t) * 0.24 +
      Math.sin(2 * Math.PI * f * 3 * t) * 0.1 +
      Math.sin(2 * Math.PI * f * 4 * t) * 0.04;
    const stereoDrift = Math.sin(2 * Math.PI * (f * 1.0018) * t + 0.6) * 0.55;
    if (start + i >= 0 && start + i < NUM_SAMPLES) {
      left[start + i] += base * env * gain;
      right[start + i] += (base * 0.65 + stereoDrift * 0.35) * env * gain;
    }
  }
};

// Acoustic frame drum (daf) strike with warm skin pitch drop.
const addDafDum = (startSec, gain = 0.42, pitch = 68, pan = 0) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(0.55 * SAMPLE_RATE);
  let phase = 0;
  let skinLp = 0;
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const freq = pitch + 46 * Math.exp(-t * 24);
    phase += (2 * Math.PI * freq) / SAMPLE_RATE;
    const skin = Math.sin(phase) * Math.exp(-t * 7.2);
    const overtone = Math.sin(phase * 1.58) * Math.exp(-t * 15) * 0.22;
    skinLp += 0.14 * (rand() - skinLp);
    const slap = skinLp * Math.exp(-t * 65) * 0.35;
    const s = (skin + overtone + slap) * Math.min(1, t / 0.004) * gain;
    mixStereo(start + i, s, pan);
  }
};

// Soft rim tap on wooden frame drum for scholarly rhythm pulses.
const addDafTak = (startSec, gain = 0.16, pan = 0.2) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(0.11 * SAMPLE_RATE);
  let prev = 0;
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const n = rand();
    const hp = n - prev * 0.82;
    prev = n;
    const wood =
      Math.sin(2 * Math.PI * 520 * t) * 0.45 +
      Math.sin(2 * Math.PI * 1240 * t) * 0.25;
    const s = (wood + hp * 0.38) * Math.exp(-t * 58) * gain;
    mixStereo(start + i, s, pan);
  }
};

// Paper page-turn foley using band-shaped noise sweep.
const addPaperTurn = (startSec, durSec = 0.36, gain = 0.18, pan = 0) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(durSec * SAMPLE_RATE);
  let lp1 = 0;
  let lp2 = 0;
  for (let i = 0; i < len; i++) {
    const u = i / len;
    const env = Math.pow(Math.sin(Math.PI * u), 1.3);
    const cutoff = 0.06 + 0.22 * Math.sin(Math.PI * u);
    const n = rand();
    lp1 += cutoff * (n - lp1);
    lp2 += cutoff * 0.45 * (lp1 - lp2);
    const rustle = (lp1 - lp2) * (0.7 + 0.3 * Math.sin(u * 32));
    mixStereo(start + i, rustle * env * gain * 2.2, pan + (u - 0.5) * 0.4);
  }
};

// Subtle fountain-pen / soft tactile keystroke click.
const addTactileTap = (startSec, freq = 960, gain = 0.18, pan = 0) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(0.03 * SAMPLE_RATE);
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const s =
      (Math.sin(2 * Math.PI * freq * t) * 0.65 +
        Math.sin(2 * Math.PI * freq * 2.1 * t) * 0.35) *
      Math.exp(-t * 145) *
      gain;
    mixStereo(start + i, s, pan);
  }
};

// Maqam Nahawand in D (D3, E3, F3, G3, A3, Bb3, C4, D4, E4, F4).
const N = {
  D2: 73.42,
  A2: 110.0,
  Bb2: 116.54,
  C3: 130.81,
  D3: 146.83,
  E3: 164.81,
  F3: 174.61,
  G3: 196.0,
  A3: 220.0,
  Bb3: 233.08,
  C4: 261.63,
  D4: 293.66,
  E4: 329.63,
  F4: 349.23,
  A4: 440.0,
};

// Act 1 (0.0s - 4.5s): Archival paper opening with paper turn and solo oud phrase.
addPaperTurn(0.08, 0.42, 0.22, -0.2);
addCelloBed(0.15, 4.35, N.D2, 0.11);
addOudPluck(0.25, N.D3, 2.4, 0.3, -0.15, 0.38);
addOudPluck(1.05, N.A3, 2.0, 0.24, 0.15, 0.42);
addOudPluck(1.75, N.G3, 1.8, 0.22, -0.1, 0.38);
addOudPluck(2.42, N.F3, 2.1, 0.28, 0.1, 0.44); // Line 2 reveal ("Kita butuh ibarah kitabnya.")
addOudPluck(3.15, N.E3, 1.5, 0.2, -0.15, 0.36);
addPaperTurn(3.85, 0.45, 0.24, 0.25);

// Act 2 (4.5s - 11.5s): Asymmetric split-canvas comparison at steady 90 BPM acoustic groove.
addDafDum(4.5, 0.44, 66, 0);
addCelloBed(4.5, 3.6, N.Bb2, 0.11);
addCelloBed(8.0, 3.2, N.A2, 0.11);

const beat = 60 / 90; // 0.6667s per beat
for (let b = 0; b < 10; b++) {
  const t = 4.5 + b * beat;
  if (b % 2 === 0 && b > 0) addDafDum(t, 0.32, 70, -0.1);
  addDafTak(t + beat * 0.5, 0.14, b % 2 === 0 ? 0.25 : -0.25);
}

// Soft organic typing cues during question entry (4.9s - 6.3s).
for (let k = 0; k < 8; k++) {
  addTactileTap(4.92 + k * 0.16, 860 + (k % 3) * 90, 0.11, (k % 2 - 0.5) * 0.25);
}

// Oud counterpoint answering the two mazhab panels.
addOudPluck(4.65, N.D3, 1.8, 0.22, -0.25);
addOudPluck(5.98, N.F3, 1.8, 0.22, 0.25);
addPaperTurn(7.15, 0.38, 0.22, 0); // Split divider shifts up for Syafi'i / Jumhur panels
addDafDum(7.25, 0.38, 64, 0);
addOudPluck(7.32, N.A3, 2.1, 0.26, -0.2, 0.46);
addOudPluck(8.0, N.Bb3, 1.8, 0.22, 0.2, 0.42);
addOudPluck(8.66, N.A3, 1.8, 0.22, -0.15, 0.4);
addPaperTurn(9.2, 0.34, 0.2, -0.2); // Jumhur comparison opens
addOudPluck(9.33, N.G3, 1.9, 0.24, 0.2, 0.42);
addOudPluck(10.0, N.F3, 1.6, 0.2, -0.2, 0.38);
addOudPluck(10.66, N.E3, 1.2, 0.18, 0.1, 0.34);

// Intentional 0.4s acoustic breath (11.15s - 11.55s) before Act 3 Ibarah focus.

// Act 3 (11.5s - 17.0s): Full-page classical Arabic ibarah focus.
addPaperTurn(11.45, 0.36, 0.24, 0);
addDafDum(11.55, 0.42, 62, 0);
addCelloBed(11.6, 5.4, N.D2, 0.13);
addOudPluck(11.6, N.D4, 3.2, 0.3, 0, 0.46);
addOudPluck(12.6, N.A3, 2.8, 0.24, -0.25, 0.42);
addOudPluck(13.65, N.F3, 2.6, 0.22, 0.25, 0.4);
addOudPluck(14.7, N.E3, 2.4, 0.2, -0.15, 0.38);
// Crisp tactile click right when "Salin ibarah" inverts to solid ink (f 915 = 15.25s).
addTactileTap(15.25, 1320, 0.32, 0);
addOudPluck(15.32, N.A3, 2.2, 0.22, 0.15, 0.44);

// Act 4 (17.0s - 22.0s): Fihris (index of 18 disciplines) rhythmic stepping.
addDafDum(17.0, 0.44, 68, 0);
addCelloBed(17.0, 5.0, N.G3 * 0.5, 0.11);
const indexNotes = [N.D3, N.F3, N.G3, N.A3, N.Bb3, N.A3, N.G3, N.F3];
for (let step = 0; step < 8; step++) {
  const t = 17.0 + step * 0.6;
  addTactileTap(t, 1080 + step * 35, 0.18, (step % 2 === 0 ? -0.2 : 0.2));
  addOudPluck(t + 0.04, indexNotes[step], 1.2, 0.22, (step % 2 === 0 ? -0.25 : 0.25), 0.45);
  if (step % 2 === 0) addDafDum(t, 0.3, 72, 0);
  else addDafTak(t, 0.16, 0.2);
}

// Act 5 (22.0s - 26.0s): Dignified ink-expansion finale and warm acoustic resolve.
addDafDum(22.0, 0.52, 58, 0);
addCelloBed(22.0, 4.0, N.D2, 0.15);
addOudPluck(22.04, N.D3, 3.8, 0.3, -0.2, 0.4);
addOudPluck(22.18, N.A3, 3.6, 0.26, 0.2, 0.42);
addOudPluck(22.34, N.D4, 3.5, 0.28, 0, 0.45);

// Warm room reflection tap delay to seat acoustic instruments in a natural hall.
const d1 = Math.floor(0.115 * SAMPLE_RATE);
const d2 = Math.floor(0.21 * SAMPLE_RATE);
for (let i = 0; i < NUM_SAMPLES; i++) {
  if (i >= d1) {
    left[i] += right[i - d1] * 0.18;
    right[i] += left[i - d1] * 0.16;
  }
  if (i >= d2) {
    left[i] += left[i - d2] * 0.1;
    right[i] += right[i - d2] * 0.1;
  }
}

for (let i = 0; i < NUM_SAMPLES; i++) {
  const t = i / SAMPLE_RATE;
  const fadeOut = t > DURATION_SEC - 1.5 ? Math.max(0, (DURATION_SEC - t) / 1.5) : 1;
  left[i] = Math.tanh(left[i] * 1.1) * 0.9 * fadeOut;
  right[i] = Math.tanh(right[i] * 1.1) * 0.9 * fadeOut;
}

const outDir = path.resolve(process.cwd(), "public/manuscript");
fs.mkdirSync(outDir, { recursive: true });
const outPath = path.join(outDir, "scholarly_acoustics.wav");

const dataBytes = NUM_SAMPLES * 4;
const buf = Buffer.alloc(44 + dataBytes);
buf.write("RIFF", 0);
buf.writeUInt32LE(36 + dataBytes, 4);
buf.write("WAVE", 8);
buf.write("fmt ", 12);
buf.writeUInt32LE(16, 16);
buf.writeUInt16LE(1, 20);
buf.writeUInt16LE(2, 22);
buf.writeUInt32LE(SAMPLE_RATE, 24);
buf.writeUInt32LE(SAMPLE_RATE * 4, 28);
buf.writeUInt16LE(4, 32);
buf.writeUInt16LE(16, 34);
buf.write("data", 36);
buf.writeUInt32LE(dataBytes, 40);

let offset = 44;
for (let i = 0; i < NUM_SAMPLES; i++) {
  buf.writeInt16LE(Math.round(clamp(left[i], -1, 1) * 32767), offset);
  buf.writeInt16LE(Math.round(clamp(right[i], -1, 1) * 32767), offset + 2);
  offset += 4;
}

fs.writeFileSync(outPath, buf);
console.log(`Generated ${outPath} (${(buf.length / 1024 / 1024).toFixed(2)} MB, ${DURATION_SEC}s)`);
