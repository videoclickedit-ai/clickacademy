#!/usr/bin/env bash
# Render completo: frames (Chromium) + SFX/voz (numpy) + mezcla a -14 LUFS -> <proyecto>/out/final.mp4
# Uso: bash build.sh <proyecto>
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PROJ="$(cd "${1:-.}" && pwd)"
node "$HERE/render.js" "$PROJ"
python3 "$HERE/sfx.py" "$PROJ"
ffmpeg -y -v error -i "$PROJ/out/video.mp4" -i "$PROJ/out/audio.wav" \
  -map 0:v -map 1:a -c:v copy -af "loudnorm=I=-14:TP=-1:LRA=11" -c:a aac -b:a 192k -ar 48000 \
  -movflags +faststart -shortest "$PROJ/out/final.mp4"
echo "ok $PROJ/out/final.mp4"
