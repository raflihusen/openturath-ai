/**
 * Procedural 120 BPM Cinematic Motion-Graphic Soundtrack & SFX Generator
 * For OpenTurath AI — "OpenTurathKinetic" (24.0s @ 60fps = 1440 frames)
 * Output: public/promopro/kinetic_120bpm.wav (48kHz, 16-bit Stereo PCM)
 */

import fs from "node:fs";
import path from "node:path";

const SAMPLE_RATE = 48000;
const DURATION_SEC = 24.0;
const NUM_SAMPLES = Math.floor(SAMPLE_RATE * DURATION_SEC);
const BPM = 120;
const BEAT_SEC = 60 / BPM; // 0.5s = 30 frames @ 60fps

const left = new Float32Array(NUM_SAMPLES);
const right = new Float32Array(NUM_SAMPLES);

// Deterministic PRNG for clean, repeatable noise/whoosh/percussion
let seed = 20261119;
const rand = () => {
  seed = (seed * 1664525 + 1013904223) >>> 0;
  return (seed / 0xffffffff) * 2 - 1;
};

const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));

const addSample = (idx, l, r) => {
  if (idx >= 0 && idx < NUM_SAMPLES) {
    left[idx] += l;
    right[idx] += r;
  }
};

// 1. Deep Sub-Impact Boom (for major cuts & finale)
const addSubImpact = (startSec, gain = 0.72, durSec = 1.15) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(durSec * SAMPLE_RATE);
  let phase = 0;
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const env = Math.exp(-t * 4.2) * Math.min(1, t / 0.004);
    const freq = 38 + 115 * Math.exp(-t * 18);
    phase += (2 * Math.PI * freq) / SAMPLE_RATE;
    const body = Math.sin(phase) + 0.25 * Math.sin(phase * 2) * Math.exp(-t * 12);
    const punch = rand() * Math.exp(-t * 75) * 0.22;
    const s = (body + punch) * env * gain;
    addSample(start + i, s, s);
  }
};

// 2. Tight Editorial Kick (120 BPM modern tech pulse)
const addKick = (startSec, gain = 0.45) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(0.24 * SAMPLE_RATE);
  let phase = 0;
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const env = Math.exp(-t * 15) * Math.min(1, t / 0.002);
    const freq = 46 + 130 * Math.exp(-t * 38);
    phase += (2 * Math.PI * freq) / SAMPLE_RATE;
    const s = Math.sin(phase) * env * gain;
    addSample(start + i, s, s);
  }
};

// 3. Crisp Micro-Percussion / Hi-hat Tick
const addTick = (startSec, gain = 0.14, pan = 0, bright = 1.0) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(0.055 * SAMPLE_RATE);
  let prev = 0;
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const env = Math.exp(-t * (65 + bright * 45));
    const n = rand();
    // Simple high-pass derivative for crisp metallic click
    const hp = n - prev * 0.85;
    prev = n;
    const tone = Math.sin(2 * Math.PI * (3400 + bright * 2200) * t) * 0.25;
    const s = (hp * 0.75 + tone) * env * gain;
    const lGain = Math.cos(((pan + 1) * Math.PI) / 4);
    const rGain = Math.sin(((pan + 1) * Math.PI) / 4);
    addSample(start + i, s * lGain, s * rGain);
  }
};

// 4. Tactile UI Click (Apple/Linear style wooden-glass click)
const addUiClick = (startSec, pitch = 1400, gain = 0.34, pan = 0) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(0.04 * SAMPLE_RATE);
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const env = Math.exp(-t * 130);
    const s =
      (Math.sin(2 * Math.PI * pitch * t) * 0.65 +
        Math.sin(2 * Math.PI * pitch * 2.38 * t) * 0.35) *
      env *
      gain;
    const lGain = Math.cos(((pan + 1) * Math.PI) / 4);
    const rGain = Math.sin(((pan + 1) * Math.PI) / 4);
    addSample(start + i, s * lGain, s * rGain);
  }
};

