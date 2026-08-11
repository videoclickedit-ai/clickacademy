#!/usr/bin/env bash
# Quick real-world test (a taste of FASE 2, done manually before the bridge
# exists): image URL -> download -> CapCut, reusing the same macOS
# CapCutController spike script.
#
# Usage:
#   ./send-url-to-capcut.sh "https://example.com/imagen.jpg"
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Uso: ./send-url-to-capcut.sh \"URL_DE_LA_IMAGEN\""
  exit 1
fi

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Este script es para macOS."
  exit 1
fi

URL="$1"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EXT="${URL##*.}"
EXT="${EXT%%\?*}"
case "$EXT" in
  jpg|jpeg|png|webp) ;;
  *) EXT="jpg" ;;
esac

TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)"
OUT="$DIR/click_asset_${TIMESTAMP}.${EXT}"

echo "[Click Tools] Downloading image..."
curl -sL --max-time 20 "$URL" -o "$OUT" || true

if [[ ! -s "$OUT" ]]; then
  echo "[FAILED] La descarga quedó vacía. ¿La URL es correcta?"
  rm -f "$OUT"
  exit 1
fi

if ! file "$OUT" | grep -qi "image"; then
  echo "[FAILED] Lo descargado no parece ser una imagen válida:"
  file "$OUT"
  rm -f "$OUT"
  exit 1
fi

echo "[Click Tools] Saved: $OUT"
echo ""
osascript "$DIR/../../bridge/src/platform/macos/capcut-controller.applescript" "$OUT"
