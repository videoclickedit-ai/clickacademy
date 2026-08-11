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

-- CapCut's File menu, localized. Confirmed via ui-inspector.applescript on a
-- Spanish macOS install: menu bar item "Archivo" -> menu item "Importar".
-- English installs presumably use "File" -> "Import" (not yet confirmed).
-- Known limitation: this is a hardcoded lookup table, not real i18n.
property fileMenuNames : {"Archivo", "File"}
property importItemNames : {"Importar", "Import"}

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

-- ---------- Strategy C: native File > Import menu + Open panel ----------
-- Confirmed via ui-inspector.applescript that CapCut has a real, scriptable
-- "Archivo > Importar" menu item. Clicking it opens the standard macOS Open
-- panel, which we drive with Cmd+Shift+G ("Go to Folder") since that lets us
-- jump straight to an exact file path instead of guessing button/column
-- names inside the panel.
on tryImportViaMenu(filePath)
	tell application "System Events"
		if not (exists process capcutAppName) then return false
		tell process capcutAppName
			set frontmost to true
			delay 0.3

			set clickedFile to false
			repeat with fName in fileMenuNames
				if exists menu bar item fName of menu bar 1 then
					try
						click menu bar item fName of menu bar 1
						delay 0.3
						repeat with iName in importItemNames
							if exists menu item iName of menu 1 of menu bar item fName of menu bar 1 then
								click menu item iName of menu 1 of menu bar item fName of menu bar 1
								set clickedFile to true
								exit repeat
							end if
						end repeat
					end try
				end if
				if clickedFile then exit repeat
			end repeat

			if not clickedFile then
				log "[CapCut] Could not find File > Import menu item (tried: " & fileMenuNames & " / " & importItemNames & ")"
				key code 53 -- Escape, in case a menu is still open
				return false
			end if
		end tell
	end tell

	delay 1.2 -- give the Open panel time to appear

	tell application "System Events"
		try
			keystroke "G" using {command down, shift down} -- "Go to Folder"
			delay 0.6
			keystroke filePath
			delay 0.3
			key code 36 -- Return: navigate to / select the file
			delay 0.8
			key code 36 -- Return: confirm the Open/Import button
		on error errText
			log "[CapCut] Open panel automation failed: " & errText
			return false
		end try
	end tell

	delay 1
	return true
end tryImportViaMenu

-- ---------- Strategy A: clipboard paste ----------
-- Copies the image to the system clipboard as image data and sends Cmd+V
-- to the frontmost CapCut window. Kept as a secondary attempt in case the
-- menu strategy fails for some reason — confirmed NOT sufficient on its own
-- during the FASE 1 spike (CapCut did not accept a bare Cmd+V paste).
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
	return true -- "sent", not proof of import
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

	log "[CapCut] Importing asset via File > Import menu (Strategy C)..."
	log "[IMPORT_ATTEMPTED strategy=accessibility-ui]"
	set menuWorked to tryImportViaMenu(filePath)

	if menuWorked then
		log "[Click Tools] Menu import sequence completed."
		log "[Click Tools] MANUAL CHECK REQUIRED: look at CapCut now — did the image land in the media panel / timeline?"
		log "[Click Tools] Report back: YES it appeared -> Strategy C works, this is our import path for FASE 2."
		log "[Click Tools] Report back: NO nothing happened / wrong dialog -> tell me exactly what you saw on screen."
	else
		log "[CapCut] Menu strategy failed, falling back to clipboard paste (Strategy A)..."
		log "[IMPORT_ATTEMPTED strategy=clipboard]"
		set sent to tryImportViaClipboard(filePath)
		if sent then
			log "[Click Tools] Cmd+V sent to CapCut as a fallback attempt."
			log "[Click Tools] MANUAL CHECK REQUIRED: look at CapCut now."
		else
			log "[FAILED] Both menu and clipboard strategies failed."
			revealInFinder(filePath)
		end if
	end if
end run
