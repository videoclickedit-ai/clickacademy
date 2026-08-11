#!/usr/bin/env bash
# FASE 1 spike runner (macOS).
#
# Preconditions:
#   1. CapCut Desktop is open with a project already loaded.
#   2. This is your first time running an osascript automation -> macOS will
#      pop a permission dialog: System Settings > Privacy & Security >
#      Accessibility -> allow Terminal (or iTerm) to control your computer.
#      If you miss the dialog, add it manually and re-run.
#
# What it does:
#   1. Generates test.png next to this script.
#   2. Runs the macOS CapCutController spike: detect CapCut, focus it,
#      attempt Strategy A (clipboard paste import).
#   3. Prints structured logs you can read stage by stage.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This spike is the macOS adapter — run it on a Mac with CapCut installed."
  exit 1
fi

"$DIR/create-test-image.sh"

echo ""
echo "[Click Tools] Running CapCut spike..."
echo ""
osascript "$DIR/../../bridge/src/platform/macos/capcut-controller.applescript" "$DIR/test.png"
