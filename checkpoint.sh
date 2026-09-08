#!/usr/bin/env bash
# ==============================================================================
# OpenTurath AI - Script Otomatis Pembuat Checkpoint
# Penggunaan: ./checkpoint.sh "Deskripsi perubahan / fitur"
# ==============================================================================

set -e

MSG="$1"
if [ -z "$MSG" ]; then
  echo "⚠️  Harap sertakan pesan checkpoint!"
  echo "   Contoh: ./checkpoint.sh \"versi stabil sebelum ubah webview\""
  exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CLEAN_SLUG=$(echo "$MSG" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//')
TAG_NAME="cp_${TIMESTAMP}_${CLEAN_SLUG}"

# Masuk ke direktori project openturath_ai
cd "$(dirname "$0")/openturath_ai"

echo "📌 [1/3] Menyimpan perubahan kode ke Git..."
git add .
git commit -m "checkpoint: $MSG" || echo "ℹ️  Tidak ada perubahan file baru untuk di-commit."

echo "🏷️  [2/3] Membuat Git Tag: $TAG_NAME..."
git tag -a "$TAG_NAME" -m "$MSG"

# Backup APK jika ada output rilis terbaru
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
  echo "📦 [3/3] Mengarsipkan file APK ke folder release_apk/..."
  mkdir -p ../release_apk
  APK_DEST="../release_apk/openturath_${TAG_NAME}.apk"
  cp build/app/outputs/flutter-apk/app-release.apk "$APK_DEST"
  echo "   ✅ APK tersimpan di: $APK_DEST"
else
  echo "ℹ️  [3/3] Tidak ada APK baru di build/app/outputs, hanya checkpoint kode yang dicatat."
fi

echo ""
echo "🎉 Checkpoint BERHASIL dibuat!"
echo "   Tag: $TAG_NAME"
echo "   Untuk rollback ke titik ini kapan saja, jalankan:"
echo "   ./rollback.sh $TAG_NAME"
