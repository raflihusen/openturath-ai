#!/usr/bin/env bash
# ==============================================================================
# OpenTurath AI - Script Otomatis Rollback Checkpoint
# Penggunaan: ./rollback.sh [NAMA_TAG]
# ==============================================================================

set -e

cd "$(dirname "$0")/openturath_ai"

TARGET_TAG="$1"

if [ -z "$TARGET_TAG" ]; then
  echo "📋 Daftar Checkpoint Tersedia:"
  echo "--------------------------------------------------------"
  git tag -l -n3 --sort=-creatordate
  echo "--------------------------------------------------------"
  echo ""
  echo "Cara pakai:"
  echo "  ./rollback.sh <nama_tag>"
  echo ""
  echo "Contoh:"
  echo "  ./rollback.sh v1.0.8-ideal"
  exit 0
fi

# Pastikan tag valid
if ! git rev-parse "$TARGET_TAG" >/dev/null 2>&1; then
  echo "❌ Tag '$TARGET_TAG' tidak ditemukan di Git!"
  exit 1
fi

echo "⚠️  PERINGATAN: Anda akan mengembalikan kode ke checkpoint: $TARGET_TAG"
echo "   Perubahan yang belum tersimpan akan dibersihkan."
read -p "Lanjutkan rollback? (y/N): " CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  git reset --hard "$TARGET_TAG"
  echo ""
  echo "✅ Kode berhasil di-rollback ke checkpoint: $TARGET_TAG"
  echo "   Status repositori sekarang bersih pada titik tersebut."
else
  echo "Dibatalkan."
fi
