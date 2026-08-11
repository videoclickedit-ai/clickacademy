-- CapCutController (macOS adapter)
-- Implements the contract described in /shared/types/capcut-controller.d.ts
-- Zero external dependencies: pure AppleScript + System Events (built into macOS).
--
-- Requires: System Settings > Privacy & Security > Accessibility must allow
-- "Terminal" (or whatever app runs osascript) to control your computer.
-- macOS will prompt for this automatically on first run.
--
-- ===== FASE 1 findings (documented, not guessed) =====
-- - CapCut's native macOS menu bar IS scriptable: Archivo/File > Importar
--   exists as a real menu item (Cmd+I), but that only opens CapCut's OWN
--   "Archivos multimedia" browser screen, not the OS file picker.
-- - That screen's inner "Importar" button, and CapCut's window content in
--   general, is NOT exposed to macOS Accessibility (confirmed: System
--   Events scans of its windows come back empty). CapCut renders its UI
--   with a custom toolkit that doesn't implement NSAccessibility for
--   internal widgets, so we can't click that button by name.
-- - The native "Selecciona un recurso multimedia" Open panel that the
--   button opens IS a real, fully accessible NSOpenPanel — but automating
--   "Go to Folder" (Cmd+Shift+G) inside it, including setting its text
--   field's value directly, repeatedly failed in live testing (kept
--   landing on the panel's default folder instead of the target file).
--   The exact cause wasn't pinned down after several attempts, and rather
--   than keep guessing at increasingly fragile keyboard/focus workarounds,
--   we changed approach entirely (see below).
--
-- ===== Resulting design =====
-- Skip automating CapCut's import UI altogether. Instead: reveal the
-- downloaded file in Finder, already selected, and ask the user to drag
-- it into CapCut themselves — one simple, completely standard macOS
-- action that works regardless of CapCut's accessibility support, since
-- it's the user's own hand doing the drag, not a script pretending to be
-- one. This also naturally covers dropping straight onto the timeline if
-- the user wants, without needing fragile coordinate automation for that
-- either.

use AppleScript version "2.4"
use scripting additions

property capcutAppName : "CapCut"

-- ---------- Contract: isCapCutRunning() ----------
on isCapCutRunning()
	tell application "System Events"
		return (exists (processes where name is capcutAppName))
	end tell
end isCapCutRunning

-- ---------- Contract: focusCapCut() ----------
on focusCapCut()
	if not isCapCutRunning() then return false
	tell application capcutAppName to activate
	delay 0.8
	tell application "System Events"
		return (frontmost of process capcutAppName)
	end tell
end focusCapCut

-- ---------- Contract: importImage(filePath) ----------
-- Reveals the file in Finder, pre-selected, and asks the user to drag it
-- into CapCut. Automation ends here — the drag itself is manual by design.
on revealInFinder(filePath)
	tell application "Finder"
		activate
		reveal (POSIX file filePath)
		try
			select (POSIX file filePath)
		end try
	end tell
	return true
end revealInFinder

-- ---------- Entry point for the FASE 1 spike ----------
-- Usage: osascript capcut-controller.applescript /absolute/path/to/test.png
on run argv
	if (count of argv) is 0 then
		log "[FAILED] No file path provided"
		error "Usage: osascript capcut-controller.applescript <absolute-path-to-image>"
	end if
	set filePath to item 1 of argv

	log "[Click Tools] Image detected: " & filePath

	if not isCapCutRunning() then
		log "[CapCut] Application NOT detected"
		log "[FAILED] CapCut is not running. Open CapCut with a project and try again."
		revealInFinder(filePath)
		return
	end if
	log "[CapCut] Application detected"
	log "[CAPCUT_DETECTED]"

	set didFocus to focusCapCut()
	if didFocus then
		log "[CapCut] Focused"
	else
		log "[CapCut] Could not confirm focus (continuing anyway)"
	end if

	revealInFinder(filePath)
	log "[Click Tools] Finder opened with the image already selected."
	log "[IMPORT_ATTEMPTED strategy=manual-fallback]"

	try
		display notification "Arrastrá la imagen (ya seleccionada en Finder) hacia CapCut" with title "Click Tools" subtitle "Un solo arrastre y listo"
	end try

	log "[Click Tools] MANUAL CHECK REQUIRED: arrastrá la imagen desde Finder hacia CapCut (al panel de medios o directo a la línea de tiempo)."
	log "[Click Tools] Report back: YES si se importó bien -> este es nuestro flujo para FASE 2."
	log "[Click Tools] Report back: NO / algo raro -> contame exactamente qué pasó."
end run