// 5. Filtered Noise Riser & Transition Whoosh
const addWhoosh = (centerSec, durSec = 0.65, gain = 0.32, sweepDir = 1) => {
  const start = Math.floor((centerSec - durSec * 0.6) * SAMPLE_RATE);
  const len = Math.floor(durSec * SAMPLE_RATE);
  let lp1 = 0;
  let lp2 = 0;
  for (let i = 0; i < len; i++) {
    const u = i / len;
    const env = Math.sin(Math.PI * Math.pow(u, 0.85));
    const cutoff =
      sweepDir > 0
        ? 0.02 + 0.32 * Math.pow(u, 2.1)
        : 0.34 - 0.3 * Math.pow(u, 1.4);
    const n = rand();
    lp1 += cutoff * (n - lp1);
    lp2 += cutoff * (lp1 - lp2);
    const bp = lp1 - lp2 * 0.55;
    const pan = (u * 2 - 1) * 0.45 * sweepDir;
    const lGain = Math.cos(((pan + 1) * Math.PI) / 4);
    const rGain = Math.sin(((pan + 1) * Math.PI) / 4);
    const s = bp * env * gain * 2.4;
    addSample(start + i, s * lGain, s * rGain);
  }
};

// 6. Plucked Modern-Modal Synth Note (clean, plucked glass/oud-harp hybrid)
const addPluck = (startSec, freq, durSec = 0.7, gain = 0.16, pan = 0) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(durSec * SAMPLE_RATE);
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const attack = Math.min(1, t / 0.006);
    const env = Math.exp(-t * 4.6) * attack;
    const bright = Math.exp(-t * 14);
    const s =
      (Math.sin(2 * Math.PI * freq * t) * 0.68 +
        Math.sin(2 * Math.PI * freq * 2 * t) * 0.24 * bright +
        Math.sin(2 * Math.PI * freq * 3 * t) * 0.12 * bright +
        Math.sin(2 * Math.PI * freq * 0.5 * t) * 0.14) *
      env *
      gain;
    const lGain = Math.cos(((pan + 1) * Math.PI) / 4);
    const rGain = Math.sin(((pan + 1) * Math.PI) / 4);
    addSample(start + i, s * lGain, s * rGain);
  }
};

// 7. Wide Warm Atmospheric Pad Chord
const addPadChord = (startSec, durSec, freqs, gain = 0.11) => {
  const start = Math.floor(startSec * SAMPLE_RATE);
  const len = Math.floor(durSec * SAMPLE_RATE);
  for (let i = 0; i < len; i++) {
    const t = i / SAMPLE_RATE;
    const u = i / len;
    const env =
      Math.min(1, t / 0.55) *
      Math.min(1, (durSec - t) / 0.75) *
      (0.88 + 0.12 * Math.sin(2 * Math.PI * 0.35 * t));
    let l = 0;
    let r = 0;
    for (let k = 0; k < freqs.length; k++) {
      const f = freqs[k];
      const detune = 1 + (k % 2 === 0 ? 0.0022 : -0.0022);
      const wL =
        Math.sin(2 * Math.PI * f * t) * 0.7 +
        Math.sin(2 * Math.PI * f * 2 * t) * 0.15;
      const wR =
        Math.sin(2 * Math.PI * f * detune * t + 0.7) * 0.7 +
        Math.sin(2 * Math.PI * f * 2 * detune * t + 0.4) * 0.15;
      l += wL;
      r += wR;
    }
    const scale = (gain / freqs.length) * env;
    addSample(start + i, l * scale, r * scale);
  }
};

// 8. Crystalline Harmonic Shimmer (for Ibarah Spotlight & Finale)
const addShimmer = (startSec, freqs, durSec = 1.6, gain = 0.15) => {
  freqs.forEach((f, idx) => {
    addPluck(startSec + idx * 0.045, f, durSec, gain, (idx - 1.5) * 0.35);
  });
};

// ========================
// MUSICAL COMPOSITION (D Minor Modern Cinematic — 120 BPM)
// ========================

