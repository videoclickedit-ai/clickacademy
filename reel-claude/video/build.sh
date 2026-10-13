#!/usr/bin/env bash
# Renderiza el reel completo: frames (Chromium) + SFX/voz (numpy) -> ../render/reel-claude.mp4
set -euo pipefail
cd "$(dirname "$0")"
node render.js
python3 sfx.py
mkdir -p ../render
ffmpeg -y -v error -i out/video.mp4 -i out/audio.wav \
  -map 0:v -map 1:a -c:v copy -af "loudnorm=I=-14:TP=-1:LRA=11" -c:a aac -b:a 192k -ar 48000 \
  -movflags +faststart -shortest ../render/reel-claude.mp4
echo "ok ../render/reel-claude.mp4"
