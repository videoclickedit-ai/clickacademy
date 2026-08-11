-- CapCutController (macOS adapter)
-- Implements the contract described in /shared/types/capcut-controller.d.ts
-- Zero external dependencies: pure AppleScript + System Events (built into macOS).
--
-- Requires: System Settings > Privacy & Security > Accessibility must allow
-- "Terminal" (or whatever app runs osascript) to control your computer.
-- macOS will prompt for this automatically on first run.

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

-- ---------- Strategy A: clipboard paste ----------
-- Copies the image to the system clipboard as image data and sends Cmd+V
-- to the frontmost CapCut window. This is the least invasive strategy: it
-- makes no assumption about CapCut's menu/accessibility tree, only that
-- pasting an image into the media panel is supported (needs to be verified).
on tryImportViaClipboard(filePath)
	try
		set imgFile to POSIX file filePath
		set the clipboard to (read imgFile as «class PNGf»)
	on error errText
		log "[CapCut] Clipboard copy step failed: " & errText
		return false
	end try

	tell application "System Events"
		if not (exists process capcutAppName) then return false
		tell process capcutAppName
			set frontmost to true
			delay 0.4
			keystroke "v" using command down
		end tell
	end tell
	delay 1
	return true -- "sent", not proof of import — caller must confirm visually for this spike
end tryImportViaClipboard

-- ---------- Strategy D: fallback ----------
-- Reveals the file in Finder so the user (or a later manual step) has zero
-- searching to do. Used when automated strategies fail or are unverified.
on revealInFinder(filePath)
	tell application "Finder"
		activate
		reveal (POSIX file filePath)
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

	log "[CapCut] Importing asset via clipboard paste (Strategy A)..."
	log "[IMPORT_ATTEMPTED strategy=clipboard]"
	set sent to tryImportViaClipboard(filePath)

	if sent then
		log "[Click Tools] Cmd+V sent to CapCut."
		log "[Click Tools] MANUAL CHECK REQUIRED: look at CapCut now — did the image land in the media panel / timeline?"
		log "[Click Tools] Report back: YES it appeared -> Strategy A works, we can automate confirmation next."
		log "[Click Tools] Report back: NO nothing happened -> Strategy A is not viable, move to Strategy C (menu/accessibility) with real UI element names."
	else
		log "[FAILED] Could not send paste command to CapCut"
		revealInFinder(filePath)
	end if
end run