// Pad Chord Progression across 24s (4-second harmonic chapters)
// Dm9 -> Bbmaj7 -> Gm9 -> Asus4/A -> Dm9 -> Dm(add9)
addPadChord(0.0, 4.3, [146.83, 220.0, 261.63, 329.63], 0.12); // Act 1: Dm9
addPadChord(4.0, 4.3, [116.54, 174.61, 220.0, 293.66], 0.13); // Act 2: Bbmaj7
addPadChord(8.0, 4.3, [98.0, 196.0, 233.08, 329.63], 0.13); // Act 3a: Gm9
addPadChord(12.0, 3.3, [110.0, 220.0, 293.66, 329.63], 0.14); // Act 3b: Asus4
addPadChord(15.0, 5.2, [146.83, 220.0, 293.66, 349.23, 440.0], 0.15); // Act 4: Dm high drive
addPadChord(20.0, 4.0, [73.42, 146.83, 220.0, 329.63, 440.0], 0.16); // Act 5: Grand Dm(add9) resolve

// Rhythmic Kick & Micro-Percussion Grid (120 BPM = 48 beats)
for (let b = 0; b < 44; b++) {
  const t = b * BEAT_SEC;

  // Act 1 (beats 0..7): suspenseful sparse ticks + beat 3 flash hit
  if (b >= 1 && b < 8) {
    addTick(t, 0.16, b % 2 === 0 ? -0.25 : 0.25, 0.8);
    if (b === 3 || b === 6) addKick(t, 0.42);
  }

  // Act 2 (beats 8..15): kinetic architectural groove
  if (b >= 8 && b < 16) {
    if (b % 2 === 0) addKick(t, 0.48);
    addTick(t, 0.12, -0.3, 0.6);
    addTick(t + BEAT_SEC * 0.5, 0.15, 0.3, 1.1);
    if (b % 4 === 3) addTick(t + BEAT_SEC * 0.75, 0.11, 0.15, 1.3);
  }

  // Act 3 (beats 16..29): focused modern product rhythm
  if (b >= 16 && b < 30) {
    if (b % 2 === 0) addKick(t, 0.46);
    if (b % 4 === 3) addKick(t + BEAT_SEC * 0.5, 0.32);
    addTick(t + BEAT_SEC * 0.25, 0.08, -0.35, 0.9);
    addTick(t + BEAT_SEC * 0.5, 0.14, 0.35, 1.2);
    addTick(t + BEAT_SEC * 0.75, 0.09, -0.15, 0.7);
  }

  // Act 4 (beats 30..39): high-energy 18-discipline kinetic climax
  if (b >= 30 && b < 40) {
    addKick(t, b % 2 === 0 ? 0.56 : 0.34);
    addTick(t, 0.13, -0.4, 1.0);
    addTick(t + BEAT_SEC * 0.25, 0.1, 0.2, 1.3);
    addTick(t + BEAT_SEC * 0.5, 0.18, 0.4, 1.4);
    addTick(t + BEAT_SEC * 0.75, 0.11, -0.2, 1.1);
  }
}

// Melodic Plucked Arpeggio Motif (fresh modern D-minor / E-Phrygian scholarly pulse)
const arpAct2 = [293.66, 349.23, 440.0, 523.25, 440.0, 349.23, 329.63, 293.66];
for (let i = 0; i < 16; i++) {
  const t = 4.0 + i * (BEAT_SEC * 0.5);
  addPluck(t, arpAct2[i % arpAct2.length], 0.55, 0.14, i % 2 === 0 ? -0.35 : 0.35);
}

const arpAct3 = [293.66, 440.0, 587.33, 523.25, 440.0, 392.0, 349.23, 329.63];
for (let i = 0; i < 24; i++) {
  const t = 8.0 + i * (BEAT_SEC * 0.5);
  addPluck(t, arpAct3[i % arpAct3.length], 0.5, 0.11, i % 2 === 0 ? 0.3 : -0.3);
}

const arpAct4 = [587.33, 659.25, 698.46, 880.0, 698.46, 659.25, 587.33, 440.0];
for (let i = 0; i < 20; i++) {
  const t = 15.0 + i * (BEAT_SEC * 0.5);
  addPluck(t, arpAct4[i % arpAct4.length], 0.48, 0.15, (i % 4 - 1.5) * 0.3);
}

// ========================
// FRAME-SYNCED CINEMATIC SFX (60fps -> seconds = frame / 60)
// ========================

