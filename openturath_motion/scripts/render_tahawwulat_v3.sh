#!/bin/bash
set -e

PROJ_DIR="/Users/apple/Downloads/remotion-fikih-tahawwulat-v3"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
OUT_DIR="$PROJ_DIR/out"

mkdir -p "$OUT_DIR"

echo "=========================================================="
echo " [1/4] MEMULAI RENDER EPISODE 1: Hadis Jibril & Ummus Sunnah"
echo " (Durasi: 18.371 frames / ~10.2 Menit)"
echo "=========================================================="
npx --prefix "$PROJ_DIR" remotion render \
  "$PROJ_DIR/src/index.ts" \
  Episode1-HadisJibrilDanUmmusSunnah \
  "$OUT_DIR/episode-1.mp4" \
  --concurrency=2 \
  --image-format=jpeg \
  --browser-executable="$CHROME"

echo "=========================================================="
echo " [2/4] MEMULAI RENDER EPISODE 2: Wilayah & Lima Cabang Ilmu"
echo " (Durasi: 16.418 frames / ~9.1 Menit)"
echo "=========================================================="
npx --prefix "$PROJ_DIR" remotion render \
  "$PROJ_DIR/src/index.ts" \
  Episode2-WilayahDanLimaCabangIlmu \
  "$OUT_DIR/episode-2.mp4" \
  --concurrency=2 \
  --image-format=jpeg \
  --browser-executable="$CHROME"

echo "=========================================================="
echo " [3/4] MEMULAI RENDER EPISODE 3: Peta Waktu, Rambu & Sikap"
echo " (Durasi: 18.661 frames / ~10.3 Menit)"
echo "=========================================================="
npx --prefix "$PROJ_DIR" remotion render \
  "$PROJ_DIR/src/index.ts" \
  Episode3-PetaWaktuRambuDanSikap \
  "$OUT_DIR/episode-3.mp4" \
  --concurrency=2 \
  --image-format=jpeg \
  --browser-executable="$CHROME"

echo "=========================================================="
echo " [4/4] MENGGABUNGKAN KETIGA EPISODE MENJADI MASTER LENGKAP"
echo " (Total: 53.450 frames / ~29.7 Menit via Stream Copy)"
echo "=========================================================="
cat << 'EOF' > "$OUT_DIR/concat_list.txt"
file 'episode-1.mp4'
file 'episode-2.mp4'
file 'episode-3.mp4'
EOF

ffmpeg -y -f concat -safe 0 -i "$OUT_DIR/concat_list.txt" -c copy "$OUT_DIR/master-v3.mp4"
rm "$OUT_DIR/concat_list.txt"

echo "=========================================================="
echo " ALHAMDULILLAH! SELURUH VIDEO TELAH SELESAI DIRENDER:"
echo " 1. $OUT_DIR/episode-1.mp4"
echo " 2. $OUT_DIR/episode-2.mp4"
echo " 3. $OUT_DIR/episode-3.mp4"
echo " 4. $OUT_DIR/master-v3.mp4"
echo "=========================================================="
