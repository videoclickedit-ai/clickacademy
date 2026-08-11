#!/usr/bin/env bash
# Quick real-world test (a taste of FASE 2, done manually before the bridge
# exists): image URL -> download -> CapCut, reusing the same macOS
# CapCutController spike script.
#
# Usage:
#   ./send-url-to-capcut.sh                  (prompts for the URL — avoids
#                                              shell-quoting issues with
#                                              URLs containing & or spaces)
#   ./send-url-to-capcut.sh "https://..."     (or pass it directly, quoted)
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Este script es para macOS."
  exit 1
fi

if [[ $# -ge 1 ]]; then
  URL="$1"
else
  read -r -p "Pegá la URL de la imagen y apretá Enter: " URL
fi

if [[ -z "$URL" ]]; then
  echo "[FAILED] No pegaste ninguna URL."
  exit 1
fi

# Downloads go to a dedicated Click Tools folder, not inside the git repo.
OUT_DIR="$HOME/Downloads/ClickTools"
mkdir -p "$OUT_DIR"

EXT="${URL##*.}"
EXT="${EXT%%\?*}"
case "$EXT" in
  jpg|jpeg|png|webp) ;;
  *) EXT="jpg" ;;
esac

TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)"
OUT="$OUT_DIR/click_asset_${TIMESTAMP}.${EXT}"

echo "[Click Tools] Downloading image..."
curl -sL --max-time 20 -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15" "$URL" -o "$OUT" || true

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
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
osascript "$DIR/../../bridge/src/platform/macos/capcut-controller.applescript" "$OUT"
