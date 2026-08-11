# Windows adapter — pending

Not implemented yet. This project starts with the macOS adapter (see `../macos/`) because that's
where the FASE 1 spike is being validated first.

When it's time to build this adapter, it must implement the same contract as the macOS one
(`shared/types/capcut-controller.d.ts`):

- `isCapCutRunning()`
- `focusCapCut()`
- `importImage(filePath)`

Likely approach: PowerShell + `System.Windows.Automation` (UI Automation) for detection/focus,
with the same strategy order as macOS (clipboard paste first, UI Automation second, manual
fallback last). Needs its own spike against a real Windows CapCut install before being trusted.