// Major Impacts on every Scene Beat
addSubImpact(0 / 60, 0.72, 1.1); // Spark open
addSubImpact(90 / 60, 0.48, 0.65); // "TANPA RIUH" flash slam
addSubImpact(240 / 60, 0.75, 1.15); // Portal through Mihrab -> Act 2
addSubImpact(480 / 60, 0.72, 1.05); // 3D Flip into App -> Act 3
addSubImpact(900 / 60, 0.82, 1.25); // "18" Kinetic Stamp -> Act 4
addSubImpact(1200 / 60, 0.88, 1.8); // Grand Finale Logo Lockup -> Act 5

// Transition Whooshes / Risers
addWhoosh(234 / 60, 0.65, 0.36, 1);
addWhoosh(474 / 60, 0.58, 0.34, -1);
addWhoosh(894 / 60, 0.52, 0.38, 1);
addWhoosh(1194 / 60, 0.68, 0.4, -1);

// Precision UI SFX inside Act 3 (App Showcase)
addUiClick(515 / 60, 1480, 0.34, -0.2); // Tab click
addUiClick(575 / 60, 1760, 0.32, 0.25); // Send question pulse
for (let k = 0; k < 6; k++) {
  // 6 structured rukun items reveal ticks
  addUiClick((655 + k * 10) / 60, 1200 + k * 90, 0.2, (k % 2 === 0 ? -0.2 : 0.2));
}
addShimmer(756 / 60, [587.33, 880.0, 1174.66, 1318.51], 1.4, 0.14); // Ibarah card lift
addUiClick(840 / 60, 1920, 0.36, 0.0); // "Salin ibarah" click

// Grand Finale Shimmer
addShimmer(1204 / 60, [293.66, 440.0, 587.33, 880.0, 1174.66], 2.6, 0.15);

// ========================
// LIGHT STEREO DELAY + SOFT LIMITER + MASTER FADE
// ========================
const delaySamplesL = Math.floor(0.25 * SAMPLE_RATE); // 1/8th note delay
const delaySamplesR = Math.floor(0.375 * SAMPLE_RATE); // dotted 1/8th delay
for (let i = 0; i < NUM_SAMPLES; i++) {
  if (i >= delaySamplesL) left[i] += right[i - delaySamplesL] * 0.22;
  if (i >= delaySamplesR) right[i] += left[i - delaySamplesR] * 0.18;
}

// Soft saturation limiter + clean 1.5s tail fade-out
for (let i = 0; i < NUM_SAMPLES; i++) {
  const t = i / SAMPLE_RATE;
  const fadeOut = t > DURATION_SEC - 1.6 ? Math.max(0, (DURATION_SEC - t) / 1.6) : 1;
  left[i] = Math.tanh(left[i] * 1.15) * 0.9 * fadeOut;
  right[i] = Math.tanh(right[i] * 1.15) * 0.9 * fadeOut;
}

// Write 16-bit Stereo WAV
const outDir = path.resolve(process.cwd(), "public/promopro");
fs.mkdirSync(outDir, { recursive: true });
const outPath = path.join(outDir, "kinetic_120bpm.wav");

const dataBytes = NUM_SAMPLES * 4;
const buf = Buffer.alloc(44 + dataBytes);
buf.write("RIFF", 0);
buf.writeUInt32LE(36 + dataBytes, 4);
buf.write("WAVE", 8);
buf.write("fmt ", 12);
buf.writeUInt32LE(16, 16); // PCM chunk size
buf.writeUInt16LE(1, 20); // PCM format
buf.writeUInt16LE(2, 22); // Stereo
buf.writeUInt32LE(SAMPLE_RATE, 24);
buf.writeUInt32LE(SAMPLE_RATE * 4, 28);
buf.writeUInt16LE(4, 32);
buf.writeUInt16LE(16, 34);
buf.write("data", 36);
buf.writeUInt32LE(dataBytes, 40);

let offset = 44;
for (let i = 0; i < NUM_SAMPLES; i++) {
  const lInt = Math.round(clamp(left[i], -1, 1) * 32767);
  const rInt = Math.round(clamp(right[i], -1, 1) * 32767);
  buf.writeInt16LE(lInt, offset);
  buf.writeInt16LE(rInt, offset + 2);
  offset += 4;
}

fs.writeFileSync(outPath, buf);
console.log(`Generated ${outPath} (${(buf.length / 1024 / 1024).toFixed(2)} MB, ${DURATION_SEC}s @ ${SAMPLE_RATE}Hz)`);
